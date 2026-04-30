---
name: klarsprak
description: Klarsprak-skillen veileder klarspråk og språkvask av feilmeldinger, mikrotekst og AI-markører i norsk tekst. Brukes via /klarsprak når brukeren ber om klarspråk, språkvask, AI-markører, feilmeldinger eller mikrotekst.
---
# Klarspråk — norsk teknisk skriving

Retningslinjer for norsk bokmål i teknisk dokumentasjon, UI-tekst, PR-beskrivelser og blogginnlegg. Basert på Språkrådets klarspråk-prinsipper, ISO 24495-1, Digdirs klarspråk-veileder og Navs språkprofil. Språkloven pålegger offentlige organer klart, korrekt språk tilpassa mottakerne.

- **Kjernereglene auto-loades via `norwegian-text.instructions.md`. Denne skillen utdyper for spesifikke flater (mikrotekst, feilmeldinger, labels, PR-/blogg-tekst).**

## Når du skal bruke skillen

Bruk `/klarsprak` når du trenger målrettet språkvask utover kjernereglene:

- UI-tekst (knapper, labels, hjelpetekst, valideringstekst)
- Feilmeldinger (hva gikk galt + hva gjør brukeren nå)
- PR-beskrivelser, release-notes og bloggtekst
- Terminologivalg når norsk og engelsk blandes
- Eksempeltekster før/etter for opprydding av tone

## Fagtermer

### Alltid engelsk (ikke oversett)

image, cluster, node, container, deployment, release, plugin, backup, failover, rollback, upstream, downstream, secret, namespace, pod, CRD, PVC, PDB, pull request, merge, commit, branch, rebase, token.

Og disse — også alltid på engelsk:

edge case, bug, bugfix, hotfix, patch, roadmap, governance, community, middleware, pipeline, workflow, runtime, framework, endpoint, payload, scope.

### Norsk er OK for

feilsøking, oppgradering, sikkerhetskrav, vedlikehold, bidragsytere, brukervennlighet, tilgjengelighet, kodegjennomgang, avhengighet.

### Sammensatte ord med engelske termer

Bruk bindestrek: `image-bygg`, `CI-pipeline`, `deploy-steg`, `Kafka-topicet`, `GitHub-repoet`. Ikke særskriv: `Postgres operatoren` er feil.

## Anglisismer

Unødvendige anglisismer — bruk norsk:

| Anglisisme | Norsk alternativ |
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

## Teksttyper

| Teksttype | Tone | Tips |
|-----------|------|------|
| ADR | Nøytral, teknisk | Kontekst → Beslutning → Konsekvenser. Beslutning i presens, aktiv form. |
| README | Direkte, vennlig | Start med hva appen gjør, deretter oppsett. Ikke selg prosjektet. |
| Blogginnlegg | Personlig, konkret | Start med hva som er nytt, ikke historisk kontekst. "Vi" i aktiv form. Unngå AI-typisk "definere temaet"-innledning. |
| UI-tekst | Enkel, handlingsrettet | Korte setninger. Brukeren er "du". |
| PR-beskrivelse | Konkret | Hva endres, hvorfor. Se også `pull-request`-skillen. |

For commit-meldinger, se `conventional-commit`-skillen.

## UI-tekst

- **Knapper**: Korte, handlingsorienterte — "Lagre", "Send inn", "Avbryt".
- **Labels**: Beskriv hva brukeren skal skrive, ikke hva systemet vet.
- **Hjelpetekst**: Eksempel + formatkrav i samme linje når mulig.
- **Feilmeldinger**: Forklar problem + løsning i aktiv form.
- **Lenketekst**: Beskrivende, ikke "klikk her" eller "les mer".
- Norsk tallformat: mellomrom som tusenskilletegn ("151 354"), mellomrom før prosenttegn ("20 %").

### Feilmeldinger — mini-mal

Bruk dette mønsteret:

1. Hva gikk galt
2. Hva brukeren kan gjøre nå
3. Eventuelt hvor brukeren får hjelp

Eksempel:

```
❌ Ugyldig input.
✅ Vi fant ikke fødselsdatoen. Skriv dato på formatet DD.MM.ÅÅÅÅ.
```

## Før og etter

Se `references/for-og-etter.md` for fyldige eksempler: feiloversatt fagterm, stiv tone, PR-beskrivelse, README, UI-tekst, unødvendig oppsummering.

## Grenser

### ✅ Alltid
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
