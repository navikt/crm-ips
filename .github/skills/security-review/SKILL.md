---
name: security-review
description: Sikkerhetsgjennomgang for Nav-apper — PII-klassifisering, accessPolicy-vurdering og eskalering til sikkerhetschampion. Progressive disclosure for dyp trusselmodellering.
---

# Sikkerhetsgjennomgang — Nav

Nav-spesifikk sikkerhetssjekk før commit, push og PR. Generiske OWASP-mønstre (SQLi, XSS, CSRF, injection) forutsettes kjent — dette dokumentet fokuserer på Nav-konteksten: PII-klassifisering, accessPolicy som sikkerhetsmekanisme, og eskalering til sikkerhetschampion.

## PII-klassifisering i Nav

Nav behandler personopplysninger med fire beskyttelsesnivåer. Feil klassifisering er den vanligste rotårsaken til alvorlige avvik.

| Nivå | Typiske data | Behandling |
|------|--------------|------------|
| **Strengt fortrolig** | Helseopplysninger, diagnoser, sykemeldinger, voldsutsatte/kode 6, barnevernsdata | Kryptering i ro og transit, streng tilgangsstyring, CEF-auditlogg ved visning (WARN), dedikert DPIA |
| **Fortrolig** | Fødselsnummer (fnr), D-nummer, kode 7, sensitive ytelsesdata | Aldri i standardlogger, CEF-auditlogg ved visning, tilgangsstyring per sak/bruker |
| **Intern** | Navn, adresse, telefon, e-post, ikke-sensitiv ytelsesstatus | Dataminimering, tilgang per tjenstlig behov, retention dokumentert |
| **Åpen** | Offentlig statistikk, anonymiserte aggregater | Normal tilgang; verifiser at anonymiseringen tåler koblingsangrep |

**Klassifisering av ytelsesdata**: Faktumet "en bruker mottar ytelse X" kan være fortrolig eller strengt fortrolig avhengig av ytelsen (f.eks. AAP/uføretrygd implisitt helseinformasjon). Spør sikkerhetschampion ved tvil.

**Placeholder i kode og dokumentasjon**: Bruk aldri ekte fnr. I eksempler og tester: `00000000000` eller Skatteetatens offisielle testserie (markert eksplisitt som syntetisk). Se `references/nav-threat-model.md` for DPIA-prosess og audit-krav.

### PII i logger

```kotlin
// OK — korrelasjons-ID og tema, ingen PII
log.info("Behandler sak", kv("sakId", sak.id), kv("tema", sak.tema))

// Aldri — FNR, navn, diagnose eller ytelsesdata i standardlogg
log.info("Behandler sak for ${bruker.fnr}")
```

Visning av personopplysninger til Nav-ansatte skal logges i **CEF-format** til auditlog (ikke standardlogg). Se `references/nav-threat-model.md` for format og hva som skal logges når.

## accessPolicy som first-line defense

`accessPolicy` i Nais-manifestet er første forsvarslinje — ikke en tilleggsmekanisme. Default deny på Nais-plattformen betyr at glemt regel = brutt tilgang, ikke åpen tilgang. Men feil regel = eksponert tjeneste.

```yaml
spec:
  accessPolicy:
    inbound:
      rules:
        - application: min-frontend         # eksplisitt navngitt caller
    outbound:
      rules:
        - application: pdl-api
          namespace: pdl
          cluster: prod-gcp
      external:
        - host: api.ekstern-tjeneste.no     # kun når strengt nødvendig
```

**Kritiske vurderinger ved gjennomgang:**

- **Ingen åpen inbound**: `inbound.rules` må være eksplisitt liste. Fravær av rules = ingen tilgang (OK for intern batch/job), men åpne wildcards eller mange generelle rules krever begrunnelse.
- **Inbound vs. auth-kode speiler hverandre**: Hver app i `inbound.rules` skal være validert i auth-koden (f.eks. `azp`-sjekk mot `AZURE_APP_PRE_AUTHORIZED_APPS`). Diff avvik — enten død kode eller manglende nettverksregel.
- **Outbound er et sikkerhetstiltak, ikke bare ruting**: Begrenset outbound = begrenset blast radius hvis appen kompromitteres. Outbound `external` må ha tydelig formål og eier.
- **Cluster/namespace stemmer med miljøet**: `prod-gcp` vs `dev-gcp` — feil cluster i outbound = tjeneste fungerer ikke i prod, men blir ofte oppdaget sent.

## Sikkerhetschampion-rolle og eskalering

Hvert team har en sikkerhetschampion (eller kan eskalere til plattformens sikkerhetsfunksjon). Denne rollen eies av teamet, ikke av `security-review`-skillen.

**Når skillen håndterer det (ingen eskalering):**

- Parameteriserte spørringer, input-validering, standard OWASP-mønstre.
- CEF-auditlogg ved visning av personopplysninger (mønster er etablert).
- accessPolicy-oppsett for standard inbound/outbound.
- Trivy/zizmor-funn med kjente fixes.

**Når du eskalerer til sikkerhetschampion (eller `#appsec`):**

- **Ny klasse data**: Første gang teamet behandler helseopplysninger, barnevernsdata eller kode 6/7.
- **DPIA-behov**: Ny behandling med personopplysninger eller vesentlig endring i eksisterende behandling. Se `references/nav-threat-model.md`.
- **Ny integrasjon med eksternt domene**: `outbound.external` mot leverandør/tredjepart.
- **Endring i autentiseringsmekanisme**: Bytte mellom Azure AD/TokenX/ID-porten/Maskinporten, eller ny RBAC-modell.
- **Mistanke om hendelse**: Lekket secret, uautorisert tilgang, avvikende bruksmønster — ikke vent, eskaler umiddelbart.
- **Compliance-vurdering utenfor standardmønster**: Tilsynssaker, Datatilsynet-henvendelser, svar på revisjon.

**Hastegrad:**

- **Akutt (ring/ping umiddelbart)**: Aktiv hendelse, eksponert secret i git-historikk, mistanke om databehandlingsbrudd.
- **Samme dag**: Ny ekstern integrasjon i prod, endret autentiseringsflyt, nye datakategorier.
- **Planlagt (Slack/issue)**: DPIA-forberedelse, arkitekturgjennomgang, trusselmodellering.

Kontaktkanaler (prosess, ikke personer): Teamets interne sikkerhetschampion-kanal; Navs `#appsec` for generelle spørsmål; `#auditlogging-arcsight` for auditlogg; plattformens sikkerhetsfunksjon for hendelser.

## Automatiserte skanninger

```bash
# Sårbarheter og hemmeligheter i repoet
trivy repo .

# HIGH/CRITICAL CVE-er i container-image
trivy image <image-name> --severity HIGH,CRITICAL

# GitHub Actions workflows
zizmor .github/workflows/

# Hemmeligheter i git-historikk
git log -p --all -S 'password' -- '*.kt' '*.ts' | head -100
git log -p --all -S 'secret' -- '*.kt' '*.ts' | head -100
```

## Hemmeligheter

```kotlin
// OK — fra miljø (Nais injiserer via Console-secret)
val dbPassword = System.getenv("DB_PASSWORD")
    ?: error("DB_PASSWORD mangler")

// Aldri — hardkodet
val dbPassword = "supersecret123"
```

Secrets opprettes i Nais Console og injiseres via `envFrom`/`filesFrom`. Kopier aldri prod-secrets lokalt.

## Sjekkliste (Nav-fokus)

- [ ] PII-klassifisering er avklart for all data tjenesten behandler (strengt fortrolig/fortrolig/intern/åpen)
- [ ] Ingen FNR, navn, helse- eller sensitive ytelsesdata i standardlogger
- [ ] CEF-auditlogg dekker visning av personopplysninger til Nav-ansatte
- [ ] `accessPolicy.inbound` er eksplisitt og speiler auth-kodens validering
- [ ] `accessPolicy.outbound` begrenset til nødvendige tjenester/hoster med cluster/namespace korrekt
- [ ] Secrets kun fra Nais Console, ingen hardkodede verdier eller prod-secrets lokalt
- [ ] `Nav-Call-Id` propageres for korrelasjon på tvers av tjenester
- [ ] Behandlingsgrunnlag, retention og sletting er dokumentert for persondata
- [ ] Parameteriserte spørringer, input validert, tilgangskontroll sjekker eierskap
- [ ] `trivy repo .` uten HIGH/CRITICAL, `zizmor` OK, ingen committede secrets
- [ ] Eskalering til sikkerhetschampion er vurdert for nye datakategorier, integrasjoner eller auth-endringer
- [ ] DPIA-behov vurdert (se `references/nav-threat-model.md`) før ny behandling av personopplysninger

## Referanser

| Ressurs | Bruksområde |
|---------|-------------|
| [sikkerhet.nav.no](https://sikkerhet.nav.no) | Navs Golden Path for sikkerhet |
| auth-overview skill | JWT-validering, TokenX, ID-porten, Maskinporten |
| `references/nav-threat-model.md` | Dyp trusselmodellering (STRIDE i Nav-kontekst), DPIA-prosess, audit-logging-krav, Datatilsynet-varsling |
| `references/gdpr-privacy.md` | Nav-spesifikk PII-kategorisering og pekere til DPIA/CEF/retention |
| `references/api-security.md` | Nav-signal: Nav-Call-Id, Nav-Consumer-Id, accessPolicy som primærmekanisme |
