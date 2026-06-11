# Aksel-tokens for Figma-skisser (empirisk uttrukket)

Komponentene i [`aksel-figma-katalog.md`](./aksel-figma-katalog.md) bærer sin egen styling. Denne filen dekker **layouten rundt** dem — luft, bakgrunner, kanter, hjørner og løs tekst — så hele skissen blir Aksel-korrekt, ikke bare komponentene.

> Tokens ligger i biblioteket `01 Aksel Tokens`. **Autoritativ live-kilde:** `get_variable_defs` på en node returnerer de faktiske `--ax-*`-verdiene den bruker — kjør den ved tvil. Verdiene under er en praktisk hurtigreferanse for å bygge omkringliggende layout uten å gjette.

## Spacing (`--ax-space-N`, N = piksler)

Lineær px-skala: bruk verdien direkte til `itemSpacing`, `padding*`, gaps.

`0 · 2 · 4 · 6 · 8 · 12 · 16 · 20 · 24 · 28 · 32 …`

Praktiske valg: feltavstand i skjema **24**, seksjonsavstand **40–48**, tett gruppe **8–12**, padding i kort/paneler **16–24**.

## Hjørneradius (`--ax-radius-N`)

| Token | px | Bruk |
|---|---|---|
| `radius-4` | 4 | små elementer, tags |
| `radius-8` | 8 | knapper, input, kort |
| `radius-12` | 12 | paneler, modaler |
| `radius-full` | 9999 | pill/sirkel |

## Semantiske farger (token-navn → bruk)

> **Ikke hardkod hex.** Hent den faktiske verdien live: `get_variable_defs` på en
> node, eller `search_design_system` på token-navnet for å binde variabelen. Da kan
> fargene aldri drifte fra Aksel. Listene under er *navnekart* — hvilket token som
> hører til hvilken situasjon — ikke en verditabell.

**Bakgrunn** (`--ax-bg-*`)
| Token | Bruk |
|---|---|
| `bg-default` | standard sidebakgrunn |
| `bg-raised` | kort/svevende bokser |
| `bg-sunken` | nedsunket seksjon (lysere grå) |
| `bg-neutral-soft` | subtil grå flate |
| `bg-neutral-moderate` | tydeligere grå |
| `bg-info-moderate` | info-flate |
| `bg-success-moderate` | suksess-flate |
| `bg-success-strong` | meningsbærende grønn |
| `bg-accent-strong` | primær blå (knapp/markering) |

**Tekst** (`--ax-text-*`)
| Token | Bruk |
|---|---|
| `text-neutral` | standard tekst |
| `text-neutral-subtle` | dempet/sekundær tekst |
| `text-neutral-contrast` | tekst på mørk/sterk flate |
| `text-accent-subtle` | lenke/aksent-tekst |
| `text-success` | suksess-tekst |
| `text-info` | info-tekst |

**Kant** (`--ax-border-*`)
| Token | Bruk |
|---|---|
| `border-neutral` | standard kant |
| `border-neutral-subtleA` | subtil skillelinje (alpha) |
| `border-neutral-strong` | tydelig kant |
| `border-accent` | aksent-kant |
| `border-success` | suksess-kant |
| `border-info` | info-kant |

## Typografi (for LØS tekst du lager selv)

Bruk komponentene `Heading`/`Detail` der det passer. For ren tekst i layout, match Aksel-skalaen. Familie: **`Source Sans 3`** (noen eldre noder: `Source Sans Pro` — les alltid `node.fontName`).

| Stil | Font · vekt | Størrelse / linjehøyde | Bruk |
|---|---|---|---|
| Heading Large | Source Sans 3 · SemiBold | 32 / 40 | sidetittel (desktop) |
| Heading Medium | Source Sans 3 · SemiBold | 24 / 32 | seksjonstittel |
| Heading Small | Source Sans 3 · SemiBold | 20 / 28 | underseksjon |
| BodyLong Medium | Source Sans 3 · Regular | 18 / 28 | brødtekst (lange avsnitt) |
| BodyShort Medium | Source Sans 3 · Regular | 18 / 24 | korte tekster/labels |
| BodyShort Small | Source Sans 3 · Regular | 16 / 20 | hjelpetekst |
| Detail Uppercase | Source Sans 3 · Regular | 14 / 20 (ls 7.5) | metadata/caps |

## Slik bruker du tokens i `use_figma`

- **Raskt (90 %):** rå px-verdier direkte for layout — `frame.itemSpacing = 24`, `frame.cornerRadius = 8`. For *farger*, hent token-verdien live (`get_variable_defs` / `search_design_system`) i stedet for å gjette hex. Dekker nesten alle skisser.
- **Token-bundet (presist):** importer variabelen og bind den:
  ```javascript
  const v = await figma.variables.importVariableByKeyAsync(KEY); // key fra search_design_system
  frame.setBoundVariable('itemSpacing', v);      // eller fills via setBoundVariableForPaint
  ```
  Bruk dette når skissen skal være helt token-tro (f.eks. før kode-overlevering / Fase 5).
- **Ved tvil:** `get_variable_defs` på en eksisterende Aksel-komponent i samme fil viser hvilke `--ax-*` den faktisk bruker — kopier de tokenene.
