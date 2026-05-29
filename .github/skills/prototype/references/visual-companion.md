# Visual Companion — brukerveiledning

Nettleserbasert verktøy for å vise mockups, varianter og visuelle valg
under designutforsking.

## Aksel-korrekthet (VIKTIG)

Serveren laster **ekte `@navikt/ds-css`** fra prosjektets node_modules.
Alle Aksel-tokens og komponentklasser er tilgjengelige.

**Før du skriver HTML-mockups:**
1. Sjekk `/aksel-design` skill for komponent-API og spacing-regler
2. **ALLTID** hent oppdatert token-referanse fra `https://aksel.nav.no/llm.md` ved første HTML-generering i sesjonen — modellens trente kunnskap om Aksel-tokens er ikke pålitelig
3. Ved senere iterasjoner i samme sesjon: gjenbruk konteksten fra steg 2, med mindre nye tokens trengs
4. Bruk korrekte v8-tokens: `--ax-space-{px}`, `--ax-radius-{px}`, `--ax-bg-*`, `--ax-text-*`

**To nivåer av nøyaktighet:**
- **Ekte Aksel-klasser** (`.aksel-button`, `.aksel-text-field`, etc.): For high-fidelity mockups som skal se pixel-perfect ut
- **`.mock-*` snarveiklasser**: For raske wireframes der layout og konsept er viktigere enn detaljer

**Token-regler (v8):**
- `--ax-space-16` = 16px (token = pixelverdi direkte)
- Button: 48px høyde, `--ax-radius-4`
- TextField: 48px høyde, `--ax-radius-4`, 18px font
- Textarea: min 120px høyde
- Spacing mellom formfelter: `--ax-space-24` (24px)
- Spacing mellom siste felt og knapp: `--ax-space-32` (32px)

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

### Mockup-wireframes

```html
<h2>Slik kan det se ut</h2>

<div class="mockup">
  <div class="mockup-header">Oppfølgingsplan — Godkjenning</div>
  <div class="mockup-body">
    <div class="mock-checkbox">
      <input type="checkbox" checked>
      <div>
        <label>Legg ved en melding til fastlegen</label>
        <div class="description">Meldingen blir synlig for den sykmeldte</div>
      </div>
    </div>
    <div style="margin-top: var(--ax-space-24)">
      <div class="label">Melding til fastlegen (valgfritt)</div>
      <textarea class="mock-textarea" placeholder="Skriv en melding …"></textarea>
    </div>
    <div style="margin-top: var(--ax-space-32)">
      <button class="mock-button">Godkjenn plan</button>
    </div>
  </div>
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

### Wireframe-snarveier (`.mock-*`)

| Klasse | Bruk | Aksel-komponent |
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

### Ekte Aksel-klasser (for high-fidelity)

Serveren laster `@navikt/ds-css` — du kan bruke ekte Aksel HTML-struktur:

```html
<!-- Ekte Aksel Button -->
<button class="aksel-button" data-variant="primary">
  <span class="aksel-button__inner">Send melding</span>
</button>

<!-- Ekte Aksel TextField -->
<div class="aksel-form-field">
  <label class="aksel-form-field__label">Tema</label>
  <input class="aksel-text-field" type="text">
</div>
```

For korrekt HTML-struktur av Aksel-komponenter, hent `aksel.nav.no/llm.md`
(bør allerede være i kontekst fra steg 2 over).

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
