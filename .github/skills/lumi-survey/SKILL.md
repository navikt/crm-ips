---
name: lumi-survey
description: Integrer @navikt/lumi-survey tilbakemeldingswidget i en Nav-frontendapplikasjon
---

# Lumi Survey-integrasjon

Legg til en Lumi Survey-widget i applikasjonen din. Dekker installasjon, survey-konfigurasjon, backend-transportendepunkt og NAIS-oppsett.

## Fase 1: Kartlegging

Før du gjør endringer, kartlegg eksisterende oppsett:

1. Sjekk `package.json` for eksisterende avhengigheter — er `@navikt/ds-react` og `@navikt/ds-css` installert?
2. Verifiser at appen bruker **Aksel v8+** (`@navikt/ds-react` ≥ 8.0.0). Lumi Survey krever v8. Hvis appen er på v7 eller lavere, må Aksel oppgraderes først — det er utenfor scope for denne skillen.
3. Finn appens rammeverk — Next.js, TanStack Start, Remix, Vite SPA, eller annet
4. Les NAIS-manifest(er) for auth-konfig (`tokenx`, `azure.application`) og `accessPolicy`
5. Søk etter eksisterende `@navikt/lumi-survey`-bruk (`grep -r "lumi-survey" --include="*.ts" --include="*.tsx"`)
6. Finn appens entry point der globale stiler importeres (f.eks. `_app.tsx`, `layout.tsx`, `main.tsx`, `root.tsx`)
7. Sjekk om appen har et BFF/backend-for-frontend-lag, eller om det er en ren SPA som proxyer gjennom en backend

### Kartleggingsresultat

Etter kartleggingen bør du ha svar på disse — de styrer resten av integrasjonen:

| Funn | Brukes i |
|------|----------|
| **Aksel-versjon** (v8+ = ok, lavere = stopp) | Gate — ikke fortsett uten v8 |
| **Rammeverk** (Next.js / TanStack Start / Remix / etc.) | Fase 3c (stil-import), Fase 5 (backend-mønster) |
| **Auth-type** (TokenX / AzureAD / begge / ingen) | Fase 2 (auto-deteksjon), Fase 5 (endepunkt), Fase 6 (NAIS-konfig) |
| **Stil-entry point** (filnavn) | Fase 3c (der stiler importeres) |
| **Backend-type** (Node.js BFF / Kotlin BFF / annet) | Fase 5 (hvilken mal som brukes) |
| **Eksisterende lumi-survey?** | Hvis ja → tilpass eksisterende, ikke ny integrasjon |

Bruk disse funnene aktivt i de neste fasene — de bestemmer hvilke maler og konfigurasjoner som genereres.

## Fase 2: Kravinnhenting

Før du genererer kode, avklar det som trengs. Bruk kartleggingen fra Fase 1 til å besvare så mye som mulig automatisk — spør bare utvikleren om det du ikke kan utlede.

### Autentisering (detekter automatisk)

Les NAIS-manifestet fra Fase 1 og bestem auth-type:

| Funn i manifest | Auth-type | Audience-format |
|-----------------|-----------|-----------------|
| `tokenx.enabled: true` | **TokenX** | `<cluster>:team-esyfo:lumi-api` |
| `azure.application.enabled: true` | **AzureAD** | `api://<cluster>.team-esyfo.lumi-api/.default` |
| Begge er aktivert | Avhenger av brukergruppe — spør utvikleren | Se over |
| Ingen av delene | Auth mangler — spør utvikleren om oppsett | — |

Hvis auth-type er entydig, **ikke spør** — informer utvikleren om hva du fant: *"Jeg ser at appen bruker TokenX. Bruker det for Lumi-integrasjonen."*

Spør kun hvis det er tvetydig eller mangler.

### Spørsmål 1: Type undersøkelse

Spør: *"Hva slags tilbakemelding vil du samle inn?"*

Presenter alternativer med anbefalinger:

| Type | Passer best for | Anbefaling |
|------|-----------------|------------|
| **Rating** (emoji 😡🙁😐😀😍) | Generell tilfredshet — "hvordan var opplevelsen?" | ✅ **Anbefalt standard.** Enkel, høy fullføringsrate. |
| **Rating** (tommel 👎👍) | Rask binær tilbakemelding på en spesifikk funksjon | Bra for målrettet, lavterskel feedback |
| **Discovery** | Forstå brukermål — "hva prøvde du å gjøre?" | Best for nye tjenester eller store redesign |
| **Top Tasks** | Måle oppgavesuksess/-feilrate (McGovern-metoden) | Best for etablerte tjenester med kjente brukeroppgaver |
| **Task Priority** | Rangere hva som betyr mest for brukerne (Long Neck-metoden) | Best for veikartprioritering |
| **Tilpasset** | Skreddersydde spørsmålsflyter med forgreningslogikk | Kun når forhåndsdefinerte typer ikke passer |

Hvis utvikleren er usikker, anbefal **Rating med emoji-variant** — det er det mest utprøvde mønsteret i Nav.

### Spørsmål 2: Oppfølgingsspørsmål (kun for Rating)

Hvis utvikleren valgte en rating-survey, spør: *"Vil du ha et oppfølgingsspørsmål ved lav score? (anbefalt: ja — fritekstfelt ved score ≤ 2)"*

Anbefaling: Ja — fritekst ved lav rating gir handlingsbar innsikt med minimal brukerbelastning. `DEFAULT_SURVEY_RATING` har dette innebygd.

For andre survey-typer (Discovery, Top Tasks, etc.) har de innebygde oppfølgingsspørsmål allerede — ikke spør.

## Fase 3: Installasjon

### 3a. Konfigurer GitHub Packages-registry

Sjekk om `.npmrc` allerede har GitHub Packages-konfig. Hvis ikke:

```
@navikt:registry=https://npm.pkg.github.com
```

### 3b. Installer pakken

```bash
npm install @navikt/lumi-survey
```

Peer-avhengigheter (`@navikt/ds-react`, `@navikt/ds-css`) er vanligvis allerede installert i Nav-apper. Hvis ikke:

```bash
npm install @navikt/ds-react @navikt/ds-css
```

### 3c. Importer stiler

I appens globale stil-entry point (identifisert i Fase 1), sørg for denne importrekkefølgen:

```tsx
import "@navikt/ds-css";                  // Må komme først
import "@navikt/lumi-survey/styles.css";  // Deretter lumi-survey
```

**Viktig**: `@navikt/ds-css` MÅ importeres før `@navikt/lumi-survey/styles.css`.
## Fase 4: Survey-komponent

### 4a. Opprett survey-konfigurasjon

Lag en egen fil for survey-konfigurasjonen (f.eks. `survey.ts` eller `lumiSurvey.ts`). Bruk `satisfies LumiSurveyConfig` for typesikkerhet.

Guiding: Basert på survey-typen valgt i Fase 2, hjelp utvikleren med å bygge opp konfigurasjonen steg for steg. Tilpass spørsmålstekster til tjenesten — bruk norsk og vær konkret.

#### Rating-survey

```tsx
import type { LumiSurveyConfig } from "@navikt/lumi-survey";

export const survey = {
  type: "rating",
  questions: [
    {
      id: "inntrykk",
      type: "rating",
      variant: "emoji",       // "emoji" | "thumbs" | "stars" | "nps"
      prompt: "Hva er ditt inntrykk av tjenesten?",
      required: true,
    },
    {
      id: "innspill",
      type: "text",
      prompt: "Har du noen kommentarer eller innspill?",
      maxLength: 1000,
      visibleIf: {
        field: "ANSWER",
        questionId: "inntrykk",
        operator: "EXISTS",
      },
    },
  ],
} satisfies LumiSurveyConfig;
```

Tilpass til tjenesten:
- Endre `prompt`-tekster til noe som passer appen (f.eks. *"Hvordan var det å søke om sykepenger?"*)
- Juster `visibleIf` — vis oppfølging kun ved lav score (`operator: "LT", value: 3`) eller alltid (`operator: "EXISTS"`)
- Legg til flere spørsmål ved behov (se spørsmålstyper under)

#### Discovery-survey

```tsx
import type { LumiSurveyConfig } from "@navikt/lumi-survey";

export const survey = {
  type: "discovery",
  questions: [
    {
      id: "oppgave",
      type: "text",
      prompt: "Hva prøvde du å gjøre i dag?",
      maxLength: 500,
      required: true,
    },
    {
      id: "fullfort",
      type: "singleChoice",
      prompt: "Fikk du gjort det du kom for?",
      options: [
        { value: "ja", label: "Ja" },
        { value: "delvis", label: "Delvis" },
        { value: "nei", label: "Nei" },
      ],
      required: true,
    },
    {
      id: "blokkering",
      type: "text",
      prompt: "Hva hindret deg?",
      maxLength: 1000,
      visibleIf: {
        field: "ANSWER",
        questionId: "fullfort",
        operator: "EQ",
        value: "nei",
      },
    },
  ],
} satisfies LumiSurveyConfig;
```

#### Top Tasks-survey

```tsx
import type { LumiSurveyConfig } from "@navikt/lumi-survey";

export const survey = {
  type: "topTasks",
  questions: [
    {
      id: "oppgave",
      type: "singleChoice",
      prompt: "Hva kom du hit for å gjøre?",
      options: [
        { value: "soke", label: "Søke om ytelse" },
        { value: "status", label: "Sjekke status på søknad" },
        { value: "dokument", label: "Sende inn dokumentasjon" },
        { value: "annet", label: "Annet" },
      ],
      randomize: true,
      required: true,
    },
    {
      id: "fullfort",
      type: "singleChoice",
      prompt: "Fikk du gjort det?",
      options: [
        { value: "ja", label: "Ja" },
        { value: "delvis", label: "Delvis" },
        { value: "nei", label: "Nei" },
      ],
      required: true,
    },
    {
      id: "blokkering",
      type: "text",
      prompt: "Hva hindret deg?",
      maxLength: 1000,
      visibleIf: {
        field: "ANSWER",
        questionId: "fullfort",
        operator: "NEQ",
        value: "ja",
      },
    },
  ],
} satisfies LumiSurveyConfig;
```

#### Task Priority-survey

```tsx
import type { LumiSurveyConfig } from "@navikt/lumi-survey";

export const survey = {
  type: "taskPriority",
  questions: [
    {
      id: "viktigst",
      type: "multiChoice",
      variant: "checkbox",
      prompt: "Hvilke oppgaver er viktigst for deg? (velg inntil 5)",
      maxSelections: 5,
      randomize: true,
      options: [
        { value: "soke", label: "Søke om ytelse" },
        { value: "status", label: "Sjekke status" },
        { value: "dokument", label: "Sende dokumentasjon" },
        { value: "endring", label: "Melde endring" },
        { value: "utbetaling", label: "Se utbetalinger" },
        // Legg til 15-40 oppgaver for robust Long Neck-analyse
      ],
      required: true,
    },
  ],
} satisfies LumiSurveyConfig;
```

Anbefaling: Inkluder 20-50 oppgaver for god Long Neck-analyse. Bruk `randomize: true` for å unngå rekkefølgebias.

#### Tilgjengelige spørsmålstyper

| Type | Beskrivelse | Viktige props |
|------|-------------|---------------|
| `rating` | Skala (emoji/tommel/stjerner/NPS) | `variant`, `prompt`, `required` |
| `text` | Fritekst | `prompt`, `maxLength`, `minRows`, `placeholder` |
| `singleChoice` | Velg én | `prompt`, `options`, `randomize` |
| `multiChoice` | Velg flere | `prompt`, `options`, `maxSelections`, `variant` (`"checkbox"` \| `"combobox"`) |

#### Betinget visning med `visibleIf`

Vis spørsmål basert på tidligere svar:

| Operator | Betydning | Eksempel |
|----------|-----------|---------|
| `EXISTS` | Spørsmålet er besvart | Vis oppfølging uansett hva de svarte |
| `LT` | Mindre enn (tall) | Vis ved lav rating (`value: 3`) |
| `GT` | Større enn (tall) | Vis ved høy rating |
| `EQ` | Lik (tekst/tall) | Vis ved spesifikt svar (`value: "nei"`) |
| `NEQ` | Ulik | Vis når svaret IKKE er en bestemt verdi |
| `CONTAINS` | Inneholder (multi-choice) | Vis når et bestemt valg er valgt |

### 4b. Implementer transporten

Transporten kobler widgeten til ditt backend-endepunkt:

```tsx
import type { LumiSurveyTransport } from "@navikt/lumi-survey";

const transport: LumiSurveyTransport = {
  async submit(submission) {
    const response = await fetch("/api/lumi/feedback", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(submission.transportPayload),
    });
    if (!response.ok) {
      throw new Error(`Lumi feedback-innsending feilet: ${response.status}`);
    }
  },
};
```

### 4c. Render widgeten

```tsx
import { LumiSurveyDock } from "@navikt/lumi-survey";
import { survey } from "./survey";

<LumiSurveyDock
  surveyId="<app-navn>-feedback"
  survey={survey}
  transport={transport}
/>
```

Velg en unik `surveyId` — bruk appnavnet som prefiks (f.eks. `"sykepengesoknad-feedback"`, `"modia-satisfaction"`). Denne ID-en identifiserer surveyen i Lumi-dashboardet.

### 4d. Valgfritt: Kontekst-tags for segmentering

Send med metadata for å muliggjøre filtrering i Lumi-dashboardet:

```tsx
<LumiSurveyDock
  surveyId="<app-navn>-feedback"
  survey={survey}
  transport={transport}
  context={{
    tags: {
      // Lav kardinalitet — disse blir filterdimensjoner i dashboardet
      feature: "new-ui",
      role: "employer",
    },
  }}
/>
```

Regler for kontekst:
- `tags`: Kun verdier med lav kardinalitet (A/B-testgrupper, roller, features)
- `debug`: Høy kardinalitet tillatt (sesjons-ID-er, request-ID-er)
- **Aldri inkluder personopplysninger** (personnummer, e-post, navn)

### 4e. Lagringsstrategi

For **offentlige sider** med Nav-dekoratøren (nav.no): standard `consent`-strategi fungerer automatisk.

For **interne apper** (Modia, admin-verktøy) uten dekoratøren:

```tsx
<LumiSurveyDock
  behavior={{ storageStrategy: "localStorage" }}
  {...otherProps}
/>
```

> **Merk:** `localStorage` brukes kun for ikke-sensitiv survey UX-state (f.eks. om brukeren har sett/lukket undersøkelsen). Aldri lagre tokens, PII eller sensitiv data i localStorage.

## Fase 5: Backend-endepunkt

Se [references/backend-transport.md](references/backend-transport.md) for komplette backend-maler (Node.js og Kotlin).

## Fase 6: NAIS-konfigurasjon

Se [references/nais-konfigurasjon.md](references/nais-konfigurasjon.md) for NAIS-manifest og accessPolicy-oppsett.

## Fase 7: Validering

Etter implementasjon, verifiser hele flyten:

- [ ] `@navikt/lumi-survey` installert og stiler importert (ds-css FØR lumi-survey)
- [ ] Aksel v8+ bekreftet (`@navikt/ds-react` ≥ 8.0.0)
- [ ] `LumiSurveyDock` rendres i appen med en unik `surveyId`
- [ ] Survey-konfigurasjon bruker `satisfies LumiSurveyConfig`
- [ ] Transport sin `submit`-funksjon kaller ditt backend-endepunkt
- [ ] Backend-endepunkt utveksler token og videresender til Lumi API via `LUMI_FEEDBACK_PATH`
- [ ] NAIS-manifest har `LUMI_API_HOST`, `LUMI_AUDIENCE`, `LUMI_FEEDBACK_PATH` og `accessPolicy`
- [ ] Auth-type og endepunkt matcher (TokenX → `/api/tokenx/...`, AzureAD → `/api/azure/...`)
- [ ] Inbound access-policy bestilt hos Team eSyfo
- [ ] Ingen personopplysninger i kontekst-tags
- [ ] Lagringsstrategi matcher app-type (consent for offentlige, localStorage for interne)
- [ ] Surveyen dukker opp i riktig Lumi-dashboard etter testinnsending (dev: https://lumi-dashboard.ansatt.dev.nav.no, prod: https://lumi-dashboard.ansatt.nav.no/)

## Hurtigstart: Forhåndsdefinerte surveys

Hvis du bare vil komme raskt i gang uten skreddersøm, finnes det ferdige presets:

```tsx
import { LumiSurveyDock, DEFAULT_SURVEY_RATING } from "@navikt/lumi-survey";

<LumiSurveyDock surveyId="<app-navn>-feedback" survey={DEFAULT_SURVEY_RATING} transport={transport} />
```

| Import | Type | Beskrivelse |
|--------|------|-------------|
| `DEFAULT_SURVEY_RATING` | Rating (emoji) | 5-punkts emoji + tekstoppfølging ved lav score |
| `DEFAULT_SURVEY_THUMBS` | Rating (tommel) | Binær tommel opp/ned + tekstoppfølging |
| `DEFAULT_SURVEY_STARS` | Rating (stjerner) | 5-stjerners rating + tekstoppfølging |
| `DEFAULT_SURVEY_NPS` | Rating (NPS) | 0-10 Net Promoter Score |
| `DEFAULT_SURVEY_DISCOVERY` | Discovery | Mål + fullføring + blokkeringsanalyse |
| `DEFAULT_SURVEY_SERVICE_FEEDBACK` | Service feedback | Rating + forhåndsdefinerte årsaker + tekst |

Anbefaling: Bruk presets kun for rask prototyping. For produksjon, lag en skreddersydd konfigurasjon (Fase 4a) med spørsmålstekster tilpasset tjenesten.

## Avansert konfigurasjon

Se [references/avansert-konfigurasjon.md](references/avansert-konfigurasjon.md) for forgreningslogikk, events og øvrige avanserte tilpasninger.
