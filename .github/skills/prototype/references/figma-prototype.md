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

## Preflight (ALLTID før bygging)

Kjør alltid en preflight-sjekk med EN instans av hver komponenttype du planlegger å bruke. Dette avdekker varianter, text-node-navn og font-krav:

```javascript
// Preflight-mønster — kjør som FØRSTE use_figma-kall
const componentSet = await figma.importComponentSetByKeyAsync("COMPONENT_KEY");

// 1. Logg varianter
const variantNames = componentSet.children.map(c => c.name);

// 2. Opprett test-instans og logg tekstnoder
const testInstance = componentSet.defaultVariant.createInstance();
const textNodes = testInstance.findAll(n => n.type === "TEXT");
const nodeInfo = textNodes.map(n => ({ name: n.name, chars: n.characters, font: n.fontName }));

// 3. Returner data — bruk dette til å bygge skissen i neste kall
testInstance.remove();
return JSON.stringify({ variants: variantNames, textNodes: nodeInfo });
```

Dette forhindrer feil-runder der du gjetter variant-navn eller tekst-node-navnene.

## Plugin API-mønster for instansiering

```javascript
// Importer komponent-set og opprett instans
const componentSet = await figma.importComponentSetByKeyAsync("COMPONENT_KEY");

// Velg variant med eksakt navnematch (fra preflight-data)
const variant = componentSet.children.find(c => c.name === "Size=Medium, Variant=Filled");
const instance = (variant || componentSet.defaultVariant).createInstance();
frame.appendChild(instance);
```

### Korrekt tekst-overstyring i komponent-instanser

Aksel-komponentenes `componentProperties` har nøkler med instansspesifikke ID-suffiks (f.eks. `"Label Text#21497:30"`) som varierer mellom instanser. `setProperties()` fungerer derfor **ikke pålitelig** for tekstendringer.

**Anbefalt tilnærming:** Bruk `findOne` med **eksakt** `name`-match på direkte instansen:

```javascript
// ✅ RIKTIG: Finn tekstnode med eksakt navn innenfor den spesifikke instansen
const labelNode = instance.findOne(n => n.type === "TEXT" && n.name === "Label");
if (labelNode) {
  await figma.loadFontAsync(labelNode.fontName);
  labelNode.characters = "Fastlegen til den ansatte";
}

// ✅ For TextArea:
// Typiske nodenavn: "Label", "Description", "Text", "Value"
const taLabel = textareaInstance.findOne(n => n.type === "TEXT" && n.name === "Label");
const taDesc = textareaInstance.findOne(n => n.type === "TEXT" && n.name === "Description");

// ✅ For Button:
// Nodenavn er "label" (lowercase!)
const btnLabel = buttonInstance.findOne(n => n.type === "TEXT" && n.name === "label");

// ✅ For Checkbox:
// Nodenavn er "Label" (uppercase)
const cbLabel = checkboxInstance.findOne(n => n.type === "TEXT" && n.name === "Label");
```

**VIKTIG — bruk direkte children, IKKE findAll på parent:**

```javascript
// ❌ FEIL: findAll på frame går inn i nestede instanser
const instances = frame.findAll(n => n.type === "INSTANCE"); // Inkluderer sub-instanser!

// ✅ RIKTIG: Bruk direkte children
const instances = frame.children.filter(c => c.type === "INSTANCE");
```

**Feilsøkings-mønster** (bruk når tekst ikke endres):

```javascript
// Logg alle tekstnoder i en instans for å finne riktig navn
const textNodes = instance.findAll(n => n.type === "TEXT");
console.log(textNodes.map(n => ({ name: n.name, chars: n.characters, font: n.fontName })));
```

### Auto Layout-regler

```javascript
// counterAxisSizingMode godtar kun "FIXED" eller "AUTO" — ALDRI "FILL"
frame.counterAxisSizingMode = "FIXED"; // eller "AUTO"

// For å fylle bredden til parent, bruk layoutSizingHorizontal på child:
childFrame.layoutSizingHorizontal = "FILL";

// Unngå spacing-akkumulering — bruk ÉN flat auto-layout med itemSpacing
// Ikke nøst frames med padding + spacer-frames
mainFrame.itemSpacing = 24; // Mellom alle felt
// IKKE: itemSpacing + paddingTop på child + spacer-frame
```

## Gotchas

- Font "Inter": style er `"Semi Bold"` (med mellomrom), ikke `"SemiBold"`
- Tekstendring krever font-loading: kall `loadFontAsync()` for alle fonter i noden *før* du endrer `.characters`
- Bruk `await figma.setCurrentPageAsync(page)` — IKKE `figma.currentPage = page`
- `generate_figma_design` lager ny fil — bruk `use_figma` for å redigere eksisterende
- Aksel-biblioteker trenger ikke manuell subscription i Nav-org
- `counterAxisSizingMode` aksepterer bare `"FIXED"` eller `"AUTO"` — aldri `"FILL"`
- Logg alltid `componentSet.children.map(c => c.name)` FØR du velger variant
- `setProperties()` fungerer IKKE pålitelig for tekst — bruk `findOne` med eksakt nodename
- `layoutSizingHorizontal = "FILL"` kan kun settes ETTER at noden er appended til auto-layout parent
- `frame.children.filter(...)` for direkte barn — ALDRI `frame.findAll(...)` for instansvalg (inkluderer sub-instanser)
- Button text node heter `"label"` (lowercase), Checkbox heter `"Label"` (uppercase)

## Layout-oppbygging

Bygg alltid top-down:
1. Page → Frame (viewport-størrelse, f.eks. 1440×900 for desktop)
2. Frame → Auto Layout (vertikal/horisontal)
3. Sett spacing, padding, fills via Plugin API
4. Legg til komponenter fra Aksel-biblioteket

### Farger og tokens

**Aldri gjett RGB-verdier.** Bruk `search_design_system` eller `get_variable_defs` for å finne riktig fargeverdi:

```javascript
// Bruk variable-binding når mulig, ellers kjente verdier:
// Aksel info-soft = #E6F0FF → {r: 230/255, g: 240/255, b: 255/255}
// Aksel bg-default = #FFFFFF
// Aksel bg-subtle = #F7F7F7
```

Hvis du er usikker på en farge, slå opp tokenet i Aksel-biblioteket FØR du bygger.

### Labels og frame-navn

**Bruk kun frame-navn** — aldri lag separate tekst-labels over frames. Figma viser frame-navnene automatisk. Doble labels overlapper.

## Verifiseringssløyfe (OBLIGATORISK)

**Aldri lever uten visuell verifisering.** Etter bygging:

1. Ta screenshot: `get_screenshot(fileKey, nodeId)` av hovedframen
2. Sjekk visuelt:
   - Overlapper tekst eller elementer?
   - Er alle felter synlige (textarea, input, knapper)?
   - Er spacing proporsjonal og ikke akkumulert?
   - Matcher resultatet konseptet fra Visual Companion?
3. Fiks problemer funnet i steg 2
4. Ta nytt screenshot for å bekrefte
5. Lever til designeren

Typiske feil å fange:
- Tekstnoder som overlapper fordi auto-layout ikke er satt
- Textarea/input som kollapser til 0px høyde (mangler resize eller minHeight)
- Dobbel spacing fra nøstede frames med itemSpacing + padding
- Komponent-instanser som bruker default-tekst fordi setProperties feilet stille

## Lever

Returner alltid Figma-URL til designeren:
```
https://www.figma.com/design/<fileKey>/<fileName>
```
