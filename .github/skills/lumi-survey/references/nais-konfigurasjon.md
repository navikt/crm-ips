## Fase 6: NAIS-konfigurasjon

Legg til i NAIS-manifest(ene). **Merk:** Verdiene avhenger av auth-type og miljø.

### 6a. Miljøvariabler

**TokenX (offentlige apper):**

```yaml
# nais-dev.yaml
spec:
  env:
    - name: LUMI_API_HOST
      # Intern service-to-service trafikk i NAIS-clusteret bruker HTTP.
      # Linkerd service mesh krypterer all trafikk mellom pods (mTLS).
      # HTTPS brukes kun for ekstern trafikk via ingress.
      value: http://lumi-api.team-esyfo
    - name: LUMI_AUDIENCE
      value: "dev-gcp:team-esyfo:lumi-api"
    - name: LUMI_FEEDBACK_PATH
      value: /api/tokenx/v1/feedback
```

```yaml
# nais-prod.yaml
spec:
  env:
    - name: LUMI_API_HOST
      value: http://lumi-api.team-esyfo
    - name: LUMI_AUDIENCE
      value: "prod-gcp:team-esyfo:lumi-api"
    - name: LUMI_FEEDBACK_PATH
      value: /api/tokenx/v1/feedback
```

**AzureAD (interne apper):**

```yaml
# nais-dev.yaml — NB: dev bruker lumi-submission-proxy pga. tenant-mismatch
spec:
  env:
    - name: LUMI_API_HOST
      value: http://lumi-submission-proxy.team-esyfo
    - name: LUMI_AUDIENCE
      value: "api://dev-gcp.team-esyfo.lumi-submission-proxy/.default"
    - name: LUMI_FEEDBACK_PATH
      value: /api/azure/v1/feedback
    - name: LUMI_IDENTITY_PROVIDER  # Kun for Kotlin/Texas
      value: azuread
```

```yaml
# nais-prod.yaml
spec:
  env:
    - name: LUMI_API_HOST
      value: http://lumi-api.team-esyfo
    - name: LUMI_AUDIENCE
      value: "api://prod-gcp.team-esyfo.lumi-api/.default"
    - name: LUMI_FEEDBACK_PATH
      value: /api/azure/v1/feedback
    - name: LUMI_IDENTITY_PROVIDER  # Kun for Kotlin/Texas
      value: azuread
```

### 6b. Tilgangspolicy (outbound)

```yaml
spec:
  accessPolicy:
    outbound:
      rules:
        - application: lumi-api
          namespace: team-esyfo
        # I dev med AzureAD, legg også til:
        # - application: lumi-submission-proxy
        #   namespace: team-esyfo
```

### 6c. Bestill tilgang hos Lumi-teamet

Lumi API krever at din app er lagt til som **inbound**-regel i Lumi sitt NAIS-manifest. Denne endringen gjøres av Team eSyfo.

**Opprett et issue eller kontakt Team eSyfo** med:
- Appnavn og namespace
- Auth-type (TokenX eller AzureAD)
- Miljø (dev og/eller prod)

Vent med å teste fullstendig flyt til inbound-tilgang er på plass — uten den vil du få 403 fra Lumi API.

### 6d. Token-utveksling

Hvis ikke allerede aktivert, legg til TokenX- eller Azure-konfig:

```yaml
# TokenX (offentlige apper)
spec:
  tokenx:
    enabled: true

# AzureAD (interne apper)
spec:
  azure:
    application:
      enabled: true
```
