---
name: repo-sync
description: "Henter siste endringer fra Git — fetch, pull og branch-sjekk for oppdatert kodebase. Brukes via /repo-sync ved oppstart eller når koden kan være utdatert."
---

# Repo Sync — hold kodebasen oppdatert

Sørger for at den lokale kodebasen er oppdatert med siste versjon fra Git. Laget for å være trygt å kjøre automatisk — ingen destruktive operasjoner.

## Når brukes denne?

- Ved oppstart av en ny samtale i et repo
- Når agenten mistenker at koden er utdatert
- Designere og andre ikke-tekniske brukere som ikke kjenner Git

## Bruk

Kjør scriptet:

```bash
bash .github/skills/repo-sync/scripts/sync.sh
```

Scriptet ligger i skill-mappen. Agenten må resolve stien basert på repo-roten.

Scriptet returnerer JSON med `status`, `message` og `count`:

| Status | Betydning | Handling |
|---|---|---|
| `updated` | Hentet N nye endringer | Informer: «Kodebasen er oppdatert — hentet N nye endringer. ✅» |
| `current` | Allerede oppdatert | Si ingenting, gå videre |
| `skipped` | Ikke på hovedbranch | Si ingenting, gå videre |
| `error` | Noe gikk galt | Gi en kort, ikke-teknisk forklaring |

Ved `error`: unngå git-jargong for ikke-tekniske brukere. Eksempel: «Jeg klarte ikke å hente siste versjon akkurat nå, men vi kan jobbe videre med det vi har.»

## Hva scriptet gjør

1. Sjekker at vi er i et git-repo
2. Finner hovedbranch (origin/HEAD → main → master)
3. Sjekker at vi er på hovedbranch — hvis ikke, hopper over stille
4. Kjører `git fetch`
5. Sjekker antall nye commits
6. Kjører `git pull --ff-only` kun ved endringer

## Boundaries

### ✅ Alltid
- Bruk scriptet — ikke kjør git-kommandoer direkte
- Informer om oppdateringer
- Stopp ved feil — aldri force

### 🚫 Aldri
- `git reset --hard`
- `git push`
- `git rebase`
- `git checkout` (aldri bytt branch)
- Slette branches
- Installere dependencies (npm install etc.)
