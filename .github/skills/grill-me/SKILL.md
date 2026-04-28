---
name: grill-me
description: "Stress-testing av planer, løsninger og arkitekturbeslutninger — antagelser, kanttilfeller, skjulte avhengigheter, enklere alternativer og risiko. Brukes via /grill-me før beslutning tas."
---

# Grill Me — stress-test en idé

Grill utvikleren intensivt om alle sider ved en plan eller et design til dere har en felles forståelse. Gå ned hver gren i beslutningstreet og løs avhengigheter én for én.

## Når brukes denne?

- Utvikleren sier "grill meg", "utfordre dette", "er dette solid?"
- Før en stor implementasjon starter
- Etter en brainstorm, for å validere resultatet
- Når utvikleren er usikker på en arkitekturbeslutning

## Prosess

### 1. Forstå hva som grilles

Les planen, designet eller beskrivelsen grundig. Utforsk kodebasen for kontekst.

### 2. Still spørsmål én om gangen

For hvert spørsmål:
- Still spørsmålet
- Gi et **anbefalt svar** (slik at utvikleren kan si "ja, enig" eller "nei, fordi...")
- Vent på svar før neste spørsmål

### 3. Følg tråder

Når et svar avdekker usikkerhet:
- Grav dypere i den tråden
- Ikke gå videre til neste tema før dette er løst

### 4. Oppsummer

Når alle tråder er løst:
- List beslutningene som ble tatt
- List gjenstående risiko
- Anbefal neste steg

## Spørsmålskategorier

Gå gjennom disse i rekkefølge (hopp over det som er irrelevant):

1. **Omfang** — Er dette riktig avgrenset? Hva er utenfor?
2. **Alternativer** — Ble andre tilnærminger vurdert? Hvorfor ble dette valgt?
3. **Randtilfeller** — Hva skjer ved [uvanlig input/tilstand/feil]?
4. **Avhengigheter** — Hva forutsetter dette? Hva kan gå galt?
5. **Testing** — Hvordan vet vi at det fungerer? Hva er vanskelig å teste?
6. **Vedlikehold** — Hvem eier dette om 6 måneder? Er det forståelig?
7. **Sikkerhet** — Er det noen angrepsflater? PII? Tilgangskontroll?

## Regler

- **Vær direkte** — ikke pakk inn bekymringer
- **Gi anbefalinger** — ikke bare still spørsmål, foreslå svar
- **Utforsk kodebasen** — hvis et spørsmål kan besvares av koden, les koden i stedet for å spørre
- **Stopp når det er nok** — ikke grill for grillens skyld
