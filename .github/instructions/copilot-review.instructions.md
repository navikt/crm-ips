---
description: "Styrer hvordan Copilot Code Review prioriterer PR-funn med fokus på scope-disiplin, sikkerhet, tilgjengelighet, klarspråk og handlingsrettede kommentarer"
applyTo: "**"
---

# Copilot Code Review — Nav-retningslinjer

Disse instruksjonene brukes når GitHub Copilot Code Review aktiveres på PR-er i Nav-repoer.

Formålet er å gi korte, presise review-forslag med høy signalverdi.
Instruksjonen supplerer repo-spesifikke regler, men overstyrer dem ikke.

## Kjernesjekker

1. **Minimal editing og diff-disproporsjon**
   - Vurder om endringen holder seg til oppgavens scope.
   - Flagges som varsel når diffen rører ubeslektet kode eller virker ute av proporsjon med oppgaven.
   - Typiske tegn: store formatterings-sveip, fil-rename uten funksjonell grunn, refactor utenfor stated scope.

2. **Sikkerhet**
   - Sjekk at databasekall bruker parameteriserte queries.
   - Sjekk at secrets ikke ligger i kode, config, testdata eller logger.
   - Sjekk at personopplysninger (PII) ikke logges eller eksponeres unødvendig.
   - Ved tvil: foreslå manuell sikkerhetsgjennomgang via `/security-review`.

3. **Tilgjengelighet (frontend-PR-er)**
   - Sjekk tastaturnavigasjon, semantikk, fokusrekkefølge og meningsfulle labels.
   - Sjekk at feilmeldinger og validering er forståelige med skjermleser.
   - Sjekk kontrast og at interaktive elementer kan brukes uten mus.
   - Ved behov: foreslå gjennomgang via `/accessibility-review`.

4. **Klarspråk (brukerrettet tekst)**
   - Sjekk at labels, hjelpetekst, feilmeldinger og bekreftelser er tydelige og konkrete.
   - Unngå internsjargong i brukerflate-tekst.
   - Påpek uklare eller tvetydige formuleringer.
   - Ved behov: foreslå forbedring via `/klarsprak`.

## Avgrensning

- Denne filen beskriver kun kjernesjekker for Copilot Code Review.
- Dype arkitektur- og domenereviews håndteres av egne agenter og skills.
- Reviewkommentarer skal være handlingsrettede, med tydelig risiko og anbefalt endring.

## Prioritering i kommentarer

1. Korrekthet og sikkerhet
2. Brukerpåvirkning (tilgjengelighet og språk)
3. Vedlikeholdbarhet og scope-disiplin

## Kommentarstil

- Kommentaren bør vise *hva* som er problemet, *hvorfor* det betyr noe, og *hva* som bør endres.
- Unngå lange avsporinger; hold fokus på observerbar risiko i PR-en.
- Unngå duplikater når samme funn gjelder flere steder; samle i ett tydelig punkt.

Hvis ingen konkrete funn finnes, bør reviewen være kort og bekrefte at endringen ser konsistent ut med repoets mønstre.
