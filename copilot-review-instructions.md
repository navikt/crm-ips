# Review av crm-ips

Les også `.github/instructions/copilot-review.instructions.md` for Navs felles review-prioritering.

- Sjekk om Salesforce-automatisering kolliderer med eksisterende Flows og triggere, særlig på `User`.
- Ved endringer i roller, ledere eller tilganger: vurder permission sets, deling og eksisterende rolleendrings-Flows.
- Se etter Mixed DML når en transaksjon endrer både `User` og ikke-setup-objekter.
- Sjekk at Apex er bulkifisert, og at Flows ikke gjør unødvendige oppdateringer.
- Ikke godta hardkodede Salesforce-ID-er eller logging av Nav-identer, personopplysninger og hemmeligheter.
- Kontroller at metadata og Apex er validert i en Salesforce-org; lokale npm-tester dekker bare deler av løsningen.
- Flagg endringer utenfor oppgavens scope.
- Bruk klarsprak skill for å vurdere og forbedre tekster i labels og beskrivelser 
