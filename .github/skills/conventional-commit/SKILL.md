---
name: conventional-commit
description: Generer conventional commit-meldinger med Nav-relevante scopes og breaking change-format
---

# Conventional commit

Generer commit-meldinger etter Conventional Commits-spesifikasjonen, tilpasset Nav-prosjekter.

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Typer

| Type | Brukes når |
|---|---|
| `feat` | Ny funksjonalitet |
| `fix` | Bugfiks |
| `docs` | Kun dokumentasjonsendringer |
| `style` | Formatering, semikolon osv. (ingen kodeendring) |
| `refactor` | Kode som verken fikser en bug eller legger til en feature |
| `perf` | Ytelsesendringer |
| `test` | Legge til eller fikse tester |
| `build` | Endringer i build-system eller avhengigheter |
| `ci` | Endringer i CI-konfigurasjon |
| `chore` | Andre endringer som ikke påvirker kode |

## Nav-relevante scopes

```
feat(vedtak): legg til støtte for klagevedtak
fix(auth): fiks token-validering for TokenX
docs(api): oppdater OpenAPI-spec for vedtak-endepunktet
refactor(repository): bruk CTE for bedre lesbarhet
test(controller): legg til integrasjonstest med MockOAuth2Server
build(deps): oppgrader Spring Boot til 3.4.1
ci(deploy): legg til prod-deploy steg
perf(db): legg til indeks på bruker_id
chore(nais): oppdater ressursgrenser
```

## Breaking changes

```
feat(api)!: endre responsformat for vedtak-endepunktet

BREAKING CHANGE: Feltet `vedtakDato` er endret til `opprettetDato`.
Konsumenter må oppdatere sin parsing.
```

## Regler

- Første linje: maks 72 tegn
- Bruk imperativ: "add", ikke "added" eller "adds"
- Ikke avslutt med punktum
- Bruk norsk eller engelsk konsekvent i prosjektet
- Referer til GitHub-issue i footer: `Closes #123`
- Ta alltid med `Co-authored-by`-trailer for Copilot

## Arbeidsflyt

### 1. Analyser staged changes

```bash
git diff --cached --stat        # Overview of changed files
git diff --cached               # Detailed diff
```

### 2. Finn type og scope

Basert på diff-en:
1. Identifiser **type** (feat/fix/refactor/etc.)
2. Identifiser **scope** (hvilket modul- eller domeneområde)
3. Skriv en kort og presis beskrivelse

### 3. Skriv commit-melding

```bash
git commit -m "type(scope): kort beskrivelse" \
  -m "Utdypende forklaring hvis nødvendig." \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

### 4. Flere logiske endringer

Hvis staged changes inneholder flere logiske endringer:
1. Foreslå å dele dem opp i egne commits
2. Bruk `git add -p` for å stage deler av endringene
3. Lag én commit per logisk endring

## Sikkerhetsprotokoll

Før du committer, verifiser at staged changes **IKKE** inneholder:
- Tokens, API keys eller credentials
- Passord eller secrets (også i kommentarer)
- PII (fødselsnumre, e-postadresser, navn i testdata)
- `.env`-filer med sensitive verdier

Hvis du oppdager sensitive data: **STOPP** og varsle brukeren.

## Eksempler

```bash
# Enkel feature
git commit -m "feat(søknad): legg til validering av fødselsnummer" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Bugfiks med referanse
git commit -m "fix(auth): håndter utløpt refresh-token" \
  -m "Refresh-tokenet ble ikke fornyet ved utløp, som førte til
at brukere ble logget ut uten varsel." \
  -m "Fixes #456

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Oppdatering av avhengighet
git commit -m "build(deps): oppgrader postgresql driver til 42.7.4" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# Breaking change
git commit -m "feat(api)!: fjern deprecated /api/v1/vedtak endepunkt" \
  -m "BREAKING CHANGE: /api/v1/vedtak er fjernet. Bruk /api/v2/vedtak.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
