# Plain Apache Kafka og Spring Kafka — mønstre

Les kun den delen som matcher teamets stack. Ikke blande med mindre det finnes et eksisterende mønster i repoet.

## Plain Apache Kafka (Kotlin)

### Consumer-skjelett

```kotlin
val consumer = KafkaConsumer<String, String>(consumerProps())
consumer.subscribe(listOf(topic))

while (running) {
    val records = consumer.poll(Duration.ofMillis(1000))
    records.forEach { record ->
        try {
            processRecord(record)
        } catch (e: Exception) {
            logger.error(
                "Feil ved prosessering av melding",
                kv("topic", record.topic()),
                kv("partition", record.partition()),
                kv("offset", record.offset()),
                e
            )
            // Midlertidig feil → kast videre, Kafka retry via polling.
            // Permanent feil → send til DLQ, fortsett.
        }
    }
    consumer.commitSync()
}
```

Commit-strategi: `commitSync()` etter hver batch er trygt og enkelt. `commitAsync()` gir høyere throughput — bruk kun om du har et bevisst behov.

### Producer-skjelett

```kotlin
producer.send(ProducerRecord(topic, key, value)) { metadata, exception ->
    if (exception != null) {
        logger.error("Feil ved sending til Kafka", kv("topic", topic), exception)
    }
}
```

For exactly-once-lignende semantikk: `enable.idempotence=true` og `acks=all`. Transaksjoner (`initTransactions()`) kun når du koordinerer produce + consume-commit i samme app.

### Konfigurasjon (NAIS-injiserte env vars)

```kotlin
val props = Properties().apply {
    put("bootstrap.servers", System.getenv("KAFKA_BROKERS"))
    put("security.protocol", "SSL")
    put("ssl.truststore.type", "PKCS12")
    put("ssl.truststore.location", System.getenv("KAFKA_TRUSTSTORE_PATH"))
    put("ssl.truststore.password", System.getenv("KAFKA_CREDSTORE_PASSWORD"))
    put("ssl.keystore.type", "PKCS12")
    put("ssl.keystore.location", System.getenv("KAFKA_KEYSTORE_PATH"))
    put("ssl.keystore.password", System.getenv("KAFKA_CREDSTORE_PASSWORD"))
    // consumer-spesifikt:
    put("group.id", "min-app-v1")
    put("auto.offset.reset", "earliest")
    put("enable.auto.commit", "false")
}
```

## Spring Kafka (Kotlin)

### Consumer med `@KafkaListener`

```kotlin
@KafkaListener(topics = ["\${kafka.topic.name}"], groupId = "\${kafka.consumer.group-id}")
fun consume(record: ConsumerRecord<String, String>) {
    processRecord(record)
}
```

Feilhåndtering konfigureres sentralt via `DefaultErrorHandler` / `DeadLetterPublishingRecoverer` — ikke spre try/catch over alle lyttere.

```kotlin
@Bean
fun errorHandler(kafkaTemplate: KafkaTemplate<String, String>): DefaultErrorHandler {
    val recoverer = DeadLetterPublishingRecoverer(kafkaTemplate) { record, _ ->
        TopicPartition("${record.topic()}.dlq", record.partition())
    }
    return DefaultErrorHandler(recoverer, FixedBackOff(1000L, 3))
}
```

### Producer med `KafkaTemplate`

```kotlin
kafkaTemplate.send(topic, key, value)
    .whenComplete { result, ex ->
        if (ex != null) logger.error("Send feilet", kv("topic", topic), ex)
    }
```

### SSL-konfig (`application.yml`)

```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BROKERS}
    properties:
      security.protocol: SSL
      ssl.truststore.type: PKCS12
      ssl.truststore.location: ${KAFKA_TRUSTSTORE_PATH}
      ssl.truststore.password: ${KAFKA_CREDSTORE_PASSWORD}
      ssl.keystore.type: PKCS12
      ssl.keystore.location: ${KAFKA_KEYSTORE_PATH}
      ssl.keystore.password: ${KAFKA_CREDSTORE_PASSWORD}
    consumer:
      group-id: min-app-v1
      auto-offset-reset: earliest
      enable-auto-commit: false
```

## Testing

- **Plain**: Bruk Testcontainers `KafkaContainer` for integrasjonstester — ikke embedded Kafka (avviklet).
- **Spring**: `@EmbeddedKafka` eller Testcontainers. Foretrekk Testcontainers for realistisk SSL/versjonsoppførsel.
- Unit-test prosesseringslogikk separat fra Kafka-klientene — injiser `ConsumerRecord` direkte.
