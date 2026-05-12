# PromQL, LogQL og dashboards

Denne referansen samler vanlige queries for Grafana, Prometheus og Loki. Tilpass metric-navn, labels og tidsvinduer til applikasjonen du jobber med.

## PromQL-eksempler

### Throughput

```promql
sum(rate(http_server_requests_seconds_count{app="my-app"}[5m]))
```

For event-drevne systemer:

```promql
sum(rate(rapids_events_processed_total{app="my-app"}[5m])) by (event_type)
```

### Error rate

```promql
sum(rate(http_server_requests_seconds_count{app="my-app",status=~"5.."}[5m]))
/
sum(rate(http_server_requests_seconds_count{app="my-app"}[5m]))
```

Hvis appen bruker egne countere for business-feil:

```promql
sum(rate(payments_processed_total{app="my-app",result="failure"}[5m]))
/
sum(rate(payments_processed_total{app="my-app"}[5m]))
```

### Latency percentiles

Micrometer/Spring eksponerer ofte histogram buckets som kan brukes slik:

```promql
histogram_quantile(
  0.95,
  sum(rate(http_server_requests_seconds_bucket{app="my-app"}[5m])) by (le, uri, method)
)
```

Tilsvarende for en egendefinert timer:

```promql
histogram_quantile(
  0.99,
  sum(rate(payment_processing_duration_seconds_bucket{app="my-app"}[5m])) by (le)
)
```

### Pod restarts og køstørrelse

```promql
sum(increase(kube_pod_container_status_restarts_total{app="my-app"}[15m]))
```

```promql
max_over_time(task_queue_size{app="my-app"}[10m])
```

## LogQL-eksempler

### Enkel filtrering

```logql
{app="my-app", namespace="your-team"} |= "ERROR"
```

```logql
{app="my-app", namespace="your-team"} | json | level="error"
```

### Aggregering

Feil per container per minutt:

```logql
sum(rate({app="my-app", namespace="your-team"} |= "ERROR" [1m])) by (container)
```

Strukturerte logs gruppert på event-type:

```logql
sum by (event_type) (
  rate({app="my-app"} | json | event_type=~".+" [5m])
)
```

### Korrelasjon med traces

Når logger inneholder `trace_id`, kan du hente alle loggene for et trace:

```logql
{app="my-app", namespace="your-team"}
| json
| trace_id="2f2f2264a8b6df9f8b3d614f4c9ce111"
```

Du kan også kombinere med feilmeldinger:

```logql
{app="my-app"}
| json
| level="error"
| trace_id=~".+"
```

### Kafka og Rapids & Rivers

```logql
{app="my-app"}
| json
| event_type="payment_created"
| result="failure"
```

```logql
{app="my-app"} |= "consumer lag"
```

## Dashboard-forslag

Et godt dashboard bør dekke både teknisk helse og domeneeffekt.

### 1. Golden signals
- throughput / request rate
- error rate
- latency p50, p95 og p99
- saturation: CPU, minne, connection pools, consumer lag

### 2. Plattform og drift
- antall pods / tilgjengelige replikaer
- pod restarts
- readiness/liveness-feil
- database pool usage

### 3. Business metrics
- prosesserte hendelser per type
- antall feil per flyt eller steg
- køstørrelse
- behandlingstid for viktige domeneoperasjoner

## Praktiske tips

- Bruk samme label-sett i dashboard og varsler der det gir mening
- Normaliser `route` eller `uri` før du bygger paneler, ellers blir grafene støyete
- Se alltid på både metrics og logs når du feilsøker latency eller feilrater
- Bruk traces når du må finne flaskehalser på tvers av HTTP, Kafka og databasekall
