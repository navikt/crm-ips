---
description: "Universell utforming (UU) — WCAG 2.1 AA med Aksel-komponenter for Nav-frontend"
applyTo: "**/*.tsx, **/*.jsx"
---

# Tilgjengelighet (UU) — WCAG 2.1 AA

Universell utforming er lovpålagt i Norge. All frontend-kode i Nav skal oppfylle WCAG 2.1 AA.

## Aksel-komponenter har innebygd UU

Aksel-komponenter (`@navikt/ds-react`) håndterer mange tilgjengelighetskrav automatisk: roller, ARIA-attributter, tastaturnavigasjon, fokushåndtering og fargekontrast.

**Bruk alltid Aksel-komponenter fremfor egne `<div>`/`<button>`-løsninger.**

## Semantisk HTML

Bruk `<main>`, `<nav>`, `<article>`, `<section>` — ikke generiske `<div>`-er.

```tsx
// ✅ Semantiske elementer
<main>
  <nav aria-label="Hovednavigasjon">...</nav>
  <article>
    <Heading size="large" level="1">Tittel</Heading>
    <section aria-labelledby="seksjon-id">...</section>
  </article>
</main>

// ❌ Div-suppe uten semantikk
<div className="main">
  <div className="nav">...</div>
  <div className="content">
    <div className="title">Tittel</div>
  </div>
</div>
```

## Heading-hierarki

Overskriftsnivåer skal være logiske og uten hopp (h1 → h2 → h3).

```tsx
// ✅ Sammenhengende nivåer
<Heading size="large" level="1">Sidetittel</Heading>
  <Heading size="medium" level="2">Seksjon</Heading>
    <Heading size="small" level="3">Underseksjon</Heading>

// ❌ Hopper fra h1 til h3
<Heading size="large" level="1">Sidetittel</Heading>
  <Heading size="small" level="3">Underseksjon</Heading>
```

## Skjemaer

Bruk Aksel-skjemaelementer (`TextField`, `Select`) — de har innebygd label-kobling. Vis `ErrorSummary` øverst ved feil.

```tsx
import { TextField, Select, ErrorSummary } from "@navikt/ds-react";

// ✅ Aksel-skjemaelementer har innebygd label-kobling
<TextField
  label="Fødselsnummer"
  description="11 siffer"
  error={errors.fnr}
  autoComplete="off"
/>

// ✅ Feiloppsummering øverst i skjemaet
<ErrorSummary heading="Du må rette disse feilene før du kan sende inn">
  <ErrorSummary.Item href="#fnr">Fødselsnummer er påkrevd</ErrorSummary.Item>
</ErrorSummary>
```

## Bilder og ikoner

Meningsbærende bilder trenger beskrivende `alt`-tekst, dekorative bilder får `alt=""`. Ikonknapper må ha tilgjengelig navn via `title`-prop.

```tsx
// ✅ Meningsbærende bilder
<img src="/chart.png" alt="Bruksstatistikk siste 30 dager: 450 aktive brukere" />

// ✅ Dekorative bilder
<img src="/decoration.svg" alt="" />

// ✅ Ikoner med mening
<Button variant="tertiary" icon={<TrashIcon title="Slett element" />} />

// ❌ Ikonknapp uten tilgjengelig navn
<Button variant="tertiary" icon={<TrashIcon />} />
```

## Interaktive elementer

Alle klikkbare elementer trenger synlig fokusindikator og tilgjengelig navn. Bruk beskrivende lenketekst, aldri "Klikk her".

```tsx
// ✅ Synlig fokusindikator, tilgjengelig navn
<Button variant="primary">Send inn</Button>

// ✅ Lenkebeskrivelse med kontekst
<Link href={`/sak/${id}`}>Se detaljer for sak {saksnummer}</Link>

// ❌ Generisk lenketekst
<Link href={`/sak/${id}`}>Klikk her</Link>

// ❌ onClick på div uten rolle/keyboard
<div onClick={handleClick}>Klikk meg</div>
```

## ARIA-attributter

Bruk kun ARIA når HTML-semantikk ikke er tilstrekkelig:

```tsx
// ✅ Navigasjonslandemerker
<nav aria-label="Brødsmulesti">...</nav>

// ✅ Live-regioner for dynamisk innhold (Aksel håndterer ARIA automatisk)
<LocalAlert variant="success">
  <LocalAlert.Content>Skjemaet ble sendt inn</LocalAlert.Content>
</LocalAlert>

// ✅ Expanding/collapsing
<Button aria-expanded={isOpen} aria-controls="panel-id" onClick={() => setIsOpen(!isOpen)}>
  Vis detaljer
</Button>

// ✅ Loading-tilstander
<div aria-busy={isLoading} aria-live="polite">
  {isLoading ? <Loader title="Laster" /> : <DataTable data={data} />}
</div>
```

## Modal med fokusfelle

```tsx
// ✅ Fokusfelle i modal — Aksel Modal håndterer dette
<Modal open={isOpen} onClose={() => setIsOpen(false)} header={{ heading: "Bekreft sletting" }}>
  <Modal.Body>Er du sikker?</Modal.Body>
  <Modal.Footer>
    <Button onClick={handleDelete}>Slett</Button>
    <Button variant="secondary" onClick={() => setIsOpen(false)}>Avbryt</Button>
  </Modal.Footer>
</Modal>
```

## Fargekontrast

- **Tekst**: Minimum 4.5:1 (AA)
- **Stor tekst** (>=18px bold / >=24px): Minimum 3:1
- **Ikke-tekst UI**: Minimum 3:1
- Bruk Aksel semantiske farger — de oppfyller kontrastkrav automatisk
- Aldri bruk farge alene for å formidle informasjon

## Tastaturnavigasjon

- `Tab` / `Shift+Tab`: Naviger mellom elementer
- `Enter` / `Space`: Aktiver knapper og lenker
- `Escape`: Lukk modaler og menyer
- `Arrow keys`: Naviger i lister, tabs og menyer

Aksel Modal håndterer fokusfelle automatisk.

## Testing

Bruk `jest-axe` for enhetstesting, Playwright + `@axe-core/playwright` for E2E, og Lighthouse CLI for CI-sjekker.

```tsx
// jest-axe (enhetstest)
import { axe, toHaveNoViolations } from "jest-axe";
expect.extend(toHaveNoViolations);

it("should have no accessibility violations", async () => {
  const { container } = render(<MyComponent />);
  expect(await axe(container)).toHaveNoViolations();
});
```

```tsx
// Playwright + axe-core (E2E)
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("side har ingen tilgjengelighetsfeil", async ({ page }) => {
  await page.goto("/skjema");
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Sjekkliste

- Heading-nivåer er logiske (h1 → h2 → h3, ingen hopp)
- Alle skjema-elementer har synlige labels
- Alle bilder har meningsfull `alt`-tekst eller `alt=""`
- Alle interaktive elementer har tilgjengelig navn
- Ingen informasjon formidles kun med farge
- Siden er fullt brukbar med kun tastatur
- Dynamisk innhold annonseres med `aria-live`
- Feilmeldinger er koblet til rett felt og samlet i en oppsummering

## Grenser

### Alltid
- Bruk Aksel-komponenter — de har innebygd tilgjengelighet
- Test med tastatur (Tab gjennom hele siden)
- Sjekk heading-hierarki

### Spør først
- Egendefinerte ARIA-roller utover standard HTML-semantikk
- Avvik fra Aksel-mønster for tilgjengelighet

### Aldri
- `<div onClick>` uten `role="button"` og `tabIndex`
- Ikonknapper uten tilgjengelig navn
- Fjern fokusindikator (`outline: none`) uten erstatning
