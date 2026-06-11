## TypeScript

- Use Aksel Design System spacing tokens (`space-16`), never Tailwind `p-*`/`m-*`
- TypeScript strict mode — no `any` without justification
- Named imports from `@navikt/ds-react`, never `import *`

## Norwegian text (all `.md` and user-facing strings)

- Use Norwegian bokmål for user-facing text
- Avoid unnecessary anglicisms when good Norwegian alternatives exist

## Security

- No secrets, tokens, or credentials in code
- SQL queries must be parameterized
- GitHub Actions pinned to full SHA with version comment

## Over-editing

Flag changes where the diff is disproportionate to the stated goal:

- Renamed variables or parameters not related to the fix
- Restructured working code without justification
- Added refactoring outside the PR scope
