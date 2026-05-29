# SQL-mønstre — Nav-spesifikk tuning

Denne referansen dekker kun Nav-spesifikke innstillinger. Se [SKILL.md](../SKILL.md) for prinsipper og sjekkliste.

Generisk SQL-optimalisering (EXPLAIN ANALYZE, indeksvalg, N+1, SELECT *, JSONB-operatorer, window functions, upsert/ON CONFLICT, advisory locks, range partitioning) er utenfor scope for denne skillen — LLM-en kan dette selv. Se PostgreSQL-dokumentasjonen, eller teamets egen best-practice hvis det finnes.

## Tilkoblingspool — HikariCP i Nais-containere

Nav-default er Cloud SQL via `gcp.sqlInstances` i Nais-manifest. Pool-størrelsen må dimensjoneres etter replicas og Cloud SQL sin `max_connections`, ikke JVM-defaults.

```yaml
# Nais — Cloud SQL-instans
spec:
  gcp:
    sqlInstances:
      - type: POSTGRES_15
        databases:
          - name: myapp-db
            envVarPrefix: DB
```

```kotlin
// HikariCP-defaults for Nav-tjenester
HikariConfig().apply {
    maximumPoolSize = 3          // Start smått — 3–5 for typiske Nav-tjenester
    minimumIdle = 1
    connectionTimeout = 10_000   // Feil raskt hvis Cloud SQL Proxy er nede
    idleTimeout = 300_000        // 5 min — slipp idle connections raskt
    maxLifetime = 1_800_000      // 30 min — under Cloud SQL sin restart-terskel
    transactionIsolation = "TRANSACTION_READ_COMMITTED"
}
```

**Dimensjoneringsformel:** `replicas.max × maximumPoolSize ≤ max_connections`

Cloud SQL har `max_connections = 100` som default. Overvåk bruken ved skalering.

**`maxLifetime = 30 min`:** Cloud SQL Proxy restartes ved vedlikehold/node-bytter. Lavere lifetime bytter ut connections før proxyen tvinger brudd, slik at du unngår "connection reset"-feil i logger.

**Eksplisitt `READ_COMMITTED`:** Matcher PostgreSQL-default og unngår overraskelser ved driver-oppgraderinger.

> **⚠️ Spør først** før `maximumPoolSize > 5` — det er nesten alltid symptom på langsomme spørringer eller manglende indekser, ikke pool-mangel.
