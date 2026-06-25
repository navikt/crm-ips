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
- `LocalAlert`, `GlobalAlert`, `InlineMessage`, `InfoCard` (`Alert` er **deprecated** i kode — bruk `LocalAlert`/`GlobalAlert`. Det finnes ingen frittstående `Alert` i Figma-biblioteket)
- `Heading`, `BodyLong`, `BodyShort`, `Label`

**Søk på enkelt komponentnavn — ikke beskrivende fraser.** `search_design_system("Select dropdown")` ga NULL Aksel-treff (kun ikoner); `"Select"` alene fant komponenten. Er et søk tomt, prøv synonymer (`Select`/`Combobox`/`Dropdown`), ikke lengre fraser.

**Ferdige maler finnes.** `Aksel Templates`-biblioteket har sammensatte maler verdt å sjekke for hele flyter — f.eks. `Form-ButtonNavigation` (tilbake/neste-knapper i skjema) og sidemaler. Kan spare mye manuell bygging.

### Slik er Aksel-biblioteket faktisk strukturert (verifisert)

Søk gir ofte flere treff enn forventet. Disse fakta er bekreftet mot biblioteket og sparer deg for feil-runder:

- **Button er IKKE ett sett.** Det er separate sett per farge: `Button Accent`, `Button Neutral`, `Button Danger`. Hver har 72 varianter med fire akser: `Size`, `Variant` (`Primary`/`Secondary`/`Tertiary` — IKKE "Filled"), `State`, `Icon only`. Primær knapp = `Button Accent`, variant `Primary`.
- **Hopp over treff merket `🚨 OLD`, `[🚨Old]` eller `___Old_`.** Bruk alltid den nye komponenten med samme navn.
- **Det finnes ingen enkelt `Table`-komponent** (se egen Tabell-seksjon under).
- Tekst-primitives (`Heading`, `BodyLong`, `BodyShort`, `Label`) finnes som komponenter, men for skisser er det ofte enklere og mer stabilt å lage rene `figma.createText()`-noder med riktig font (se under).

### Velg riktig Nav-komponent — les komponentens `description`

`search_design_system` returnerer en `description` per komponent med Aksel sin «Egnet/Uegnet til»-guide. Les den — den avgjør ofte hvilken komponent som er riktig, selv når skissen viser et generisk mønster:

| Skissen viser | Riktig Aksel-komponent | Ikke bruk |
|---|---|---|
| Søknadssteg / «Steg 2 av 4» | `FormProgress` | `Stepper` |
| Tidkrevende prosess med fremdrift | `ProgressBar` | `Stepper` |
| Generell sekvens/navigasjon | `Stepper` | — |

`FormProgress` rendrer bevisst annerledes enn en horisontal stepper (fremdriftslinje + «Steg X av Y» + «Vis alle steg»-utvider) — det er det riktige Nav-mønsteret for søknadsdialog. Tekstnoder: `"333"` (gjeldende steg), `"999"` (totalt antall). Når Aksel har en mer spesifikk komponent enn skissens generiske mønster, velg Aksel-komponenten og forklar designeren avviket.

### Varianter: default er nesten alltid feil for status/tilstand

`defaultVariant` er sjelden den du vil ha når skissen viser en bestemt **farge, status eller tilstand**. Verifiserte feller:

| Komponent | defaultVariant | Konsekvens hvis du bruker default |
|---|---|---|
| GlobalAlert / LocalAlert | `Variant=Error` (rød) | Et «vedlikehold»-varsel blir rødt feilvarsel |
| Tag | `Color=Neutral, Variant=Outline` | Statusfarge mangler (grå outline) |
| Checkbox | `Checked=False` | Avhuket checkbox vises tom |

> **Alert-varianter:** `LocalAlert`/`GlobalAlert` har verdier `Error, Warning, Announcement, Success` — det finnes **ingen `Info`**; bruk `Announcement`. Tekstnoder: `Heading`, `paragraph`.

**Velg variant eksplisitt** ut fra skissens semantikk. Bygg variantstrengen ved å starte fra `defaultVariant.name` og bytte ÉN akse — ikke skriv lange strenger for hånd (akser kan inneholde Unicode som `↳ Selected`):

```javascript
// ✅ Bytt én akse trygt, behold resten
const base = cs.defaultVariant.name;
const wanted = base.replace(/Variant=\w+/, "Variant=Warning");
const v = cs.children.find(c => c.name === wanted) || cs.defaultVariant;
const inst = v.createInstance();
```

Nav status → Tag-farge (Tag har 81 varianter — `Size × Color × Variant`):

| Status i skissen | `Color` | `Variant` |
|---|---|---|
| Under behandling / venter | `Warning` | `Moderate` |
| Innvilget / fullført | `Success` | `Moderate` |
| Avslått / feil | `Danger` | `Moderate` |
| Utkast / nøytral | `Neutral` | `Moderate` |

Gyldige `Color`-verdier: `Info, Neutral, Warning, Success, Danger, Meta 1, Meta 2, Brand Magenta, Brand Beige`.

### Endre farge/variant på en nestet komponent

I motsetning til tekst (se under) fungerer `setProperties` **bra** for variant-akser. Slik fargelegger du en nestet Tag (f.eks. inni en LinkCard, eller en frittstående Tag):

```javascript
const tag = card.findAllWithCriteria({ types: ["INSTANCE"] }).find(n => /tag/i.test(n.name));
tag.setProperties({ "Color": "Warning", "Variant": "Moderate" }); // ✅ variant-akser er stabile nøkler
```

### Antall barn er en variant-akse (lister og containere)

Aksel sine liste-/container-komponenter lar deg **ikke** appende barn. Antall barn er kodet som en **variant-akse**, og default er alltid laveste antall:

| Komponent | Akse for antall | Verdier | Default |
|---|---|---|---|
| RadioGroup | `Options` | 2–6 | 2 |
| Accordion | `Items` | 02–14 | 02 |
| Tabs | `Number of` | 2–5 | 2 |

For N elementer: velg varianten med riktig antall, og fyll deretter de N likt-navngitte tekstnodene **per indeks** (de heter ofte det samme, så `findOne` på navn treffer kun første):

```javascript
const set = await figma.importComponentSetByKeyAsync(RADIOGROUP_KEY);
const variant = set.children.find(c => /Options=3/.test(c.name)) || set.defaultVariant;
const group = variant.createInstance();
frame.appendChild(group);
// Fyll de 3 radio-etikettene per indeks
const labels = group.findAllWithCriteria({ types: ["TEXT"] }).filter(n => n.name === "label");
const texts = ["Ja", "Nei", "Vet ikke"];
for (let i = 0; i < texts.length; i++) {
  await figma.loadFontAsync(labels[i].fontName);
  labels[i].characters = texts[i];
}
```

Forhåndsvalgt tilstand (valgt radio/checkbox i en gruppe) finnes ikke som gruppe-akse — det må eventuelt settes via `setProperties` på en nestet sub-instans. For en skisse er det ofte godt nok å vise uvalgt.

## Preflight (kun for komponenter katalogen ikke dekker)

> **Sjekk katalogen først — den er fasiten.** Alle 45 aktive Aksel-Figma-komponenter er empirisk uttrukket (key, akser, default, tekst-node-navn, fonter, antall-akser, slot-feller). To formater, samme innhold:
> - [`aksel-figma-katalog.json`](./aksel-figma-katalog.json) — **kilde til sannhet** (maskinlesbar; bruk feltene direkte: `key`, `axes[].default`, `countAxis`, `slot`, `textNodes`).
> - [`aksel-figma-katalog.md`](./aksel-figma-katalog.md) — lesbart oppslag for mennesker.
>
> Finner du komponenten i katalogen, **hopp over preflight** og bruk verdiene direkte. Katalogen er drift-validert (se under), så keys og defaults stemmer. Preflight kun det katalogen ikke dekker.
>
> **For layouten rundt komponentene** (luft, bakgrunner, kanter, hjørner, løs tekst) bruk [`aksel-figma-tokens.md`](./aksel-figma-tokens.md) — spacing-skala, semantiske farger, radius og typografi. Da blir hele skissen Aksel-korrekt, ikke bare komponentene. Ved tvil: `get_variable_defs` på en eksisterende Aksel-node viser de faktiske `--ax-*`-tokenene.

Preflight er kun nødvendig for komponenter **utenfor** katalogen (sjelden). Da kjører du EN instans for å avdekke varianter, text-node-navn og font-krav — den eneste pålitelige kilden til faktiske node-navn (som `"intput text"`) og default-varianter. Legg gjerne funnet inn i katalogen etterpå.

```javascript
// Preflight-mønster — kjør som FØRSTE use_figma-kall
const componentSet = await figma.importComponentSetByKeyAsync("COMPONENT_KEY");

// 1. Logg varianter OG default (default er ofte feil farge/tilstand)
const variantNames = componentSet.children.map(c => c.name);
const defaultName = componentSet.defaultVariant.name;

// 2. Opprett test-instans og logg tekstnoder + fonter
const testInstance = componentSet.defaultVariant.createInstance();
const textNodes = testInstance.findAllWithCriteria({ types: ["TEXT"] });
const nodeInfo = textNodes.map(n => ({ name: n.name, chars: n.characters, font: n.fontName }));

// 3. Returner data — bruk dette til å bygge skissen i neste kall
testInstance.remove();
return JSON.stringify({ variants: variantNames, default: defaultName, textNodes: nodeInfo });
```

Dette forhindrer feil-runder der du gjetter variant-navn, default-varianter, fonter eller tekst-node-navn.

## Vedlikehold av katalogen (drift-validering)

Katalogen er en **selv-validert kontrakt**, ikke et statisk dokument:

- **Vokter-test** (`scripts/test_catalog.py`, kjøres i CI sammen med de andre testene): verifiserer at JSON er internt konsistent (gyldige akser/defaults, `countAxis` peker på en ekte akse, keys er 40-tegns hex) **og** at markdown speiler JSON (samme navn + keys). JSON og markdown kan derfor ikke drifte fra hverandre usett.
- **Figma-drift-harness**: når Aksel slipper ny versjon, kjør ett `use_figma`-kall som looper over alle `key` i JSON, importerer hver og sammenligner `defaultVariant`-akser mot fasiten. Avvik = Aksel har endret en key/akse/default → oppdater katalogen. Mønster:

```javascript
// Drift-harness — lim inn [{navn,kind,key,axes:{Akse:default}}] fra JSON
const issues = [];
for (const e of EXP) {
  const s = e.kind === 'component'
    ? await figma.importComponentByKeyAsync(e.key)
    : await figma.importComponentSetByKeyAsync(e.key);
  if (!s) { issues.push(`${e.navn}: import feilet`); continue; }
  if (e.kind === 'component') continue;
  const defVP = s.defaultVariant.variantProperties || {};
  const defs = s.componentPropertyDefinitions || {};
  for (const [ax, val] of Object.entries(e.axes)) {
    if (!(ax in defs)) issues.push(`${e.navn}: akse "${ax}" borte`);
    else if (defVP[ax] !== undefined && defVP[ax] !== val)
      issues.push(`${e.navn}: default ${ax}=${defVP[ax]} (fasit ${val})`);
  }
}
return { av: EXP.length, avvik: issues };  // avvik=[] → katalogen er i synk
```

Sist verifisert: **45/45 importerer, null avvik.**

## Plugin API-mønster for instansiering

```javascript
// Importer komponent-set og opprett instans
const componentSet = await figma.importComponentSetByKeyAsync("COMPONENT_KEY");

// Velg variant med eksakt navnematch (fra preflight-data)
const variant = componentSet.children.find(c => c.name === "Size=Medium, Variant=Primary");
const instance = (variant || componentSet.defaultVariant).createInstance();
frame.appendChild(instance);
```

### Byggrobusthet (to vanlige Plugin API-feller)

1. **Auto-layout-barn må appendes FØR størrelse settes.** `layoutSizingHorizontal = "FILL"` kaster `FILL can only be set on children of auto-layout frames` hvis du setter den før `appendChild`. Rekkefølge: opprett instans → `frame.appendChild(instance)` → `instance.layoutSizingHorizontal = "FILL"`.

```javascript
frame.appendChild(instance);
try { instance.layoutSizingHorizontal = "FILL"; } catch (e) {}  // etter append
```

2. **Pakk `findOne` i try/catch.** Komponenter med slot-/placeholder-noder (LinkCard, FormSummary, Accordion) kan transient kaste `Node ... not found` midt i traverseringen. Uten try/catch stopper hele byggescriptet. Gjør tekst-fyll defensiv slik at én ustabil node ikke velter resten:

```javascript
async function setText(node, name, value) {
  let t = null;
  try { t = node.findOne(n => n.type === "TEXT" && n.name === name); } catch (e) { return; }
  if (!t) return;
  try { await figma.loadFontAsync(t.fontName); t.characters = value; } catch (e) {}
}
```


### Korrekt tekst-overstyring i komponent-instanser

Aksel-komponentenes `componentProperties` har nøkler med instansspesifikke ID-suffiks (f.eks. `"Label Text#21497:30"`) som varierer mellom instanser. `setProperties()` fungerer derfor **ikke pålitelig** for tekstendringer.

**Anbefalt tilnærming:** Bruk `findOne` med **eksakt** `name`-match på direkte instansen. **Du MÅ kjenne det faktiske nodenavnet fra preflight** — gjettede navn gir ingen feilmelding, de bare lar placeholder-teksten stå igjen.

> I faktiske byggescript bør disse `findOne`-kallene gå gjennom den defensive `setText`-helperen fra **Byggrobusthet** (over) — eksemplene under viser kun riktig `name` per komponent, ikke feilhåndteringen.

```javascript
// ✅ RIKTIG: Finn tekstnode med eksakt navn innenfor den spesifikke instansen
const labelNode = instance.findOne(n => n.type === "TEXT" && n.name === "Label");
if (labelNode) {
  await figma.loadFontAsync(labelNode.fontName);
  labelNode.characters = "Fastlegen til den ansatte";
}

// ✅ For TextField — input-noden heter "intput text" (ja, skrivefeil i Aksel!):
// Noder: "Label", "Description", "intput text"
const tfInput = textfieldInstance.findOne(n => n.type === "TEXT" && n.name === "intput text");

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

// ✅ For GuidePanel — noder "heading" og "text" (lowercase), default har Star Wars-tekst
const gpHeading = guidePanelInstance.findOne(n => n.type === "TEXT" && n.name === "heading");
```

**Skjul/erstatt placeholder-tekst.** Mange Aksel-instanser leveres med synlig demo-tekst: TextField/TextArea har en `"Description"`-node, GuidePanel har Star Wars-tekst. Hvis skissen ikke har en beskrivelse, må du sette `.visible = false` på noden — ellers blir placeholder stående.

**Antall-akse-komponenter har skjulte breakpoint-kopier — fyll KUN synlige noder.** Komponenter med Breakpoint-akse (xl/sm) og gjentatte tekstnoder (f.eks. FormSummary `Item Label`/`Text`, ErrorSummary, FormSummary-svar) inneholder en skjult `sm`-kopi av hver rad i tillegg til den synlige `xl`-raden. Fyller du gjentatte noder blindt i rekkefølge, lander verdiene på de skjulte sm-kopiene og de synlige radene blir stående som placeholder («Tekst»). Filtrer alltid på synlighet før du fyller:

```javascript
// ✅ Bare synlige noder — hopper over skjulte sm-breakpoint-kopier
function synlig(node, root){
  let p = node;
  while (p && p !== root){ if (p.visible === false) return false; p = p.parent; }
  return root.visible !== false;
}
const verdier = ["1. juni 2025", "15 uker", "Nei"];
let i = 0;
for (const t of fs.findAllWithCriteria({ types: ["TEXT"] })){
  if (t.name !== "Text" || !synlig(t, fs)) continue;
  await figma.loadFontAsync(t.fontName);
  t.characters = verdier[i++];
}
```

**Bruk `findAllWithCriteria` for robust traversering.** `findOne`/`findAll` med predikat kan kaste «Node not found» på ferske, komplekse instanser (se Gotchas). `findAllWithCriteria` er mer stabilt:

```javascript
// ✅ Mer stabilt enn findAll(n => n.type === "TEXT")
const texts = instance.findAllWithCriteria({ types: ["TEXT"] });
const label = texts.find(n => n.name === "Label");
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
const textNodes = instance.findAllWithCriteria({ types: ["TEXT"] });
console.log(textNodes.map(n => ({ name: n.name, chars: n.characters, font: n.fontName })));
```

### Modal og Accordion: erstatt slot-placeholdere

Modal og Accordion leveres med **synlig placeholder-innhold** som lekker inn i skissen hvis du ikke fjerner det:
- En `Slot`-node + en lang node ved navn `Erstatt med eget innhold ved å bytte ut denne med din egen komponent` (rosa stiplet) — skjul/erstatt med din egen frame.
- Modal har i tillegg et default dokument-ikon ved tittelen og en `Eyebrow heading`-node — skjul hvis ikke ønsket.
- Modal har tre innebygde footer-knapper (`Tertiary`/`Secondary`/`Primary`) som er **accent (blå)** med fast variant. For en danger-bekreftelse (rød): skjul de innebygde knappene og legg inn egne `Button Danger`-instanser i footeren — eller godta accent og noter avviket.

```javascript
// Skjul placeholder + uønsket default i Modal/Accordion
instance.findAllWithCriteria({ types: ["FRAME", "INSTANCE", "TEXT"] })
  .filter(n =>
    n.name === "Slot" ||
    /Erstatt med eget innhold/.test(n.name) ||
    n.name === "Eyebrow heading"
  ).forEach(n => { n.visible = false; });
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

### Font (viktig — feil i tidligere versjon)
- **Aksel bruker `Source Sans 3`, ikke Inter.** Stilnavn er `"Regular"`, `"SemiBold"`, `"Bold"` (UTEN mellomrom). Noen eldre noder bruker `"Source Sans Pro"`.
- **Aldri hardkod fontnavn.** Les fonten fra noden og last den dynamisk — da treffer du alltid riktig familie/stil:
  ```javascript
  await figma.loadFontAsync(node.fontName); // ✅ bruk nodens egen font
  node.characters = "…";
  ```
- For nye `createText()`-noder: last `{ family: "Source Sans 3", style: "Regular" }` (eller `"SemiBold"`/`"Bold"`).

### Atferd i `use_figma` (kritisk for stabilitet)
- **Atomisk rollback:** ÉN kastet exception ruller tilbake HELE scriptet — ingen delvis lagring. En liten feil sent i et stort script sletter alt arbeidet. Pakk risikable kall i `try/catch` og returner en logg i stedet for å kaste.
- **Bygg inkrementelt:** kjør ett `use_figma`-kall per seksjon (header, så kort-rad, så tabell) i stedet for ett stort. Da overlever fullførte deler en senere feil.
- **Intermitterende traverserings-crash:** `findAll(predikat)` på en fersk, kompleks instans (f.eks. LinkCard) kan kaste «in get_name: Node not found», men funke ved nytt forsøk. Bruk `findAllWithCriteria({types:[...]})` og bygg inkrementelt.
- **Villedende timeout:** et kall kan returnere «Plugin execution failed due to internal timeout» selv om operasjonen faktisk committet. Ikke retry blindt — verifiser med `get_metadata`/`get_screenshot` først (operasjonene er ofte idempotente, blind retry kan duplisere).

### Øvrige
- Tekstendring krever font-loading: kall `loadFontAsync()` for alle fonter i noden *før* du endrer `.characters`
- Bruk `await figma.setCurrentPageAsync(page)` — IKKE `figma.currentPage = page`
- `setRelaunchData`, `getPluginData`/`setPluginData` er IKKE støttet her — bruk `getSharedPluginData`/`setSharedPluginData` ved behov
- `generate_figma_design` lager ny fil — bruk `use_figma` for å redigere eksisterende
- Aksel-biblioteker trenger ikke manuell subscription i Nav-org
- `counterAxisSizingMode` aksepterer bare `"FIXED"` eller `"AUTO"` — aldri `"FILL"`
- Logg alltid `componentSet.children.map(c => c.name)` FØR du velger variant
- `setProperties()` fungerer IKKE pålitelig for tekst (bruk `findOne`/`findAllWithCriteria`), men fungerer BRA for variant-akser (`Color`, `Variant`, `Size`)
- `layoutSizingHorizontal = "FILL"` kan kun settes ETTER at noden er appended til auto-layout parent
- `frame.children.filter(...)` for direkte barn — ALDRI `frame.findAll(...)` for instansvalg (inkluderer sub-instanser)
- Button text node heter `"label"` (lowercase), Checkbox heter `"Label"` (uppercase)
- Beskrivelsesliste (`dl`) finnes ikke som Aksel-komponent — bygg et custom tekst-grid. Fyll i leserekkefølge (rad-major), ikke kolonne-major, så par havner riktig.
- `LinkCard` har innebygd Tag (`tag label`) + heading + paragraph — velegnet til sakskort/lenkekort, bedre enn å bygge kort fra scratch.

## Tabeller — det finnes ingen `Table`-komponent

Aksel har ingen samlet `Table`-komponent i Figma. Du komponerer fra `Table row`, `Table cell` og `Table row content`. Verifisert oppskrift:

- **`Table cell`** (sett): header-celle = variant `Variant=Header, Size=Large, Interactive=False, State=Default`; data-celle = default. Tekstnode heter `"Content"`.
- **`Table row`** har 7 tekstnoder som ALLE heter `"Content"` → `findOne(name=="Content")` treffer kun første. Default-rad er 1584px bred. Bruk heller `findAllWithCriteria({types:["TEXT"]})` og indekser, eller bygg raden selv av `Table cell`-instanser i en horisontal auto-layout.
- **Du kan ikke legge barn (Tag, Button, Link) inn i en `Table cell`-instans.** For en statuskolonne med Tag må du bygge en **custom celle-frame**. Match Aksel-cellens utseende: samme padding (16) og **kun bunnramme** (`strokeBottomWeight`), ikke full ramme — ellers får du en uønsket vertikal strek.
- Sett `layoutSizingHorizontal = "FILL"` på celler ETTER at de er lagt i radens auto-layout, så kolonnene fyller bredden.

```javascript
// Custom statuscelle som matcher Aksel-celle (kun bunnramme)
const cell = figma.createFrame();
cell.layoutMode = "HORIZONTAL";
cell.paddingTop = cell.paddingBottom = cell.paddingLeft = cell.paddingRight = 16;
cell.strokes = [{ type: "SOLID", color: { r: 0.8, g: 0.8, b: 0.8 } }];
cell.strokeBottomWeight = 1;
cell.strokeTopWeight = cell.strokeLeftWeight = cell.strokeRightWeight = 0; // ✅ unngå vertikal strek
row.appendChild(cell);
cell.appendChild(statusTag);
```

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

## Kontekst uten å miste redigerbarhet (eksisterende flater)

For eksisterende flater vil designere ofte se modulen i **ekte sidekontekst** (plassering, proporsjoner, hvordan resten av siden flyter) **og** kunne flikke videre på den. Et flatt skjermbilde av hele siden er en blindvei: det kan ikke redigeres, og Figma Make jobber dårlig fra piksler. Løsningen er **bakgrunn + redigerbar overlay** — ekte side som skjermbilde, med den ekte komponent-instansen lagt oppi.

**Teknikk (kontekst-overlay):**

1. **Mål kolonnen** i den kjørende appen — posisjon og bredde der modulen skal stå, relativt til innholdsregionen:
   ```javascript
   const m = document.querySelector('#injection-point').getBoundingClientRect();
   const c = document.querySelector('#maincontent').getBoundingClientRect();
   // { x: m.left - c.left, y: m.top - c.top, w: m.width }
   ```
2. **Injiser et tomt felt** (spacer) med modulens omtrentlige høyde der modulen skal stå, så innholdet under flyter naturlig ned. **Aldri håndkod en HTML-tilnærming av selve modulen** for skjermbildet — det gir drift (feil knapper, feil alert, ulik tekst) fordi tilnærmingen sklir fra den ekte komponenten. Bare et tomt felt.
3. **Knips innholdsregionen** (`#maincontent` e.l.) — ekskluder dekoratør-krom som ofte rendrer ustylet lokalt.
4. **I Figma**: lag en frame med **samme dimensjon/aspektforhold** som skjermbildet (ellers cropper `FILL` bildet og offsetene treffer feil), legg skjermbildet som frame-bakgrunn (`scaleMode: FILL`), og plasser den **redigerbare** Aksel-komponent-instansen oppi det tomme feltet. Match kolonnebredden med `resize` (ikke `rescale`):
   ```javascript
   inst.x = kolonneX; inst.y = kolonneY;
   inst.resize(kolonneBredde, inst.height); // auto-layout reflyter; tekst/spacing/tokens beholdes
   ```
   > **Ikke bruk `node.rescale(factor)`** her — den skalerer hele objektet (typografi, spacing, strokes) som Figmas Scale-verktøy, og gir drift fra Aksel-tokenene. `resize` lar komponentens auto-layout reflyte ved riktig bredde uten å skalere innholdet.

Resultat: ekte sidekontekst + en modul som fortsatt kan redigeres (den er en instans, ikke et bilde), uten overlapping. Endrer du komponentens høyde vesentlig, må spacer/bakgrunn knipses på nytt.

**Den ekte Figma-/Aksel-komponenten er eneste fasit.** Skjermbilder er kun bakgrunn for kontekst — aldri en kilde komponenten skal «matche».

## Lever tilstander som variant-komponent (ikke løse frames)

Designere flikker i Figma og bruker Figma Make. Begge jobber best fra **ekte, redigerbar struktur** — ikke løse statiske rammer eller piksler. Samle derfor tilstandene i **én komponent med en `Tilstand`-variant-akse**:

```javascript
const variants = states.map(s => {
  const comp = figma.createComponentFromNode(s.node);
  comp.name = "Tilstand=" + s.navn;   // f.eks. Tilstand=Tilby
  return comp;
});
const set = figma.combineAsVariants(variants, figma.currentPage);
set.name = "<Modulnavn>";
```

**Slå sammen nesten-like tilstander.** Skiller to tilstander seg bare med et **forbigående** element (f.eks. en bekreftelse som vises kort etter en handling og forsvinner av seg selv), behold **én** hviletilstand og dokumentér det forbigående elementet som en egen **annotasjon** ved siden av — ikke en egen permanent skjerm. To nesten-identiske «status»-rammer leses som dobbeltføring.

## Parity-gate: Figma vs Visual Companion-fasit (OBLIGATORISK)

**Aldri lever uten visuell verifisering mot fasiten.** Visual Companion-skissen er fasit — Figma-resultatet skal matche den. Etter bygging:

1. Ta screenshot av Figma: `get_screenshot(fileKey, nodeId)` av hovedframen
2. Hent fasiten: VC-screenshotet fra `screen_dir` (det designeren valgte)
3. Sammenlign side om side mot denne sjekklisten (avledet fra faktiske feil-moduser):
   - **Struktur**: samme komponenter, samme rekkefølge, ingen manglende felter
   - **Overlapp**: overlapper tekst/elementer? (auto-layout ikke satt)
   - **Kollaps**: textarea/input kollapset til 0px? (mangler resize/minHeight)
   - **Spacing**: proporsjonal, ikke akkumulert dobbel-spacing fra nøstede frames
   - **Variant/tilstand**: riktig variant (ikke default Error/Neutral/unchecked)? riktig antall barn?
   - **Tekst**: faktisk innhold, ikke placeholder (`Label`/`intput text`/«Erstatt med eget innhold»)?
   - **Slot**: Modal/Accordion/ExpansionCard — er Slot-placeholdere skjult/erstattet?
   - **Font**: `Source Sans 3`, ikke Inter/hardkodet
4. Fiks alle avvik funnet i steg 3
5. Ta nytt screenshot og bekreft mot fasiten
6. Lever til designeren først når Figma matcher VC-skissen

Hvis du ikke har en VC-fasit (gikk rett til Figma), bruk samme sjekkliste mot det avtalte konseptet.

## Figma→kode-handoff (Fase 5)

Når en Figma-skisse skal bli klikkbar kode (Fase 5), leser konditor designet med disse verktøyene — ikke gjett fra screenshot alene:

- **`get_design_context(nodeId, fileKey)`** — primærkilden. Gir referansekode + struktur for en node/seleksjon, som tilpasses til prosjektets stack (`@navikt/ds-react`).
- **`get_variable_defs(nodeId, fileKey)`** — Figma-variabler/tokens brukt i seleksjonen → map til Aksel design-tokens i kode for tro gjengivelse av farger/spacing.
- **`get_metadata(nodeId, fileKey)`** — sparsom XML (id/navn/type/posisjon/størrelse) for å forstå hierarkiet før koding.

**Code Connect (`get_code_connect_map`) — status i Nav:** Verifisert empirisk at Aksel **ikke** publiserer Code Connect-mappinger i dag (`get_code_connect_map` på Aksel-noder returnerer `{}`). Når/hvis Aksel-teamet publiserer det org-bredt (via Code Connect CLI i aksel-repoet), gir dette node→`@navikt/ds-react`-komponent + props automatisk — da bør Fase 5 slå opp mappingen i stedet for å mappe manuelt. Inntil da er [`aksel-figma-katalog.md`](./aksel-figma-katalog.md) den manuelle broen. `add_code_connect_map` skriver kun til egne filer (propagerer ikke til delt bibliotek), så det løser ikke org-bred mapping.

## Lever

Returner alltid Figma-URL til designeren:
```
https://www.figma.com/design/<fileKey>/<fileName>
```
