# Tokens

Denne referansen er for rask oppslag når du jobber med Aksel v8+.

## Spacing-skala for props (`space-*`)

Bruk disse tokenene i Aksel-props som `gap`, `padding`, `paddingInline`, `paddingBlock`, `margin`, `marginInline` og `marginBlock`.

| Token | Verdi |
|---|---:|
| `space-0` | 0px |
| `space-1` | 1px |
| `space-2` | 2px |
| `space-4` | 4px |
| `space-6` | 6px |
| `space-8` | 8px |
| `space-12` | 12px |
| `space-16` | 16px |
| `space-20` | 20px |
| `space-24` | 24px |
| `space-28` | 28px |
| `space-32` | 32px |
| `space-36` | 36px |
| `space-40` | 40px |
| `space-44` | 44px |
| `space-48` | 48px |
| `space-56` | 56px |
| `space-64` | 64px |
| `space-72` | 72px |
| `space-80` | 80px |
| `space-96` | 96px |
| `space-128` | 128px |

## Legacy migreringstabell (pre-v7 → v7)

> **Merk**: Denne migrasjonsguiden dekker pre-v7 (`--navds-*`) til v7 (`--a-spacing-*` / `--a-border-radius-*`). For v7 → v8, bruk codemods: `npx @navikt/aksel codemod v8-primitive-spacing`

Bruk denne tabellen når du rydder i eldre CSS-variabler. For komponent-props i Aksel-primitives bruker du `space-*` og `radius-*` i prop-API-et, mens CSS-eksemplene lenger ned viser dagens `--a-*`-variabler fra `@navikt/ds-css`.

### Spacing-variabler (legacy)

| Pre-v7 | v7 |
|---|---|
| `--navds-spacing-1` | `--a-spacing-1` |
| `--navds-spacing-2` | `--a-spacing-2` |
| `--navds-spacing-4` | `--a-spacing-4` |
| `--navds-spacing-8` | `--a-spacing-8` |
| `--navds-spacing-12` | `--a-spacing-12` |
| `--navds-spacing-16` | `--a-spacing-16` |
| `--navds-spacing-20` | `--a-spacing-20` |
| `--navds-spacing-24` | `--a-spacing-24` |
| `--navds-spacing-32` | `--a-spacing-32` |

### Radius-variabler (legacy)

| Pre-v7 | v7 |
|---|---|
| `--navds-border-radius-small` | `--a-border-radius-small` |
| `--navds-border-radius-medium` | `--a-border-radius-medium` |
| `--navds-border-radius-large` | `--a-border-radius-large` |
| `--navds-border-radius-xlarge` | `--a-border-radius-xlarge` |
| `--navds-border-radius-full` | `--a-border-radius-full` |

## Border radius

Brukes i `Box borderRadius` og andre APIs som tar radius-tokens.

| Token | Verdi |
|---|---:|
| `radius-0` | 0px |
| `radius-2` | 2px |
| `radius-4` | 4px |
| `radius-8` | 8px |
| `radius-12` | 12px |
| `radius-full` | 9999px |

Merk: `Box borderRadius` bruker verdiene `"0"`, `"2"`, `"4"`, `"8"`, `"12"` og `"full"` i propen, mens CSS-variablene er `--a-radius-*`.

## Brytepunkter

Aksel responsive props bygger på disse breakpointene:

| Token | Verdi | Typisk bruk |
|---|---:|---|
| `xs` | 0px | Mobil som standard |
| `sm` | 480px | Stor mobil / lite nettbrett |
| `md` | 768px | Nettbrett / liten desktop |
| `lg` | 1024px | Desktop |
| `xl` | 1280px | Bred desktop |

Det finnes også `2xl` (1440px) i tokenlaget, men de fleste layout-eksempler i repoet bruker `xs` til `xl`.

## Semantiske tokens

Disse er gode standardvalg for vanlige flater og tekst. For det fulle `--ax-*`-laget og `data-color`-mekanismen, se `references/semantic-tokens.md`.

| Token | Hva det er | Nåværende verdi |
|---|---|---|
| `surface-default` | Standard flate | `rgba(255, 255, 255, 1)` |
| `surface-subtle` | Nedtonet flate | `rgba(242, 243, 245, 1)` |
| `border-subtle` | Lav kontrast / skillelinje | `rgba(7, 26, 54, 0.21)` |
| `border-default` | Standard border | `rgba(2, 20, 49, 0.49)` |
| `text-default` | Standard tekstfarge | `rgba(35, 38, 42, 1)` |
| `text-subtle` | Sekundær tekst | `rgba(1, 11, 24, 0.68)` |

## CSS-variabler

> **Merk**: CSS-variabelnavn avhenger av Aksel-versjon og importmetode. Sjekk faktisk installerte tokens i prosjektet (`@navikt/ds-css` vs `@navikt/ds-tokens`). Eksemplene under bruker `--a-*`-prefikset fra `@navikt/ds-css`, som fortsatt er vanlig i Nav-prosjekter.

Når du må skrive CSS, bruk Aksel sine variabler direkte og hold prop-token og CSS-variabel i samme familie.

### Spacing
- `space-4` i prop-API ↔ `var(--a-space-4)` i CSS
- `space-16` i prop-API ↔ `var(--a-space-16)` i CSS
- `space-24` i prop-API ↔ `var(--a-space-24)` i CSS
- `space-40` i prop-API ↔ `var(--a-space-40)` i CSS
- `space-128` i prop-API ↔ `var(--a-space-128)` i CSS

### Radius
- `radius-2` i prop-API ↔ `var(--a-radius-2)` i CSS
- `radius-4` i prop-API ↔ `var(--a-radius-4)` i CSS
- `radius-8` i prop-API ↔ `var(--a-radius-8)` i CSS
- `radius-12` i prop-API ↔ `var(--a-radius-12)` i CSS
- `radius-full` i prop-API ↔ `var(--a-radius-full)` i CSS

### Surface / border / text
- `var(--a-surface-default)`
- `var(--a-surface-subtle)`
- `var(--a-border-subtle)`
- `var(--a-border-default)`
- `var(--a-text-default)`
- `var(--a-text-subtle)`

### Brytepunkter
- `var(--a-breakpoint-sm)` → `480px`
- `var(--a-breakpoint-md)` → `768px`
- `var(--a-breakpoint-lg)` → `1024px`
- `var(--a-breakpoint-xl)` → `1280px`

## Tommelfingerregler

- I React-props: bruk `space-*` og responsive objekt-props
- I CSS: bruk `var(--a-space-*)`, `var(--a-radius-*)` og semantiske tokens når prosjektet eksporterer dem via `@navikt/ds-css`
- Foretrekk semantiske surface-/text-/border-tokens foran rå farger
