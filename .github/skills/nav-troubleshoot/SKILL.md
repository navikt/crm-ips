---
name: nav-troubleshoot
description: "Feilsøking av runtime-problemer i Nav-miljø — pod crash, OOMKilled, 401/403, auth-feil, Kafka lag, DB-timeout, Flyway-feil, logger og Nais-diagnostikk. Brukes via /nav-troubleshoot ved driftsfeil."
---

# Nav Troubleshoot — plattform-diagnostikk

Strukturerte diagnostiske trær for kjøre-tids-symptomer på Nais-plattformen. Bruk denne skillen når noe **feiler i drift** (pod krasjer, 401/403, consumer lag, DB-timeout) — ikke når du skal designe eller endre schema / manifest.

Skillen er Nav-spesifikk: Nais, Texas/Oasis, TokenX, Rapids & Rivers, `accessPolicy`. Generisk Kubernetes-/Kafka-/SQL-kunnskap er ikke replikert her — bruk den fra eget repertoar.

## Arbeidsflyt

1. **Identifiser symptomet** før du kjører kommandoer — hva feiler konkret?
2. **Detekter eksisterende stack først** — Spring Boot vs. Ktor, plain Kafka vs. Rapids & Rivers, Azure AD vs. TokenX vs. ID-porten. Diagnosen må matche det teamet faktisk kjører.
3. **Følg diagnostisk tre** i riktig `references/*.md` — steg for steg.
4. **Foreslå minst invasive fiks først**; eskaler kun hvis nødvendig.

## Symptom-oversikt

| Symptom | Start her |
|---------|-----------|
| Pod starter ikke / krasjer / OOMKilled | [references/pod-diagnose.md](./references/pod-diagnose.md) |
| 401 Unauthorized / 403 Forbidden | [references/auth-diagnose.md](./references/auth-diagnose.md) |
| Kafka consumer lag / meldinger prosesseres ikke | [references/kafka-diagnose.md](./references/kafka-diagnose.md) |
| Database-tilkoblingsfeil / pool exhaustion | [references/database-diagnose.md](./references/database-diagnose.md) |
| Treg responstid | Se kort tre under |
| Deploy feiler | Se kort tre under |

## Ytelsesproblemer (kort)

```
Treg responstid
├── Hvor er flaskehalsen?
│   └── Prometheus (http_request_duration_seconds), Tempo (trace), Loki (logg)
├── Database-queries? → EXPLAIN ANALYZE, N+1, paginering
├── Ekstern tjeneste treg? → Circuit breaker, caching
└── Ressursbegrensning?
    ├── CPU throttling → ALDRI sett CPU limits på NAIS (bruk kun requests)
    └── Memory pressure → øk `resources.limits.memory`
```

Se `observability-setup` for Micrometer, PromQL/LogQL og varsling.

## Deploy-problemer (kort)

```
Deploy feiler
├── GitHub Actions-feil? → Build/Docker/Push — sjekk actions-log og GAR-tilgang
├── Nais deploy-feil?
│   ├── "invalid manifest" → valider YAML (se `nais-manifest`)
│   ├── "unauthorized" → sjekk deploy-key / workload-identity
│   └── "resource quota exceeded" → team-kvote
└── Deploy OK men app feiler? → bruk pod-diagnose
```

## Relaterte skills

- `nais-manifest` — manifest-struktur, resources, accessPolicy, GCP SQL, Kafka pool
- `auth-overview` — Azure AD, TokenX, ID-porten, Maskinporten, Texas/Oasis
- `kafka-topic` — consumer/producer-mønstre, SSL-env, idempotens
- `observability-setup` — metrikker, logging, tracing og varsling

## Grenser

### Alltid

- Start med symptomet; ikke spekuler på årsak før logs/events er sjekket.
- Følg det diagnostiske treet steg for steg.
- Sjekk `kubectl logs --previous` ved CrashLoopBackOff.
- Respekter teamets eksisterende stack — ikke foreslå Rapids & Rivers-fiks på en plain Kafka-konsument eller omvendt.

### Spør først

- Endre produksjons-konfigurasjon (resources, replicas, secrets, accessPolicy).
- Restart av pods i produksjon.
- Endring av database-konfigurasjon eller pool-størrelse.

### Aldri

- Endre secrets direkte i klusteret (gå via kildekontroll / NAIS).
- Kjør `kubectl delete pod` i prod uten å forstå årsaken.
- Ignorer `OOMKilled` — den vil komme tilbake.
- Sett CPU-limits på NAIS — forårsaker throttling.
