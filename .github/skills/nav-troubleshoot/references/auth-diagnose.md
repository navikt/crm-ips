# Auth-diagnose — 401 Unauthorized og 403 Forbidden

Diagnostiske trær for autentiserings- og autorisasjonsfeil i Nav-apper. Dekker Azure AD, TokenX, ID-porten og Maskinporten via Texas (Kotlin) eller Oasis (TypeScript).

Se `auth-overview` for mekanismene; denne filen er for å *diagnostisere når de feiler*.

## Dekode JWT

```bash
# Dekode payload uten signatur-verifikasjon
echo "{token}" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq .
```

Viktige felt:
- `iss` (issuer) — hvem utstedte token (`login.microsoftonline.com/...` for Azure AD, TokenX URL for TokenX, ID-porten URL for ID-porten)
- `aud` (audience) — hvem token er ment for
- `exp` (expiry) — når token utløper
- `sub` / `NAVident` / `pid` — hvem token representerer
- `azp` (authorized party) — klient som fikk token utstedt

## Sjekk auth-konfigurasjon i pod

```bash
# Se alle auth-relaterte env-vars fra NAIS
kubectl get pod {pod} -n {namespace} \
  -o jsonpath='{range .spec.containers[0].env[*]}{.name}={.value}{"\n"}{end}' \
  | grep -E 'AZURE|TOKEN_X|IDPORTEN|MASKINPORTEN'

# Test at JWKS-endepunkt er tilgjengelig fra podden
kubectl exec -n {namespace} {pod} -- \
  wget -qO- --timeout=5 "$AZURE_OPENID_CONFIG_JWKS_URI" 2>&1 | head -1
```

## Sjekk accessPolicy

```bash
# Se gjeldende accessPolicy (inbound/outbound)
kubectl get app -n {namespace} {app-name} -o yaml | grep -A 30 accessPolicy

# Se network policies som Nais genererer
kubectl get networkpolicy -n {namespace} -l app={app-name}
```

## 401 Unauthorized — diagnostisk tre

```
401 Unauthorized
├── Har forespørselen Authorization-header?
│   ├── Nei → kaller mangler token. Sjekk frontend / Texas sidecar / Oasis-oppsett.
│   └── Ja → gå videre
├── Er token fra riktig issuer?
│   ├── Azure AD men forventet TokenX → feil auth-flow (bruk token-exchange, ikke M2M)
│   ├── ID-porten men forventet Azure AD → feil inngang / wonky sidecar-config
│   └── Riktig issuer → gå videre
├── Er audience riktig?
│   │   Azure AD: `api://{cluster}.{namespace}.{app}/.default`
│   │   TokenX:   `{cluster}:{namespace}:{app}`
│   ├── Feil audience → kaller sender token til feil mottaker (fiks target i token-exchange)
│   └── Riktig → gå videre
├── Er token utløpt?
│   ├── exp < nåtid → token expired. Sjekk token-refresh (Texas/Oasis gjør dette automatisk)
│   └── Gyldig → gå videre
├── Er klokken synkronisert?
│   ├── Klokke-skew > noen sekunder → infra-problem (sjelden på Nais)
│   └── OK → gå videre
└── Er JWKS tilgjengelig fra podden?
    ├── Nei → nettverksproblem, sjekk `accessPolicy.outbound.external` (login.microsoftonline.com for Azure AD)
    └── Ja → sjekk token-validation-konfig (biblioteket i appen)
```

## 403 Forbidden — diagnostisk tre

```
403 Forbidden
├── Er accessPolicy.inbound konfigurert?
│   ├── Nei → legg til kaller i inbound rules
│   └── Ja → gå videre
├── Er kaller registrert i inbound-listen?
│   │   Eksempel:
│   │     accessPolicy.inbound.rules:
│   │       - application: {kaller-app}
│   │         namespace: {kaller-namespace}
│   ├── Nei → legg til kaller
│   └── Ja → gå videre
└── Er det autorisasjon på applikasjonsnivå?
    ├── Ja → sjekk roller/grupper/scopes i token
    │   - Azure AD: roller via app-roles eller gruppe-claims
    │   - TokenX: videreført bruker — sjekk `NAVident` eller `pid`
    │   - Maskinporten: sjekk `scope`
    └── Nei → sjekk Nais app-status: `kubectl get app {name} -o yaml`
```

## Vanlige Nav-spesifikke feilmønstre

| Feilmelding | Årsak | Løsning |
|------------|-------|---------|
| `Token validation failed: wrong issuer` | Token fra feil IdP | Kaller bruker feil auth-mekanisme (Azure AD vs. TokenX vs. ID-porten) |
| `Token validation failed: wrong audience` | Token ment for annen app | Fiks `target` i Texas/Oasis token-exchange-kallet |
| `Token validation failed: expired` | Token utløpt | Token-cache for gammel. Texas/Oasis gjør refresh selv — ikke egen caching. |
| `Connection refused: login.microsoftonline.com` | Kan ikke nå JWKS/issuer | Legg til `accessPolicy.outbound.external` for issuer-host |
| `No bearer token found` | Manglende `Authorization`-header | Sjekk at frontend / sidecar sender token; sjekk at rute ikke er uventet public |
| `403 denied by NetworkPolicy` | `accessPolicy.inbound` mangler kaller | Legg til `{application, namespace}` i inbound.rules |

## Når bruke Texas vs. Oasis

- Kotlin backend → Texas sidecar på `localhost:3000` (feilsøking: `curl` fra podden for å isolere sidecar-problem fra app-problem)
- TypeScript / Next.js → `@navikt/oasis` (feilsøking: logg validerings-resultatet uten å logge selve tokenet)

Ikke implementer egen token-caching eller OAuth-flyt manuelt. Se `auth-overview`.
