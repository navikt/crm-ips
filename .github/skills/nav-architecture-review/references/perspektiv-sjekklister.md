# 3-perspektiv-sjekklister for Nav-arkitektur-review

Sjekklistene dekker det som er Nav-spesifikt. Generisk arkitektur-/security-visdom er utelatt — bruk den fra ditt eget repertoar.

## Arkitektur

Fokus: passer endringen inn i Navs plattform- og team-modell?

- Respekterer endringen team-autonomi? (Architecture Advice Process — søk råd, ta beslutningen selv.)
- Er berørte team (konsumenter/produsenter av data eller events) identifisert og rådspurt?
- Gjenbruker løsningen plattform-kapabiliteter framfor å bygge eget?
  - Auth → Wonderwall / Texas-Oasis, ikke egen auth-proxy.
  - Secrets → Nais secrets / Google Secret Manager, ikke egen secret store.
  - Kafka → Aiven via Nais (Kafkarator), ikke egen kluster.
  - Database → Cloud SQL via Nais, ikke egen DB-server.
  - Metrics/logg/tracing → Prometheus / Loki / Tempo, ikke egen pipeline.
- Følger løsningen Navs standardmønstre for kobling?
  - Kafka/events for asynkron kommunikasjon mellom team, REST kun der det gir mening.
  - API-kontrakter framfor delte databaser.
- Er tjenestens ansvar tydelig avgrenset (essensiell kompleksitet, ikke accidental)?
- Er det avhengigheter til on-prem eller legacy som må planlegges bort?
- Er avvik fra Nav-standard begrunnet og dokumentert?
- DORA-metrikker: gjør endringen deploy/lead time/change failure rate/recovery bedre eller verre?

## Sikkerhet

Fokus: Nav-spesifikk auth, `accessPolicy`, PII og personvern. Dypere trusselmodellering → `security-review`.

- **Dataklassifisering:** Åpen / Intern / Fortrolig / Strengt fortrolig — avgjør auth- og lagringskrav.
- **Auth-mekanisme valgt riktig?**
  - Borger-flyt → ID-porten (via Wonderwall/Texas-Oasis).
  - Intern Nav-ansatt → Azure AD.
  - Tjeneste-til-tjeneste internt → TokenX (on-behalf-of) eller Azure AD client credentials.
  - Ekstern virksomhet → Maskinporten.
- **`accessPolicy` i Nais-manifest:**
  - `inbound.rules` begrenser hvem som kan kalle inn — kun nødvendige konsumenter.
  - `outbound.rules` / `outbound.external` deklarerer hvert utgående kall.
  - Least privilege — ingen wildcards der det kan unngås.
- **PII-beskyttelse:**
  - Ingen fødselsnummer, navn, adresse eller saksinnhold i strukturert logg.
  - Bruk maskering / hash der ID må logges for korrelasjon.
  - Kryptering i transitt (TLS) og hvilemode (default i Cloud SQL / bucket).
- **Personvern og regulatoriske krav:**
  - Ny eller endret behandling av personopplysninger? → vurder DPIA (personvernkonsekvensvurdering).
  - Kontakt personvernombud og / eller behandlingsansvarlig ved usikkerhet.
  - Er behandlingsgrunnlag dokumentert (lovhjemmel, samtykke, etc.)?
  - Melding til Datatilsynet nødvendig? (ved høy risiko tross tiltak).
- **Secrets:** ingen secrets i kode, logg eller ADR — bruk Nais secrets / Google Secret Manager.
- **Audit-spor:** er sensitive operasjoner sporet et sted man faktisk kan søke i?

## Plattform

Fokus: Nais/GCP-konsekvenser, observerbarhet, CI/CD.

- **Nais-manifest:**
  - `resources.requests` satt realistisk (CPU + minne).
  - **Ikke** sett `resources.limits.cpu` — gir throttling på Nais.
  - `resources.limits.memory` satt for å fange lekkasjer; aksepter OOM framfor trege pods.
  - `replicas.min` / `replicas.max` passer trafikk og HA-behov.
  - `liveness` og `readiness` probes konfigurert riktig (readiness skal feile før liveness under oppstart).
- **Plattform-tjenester:**
  - Cloud SQL: instanstype, disk, backup, `flags` — og migreringsverktøy (Flyway/Liquibase).
  - Kafka: topic-er deklarert i Kafkarator, pool valgt (`nav-prod`, `nav-dev`, etc.), retention satt.
  - GCS bucket / Redis / andre — deklarert i manifest der mulig.
- **Observerbarhet fra dag 1:**
  - Prometheus-metrikker: forretning (domeneteller) + teknisk (HTTP, kø-lag, DB-pool).
  - Strukturert JSON-logg via Logback/Logstash-encoder, ingen PII.
  - Distribuert tracing (OpenTelemetry) — auto-instrumentering der mulig.
  - Alerts med meningsfulle terskler og runbook-lenke.
- **CI/CD:**
  - Standard GitHub Actions-workflow (build → test → deploy til dev → deploy til prod).
  - Deploy-strategi (rolling / feature toggle / parallell drift) passer endringen.
  - Rollback-sti tydelig (revert + re-deploy, eller `kubectl rollout undo` som siste utvei).
- **Kostnad og kvote:**
  - Ressursbehov innenfor team-kvote i GCP-prosjektet?
  - Data-egress, lagring og Cloud SQL-instanser er de største kostnadsdriverne — gjør et grovt estimat.
- **Drift og beredskap:**
  - Runbook for vanlige feilmoduser (se også `nav-troubleshoot`).
  - Eier og vakt-ansvar tydelig før produksjonssetting.
