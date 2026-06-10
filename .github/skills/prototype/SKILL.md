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

### Forutsetninger

- Node.js ≥ 18 (for HTTP-server)
- `@navikt/ds-css` i node_modules — KREVES for ekte farger; uten den blir alt fargeløst/klint

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

Bruk **ekte `.aksel-*`-markup fra `references/aksel-markup-fasit.md`** — generert fra
`@navikt/ds-react` (ds-reacts egen DOM), rendrer autentisk Aksel via ds-css. Frame-malen
setter rot-konteksten (`data-color="accent"`) som gjør primærknapper blå. `.mock-*` er kun
for ikke-Aksel-stillas. Fargene ligger i CSS-en (`data-color`/`data-variant`), ikke i JS.

Tokens i v8: `--ax-space-{px}` (f.eks. `--ax-space-16` = 16px, `--ax-space-24` = 24px).
Radius: `--ax-radius-4`, `--ax-radius-8`, `--ax-radius-12`.

Se `references/visual-companion.md` for alle CSS-klasser og eksempler.

**Regler:**
- Semantiske filnavn: `konsept-a.html`, `layout-v2.html`
- Aldri gjenbruk filnavn
- 2–4 alternativer per skjerm
- Forklar spørsmålet på siden: «Hvilken tilnærming passer best?»
- Skaler fidelitet etter spørsmålet — wireframe for layout, detaljer for detaljer
- **Norske tegn (æ/ø/å) direkte som UTF-8** — aldri `\u00f8`-escapes; serveren skriver
  ordrett, så escapen blir synlig tekst i skissen («m\u00f8te» i stedet for «møte»)

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

Vis ulike situasjoner som separate mockups eller sekvens: normal, venter (lasting), feil, tom tilstand, og ferdig/bekreftelse.

## Fase 2: Figma-leveranse

Når konseptet er valgt, bygg en Figma-skisse av den valgte varianten.

### Krav

Figma MCP-verktøy tilgjengelig.

### Flyt

1. `whoami` → finn planKey
2. `create_new_file` → opprett fil, **del URL med designeren**
3. `search_design_system` → finn relevante Aksel-komponenter
4. `use_figma` **preflight** → importer + logg varianter, default-variant, tekst-node-navn og fonter (se referanse)
5. `use_figma` → bygg skissen **inkrementelt, én seksjon per kall** med eksakte variant-navn og node-navn fra preflight
6. **`get_screenshot`** → parity-gate: sammenlign mot Visual Companion-fasiten (se referanse for sjekkliste)
7. Fiks eventuelle problemer, del oppdatert lenke ved milepæler

**Sjekk katalogen først — den er fasiten.** Alle 45 aktive Aksel-komponenter har key, akser, defaults, tekst-noder og feller ferdig uttrukket i `references/aksel-figma-katalog.json` (maskinlesbar kilde) og `.md` (lesbar). For layouten rundt komponentene (luft, farger, kanter, typografi) bruk `references/aksel-figma-tokens.md`. Drift-validert — hopp over preflight for det katalogen dekker. Detaljer i `references/figma-prototype.md`.

Bygg kun den nye komponenten/endringen — ikke hele siden. Bruk ekte Aksel-komponenter, riktige tokens, og vis varianter som egne frames.

### Komponent-gate

Før du bygger i Figma, søk Aksel-biblioteket:

```
search_design_system(query: "<komponentnavn>", fileKey: "<key>")
```

Finnes komponenten? → Bruk den.
Finnes den ikke? → Bygg custom, men med Aksel-tokens.

### Komponent-instansiering

- **Preflight først**: importer + logg varianter, default og tekst-noder i ETT kall
- **Bygg inkrementelt**: ett `use_figma`-kall per seksjon (atomisk — én feil ruller tilbake hele kallet)
- **`defaultVariant` er ofte feil**: GlobalAlert/LocalAlert=Error, Tag=Neutral, Checkbox=unchecked. Antall barn (RadioGroup/Accordion/Tabs) er også en variant-akse — velg bevisst
- **Tekst** via `findOne`/`findAllWithCriteria` med eksakt name (ikke `setProperties()` for tekst); les font med `loadFontAsync(node.fontName)` — Aksel = `Source Sans 3`
- **Komposisjon**: søknadssteg→`FormProgress`; bygg `Table` fra `Table cell`; skjul Slot-placeholdere; `layoutSizingHorizontal="FILL"` kun etter append; farger via `search_design_system` — aldri gjett RGB

Se `references/figma-prototype.md` for fullstendige regler og eksempler.

## Valgfritt: Kodeprototype (opt-in)

Fra skisse til **ekte, klikkbar kode** med `@navikt/ds-react` og mockdata — kjørbar lokalt og i demo. Tilbys etter et Visual Companion- og/eller Figma-resultat når retningen er valgt.

Designer-agenten skriver **aldri** kode selv. Spør «Skal jeg få bygget dette som en klikkbar prototype med mockdata?» og deleger til **konditor** med disse rammene:
- Ekte Aksel-komponenter + alle tilstander (normal/lasting/feil/tom/ferdig)
- **Kun mockdata** (fixtures/MSW) — ingen ekte API-er, PII, secrets eller accessPolicy
- Egen `prototype/*`-branch, aldri `main`/prod, merket «prototype – ikke for prod»
- Kjørbar lokalt + efemert demo-miljø; utviklere tar over for ekte data og UU-live-review før prod

Etter bygging: del demo-lenke/branch. Tilby Issue så utviklerne tar prototypen videre.

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
- Lever kodeprototype til `main`/prod eller mot ekte data — kun `prototype/*`-branch med mockdata
- Eksponer verktøynavn til designeren
- Feilsøk build-problemer (fall tilbake til neste metode)
- Hopp over UU-sjekk ved leveranse
