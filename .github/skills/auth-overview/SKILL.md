---
name: auth-overview
description: Sett opp autentisering i en Nav-applikasjon — Azure AD, TokenX, ID-porten, Maskinporten, Wonderwall-sidecar, Texas (Kotlin) og Oasis (TypeScript)
---

# Autentiseringsoversikt — Nav

Oversikt over autentiseringsmekanismer i Nav. Bruk denne som referanse ved oppsett av autentisering i nye eller eksisterende tjenester.

## Beslutningstre — caller-type → auth-mekanisme

Start med å identifisere hvem som initierer forespørselen. Rask oppsummering:

- Innbygger → ID-porten + Wonderwall
- Saksbehandler → Azure AD + Wonderwall
- Nav-tjeneste med brukerkontekst → TokenX (OBO)
- Batch / Nav-tjeneste uten brukerkontekst → Azure AD client_credentials
- Ekstern partner → Maskinporten
- Altinn 3 systembruker → Maskinporten + systembruker

Komplett tabell, mot-eksempler og vanlige feil: se [`references/decision-tree.md`](references/decision-tree.md).

## Nais-konfigurasjon per mekanisme

### Azure AD / Entra ID (interne Nav-brukere)
```yaml
azure:
  application:
    enabled: true
    tenant: nav.no
```
Auto-injiserte env vars: `AZURE_APP_CLIENT_ID`, `AZURE_APP_CLIENT_SECRET`, `AZURE_APP_WELL_KNOWN_URL`, `AZURE_OPENID_CONFIG_ISSUER`, `AZURE_OPENID_CONFIG_JWKS_URI`.

### TokenX (service-to-service, on-behalf-of)
```yaml
tokenx:
  enabled: true
accessPolicy:
  inbound:
    rules:
      - application: calling-service
        namespace: team-calling
  outbound:
    rules:
      - application: downstream-service
        namespace: team-downstream
```
Auto-injiserte env vars: `TOKEN_X_WELL_KNOWN_URL`, `TOKEN_X_CLIENT_ID`, `TOKEN_X_PRIVATE_JWK`.

### ID-porten (innbyggere)
```yaml
idporten:
  enabled: true
  sidecar:
    enabled: true
    level: Level4 # eller Level3
```
Sidecar (Wonderwall) håndterer innlogging før forespørselen når applikasjonen.

### Maskinporten (eksterne organisasjoner)
```yaml
maskinporten:
  enabled: true
  scopes:
    consumes:
      - name: "nav:example/scope"
```

## Wonderwall-sidecar (nettleser-pålogging)

Wonderwall er Nav-sidecaren som håndterer session og innlogging for ID-porten- og Azure AD-baserte frontender. Appen din ser en innlogget bruker via cookies/headers og slipper å håndtere OAuth-flyten selv.

- Aktiveres via `idporten.sidecar.enabled: true` eller `azure.sidecar.enabled: true` i Nais-manifestet.
- Sidecaren kjører i samme pod og beskytter alle ruter som default.
- Definer `ingresses` og `accessPolicy` som vanlig — Wonderwall tar seg av login/logout-endepunkter.

## Biblioteker per språk

| Språk    | Bibliotek                                 | Bruksområde                                      |
|----------|-------------------------------------------|--------------------------------------------------|
| JVM      | `no.nav.security:token-validation-spring` | Spring Boot JWT-validering (`@ProtectedWithClaims`) |
| JVM      | `no.nav.security:token-validation-ktor-v3`| Ktor JWT-validering                              |
| JVM      | `navikt/token-support` (paraply)          | Token-validering og token exchange på JVM        |
| JVM      | Texas (HTTP-sidecar på `localhost:3000`)  | Token-utstedelse / exchange / introspect uten OAuth-lib |
| TS/Node  | `@navikt/oasis`                           | Validering, OBO og M2M i TypeScript              |

### Betinget råd — respekter eksisterende valg
Detekter eksisterende auth-bibliotek i repoet (`navikt/token-support`, `@navikt/oasis`, annet) før du anbefaler noe. Følg teamets valg. **Ikke foreslå bytte av auth-bibliotek uten eksplisitt oppdrag.**

## Kotlin — Texas sidecar

Texas kjører på `localhost:3000` i Nais-podden og håndterer tokenoperasjoner uten at applikasjonen trenger OAuth-biblioteker.

### Token (M2M)
```
POST http://localhost:3000/api/v1/token
Content-Type: application/json

{ "identity_provider": "azuread", "target": "api://cluster.namespace.app/.default" }
```

### Token Exchange (OBO)
```
POST http://localhost:3000/api/v1/token/exchange
Content-Type: application/json

{ "identity_provider": "tokenx", "target": "cluster:namespace:app", "user_token": "<brukerens token>" }
```

**Audience-format:**
- Azure AD: `api://cluster.namespace.app/.default`
- TokenX: `cluster:namespace:app`

### Introspect (validering)
```
POST http://localhost:3000/api/v1/introspect
Content-Type: application/json

{ "token": "<token som skal valideres>" }
```

**Caching:** Texas cacher tokens automatisk med 60 sekunders preemptiv refresh. Ikke implementer egen caching.

### Spring Boot-auth-dekorator
```kotlin
@ProtectedWithClaims(issuer = "azuread", claimMap = ["NAVident=*"])
```
Krever `token-validation-spring`.

### NAV-spesifikke JWT-claims
- `NAVident` — ansattens identifikator
- `oid` — objekt-ID i Azure AD
- `pid` — fødselsnummer (ID-porten)
- `azp` — authorized party (M2M, må valideres mot `AZURE_APP_PRE_AUTHORIZED_APPS`)

## TypeScript — Oasis

`@navikt/oasis` er Nav-biblioteket for token-validering og -utveksling i TypeScript.

```typescript
import {
  validateAzureToken, validateIdportenToken, validateTokenxToken,
  requestOboToken, requestAzureClientCredentialsToken,
  parseAzureUserToken, parseIdportenToken,
} from "@navikt/oasis"

// Validering
const v = await validateAzureToken(token); if (v.ok) { /* gyldig */ }

// OBO
const obo = await requestOboToken(userToken, "cluster:namespace:app")

// M2M
const m2m = await requestAzureClientCredentialsToken("api://cluster.namespace.app/.default")

// Brukerinfo
const { NAVident, name, oid } = parseAzureUserToken(token)
const { pid } = parseIdportenToken(token) // pid = fødselsnummer
```

**Caching:** Oasis har innebygd SIEVE-cache med Prometheus-metrikker. Ikke implementer egen caching.

## Tilnærming

1. Les Nais-manifestet for å identifisere hvilke autentiseringsmekanismer som er konfigurert.
2. Søk i kodebasen etter eksisterende autentiseringsoppsett og følg samme mønster.
3. Bruk Texas (Kotlin) eller Oasis (TypeScript) framfor å implementere OAuth-flyter manuelt.
4. For lokal utvikling / e2e-tester, se [`references/local-auth-mock.md`](references/local-auth-mock.md).

Komplett Nav-autentiseringsdokumentasjon: https://doc.nais.io/auth/ · Golden Path: https://sikkerhet.nav.no/docs/goldenpath/

## Boundaries

### Alltid
- Valider JWT-utsteder, audience, utløpstid og signatur.
- Valider `azp` mot `AZURE_APP_PRE_AUTHORIZED_APPS` for M2M-tokens.
- Kryssjekk auth-kode mot `.nais/`-filens `accessPolicy.inbound.rules` (drift = feil).
- Bruk kun HTTPS for tokenoverføring.
- Definer eksplisitt `accessPolicy` i Nais-manifestet.
- Bruk miljøvariabler fra Nais (aldri hardkod).

### Spør først
- Endringer i accessPolicy i produksjon.
- Endringer i tokenvalideringsregler, audience eller OAuth-scopes.
- Bytte av auth-bibliotek (se betinget råd over).

### Aldri
- Hardkode klienthemmeligheter eller tokens.
- Logge hele JWT-er (eller deler med PII).
- Hoppe over tokenvalidering "for test".
- Lagre tokens i `localStorage` (bruk httpOnly cookies).
- Lage egen token-caching (Texas/Oasis håndterer det).
