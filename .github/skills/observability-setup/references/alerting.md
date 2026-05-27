# Alerting, Faro og varsling

Denne referansen beskriver praktiske mønstre for Prometheus-regler, frontend-observability med Faro og varsling til Slack i NAIS.

## Vanlige varslingsmønstre

Prioriter varsler som peker på reelle brukerproblemer eller driftsproblemer teamet faktisk må reagere på.

### High error rate

```yaml
groups:
  - name: my-app-alerts
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_server_requests_seconds_count{app="my-app",status=~"5.."}[5m]))
            /
            sum(rate(http_server_requests_seconds_count{app="my-app"}[5m]))
          ) > 0.05
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "High error rate for my-app"
          description: "More than 5% of requests fail with 5xx over 10 minutes"
          runbook_url: "https://teamdocs/runbooks/my-app-errors"
```

### Latency spike

```yaml
- alert: HighLatencyP95
  expr: |
    histogram_quantile(
      0.95,
      sum(rate(http_server_requests_seconds_bucket{app="my-app"}[5m])) by (le)
    ) > 1
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: "High latency for my-app"
    description: "p95 latency is above 1 second"
```

### Pod restart / utilgjengelighet

```yaml
- alert: PodRestarts
  expr: sum(increase(kube_pod_container_status_restarts_total{app="my-app"}[15m])) > 3
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Pods are restarting frequently"
    description: "my-app has restarted more than 3 times in 15 minutes"

- alert: ApplicationDown
  expr: sum(up{app="my-app"}) == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Application is down"
    description: "No healthy targets are being scraped for my-app"
```

### Kafka / køproblemer

```yaml
- alert: KafkaConsumerLagHigh
  expr: max(kafka_consumer_lag{app="my-app"}) > 10000
  for: 15m
  labels:
    severity: warning
  annotations:
    summary: "Kafka consumer lag is high"
    description: "Lag has stayed above 10000 for 15 minutes"
```

## NAIS-mønstre for varslingsregler

- Bruk korte, stabile alert-navn
- Legg alltid til `summary`, `description` og helst runbook-lenke
- Bruk `warning` for ting som bør undersøkes, `critical` for aktiv hendelse
- Alert på symptomer før interne indikatorer
- Test terskler i dev eller staging før du strammer dem i prod
- Unngå mange nesten-like varsler med små variasjoner i terskel

## Slack-integrasjon

Varsler kan sendes til Slack-kanaler via NAIS Alert-ressurser.

```yaml
apiVersion: nais.io/v1
kind: Alert
metadata:
  name: my-app-alerts
spec:
  receivers:
    slack:
      channel: "#your-team-alerts"
      prependText: "@here "
  alerts:
    - alert: HighErrorRate
    - alert: HighLatencyP95
    - alert: ApplicationDown
```

Velg kanal og `prependText` med omtanke. Kritiske varsler kan bruke `@here`; støyende varsler bør normalt ikke gjøre det.

## Faro frontend SDK (Next.js)

Faro er nyttig når du trenger frontend-feil, hendelser og korrelasjon mellom brukeropplevelse og backend-hendelser.

```typescript
import { initializeFaro } from '@grafana/faro-web-sdk';

export const faro = initializeFaro({
  url: process.env.NEXT_PUBLIC_FARO_URL!,
  app: {
    name: 'my-app-frontend',
    version: process.env.NEXT_PUBLIC_APP_VERSION,
    environment: process.env.NEXT_PUBLIC_ENVIRONMENT,
  },
});
```

Manuell rapportering av feil og events:

```typescript
import { faro } from './faro';

export async function submitApplication(): Promise<void> {
  try {
    faro.api.pushEvent('application_submit_started', { surface: 'main-form' });
    await fetch('/api/applications', { method: 'POST' });
    faro.api.pushEvent('application_submit_completed', { result: 'success' });
  } catch (error) {
    faro.api.pushError(error as Error, {
      context: { flow: 'application_submit' },
    });
    faro.api.pushEvent('application_submit_completed', { result: 'failure' });
    throw error;
  }
}
```

### Faro-regler
- Send bare teknisk og forretningsmessig nyttig metadata
- Ikke send fødselsnummer, e-post, tokens eller andre sensitive felter
- Bruk konsistente event-navn og et lite, stabilt sett med attributter
- Samordne event-navn med dashboards og varsler der det gir verdi
