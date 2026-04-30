---
name: aksel-design
description: "Aksel-designsystem og Nav-frontendmønstre — komponentvalg, layout, spacing/tokens, skjema og responsiv UI med @navikt/ds-react. Brukes via /aksel-design ved nye komponenter, layout-endringer eller styling-valg, og før rå HTML/CSS eller custom styling vurderes."
---

# Aksel Design System

Bruk denne skillen når du jobber i Nav-frontend med `@navikt/ds-react`, layout i Aksel-primitives og responsiv UI. Hovedregler ligger her; detaljer ligger i `references/`.

## Kort intro

- Komponentbibliotek: `@navikt/ds-react`
- Ikoner: `@navikt/aksel-icons`
- Tokens: `@navikt/ds-tokens`
- Dokumentasjon: `aksel.nav.no`
- Verifiser alltid komponent-API og props før implementasjon

## Hent oppdatert dokumentasjon

Aksel-dokumentasjon er tilgjengelig som LLM-optimaliserte .md-filer. Hent alltid dokumentasjon fra kilden fremfor å anta API fra treningsdata:

```
https://aksel.nav.no/llm.md
```

Denne filen er et indeks over alle Aksel-docs. Hent individuelle sider ved behov.

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

## Kritiske v8-regler

Disse overstyrer treningsdata. Verifiser alltid mot `aksel.nav.no/llm.md`.

- **`Alert` er deprecated** (nov 2025): Bruk `LocalAlert`, `GlobalAlert`, `InlineMessage` eller `InfoCard`
- **Ingen `Button variant="danger"`**: Bruk `data-color="danger"` i stedet
- **Ingen `Button size="large"`**: Gyldige: `"medium"`, `"small"`, `"xsmall"`
- **`borderRadius="large"` fjernet**: Bruk `"4"`, `"8"`, `"12"`, `"full"`
- **CSS-klasseprefiks er `.aksel-`**: Ikke `.navds-`
- **Aldri override `--ax-*` semantiske tokens** eller `.aksel-*` klasser
- **VStack/HStack har ingen `padding`-prop**: Wrap i `Box` for padding
- **`gap` trenger alltid `space-`-prefiks**: `gap="space-16"`, aldri `gap="4"`

```tsx
// ❌ Deprecated/feil i v8
<Alert variant="error">Feil</Alert>
<Button variant="danger">Slett</Button>
<Box borderRadius="large">

// ✅ Korrekt v8
<LocalAlert status="error">
  <LocalAlert.Header>
    <LocalAlert.Title>Feil</LocalAlert.Title>
  </LocalAlert.Header>
  <LocalAlert.Content>Noe gikk galt</LocalAlert.Content>
</LocalAlert>
<Button data-color="danger">Slett</Button>
<Box borderRadius="8">
```

## Layout og komponenter

Bruk `Box`, `VStack`, `HStack`, `HGrid`, `Show`/`Hide` og `Page`/`Page.Block` for layout. Jobb mobile-first med responsive props (`xs`, `sm`, `md`, `lg`, `xl`).

For komponent-API og eksempler, se `references/components.md`.
For layout-mønstre (sidebar, kort-grid, skjema), se `references/patterns.md`.

## Boundaries

### ✅ Alltid
- Bruk Aksel-komponenter for standard UI-elementer
- Bruk `space-*`-tokens i layout-props
- Bruk responsive props når komponenten støtter det
- Håndter lasting, feil, tomtilstand og suksess eksplisitt
- Sjekk eksisterende UI-mønstre i repoet først
- Hent Aksel-docs fra aksel.nav.no/llm.md — aldri stol på treningsdata for komponent-API

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
