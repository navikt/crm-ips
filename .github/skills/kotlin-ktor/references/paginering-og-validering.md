# Kodeeksempler — Paginering og Input-validering

## Paginering

### PaginatedResponse

```kotlin
@Serializable
data class PaginatedResponse<T>(
    val innhold: List<T>,
    val side: Int,
    val antallPerSide: Int,
    val totaltAntall: Long,
    val totaltAntallSider: Int,
)

get("/api/v1/vedtak") {
    val side = call.queryParameters["side"]?.toIntOrNull() ?: 0
    val antall = call.queryParameters["antall"]?.toIntOrNull() ?: 20
    if (antall > 100) throw BadRequestException("Maks 100 per side")
    val result = vedtakService.findAll(offset = side * antall, limit = antall)
    call.respond(result)
}
```

### Eksempel respons

```json
{
  "innhold": [...],
  "side": 0,
  "antallPerSide": 20,
  "totaltAntall": 142,
  "totaltAntallSider": 8
}
```

## Input-validering

### Eksempel route med validering

```kotlin
@Serializable
data class CreateVedtakRequest(val brukerId: String, val beskrivelse: String? = null, val type: VedtakType)

post("/api/v1/vedtak") {
    val request = call.receive<CreateVedtakRequest>()
    if (request.brukerId.isBlank()) throw ApiErrorException.BadRequestException("brukerId kan ikke være tom")
    request.beskrivelse?.let { if (it.length > 500) throw ApiErrorException.BadRequestException("beskrivelse maks 500 tegn") }
    val vedtak = vedtakService.create(request)
    call.response.header("Location", "/api/v1/vedtak/${vedtak.id}")
    call.respond(HttpStatusCode.Created, vedtak.toDto())
}
```
