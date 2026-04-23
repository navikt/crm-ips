---
name: create-a-skill
description: Opprett nye agent-skills med riktig struktur, progressiv disclosure og medfølgende ressurser. Brukes når bruker vil lage, skrive eller bygge en ny skill.
---

# Lage skills

## Prosess

1. **Samle krav** — spør brukeren om:
   - Hvilken oppgave/domene dekker skillen?
   - Hvilke bruksscenarier skal den håndtere?
   - Trenger den kjørbare skript eller kun instruksjoner?
   - Finnes det referansemateriale som skal inkluderes?

2. **Skriv utkast** — opprett:
   - SKILL.md med konsise instruksjoner (maks ~100 linjer)
   - Referansefiler for utfyllende innhold
   - Verktøyskript hvis det trengs deterministiske operasjoner

3. **Gjennomgå med brukeren** — presenter utkastet og spør:
   - Dekker dette bruksscenarier dine?
   - Mangler noe, eller er noe uklart?
   - Bør noen seksjoner være mer/mindre detaljerte?

## Filstruktur

```
skill-navn/
├── SKILL.md           # Hovedinstruksjoner (påkrevd)
├── REFERENCE.md       # Utfyllende dokumentasjon (ved behov)
├── EXAMPLES.md        # Brukseksempler (ved behov)
└── scripts/           # Verktøyskript (ved behov)
    └── helper.js
```

## SKILL.md-mal

```md
---
name: skill-navn
description: Kort beskrivelse av kapabiliteten. Brukes når [spesifikke triggere].
---

# Skill-navn

## Hurtigstart

[Minimalt fungerende eksempel]

## Arbeidsflyter

[Steg-for-steg-prosesser med sjekklister for komplekse oppgaver]

## Referanser

[Lenke til separate filer: Se [REFERENCE.md](REFERENCE.md)]
```

## Krav til description

Beskrivelsen er **det eneste agenten ser** når den avgjør hvilken skill som skal lastes. Den vises i systemprompten sammen med alle andre installerte skills. Agenten leser beskrivelsene og velger riktig skill basert på brukerens forespørsel.

**Mål**: Gi agenten akkurat nok info til å vite:

1. Hvilken kapabilitet skillen gir
2. Når/hvorfor den skal aktiveres (spesifikke nøkkelord, kontekster, filtyper)

**Format**:

- Maks 1024 tegn
- Skriv i tredjeperson
- Første setning: hva den gjør
- Andre setning: «Brukes når [spesifikke triggere]»

```
# ✅ God beskrivelse
Opprett og administrer Kafka-topics, consumers og producers i Nav.
Brukes når bruker jobber med Kafka, meldingskøer eller event-strømmer.

# ❌ Dårlig beskrivelse
Hjelper med meldinger.
```

Den dårlige beskrivelsen gir agenten ingen mulighet til å skille skillen fra andre.

## Når du bør legge til skript

Legg til verktøyskript når:

- Operasjonen er deterministisk (validering, formatering)
- Samme kode ville blitt generert gjentatte ganger
- Feil krever eksplisitt håndtering

Skript sparer tokens og gir bedre pålitelighet enn generert kode.

## Når du bør dele opp i filer

Del opp i separate filer når:

- SKILL.md overskrider 100 linjer
- Innholdet har distinkte domener (ulike skjemaer, ulike kontekster)

## Lean-filter

Alt innhold skal bestå lean-filteret:

1. **Kan modellen dette fra før?** Dropp generell syntax, velkjente mønstre og standardbibliotek-kunnskap.
2. **Lærer det å jobbe i Nav, eller styrker det agenten?** Behold Nav-spesifikke mønstre, plattformkunnskap og teamkonvensjoner.

Drop hvis ja på 1 og nei på 2.

## Grenser

### Alltid
- Skriv innholdet på norsk hvis repoet forventer norsk

### Spør først
- Om skillen overlapper med en eksisterende skill

### Aldri
- Dupliser ren LLM-allmennkunnskap uten Nav- eller repo-verdi

## Sjekkliste

Etter utkastet, verifiser:

- [ ] Beskrivelsen inkluderer triggere («Brukes når ...»)
- [ ] SKILL.md under 100 linjer (eller splittet i referansefiler)
- [ ] Ingen tidssensitiv informasjon
- [ ] Konsekvent terminologi
- [ ] Konkrete eksempler inkludert
- [ ] Referanser maks ett nivå dypt
- [ ] Bestått lean-filteret
