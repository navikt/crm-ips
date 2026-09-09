---
name: nav-architecture-review
description: "Arkitektur-review og ADR for Nav — systemgrenser, eierskap, dataflyt, plattform, sikkerhet, DPIA, TokenX, accessPolicy og beslutningsdokumentasjon. Brukes via /nav-architecture-review ved arkitekturbeslutninger."
---

# Nav Architecture Review — ADR + 3-perspektiv

Skriv Architecture Decision Records (ADR) og gjør tyngre arkitektur-review for Nav-apper. Skillen dekker det som er Nav-spesifikt: Nais/GCP-plattformen, TokenX/Azure AD/ID-porten/Maskinporten, `accessPolicy`, Datatilsynet/DPIA og Navs arkitekturprinsipper (Team First, Architecture Advice Process, foretrekk plattform-kapabiliteter).

Generisk stoff om "hva er en ADR" eller generiske security-OWASP-lister er ikke replikert her — bruk det fra ditt eget repertoar.

## Når aktiveres skillen

Aktiveres av inspektor-claude/inspektor-gpt i hovmester Steg 4 for tyngre arkitekturendringer. Typiske signaler:

- Ny tjeneste, ny integrasjon mot annet team, nytt lagringslag eller ny event-kontrakt.
- Endring som krever `accessPolicy`-oppdatering hos andre team, eller ny auth-mekanisme (TokenX/Azure AD/ID-porten/Maskinporten).
- Behandling av nye personopplysninger (mulig DPIA / melding til Datatilsynet).
- Teknisk gjeld-opprydding eller plattform-migrering (on-prem → Nais, plain Kafka → Rapids & Rivers, etc.).
- Avvik fra Navs standardmønstre eller introduksjon av ny teknologi.

Lettere valg (biblioteksvalg innenfor eksisterende stack, intern refaktor) trenger ikke formell ADR.

## 3-perspektiv-review

Evaluer endringen fra tre perspektiver før ADR-en konkluderer. Skriv én til tre linjer per perspektiv — noter bekymring, risiko og anbefaling.

1. **Arkitektur** — passer i Navs overordnede arkitektur, respekterer team-autonomi, gjenbruker plattform-kapabiliteter, unngår accidental complexity.
2. **Sikkerhet** — dataklassifisering, auth-mekanisme, `accessPolicy` (inngang/utgang), PII-beskyttelse i logg/lagring/transport, behov for DPIA.
3. **Plattform** — Nais-manifest-endringer, ressursbehov, observerbarhet (Prometheus/Loki/Tempo), CI/CD, avhengigheter til on-prem eller legacy.

Full sjekkliste med Nav-spesifikke spørsmål per perspektiv ligger i [references/perspektiv-sjekklister.md](./references/perspektiv-sjekklister.md).

Ved endring av eksisterende system: ta også med migrasjon (bakoverkompatibilitet, rollback-plan, feature toggle, exit criteria, dekommisjonering).

## Detekter eksisterende stack først

Før du anbefaler løsning: sjekk hva teamet faktisk kjører (Kotlin/Ktor, Kotlin/Spring, Next.js, fullstack). Forslagene i ADR-en skal matche det stacket — ikke tvinge teamet over på noe annet uten at det er selve beslutningen.

## Alternativer og Architecture Advice Process

Dokumenter minst to alternativer pluss "gjøre ingenting". Navs Architecture Advice Process er rådgivende, ikke godkjenningsbasert: teamet søker råd fra berørte parter, men eier beslutningen selv. Identifiser berørte team tidlig og del utkast-ADR med dem før beslutning fattes.

## ADR-format

Bruk malen i [references/adr-template.md](./references/adr-template.md). Lagre ADR-er under `docs/adr/ADR-{nummer}-{kort-tittel}.md` i teamets repo.

Korte ADR-er er best — én beslutning per ADR. Oppdater status når beslutningen er tatt; bruk "Erstattet av ADR-{n}" når en beslutning revideres.

## Relaterte skills

- `nais-manifest` — manifest-struktur, `resources`, `accessPolicy`, Cloud SQL, Kafka pool.
- `auth-overview` — Azure AD, TokenX, ID-porten, Maskinporten, Texas/Oasis.
- `security-review` — dypere sikkerhetsgjennomgang, trusselmodellering, PII-håndtering, DPIA-vurdering.
- `observability-setup` — metrikker, logging, tracing, varsling.
- `nav-troubleshoot` — drift-diagnose, ikke design.

## Grenser

### Alltid

- Inkluder minst to alternativer (pluss "gjøre ingenting").
- Vurder alle tre perspektiver — arkitektur, sikkerhet, plattform.
- Dokumenter Nav-spesifikke vurderinger: auth, dataklassifisering, `accessPolicy`, Nais-endringer.
- Avslutt med konkrete aksjonspunkter (eier + frist).

### Spør først

- ADR som påvirker andre teams tjenester eller kontrakter.
- Beslutninger som avviker fra Navs standardmønstre (Nais-plattform, Wonderwall, Kafkarator).
- Introduksjon av ny teknologi, nytt språk eller ny plattform-komponent.
- Behandling av nye kategorier personopplysninger — vurder DPIA og kontakt personvernombud.

### Aldri

- Fatt arkitekturbeslutning uten å vurdere sikkerhet og personvern.
- Ignorer plattform-konsekvenser (ressurser, observerbarhet, `accessPolicy`).
- Hopp over alternativer — det finnes alltid minst to valg.
- Dokumenter PII eller hemmeligheter i selve ADR-en.
