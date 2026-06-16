---
name: accessibility-review
description: "UU/WCAG-review for Nav-frontend — tastaturflyt, skjermleser, axe, kontrast, fokus, feilmeldinger, skjema og Aksel-bruk. Brukes via /accessibility-review før PR eller release."
---
# Tilgjengelighet-review

Review-prosess for universell utforming (UU) i Nav-flater. Universell utforming av ikt er lovpålagt for offentlig sektor gjennom **Likestillings- og diskrimineringsloven §17** og **Forskrift om universell utforming av ikt-løsninger**, med **WCAG 2.1 nivå A og AA** som forskriftskravet per i dag. **WCAG 2.2 AA** er fremoverlent praksis der relevant (nye suksesskriterier som 2.4.11 Focus Not Obscured er enkle å etterleve med Aksel). Verifiser alltid gjeldende krav mot **Tilsynet for universell utforming av ikt** (uutilsynet.no), som kan revidere løsningene våre og gi pålegg.

## Avgrensning mot `accessibility.instructions.md`

Denne skillen er for review-arbeid og større UI-flyter; instructions auto-injiseres under koding med korte minimumsregler. Skillen utdyper med konkrete sjekkpunkter, testoppskrifter og Nav-spesifikke heuristikker.

Når du koder nytt: la instructions styre. Når du skal gjennomgå en branch, flate eller ekstern leveranse før produksjon: bruk denne skillen.

## Kodemønstre som skal sjekkes

### Semantikk og struktur

- Bruk `<main>`, `<nav>`, `<article>`, `<section>`, `<button>` og `<a>` der semantikken finnes.
- Overskriftsnivåer skal være logiske og uten hopp (`h1` → `h2` → `h3`).
- Dokumentet skal ha riktig `lang` og sidetittel der app-strukturen eier dette.

### Skjema og feil

- Bruk Aksel `TextField`, `Textarea`, `Select`, `Checkbox`, `Radio` og tilsvarende der de finnes.
- Alle felter skal ha synlig label.
- Feltfeil skal være koblet til feltet og være konkrete på klarspråk.
- Flere feil i samme skjema skal samles i `ErrorSummary` øverst.

### Interaksjon

- Alle interaktive elementer skal ha tilgjengelig navn og synlig fokus.
- Ikonknapper skal ha `title` eller tilsvarende Aksel-mønster.
- Ikke bruk `<div onClick>` uten rolle, `tabIndex`, tastaturhåndtering og fokusstil.
- Bruk beskrivende lenketekst, ikke "Klikk her".

### Dynamisk innhold

- Loading, feil, tomtilstand og suksess skal annonseres når de påvirker brukerflyten.
- Bruk `aria-live`, `aria-busy` eller Aksel-komponentenes innebygde mønstre der semantikken ikke allerede er dekket.
- Modal, meny og tabs skal ha korrekt fokusrekkefølge og kunne lukkes/navigeres med tastatur.

## Testoppskrifter

### Tastatur

1. Tab gjennom hele endret flyt uten mus.
2. Kontroller at fokus er synlig hele veien.
3. Kontroller at rekkefølgen følger visuell og logisk flyt.
4. Bruk Enter/Space på knapper og lenker.
5. Bruk Escape for modal/meny der relevant.

### `jest-axe`

```tsx
import { axe, toHaveNoViolations } from "jest-axe";

expect.extend(toHaveNoViolations);

it("har ingen automatiske tilgjengelighetsfeil", async () => {
  const { container } = render(<MyComponent />);
  expect(await axe(container)).toHaveNoViolations();
});
```

### Playwright + axe-core

```tsx
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("side har ingen alvorlige tilgjengelighetsfeil", async ({ page }) => {
  await page.goto("/skjema");
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Bruk Aksel i bunn

Aksel-komponenter (`@navikt/ds-react`) har WCAG-samsvar, fokus-håndtering, ARIA og skjermleser-støtte innebygd. Første review-spørsmål er alltid: *brukes Aksel-komponenter der det finnes, eller er noe håndlaget unødvendig?*

Se `aksel-design`-skillen for komponentvalg, tokens og mønstre.

## Manuell + automatisk testing (Nav-praksis)

Begge deler kreves — automatiske verktøy fanger ~30 % av WCAG-bruddene.

- **Automatisk:** `axe-core` (via `@axe-core/react` eller Playwright-integrasjon) i CI. Lighthouse for rask sanity-sjekk.
- **Manuell tastatur-test:** Tab gjennom hele flyten uten mus. Fokus skal være synlig, rekkefølgen logisk, ingen feller.
- **Skjermleser-test:** NVDA (Windows) eller VoiceOver (macOS/iOS) på minst én kritisk flyt. JAWS for eksterne revisjoner.
- **Zoom og reflow:** 200 % zoom og 400 % (reflow-krav), samt tekstavstand per WCAG 1.4.10/1.4.12.
- **Farger:** Kontrast gjennom Aksel-tokens; verifiser med devtools dersom custom farger brukes.

## Klarspråk er tilgjengelighet

Nav skriver for folk i sårbare situasjoner. Uklart språk er et UU-brudd i praksis (WCAG 3.1.5 Lesenivå). Feilmeldinger, labels og hjelpetekst skal være konkrete og handlingsrettede. Se `klarsprak`-skillen.

## Hvem tester

- **Teamet selv** ved hver PR: automatisk skann + tastatur-gjennomgang av endrede flyter. Nye sider krever også skjermleser-sjekk.
- **Fagressurs/designer** ved større flyter eller nytt flow-design.
- **Ekstern UU-revisor (WCAG-EM-metodikk)** ved lansering av nye publikumsrettede tjenester, og periodisk for eksisterende. Funn prioriteres i backlog med frist.
- **Brukertesting med assistive teknologier** bør inngå i større leveranser — ikke alt fanges av heuristikker.

## Review-sjekkliste

- [ ] Aksel-komponenter brukt der det finnes tilsvarende
- [ ] `axe-core` uten `serious`/`critical` funn på endrede sider
- [ ] Full tastatur-gjennomgang av endret flyt
- [ ] Skjermleser-test på nye eller endrede skjemaer og modaler
- [ ] Synlig fokus og logisk fokus-rekkefølge
- [ ] Feilmeldinger er koblet til felt (`aria-describedby`) og på klarspråk
- [ ] Overskrifts-hierarki (`h1`–`h3`) uten hopp
- [ ] Språk-attributt (`lang="nb"`) og korrekt dokumenttittel
- [ ] Kontrast og reflow ved 200/400 % zoom
- [ ] Tilgjengelighetserklæring oppdatert ved kjente avvik (uutilsynet-krav)

## Kilder

- [uutilsynet.no](https://www.uutilsynet.no) — tilsyn, regelverk, tilgjengelighetserklæring
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/) — W3C-standard; vurder 2.2-suksesskriterier der relevant (forskriftskravet er per i dag 2.1 A/AA — verifiser mot uutilsynet.no)
- [Aksel tilgjengelighet](https://aksel.nav.no/grunnleggende/prinsipper/universell-utforming) — Navs praksis og komponentstøtte
- [WCAG-EM](https://www.w3.org/TR/WCAG-EM/) — metodikk for eksterne revisjoner
