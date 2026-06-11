# Visual Companion — brukerveiledning

Nettleserbasert verktøy for å vise mockups, varianter og visuelle valg
under designutforsking.

## Aksel-korrekthet (VIKTIG)

> **Bruk markup-fasiten — `references/aksel-markup-fasit.md`.** Den inneholder ekte
> `.aksel-*`-markup for hver aktive komponent, generert direkte fra `@navikt/ds-react`
> (`react-dom/server`). Det er ds-reacts *egen* output — garantert korrekt DOM som
> rendrer autentisk Aksel (riktige farger, fasonger, ikoner, struktur) i VC, helt uten
> React eller build. Lim inn snippeten, bytt teksten. Dette er den pålitelige veien til
> Aksel-likt utseende i VC.

Serveren laster **ekte `@navikt/ds-css`** fra prosjektets node_modules, slik at
alle Aksel-tokens (`--ax-*`) og komponentklasser (`.aksel-*`) er definert.

**Forutsetning for korrekt utseende:** `@navikt/ds-css` MÅ være installert
(`[ -d node_modules/@navikt/ds-css ] || pnpm install`). Uten den er `--ax-*`-tokenene
udefinerte, og alt blir fargeløst og «klint» — knapper uten fyll, alerts uten farge.
Ser du det røde «Aksel CSS mangler»-banneret: kjør `pnpm install` før du fortsetter.

**Hvordan Aksel v8 fargelegger (viktig mekanisme):** Fargene ligger i CSS-en, ikke i
runtime-JS. De trigges av attributter: `data-color` (info/success/warning/danger/accent
…) setter token-konteksten, og komponentene leser den (f.eks.
`.aksel-button[data-variant=primary]` bruker `--ax-bg-strong`). Derfor MÅ VC-siden ha
**rot-konteksten** rundt alt innhold, som setter standard fargekontekst = `accent` (så
primærknapper blir blå):

```html
<div class="aksel-theme light" data-background="true" data-color="accent">
  <!-- alt VC-innhold her -->
</div>
```

Frame-malen setter denne automatisk. Komponenter som setter egen `data-color`
(LocalAlert, GlobalAlert, Tag …) overstyrer rot-konteksten — det er meningen
(nøstede fargekontekster).

**Hvorfor frame-malen IKKE må ha en ulagret `* { padding:0 }`-reset (kritisk):**
ds-css v8 legger *all* komponent-CSS i `@layer` (`aksel.components.*`). En ulagret regel
slår en lagret regel **uansett spesifisitet** — så en vanlig `* { margin:0; padding:0 }`
fjernet stilltiende all Aksel-padding (knapper/alerts ble `padding:0`, tekst klint inntil
kanten). Fiks som er på plass i frame-malen: et `@layer vc-base;` deklareres **før**
`ds-css` lastes, og malens generiske element-resets (`*`, `h2`, `h3`) ligger i det laget.
Da vinner Aksel for alt `.aksel-*`-innhold, mens chrome-klasser (`.vc-*`, `.mock-*`) er
ulagret = høyest prioritet. Endrer du frame-malen: behold dette laget — legg aldri til en
ulagret regel som rører `padding`/`margin` på generiske selektorer.

**Arbeidsflyt for HTML-mockups:**
1. Hent komponent-markup fra `references/aksel-markup-fasit.md` (ekte `.aksel-*`).
   Kopier **hele** snippeten — inkludert ikon-SVG-er og wrapper-divs — og bytt kun
   teksten. Forenkler du for hånd (dropper f.eks. `aksel-alert__icon`-SVG-en),
   mister komponenten deler av utseendet sitt.
2. Trenger du spacing/token-detaljer utover fasiten: sjekk `/aksel-design`, og hent
   `https://aksel.nav.no/llm.md` ved første HTML-generering i sesjonen.
3. `.mock-*`-klassene er kun for **ikke-Aksel-stillas** (egne layout-bokser uten en
   tilsvarende komponent) — ikke for å etterligne en Aksel-komponent. Finnes komponenten
   i fasiten, bruk fasiten.

**VC vs. Figma:** VC med ekte markup gir komponent-tro utseende for utforsking av layout,
flyt og hierarki. Pixel-/variant-presisjon og handoff hører fortsatt hjemme i Figma
(katalogen). Regenerer fasiten ved Aksel-oppgradering: `node scripts/generate_markup_fasit.mjs`.

## Når brukes nettleseren vs. chatten?

Avgjør **per spørsmål**, ikke per økt.

**Nettleser** — innholdet ER visuelt:
- Wireframes, mockups, layout-sammenlikninger
- Side-by-side designvarianter
- Komponenteksempler med Aksel-styling
- Visuell hierarki og spacing

**Chat** — innholdet er tekst:
- Kravspørsmål, scope-avklaringer
- Konseptuelle A/B/C-valg beskrevet i ord
- Avveininger og fordeler/ulemper
- Tekniske beslutninger

## Starte serveren

```bash
node .github/skills/prototype/scripts/server.js \
  --project-dir /path/to/project
```

Returnerer JSON med:
- `url` — åpne i nettleser
- `screen_dir` — skriv HTML-filer hit
- `state_dir` — les events herfra

Gi designeren URL umiddelbart etter oppstart.

## Løkken

1. **Skriv HTML-fragment** til en ny fil i `screen_dir`
   - Bruk semantiske filnavn: `konsept-a.html`, `layout-v2.html`
   - Aldri gjenbruk filnavn — serveren viser nyeste fil
   - Skriv content fragments, IKKE fulle HTML-dokumenter
   - Skriv norske tegn (æ/ø/å) direkte som UTF-8 — aldri `\u00f8`-escapes
     (de blir stående som synlig tekst i skissen)

2. **Si til designeren hva som vises:**
   > «Åpne lenken — du ser tre varianter for meldingsfunksjonen. Klikk den
   > du foretrekker.»

3. **Les events på neste runde:**
   - Les `$STATE_DIR/events` for klikk-data (JSON-linjer)
   - Kombiner med designerens tekstrespons

4. **Iterer eller gå videre:**
   - Ny versjon? Skriv ny fil (f.eks. `layout-v2.html`)
   - Ferdig? Gå til Figma-leveranse

5. **Rydde ved temaskifte:** Push et venteinnhold:
   ```html
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Vi jobber videre i chatten …</p>
   </div>
   ```

## Skrive innhold

Skriv bare innholdet — serveren wrapper det i Aksel-temat automatisk.

### Valgalternativer (A/B/C)

```html
<h2>Hvilken tilnærming passer best?</h2>
<p class="subtitle">Klikk på den du liker best</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Checkbox med meldingsfelt</h3>
      <p>Bruker haker av for å legge ved melding til fastlegen</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Alltid synlig meldingsfelt</h3>
      <p>Meldingsfeltet vises alltid, ingen checkbox nødvendig</p>
    </div>
  </div>
</div>
```

### Ekte Aksel-komponenter (anbefalt)

Hent markup fra `references/aksel-markup-fasit.md`. Eksempel — et felt + knapp:

```html
<div class="aksel-form-field aksel-form-field--medium">
  <label class="aksel-form-field__label aksel-label">Melding til fastlegen (valgfritt)</label>
  <textarea class="aksel-textarea__input" rows="4"></textarea>
</div>
<div style="margin-top: var(--ax-space-32)">
  <button data-variant="primary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Godkjenn plan</span>
  </button>
</div>
```

### Grovt wireframe-stillas (`.mockup`) — kun når komponentene IKKE er poenget

`.mockup` + `.mockup-header` er en bevisst grå wireframe-ramme for raske skisser der du
viser *layout/plassering*, ikke komponent-utseende. Vil du vise hvordan noe faktisk ser
ut i Aksel, bruk ekte markup over — ikke `.mockup`.

```html
<div class="mockup">
  <div class="mockup-header">Grovt riss — plassering</div>
  <div class="mockup-body">…</div>
</div>
```

### Side-by-side sammenlikning

```html
<h2>Før og etter</h2>
<div class="split">
  <div class="mockup">
    <div class="mockup-header">Nåtilstand</div>
    <div class="mockup-body">…</div>
  </div>
  <div class="mockup">
    <div class="mockup-header">Nytt konsept</div>
    <div class="mockup-body">…</div>
  </div>
</div>
```

### Flervalg

Legg til `data-multiselect` på container:

```html
<div class="options" data-multiselect>
  <!-- Brukeren kan velge flere -->
</div>
```

## Tilgjengelige CSS-klasser

### Wireframe-snarveier (`.mock-*`) — kun ikke-Aksel-stillas

Disse er for layout-stillas uten en tilsvarende Aksel-komponent. **Er det en
Aksel-komponent, hent ekte markup fra `references/aksel-markup-fasit.md` i stedet** —
tredje kolonne viser hvilken. `.mock-*`-radene merket med en komponent finnes nå i
fasiten og bør erstattes med ekte markup.

| Klasse | Bruk | Bruk ekte i stedet (fasit) |
|---|---|---|
| `.options` + `.option` | A/B/C-valg (klikk for å velge) | — |
| `.cards` + `.card` | Visuelle kort med bilde+tekst | — |
| `.mockup` + `.mockup-header` + `.mockup-body` | Wireframe-container | — |
| `.split` | Side-by-side (to kolonner) | HGrid |
| `.pros-cons` + `.pros` + `.cons` | Fordeler/ulemper | — |
| `.mock-nav` | Mørk navigasjonslinje | — |
| `.mock-sidebar` + `.mock-content` | Sidebar-layout | HGrid |
| `.mock-button` / `.mock-button--secondary` | Knapper (48px) | Button |
| `.mock-input` | Tekstfelt (48px, 18px font) | TextField |
| `.mock-textarea` | Tekstområde (120px min) | Textarea |
| `.mock-alert--info/success/warning/error` | Varsler | LocalAlert |
| `.mock-checkbox` / `.mock-radio` | Avkrysnings-/radioknapper (24px) | Checkbox/Radio |
| `.placeholder` | Plassholder (dashed border) | — |
| `.subtitle` | Undertekst | BodyShort |
| `.section` | Innholdsseksjon (32px gap) | VStack |
| `.label` | Skjemaetikett (16px, bold) | Label |

### Ekte `.aksel-*`-markup vs. `.mock-*`

Bruk **ekte `.aksel-*`-markup fra `references/aksel-markup-fasit.md`** for alt som er en
Aksel-komponent. Det rendrer autentisk fordi Aksel v8 fargelegger via CSS som leser
`data-color`/`data-variant`-attributter — og frame-malens rot-kontekst
(`class="aksel-theme light" data-color="accent"`) gir riktig standardkontekst. Knapper
blir blå, alerts får farge, FormSummary får riktig header — uten React.

`.mock-*`-klassene over er **kun for ikke-Aksel-stillas** (egne wireframe-bokser,
sidebars, splittvisninger uten en tilsvarende komponent). Ikke bruk `.mock-*` for å
representere en Aksel-komponent som finnes i fasiten.

### Spacing i innhold

Bruk `--ax-space-*` tokens for all spacing i HTML-fragmenter:

```html
<div style="margin-bottom: var(--ax-space-24)">…felt…</div>
<div style="margin-top: var(--ax-space-32)">…knapp…</div>
<div style="display: flex; gap: var(--ax-space-8)">…knapper…</div>
```

## Events-format

```jsonl
{"type":"click","choice":"a","text":"Checkbox med meldingsfelt","timestamp":1706000101}
{"type":"click","choice":"b","text":"Alltid synlig","timestamp":1706000108}
```

Siste event er typisk det endelige valget. Klikk-mønsteret kan avsløre nøling.

## Stoppe serveren

Serveren stopper automatisk etter 30 minutter uten aktivitet, eller:

```bash
kill <PID>  # PID-en fra session-id
```

Filer i `.visual-companion/sessions/` bevares for referanse.
Legg til `.visual-companion/` i `.gitignore`.
