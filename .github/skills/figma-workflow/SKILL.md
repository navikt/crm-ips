---
name: figma-workflow
description: "Design-til-kode-arbeidsflyt — Figma-lenker, Code Connect og mapping fra design til Aksel-komponenter, tokens og responsiv layout. Brukes via /figma-workflow når oppgaven har Figma-lenke eller design-to-code."
---

# Figma → Aksel-kode

Bruk denne skillen når du har en Figma-lenke eller Figma-referanse og skal implementere designet i Nav-frontend med `@navikt/ds-react`. Skillen forutsetter at Figma MCP-verktøy er tilgjengelig.

## Aksel-dokumentasjon

Hent komponent-API, tokens og props fra live dokumentasjon:

```
https://aksel.nav.no/llm.md
```

Mapping-tabellene nedenfor er en hurtigreferanse. Ved tvil — hent fra kilden.

## Arbeidsflyt

### 1. Hent designkontekst

Hent struktur, hierarki og visuell intensjon fra Figma-noden via MCP-verktøyene.

### 2. Hent variabler

Finn spacing-, farge- og typografivariabler som er brukt i designet.

### 3. Sjekk Code Connect

Sjekk om Figma-noder allerede er koblet til `@navikt/ds-react`-komponenter. Når en mapping finnes — bruk den direkte.

### 4. Mapp til Aksel

Oversett Figma-strukturen til Aksel-komponenter og tokens (se mapping-tabellene nedenfor). Verifiser komponent-API mot aksel.nav.no/llm.md. Se også `aksel-design`-skillen.

### 5. Implementer

Bygg med Aksel-primitives. Aldri generisk HTML for elementer Aksel dekker.

### 6. Visuell verifisering

Sammenlign resultatet med Figma-originalen. Sjekk spacing, farger, typografi og responsiv oppførsel.

## Figma → Aksel mapping

### Layout: Auto Layout → Layout-primitives

| Figma Auto Layout | Aksel-komponent |
|---|---|
| Vertikal, gap | `<VStack gap="space-*">` |
| Horisontal, gap | `<HStack gap="space-*">` |
| Horisontal, wrap | `<HStack gap="space-*" wrap>` |
| Grid med kolonner | `<HGrid columns={...} gap="space-*">` |
| Container med padding | `<Box padding="space-*">` |
| Container med border + bakgrunn | `<Box background="..." borderColor="..." borderWidth="1" borderRadius="...">` |

```tsx
// ❌ Feil — rå HTML med inline styles fra Figma
<div style={{ display: "flex", flexDirection: "column", gap: "24px", padding: "32px" }}>
  <div style={{ display: "flex", gap: "12px" }}>
    <button>Avbryt</button>
    <button>Lagre</button>
  </div>
</div>

// ✅ Riktig — Aksel-primitives med tokens
<Box padding="space-32">
  <VStack gap="space-24">
    <HStack gap="space-12" justify="end">
      <Button variant="secondary">Avbryt</Button>
      <Button>Lagre</Button>
    </HStack>
  </VStack>
</Box>
```

### Spacing: Figma-variabler → `space-*` tokens

| Figma-verdi (px) | Aksel-token |
|---|---|
| 0 | `space-0` |
| 4 | `space-4` |
| 8 | `space-8` |
| 12 | `space-12` |
| 16 | `space-16` |
| 20 | `space-20` |
| 24 | `space-24` |
| 32 | `space-32` |
| 40 | `space-40` |
| 48 | `space-48` |
| 64 | `space-64` |

I v8 er token-navnet pikselbasert: `spacing/24` i Figma → `space-24`. Fullstendig skala i `aksel-design`-skillens `tokens.md`.

### Farger: Figma-variabler → Aksel semantiske farger

Figma bruker Navs felles fargebibliotek med semantiske variabelnavn. Mapp til Aksel:

| Figma-variabel (eksempel) | Aksel `background` / `borderColor` / CSS |
|---|---|
| `surface/default` | `background="default"` |
| `surface/subtle` | `background="neutral-soft"` |
| `surface/action` | `background="accent-soft"` |
| `surface/success` | `background="success-soft"` |
| `surface/warning` | `background="warning-soft"` |
| `surface/danger` | `background="danger-soft"` |
| `border/default` | `borderColor="neutral-subtle"` |
| `border/strong` | `borderColor="neutral"` |
| `text/default` | Automatisk via Aksel-typografi |
| `text/subtle` | `<BodyShort textColor="subtle">` |

Bruk `data-color` for fargeoverrides i spesielle kontekster. Aldri hardkod hex-verdier.

```tsx
// ❌ Feil — hardkodet farge fra Figma
<div style={{ backgroundColor: "#E6F0FF", border: "1px solid #0067C5" }}>

// ✅ Riktig — Aksel semantisk farge
<Box background="accent-soft" borderColor="accent" borderWidth="1">
```

### Komponenter

For komponentmapping, hent fra `aksel.nav.no/llm.md` og sjekk Code Connect-mapping først. Bruk `data-color="danger"` i stedet for variant `danger` på Button. Alert er deprecated — bruk `LocalAlert`, `GlobalAlert`, `InlineMessage` eller `InfoCard`.

## Code Connect

Code Connect kobler Figma-noder direkte til `@navikt/ds-react`-komponenter. Når MCP-verktøyene returnerer en Code Connect-mapping for en node, bruker du den eksakte komponenten som er spesifisert.

Sjekk alltid om mappingen allerede finnes før du oppretter en ny. For oppsett og publisering, se [Figma Code Connect-docs](https://github.com/figma/code-connect).

## Responsiv mapping

Figma viser ofte kun én breakpoint. Sjekk om det finnes flere frames for mobil/desktop. Mapp til responsive props (`columns={{ xs: 1, md: 3 }}`, `gap={{ xs: "space-16", md: "space-24" }}`, `padding={{ xs: "space-16", md: "space-32" }}`). Se `aksel-design`-skillens `patterns.md` for fullstendige eksempler.

## Boundaries

### ✅ Alltid
- Mapp Figma-variabler til Aksel-tokens — aldri hardkod pikselverdier eller hex-farger
- Bruk Aksel-komponenter når Figma-elementet har en `@navikt/ds-react`-ekvivalent
- Sjekk Code Connect-mapping før manuell komponent-matching
- Bruk `aksel-design`-skillen for å verifisere komponent-API og props

### ⚠️ Spør først
- Designelementer uten tydelig Aksel-ekvivalent — avklar med designer/team
- Avvik mellom Figma-design og eksisterende UI-mønstre i repoet
- Nye spacing-verdier som ikke finnes i `space-*`-skalaen

### 🚫 Aldri
- Bygg rå HTML/CSS for elementer Aksel dekker
- Hardkod farger, spacing eller typografi fra Figma-inspektøren
- Ignorer responsive behov fordi Figma kun viser én breakpoint
- Opprett egne design-tokens som dupliserer Aksels eksisterende tokens
