---
name: flyway-migration
description: Opprett en Flyway-databasemigrering etter riktige konvensjoner
---

# Flyway-migrering

Opprett en ny Flyway-migreringsfil etter teamets konvensjoner.

## Steg

1. Finn migreringsmappen ved å søke etter eksisterende `V*__*.sql`-filer under `src/main/resources/db/`, eller sjekk `flyway.locations` i applikasjonskonfigurasjonen. List deretter eksisterende migreringer for å finne neste versjonsnummer.
2. Les den nyeste migreringen for å forstå navngivings- og stilkonvensjonene
3. Opprett den nye migreringsfilen med riktig navn: `V{next}__{description}.sql`

## Konvensjoner

- Foretrekk fail-fast i versjonerte migreringer — bruk `IF NOT EXISTS` / `IF EXISTS` bare når du bevisst vil gjøre migreringen idempotent
- Bruk `TIMESTAMPTZ` for tidsstempler (med `DEFAULT NOW()`)
- Bruk `UUID` med `gen_random_uuid()` for primærnøkler der det passer
- Bruk `TEXT` i stedet for `VARCHAR`
- Legg til indekser for kolonner det søkes ofte på
- Én fokusert endring per migrering

## Mal

```sql
-- V{number}__{description}.sql
CREATE TABLE table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_table_name_field ON table_name(field);
```

## CONCURRENTLY-indekser

Bruk egen migrering når du må opprette indeks på stor tabell i produksjon uten å blokkere skriving.

```sql
-- V5__add_index_concurrently.sql
-- NB: CREATE INDEX CONCURRENTLY kan ikke kjøre i transaksjon
-- Kjør denne migreringen alene og verifiser Flyway-oppsettet først
-- migration:executeInTransaction=false
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vedtak_bruker ON vedtak (bruker_id);
```

Hvis prosjektet bruker rammeverk-konfig for Flyway, verifiser tilsvarende innstilling der i stedet for å gjette på globale properties.

## Repeterbare migreringer

`R__*.sql`-filer kjøres på nytt hver gang innholdet endres.

Bruk dem for:
- views
- funksjoner
- triggers
- seed data

Hold versjonerte `V__`-migreringer uendrede, og bruk repeterbare migreringer for objekter som naturlig regenereres.

Eksempel på `updated_at`-trigger i en repeterbar migrering:

```sql
-- R__update_updated_at.sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
```

## Testcontainers-eksempel

Bruk Testcontainers for å verifisere at migrasjoner faktisk kan kjøres mot en ekte PostgreSQL-instans i tester.

```kotlin
@Testcontainers
class DatabaseTest {
    companion object {
        @Container
        val postgres = PostgreSQLContainer("postgres:15-alpine")
            .withDatabaseName("testdb")
    }

    @Test
    fun `migrasjoner kjører uten feil`() {
        Flyway.configure()
            .dataSource(postgres.jdbcUrl, postgres.username, postgres.password)
            .load()
            .migrate()
    }
}
```

Dette gir rask tilbakemelding på at migrasjonsrekkefølge, SQL-syntaks og Flyway-konfig faktisk fungerer sammen.
