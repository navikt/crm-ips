---
name: nais-manifest
description: Generer og vedlikehold NAIS-manifest — spec, database, Kafka, auth, accessPolicy, ressurser, Naisjob
keywords: [nais, nais-manifest, application, naisjob, accesspolicy, cpu-limits, cpu-throttling, hikaricp, ingress, health-endpoints, gcp-sql, kafka, azure-ad, tokenx]
---

# NAIS-manifest

Bruk denne skillen når du skal lage eller oppdatere et komplett NAIS-manifest (CRD-ene `Application` og `Naisjob`).

## Fremgangsmåte

1. **Les eksisterende NAIS-manifester** i `.nais/` eller `nais/` for å forstå hvordan applikasjonen er satt opp i dag. Bruk eksisterende `namespace` og `labels.team` — ikke anta verdier.
2. Avklar om applikasjonen er backend (Kotlin) eller frontend (Node.js), siden port, health paths og observability-oppsett kan variere.
3. Kartlegg hvilke ressurser applikasjonen trenger: database, Kafka, auth, ingress, scaling — eller om det er en batch-jobb (`Naisjob`).
4. Gjenbruk eksisterende stier for health, readiness og metrics fra nåværende manifester.
5. Bruk miljøspesifikke manifester (`app-dev.yaml`, `app-prod.yaml`) når repoet allerede følger det mønsteret.

## Application-mal

```yaml
apiVersion: nais.io/v1alpha1
kind: Application
metadata:
  name: {app-name}
  namespace: {team-namespace}   # Les fra eksisterende manifest
  labels:
    team: {team-namespace}
spec:
  image: {{ image }}
  port: 8080                    # Frontend bruker ofte 3000

  prometheus:
    enabled: true
    path: /metrics              # Eller /internal/prometheus — sjekk eksisterende
  liveness:
    path: /isAlive              # Nais-default — sjekk eksisterende
    initialDelay: 5
  readiness:
    path: /isReady
    initialDelay: 5

  resources:
    requests:
      cpu: 50m
      memory: 256Mi
    limits:
      memory: 512Mi             # Sett aldri cpu-limits — se regel under
```

**Viktig:** Sjekk alltid eksisterende manifester for korrekt `port`, `prometheus.path`, `liveness.path` og `readiness.path`.

## Regel: ingen CPU-limits i Nais

Sett **aldri** `resources.limits.cpu` i Nais-manifest — bare `requests.cpu`.

**Hvorfor:** Kubernetes CFS-quota håndhever CPU-limits i 100ms-vinduer. Når en container når grensen kort, blir hele containeren throttlet i resten av vinduet — også tråder som ikke trenger CPU. Resultat: latenshaler, oppstartsproblemer (JIT, GC), og timeouts. Nais-plattformen anbefaler `requests.cpu` for scheduling og lar noden håndtere faktisk bruk.

Memory-limits derimot **skal settes** — uten limit kan en container ta ned hele noden via OOM.

## Ressursstartpunkter

| Størrelse | `requests.cpu` | `requests.memory` | `limits.memory` |
|-----------|----------------|-------------------|-----------------|
| Liten     | 15–50m         | 256Mi             | 512Mi           |
| Middels   | 100m           | 512Mi             | 1Gi             |
| Stor      | 200m           | 1Gi               | 2Gi             |

Juster basert på faktisk forbruk (Grafana). `replicas: { min: 2, max: 4, cpuThresholdPercentage: 80 }` er greit startpunkt for prod.

## accessPolicy — alltid eksplisitt

Definer både `inbound` og `outbound`. Glem ikke `cluster` og `namespace` for kall utenfor eget namespace:

```yaml
accessPolicy:
  inbound:
    rules:
      - application: min-frontend
        namespace: mitt-team
      - application: annen-tjeneste
        namespace: annet-team
        cluster: prod-gcp
  outbound:
    rules:
      - application: pdl-api
        namespace: pdl
      - application: downstream-app
        namespace: downstream-namespace
    external:
      - host: api.ekstern-tjeneste.no
```

Se `references/naisjob-example.md` for en full Naisjob-mal.

## PostgreSQL (GCP SQL)

```yaml
gcp:
  sqlInstances:
    - type: POSTGRES_17         # Sjekk repoets versjon
      tier: db-f1-micro         # dev; prod: db-custom-1-3840
      highAvailability: false   # prod: true
      diskAutoresize: false     # prod: true
      databases:
        - name: myapp-db
          envVarPrefix: DB
```

Gir `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.

### HikariCP i containere — pool 3–5, ikke default 10

HikariCP default `maximumPoolSize` er 10. I Nais-containere er dette feil:

- Containeren har 1–2 CPU-kjerner (`requests.cpu: 100m` betyr brøkdel av én kjerne).
- 10 aktive forbindelser gir tråd-kontensjon og kontekstsvitsj-overhead.
- Cloud SQL Proxy og Postgres har egne grenser; mange små poolere × mange replicaer sprenger serveren.

**Start med `maximumPoolSize: 3–5`.** Øk bare hvis metrikker viser pool-exhaustion (`hikaricp_connections_pending`). Se [HikariCP About Pool Sizing](https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing) — formelen `connections = ((cores * 2) + effective_spindle_count)` gir lave tall i containere.

## Kafka

```yaml
kafka:
  pool: nav-dev                 # Eller nav-prod
```

Navnekonvensjon for topics: `{team}.{domene}.v{versjon}`. Dev: `partitions: 1, replication: 1`. Prod: `partitions: 6+, replication: 3`.

## Azure AD og TokenX

```yaml
azure:
  application:
    enabled: true
    tenant: nav.no              # Eller trygdeetaten.no

tokenx:
  enabled: true                 # On-behalf-of for innlogget bruker
```

For ren maskin-til-maskin uten personkontekst: bruk Maskinporten. For partner-integrasjoner som må handle på vegne av en virksomhet i Altinn, bruk Altinn 3 systembruker (Maskinporten + systembruker-token).

## Ingress — velg riktig domene

Nav har tre hoveddomener for ingress:

| Domene                           | Bruk                                          |
|----------------------------------|-----------------------------------------------|
| `*.nav.no`                       | Publikumsrettede brukerflater (nav.no)        |
| `*.intern.nav.no`                | Interne ansattflater (krever Nav-nettverk/naisdevice) |
| `*.ekstern.nav.no`               | Eksterne brukerflater som ikke ligger på nav.no |

Dev-varianter: `*.dev.nav.no`, `*.intern.dev.nav.no`, `*.ekstern.dev.nav.no`.

```yaml
ingresses:
  - https://min-app.intern.dev.nav.no
```

## Auto-instrumentation (Observability)

```yaml
observability:
  autoInstrumentation:
    enabled: true
    runtime: java               # Eller nodejs, python
```

Tracing sendes til Tempo, logger til Loki (logg til stdout/stderr, gjerne JSON), metrikker til Prometheus.

## Naisjob — batch-jobber for app-team

Bruk `Naisjob` når teamet trenger batch-jobber (nattlige kjøringer, engangs-migreringer, rapporter). Samme team-eierskap som `Application`, men kjører til fullført i stedet for kontinuerlig. Typiske felter: `schedule` (cron), `activeDeadlineSeconds`, `backoffLimit`, og de samme blokkene for `resources`, `accessPolicy`, `gcp`, `kafka` og `azure` som `Application`.

Full mal med Kafka og Azure AD: `references/naisjob-example.md`.

## Boundaries

### Always
- Include liveness, readiness, and metrics endpoints (`/isAlive`, `/isReady`, `/metrics`)
- Set memory limits (prevents OOM)
- Define explicit `accessPolicy` (inbound + outbound)
- Use environment-specific manifests (`app-dev.yaml`, `app-prod.yaml`)

### Ask first
- Changing production resource requests/replicas
- Adding new GCP resources (cost implications)
- Modifying `accessPolicy` in prod
- Adding new ingress domains

### Never
- Set `resources.limits.cpu` (throttling via CFS-quota)
- Remove `resources.limits.memory`
- Store secrets in Git
- Skip health endpoints
- Bruk default HikariCP `maximumPoolSize: 10` i en container
