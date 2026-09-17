# Kafka-diagnose — consumer lag og prosesseringsfeil

Diagnostiske trær for NAIS Kafka-konsumenter. **Detekter eksisterende stack først** — Nav-team bruker typisk plain Apache Kafka clients, men noen team bruker Rapids & Rivers. Diagnosen må matche det teamet faktisk kjører.

Se `kafka-topic` for mønstre; denne filen er for å *diagnostisere når de ikke virker*.

## Sjekk consumer

```bash
# Logs filtrert på Kafka-relaterte meldinger
kubectl logs -n {namespace} -l app={app-name} --tail=200 \
  | grep -i "kafka\|consumer\|producer\|topic\|offset\|partition\|rebalance"

# Sjekk feil
kubectl logs -n {namespace} -l app={app-name} --tail=500 \
  | grep -i "error\|exception\|failed\|rejected"

# Sjekk om den faktisk prosesserer
kubectl logs -n {namespace} -l app={app-name} --tail=50 \
  | grep -i "processed\|consumed\|committed"

# Prometheus-metrikker (via port-forward)
kubectl port-forward -n {namespace} svc/{app-name} 8080:8080
# curl -s localhost:8080/metrics | grep kafka
# kafka_consumer_group_lag
# kafka_consumer_fetch_manager_records_consumed_total
```

## Diagnostisk tre — Kafka consumer lag

```
Consumer lag øker
├── Er konsumenten oppe?
│   ├── Nei → se pod-diagnose.md (CrashLoopBackOff?)
│   └── Ja → gå videre
├── Øker lag kontinuerlig eller sporadisk?
│   ├── Sporadisk → normal trafikk-variasjon, sannsynligvis OK
│   └── Kontinuerlig → konsumenten klarer ikke holde tritt
│       ├── Sjekk prosesseringstid per melding (logg/trace per record)
│       ├── Poison pill? — én melding som alltid feiler, blokkerer offset-commit
│       ├── Vurder å øke `replicas` (opp til antall partitions)
│       └── Vurder å øke partitions på topic (krever koordinering)
├── Logger konsumenten feil?
│   ├── Deserialisering-feil → schema-mismatch, sjekk producer og Avro/JSON-skjema
│   ├── DB-feil underveis → se database-diagnose.md
│   ├── Rebalance-loop → sjekk `max.poll.interval.ms` vs. faktisk prosesseringstid
│   └── Ingen feil men ingen progress → sjekk at den faktisk leser riktig topic / consumer group
├── SSL / oppkobling?
│   ├── "SSL handshake failed" → sjekk at `KAFKA_TRUSTSTORE_PATH` og keystore er mountet
│   ├── "Connection refused" til `KAFKA_BROKERS` → sjekk at `kafka.pool` er satt i manifest
│   └── Env-vars mangler → NAIS injiserer disse; fungerer ikke uten `kafka.pool`
└── Rapids & Rivers (kun hvis appen faktisk bruker det)?
    ├── Sjekk at `validate { ... }`-regler matcher meldingsformat
    ├── `demandValue("@event_name", ...)` feil verdi → meldinger filtreres stille vekk
    ├── `requireKey("...")` manglende felt → melding rejected
    ├── Manglende `interestedIn("...")` → felt er `null` i `packet["..."]`
    └── Logg rejected messages for å få synlighet
```

## Vanlige Nav-spesifikke feilmønstre

| Observasjon | Årsak | Løsning |
|-------------|-------|---------|
| Lag øker lineært fra deploy | Ny `group.id` / offset reset = earliest | Kontrollert; vil ta igjen. Eventuelt sett `auto.offset.reset: latest` hvis OK |
| Konsument prosesserer ingenting, ingen feil | Feil `group.id` / topic-navn | Sjekk NAIS-manifest og config |
| Rebalance hver N minutt | Prosesseringstid > `max.poll.interval.ms` | Reduser batch-størrelse, eller øk interval |
| `SSL handshake failed` | NAIS SSL-env ikke brukt riktig | Sjekk at app leser `KAFKA_TRUSTSTORE_PATH` / `KAFKA_KEYSTORE_PATH` / `KAFKA_CREDSTORE_PASSWORD` |
| Rapids-meldinger "forsvinner" | `demandValue("@event_name", "...")` matcher ikke | Logg hva River faktisk ser; sjekk producer-event-navn |

## Rapids & Rivers — debug-tips

Rapids & Rivers filtrerer meldinger **stille** via `validate`. For å få synlighet:

- Midlertidig legg til `interestedIn("@event_name")` og logg i `onPacket` / `onError` for å se hva som faktisk passerer.
- Verifiser at producer sender `@event_name` i samme snake_case-skrivemåte (`vedtak_fattet`, ikke `vedtakFattet`).
- Sjekk at `App.Builder().withKafkaModule()` bruker samme topic(s) som producer skriver til (rapids-topic er ofte team-delt).

## Når dette peker på annet

- Pod-krasj → [pod-diagnose.md](./pod-diagnose.md)
- DB-feil i konsumenten → [database-diagnose.md](./database-diagnose.md)
- Auth-feil ved sidefeks kall → [auth-diagnose.md](./auth-diagnose.md)
