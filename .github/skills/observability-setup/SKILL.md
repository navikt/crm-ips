---
name: observability-setup
description: "Observability-oppsett og -forbedring — metrikker, strukturert logging, tracing, alerts, Micrometer, PromQL/LogQL, Grafana og Faro. Brukes via /observability-setup ved etablering eller forbedring av overvåkning."
---

# Sett opp observability

Bruk denne skillen når du skal etablere eller forbedre observability i en Nav-applikasjon. Hold hovedreglene korte. Bruk `references/` for detaljer.

## Kort intro

- **Metrikker** forteller *hva* som skjer
- **Logger** forklarer *hvorfor* det skjedde
- **Traces** viser *hvor* i flyten det skjedde
- Verifiser alltid eksisterende oppsett i repoet før du legger til nye målepunkter, labels eller varsler

## Arbeidsflyt

1. Les NAIS-manifest, `application*.yaml`, `build.gradle.kts` eller `package.json` for eksisterende observability-oppsett.
2. Finn etablerte mønstre for Micrometer, `prom-client`, strukturert logging, health-endepunkter og tracing.
3. Verifiser hvilke endepunkter som faktisk brukes (`/isalive`, `/isready`, `/metrics`, `/internal/*`, `/actuator/*`).
4. Start med standardmålinger og utvid med domenemetrikker som gir operativ verdi.
5. Legg til dashboards og varsler når metrikkene og label-settet er stabile.

## Navngivning for metrikker og labels

### Metrikker
- Bruk `snake_case`
- Bruk enhetssuffiks når det er relevant: `_seconds`, `_bytes`, `_milliseconds`
- Countere skal ha suffikset `_total`
- Bruk navn som beskriver domenet
- Unngå `camelCase`, forkortelser uten mening og miljøspesifikke navn

### Nav-label-konvensjoner

Nais-plattformen legger automatisk på et sett med labels. Ikke dupliser disse på egne metrikker — bruk dem konsistent i queries, dashboards og varsler:

- `app` — applikasjonsnavn fra Nais-manifestet
- `team` — eierskapsteam (brukes til alert-ruting og DORA-metrikker)
- `namespace` — Kubernetes-namespace, typisk teamnavn
- `env` — miljø (`dev`, `prod`)
- `cluster` — Nais-cluster (`dev-gcp`, `prod-gcp`, `dev-fss`, `prod-fss`)

Egne labels bør dekke domeneaspekter:
- Gode: `method`, `route`, `status`, `event_type`, `result`, `consumer_group`, `topic`
- Dårlige: `user_id`, `email`, `fnr`, `trace_id`, `transaction_id`, rå URL-er med dynamiske segmenter
- Foretrekk normaliserte verdier som `/api/oppgaver/:id`
- Hver unik label-kombinasjon gir en ny tidsserie: legg bare til labels som brukes i dashboards, varsler eller feilsøking

## Backend (Kotlin/Spring)

- Aktiver Prometheus/Micrometer og behold eksisterende registry-oppsett hvis det finnes
- Sørg for health- og metrics-endepunkter som stemmer med NAIS-manifestet
- Bruk `Counter`, `Timer`, `Gauge` og `DistributionSummary` bevisst
- Mål viktige domenehendelser, køstørrelser, feilrater og behandlingstid
- Aktiver OpenTelemetry auto-instrumentation i NAIS før du legger til manuelle spans

Se `references/micrometer.md` for Kotlin/Spring-eksempler, health-oppsett og domenemetrikker.

## Frontend (Next.js)

- Bruk Faro når appen trenger frontend-feil, brukerhendelser eller innsikt i web-vitals
- Skill mellom tekniske hendelser og reelle domenehendelser
- Send aldri persondata, tokens eller andre hemmeligheter til frontend-observability
- Samordne event-navn og felter med backend der korrelasjon er viktig

Se `references/alerting.md` for Faro-oppsett og varslingsmønstre.

## Korrelasjons-ID for Nav-stacken

Korrelasjons-ID lar deg følge en forespørsel på tvers av tjenester, Kafka-meldinger og logger.

### Headers
- `Nav-Callid` — Nav-konvensjon, propager gjennom alle HTTP-kall
- `X-Correlation-ID` — aksepter som fallback for eksterne integrasjoner
- W3C `traceparent` — settes automatisk av OpenTelemetry-agenten

Ved innkommende request: les `Nav-Callid` (eller `X-Correlation-ID`, eller generer en UUID), og send samme verdi videre på alle utgående HTTP-kall og Kafka-headere.

### MDC i JVM

Legg korrelasjonsfelt på MDC slik at logback-encoder automatisk inkluderer dem i alle logger i request-scope:

```kotlin
MDC.put("callId", callId)
MDC.put("trace_id", Span.current().spanContext.traceId)
try {
    // handle request
} finally {
    MDC.clear()
}
```

I Ktor/Spring brukes ofte en `CallIdPlugin` eller filter som gjør dette automatisk.

### Structured logging
Inkluder `trace_id`, `span_id` og `callId` i alle logger slik at Loki kan korrelere med Tempo (klikkbare trace-IDer i Grafana).

## Logging og tracing

- Logg strukturert JSON til stdout/stderr — Nais-loki henter automatisk
- Følg eksisterende mønstre med MDC, `kv()` eller tilsvarende strukturerte argumenter
- Inkluder `trace_id`, `span_id` og `callId` når loggingoppsettet støtter det
- Ikke bruk logger som erstatning for metrikker; metrikker skal svare på frekvens, volum og varighet
- Bruk tracing for request-kjeder, Kafka-flyt og kall mot databaser eller eksterne tjenester

### JSON-format for Nais-loki

Nais-loki forventer én JSON-linje per logg på stdout. Felter som Loki parser og indekserer:

```json
{
  "@timestamp": "2026-04-14T10:23:45.123Z",
  "level": "INFO",
  "message": "Payment processed",
  "logger_name": "no.nav.payment.PaymentService",
  "thread_name": "eventLoopGroupProxy-4-1",
  "trace_id": "2f2f2264a8b6df9f8b3d614f4c9ce111",
  "span_id": "b3d614f4c9ce111a",
  "callId": "abc-123",
  "event_type": "payment_processed",
  "payment_id": "p-42"
}
```

Minimumsfelt: `@timestamp`, `level`, `message`. Legg domenedata i top-level felt (Loki JSON-parser eksponerer dem som labels i LogQL), ikke nøstet under `context`. Aldri PII, tokens eller fnr.

Bruk `logstash-logback-encoder` (JVM) eller `pino` (Node) med Nais-preset. Autonmatiske Loki-labels: `app`, `namespace`, `cluster`, `container`, `pod`, `stream` — ikke dupliser disse i payloaden.

## Grafana-dashboards for Nais-apper

Hver Nais-app bør ha et dashboard med følgende paneler som baseline. Bruk `app`, `namespace` og `cluster` som template-variabler.

### Golden signals
- **Request rate** — `sum(rate(http_server_requests_seconds_count{app="$app"}[5m]))` (per `route`/`method`)
- **Error rate** — 5xx-andel av total trafikk, både som prosent og absolutt rate
- **Latency p95/p99** — `histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket[5m])) by (le, route))`

### Ressurser
- **Pool usage** — `hikaricp_connections_active / hikaricp_connections_max` for databasen
- **JVM heap og GC** — `jvm_memory_used_bytes`, `rate(jvm_gc_pause_seconds_sum[5m])`
- **Pod restarts** — `increase(kube_pod_container_status_restarts_total{app="$app"}[1h])`

### Kafka (hvis aktuelt)
- **Consumer lag** — `kafka_consumer_lag` eller `kafka_consumergroup_lag` per `topic` og `consumer_group`
- **Consumer/producer rate** og feil per topic

### Domene
- Hendelser prosessert per minutt, per `event_type`
- Feilrate per flyt (`result="failure"`)
- Køstørrelse og behandlingstid for kritiske operasjoner

Se `references/promql-logql.md` for komplette PromQL- og LogQL-eksempler.

## Varsling

- Varsle på brukeropplevde symptomer først: feilrate, latency, utilgjengelighet og restarts
- Bruk runbook-lenker og tydelige annotasjoner
- Hold terskler forsiktige til du kjenner trafikkmønstrene
- Skill mellom `warning`, `critical` og informative varsler

Se `references/alerting.md` for Prometheus-regler, Slack-integrasjon og vanlige varslingsmønstre.

## Sjekkliste

- [ ] Health-, readiness- og metrics-endepunkter stemmer med NAIS-manifestet
- [ ] Auto-instrumentation er vurdert eller aktivert for riktig runtime
- [ ] Strukturert JSON-logging til stdout med `trace_id`, `span_id`, `callId`
- [ ] Korrelasjons-ID (`Nav-Callid`) leses, propageres og legges på MDC
- [ ] Viktige domenemetrikker er definert med stabile navn og labels
- [ ] Dashboards dekker request rate, error rate, latency p95/p99, pool usage og Kafka lag
- [ ] Varsler finnes for høy feilrate, høy latency, pod restarts og kritiske avhengigheter
- [ ] Logger, traces og labels på metrikker inneholder ikke sensitive data

## Boundaries

### Alltid
- Bruk `snake_case` og enhetssuffiks for metrikker
- Bruk lave og begrensede label-verdier
- Logg strukturert JSON til stdout (ikke filer)
- Propager `Nav-Callid` og legg `trace_id` i logger
- Følg eksisterende logging- og metrikkmønstre i repoet
- Verifiser health paths, scrape paths og tracing-oppsett mot faktisk konfigurasjon

### Spør først
- Nye labels som kan øke kardinalitet vesentlig
- Endring av produksjonsterskler for varsler
- Nye dashboards, mapper eller varslingskanaler som påvirker teamets arbeidsflyt

### Aldri
- Logg eller eksponer PII, tokens, passord, fnr eller andre hemmeligheter
- Bruk `camelCase` i metric-navn
- Bruk labels med høy kardinalitet (`user_id`, `fnr`, `transaction_id`, `trace_id`)
- Legg til observability-kode som ikke kan forklares operativt eller brukes i praksis
