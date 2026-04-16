---
description: "Nav-sikkerhetsstandarder — NAIS accessPolicy, hemmeligheter, PII, nettverkspolicyer"
applyTo: "**"
---

# Sikkerhet — Nav

Referanse: [sikkerhet.nav.no](https://sikkerhet.nav.no)

## NAIS-plattformen

- Autentisering og hemmeligheter håndteres av NAIS — sjekk manifestet
- Dependabot og Trivy for sårbarhetsskanning
- Chainguard/Distroless base images

## Nettverkspolicyer

Default-deny. Alle tilganger må deklareres eksplisitt:

```yaml
accessPolicy:
  inbound:
    rules:
      - application: calling-app
        namespace: team-calling
  outbound:
    rules:
      - application: target-app
        namespace: team-target
    external:
      - host: api.example.com
```

## Boundaries

- Parameteriserte spørringer — aldri string-interpolasjon i SQL
- Valider input ved systemgrenser
- Aldri logg PII (fødselsnummer, tokens, personnavn)
- Aldri commit hemmeligheter
- Eksplisitt `accessPolicy` i NAIS-manifest
