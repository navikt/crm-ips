# crm-ips

Jobbsporet is a Salesforce application for Nav caseworkers supporting employment follow-up.
Most application code is Salesforce metadata in `force-app/`: Flows, Apex, objects, permission sets and LWC.
Read `.github/instructions/salesforce-instructions.md` before changing Salesforce components.

## Build and test

```bash
npm run lint        # LWC and Aura lint
npm run test:unit   # LWC Jest
npm test            # Lint and LWC Jest
```

Salesforce metadata validation and Apex tests run in the PR validation workflow. `npm run build`
is a Windows scratch-org setup script, not a production build.

## Project structure

- `force-app/main/default/`: Salesforce metadata, including Flow, Apex, permissions and LWC.
- `force-app/`: package source and additional feature directories.
- `sfdx-project.json`: Salesforce package dependencies and API version.
- `.github/workflows/`: PR validation and deployment workflows.

## Working conventions

- Keep changes limited to the requested behavior and dependent metadata.
- Follow existing Salesforce automation; check related Flows before adding a new trigger or Flow.
- Review permission sets, sharing and existing User-role automation when changing access.
- Do not log personal data, Nav identifiers or credentials.
- Do not hardcode Salesforce IDs or credentials.
