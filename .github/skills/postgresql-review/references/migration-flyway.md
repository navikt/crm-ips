# Migrasjoner og Flyway-mønstre

Migrasjonsmønstre for PostgreSQL i Nav-applikasjoner. Se [SKILL.md](../SKILL.md) for prinsipper og sjekkliste.

## CONCURRENTLY-indekser i produksjon

For `CREATE INDEX CONCURRENTLY` i produksjon, se `flyway-migration`-skillen. Kort oppsummert: bruk egen migrering utenfor transaksjon for å unngå å blokkere skriving.

```sql
-- ✅ Flyway-migrering med CONCURRENTLY (krever egen fil uten transaksjon)
-- V3__create_index_concurrently.sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vedtak_bruker_status
ON vedtak (bruker_id, status);
```

## Nøkkelpunkter for migrasjoner

- Bruk `TIMESTAMPTZ` (ikke `TIMESTAMP`) for alle tidsstempel-kolonner
- Indekser på alle FK-kolonner
- UUID-primærnøkler med `gen_random_uuid()`
- Egne migreringer for `CREATE INDEX CONCURRENTLY`
- Repeterbare migreringer (`R__*.sql`) for views, funksjoner og lignende

## TIMESTAMPTZ

```sql
-- ✅ Alltid TIMESTAMPTZ
CREATE TABLE vedtak (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bruker_id UUID NOT NULL,
    status TEXT NOT NULL,
    opprettet TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    oppdatert TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ❌ Aldri TIMESTAMP uten tidssone
CREATE TABLE vedtak (
    opprettet TIMESTAMP NOT NULL DEFAULT NOW()  -- Mister tidssoneinformasjon
);
```

## FK-indekser

```sql
-- ✅ Indeks på FK-kolonner for å unngå treg cascading og JOIN
CREATE TABLE vedtak (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sak_id UUID NOT NULL REFERENCES sak(id),
    bruker_id UUID NOT NULL
);

CREATE INDEX idx_vedtak_sak_id ON vedtak (sak_id);
CREATE INDEX idx_vedtak_bruker_id ON vedtak (bruker_id);
```

## UUID-primærnøkler

```sql
-- ✅ UUID med gen_random_uuid()
CREATE TABLE hendelse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL,
    data JSONB NOT NULL,
    opprettet TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Repeterbare migreringer

```sql
-- R__vedtak_view.sql — repeterbar migrering for views
CREATE OR REPLACE VIEW aktive_vedtak AS
SELECT id, bruker_id, status, opprettet
FROM vedtak
WHERE status = 'AKTIV';
```
