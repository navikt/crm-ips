---
name: prototype
description: "Utforsk designkonsepter visuelt med Aksel-tema i nettleser, og lever som Figma-skisse. Brukes via /prototype når et konsept skal visualiseres."
---

# Prototype — fra konsept til synlig skisse

Utforsk designkonsepter interaktivt i nettleseren, iterer med designeren,
og lever som Figma-skisse med ekte Aksel-komponenter.

## Når brukes denne?

- Designer vil se et konsept visuelt (ikke bare beskrevet)
- Variant-sammenlikning for å velge retning
- Rask validering av layout, hierarki eller flyt
- Situasjonsdesign — vis alle situasjoner brukeren kan møte

### Når gå rett til Figma (hopp over Fase 1)

- Du itererer videre på et eksisterende Figma-design
- Oppgaven er detaljjustering eller finpuss (spacing, farger, typografi)
- Designeren allerede vet hva de vil og trenger Figma-komponenter
- Komponentbygging og produksjonsnære leveranser

Visual Companion er best for **tidlig utforsking** — når retningen er uklar og du vil se 2-3 konsepter raskt. Når retningen er valgt, gå rett til Figma.

## Fase 1: Visuell utforsking (Visual Companion)

Interaktivt nettleserverktøy for å utforske designkonsepter med Aksel-styling.

### Oppstart

### Forutsetninger

- Node.js ≥ 18 (for HTTP-server)
- `@navikt/ds-css` i node_modules (for Aksel-styling; fungerer uten, men viser advarsel)

1. Sørg for at avhengigheter er installert (kreves for Aksel CSS):
   ```bash
   [ -d node_modules/@navikt/ds-css ] || pnpm install
   ```
2. Start serveren:
   ```bash
   node .github/skills/prototype/scripts/server.js --project-dir .
   ```
3. Les startup-JSON fra stdout — den inneholder `url`, `screen_dir`, `state_dir`
4. Gi designeren URL umiddelbart

### Tilby visual companion

Spør designeren én gang, som egen melding:

> «Noe av det vi skal jobbe med er enklere å vise enn å beskrive. Jeg kan
> sette opp en nettleservisning der du ser mockups og klikker for å velge.
> Vil du prøve det?»

Vent på svar. Hvis nei — jobb kun med tekst og Figma.

### Bestemme per spørsmål: nettleser eller chat?

**Nettleser** — innholdet ER visuelt:
- Wireframes, mockups, layout-sammenlikninger
- Side-by-side designvarianter
- Komponenteksempler

**Chat** — innholdet er tekst:
- Kravspørsmål, scope-avklaringer
- Konseptuelle valg beskrevet i ord
- Avveininger

### Skrive innhold

Skriv HTML-fragmenter til `screen_dir`. Serveren wrapper automatisk i
Aksel-temat og laster ekte `@navikt/ds-css` fra prosjektets node_modules.

**VIKTIG — Aksel-korrekthet:**

Før du skriver en HTML-mockup, sjekk alltid `/aksel-design` skill for:
- Riktige komponentnavn og struktur
- Korrekt spacing (token = pixelverdi, f.eks. `--ax-space-16` = 16px)
- Korrekt fargebruk (`--ax-bg-*`, `--ax-text-*`, `--ax-border-*`)

Serveren laster ekte Aksel CSS. Du kan bruke:
1. **Ekte Aksel-klasser** (`.aksel-button`, `.aksel-text-field`, etc.) for high-fidelity
2. **`.mock-*` snarvei-klasser** for raske wireframes (se visual-companion.md)

Tokens i v8: `--ax-space-{px}` (f.eks. `--ax-space-16` = 16px, `--ax-space-24` = 24px).
Radius: `--ax-radius-4`, `--ax-radius-8`, `--ax-radius-12`.

Se `references/visual-companion.md` for alle CSS-klasser og eksempler.

**Regler:**
- Semantiske filnavn: `konsept-a.html`, `layout-v2.html`
- Aldri gjenbruk filnavn
- 2–4 alternativer per skjerm
- Forklar spørsmålet på siden: «Hvilken tilnærming passer best?»
- Skaler fidelitet etter spørsmålet — wireframe for layout, detaljer for detaljer

### Les brukervalg

Etter at designeren har sett skjermen:
1. Les `$STATE_DIR/events` for klikk-data
2. Kombiner med designerens tekstrespons
3. Iterer eller gå videre

### Variant-utforskning

1. Lag 2–3 varianter som valgalternativer på skjermen
2. Spør: «Hvilken variant foretrekker du?» med beskrivende navn
3. Iterer på valgt variant
4. Når konseptet er valgt — gå til Fase 2

### Situasjoner brukeren møter

Vis ulike situasjoner som separate mockups eller som sekvens:
- Normaltilstand (bruker kan handle)
- Venter (lasting/spinner)
- Feil (hva kan bruker gjøre?)
- Tom tilstand (ingenting å vise ennå)
- Ferdig / bekreftelse

## Fase 2: Figma-leveranse

Når konseptet er valgt, bygg en Figma-skisse av den valgte varianten.

### Krav

Figma MCP-verktøy tilgjengelig.

### Flyt

1. `whoami` → finn planKey
2. `create_new_file` → opprett fil, **del URL med designeren**
3. `search_design_system` → finn relevante Aksel-komponenter
4. `use_figma` **preflight** → importer + logg varianter, tekst-node-navn og fonter (se referanse)
5. `use_figma` → bygg skissen med eksakte variant-navn og node-navn fra preflight
6. **`get_screenshot`** → verifiser visuelt (se referanse for sjekkliste)
7. Fiks eventuelle problemer, del oppdatert lenke ved milepæler

**Aldri hopp over preflight** — det forhindrer gjetting og feil-runder. Se `references/figma-prototype.md` for detaljer.

Bygg kun den nye komponenten/endringen — ikke hele siden. Bruk ekte Aksel-komponenter, riktige tokens, og vis varianter som egne frames.

### Komponent-gate

Før du bygger i Figma, søk Aksel-biblioteket:

```
search_design_system(query: "<komponentnavn>", fileKey: "<key>")
```

Finnes komponenten? → Bruk den.
Finnes den ikke? → Bygg custom, men med Aksel-tokens.

### Komponent-instansiering

- **Preflight først**: Importer + logg varianter og tekst-noder i ETT kall
- **Eksakt navnematch** for variant, `defaultVariant` som fallback
- **Tekst**: `findOne` med eksakt name — IKKE `setProperties()` (ustabile nøkler)
- **`layoutSizingHorizontal = "FILL"`** kun etter append til auto-layout
- **Farger**: Slå opp via `search_design_system` — aldri gjett RGB

Se `references/figma-prototype.md` for fullstendige regler og eksempler.

## Valgfritt: Kodeprototype

> «Vil du se dette bygget med ekte Aksel-komponenter i appen?»
> → Deleger til konditor for å bygge på en prototype-branch. Designer-agenten skriver **aldri** kode selv.

## Iterasjon

Vis resultat → designer gir feedback → juster → gjenta til fornøyd.

## UU, opprydding og degradation

- Sjekk kontrast og semantikk i designet. Full WCAG: `/accessibility-review` ved overlevering.
- Etter leveranse: `server.js --project-dir . --cleanup` fjerner `.visual-companion/`.
- Uten Figma MCP → beskriv konseptet, lever som Issue.
- Uten Node.js → Chat + Figma direkte (hopp over Visual Companion).
- Uten Playwright → manuelt skjermbilde fra designer.

## Boundaries

### ✅ Alltid
- Bruk Aksel-komponenter og -tokens
- Returner URL / Figma-lenke for resultater
- Bruk handlingsspråk — aldri verktøynavn
- Spør designer før større endringer
- Del lenker umiddelbart etter opprettelse

### 🚫 Aldri
- Skriv kode i prosjektets kildekode (deleger til konditor)
- Lever prototype som ferdig kode
- Eksponer verktøynavn til designeren
- Feilsøk build-problemer (fall tilbake til neste metode)
- Hopp over UU-sjekk ved leveranse
