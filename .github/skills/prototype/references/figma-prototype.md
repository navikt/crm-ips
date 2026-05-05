# Figma-prototype — Nav-spesifikk referanse

## Oppstart: Hent planKey

```
whoami → plans[0].key (typisk "organization::810213623608415105" for Nav)
```

Hvis flere plans: spør designeren hvilken organisasjon.

## Opprett fil

```
create_new_file(fileName: "<beskrivende navn>", planKey: "<key>", editorType: "design")
```

Spør designeren: "Vil du lagre i Drafts (standard) eller et spesifikt prosjekt?"
- Drafts: utelat projectId
- Prosjekt: be om URL eller prosjekt-ID, bruk `projectId`-parameteret

## Aksel-biblioteker i Nav-org

Automatisk tilgjengelige (auto-subscribed):
- **01 Aksel Tokens** — farger, spacing, typografi
- **02 Aksel Components** — alle UI-komponenter
- **03 Aksel Icons** — ikonbiblioteket

Bekreft med `get_libraries(fileKey)` etter filopprettelse.

## Søk og bruk komponenter

Se komponent-gate og demo-tekst-regler i `SKILL.md` — de gjelder alltid før søk.

```
search_design_system(query: "Button", fileKey: "<key>")
→ Returnerer component key, variants, props
```

Nyttige søk:
- `Button`, `TextField`, `Select`, `Checkbox`, `Radio`
- `Modal`, `Tabs`, `Accordion`, `Table`
- `LocalAlert`, `GlobalAlert`, `InlineMessage`, `InfoCard` (`Alert` er deprecated i kode — bruk Aksel-erstatningene selv om Alert finnes i Figma-biblioteket)
- `Heading`, `BodyLong`, `BodyShort`, `Label`

## Plugin API-mønster for instansiering

```javascript
// Importer komponent-set og opprett instans
const componentSet = await figma.importComponentSetByKeyAsync("COMPONENT_KEY");
const instance = componentSet.defaultVariant.createInstance();
frame.appendChild(instance);

// Endre variant-props
instance.setProperties({ "Size": "Medium", "Variant": "Primary" });
```

## Gotchas

- Font "Inter": style er `"Semi Bold"` (med mellomrom), ikke `"SemiBold"`
- Tekstendring krever font-loading: kall `loadFontAsync()` for alle fonter i noden *før* du endrer `.characters`
- Bruk `await figma.setCurrentPageAsync(page)` — IKKE `figma.currentPage = page`
- `generate_figma_design` lager ny fil — bruk `use_figma` for å redigere eksisterende
- Aksel-biblioteker trenger ikke manuell subscription i Nav-org

## Layout-oppbygging

Bygg alltid top-down:
1. Page → Frame (viewport-størrelse, f.eks. 1440×900 for desktop)
2. Frame → Auto Layout (vertikal/horisontal)
3. Sett spacing, padding, fills via Plugin API
4. Legg til komponenter fra Aksel-biblioteket

## Lever

Returner alltid Figma-URL til designeren:
```
https://www.figma.com/design/<fileKey>/<fileName>
```
