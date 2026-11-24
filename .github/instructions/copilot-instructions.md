# Copilot-instruksjoner for crm-ips

Jobbsporet er en Salesforce-applikasjon for Nav-veiledere som følger opp personer på vei inn i arbeid.
Endringer ligger hovedsakelig som Salesforce-metadata i `force-app/`, ikke som en Node.js-tjeneste.
Les `.github/instructions/salesforce-instructions.md` og relevante Salesforce-skills før du endrer metadata eller Apex.

## Teknologi

- Salesforce Flows, Apex, LWC, objekter og permission sets.
- `sfdx-project.json` beskriver pakkeavhengigheter og Salesforce API-versjon.
- Node.js og npm brukes til LWC/Aura-lint og LWC Jest. Se `package.json` for kommandoer.
- PR-validering bruker workflowen `.github/workflows/pull_request-validation1.yml`.

## Arbeidsmåte

- Hold diffen til oppgaven. Undersøk eksisterende Flow-automatisering før du legger til mer.
- Når `User` eller tilgang endres, kontroller permission sets, rollehierarki og tilknyttede Flows.
- Kjør relevante npm-kommandoer lokalt; Salesforce-metadata og Apex må også valideres i en org eller via PR-validering.
- Ikke logg personopplysninger, Nav-identer eller hemmeligheter.
