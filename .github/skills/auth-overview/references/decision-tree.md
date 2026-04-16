# Auth-beslutningstre — caller-type → mekanisme

Start med å identifisere hvem som initierer forespørselen. Velg auth-mekanisme deretter.

| Caller                                    | Auth-mekanisme               | Nais-flagg                        |
|-------------------------------------------|------------------------------|-----------------------------------|
| Innbygger via nettleser                   | ID-porten (+ Wonderwall)     | `idporten.enabled: true`          |
| Saksbehandler via nettleser               | Azure AD (+ Wonderwall)      | `azure.application.enabled: true` |
| Nav-tjeneste med brukerkontext (OBO)      | TokenX                       | `tokenx.enabled: true`            |
| Nav-tjeneste uten brukerkontext (batch)   | Azure AD client_credentials  | `azure.application.enabled: true` |
| Ekstern partner / system                  | Maskinporten                 | `maskinporten.enabled: true`      |
| Systembruker (Altinn 3)                   | Maskinporten + systembruker  | `maskinporten.enabled: true`      |

## Vanlig feil

Azure client_credentials brukt der brukerkontekst finnes — identiteten tapes og per-bruker-autorisasjon blir umulig.

```
❌ FEIL:
Innbygger → Frontend → [Azure client_credentials] → Backend API
   Konsekvens: Mister hvem brukeren er, kan ikke autorisere per bruker

✅ RIKTIG:
Innbygger → Frontend → [TokenX exchange] → Backend API
   Konsekvens: Brukerens identitet følger med, kan autorisere per bruker
```

## Systembruker (Altinn 3)

Mekanisme i Altinn 3 der eksterne virksomheter oppretter en systembruker som gir tilgang til Nav-tjenester via Maskinporten. Se [Altinn 3 systembruker-dokumentasjon](https://docs.altinn.studio/authentication/what-do-you-get/systemuser/).
