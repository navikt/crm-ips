# Semantiske tokens (`--ax-*`)

Aksel v8 introduserer et semantisk token-lag med prefikset `--ax-` (aksel x). Disse tokenene abstraherer over lys/mørk modus og over fargefamilier, og **skal foretrekkes foran rå fargetokens**.

## Prinsipp

- Bruk `--ax-bg-*`, `--ax-text-*` og `--ax-border-*` for flater, tekst og border.
- Unngå rå farger som `--ax-accent-400`; bruk semantiske versjoner som `--ax-accent-moderate-hover`.
- Ikke endre hovedfargen på appen — bruk `data-color` for å bytte farge på enkeltkomponenter.

## Bakgrunnstokens

```css
/* Nøytrale flater */
--ax-bg-default           /* Standard bakgrunn (app-nivå) */
--ax-bg-raised            /* Hevet flate (kort, modal) */
--ax-bg-sunken            /* Senket flate (input-felt-bakgrunn) */
--ax-bg-overlay           /* Dialog/drawer-overlay */

/* Intensitetsnivåer per fargefamilie */
--ax-bg-neutral-soft
--ax-bg-neutral-moderate
--ax-bg-neutral-moderate-hover
--ax-bg-neutral-moderate-pressed
--ax-bg-neutral-strong
--ax-bg-neutral-strong-hover
--ax-bg-neutral-strong-pressed

/* Samme mønster for: accent, success, warning, danger, info */
--ax-bg-accent-soft
--ax-bg-accent-moderate
--ax-bg-accent-strong
/* osv. */
```

## Teksttokens

```css
--ax-text-neutral            /* Standard tekst */
--ax-text-neutral-subtle     /* Sekundær tekst */
--ax-text-neutral-decoration /* Ikoner, dekor */
--ax-text-neutral-contrast   /* Tekst på sterk bakgrunn */

/* Samme mønster for: accent, success, warning, danger, info */
--ax-text-accent
--ax-text-danger
/* osv. */
```

## Border-tokens

```css
--ax-border-neutral
--ax-border-neutral-subtle
--ax-border-neutral-strong
--ax-border-focus

/* Samme mønster for: accent, success, warning, danger, info */
--ax-border-danger-subtle
--ax-border-info-strong
/* osv. */
```

## Fargefamilier

Semantiske tokens finnes for disse familiene:

- `neutral` — standard gråskala
- `accent` — primærfarge (default)
- `info` — blå
- `success` — grønn
- `warning` — gul/oransje
- `danger` — rød
- `brand-magenta`, `brand-beige`, `brand-blue` — brand-farger
- `meta-purple`, `meta-lime` — meta-kategorier

## `data-color`-mekanismen

Standard applikasjonsfarge er `accent`. **Ikke endre app-fargen globalt** — bruk i stedet `data-color` på enkeltelementer for å bytte semantisk farge:

```tsx
<ExpansionCard data-color="info">
  {/* --ax-bg-soft, --ax-text-default osv. peker nå på info-fargen */}
</ExpansionCard>
```

Hvordan det fungerer:

```css
[data-color="info"] {
  --ax-bg-soft: var(--ax-bg-info-soft);
  --ax-bg-moderate: var(--ax-bg-info-moderate);
  --ax-bg-strong: var(--ax-bg-info-strong);
  --ax-text-default: var(--ax-text-info);
  --ax-text-subtle: var(--ax-text-info-subtle);
  --ax-border-default: var(--ax-border-info);
  /* osv. */
}
```

Inne i en `[data-color]`-kontekst kan du bruke de generiske variablene (`--ax-bg-soft`, `--ax-text-default`, `--ax-border-default`) og de vil automatisk peke på riktig fargefamilie.

## Praktiske regler

- **Foretrekk semantiske tokens** (`--ax-bg-neutral-soft`) foran rå farger (`--ax-neutral-100`).
- **Ikke hardkod farger** i komponenter — bruk semantiske tokens eller `data-color`.
- **For tilstander** (hover, pressed) finnes eksplisitte tokens: `--ax-bg-accent-moderate-hover`, `--ax-bg-accent-moderate-pressed`.
- **Kontrast-tokens** (`--ax-text-*-contrast`) brukes for tekst på sterk bakgrunn.

## Lys/mørk modus

Tokenene er allerede mørk/lys-aware. Bruk `.light` eller `.dark` (eller `:root`) som rotklasse — semantiske tokens peker automatisk på riktig verdi.

```css
.dark {
  --ax-bg-default: #0e151f;
  --ax-text-neutral: var(--ax-neutral-1000); /* lys tekst */
}
```
