---
name: prototype
description: "Lager raske Figma-prototyper med Aksel-komponenter for Nav-designere. Brukes via /prototype når et konsept skal visualiseres."
---

# Prototype — fra konsept til synlig skisse

Visualiser et designkonsept i Figma med Aksel-komponenter.

## Når brukes denne?

- Designer vil se et konsept visuelt (ikke bare beskrevet)
- Et UI-mønster skal utforskes før det bygges i kode
- Rask validering av layout, hierarki eller flyt
- Variant-sammenlikning for å velge retning
- Situasjonsdesign — vis alle situasjoner brukeren kan møte

## Figma-prototype

Opprett en Figma-fil med Aksel-komponenter direkte via MCP.

**Krav**: Figma MCP-verktøy tilgjengelig.

Flyt: `whoami` → `create_new_file` → **del Figma-URL med designeren** → `search_design_system` → `use_figma` → del oppdatert lenke ved milepæler.

Se `references/figma-prototype.md` for Nav-spesifikke detaljer.

### Variant-utforskning

1. Lag 2–3 varianter som separate frames i samme Figma-fil
2. Del Figma-lenke
3. Spør: "Hvilken variant foretrekker du?" med beskrivende navn per variant (f.eks. A «med stegindikator», B «alt på én side», C «med sidepanel»)
4. Iterer på valgt variant
5. Slett forkastede varianter

### Situasjoner brukeren møter

Et skjema eller en side ser ikke likt ut hele tiden — brukeren møter ulike situasjoner. Spør: "Hvilke situasjoner kan brukeren havne i?"

Vanlige situasjoner å vise:
- Normaltilstand (alt er klart, brukeren kan handle)
- Venter på svar (lasting/spinner)
- Noe gikk galt (feilmelding, hva kan brukeren gjøre?)
- Ingenting å vise ennå (tom liste, første besøk)
- Ikke tilgjengelig (deaktivert, mangler tilgang)
- Ferdig / bekreftelse (handlingen lyktes)

Lag hver situasjon som egen frame i Figma. For hver, noter:
- **Hva skjedde?** Hva førte brukeren hit?
- **Hva skjer videre?** Forsvinner dette av seg selv, eller må brukeren gjøre noe?
- **Hva kan brukeren gjøre?** Knapper, lenker, handlinger
- **Hvor havner oppmerksomheten?** Fokus og eventuell skjermleser-annonsering

### Import av eksisterende side

For å forankre et redesign i nåtilstand. Prioritert rekkefølge:

1. **Lokal app via Playwright** (standard) — Start dev-server, naviger, ta screenshot, last opp til Figma
2. **Figma-lenke** — Hent kontekst via `get_design_context`. Bruk `use_figma` for å jobbe videre i eksisterende fil.
3. **Offentlig URL** — Importer via `generate_figma_design`. NB: dette oppretter en ny Figma-fil. Bruk `use_figma` for å jobbe videre i eksisterende fil.
4. **Manuell fallback** — Be designer om skjermbilde

**Lokal capture (Playwright MCP)**:
1. Les `package.json` + sjekk lockfil (`pnpm-lock.yaml`/`yarn.lock`/`package-lock.json`) → finn package manager og dev-server-kommando
2. **Next.js**: Sjekk `basePath` i `next.config.js`/`next.config.mjs` — URL = `localhost:<port><basePath>/sti`
3. Start server, vent på `ready` / `compiled`
4. Naviger med `browser_navigate`, ta `browser_take_screenshot`
5. Last opp til Figma med `upload_assets` eller bruk som visuell referanse
6. Stopp server når ferdig

Hvis dev-server feiler → informer kort og fall tilbake til neste metode. Ikke feilsøk build-problemer.
Hvis Playwright MCP ikke er tilgjengelig → hopp til metode 2 (Figma-lenke), 3 (offentlig URL) eller 4 (manuell fallback).

### Hybrid kontekst-validering (for endring på eksisterende side)

Når du har importert nåtilstand, bruk denne flyten for å validere nye komponenter i kontekst:

1. Last opp screenshot av eksisterende side som referanse-frame i Figma
2. Utforsk 2–3 isolerte varianter av den nye komponenten som separate frames
3. Plasser valgt variant-frame over referanse-bildet (z-rekkefølge) for visuell kontekst-validering
4. Ta screenshot av resultatet og vis designeren for bekreftelse før videre iterasjon

Denne flyten sikrer at komponenter ser riktige ut i helhet — ikke bare isolert.

## Iterasjon

1. Vis resultat (Figma-lenke)
2. Designer gir feedback
3. Juster og vis på nytt
4. Gjenta til fornøyd

## UU etter designleveranse

Dette er en designmessig forhåndssjekk av struktur, kontrast og innhold. Etter leveranse skal utviklere gjøre live-validering i kode via `/accessibility-review` før release.

## Graceful degradation

**Med Figma MCP**: Full flyt — opprett filer, søk Aksel-komponenter, bygg skisser.
**Uten Figma MCP**: Figma-skissering er utilgjengelig. Tilby konseptbeskrivelse og designoppgave (Issue).

## Boundaries

### ✅ Alltid
- Bruk Aksel-komponenter (aldri custom styling for standard UI)
- Returner Figma-lenke for nye design
- Bruk handlingsspråk — aldri verktøynavn
- Spør designer før større endringer

### 🚫 Aldri
- Bygg lokale prototyper (HTML, npx serve, temp-filer)
- Lagre filer i prosjektets kildekode
- Lever prototype som ferdig kode
- Eksponer verktøynavn til designeren
- Feilsøk build-problemer i dev-server (fall tilbake til neste metode)
