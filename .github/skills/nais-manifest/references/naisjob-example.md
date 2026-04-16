# Naisjob — full eksempel

Batch-jobb for et app-team, med Kafka-produsent, Azure AD (M2M via client credentials) og Postgres.

```yaml
apiVersion: nais.io/v1
kind: Naisjob
metadata:
  name: nightly-report
  namespace: mitt-team
  labels:
    team: mitt-team
spec:
  image: {{ image }}

  # Cron — dette kjøres 02:00 hver natt. Bruk tom/utelatt for engangs-kjøring.
  schedule: "0 2 * * *"

  # Sikkerhetsnett mot hengende jobber og feil-loops
  activeDeadlineSeconds: 3600   # Abort etter 1 time
  backoffLimit: 2               # Maks 2 retries ved feil
  ttlSecondsAfterFinished: 86400

  # Observability — samme som Application
  prometheus:
    enabled: true
    path: /metrics
  observability:
    autoInstrumentation:
      enabled: true
      runtime: java

  # Ingen cpu-limit (CFS-throttling); memory-limit er obligatorisk
  resources:
    requests:
      cpu: 100m
      memory: 512Mi
    limits:
      memory: 1Gi

  # M2M via Azure AD client credentials
  azure:
    application:
      enabled: true
      tenant: nav.no

  # Tilgangsstyring — vær eksplisitt på alt jobben kaller
  accessPolicy:
    outbound:
      rules:
        - application: min-api
          namespace: mitt-team
        - application: pdl-api
          namespace: pdl
      external:
        - host: graph.microsoft.com

  # Kafka — samme pool-navngiving som Application
  kafka:
    pool: nav-prod

  # Postgres — dedikert jobb-database eller delt med Application
  gcp:
    sqlInstances:
      - type: POSTGRES_17
        tier: db-custom-1-3840
        highAvailability: true
        diskAutoresize: true
        databases:
          - name: report-db
            envVarPrefix: DB

  # Miljøvariabler for selve jobben
  env:
    - name: REPORT_TARGET_BUCKET
      value: gs://mitt-team-rapporter
```

## Når bør du bruke Naisjob framfor Application?

- Jobben har en **definert slutt** (rapport-kjøring, migrering, opprydding).
- Den skal kjøre **på skjema** (cron) eller **manuelt** (engangs-kjøring).
- Den skal **ikke** eksponere HTTP for innkommende trafikk.

Hvis du trenger en kontinuerlig kø-konsument (Kafka), bruk `Application` — ikke `Naisjob`.

## Scheduling-tips

- Unngå `* * * * *`-nær-frekvens — bruk heller en langkjørende `Application` hvis jobben kjører oftere enn hvert 5. minutt.
- Sett `concurrencyPolicy: Forbid` hvis en jobb kan overlappe seg selv.
- Test cron-uttrykk med [crontab.guru](https://crontab.guru) før commit.
