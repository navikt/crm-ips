---
name: api-design
description: Nav-konvensjoner for API-design — accessPolicy.inbound, TokenX-inbound-validering, API-versjonering koordinert med andre team. Teknologiagnostisk.
---

# API Design — Nav-konvensjoner

Dette dokumentet dekker **Nav-spesifikke** konvensjoner for API-design. Generelle REST-/HTTP-mønstre er ikke dekket her — bruk teamets etablerte praksis.

## accessPolicy.inbound — hvem får kalle API-et?

Nav-API-er eksponert via nais må eksplisitt liste hvilke andre applikasjoner som har tilgang. Ingen implisitt "alle Nav-apper". Navngi team og app.

```yaml
# nais.yaml (utdrag — teknologiagnostisk: samme prinsipp gjelder uansett rammeverk)
spec:
  accessPolicy:
    inbound:
      rules:
        - application: saksbehandling-frontend
          namespace: team-vedtak
          cluster: prod-gcp
        - application: oppfolging-api
          namespace: team-oppfolging
          cluster: prod-gcp
```

### Regler
- **Aldri** tom `inbound` på intern-API uten å mene det: tom inbound stenger API-et helt (Nais krever eksplisitt liste — også for kallere i samme namespace).
- **Aldri** `*` wildcard uten eksplisitt begrunnelse + sikkerhetsreview.
- Koordiner med konsumerende team **før** du legger dem til — de må også ha `outbound`-regel mot deg.
- Fjern konsumenter som ikke lenger bruker API-et (revideres kvartalsvis).

## TokenX-inbound-validering

API-er som eksponeres for frontend via TokenX må validere token på serversiden. Rammeverket (Ktor, Spring, annet) er uvesentlig — valideringsreglene er like:

- **Issuer**: matcher TokenX-issuer for riktig miljø (dev-gcp / prod-gcp).
- **Audience (`aud`)**: matcher din applikasjons client-id.
- **Signatur**: verifiser mot TokenX JWKS-endpoint.
- **`pid`-claim**: inneholder brukerens fødselsnummer — bruk denne som autoritativ brukeridentitet, **ikke** noe som kommer fra request body.
- **`acr`-claim**: sjekk nivå (`Level4` / `idporten-loa-high`) hvis API-et krever høyt innloggingsnivå.
- **Exp/nbf**: standard gyldighetssjekk.

Logg aldri hele tokenet. Logg `sub`/`jti` for sporbarhet hvis nødvendig.

## API-versjonering — koordiner med andre team

Breaking changes på API-er som andre Nav-team konsumerer er et **koordineringsproblem**, ikke bare et teknisk problem.

### Før brudd-endring
1. **Identifiser konsumenter** via `accessPolicy.inbound` + faktisk trafikk (logger/metrics).
2. **Varsle team eksplisitt** — Slack, e-post, eller teamets foretrukne kanal. Ikke anta at de leser changelog.
3. **Avtal overgangsvindu** — typisk 1–3 måneder der begge versjoner lever parallelt.
4. **Versjoner URL-en** (`/v1/` → `/v2/`) eller bruk annen mekanisme teamet ditt har etablert.
5. **Deprecering først**: merk gammel versjon som deprecated, gi konsumentene tid.

### Ikke-brudd-endringer (trygge)
- Legge til nye felter i response.
- Gjøre nye request-felter valgfrie.
- Legge til nye endpoints.

Disse kan rulles ut uten koordinering, men dokumenter dem.

## API-katalog

Registrer API-et i [apikatalog.nav.no](https://apikatalog.nav.no) slik at andre team kan finne det. Særlig viktig for API-er som kan ha bredere nytte enn umiddelbare konsumenter.

## Dokumentasjon — bruk teamets format

Dokumenter API-ene i formatet **teamet allerede bruker** (OpenAPI/Swagger, Postman-collection, Markdown, AsyncAPI for event-drevne API-er, tilsvarende). Ikke påtving ett bestemt format. Målet er at konsumenter finner og forstår kontrakten — ikke formatvalget i seg selv.

## Grenser

### Alltid
- Eksplisitt `accessPolicy.inbound` med navngitte team/apper.
- TokenX-validering (issuer, audience, signatur, `pid`) for frontend-API-er.
- Koordinere brudd-endringer med konsumerende team før release.
- Aldri PII (FNR, navn) i URL-er eller query params — bruk `pid` fra token.

### Spør først
- Fjerning av konsument fra `accessPolicy.inbound`.
- Brudd-endring i kontrakt.
- Eksponering av API utenfor `cluster` (ekstern tilgang).

### Aldri
- Tom eller wildcard `inbound` uten sikkerhetsreview.
- Stole på brukeridentitet fra request body — bruk token-claim.
- Silent breaking changes.
- Logge hele tokens eller PII.
