---
name: klarsprak
description: Norsk teknisk redaktør — klarspråk, AI-markører, anglismer, fagtermer, mikrotekst
---
# Klarspråk — norsk teknisk skriving

Retningslinjer for norsk bokmål i teknisk dokumentasjon, UI-tekst, PR-beskrivelser og blogginnlegg. Basert på Språkrådets klarspråk-prinsipper, ISO 24495-1, Digdirs klarspråk-veileder og Navs språkprofil. Språkloven pålegger offentlige organer klart, korrekt språk tilpassa mottakerne.

## Klarspråk

### Det viktigste først

Start med konklusjonen. Bakgrunn og kontekst kommer etterpå.

```
❌ Etter en grundig evaluering av flere alternativer, der vi vurderte
   både ytelse, driftskompleksitet og kostnad, har vi besluttet å
   gå videre med CNPG som Postgres-operator.

✅ Vi bruker CNPG som Postgres-operator. Den gir oss automatisk
   failover, backup og oppgradering uten nedetid.
```

### Unngå substantivsyke

```
❌ Vi foretar en gjennomgang av implementasjonen.
✅ Vi gjennomgår implementasjonen.

❌ Det er behov for en vurdering av sikkerhetsaspektene.
✅ Vi må vurdere sikkerheten.
```

### Kort over langt

- Kort setning over lang
- Vanlig ord over fancy ord
- Aktiv form over passiv ("vi bruker" ikke "det benyttes")
- Konkret over abstrakt
- Kutt fyllord: "i bunn og grunn", "i stor grad", "på mange måter"

### Struktur

- Korte avsnitt (2–4 setninger)
- Gode mellomtitler som sier hva seksjonen handler om
- Kulepunkter for lister
- Bare første ord og egennavn med stor bokstav i overskrifter

## AI-markører

Fjern mønstre som avslører KI-generert tekst. Fyldig liste og eksempler i `references/ai-markorer.md`.

### Svulstige ord — kort oversikt

| AI-markør | Gjør i stedet |
|-----------|---------------|
| "banebrytende", "revolusjonerende", "innovativ" | Konkrete beskrivelser |
| "robust", "helhetlig", "sømløs" | Skriv om eller dropp |
| "spiller en avgjørende rolle" | Gå rett på sak |
| "muliggjøre", "tilrettelegge for" | Si hva som skjer |
| "sikre at", "sørge for at" | "passe på", "gjøre" |
| "implementere" | "innføre", "ta i bruk", "lage" |
| "ivareta", "understøtte" | "ta vare på", "støtte" |

### Engelske AI-ord som siver inn i norsk

Disse engelske ordene brukes mye oftere i KI-generert norsk enn i naturlig norsk. Erstatt:

- **delve into** → fordype seg i (ofte: bare skriv innholdet)
- **leverage** → utnytte, bruke
- **landscape** → område, felt, markedet, situasjonen
- **navigate** → håndtere, forholde seg til
- **streamline** → effektivisere (si heller hva som blir enklere)
- **foster** → fremme (si heller hva du gjør konkret)
- **realm** → område, felt
- **underscore** → understreke (si heller poenget direkte)
- **crucial** → avgjørende (si heller hvorfor det er viktig)

### Tegnsetting som AI-markører

KI legger ofte inn fast tegnsetting som skiller teksten fra naturlig norsk. Rens bort.

- **Em-dash (—) i annethvert kulepunkt**: bruk sjelden. Varier med kolon, parentes eller omskriving.
- **Kolon i hver overskrift** (`Deploy: slik gjør vi det`): varier overskriftsform.
- **Overforbruk av semikolon**: i norsk teknisk tekst er semikolon sjelden naturlig. Del opp eller bruk punktum.
- **Utropstegn i teknisk tekst**: dropp.

### Åpninger, oppsummeringer og overgangsord

Kutt: "det er verdt å merke seg", "i dagens verden", "la oss dykke ned i", "oppsummert kan man si at", "avslutningsvis". Unngå "Videre", "I tillegg", "Dessuten" som paragrafåpner — bruk heller konkrete subjekter ("Teamet ...", "Koden ..."). Fjern oppsummeringssetninger som bare gjentar det du har skrevet. Varier grammatisk struktur i kulepunkter.

## Fagtermer

### Alltid engelsk (ikke oversett)

image, cluster, node, container, deployment, release, plugin, backup, failover, rollback, upstream, downstream, secret, namespace, pod, CRD, PVC, PDB, pull request, merge, commit, branch, rebase, token.

Og disse — også alltid på engelsk:

edge case, bug, bugfix, hotfix, patch, roadmap, governance, community, middleware, pipeline, workflow, runtime, framework, endpoint, payload, scope.

### Norsk er OK for

feilsøking, oppgradering, sikkerhetskrav, vedlikehold, bidragsytere, brukervennlighet, tilgjengelighet, kodegjennomgang, avhengighet.

### Sammensatte ord med engelske termer

Bruk bindestrek: `image-bygg`, `CI-pipeline`, `deploy-steg`, `Kafka-topicet`, `GitHub-repoet`. Ikke særskriv: `Postgres operatoren` er feil.

## Anglismer

Unødvendige anglismer — bruk norsk:

| Anglisme | Norsk alternativ |
|----------|-----------------|
| "adressere et problem" | "løse", "fikse", "ta tak i" |
| "på slutten av dagen" | "til syvende og sist", eller dropp |
| "ta eierskap til" | "ha ansvar for" |
| "delivere" | "levere" |
| "har du noen input?" | "har du innspill?" |
| "involvere" (overbrukt) | "ta med", "inkludere" |
| "deploye" | "rulle ut" |
| "shippe" | "levere", "sende ut" |
| "reviewe" | "gå gjennom", "se over" |
| "release" (som verb) | "gi ut", "rulle ut" |
| "onboarde" | "ta imot", "sette i gang" |
| "pitche" | "presentere", "foreslå" |
| "tracke" | "følge med på", "spore" |
| "booste" | "øke", "forbedre" |
| "aligne" | "samkjøre", "enes om" |
| "triage" | "prioritere", "sortere" |
| "være på samme side" | "være enige" |
| "i henhold til" (overbrukt) | "etter", "ifølge" |
| "per dags dato" | "nå", "i dag" |

## Nav-spesifikt

- **Nav** — ikke "NAV" (gammelt akronym) og ikke "nav"
- Konsekvent bokmål, ikke bland inn nynorsk
- Moderne, ledig bokmål: "framtid" over "fremtid"
- "vi" ikke "man" i interne dokumenter
- Skriv som om du forklarer til en kollega, ikke som en pressemelding

## Teksttyper

| Teksttype | Tone | Tips |
|-----------|------|------|
| ADR | Nøytral, teknisk | Kontekst → Beslutning → Konsekvenser. Beslutning i presens, aktiv form. |
| README | Direkte, vennlig | Start med hva appen gjør, deretter oppsett. Ikke selg prosjektet. |
| Blogginnlegg | Personlig, konkret | Start med hva som er nytt, ikke historisk kontekst. "Vi" i aktiv form. Unngå AI-typisk "definere temaet"-innledning. |
| UI-tekst | Enkel, handlingsrettet | Korte setninger. Brukeren er "du". |
| PR-beskrivelse | Konkret | Hva endres, hvorfor. Se også `pull-request`-skillen. |

For commit-meldinger, se `conventional-commit`-skillen.

## Tegnsetting

- **Bindestrek (-)**: Sammensatte ord: `API-kall`, `deploy-steg`, `CI-pipeline`
- **Tankestrek (–)**: Mellom verdier: `kl. 08–16`, `side 3–7`
- **Komma**: Sett komma før leddsetning som starter med "som", "fordi", "slik at", "når", "dersom"
- **Kolon**: Små bokstaver etter kolon med mindre det følger en hel setning

## UI-tekst

- **Knapper**: Korte, handlingsorienterte — "Lagre", "Send inn", "Avbryt"
- **Feilmeldinger**: Si hva som gikk galt og hva brukeren kan gjøre
- **Lenketekst**: Beskrivende, ikke "klikk her" eller "les mer"
- Norsk tallformat: mellomrom som tusenskilletegn ("151 354"), mellomrom før prosenttegn ("20 %")

## Før og etter

Se `references/for-og-etter.md` for fyldige eksempler: feiloversatt fagterm, stiv tone, PR-beskrivelse, README, UI-tekst, unødvendig oppsummering.

## Grenser

### ✅ Alltid
- Følg klarspråk-prinsippene: det viktigste først, aktiv form, konkret språk
- Behold etablerte engelske fagtermer
- Bindestrek i sammensatte ord med engelske termer
- Konsekvent formvalg gjennom hele teksten

### ⚠️ Spør først
- Endringer som kan påvirke faglig innhold
- Omstrukturering av hele dokumenter

### 🚫 Aldri
- Endre faglig innhold eller tekniske beslutninger
- Oversette etablerte engelske fagtermer til norsk
- Innføre nynorsk i bokmålstekster

## Kilder

- [Språkrådets klarspråk-prinsipper](https://sprakradet.no/Klarsprak/) og [KI-rapport](https://sprakradet.no/aktuelt/ki-sprakets-fallgruver/) (jan 2025)
- [ISO 24495-1](https://sprakradet.no/klarsprak/kunnskap-om-klarsprak/iso-standard-for-klarsprak/) — internasjonal klarspråk-standard
- [Digdirs klarspråk-veileder](https://www.digdir.no/klart-sprak/ny-veileder-om-klart-sprak-i-utvikling-av-digitale-tjenester/3603) — klarspråk i digitale tjenester
- [Designsystemets tekstpraksis](https://designsystemet.no/no/blog/shared-guidelines-for-text/) — UI-tekst
- [Termportalen](https://www.termportalen.no/) — norske faguttrykk (UiB/Språkrådet)
- Adam Tzur / AIavisen og Kommunikasjonsforeningen — norske AI-markører og crowdsourcede lister