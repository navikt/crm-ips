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
- **Spring Boot**: **Invoker `/kotlin-spring`** for `@ProtectedWithClaims`, NAIS-miljøvariabler, Testcontainers
- **Ktor**: **Invoker `/kotlin-ktor`** for JWT-claims, Koin DI, CallLogging MDC

## Bevar eksisterende struktur

Bevar eksisterende kodestruktur. Endre kun det oppgaven eksplisitt krever. Hvis diffen blir uforholdsmessig stor sammenlignet med oppgavens omfang, stopp og forklar før du fortsetter — ikke refaktorer på siden.
