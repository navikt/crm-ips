# Micrometer og health endpoints

Denne referansen samler typiske backend-mønstre for Kotlin/Spring i Nav-applikasjoner.

## MeterRegistry-oppsett

Bruk eksisterende registry hvis repoet allerede har Micrometer eller Spring Boot Actuator. I Spring Boot er det mest pragmatisk å la Actuator auto-konfigurere Prometheus-registry i stedet for å opprette `PrometheusMeterRegistry` manuelt.

```kotlin
// Spring Boot Actuator auto-konfigurerer PrometheusMeterRegistry.
// build.gradle.kts:
//   implementation("org.springframework.boot:spring-boot-starter-actuator")
//   runtimeOnly("io.micrometer:micrometer-registry-prometheus")
//
// Bruk MeterRegistry direkte via dependency injection:
import io.micrometer.core.instrument.MeterRegistry
import org.springframework.stereotype.Service

@Service
class MetricsService(
    private val registry: MeterRegistry,
) {
    private val customRequests = registry.counter("custom_requests_total")

    fun recordRequest(): Unit {
        customRequests.increment()
    }
}
```

For Spring Boot er Actuator + Prometheus-endepunkt vanligst:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus
  endpoint:
    health:
      probes:
        enabled: true
      show-details: never
```

Hvis du trenger helseprober på hovedporten, vurder også:

```properties
management.endpoint.health.probes.add-additional-paths=true
```

## Counter

Bruk `Counter` for ting som bare kan øke.

```kotlin
import io.micrometer.core.instrument.Counter
import io.micrometer.core.instrument.MeterRegistry

class JournalService(private val registry: MeterRegistry) {
    private val journalRequests = Counter.builder("journal_requests_total")
        .description("Total journal requests")
        .tag("operation", "create")
        .register(registry)

    fun createJournal(): Unit {
        journalRequests.increment()
    }
}
```

Bruk `rate()` eller `increase()` i Prometheus når du vil se hastighet over tid.

## Timer

Bruk `Timer` for varighet. For percentiler må timeren vanligvis publisere histogram.

```kotlin
import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.Timer

class TaskService(private val registry: MeterRegistry) {
    private val processingTimer = Timer.builder("task_processing_duration_seconds")
        .description("Task processing duration")
        .publishPercentileHistogram()
        .tag("task_type", "sync")
        .register(registry)

    fun processTask(): String {
        val result = processingTimer.recordCallable {
            "done"
        }
        return requireNotNull(result) { "Task processing returned null" }
    }
}
```

Bruk timer for responstid eller behandlingstid, særlig når du trenger p50/p95/p99.

## Gauge

Bruk `Gauge` for en nåverdi, for eksempel køstørrelse eller aktive forbindelser.

```kotlin
import io.micrometer.core.instrument.Gauge
import io.micrometer.core.instrument.MeterRegistry
import java.util.concurrent.atomic.AtomicInteger

class QueueMetrics(registry: MeterRegistry) {
    private val queueSize = AtomicInteger(0)

    init {
        Gauge.builder("task_queue_size", queueSize) { it.get().toDouble() }
            .description("Current task queue size")
            .register(registry)
    }

    fun update(size: Int): Unit {
        queueSize.set(size)
    }
}
```

Bruk gauge når verdien går opp og ned og du trenger nåtilstand.

## DistributionSummary

Bruk `DistributionSummary` når du vil måle fordelinger som ikke er tid.

```kotlin
import io.micrometer.core.instrument.DistributionSummary
import io.micrometer.core.instrument.MeterRegistry

class PayloadMetrics(registry: MeterRegistry) {
    private val payloadSize = DistributionSummary.builder("journal_payload_size_bytes")
        .description("Journal payload size")
        .baseUnit("bytes")
        .publishPercentileHistogram()
        .register(registry)

    fun record(sizeInBytes: Int): Unit {
        payloadSize.record(sizeInBytes.toDouble())
    }
}
```

## Mønstre for business metrics

Velg målinger som viser om løsningen fungerer, ikke bare om JVM-en lever.

**Gode kandidater**
- antall behandlede domenehendelser per type
- andel feil/suksess for viktige flyter
- ventende oppgaver i kø
- behandlingstid per steg eller event-type

```kotlin
class PaymentMetrics(registry: MeterRegistry) {
    private val processed = Counter.builder("payments_processed_total")
        .description("Total payments processed")
        .tag("result", "success")
        .register(registry)

    private val failed = Counter.builder("payments_processed_total")
        .description("Total payments processed")
        .tag("result", "failure")
        .register(registry)

    private val duration = Timer.builder("payment_processing_duration_seconds")
        .description("Payment processing duration")
        .publishPercentileHistogram()
        .tag("flow", "batch")
        .register(registry)

    fun recordSuccess(): Unit = processed.increment()

    fun recordFailure(): Unit = failed.increment()

    fun <T : Any> recordDuration(block: () -> T): T {
        val result = duration.recordCallable(block)
        return requireNotNull(result) { "Timed block returned null" }
    }
}
```

### Rapids & Rivers / Kafka

Mål mottatte events, vellykket behandling, feil, behandlingstid og consumer lag eller køstørrelse. Bruk labels som `event_type`, `result` eller `consumer_group`, men ikke message key eller payload-id.

## Health-endepunkter

Tilpass alltid stiene til manifest og applikasjonsoppsett. I Spring Boot er Actuator ofte nok:

```yaml
management:
  endpoint:
    health:
      probes:
        enabled: true
  endpoints:
    web:
      exposure:
        include: health,prometheus
```

Hvis du lager egne prober, hold liveness enkel og la readiness avhenge av faktiske integrasjoner.

```kotlin
import org.springframework.boot.actuate.health.Health
import org.springframework.boot.actuate.health.HealthIndicator
import org.springframework.stereotype.Component

@Component
class KafkaReadinessIndicator(
    private val kafkaClient: KafkaClient,
) : HealthIndicator {
    override fun health(): Health {
        return if (kafkaClient.isReady()) {
            Health.up().build()
        } else {
            Health.down().withDetail("dependency", "kafka").build()
        }
    }
}
```

**Tommelfingerregler**
- `liveness` svarer på om prosessen bør restartes
- `readiness` svarer på om instansen kan ta trafikk nå
- Ikke legg tung logikk i health checks
- Hold detaljer fri for sensitiv informasjon
