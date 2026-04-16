# Feilhåndtering — Ktor StatusPages (komplett implementasjon)

## ApiError og ErrorType

```kotlin
open class ApiError(
    val status: HttpStatusCode,
    val type: ErrorType,
    open val message: String,
    open val path: String? = null,
    val timestamp: Instant = Instant.now(),
)

enum class ErrorType { AUTHENTICATION_ERROR, AUTHORIZATION_ERROR, NOT_FOUND, INTERNAL_SERVER_ERROR, BAD_REQUEST, INVALID_FORMAT, CONFLICT }
```

## ApiErrorException — sealed class

```kotlin
sealed class ApiErrorException(message: String, val type: ErrorType, cause: Throwable?) : RuntimeException(message, cause) {
    abstract fun toApiError(path: String): ApiError
    class ForbiddenException(val errorMessage: String = "Forbidden", cause: Throwable? = null, type: ErrorType = ErrorType.AUTHORIZATION_ERROR) : ApiErrorException(errorMessage, type, cause) {
        override fun toApiError(path: String) = ApiError(HttpStatusCode.Forbidden, type, errorMessage, path)
    }
    class BadRequestException(val errorMessage: String = "Bad Request", cause: Throwable? = null, type: ErrorType = ErrorType.BAD_REQUEST) : ApiErrorException(errorMessage, type, cause) {
        override fun toApiError(path: String) = ApiError(HttpStatusCode.BadRequest, type, errorMessage, path)
    }
    class NotFoundException(val errorMessage: String = "Not Found", cause: Throwable? = null, type: ErrorType = ErrorType.NOT_FOUND) : ApiErrorException(errorMessage, type, cause) {
        override fun toApiError(path: String) = ApiError(HttpStatusCode.NotFound, type, errorMessage, path)
    }
    class InternalServerErrorException(val errorMessage: String = "Internal Server Error", cause: Throwable? = null, type: ErrorType = ErrorType.INTERNAL_SERVER_ERROR) : ApiErrorException(errorMessage, type, cause) {
        override fun toApiError(path: String) = ApiError(HttpStatusCode.InternalServerError, type, errorMessage, path)
    }
    class UnauthorizedException(val errorMessage: String = "Unauthorized", cause: Throwable? = null, type: ErrorType = ErrorType.AUTHORIZATION_ERROR) : ApiErrorException(errorMessage, type, cause) {
        override fun toApiError(path: String) = ApiError(HttpStatusCode.Unauthorized, type, errorMessage, path)
    }
}
```

## installStatusPages()

```kotlin
fun Application.installStatusPages() {
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            logException(call, cause)
            val apiError = determineApiError(cause, call.request.path())
            call.respond(apiError.status, apiError)
        }
    }
}
```

## determineApiError()

```kotlin
fun determineApiError(cause: Throwable, path: String): ApiError = when (cause) {
    is BadRequestException -> cause.toApiError(path)
    is NotFoundException -> cause.toApiError(path)
    is ApiErrorException -> cause.toApiError(path)
    else -> ApiError(HttpStatusCode.InternalServerError, ErrorType.INTERNAL_SERVER_ERROR, cause.message ?: "Internal server error", path)
}

fun BadRequestException.toApiError(path: String?): ApiError {
    val rootCause = this.rootCause()
    return if (rootCause is MissingFieldException) {
        ApiErrorException.BadRequestException("Invalid request body. Missing required field: ${rootCause.fieldName}", type = ErrorType.INVALID_FORMAT).toApiError(path ?: "")
    } else {
        ApiError(status = HttpStatusCode.BadRequest, type = ErrorType.BAD_REQUEST, message = this.message ?: "Bad request", path = path)
    }
}

fun NotFoundException.toApiError(path: String?): ApiError = ApiError(
    status = HttpStatusCode.NotFound, type = ErrorType.NOT_FOUND, message = this.message ?: "Not found", path = path,
)

fun Throwable.rootCause(): Throwable {
    var root: Throwable = this
    while (root.cause != null && root.cause != root) root = root.cause!!
    return root
}
```

## Logging

```kotlin
private fun logException(call: ApplicationCall, cause: Throwable) {
    val callId = call.callId
    val logMessage = "Caught exception, callId=$callId"
    val log = call.application.log
    when (cause) {
        is ApiErrorException -> log.warn(logMessage, cause)
        else -> log.error(logMessage, cause)
    }
}
```

## apiModule() — oppsett

```kotlin
fun Application.apiModule() {
    installCallId()
    installContentNegotiation()
    installStatusPages()
    // ... routing
}
```

## Eksempel feilrespons

```json
{
  "status": 404,
  "type": "NOT_FOUND",
  "message": "Vedtak med id 550e8400 finnes ikke",
  "path": "/api/v1/vedtak/550e8400",
  "timestamp": "2025-01-15T10:30:00Z"
}
```
