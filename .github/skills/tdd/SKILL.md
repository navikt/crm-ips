---
name: tdd
description: Test-driven development med red-green-refactor. Brukes ved feature-utvikling, bugfiks med tester først, eller når "red-green-refactor" nevnes.
---

# Testdrevet utvikling

## Filosofi

**Kjerneprinsipp**: Tester verifiserer atferd gjennom offentlige grensesnitt, ikke implementasjonsdetaljer. Koden kan endres totalt — testene skal overleve.

**Gode tester** tester gjennom offentlige API-er. De beskriver *hva* systemet gjør. "Bruker kan sende søknad med gyldig skjema" forteller nøyaktig hvilken funksjon som finnes. Disse testene overlever refaktoreringer fordi de ikke bryr seg om intern struktur.

**Dårlige tester** er koblet til implementasjon. De mocker interne samarbeidspartnere, tester private metoder, eller verifiserer gjennom eksterne mekanismer. Varseltegn: testen feiler ved refaktorering, men atferden er uendret.

## Anti-mønster: Horisontale skiver

**IKKE skriv alle tester først, deretter all implementasjon.** Det er å behandle RED som "skriv alle tester" og GREEN som "skriv all kode."

```
FEIL (horisontalt):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIKTIG (vertikalt):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

## Arbeidsflyt

### 1. Planlegg

- [ ] Avklar med bruker hvilke grensesnittendringer som trengs
- [ ] Avklar hvilke atferder som skal testes (prioriter)
- [ ] List atferdene som skal testes (ikke implementasjonssteg)
- [ ] Få brukerens godkjenning

Spør: "Hvilket grensesnitt skal vi eksponere? Hvilke atferder er viktigst å teste?"

### 2. Tracer bullet

Skriv ÉN test som bekrefter ÉN ting om systemet:

```
RED:   Skriv test → feiler
GREEN: Minimal kode for å bestå → bestått
```

### 3. Inkrementell loop

For hver gjenværende atferd:

```
RED:   Neste test → feiler
GREEN: Minimal kode → bestått
```

Regler:
- Én test om gangen
- Bare nok kode til å bestå gjeldende test
- Ikke forutse fremtidige tester
- Fokus på observerbar atferd

### 4. Refaktorer

Etter at alle tester består:
- [ ] Ekstraher duplisering
- [ ] Flytt kompleksitet bak enkle grensesnitt
- [ ] Kjør tester etter hvert refaktoreringssteg

**Aldri refaktorer mens RED.** Kom til GREEN først.

## Sjekkliste per syklus

```
[ ] Test beskriver atferd, ikke implementasjon
[ ] Test bruker kun offentlig grensesnitt
[ ] Test ville overlevd intern refaktorering
[ ] Kode er minimal for denne testen
[ ] Ingen spekulative funksjoner lagt til
```

## Mocking

- Mock ved systemgrenser (HTTP, database, filsystem), ikke mellom interne moduler
- Hvis du må mocke en intern samarbeidspartner, er modulgrensen feil
- Foretrekk dependency injection over monkey-patching
