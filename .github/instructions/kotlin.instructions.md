---
description: "Nav-spesifikke Kotlin-standarder — Gradle Version Catalog, Flyway, logging, metrikker"
applyTo: "**/*.kt"
---

# Kotlin — Nav-spesifikke standarder

- Avhengigheter via Gradle Version Catalog — sjekk `libs.versions.toml`
- Database: Flyway for migreringer, parameteriserte spørringer (aldri string-interpolasjon i SQL)
- Logging: Sjekk eksisterende loggemønster i repoet (`KotlinLogging`, `kv()`-felter, MDC)
- Metrikker: Micrometer / Prometheus
- Autentiseringstesting: MockOAuth2Server

## Framework-spesifikke skills

Bruk riktig skill basert på rammeverket i dette repoet:
- **Spring Boot**: Bruk `kotlin-spring`-skillen for `@ProtectedWithClaims`, NAIS-miljøvariabler, Testcontainers
- **Ktor**: Bruk `kotlin-ktor`-skillen for JWT-claims, Koin DI, CallLogging MDC
