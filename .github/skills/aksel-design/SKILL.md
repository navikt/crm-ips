---
name: aksel-design
description: Aksel designsystem — spacing-tokens, layout-komponenter, responsivt design og komponentmønstre for Nav-frontend
---

# Aksel Design System

Bruk denne skillen når du jobber i Nav-frontend med `@navikt/ds-react`, layout i Aksel-primitives og responsiv UI. Hovedregler ligger her; detaljer ligger i `references/`.

## Kort intro

- Komponentbibliotek: `@navikt/ds-react`
- Ikoner: `@navikt/aksel-icons`
- Tokens: `@navikt/ds-tokens`
- Dokumentasjon: `aksel.nav.no`
- Verifiser alltid komponent-API og props før implementasjon

## Installasjon og oppsett

```bash
pnpm add @navikt/ds-react @navikt/ds-css @navikt/aksel-icons
```

Importer CSS i roten av appen (f.eks. `_app.tsx`, `layout.tsx` eller `main.tsx`):

```css
@import "@navikt/ds-css";
```

For detaljert oppsett, token-importstier og v8-codemods, se `references/setup.md`.

## Spacing-regler (KRITISK)

**Foretrekk Aksel spacing-tokens. Unngå Tailwind padding/margin når Aksel-tokens er tilgjengelige.**

- Bruk `space-*` i `Box`, `VStack`, `HStack`, `HGrid` og andre Aksel-primitives
- Foretrekk `gap`, `paddingBlock`, `paddingInline`, `marginBlock` og `marginInline`
- Bruk Tailwind spacing bare når Aksel ikke dekker behovet eller du bevisst viderefører et etablert mønster

```tsx
import { Box, VStack } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <Box paddingBlock={{ xs: "space-16", md: "space-24" }} paddingInline="space-16">
      <VStack gap="space-12">
        <div>Header</div>
        <div>Content</div>
      </VStack>
    </Box>
  );
}
```

## Layout-komponenter

### Box

```tsx
import { BodyShort, Box } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <Box background="default" borderColor="neutral-subtle" borderRadius="12" borderWidth="1" padding="space-16">
      <BodyShort>Card content</BodyShort>
    </Box>
  );
}
```

### VStack

```tsx
import { BodyShort, Heading, VStack } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <VStack gap="space-12">
      <Heading size="medium" level="2">Section title</Heading>
      <BodyShort>Supporting text</BodyShort>
    </VStack>
  );
}
```

### HStack

```tsx
import { Button, HStack } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <HStack gap="space-8" justify="end">
      <Button variant="secondary">Cancel</Button>
      <Button>Save</Button>
    </HStack>
  );
}
```

### HGrid

```tsx
import { Box, HGrid } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <HGrid columns={{ xs: 1, md: 2, xl: 3 }} gap="space-16">
      <Box padding="space-16" background="neutral-soft">A</Box>
      <Box padding="space-16" background="neutral-soft">B</Box>
      <Box padding="space-16" background="neutral-soft">C</Box>
    </HGrid>
  );
}
```

## Responsivt design

- Jobb mobile-first med `xs`, `sm`, `md`, `lg`, `xl`
- Foretrekk responsive props fremfor egne media queries
- Bruk `Show` / `Hide` når innhold faktisk skal skiftes per breakpoint

```tsx
import { Box, HGrid, Show } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <HGrid columns={{ xs: 1, md: "2fr 1fr" }} gap={{ xs: "space-12", md: "space-24" }}>
      <Box padding="space-16" background="default">Main content</Box>
      <Show above="md">
        <Box padding="space-16" background="neutral-soft">Sidebar</Box>
      </Show>
    </HGrid>
  );
}
```

## Typografi

```tsx
import { BodyLong, BodyShort, Heading, VStack } from "@navikt/ds-react";

export function Example(): JSX.Element {
  return (
    <VStack gap="space-8">
      <Heading size="large" level="2">Application status</Heading>
      <BodyShort>Short summary for scanning.</BodyShort>
      <BodyLong>Longer explanatory text with context and next steps.</BodyLong>
    </VStack>
  );
}
```

## Boundaries

### ✅ Alltid
- Bruk Aksel-komponenter for standard UI-elementer
- Bruk `space-*`-tokens i layout-props
- Bruk responsive props når komponenten støtter det
- Håndter lasting, feil, tomtilstand og suksess eksplisitt
- Sjekk eksisterende UI-mønstre i repoet først

### ⚠️ Spør først
- Nye UI-avhengigheter utenfor Aksel
- Store avvik fra etablerte layout-mønstre
- Tailwind utilities som overlapper tydelig med Aksel primitives
- Egen CSS for noe Aksel allerede dekker

### 🚫 Aldri
- Hardkod spacing, radius, farger eller typografi når Aksel-tokens finnes
- Bygg standardfelter, knapper eller varsler med rå HTML hvis Aksel tilbyr komponenten
- Bruk responsive hacks når responsive props dekker behovet

For installasjon, CSS-oppsett og v8-codemods, se `references/setup.md`.
For komplett token-oversikt, se `references/tokens.md`.
For semantiske `--ax-*`-tokens og `data-color`, se `references/semantic-tokens.md`.
For komponent-API, se `references/components.md`.
For layout-mønstre (inkl. Next.js), se `references/patterns.md`.
