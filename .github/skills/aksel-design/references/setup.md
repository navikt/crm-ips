# Oppsett og installasjon

## Pakker

Aksel består av flere npm-pakker:

```bash
# React-komponenter og CSS
pnpm add @navikt/ds-react @navikt/ds-css

# Ikoner (egen pakke)
pnpm add @navikt/aksel-icons

# Tokens (kun nødvendig hvis du ikke bruker @navikt/ds-css,
# eller trenger tokens i JS/SCSS/Less-format)
pnpm add @navikt/ds-tokens
```

## CSS-import

Legg til i roten av appen (f.eks. `_app.tsx`, `layout.tsx`, `main.tsx` eller prosjektets globale stilark):

```css
@import "@navikt/ds-css";
```

## Token-importstier

Når du trenger tokens utenfor CSS-laget:

- CSS: `@navikt/ds-tokens` eller `@navikt/ds-tokens/css`
- JavaScript: `@navikt/ds-tokens/js`
- SCSS: `@navikt/ds-tokens/scss`
- Less: `@navikt/ds-tokens/less`

## Bruk av ikoner

```tsx
import { StarIcon } from "@navikt/aksel-icons";

export function Favorite(): JSX.Element {
  return <StarIcon title="Legg til favoritt" />;
}
```

Bruk `title` på ikon-komponenten **eller** `aria-label` på knappen — ikke begge samtidig.

## v8-codemods (migrering)

Når du oppgraderer fra eldre Aksel-versjoner til v8 finnes det automatiske codemods:

```bash
# Oppdater Aksel-primitives (Box/VStack/HStack/HGrid med spacing-props)
npx @navikt/aksel codemod v8-primitive-spacing

# Oppdater tokens i CSS/SCSS/Less og Tailwind-config
npx @navikt/aksel codemod v8-token-spacing
```

Etter codemod, kjør repoets sjekker (f.eks. `mise check`, `pnpm lint`, `pnpm test`) for å fange regresjoner.

## Finn Tailwind-konflikter

Aksel-komponenter skal ikke blandes med Tailwind padding/margin. Søk etter konflikter før refaktorering:

```bash
# ripgrep
rg -g '*.tsx' -g '*.jsx' 'className="[^"]*\b(p|m|px|py|pt|pb|pl|pr|mx|my|mt|mb|ml|mr)-[0-9]'
```

Erstatt med Aksel-props (`padding`, `paddingBlock`, `paddingInline`, `gap`, `margin*`) på `Box`/`VStack`/`HStack`/`HGrid`.

## Versjonsmerknad

- **v8.x** bruker pikselbaserte token-navn: `space-16` (16px), `space-24` (24px) osv.
- **v7.x** brukte CSS-variabler som `--a-spacing-4` (16px) og prop-navn som `spacing-4`.
- **Pre-v7** brukte `--navds-spacing-*`.

Se `references/tokens.md` for migreringstabeller.
