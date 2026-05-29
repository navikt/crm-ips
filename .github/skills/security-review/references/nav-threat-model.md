# Nav Threat Model — STRIDE, DPIA, auditlogg, Datatilsynet

Dyp referanse for trusselmodellering av Nav-applikasjoner. Brukes når SKILL.md eskalerer: ny datakategori, ny integrasjon, DPIA-behov, eller strukturert sikkerhetsgjennomgang før produksjonssetting.

## STRIDE tilpasset Nav-kontekst

STRIDE brukes her som sjekkliste, ikke som generisk akademisk øvelse. For hver kategori: hvilke *Nav-konkrete* angrepsflater og tiltak som gjelder.

### Spoofing (identitetsforfalskning)

**Nav-kontekst:** Angriper utgir seg for å være en bruker, en Nav-ansatt, eller en annen tjeneste i klyngen.

- [ ] Brukerautentisering via riktig IDP: ID-porten for innbyggere, Azure AD for ansatte, Maskinporten for eksterne M2M, TokenX for intern service-to-service på vegne av bruker.
- [ ] Token-validering validerer `iss`, `aud`, `exp`, `nbf` og signatur mot IDP-ens JWKS.
- [ ] For Azure AD M2M: `azp`-claim valideres mot `AZURE_APP_PRE_AUTHORIZED_APPS`. Uten denne sjekken kan hvilken som helst app i tenanten kalle tjenesten.
- [ ] Call-ID (`Nav-Call-Id`) propageres, men brukes *aldri* som autorisasjonsgrunnlag.
- [ ] For impersonering/on-behalf-of: Verifiser at originalbruker er riktig tema-bruker i `sub`/`pid`.

### Tampering (tukling)

**Nav-kontekst:** Endring av sak/vedtak/ytelsesdata underveis, enten i transit eller i databaser/kø.

- [ ] TLS på all trafikk (Nais default). Ingen plain HTTP til interne eller eksterne tjenester.
- [ ] Input-validering ved grensen (DTO med `@Valid`/schema), ikke bare i forretningslaget.
- [ ] Integritetskontroll ved mottak av eksterne meldinger (f.eks. signerte Kafka-meldinger der kontrakten krever det).
- [ ] Idempotens-nøkler på skrivende endepunkter som kan retries.
- [ ] Databaser: FKs og constraints håndhever invariantene; ingen appen "regner med" at data er gyldige.

### Repudiation (fornektelse)

**Nav-kontekst:** Bruker eller ansatt kan i ettertid hevde at en handling ikke ble utført, eller at visning av persondata ikke skjedde.

- [ ] CEF-auditlogg når Nav-ansatte ser personopplysninger (ikke ved hver API-sjekk — ved faktisk visning).
- [ ] Én handling = én auditlogglinje. Ingen tap i stille feil.
- [ ] Auditlogg inneholder: tidsstempel, handling (`audit:read/update/create/delete`), subjekt-ID (fnr/aktør), utfører (ansatt-UPN/e-post), request-path, beslutning (`Permit`/`Deny`).
- [ ] Auditlogg skrives til egen logger (`auditLogger`) med egen konfigurasjon — ikke blandet inn i applikasjonslogg.
- [ ] Vedtaks- og sakshistorikk har ikke-overskrivbare revisjoner (append-only eller event-sourcet), slik at "hvem gjorde hva når" kan rekonstrueres.

Se seksjonen [Audit-logging-krav](#audit-logging-krav-for-sensitive-personopplysninger) for detaljer.

### Information Disclosure (informasjonslekkasje)

**Nav-kontekst:** Den største restrisikoen for Nav-apper. Lekkasje kan skje via logger, feilmeldinger, browser-cache, URL-er, eller ukontrollert outbound.

- [ ] Ingen PII (fnr, navn, diagnose, ytelsesdata) i standardlogg. Se SKILL.md for klassifisering.
- [ ] Feilmeldinger til klient er generiske; detaljer logges med korrelasjons-ID, ikke returneres.
- [ ] Persondata aldri i URL-path eller query (kommer i access-logger, browser-historikk, referer-headers). Bruk body eller header.
- [ ] `accessPolicy.outbound` begrenser hvor appen kan sende data — begrens eksfiltrasjons-flater.
- [ ] Cache-Control: `no-store` på responser med personopplysninger.
- [ ] Secrets aldri i logger, error objects, exception-meldinger eller stack traces som eksponeres.
- [ ] Anonymiserte aggregater vurderes mot koblingsangrep (k-anonymitet ved små kohorter).

### Denial of Service

**Nav-kontekst:** Sjelden primær trussel for interne tjenester (Nais har resource limits), men offentlig eksponerte tjenester (sosialhjelp, søknader) må vurderes.

- [ ] Resource limits (`resources.limits`) satt i Nais-manifestet.
- [ ] Rate limiting på offentlig eksponerte og kostbare endepunkter.
- [ ] Grenser for request-størrelse og payload-dybde (f.eks. JSON-nesting) der eksternt input aksepteres.
- [ ] Filopplasting har både størrelses- og antallsbegrensning per bruker/sak.
- [ ] Kostbare databasespørringer har pagination og tidsbegrensning.

### Elevation of Privilege

**Nav-kontekst:** Eskalering fra innbygger til saksbehandler, fra saksbehandler til superbruker, eller fra én saksbehandler til en annens saksområde.

- [ ] Tilgangskontroll sjekker *eierskap/tilhørighet*, ikke bare autentisering (IDOR-test).
- [ ] Azure AD-grupper brukes for RBAC (`claims.groups`) — `allowAllUsers: false`.
- [ ] Kode 6/7 og egen ansatt håndteres som egne tilgangskontroll-branches, ikke antatt sjelden edge-case.
- [ ] `securityContext` i Nais (runAsNonRoot, readOnlyRootFilesystem, drop ALL capabilities) er ikke overstyrt.
- [ ] Admin-/supportfunksjoner krever eksplisitt rolle, har egen audit, og er ikke default i dev-miljø (unngå "glemte" bakdører).

## DPIA-prosess (Data Protection Impact Assessment)

### Når DPIA kreves

DPIA kreves før oppstart av behandling som sannsynligvis medfører høy risiko for den registrertes rettigheter (GDPR art. 35). I Nav-kontekst utløses DPIA typisk av:

- **Ny behandling av sensitive personopplysninger**: Helseopplysninger, barnevernsdata, biometri, genetiske data.
- **Stor skala**: Behandling som omfatter en betydelig andel av Navs brukermasse.
- **Systematisk overvåking**: Bruksanalyser, automatiserte beslutninger, profilering.
- **Sammenstilling av datasett**: Kombinering av kilder som hver for seg var avgrensede (f.eks. ytelse + helsedata + skatt).
- **Ny teknologi**: AI/ML-modeller som påvirker individ-beslutninger, nye lagrings-/prosesserings-paradigmer.
- **Vesentlig endring**: Eksisterende behandling endrer formål, datakategori, kilde, eller mottakergruppe.

Ved tvil: **spør Personvernombudet**. Utelatelse av DPIA ved plikt er selvstendig avvik.

### Hvem beslutter

- **Behandlingsansvarlig** (linjen, typisk produktområde/ytelseslinje) har ansvaret for at DPIA gjennomføres og dokumenteres.
- **Personvernombudet (PVO)** gir råd, skal konsulteres, og vurderer om DPIA-en er tilstrekkelig. PVO beslutter ikke *for* behandlingsansvarlig, men negativt PVO-råd som ikke følges må begrunnes skriftlig.
- **Datatilsynet** konsulteres i forkant kun hvis DPIA-en viser høy restrisiko som ikke lar seg avbøte (GDPR art. 36). Terskelen er høy — de fleste DPIAer ender uten forhåndsdrøfting.
- **Team/utvikler** bidrar med teknisk innhold: dataflyt, lagringslokasjoner, tilgangsmodell, sikkerhetstiltak, retention.

### DPIA-innhold (minimum)

1. Systematisk beskrivelse av behandlingen og formålet.
2. Vurdering av nødvendighet og proporsjonalitet mot formålet.
3. Vurdering av risiko for de registrertes rettigheter og friheter.
4. Tiltak for å redusere risiko (tekniske og organisatoriske).
5. Konsultasjon med PVO (og eventuelt berørte grupper).

DPIA er ikke et engangsdokument — den oppdateres når behandlingen endres.

## Audit-logging-krav for sensitive personopplysninger

### Hva skal logges

- **Visning**: Når en Nav-ansatt ser personopplysninger i en saksbehandler-flate. Logges ved faktisk vising, ikke ved hver bakgrunns-API-sjekk.
- **Endring**: Endringer i vedtak, registreringer, eller andre persondata som binder forvaltningen.
- **Oppretting og sletting**: Nye saker, anonymisering, retention-sletting.
- **Eksport/utlevering**: Uttrekk til eksterne mottakere, både automatiserte og ad hoc.
- **Beslutninger**: `Permit`/`Deny` når tilgang vurderes mot persondata med restriksjoner (kode 6/7, egen ansatt).

Ikke logg: listevisninger uten visning av persondetaljer, inkludentelle referanser (f.eks. antall-tellinger), eller rene helsesjekk-kall.

### Format

**CEF (Common Event Format)** for ArcSight. Én handling = én linje. Eksempel-struktur:

```
CEF:0|<application>|auditLog|1.0|<operation>|Sporingslogg|<severity>|end=<epoch-ms> duid=<subject-id> suid=<actor-id> request=<path> flexString1Label=Decision flexString1=<Permit|Deny>
```

- **Severity**: `INFO` for standard visning/endring, `WARN` for sensitive tilfeller (fortrolig/strengt fortrolig, egen ansatt).
- **Subject-ID (`duid`)**: Personen dataene handler om (fnr/aktør). I kildekode-eksempler skal dette være `00000000000` eller tydelig syntetisk testdata.
- **Actor-ID (`suid`)**: Nav-ansatt som utfører handlingen (UPN/e-post).

Separat logger-konfigurasjon (`auditLogger`) med egen appender — ikke blandet med applikasjonslogg.

### Hvor lenge

Oppbevaringstid for auditlogg følger arkivlov og Navs retningslinjer — typisk **flere år** (ofte minst 5, ofte lenger for persondata-relaterte handlinger). Team-nivå bestemmer ikke retention selv; følg Navs sentrale krav og avtal med Team Auditlogging.

Applikasjonens egne logger (ikke audit) har kortere retention og er ikke erstatning for auditlogg.

### Hvem får se

- **Team Auditlogging** forvalter auditlogg-pipelinen og har systemtilgang.
- **Oppslag i auditlogg** krever tjenstlig behov og dokumentert hjemmel. Typiske saker: innsynsbegjæringer fra bruker (GDPR art. 15), tilsynssaker, interne undersøkelser, PVO-gjennomganger.
- **Teamet selv** ser ikke egen auditlogg fritt — bestilling går via Team Auditlogging eller relevant prosesseier.
- **Bruker** har rett til innsyn i loggføring om seg selv etter prosess (ikke selvbetjent API).

## Kontakt med Datatilsynet

Datatilsynet er tilsynsmyndighet for personvernlovgivningen. Teamet kontakter *ikke* Datatilsynet direkte — det går alltid via Personvernombudet og behandlingsansvarlig.

### Når varsle — avviksmelding

**Brudd på personopplysningssikkerheten** (GDPR art. 33) skal meldes til Datatilsynet uten ugrunnet opphold og senest **innen 72 timer** etter at behandlingsansvarlig er blitt kjent med det, med mindre bruddet sannsynligvis ikke medfører risiko for den registrertes rettigheter og friheter.

Eksempler som typisk utløser varslingsplikt:

- Uautorisert tilgang til personopplysninger (f.eks. saksbehandler ser fnr de ikke skulle hatt).
- Utlevering til feil mottaker (e-post, API-response, utskrift).
- Tap av tilgjengelighet (sletting, ransomware, ikke-gjenopprettbar feil).
- Lekket autentiseringsmateriale som gir tilgang til persondata.
- Publisering av persondata i offentlig kildekoderepo eller åpen logg.

Teamets oppgave ved mistanke:

1. **Stopp bruddet** (trekk tilgang, roter secret, fjern data hvis mulig).
2. **Bevar bevis** (logger, commit-historikk, berørte poster) før opprydning.
3. **Varsle umiddelbart** internt: sikkerhetschampion, PVO, linjeleder.
4. **Dokumenter**: hva, når, omfang, tiltak, varslede parter. Bruk Navs fastsatte mal/system.

Behandlingsansvarlig, med støtte fra PVO, vurderer og sender formell melding til Datatilsynet innen 72 timer.

### Når varsle — forhåndsdrøfting ved DPIA

Hvis DPIA viser at behandlingen ville medføre høy restrisiko selv etter tiltak, skal **forhåndsdrøfting** med Datatilsynet gjøres før behandlingen starter (GDPR art. 36). Dette er en egen prosess, ikke et avviksvarsel, og initieres via PVO.

### Hva varsle

En avviksmelding til Datatilsynet inneholder typisk:

- Arten av bruddet (kategori: tilgang, utlevering, tap).
- Kategorier og omtrentlig antall registrerte berørt.
- Kategorier og omtrentlig antall poster berørt.
- Sannsynlige konsekvenser for de registrerte.
- Tiltak iverksatt eller foreslått for å håndtere bruddet og redusere skadevirkninger.
- Kontaktpunkt (PVO) for oppfølging.

Når bruddet sannsynligvis vil medføre **høy risiko** for den registrertes rettigheter, skal også **den registrerte selv varsles** (GDPR art. 34) — dette er egen prosess eid av behandlingsansvarlig.

### Dokumentasjon uansett

Alle brudd skal dokumenteres internt — også de som ikke utløser varsling til Datatilsynet. Dokumentasjonen er grunnlag for tilsyn, læring og senere vurderinger.

## Videre lesning

- `../SKILL.md` — PII-klassifisering, accessPolicy-vurdering, eskalering til sikkerhetschampion.
- `gdpr-privacy.md` — CEF-format, retention-mønstre, anonymiserings-kode.
- `api-security.md` — API-headers, CORS, hendelseshåndtering-operasjonelt.
- [sikkerhet.nav.no](https://sikkerhet.nav.no) — Navs Golden Path, autoritativ sikkerhetsveiledning.
