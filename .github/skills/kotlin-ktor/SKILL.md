---
name: kotlin-ktor
description: "Ktor-applikasjoner i Kotlin — routes, plugins, Koin DI, JWT-claims som NAVident, CallLogging/MDC, StatusPages/ApiError, paginering og input-validering. Brukes via /kotlin-ktor ved Ktor-arbeid."
---

# Ktor — Nav-spesifikt

## Autentisering

```kotlin
authenticate("azureAd") {
    get("/api/protected") {
        val principal = call.principal<JWTPrincipal>()
        val navIdent = principal?.getClaim("NAVident", String::class)
    }
}
```

## Avhengighetsinjeksjon

Koin er standard DI-rammeverk for Ktor-repoer i teamet (hvis `io.insert-koin` finnes i avhengighetene).

## Logging

```kotlin
install(CallLogging) {
    mdc("x_request_id") { call.request.header("X-Request-Id") ?: UUID.randomUUID().toString() }
}
```

## Feilhåndtering — StatusPages + ApiError

Team-standard mønster for strukturerte feilresponser: sealed `ApiErrorException`-hierarki + `StatusPages`-plugin som mapper til en enhetlig `ApiError`-payload. Se `references/error-handling.md` for full implementasjon (ErrorType-enum, ApiErrorException-klasser, `installStatusPages()`, `determineApiError()`).

## Paginering og input-validering

Team-standard `PaginatedResponse<T>`-wrapper og route-validering med tidlig-retur på ugyldige parametre. Se `references/paginering-og-validering.md`.

## Graceful shutdown

`embeddedServer { ... }.start(wait = true)` håndterer `SIGTERM` via shutdown-hook automatisk i Ktor.
Trenger ikke manuell readiness-toggling i applikasjonen.
Plattformkonteksten er felles — se `nais-manifest`-skillen for hvordan NAIS `preStop`-hook fungerer.
Anti-mønstre: manuell `readiness=false` og lav `terminationGracePeriodSeconds`.
