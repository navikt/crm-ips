---
description: "Nav-spesifikke frontend-standarder — TypeScript, Aksel, auth, lokalisering"
applyTo: "**/*.{ts,tsx,js,jsx}"
---

# Frontend — Nav-spesifikke standarder

- **TypeScript**, ikke JavaScript. Strict mode påslått.
- **Rammeverk**: Følg mønsteret i repoet — Next.js (`app/`-struktur), Vite/React (`src/main.tsx`), eller andre. Data-henting (server components, route handlers, klient-side) varierer — bruk det som allerede finnes i repoet.
- **Aksel som standard**: Foretrekk `@navikt/ds-react`-komponenter når tilsvarende finnes.
  → *Se `aksel-design`-skill for mønstre og do/don'ts.*
- **Spacing og tokens**: Foretrekk Aksel-tokens (`space-*`, farge-tokens) når mulig. Tailwind eller egne verdier kan brukes der Aksel ikke dekker behovet, eller der repoet allerede bruker det konsistent.
- **Autentisering**: Nav-frontend bruker typisk `@navikt/oasis` for TokenX/AzureAD på server-side og klient-side.
  → *Se `auth-overview`-skill.*
- **Lokalisering**: Tall og datoer med `nb-NO`. Tekst: norsk eller engelsk konsistent per repo.
- **Surveys og spørreskjema**: For innebygde tilbakemeldinger, bruk `@navikt/lumi-survey`.
  → *Se `lumi-survey`-skill.*
- **Testing**: Vitest eller Jest (etter hva repoet bruker) + Testing Library. Ikke test Aksel-komponenter — de er testet upstream.

## Progressive disclosure
Denne instruksjonen er lean med vilje. For detaljerte mønstre, åpne de refererte skillsene når oppgaven faktisk krever det.
