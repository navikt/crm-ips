---
name: accessibility-review
description: "UU/WCAG-review for Nav-frontend — tastaturflyt, skjermleser, axe, kontrast, fokus, feilmeldinger, skjema og Aksel-bruk. Brukes via /accessibility-review før PR eller release."
---
# Tilgjengelighet-review

Review-prosess for universell utforming (UU) i Nav-flater. Universell utforming av ikt er lovpålagt for offentlig sektor gjennom **Likestillings- og diskrimineringsloven §17** og **Forskrift om universell utforming av ikt-løsninger**, med **WCAG 2.1 nivå A og AA** som forskriftskravet per i dag. **WCAG 2.2 AA** er fremoverlent praksis der relevant (nye suksesskriterier som 2.4.11 Focus Not Obscured er enkle å etterleve med Aksel). Verifiser alltid gjeldende krav mot **Tilsynet for universell utforming av ikt** (uutilsynet.no), som kan revidere løsningene våre og gi pålegg.

## Avgrensning mot `accessibility.instructions.md`

Denne skillen er for review-arbeid; instructions auto-injiseres under koding. Skillen gjentar IKKE instruction-innholdet, men bygger videre på det med review-prosess og Nav-spesifikke heuristikker.

Når du koder nytt: la instructions styre. Når du skal gjennomgå en branch, flate eller ekstern leveranse før produksjon: bruk denne skillen.

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
