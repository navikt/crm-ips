# Local auth-mocking (ID-porten / Wonderwall for e2e)

Kort oppskrift for å kjøre lokal frontend mot en mock av ID-porten / Azure AD i utvikling og Playwright-tester. Bruk `mock-oauth2-server` som OIDC-utsteder; pek Wonderwall (eller appen direkte) mot den.

**Docker Compose-snutt:**

```yaml
services:
  mock-oauth2:
    image: ghcr.io/navikt/mock-oauth2-server:latest
    ports: ["8080:8080"]
    environment:
      JSON_CONFIG: |
        {
          "interactiveLogin": true,
          "tokenProvider": { "keyProvider": { "initialKeys": "<GENERATED_JWK>" } }
        }

  wonderwall:
    image: ghcr.io/nais/wonderwall:latest
    environment:
      WONDERWALL_OPENID_PROVIDER: idporten
      WONDERWALL_OPENID_CLIENT_ID: "<TEST_CLIENT_ID>"
      WONDERWALL_OPENID_WELL_KNOWN_URL: "http://mock-oauth2:8080/<YOUR_TENANT>/.well-known/openid-configuration"
      WONDERWALL_UPSTREAM_HOST: "app:3000"
    ports: ["3001:3001"]
```

**Testdata (fnr):** bruk kun `00000000000` eller [Skatteetatens syntetiske serie](https://www.skatteetaten.no/skjema/testdata/) — merk tydelig i testen at det er syntetisk. Aldri ekte fødselsnumre.

**Placeholders:** `<TEST_CLIENT_ID>`, `<YOUR_TENANT>`, `<GENERATED_JWK>` må fylles inn av teamet ved oppsett.

**JVM-tester:** bruk `no.nav.security.mock-oauth2-server` direkte fra JUnit (`MockOAuth2Server().issueToken(...)`) uten Docker.
