## Avansert konfigurasjon

For avanserte brukstilfeller (forgreningslogikk, steg-for-steg-flyter, egendefinerte events, intro-skjermer, egne labels, styling):

1. Les de eksporterte TypeScript-typene: `node_modules/@navikt/lumi-survey/dist/index.d.ts`
2. Nøkkelgrensesnitt: `LumiSurveyDockProps`, `LumiSurveyConfig`, `LumiSurveyQuestion`, `LumiSurveyBehavior`, `LumiSurveyEvents`, `LumiSurveyStyle`
3. Full dokumentasjon: https://navikt.github.io/lumi/

**Events for analyseintegrasjon:**

```tsx
<LumiSurveyDock
  events={{
    onSubmitSuccess: () => analytics.track("survey_completed"),
    onSubmitError: (cause) => logger.error("Survey submit failed", cause),
  }}
  {...otherProps}
/>
```
