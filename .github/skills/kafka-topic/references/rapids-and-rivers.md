# Rapids & Rivers — mønstre

Rapids & Rivers er Navs eventdrevne rammeverk oppå Kafka. Bruk kun hvis teamet allerede står på Rapids — ikke introduser det i repoer som kjører plain Kafka eller Spring Kafka uten eksplisitt avtale.

## Kjernekonsepter

- **Rapid** — det delte Kafka-topicet der alle hendelser flyter (`<team>.rapid.v1`).
- **River** — en konsument som lytter på spesifikke hendelsestyper.
- **Need** — en forespørsel om data/handling, publisert som hendelse.
- **Demand / Require / Reject / Interested in** — validering og filtrering på pakke-nivå.

## Oppsett

```kotlin
import no.nav.helse.rapids_rivers.RapidApplication

fun main() {
    RapidApplication.create(System.getenv()).apply {
        VedtakRiver(this, vedtakRepository)
        UtbetalingRiver(this, utbetalingService)
    }.start()
}
```

NAIS-envvars som Rapids forventer:

```
KAFKA_BROKERS, KAFKA_TRUSTSTORE_PATH, KAFKA_KEYSTORE_PATH, KAFKA_CREDSTORE_PASSWORD
KAFKA_CONSUMER_GROUP_ID=<app-navn>-v1
KAFKA_RAPID_TOPIC=<team>.rapid.v1
```

## En River

```kotlin
class VedtakRiver(
    rapidsConnection: RapidsConnection,
    private val vedtakRepository: VedtakRepository
) : River.PacketListener {

    init {
        River(rapidsConnection).apply {
            validate { it.demandValue("@event_name", "vedtak_fattet") }
            validate { it.requireKey("vedtakId", "fnr", "fom", "tom") }
            validate { it.require("created_at", JsonNode::asLocalDateTime) }
            validate { it.interestedIn("beløp") }
        }.register(this)
    }

    override fun onPacket(packet: JsonMessage, context: MessageContext) {
        val vedtakId = packet["vedtakId"].asText()
        val eventId = packet["@id"].asText()

        if (vedtakRepository.alreadyProcessed(eventId)) return

        vedtakRepository.lagre(
            vedtakId = vedtakId,
            fnr = packet["fnr"].asText(),
            fom = packet["fom"].asLocalDate(),
            tom = packet["tom"].asLocalDate(),
            beløp = packet["beløp"].takeIf { !it.isMissingNode }?.asInt()
        )
        vedtakRepository.markProcessed(eventId)

        context.publish(
            JsonMessage.newMessage(
                mapOf(
                    "@event_name" to "utbetaling_beregnet",
                    "@id" to UUID.randomUUID().toString(),
                    "@created_at" to LocalDateTime.now(),
                    "vedtakId" to vedtakId
                )
            ).toJson()
        )
    }

    override fun onError(problems: MessageProblems, context: MessageContext) {
        logger.error("Valideringsfeil: ${problems.toExtendedReport()}")
    }
}
```

## Validering — velg riktig predikat

| Predikat | Effekt |
|----------|--------|
| `demandValue(key, value)` | Riveren aktiveres kun hvis feltet har eksakt verdi. Typisk for `@event_name`. |
| `demandKey(key)` | Kun hvis feltet finnes. |
| `requireKey(k1, k2, …)` | Alle felter må finnes, ellers `onError`. |
| `require(key, parser)` | Feltet må finnes og kunne parses. |
| `requireAny(k1, k2)` | Minst ett av feltene må finnes. |
| `interestedIn(k1, k2)` | Valgfrie felter — fanges opp hvis tilstede, ingen feil hvis ikke. |
| `rejectKey(key)` / `rejectValue(k, v)` | Skip pakken stille. |

Bruk `demandValue` for event-type-filtrering — det gjør at Riveren ikke produserer `onError` for hver hendelse som ikke er dens. `requireKey` gir `onError` på manglende felt.

## Publisere hendelser

```kotlin
context.publish(
    JsonMessage.newMessage(
        mapOf(
            "@event_name" to "vedtak_fattet",
            "@id" to UUID.randomUUID().toString(),
            "@created_at" to LocalDateTime.now(),
            "@produced_by" to "vedtak-service",
            "vedtakId" to vedtakId,
            "fnr" to fnr
        )
    ).toJson()
)
```

## Testing med TestRapid

```kotlin
class VedtakRiverTest {
    private val testRapid = TestRapid()
    private val repo = InMemoryVedtakRepository()

    init { VedtakRiver(testRapid, repo) }

    @Test
    fun `prosesserer vedtak_fattet`() {
        testRapid.sendTestMessage("""
            {
              "@event_name": "vedtak_fattet",
              "@id": "550e8400-e29b-41d4-a716-446655440000",
              "vedtakId": "v1",
              "fnr": "00000000000",
              "fom": "2026-01-01",
              "tom": "2026-03-31"
            }
        """)

        assertEquals("v1", repo.findById("v1")?.vedtakId)

        val published = testRapid.inspektør.message(0)
        assertEquals("utbetaling_beregnet", published["@event_name"].asText())
    }
}
```

## Feilhåndtering i Rivers

- **Midlertidig feil** (DB nede, nettverk): kast exception → Kafka re-leverer.
- **Permanent feil** (ugyldig payload som likevel passerte validering): log + send til DLQ-producer + return. Ikke kast — det blokkerer strømmen.
- **Valideringsfeil**: `onError` kalles automatisk. Log med `problems.toExtendedReport()`, ikke republiser.

```kotlin
override fun onPacket(packet: JsonMessage, context: MessageContext) {
    try {
        prosesser(packet)
    } catch (e: MidlertidigFeil) {
        throw e  // la Kafka retry
    } catch (e: PermanentFeil) {
        logger.error("Permanent feil, sender til DLQ", e)
        dlqProducer.send(packet.toJson(), e.message)
    }
}
```

## Idempotens

Rapids leverer minst-én-gang. Bruk `@id` som dedup-nøkkel i en event-tabell:

```kotlin
val eventId = packet["@id"].asText()
if (eventStore.alreadyProcessed(eventId)) return
// prosesser
eventStore.markProcessed(eventId)
```

## Vanlige fallgruver

- **Glemme `demandValue` på `@event_name`** → Riveren trigges for hver eneste melding, produserer `onError`-støy.
- **`requireKey` på valgfritt felt** → meldinger uten feltet feiler validering unødvendig. Bruk `interestedIn`.
- **Endre `KAFKA_CONSUMER_GROUP_ID`** → forårsaker reprosessering fra `auto.offset.reset`. Koordiner med driftsansvarlig.
- **Publisere store payloads** → Rapid-topicet er delt mellom mange team. Hold meldinger små, referer tyngre data med ID.
