---
description: "Universell utforming (UU) — korte WCAG 2.1 AA-regler for Nav-frontend"
applyTo: "**/*.tsx, **/*.jsx"
---

# Tilgjengelighet (UU)

All frontend-kode i Nav skal oppfylle WCAG 2.1 AA. Dette er minimumsreglene som alltid skal ligge i kontekst under koding. Bruk `/accessibility-review` for dyp review, testoppskrifter og større flyter.

## Kjernekrav

- Bruk Aksel-komponenter (`@navikt/ds-react`) der de finnes. De håndterer mye semantikk, fokus, ARIA og kontrast.
- Bruk `/aksel-design` ved nye komponenter, layout-endringer, skjema, spacing eller styling.
- Bruk semantisk HTML: `<main>`, `<nav>`, `<article>`, `<section>`, `<button>` og `<a>` fremfor generiske `<div>`-løsninger.
- Heading-nivåer skal være logiske og uten hopp (`h1` → `h2` → `h3`).
- Alle skjemaelementer skal ha synlig label. Feil skal være koblet til felt og samles i `ErrorSummary` når skjemaet har flere feil.
- Interaktive elementer skal ha tilgjengelig navn, synlig fokus og fungere med tastatur.
- Ikonknapper skal ha tilgjengelig navn via ikonets `title` eller tilsvarende Aksel-mønster.
- Bruk beskrivende lenketekst. Aldri bruk bare "Klikk her".
- Ikke bruk farge alene for å formidle informasjon. Bruk Aksel semantiske farger og tokens.
- Dynamiske tilstander som lasting, feil, tomtilstand og suksess skal være forståelige for skjermleser når de påvirker brukerflyten.

## Skal stoppe eller bruke skill

Bruk `/accessibility-review` før PR/release når oppgaven inneholder:

- nytt skjema, ny modal eller ny kritisk brukerflyt
- større endring i fokusrekkefølge, tastaturnavigasjon eller dynamisk innhold
- custom interaksjon, egne ARIA-roller eller avvik fra Aksel-mønstre
- kjente UU-avvik, manuell audit eller ekstern leveranse

## Grenser

### Alltid
- Bruk Aksel-komponenter for standard felter, knapper, modaler, alerts og navigasjon.
- Test endret flyt med tastatur når UI-et har interaksjon.
- Sjekk heading-hierarki og labels i endrede komponenter.

### Spør først
- Egendefinerte ARIA-roller utover standard HTML-semantikk.
- Custom komponent for noe Aksel dekker.
- Å hoppe over UU-test på ny kritisk brukerflyt.

### Aldri
- `<div onClick>` uten riktig rolle, tastaturstøtte og fokus.
- Ikonknapper uten tilgjengelig navn.
- Aldri fjern fokusindikator uten fullgod erstatning.
