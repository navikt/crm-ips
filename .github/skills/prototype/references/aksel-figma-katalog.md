# Aksel Figma-katalog (empirisk uttrukket)

Oppslag over alle **instansierbare** Aksel-komponenter i Figma-biblioteket `02 Aksel Components`, uttrukket via preflight (import + instans-inspeksjon). Bruk denne i stedet for å gjette variant-navn, defaults, tekstnode-navn eller fonter — det fjerner preflight-runder og gjettefeil.

> Vår egen «manifest» inntil Aksel publiserer en maskinlesbar én (jf. Issue #58). Verdiene er hentet direkte fra biblioteket. **45 komponenter** dekket i Figma; ytterligere 10 finnes kun i `@navikt/ds-react` (se bunn).

## Slik leser du katalogen

- **key** importeres med `importComponentSetByKeyAsync(key)` — bortsett fra rader merket `(component)` → bruk `importComponentByKeyAsync`.
- **Variant-akser**: alle gyldige verdier listes; **fet** = default. Bygg variantstrengen fra `defaultVariant.name` og bytt ÉN akse (se `figma-prototype.md`).
- **Antall-akser** (`Options`/`Amount`/`Items`/`Number of`/`Answers`) styrer **antall barn** — du kan ikke appende. Velg variant med riktig antall, fyll likt-navngitte tekstnoder per indeks.
- **Tekstnoder**: eksakte `name`-verdier for `findOne`/`findAllWithCriteria`. Gjentatte navn = fyll per indeks.
- **Font**: les alltid `node.fontName` dynamisk. Standard `Source Sans 3`; noen noder bruker fortsatt `Source Sans Pro`.
- **Default er ofte «feil»** for status/tilstand (Error/Neutral/unchecked). Katalogen markerer kjente feller.
- **`Breakpoint`-akse** (xl/sm) finnes på flere nyere komponenter = responsiv variant; velg `xl` for desktop.

## Skjema og input

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Button | `Button Accent` `c2e28c6490cec0346ffbbf5636fbdee88bbb7f41` · `Button Neutral` `f2ad7c75cb7dd9eb2215f6ffa580d9ea73107d94` · `Button Danger` `669a43e5a3ece8dd2ad458c4a83384b28a968bae` | Size(**Medium**/Small/XSmall) · Variant(**Primary**/Secondary/Tertiary) · State(**Default**/Hover/Active/Disabled) · Icon only(**False**/True) | `label` | 3 separate sett per farge, ikke fargeakse. Accent=blå primær |
| TextField | `TextField` `c580ac23684bc1b8b6f1f750eaa1ae7b548d742a` | Size(**Medium**/Small) · State(**Default**/Hover/Focus/Error/Read-only/Disabled) | `Label`, `Description`, `intput text` | Input-node heter `intput text` (skrivefeil). Skjul `Description` hvis ubrukt |
| Textarea | `TextArea` `37bed4a523afa158b6015d401143e153ab85f4d3` | Fixed height(True/**False**) · Size(**Medium**/Small) · State(**Default**/Hover/Focus/Error/Read-only/Disabled) | `Label`, `Description`, `Text`, `Value`, `Value-text` | |
| Select | `Select` `39877bb4a89c7c6777766ab90efa94f88457b838` | Size(**Medium**/Small) · State(**Default**/Hover/Focus/Error/Read-only/Disabled) | `Label`, `Description`, `intput text` | Input bruker `Source Sans Pro` |
| Checkbox | `CheckboxGroup` `d310e8c9b71cae9d89645c7e3014351240483d56` | Size(**Medium**/Small) · **Options(2–7, def 2)** · State(**Default**/Read-only/Error/Disabled) | `Label`+`Description` per element | Antall-akse. Sub-checkbox: `a9ba5731c00a4df08daa5100ff9651bb4392c9b1` |
| Radio | `Radio Group` `7b02ae73ea50ec44aa75d9b5d37ff73786121a65` · `Radio Group Horizontal` `efb5ed6274d0a61c3729a7426be7e343161eb978` | Size(**Medium**/Small) · **Options(2–7, def 2)** · State(**Default**/Error/Read-only/Disabled) | `Label`+`Description` per element | Antall-akse |
| Switch | `Switch` `ecb55bd1d9dc008d46a64d73e39f33df835cf5e5` | Size(**Medium**/Small) · Position(Right/**Left**) · State(**Default**/Hover/Read-only/Disabled) · Checked(**False**/True) · Loading · Label | `Label`, `Description` | `Checked=True` for på |
| Combobox | `Combobox__Dropdown` `d7ddf3c2103c96a7a0756576e54e9345edfcf367` | Size(**Medium**/Small) · Variant(NewValue/**Default**/MaxSelected) | `text`, `value`, `label`×N | Til >7 alternativer / flervalg |
| Chips | `ToggleChip` `1e56b247b6f97626a16babe4e9c772b6ca649d47` | Variant(**Neutral**/Accent) · Size(**Medium**/Small) · State(**Default**/Hover) · Selected(**False**/True) · hasCheck(**True**/False) | `Label` | Filtrering. `Selected=True`=aktivt |
| ToggleGroup | `ToggleGroup` `412465b2b3caaa705d133ecc7bfe7ec14d0c2095` | **Amount(2–5, def 2)** · Size(Small/**Medium**/XSmall) · Variant(**Neutral**/Accent) | `Label`×N | Antall-akse `Amount` |
| CopyButton | `CopyButton` `efe9bd1c76e9060e51d7cb409a5bc0ad9be4075d` | Size(**Medium**/Small/XSmall) · Variant(**Neutral text**/Neutral link/Accent text/Accent link) · Icon(**Icon left**/Icon right/Icon only) · State · Interaction · Tooltip | `label` | |
| Search | `Search` `027adba8384c0521d2094da02b89c5424d81ba9d` | Size(**Medium**/Small) · Variant(**Primary**/Secondary/Simple) · State(**Default**/Hover/Error) | `Label`, `Description`, `Text` | Fritekstsøk (ikke verdivalg → Combobox) |
| DatePicker | `DatePicker_Input` `9d4963840f5694193e2b4062636179510c00ae0b` | Size(**Medium**/Small) · State(**Default**/Hover/Error/Disabled/Read-only) | `Label`, `Description`, `Date` | |
| MonthPicker | `MonthPicker_Input` `0f220322c6eef12283602221aa9e14cad8822215` | Size(**Medium**/Small) · State(**Default**/Hover/Error/Disabled/Read-only) | `Label`, `Description`, `Date` | |
| FormProgress | `FormProgress` `09c3f76750b876883d302d70429a8df41c2efde7` | State(**Default**/Hover) · Open(**False**/True) | `Steg`, `333`, `av`, `999`, `label` | Søknadssteg — **bruk denne, ikke Stepper**. `333`=gjeldende, `999`=totalt (tekstnoder, ikke akse) |
| FileUpload | `FileUpload-ItemList` `da7dfbe17329c3262d786c69f1e5a7a8f4721822` `(component)` | _ingen akser_ | `Label`, `Text`+`Details` per fil | Liste over opplastede filer |
| ErrorSummary | `ErrorSummary` `28098a551f358c8e5caea1c585b440bc6a8469c2` | Size(**Medium**/Small) · **Amount(1–10, def 1)** | `Heading`, `Text` per feil | Antall-akse. Valideringsoversikt med lenker til felt |
| FormSummary | `FormSummary` `6ea440aa853552224bf6d02f3b4983aa34cfb445` | Breakpoint(**xl**/sm) · **Answers(1–12, def 1)** | `Heading`, `Item Label`, `Text`, `Comma`… | Antall-akse. Skjulte sm-kopier: fyll gjentatte noder KUN synlige |
| HelpText | `HelpText` `81162cfb1871b11c176a6255033eadc3cb51aa32` | State(**Default**/Hover/Active) · Placement(**Top**/Right/Bottom/Left) · Breakpoint(**xl**/sm) | _(innhold i popover)_ | `?`-trigger ved siden av label |

> **Antall-akser (skjema):** Checkbox/Radio `Options` 2–7, ToggleGroup `Amount` 2–5, ErrorSummary `Amount` 1–10, FormSummary `Answers` 1–12. Default lavest.

## Tilbakemelding og status

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| LocalAlert | `LocalAlert` `371252a7c82249b947473c344b5ad4342b6a6aae` | Variant(**Error**/Announcement/Warning/Success) · Size(**Medium**/Small) | `Heading`, `paragraph` | **Default=Error**. `Announcement`=nøytral info (ingen `Info`) |
| GlobalAlert | `GlobalAlert` `c28f3f88406e1903f7683e2e9106770d857cb6f0` | Variant(**Error**/Announcement/Warning/Success) · Size(**Medium**/Small) · Centered content(**True**/False) | `Heading`, `paragraph` | **Default=Error**. Hele bredden, øverst i løsningen |
| InlineMessage | `InlineMessage` `f906b500d476f60a2b637a401fe86c78ff8f9fa3` | Variant(**Error**/Warning/Success/Info) · Size(**Medium**/Small) · Is link(**False**/True) · State | `paragraph` | **Har `Info`-variant** (i motsetning til Local/GlobalAlert). Korte statusmeldinger i kontekst |
| Tag | `Tag` `247551580c347876a47506679823a7eaf5c74174` | Size(**Medium**/Small/Xsmall) · Color(**Neutral**/Info/Success/Danger/Warning/Meta 1/Meta 2/Brand Magenta/Brand Beige) · Variant(**Outline**/Moderate/Strong) | `tag label` | Status-merkelapp |
| InfoCard | `InfoCard` `eae0533f8be3249959cdf7c986194f7ed28035cc` | Type(**Info**/Tips/Do this/Avoid this/Attention/Summary/Success/Links/Message) · Size(**Medium**/Small) | `Heading`, `paragraph` | Fremhever innhold (ikke varsel). NB: Figma-varianter er inspirasjon; kode velger farge/ikon fritt |
| ProgressBar | `ProgressBar` `dc428811db999112790c5147866a1b52b957a85d` | Size(Small/**Medium**/Large) | _ingen_ | Kjent varighet/progresjon. Søknad → FormProgress |
| Loader | `Loader` `1ed30f72e820c88ec1d09b169fc387cf77cfaa4c` | Variant(**Default**/Accent) · Size(**3XLarge**/2XLarge/XLarge/Large/Medium/Small/XSmall) | _ingen_ | Ubestemt lasting >1s |
| Skeleton | `Skeleton` `9bc065ea939de7906095457839532d3f8aca49cc` | Pulse(**False**/True) · Variant(**Rectangle**/Text/Rounded/Circle) | _ingen_ | Plassholder mens innhold lastes |
| Tooltip | `Tooltip` `cd3adebd97dc567795c5858cc97e4ceee0862039` | Placement(**Top**/Right/Bottom/Left) | `label`, `key1-label`…`key4-label` | `keyN-label`=hurtigtast-hint |
| Pagination | `Pagination` `3e06ca84fd219676ad6eb373e0d75ab40e4a1501` | Size(**Medium**/Small/XSmall) · Button text(Off/**On**) | `label`×N | |

## Layout og innholdsgruppering

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Accordion | `Accordion` `58f77555191eab99934a953ab57b12ecf75d465c` | **Items(02–14, def 02)** | `Title`+`Slot`+placeholder per element | Antall-akse. **Slot + placeholder synlige** — skjul/erstatt. Title=`Source Sans Pro Bold` |
| ExpansionCard | `ExpansionCard` `19742004278114f8de04117edc24e5826df3ac79` | Size(**Medium**/Small) · State(**Default**/Hover) · Open(True/**False**) | `Title`, `Description`, `Slot`+placeholder | **Slot synlig** — skjul/erstatt. Få ganger etter hverandre → Accordion |
| ReadMore | `ReadMore` `72f5b30b4c34db52f323e02046ba668130632c2b` | Appearance(**Inline**/Panel) · State · Expanded(**False**/True) · Size(Medium/**Large**/Small) | `Label`, `Content` | Forklare begreper |
| GuidePanel | `GuidePanel` `cc76b69e9c75d19e635a846c328ba05a4ea95896` | Direction(**Horizontal**/Vertical) · Breakpoint(**xl**/sm) | `heading`, `text` | Vennlig intro/veiledning øverst på side |
| LinkCard | `LinkCard` `2d95970167b6e439a934c905de59615546b368b8` | Size(**Medium**/Small) · data-color(**Neutral**/Accent) · State(**Default**/Hover) · arrowPosition(**baseline**/center) | `heading`, `paragraph`, `tag label` | Fremhevet lenke med kontekst. NB: ny versjon (ikke `🚨 OLD LinkCard`) |

## Overlegg (modaler, popovere)

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Modal | `Modal` `3c1cfe10c8bdf94b10d9e8f8da05da8353a0451c` | Size(**Medium**/Small) · Fixed height(True/**False**) | `Eyebrow heading`, `Title`, `Text`, `Slot`+placeholder, `label`×3 | **Slot synlig** — skjul/erstatt. `Eyebrow` ofte skjult. `label`×3=footer-knapper |
| Popover | `Popover` `250e85a0bc56ba303e2167351e9ea4e20b51991c` | Breakpoint(**xl**/sm) | `Slot`+placeholder | **Slot synlig** — skjul/erstatt med eget innhold |

## Navigasjon

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Tabs | `Tabs` `4b0cda7109804b82b81799a5e193951e90c75c09` | **Number of(2–5, def 2)** · Size(**Medium**/Small) | `label`×N | Antall-akse |
| Link | `Link` `6002f876eee393496d05d8449dd2e811b9d6e1d4` | State(**Default**/Hover) · Show icon(Left/Right/**No icon**) | `Text` | Navigasjon (ikke handling → Button) |
| Stepper | `Horizontal stepper` `bfc5b14cf3208327fcf9d03902b9e31e176910a3` | Interactive(**True**/False) | `1`+`Seksjonstittel` per steg | **Søknad → FormProgress.** `1`=stegnummer (tekstnode) |
| InternalHeader | `InternalHeader` `60a1ba54917616c6b5160b56e54b4849b87adef7` `(component)` | _ingen akser_ | `Title`×3, `Label`, `Description`, `Text`, `Name` | Dekoratør for **interne flater**. Delkomp.: `Menu/Link`, `Menu/User`, `NavButton` |
| Timeline | `Timeline/Period` `b46745b5a5fb164406d4775cc6c9ac30137c927c` | Variant(Warning/Success/Error/Information/**Neutral**) · State(**Default**/Hover/Selected) · Rounded(**Left**/None/Right/Both) | _ingen_ | **Kun interne flater, ikke mobil.** Komponer fra Timeline/Date, /Period, /Pin, /Row. Ferdig mal: `40262e96466a6e23be9c63dad59c22cd4e733192` |

## Typografi

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Heading | `Heading` `e543054997514a35914c483817b46e2abea6bc75` | Size(**XLarge**/Large/Medium/Small/XSmall) · Device(Mobile/**Desktop**) · Margin bottom(**True**/False) · State · Link | `heading` | Overskrifter. BodyShort/BodyLong/Label finnes tilsvarende |
| Detail | `Detail` `9218664bfba6f01d2f83f5d5fa37744ff033d952` | Type(Regular/**Strong**/Caps) | `Small text` | Liten metadata-tekst. NB: node heter `Small text` i Regular/Strong, men i `Caps` heter den etter innholdet — fyll eneste tekstnode direkte |

## Data og tabeller

| Komponent | Figma-navn · key | Variant-akser (**default**) | Tekstnoder | Merknad |
|---|---|---|---|---|
| Table | `Table row` `be74483645b989a166d7d6783c09d5f13c111e01` · `Table cell` `77d47ecf3bd48d90aeabd0cc7342a0a3b34ae770` | **row:** Variant(**Body**/Header) · Zebra · State · Selectable · Expandable. **cell:** Variant(**Body**/Header) · Size(Small/Medium/**Large**) · Interactive · State | `Content` per celle | **Ingen samlet Table.** `Table row` inneholder allerede ~7 `Content`-celler horisontalt — instansier raden, fyll de første N `Content`-nodene og skjul resten. **Ikke** `appendChild` egne celler (stables vertikalt). `Variant=Header` for overskriftsrad |
| DataGrid | `DataGrid [PREVIEW]` `a92ac973a8c3f8d9860b7181d8da7d7ce8806cba` | Filter variant(**Simple**/Advanced) · Batch actions(**False**/True) | `heading`, `Label`, `Description`, `intput text`… | **PREVIEW** — kan endres. Delrad: `DataGrid/TableRow` |

## Kun i kode / ikke egne Figma-komponenter

Disse finnes i `@navikt/ds-react`, men ikke som instansierbare Figma-komponenter — bygg fra primitiver eller bruk angitt erstatning:

| Navn | Status |
|---|---|
| Fieldset | Kode-wrapper rundt felt — grupper felt manuelt med overskrift |
| List | Punktliste — bygg fra tekst/ikoner (typografi) |
| Box, Page | Layout-primitiver — bruk frames/auto-layout |
| Dropdown | **Deprecated** → bruk ActionMenu |
| ActionMenu | Ny er kode-først; kun `🚨 OLD ActionMenu` `3ce21c50720641c2b26d1b2a686d7344dc9619e0` i Figma |
| Dialog | Ikke egen komponent → bruk Modal |
| Chat, Process | Ingen kjerne-Figma-komponent (Chat: kun ikoner) |
| Navpoleonskake (Breadcrumbs) | Ikke kjernekomponent i Aksel Figma |

## Dekning

**45/55 aktive komponenter** uttrukket empirisk (skjema, status, layout, overlegg, navigasjon, typografi, data komplett). 10 er kun kode / ikke i Figma (over). Oppdater ved nye Aksel-utgivelser ved å kjøre samme preflight-mønster (se `figma-prototype.md`).
