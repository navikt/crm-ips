# Før og etter

Eksempler på typisk redigering fra AI-tung eller stiv tekst til klarspråk.

## AI-språk → rett på sak

```
❌ Det er viktig å påpeke at Kubernetes representerer et betydelig skritt
   fremover innen container-orkestrering, og spiller en avgjørende rolle
   i moderne skyinfrastruktur.

✅ Kubernetes orkestrerer containere. Vi bruker det til å kjøre og
   skalere appene våre i clusteret.
```

## Substantivsyke → verb

```
❌ Gjennomføring av en evaluering av ytelseskarakteristikkene til
   de ulike databasealternativene er nødvendig.

✅ Vi må teste ytelsen til de ulike databasene.
```

## Feiloversatt fagterm → behold engelsk

```
❌ Vi må rulle tilbake avbildet og opprette en ny hemmelighet
   i navnerommet.

✅ Vi må gjøre rollback på imaget og opprette en ny secret
   i namespacet.
```

```
❌ Vi fant en grensetilfelle i utrullingsflyten som krever en
   hastefiks i produksjonsmiljøet.

✅ Vi fant en edge case i deploy-flyten som krever en hotfix
   i prod.
```

## Anglisme → naturlig norsk

```
❌ Vi må adressere dette problemet og ta eierskap til prosessen
   for å levere en løsning som er på linje med forventningene.

✅ Vi må fikse dette. Teamet har ansvar for å finne en løsning.
```

## For stiv tone → kollegial

```
❌ Det benyttes en hendelsesdrevet arkitektur der meldinger
   publiseres til en meldingskø for videre prosessering.

✅ Vi bruker en eventdrevet arkitektur. Meldinger publiseres til
   Kafka og plukkes opp av konsumentene.
```

## UI-tekst → klarspråk

```
❌ Operasjonen kunne ikke gjennomføres grunnet manglende
   obligatoriske feltverdier i skjemaet.

✅ Du må fylle ut alle påkrevde felt før du kan sende inn.
```

```
❌ <Button>Klikk her for å navigere til oversikten</Button>

✅ <Button>Gå til oversikten</Button>
```

## README → rett på sak

```
❌ Dette prosjektet representerer et innovativt verktøy som
   muliggjør effektiv håndtering av søknader. Det er utviklet
   med tanke på å sette brukeren i sentrum.

✅ Behandler søknader om foreldrepenger. Bygget med Kotlin/Ktor,
   deployes til Nais.
```

## PR-beskrivelse → konkret

```
❌ Denne PR-en adresserer behovet for å implementere en mer
   robust og helhetlig løsning for autentisering som
   tilrettelegger for en sømløs brukeropplevelse.

✅ Bytter fra manuell token-validering til @navikt/oasis.
   Forenkler auth-flyten og fikser bug der utløpte tokens
   ikke ble refreshet.
```

## Unødvendig oppsummering → kutt

```
❌ Vi har nå gjennomgått de ulike aspektene ved migrasjonen.
   Som vi har sett, er det flere viktige hensyn å ta. Oppsummert
   kan man si at en vellykket migrering krever grundig planlegging.

✅ (Kutt hele avsnittet. Leseren har allerede lest det du oppsummerer.)
```