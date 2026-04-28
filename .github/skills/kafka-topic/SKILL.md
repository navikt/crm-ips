---
name: kafka-topic
description: "Kafka-oppsett i Nav — topics, Kafkarator, consumer, producer, schema registry, plain Kafka, Spring Kafka eller Rapids & Rivers. Brukes via /kafka-topic ved nye eller endrede Kafka-oppsett."
---

# Kafka — Topic, Consumer og Producer

## Detekter eksisterende Kafka-stil først

**Før du foreslår kode: finn ut hvilken stack teamet allerede bruker — plain Apache Kafka-klient, Spring Kafka, eller Rapids & Rivers. Følg teamets valg. Ikke foreslå migrasjon plain ↔ Rapids ↔ Spring uten eksplisitt oppdrag.**

Hurtigdeteksjon i repoet:

| Signal | Sannsynlig stack |
|--------|------------------|
| `no.nav.helse:rapids-rivers` i `build.gradle.kts`; `RapidApplication.create(env)`; klasser som implementerer `River.PacketListener` | Rapids & Rivers |
| `org.springframework.kafka:spring-kafka`; `@KafkaListener`; `KafkaTemplate` | Spring Kafka |
| `org.apache.kafka:kafka-clients`; direkte bruk av `KafkaConsumer` / `KafkaProducer` | Plain Apache Kafka |

Følg det dominerende mønsteret. Hvis repoet har blanding, bekreft med teamet før du introduserer en ny stil.

## Fremgangsmåte

1. Sjekk NAIS-manifest for `kafka.pool` og Kafkarator `Topic`-CRD-er.
2. Søk i kodebasen etter eksisterende consumere/producere og følg samme mønster som allerede er etablert.
3. Sjekk `build.gradle.kts` for å bekrefte stack (se tabell over).
4. Planlegg event-kontrakt (navn, nøkkel, felter) — se [Nav-hendelsesdesign](#nav-hendelsesdesign) under.

## Sync vs. hendelse — når velge hva

Valget står mellom synkron REST og asynkron hendelse. Velg etter behov, ikke etter vane.

| Behov | Mønster | Når bruke |
|-------|---------|-----------|
| Svar trengs umiddelbart, kallet må lykkes eller feile synlig | REST / GraphQL | CRUD, oppslag, brukerinteraksjon |
| Fire-and-forget notifikasjon, logg eller asynk prosessering | Kafka-produsent (plain/Spring) | Varsling, audit, downstream-prosess som kan vente |
| Hendelse-koreografi på tvers av mange tjenester | Rapids & Rivers på delt rapid-topic | Saga-flyter, flertjeneste-arbeidsflyt |
| Batch / periodisk prosessering | Naisjob (+ Kafka hvis nedstrøm) | Nattjobber, rapporter, reprocessing |

Hvis teamet allerede bruker Rapids & Rivers for koreografi, publiser nye hendelser dit i stedet for å lage parallell plain-producer.

## NAIS Kafka-konfigurasjon

```yaml
# nais.yaml
spec:
  kafka:
    pool: nav-dev  # eller nav-prod
```

NAIS injiserer automatisk SSL-env vars i podden:

- `KAFKA_BROKERS` — bootstrap servers
- `KAFKA_TRUSTSTORE_PATH` / `KAFKA_KEYSTORE_PATH` — PKCS12-filer
- `KAFKA_CREDSTORE_PASSWORD` — passord for begge
- `KAFKA_SCHEMA_REGISTRY` / `KAFKA_SCHEMA_REGISTRY_USER` / `KAFKA_SCHEMA_REGISTRY_PASSWORD` — hvis `kafka.streams.enabled` eller schema registry er aktivert

## Topic-provisjonering med Kafkarator

Topics i Nav opprettes deklarativt via Kafkarator `Topic`-CRD-er i team-repoet (ofte i `<team>-kafka`-repo) — ikke via kode eller kubectl manuelt.

```yaml
apiVersion: kafka.nais.io/v1
kind: Topic
metadata:
  name: <team>.<domene>.v<versjon>
  namespace: <team>
  labels:
    team: <team>
spec:
  pool: nav-prod
  config:
    retentionHours: 168          # 7 dager
    retentionBytes: -1           # uten grense
    cleanupPolicy: delete        # eller "compact" for state-topics
    minimumInSyncReplicas: 2
    partitions: 3
    replication: 3
  acl:
    - team: <team>
      application: <app>
      access: readwrite          # read | write | readwrite
    - team: <annet-team>
      application: <konsument-app>
      access: read
```

Viktige valg:

- **cleanupPolicy: compact** for topics som representerer siste tilstand per nøkkel (f.eks. brukertilstand). Krever at key er satt og stabil.
- **partitions**: øk tidlig, nedjustering krever ny topic. Start med 3–6 for domene-hendelser, høyere for rapid.
- **acl**: eksplisitt per konsument-app — ikke wildcard.

## Nav-hendelsesdesign

Disse konvensjonene er **stack-agnostiske** — gjelder uansett om du bruker plain Kafka, Spring eller Rapids.

### Topic-navngivning

```
<team>.<domene>.v<versjon>

teamdagpenger.rapid.v1           # Rapids & Rivers fellestopic
teamforeldrepenger.vedtak.v1     # Domene-hendelser
teamtiltak.saksbehandling.v1     # Domene-hendelser
```

### Key-strategi

- **Bruker/entitet-ID som key** → hendelser for samme entitet havner på samme partisjon → rekkefølge bevares per entitet.
- `fnr`, `aktørId`, `søknadId`, `vedtakId` er typiske nøkler.
- Ikke bruk random UUID som key med mindre du bevisst vil ha jevn partisjonsspredning uten rekkefølge-garanti.

### Event-navngivning og innhold

- **Fortid + snake_case**: `vedtak_fattet`, `søknad_sendt`, `utbetaling_beregnet` — ikke `create_vedtak` / `process`.
- **Hendelser er fakta**, ikke kommandoer. Beskriv hva som skjedde, ikke hva mottaker skal gjøre.
- **Standard metadata** i payload:
  - `@event_name` — hendelsestype
  - `@id` — unik UUID per hendelse (brukes til idempotens)
  - `@created_at` — ISO-8601 timestamp
  - `@produced_by` — avsendertjeneste
  - `@correlation_id` — propagér fra innkommende request (valgfritt men sterkt anbefalt)
- **Ingen PII uten bevisst vurdering**. Fødselsnummer som key er akseptabelt på Nav-interne topics, men vurder kryptering av fritekst og sensitive felter.

### Versjonering av hendelser

Se [Event-evolusjon](#event-evolusjon) under.

## Idempotens

Kafka leverer minst-én-gang — duplikater forekommer. Konsumenter må være idempotente.

```kotlin
fun processRecord(eventId: String, /* ... */) {
    if (eventStore.alreadyProcessed(eventId)) return
    // prosesser...
    eventStore.markProcessed(eventId)
}
```

Bruk `@id` (Rapids) eller en stabil event-ID i payload — ikke Kafka-offset (endres ved re-partisjonering).

## Dead-letter-håndtering (konsept)

Meldinger som aldri kan prosesseres (korrupt payload, permanent valideringsfeil, ukjent schema) skal **ikke blokkere strømmen**. Strategi:

1. **Skill mellom midlertidig og permanent feil**. Midlertidige (nettverk, DB nede) → kast exception, la Kafka retry. Permanente → log + send til DLQ, fortsett.
2. **DLQ-topic** per domene (`<team>.<domene>.dlq.v1`) som fanger originalmelding + feilårsak + timestamp.
3. **Alarm** på DLQ-innflyt (ikke på enkeltmelding — på rate).
4. **Manuell gjenspilling** etter bugfix: les DLQ, republiser til original topic.

Konkret implementasjon følger teamets stack — Spring har `DeadLetterPublishingRecoverer`, Rapids-team ruller ofte egen DLQ-producer. Følg mønsteret som allerede finnes i repoet.

## Stack-spesifikke mønstre

Detaljerte eksempler for hver stack — les kun den som er aktuell:

- **Plain Apache Kafka** (Kotlin consumer/producer-skjelett, Spring Kafka `@KafkaListener`, SSL-config): se [`references/plain-and-spring.md`](references/plain-and-spring.md).
- **Rapids & Rivers** (River-oppsett, validate/demand/require, publisering, TestRapid): se [`references/rapids-and-rivers.md`](references/rapids-and-rivers.md).

## Event-evolusjon

```
Hvordan endre en eksisterende hendelse?
├── Legg til nytt felt (optional)
│   └── Bakoverkompatibelt. Konsumenter må bruke interestedIn / tolerant parsing,
│       ikke requireKey, på nye felter.
│
├── Endre feltformat (breaking)
│   └── Ny topic-versjon v2. Dual-write fra produsent.
│       Migrer konsumenter én om gangen. Stopp v1-produksjon sist.
│
├── Fjerne felt
│   └── 1. Verifiser at ingen konsumenter krever feltet.
│       2. Fjern fra produsent.
│       3. Vent minst én uke + overvåk før topic-rydding.
│
└── Ny hendelsestype
    └── Publiser med ny @event_name. Eksisterende konsumenter ignorerer
        ukjente event_names automatisk (gjelder spesielt Rapids).
```

## Sjekkliste

- [ ] Stack identifisert i repoet — følger eksisterende mønster
- [ ] `kafka.pool` satt i NAIS-manifest
- [ ] Topic opprettet via Kafkarator `Topic`-CRD (ikke ad-hoc)
- [ ] ACL eksplisitt per konsument-app
- [ ] Topic-navn følger `<team>.<domene>.v<versjon>`
- [ ] Event-navn i fortid + snake_case
- [ ] Key-strategi gir rimelig partisjonsspredning og bevarer rekkefølge per entitet
- [ ] Standard metadata (`@event_name`, `@id`, `@created_at`) i payload
- [ ] Idempotent konsumering (dedup på event-ID)
- [ ] DLQ-strategi for permanente feil, alarm på DLQ-rate
- [ ] Strukturert logging med `event_id` / `correlation_id` — ingen PII i logg
- [ ] Metrikker for prosesserte hendelser og feil
- [ ] Tester etter eksisterende testmønster i repoet
