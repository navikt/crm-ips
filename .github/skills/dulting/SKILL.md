---
name: dulting
description: "Dulting (nudging) i Nav-tjenester — utforsk muligheter, design intervensjoner og prototype med EAST, Fogg og FORGOOD-etikk. Brukes via /dulting ved utforsking av dulting-muligheter eller design av atferdsintervensjoner."
---

# Dulting — atferdsdesign for Nav-tjenester

Hjelper med å utforske, designe og teste dulting (nudging) i Nav-tjenester gjennom guidet dialog. Bygger på EAST, Fogg, FORGOOD og Nav-spesifikke guardrails.

## Når brukes denne?

- Utforsker en brukerreise for dulting-muligheter
- Designer varsler, påminnelser, defaults eller motiverende tekst
- Vil redusere friksjon eller øke gjennomføring av ønsket handling
- Skisserer eller prototyper en dulte-idé

## Prosess

Still spørsmål **ett om gangen**. Bruk flervalg der mulig.

### Steg 0: Er dette et dulte-problem?

Før du foreslår dulting, avklar om problemet faktisk bør løses med atferdspåvirkning:

> Hva hindrer brukeren i dag?
> A) Vet ikke at de skal gjøre noe (manglende prompt)
> B) Vet det, men det er for vanskelig/kronglete (friksjon/sludge)
> C) Vet det, men er ikke motivert nok (motivasjon)
> D) Forstår ikke regelverket eller konsekvensene (informasjon/tillit)
> E) Usikker — jeg vil utforske brukerreisen

**Hvis B:** Fjern friksjon/sludge først — det er ikke dulting, det er bedre tjenestedesign.
**Hvis D:** Forbedre informasjon og språk — bruk `/klarsprak`.
**Hvis A, C eller E:** Fortsett til neste steg.

### Steg 1: Forstå kontekst

Spør om:
1. Hvilken brukerreise eller flate gjelder det?
2. Hvilken konkret handling vil du ha mer av? (Formuler: *Når X skjer, skal bruker Y gjøre Z*)
3. Hva skjer i dag? Hvor stopper det opp?
4. Er handlingen frivillig, pliktig eller rettighetskritisk?

### Steg 2: Diagnostiser barriere

Bruk Fogg (B = MAP) for å finne hovedbarrieren:

| Faktor | Tegn | Tiltak |
|--------|------|--------|
| **Motivasjon** | Brukeren kan, men gidder ikke / ser ikke poenget | Vis konsekvens, gevinst, sosial norm |
| **Evne** | Brukeren vil, men det er for vanskelig | Forenkling, defaults, stegvis avsløring |
| **Prompt** | Brukeren vil og kan, men glemmer / ser ikke | Riktig tidspunkt, synlig CTA, påminnelse |

Spør: *Tror du hovedbarrieren er motivasjon, evne eller prompt?*

### Steg 3: Fjern sludge først

Før sterkere dulting, kartlegg unødvendig friksjon i reisen:
- Unødvendige klikk, bekreftelser, omveier?
- Dokumentkrav som kunne vært forhåndsutfylt?
- Informasjon som forvirrer mer enn den hjelper?

Fjern sludge før du legger på dulting.

### Steg 4: Design dultehypotese

Foreslå **2-3 intervensjoner** med ulik styrke. Se [REFERENCE.md](REFERENCE.md) for teknikkatalog.

For hver: beskriv teknikk, plassering i flyten, og forventet effekt.

### Steg 5: FORGOOD-vurdering

Kjør rask etikksjekk (alle 7 dimensjoner). Se [REFERENCE.md](REFERENCE.md) for detaljer.

| Dimensjon | Spørsmål |
|-----------|----------|
| Fairness | Rammer noen grupper urettferdig? |
| Openness | Er dultingen synlig og forklarbar? |
| Respect | Respekteres autonomi og verdighet? |
| Goals | Er målet i brukerens interesse? |
| Opinions | Ville brukerne akseptere dette? |
| Options | Bevares reell valgfrihet? |
| Delegation | Er det riktig instans som dulter? |

### Steg 6: Produser dulting brief

Lever et strukturert artefakt:

```markdown
## Dulting brief
- **Brukerreise:** [beskrivelse]
- **Ønsket atferd:** Når X, skal Y gjøre Z
- **Dagens atferd / baseline:** [hva skjer nå]
- **Barriere:** motivasjon / evne / prompt
- **Intervensjon:** [teknikk + plassering]
- **Risiko:** [FORGOOD-funn, sårbare grupper]
- **Måling:** [primærmetrikk + guardrail-metrikk]
- **Neste steg:** prototype / brukertest / A/B-test
```

### Steg 7: Prototype og test

- Bruk `/prototype` eller `@designer` for å visualisere
- Bruk `/aksel-design` for komponentvalg
- Bruk `/klarsprak` for mikrotekst
- A/B-test én endring om gangen. Mål effekt OG skadevirkninger.

## Stopp-regler

Bruk **ALDRI** disse teknikkene uten eksplisitt fag-/juridisk avklaring:
- Tapsframing mot brukere i akutt krise eller alvorlig sykdom
- Defaults som deler helse- eller personopplysninger
- Tidspress der konsekvensen er tap av rettigheter
- Sosiale normer basert på tall du ikke har kildebelagt

Foreslå ALDRI konkrete prosenttall eller statistikk i sosiale normer — brukeren må oppgi faktisk datagrunnlag.

## Referanser

Se [REFERENCE.md](REFERENCE.md) for teknikkatalog, FORGOOD-utdyping, sludge audit, måling og akademisk grunnlag.
