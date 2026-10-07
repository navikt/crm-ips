# NAV Domenekontekst: Rekruttering til stillinger i NAV

Generert: 2026-08-27 (erstatter tidligere versjon — nå supplert med Navet-kilder)
Fagområde: Rekruttering og ansettelse (intern HR-prosess i NAV, ikke ytelsesforvaltning)
Gjelder systemer: Digitale søknadsløsninger for stillinger i NAV (f.eks. sommer26_nav_jobbsok / B695)

> Deles av alle systemer som støtter NAVs egen rekrutterings- og ansettelsesprosess.
> Basert på generell GDPR- og arbeidsrettslig kunnskap, data fra behandlingskatalogen (B695),
> og — nytt i denne versjonen — faktisk NAV-praksis hentet fra Navet-siten
> `intranett-omstilling` (fagområdekode `intranett-omstilling` i nav-etterlevelse-mcp).

---

## 1. Rettslig grunnlag (felles for fagområdet)

### Primær nasjonal hjemmel
Rekruttering til stillinger i NAV er en ordinær arbeidsgiverprosess og reguleres av:
- **Statsansatteloven** (for statlige virksomheter som NAV) — kvalifikasjonsprinsippet
  ved ansettelse i staten.
- **Likestillings- og diskrimineringsloven** — forbyr direkte og indirekte forskjellsbehandling
  på grunnlag av bl.a. etnisitet, religion, livssyn, funksjonsnedsettelse, seksuell orientering,
  kjønn og fagforeningstilhørighet i ansettelsesprosesser (§ 6, § 30 om forbud mot innhenting av
  visse opplysninger ved ansettelse).
- **Arbeidsmiljøloven § 9-3 og § 13-1 flg.** — vern mot diskriminering og skranker for
  innhenting av helseopplysninger ved ansettelse.

### GDPR-grunnlag
**Artikkel 6(1)(b) — Avtale/forhandling om avtale** er registrert som grunnlag i
behandlingskatalogen (B695): behandlingen er nødvendig for å gjennomføre tiltak på den
registrertes anmodning før en eventuell arbeidsavtale inngås.

### Særlig om sensitive personopplysninger (art. 9)
Rekrutteringsprosesser skal som hovedregel **ikke** samle inn særlige kategorier
personopplysninger (helse, religion/livssyn, seksuell orientering, etnisk opprinnelse,
fagforeningsmedlemskap) med mindre det finnes et konkret, saklig og lovlig grunnlag:

- **Helseopplysninger**: Arbeidsmiljøloven §§ 9-3 og 13-1 setter strenge skranker for hvilke
  helseopplysninger en arbeidsgiver kan innhente ved ansettelse — kun opplysninger som er
  «nødvendige for å utføre de arbeidsoppgaver som knytter seg til stillingen». Generell
  spørring om «tilretteleggingsbehov» uten kobling til konkrete stillingskrav er problematisk.
- **Fagforeningsmedlemskap**: Diskrimineringsloven § 30 forbyr arbeidsgiver å innhente
  opplysninger om søkerens fagforeningstilhørighet ved ansettelse — dette er et **eksplisitt
  lovforbud**, ikke bare en «bør unngås»-anbefaling.
- **Religion, seksuell orientering, etnisitet («landbakgrunn»)**: Innhenting av slike
  opplysninger i en jobbsøknad har normalt intet saklig formål og er i utgangspunktet ulovlig
  diskriminerende grunnlag for behandling — både etter GDPR art. 9 (mangel på unntaksgrunnlag)
  og etter likestillings- og diskrimineringsloven.
- **Straffedommer (GDPR art. 10)**: Kan kun behandles med hjemmel i lov eller under offentlig
  kontroll — normalt kun aktuelt for stillinger med lovpålagt vandelskrav (f.eks. barnehage,
  NAV-kontor med tilgang til sensitive systemer), og skal aldri innhentes rutinemessig for alle
  søkere.

### Hva er lovlig å registrere
- Navn, kontaktinformasjon, CV, utdanning, arbeidserfaring, søknadstekst, referanser oppgitt
  av kandidaten, kvalifikasjoner relevante for stillingen.
- Bostedskommune/adresse kan være relevant for f.eks. oppmøtested, men skal **ikke** brukes
  som automatisk grunnlag for avslag med mindre det foreligger et saklig krav til
  arbeidssted/reisevei som er kommunisert og gjelder likt for alle søkere.

### Hva er IKKE lovlig å registrere/bruke som beslutningsgrunnlag
- Hårfarge, utseende — intet saklig grunnlag i noen rekrutteringsprosess.
- Fagforeningsmedlemskap — eksplisitt lovforbud (diskrimineringsloven § 30).
- Religion/livssyn, seksuell orientering, etnisitet/landbakgrunn — diskrimineringsgrunnlag,
  ingen saklig relevans for kvalifikasjonsvurdering.
- Helseopplysninger utover det som er strengt nødvendig for konkret tilrettelegging knyttet
  til spesifikke arbeidsoppgaver, og kun når søkeren selv ønsker å opplyse om det i
  forbindelse med et konkret tilretteleggingsbehov — ikke som obligatorisk/generelt
  scoringsgrunnlag.
- Geografisk opprinnelse/bosted som eksplisitt diskvalifiserende («blokkliste») uten saklig,
  dokumentert og likt anvendt kriterium.

---

## 2. Faktisk NAV-praksis (fra Navet: intranett-omstilling)

Denne seksjonen er basert på sider hentet fra `https://navno.sharepoint.com/sites/intranett-omstilling`
27.08.2026, og beskriver hvordan NAV faktisk gjennomfører rekruttering i dag. Brukes til å
vurdere om et system avviker fra etablert, akseptert praksis.

### Standardverktøy: Webcruiter og PRIM
NAVs rekrutteringsprosesser gjennomføres normalt i **Webcruiter** (rekrutteringsportal for
utlysning, søknadsmottak, kandidathåndtering og innstilling) og **PRIM** (Plattform for
Rekruttering og Intern Mobilitet, brukt til jobbanalyse/behovsvurdering i forkant av utlysning).
Kandidathåndtering og behandling av søknader skjer digitalt i Webcruiter.
Kilde: `Kandidathåndtering.aspx`, `Plattform-for-rekruttering-og-intern-mobilitet-(PRIM).aspx`.

**Konsekvens for vurdering av egenutviklede løsninger:** Et system som gjør egen mottak,
scoring og lagring av jobbsøknader utenfor Webcruiter/PRIM er et avvik fra NAVs etablerte
rekrutteringsverktøy og bør begrunnes særskilt (hvorfor ikke bruke Webcruiter?), uavhengig
av øvrige personvernfunn.

### Rekrutteringsprosessen i seks trinn
Kilde: `Rekruttering(2).aspx`, samt egne prosessider (`1.-Behovsanalysen-(PRIM)`,
`2.-Utlysning-og-stillingsannonsen`, `3.-Kandidathåndtering-og-behandling-av-søknader`,
`4.-Intervju-og-referanseintervju`, `5.-Innstilling`, `6.-Ansettelsesrådet...`):

1. Jobbanalyse (PRIM)
2. Stillingsannonsen
3. Kandidathåndtering (vurdering av kandidater mot kravene i utlysningsteksten)
4. Intervju og referanser (standard to intervjurunder, skreddersydd intervjuguide som dekker
   alle kvalifikasjonskrav)
5. Innstilling (godkjennes av ansettelsesrådet)
6. Avslutning, ansettelse og innfasing

Ingen av disse trinnene beskriver automatisert avslag eller scoring av kandidater — vurdering
mot kvalifikasjonskrav er gjennomgående en manuell prosess med strukturerte hjelpemidler
(intervjuguide, screeningspørsmål), ikke en automatisert beslutning.

### Screeningspørsmål og pilot uten søknadsbrev
Kilde: `Rekruttering.aspx`, `Screeningspørsmål-i-rekruttering.aspx`.

Fra mai til og med 2026 piloterer NAV å erstatte søknadsbrev med 2–4 målrettede
screeningsspørsmål + en utfyllende CV. Eksplisitt begrunnelse (sitat): søknadsbrevet er et
fritekstfelt der søkere «legge inn mye ulik informasjon» som gir «informasjon som ikke er
nødvendig for kvalifikasjonsvurderingene», og at strukturerte screeningsspørsmål gir et
«mer strukturert og rettferdig vurderingsgrunnlag» og bidrar til å **fjerne barrierer og
biaser**. Piloten krever organisatorisk forankring hos tillitsvalgte og ledelse før den tas
i bruk, og skal ha standardisert informasjonstekst i annonsen.

**Relevans:** Dette er det nærmeste NAV kommer en offisielt akseptert, strukturert
førstevurdering av kandidater — men den er fortsatt **manuell** (leder vurderer selv CV og
svar), krever få og saklig relevante spørsmål, og har eksplisitt formål om å **redusere**
bias, ikke innføre nye diskrimineringsgrunnlag.

### Presedens for aggregert/anonymisert databehandling i rekruttering
Kilde: `Utlevering-av-data-til-Difi.aspx` — beskriver et tidligere forsøk med anonymisert
rekruttering i Arbeids- og velferdsdirektoratet, der Webcruiter utleverte data til Difi
(nå Digdir) for evaluering. Utlevering var begrenset til:
- Antall vurdert som aktuelle/innkalt til intervju/ansatt, fordelt på **med/uten
  innvandrerbakgrunn**
- Bakgrunnsvariabler: **kjønn, alder**, og informasjon fra screeningspørsmål
- Stillingskategori (f.eks. jurist/økonom)
- Endringshistorikk og begrunnelse **kun** ved statusendring etter at anonymisering ble opphevet

Eksplisitt presisert i kilden: «Personopplysninger som kan knyttes til enkeltpersoner i
direktoratet utleveres ikke».

**Relevans:** Dette er det eneste identifiserte tilfellet av NAV-praksis der
bakgrunnsvariabler (kjønn, alder, innvandrerbakgrunn) er behandlet i rekrutteringssammenheng
— og det skjedde **aggregert, ikke personidentifiserbart, og kun til evalueringsformål**,
med tydelig avgrensning og formål. Det finnes **ingen presedens** i NAVs egen dokumenterte
praksis for å bruke hårfarge, religion, seksuell orientering, fagforeningsmedlemskap eller
helseopplysninger som individuelt scoringsgrunnlag for enkeltkandidater. Dette styrker
konklusjonen om at slik bruk mangler saklig forankring i etablert praksis, i tillegg til å
være i strid med lov.

### Arkivering av rekrutteringssaken
Kilde: `Arkivering-av-rekrutteringssaken.aspx` (Rutine for arkivering av dokumenter i
forbindelse med rekruttering, eid av NAV HR-avdelingen).

Rutinen lister konkret, for hvert dokument som oppstår i rekrutteringsprosessen, om det er
journal-/arkivpliktig, hvor det arkiveres (Webcruiter og/eller P360) og om arkivering skjer
automatisk eller manuelt. Sentrale punkter:

| Dokument | Arkivpliktig | Hvor | Automatisk/manuelt |
|---|---|---|---|
| Jobbanalyse | Nei | PRIM | Automatisk |
| Stillingsannonse | Ja | Webcruiter + P360 | Automatisk ved publisering |
| Søknad/CV (kun innstilte kandidater ved manuell arkivering) | Ja | Webcruiter + P360 | Automatisk |
| Offentlig/utvidet søkerliste | Ja | Webcruiter + P360 | Manuelt (låses før overføring) |
| Innstilling m/vedlegg | Ja | Webcruiter + P360 | Manuelt, etter godkjenning av ansettelsesrådet |
| Vedtak/protokoll | Ja | Webcruiter + P360 | Manuelt |
| Tilbudsbrev/arbeidsavtale | Ja | P360 (personalmappe) | Manuelt |
| Klage fra kandidat | Ja | P360 (egen klagesak) | Manuelt |
| Innsynskrav | Ja | P360 (egen innsynssak) | Manuelt |

**Relevans:** Dette er direkte relevant sammenligningsgrunnlag for K226 (journalføring),
K230 (avlevering/sletting) og K128 (sak-/arkivsystemer). Et system som lagrer søknader i en
flat fil uten kobling til P360/Joark, uten journalføring og uten sletterutine avviker fra
denne dokumenterte, forventede arkiveringspraksisen.

---

## 3. Faglige retningslinjer og restriksjoner (supplerende)

Generelt for offentlig sektor:
- **Kvalifikasjonsprinsippet** (statsansatteloven § 3): den best kvalifiserte skal ansettes —
  automatiserte avslag må kunne begrunnes i kvalifikasjonskriterier, ikke irrelevante eller
  diskriminerende faktorer.
- Automatiserte eller halvautomatiserte avgjørelser i ansettelsesprosesser bør alltid ha
  **menneskelig kvalitetssikring** før avslag effektueres overfor kandidat, jf. GDPR art. 22
  (rett til ikke å være gjenstand for utelukkende automatiserte avgjørelser med rettsvirkning).
  Dette samsvarer med NAVs egen prosess (seksjon 2), der selv strukturerte screeningsspørsmål
  vurderes manuelt av leder — ingen trinn i den dokumenterte prosessen er helautomatisert.

`[Teamet bør supplere med: interne lokale rutiner for rekruttering ("Lokale sider om
rekruttering"), NAVs personalreglement, og "Relevant lov- og regelverk for ansettelse" —
disse fantes som lenker i Navet men pekte ikke til egne sider innenfor
intranett-omstilling-siten og må hentes separat, f.eks. som PDF/dokument eller fra HR direkte.]`

---

## 4. Kategorier av registrerte (felles)

- Eksterne jobbsøkere til stillinger i NAV (ikke NAV-brukere/ytelsesmottakere i vanlig
  forstand, men behandlingskatalogen bruker likevel kategorien «Bruker» generisk).
- Interne ansatte som senere ansettes (registrert som egen behandling i katalogen for
  oppfølging etter ansettelse).

---

## 5. Referanser

- **Behandlingskatalog**: B695 "Digital rekruttering til stillinger i Nav (testcase)"
- **Lovdata**: Statsansatteloven, Likestillings- og diskrimineringsloven § 30,
  Arbeidsmiljøloven §§ 9-3, 13-1
- **Navet** (`intranett-omstilling`, hentet 27.08.2026 via nav-etterlevelse-mcp):
  - [Rekruttering](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Rekruttering(2).aspx)
  - [Rekruttering uten søknadsbrev](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Rekruttering.aspx)
  - [Screeningspørsmål i rekrutteringprosess](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Screeningsp%C3%B8rsm%C3%A5l-i-rekruttering.aspx)
  - [Rutine for arkivering av dokumenter i forbindelse med rekruttering](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Arkivering-av-rekrutteringssaken.aspx)
  - [Utlevering av data til Difi](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Utlevering-av-data-til-Difi.aspx)
  - [Kandidathåndtering og behandling av søknader i Webcruiter](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Kandidath%C3%A5ndtering.aspx)
  - [PRIM - Plattform for rekruttering og intern mobilitet](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Plattform-for-rekruttering-og-intern-mobilitet-(PRIM).aspx)
  - [Rekruttering og omstilling (startside)](https://navno.sharepoint.com/sites/intranett-omstilling/SitePages/Start.aspx)
