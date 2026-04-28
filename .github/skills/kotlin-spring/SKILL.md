---
name: kotlin-spring
description: "Spring Boot-applikasjoner i Kotlin — controllers, services, @ProtectedWithClaims, NAIS-miljøvariabler, token-validation, Testcontainers og MockOAuth2Server. Brukes via /kotlin-spring ved Spring Boot-arbeid."
---

# Spring Boot — Nav-spesifikt

Dette er en **konfig- og review-skill**, ikke en scaffolding-skill. For nytt
Spring Boot-prosjekt: bruk Nav sine starter-templates/-repos (f.eks.
`navikt/spring-boot-template`-varianter eller klon et eksisterende
team-repo som utgangspunkt). Denne skillen forutsetter at prosjektet
finnes, og viser hvordan det skal konfigureres for Nais.

## Autentisering

```kotlin
@ProtectedWithClaims(issuer = "azuread", claimMap = ["NAVident=*"])
```
Krever `token-validation-spring`-avhengigheten.

## NAIS-miljøvariabler for database

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

## Testing

- `@SpringBootTest` + Testcontainers for integrasjonstester
- `@MockkBean` (krever `com.ninja-squad:springmockk`)
- MockOAuth2Server for autentiseringstester

## token-support for TokenX og Azure AD

Bruk [`navikt/token-support`](https://github.com/navikt/token-support) —
Spring Boot-modulen heter `token-validation-spring-boot-starter` og gir
auto-konfigurert JWT-validering for både TokenX (borger-flows) og
Azure AD (intern).

```kotlin
// build.gradle.kts
dependencies {
    implementation("no.nav.security:token-validation-spring-boot-starter:5.0.13")
}
```

```yaml
# application.yml — to issuers parallelt
no.nav.security.jwt:
  issuer:
    azuread:
      discoveryurl: ${AZURE_APP_WELL_KNOWN_URL}
      accepted-audience: ${AZURE_APP_CLIENT_ID}
    tokenx:
      discoveryurl: ${TOKEN_X_WELL_KNOWN_URL}
      accepted-audience: ${TOKEN_X_CLIENT_ID}
```

```kotlin
// Intern-endepunkter: Azure AD
@ProtectedWithClaims(issuer = "azuread", claimMap = ["NAVident=*"])
class InternController

// Borger-endepunkter: TokenX med acr-krav
@ProtectedWithClaims(issuer = "tokenx", claimMap = ["acr=Level4"])
class BorgerController
```

Starteren eksponerer også `TokenValidationContextHolder` for å hente
claims (f.eks. `pid` fra TokenX, `NAVident` fra Azure) i service-laget.

## Actuator — Nais health-probes

Nais `liveness`/`readiness` peker på Spring Boot Actuator sine
dedikerte probe-endepunkter, **ikke** custom `/isAlive`/`/isReady`.
Bruk `base-path: /internal` for å holde probes utenfor `accessPolicy`.

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus
      base-path: /internal
  endpoint:
    health:
      probes:
        enabled: true          # aktiverer liveness/readiness-grupper
      show-details: always
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
```

Resulterer i:
- `/internal/health/liveness`
- `/internal/health/readiness`
- `/internal/prometheus`

Nais-manifest:

```yaml
spec:
  liveness:
    path: /internal/health/liveness
  readiness:
    path: /internal/health/readiness
  prometheus:
    enabled: true
    path: /internal/prometheus
```

Merk: Nais kan godt peke på `/isAlive` / `/isReady` hvis du eksponerer
egne endepunkter, men Actuator-probene er standard og reflekterer
Spring sin egen `ApplicationAvailability` (`ReadinessState.REFUSING_TRAFFIC` er intern state og skal ikke toggles manuelt for å håndtere Nais-shutdown).
Plattformkonteksten er felles — se `nais-manifest`-skillen for hvordan NAIS `preStop`-hook fungerer.

## HikariCP — defaults for Nais-containere

Nais-pods er små og korte-lived. Start med liten pool og forutsigbar
lifecycle. Se `postgresql-review` for utdypning.

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 3          # små pods, mange replicas — ikke blås opp connection-count mot Cloud SQL
      minimum-idle: 1
      idle-timeout: 600000          # 10 min
      max-lifetime: 1800000         # 30 min — kortere enn Cloud SQL sin 60 min
      connection-timeout: 30000     # 30 s — fail fast heller enn å henge readiness
      leak-detection-threshold: 60000
```

Hvorfor disse:
- `max-lifetime=30m` < Cloud SQL/PgBouncer-timeouts → unngå "connection was closed unexpectedly".
- `maximum-pool-size=3` × `replicas` holder totalt connection-budsjett under Cloud SQL-grensa.
- `leak-detection-threshold` fanger lekkede connections i dev.

## Structured logging — Nais/Loki-vennlig JSON

Nais samler stdout til Loki; JSON pr. linje gir søkbare felt. Bruk
`logstash-logback-encoder`. Legg `logback-spring.xml` under
`src/main/resources/`:

```xml
<configuration>
  <springProfile name="!local">
    <appender name="stdout_json" class="ch.qos.logback.core.ConsoleAppender">
      <encoder class="net.logstash.logback.encoder.LogstashEncoder">
        <includeMdcKeyName>x_callId</includeMdcKeyName>
        <includeMdcKeyName>x_consumerId</includeMdcKeyName>
        <customFields>{"application":"${spring.application.name}"}</customFields>
      </encoder>
    </appender>
    <root level="INFO">
      <appender-ref ref="stdout_json"/>
    </root>
  </springProfile>

  <springProfile name="local">
    <appender name="stdout" class="ch.qos.logback.core.ConsoleAppender">
      <encoder>
        <pattern>%d{HH:mm:ss} %-5level %logger{36} - %msg%n</pattern>
      </encoder>
    </appender>
    <root level="INFO">
      <appender-ref ref="stdout"/>
    </root>
  </springProfile>
</configuration>
```

```kotlin
// build.gradle.kts
implementation("net.logstash.logback:logstash-logback-encoder:8.0")
```

Propager `x_callId`/`Nav-Call-Id` via MDC i en request-filter slik at
logger fra samme kall kan korreleres på tvers av tjenester i Loki.
Logg **aldri** fødselsnummer, tokens eller andre sensitive felt —
bruk `@Loggable`-patterns / eksplisitt maskering.

## Checklist før deploy

- [ ] `token-validation-spring-boot-starter` konfigurert for riktig issuer(e)
- [ ] Actuator-probes på `/internal/health/{liveness,readiness}` matcher `nais.yaml`
- [ ] HikariCP `max-lifetime < 60m`, `maximum-pool-size` × replicas < DB-budsjett
- [ ] `logback-spring.xml` gir JSON på stdout utenfor `local`-profilen
- [ ] Ingen sensitive felt i logger (fnr, tokens, navn)
