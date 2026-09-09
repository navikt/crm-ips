---
name: postgresql-review
description: "PostgreSQL-design og -review — HikariCP, connection pools i Nais, indekser, N+1, trege queries, EXPLAIN, Flyway-samspill og delte schemas. Brukes via /postgresql-review ved database-arbeid."
---
# PostgreSQL-gjennomgang

Gjennomgang av PostgreSQL-bruk i Nav-applikasjoner. Dekker Nav-spesifikk tilkoblingspool-dimensjonering (Nais + Cloud SQL), indekser, anti-mønstre, migrasjoner og koordinering av delte schemas.

Se [references/sql-patterns.md](references/sql-patterns.md) for Nav-spesifikk HikariCP- og Cloud-SQL-oppsett. Generisk SQL-tuning (indekser, JSONB, window functions, upsert, partisjonering, N+1) er utenfor scope — bruk LLM-en eller PostgreSQL-dokumentasjonen.

## Database-valgtre i Nav-kontekst

Nav-default er PostgreSQL via `gcp.sqlInstances` i Nais-manifest. Velg teknologi før du skriver kode:

| Behov | Valg | Begrunnelse |
|-------|------|-------------|
| Transaksjonell tilstand, CRUD, saksbehandling | **PostgreSQL** (`gcp.sqlInstances`) | Nav-default. ACID, Flyway-migrasjoner, godt støttet i plattformen. |
| Kun cache eller efemer tilstand | **Ingen DB** (Valkey/Redis eller in-memory) | Unngå Cloud SQL-kostnad og drift hvis data kan gjenskapes. |
| Analyse, rapportering, store aggregeringer | **BigQuery** (dataplattform) | For dataplattform/analytics — ikke for operasjonell drift. |
| Hendelsesflyt mellom tjenester | **Kafka**, ikke DB | Rapids & Rivers / domene-events. DB er ikke integrasjonsmekanisme. |

> **⚠️ Spør først** før du introduserer ny database-type i en tjeneste som ikke har det fra før — det påvirker drift, backup og tilgangsstyring.

## HikariCP for Nais-containere

Pool-størrelsen må være tilpasset Nais-replicas og Cloud SQL-grensene, ikke JVM-defaults.

```kotlin
HikariDataSource().apply {
    maximumPoolSize = 3                              // Start smått! 3–5 for typiske Nav-tjenester
    minimumIdle = 1
    connectionTimeout = 10_000                       // 10s — feil raskt hvis Cloud SQL Proxy er nede
    idleTimeout = 300_000                            // 5 min — slipp idle connections raskt
    maxLifetime = 1_800_000                          // 30 min — under Cloud SQL sin restart-terskel
    transactionIsolation = "TRANSACTION_READ_COMMITTED"
}
```

**Dimensjoneringsformel:**

```
replicas × maximumPoolSize ≤ max_connections
```

Cloud SQL har `max_connections = 100` som default. Med `replicas.max = 4` og `maximumPoolSize = 3` bruker du maks 12 av 100 — trygt. Med `replicas.max = 10` og `maximumPoolSize = 20` bruker du 200 — tjenesten faller over på høy last.

**Begrunnelse for `maxLifetime = 30 min`:** Cloud SQL Proxy kan restarte (vedlikehold, node-bytter). Med lavere lifetime blir connections byttet ut før proxyen tvinger brudd, så du unngår "connection reset"-feil i applikasjonslogger.

**Begrunnelse for `transactionIsolation`:** Eksplisitt `READ_COMMITTED` matcher PostgreSQL-default og unngår overraskelser når driver-defaults endres mellom versjoner.

> **⚠️ Spør først** før du øker `maximumPoolSize` over 5 — det er nesten alltid et symptom på langsomme spørringer eller manglende indekser, ikke pool-mangel.

Se [references/sql-patterns.md](references/sql-patterns.md) for fullstendig HikariCP- og `gcp.sqlInstances`-oppsett.

## Delt database — koordinering av migrasjoner

Flere Nav-team leser ofte fra samme Cloud SQL-instans (felles domene-data). Schema-endringer er da ikke lokale.

**Betinget råd:** Hvis andre team leser fra din database, koordiner schema-endringer med konsument-team FØR merge.

Sjekk før destruktive migrasjoner:

- [ ] Er det andre apper/team med tilgang til denne `gcp.sqlInstances`-instansen?
- [ ] Sjekket du `DROP COLUMN`, `ALTER COLUMN TYPE`, `RENAME` mot konsumentenes spørringer?
- [ ] Har konsumentene deployet kode som tåler det nye skjemaet før du merger?

Bruk **trestegs feltmigrasjon** (expand-migrate-contract) for delte schemas:

1. **Expand:** Legg til ny kolonne/tabell. Ingen konsumenter påvirkes.
2. **Migrate:** Dual-write fra produsent, konsumenter migrerer lesing til ny kolonne én om gangen.
3. **Contract:** Fjern gammel kolonne i separat PR når alle konsumenter er bekreftet migrert (sjekk produksjonstrafikk i 2+ uker).

> **🚫 Aldri** kjør `DROP COLUMN` eller `ALTER COLUMN TYPE` på delt schema uten forhåndsvarsel og bekreftelse fra konsument-team. Én deploy kan ta ned andres tjenester.

Se [references/migration-flyway.md](references/migration-flyway.md) for Flyway-mønstre.

## Generisk SQL-tuning

Indeksstrategier, JSONB-mønstre, upsert/ON CONFLICT, CHECK/UNIQUE-constraints, advisory locks, partisjonering og anti-mønstre (N+1, SELECT *, manglende LIMIT) er generisk PostgreSQL-kunnskap — LLM-en kan dette. Bruk de standard Nav-prinsippene:

- Indekser på FK-kolonner og hyppige WHERE-kolonner
- `@>` + GIN-indeks for JSONB-containment, `->>` for nøkkeloppslag
- `ON CONFLICT` kun mot faktisk `UNIQUE`-constraint
- Batch-henting (`findByIdIn`) i stedet for N+1
- LIMIT på spørringer som kan returnere mange rader
- `CREATE INDEX CONCURRENTLY` i egen migrering utenfor transaksjon — se `flyway-migration`-skillen

Partisjonering og advisory locks: **⚠️ Spør først** før du introduserer i eksisterende løsning.

## Migrasjoner

For Flyway-migrasjoner og SQL-konvensjoner, se `flyway-migration`-skillen. Nøkkelpunkter:
- Bruk `TIMESTAMPTZ` (ikke `TIMESTAMP`) for alle tidsstempel-kolonner
- Indekser på alle FK-kolonner
- UUID-primærnøkler med `gen_random_uuid()`
- Egne migreringer for `CREATE INDEX CONCURRENTLY`
- Repeterbare migreringer (`R__*.sql`) for views, funksjoner og lignende
- Koordiner destruktive endringer med konsument-team for delte schemas

Se [references/migration-flyway.md](references/migration-flyway.md) for migrasjonseksempler.

## Sjekkliste

- [ ] HikariCP: `maximumPoolSize` 3–5, `maxLifetime = 30 min`, `transactionIsolation` satt eksplisitt
- [ ] Dimensjonering: `replicas.max × maximumPoolSize ≤ max_connections`
- [ ] Database-valg bekreftet (PostgreSQL for operasjonell, BigQuery for analyse)
- [ ] Delt schema? Konsument-team varslet før destruktive endringer
- [ ] Indekser på alle FK-kolonner og hyppig brukte WHERE-kolonner
- [ ] `CREATE INDEX CONCURRENTLY` vurdert for nye prod-indekser på store tabeller
- [ ] CHECK/UNIQUE constraints brukt der domeneregler kan håndheves i databasen
- [ ] Ingen N+1-spørringer
- [ ] SELECT bare kolonner som trengs
- [ ] LIMIT på spørringer som kan returnere mange rader
- [ ] Migrasjoner er reversible der mulig
- [ ] Ingen `SELECT *` i produksjonskode

## Grenser

### ✅ Alltid
- HikariCP `maximumPoolSize` 3–5, `maxLifetime = 30 min` for Cloud SQL
- Verifiser `replicas × pool ≤ max_connections` før prod-deploy
- Indekser på FK-kolonner og hyppige WHERE-kolonner
- TIMESTAMPTZ for alle tidsstempel-kolonner
- LIMIT på spørringer som kan returnere mange rader
- Varsle konsument-team ved schema-endringer på delt database

### ⚠️ Spør først
- `maximumPoolSize > 5` (nesten alltid symptom, ikke løsning)
- Ny database-type (BigQuery, Valkey) i tjeneste som ikke har det
- Nye indekser på store tabeller i produksjon — bruk `CONCURRENTLY` ved behov
- Partisjonering eller advisory locks i eksisterende løsninger
- Destruktive migrasjoner (`DROP COLUMN`, `ALTER TYPE`, `RENAME`) på delte schemas

### 🚫 Aldri
- `SELECT *` i produksjonskode
- N+1-spørringer
- `DROP TABLE` i produksjon uten backup-plan
- `TIMESTAMP` uten tidssone (bruk `TIMESTAMPTZ`)
- `DROP COLUMN` på delt schema uten bekreftet konsument-migrasjon
- Bruk database som integrasjonsmekanisme mellom team (bruk Kafka/API)

## Referansefiler

| Fil | Innhold |
|-----|---------|
| [references/sql-patterns.md](references/sql-patterns.md) | Nav-spesifikk HikariCP-tuning og `gcp.sqlInstances`-oppsett |
| [references/migration-flyway.md](references/migration-flyway.md) | Migrasjonsmønstre: TIMESTAMPTZ, FK-indekser, UUID, CONCURRENTLY, repeterbare migreringer, trestegs feltmigrasjon |
