# ADR-mal for Nav

Nav-spesifikk mal for Architecture Decision Records. Fyll inn avsnittene som er relevante, slett resten. Hold ADR-en kort og fokusert — én beslutning per ADR.

## Filnavn

`docs/adr/ADR-{nummer}-{kort-tittel}.md`

## Mal

```markdown
# ADR-{nummer}: {Tittel}

**Dato:** YYYY-MM-DD
**Status:** Foreslått | Godkjent | Forkastet | Erstattet av ADR-{n}
**Beslutningstakere:** {team eller personer}

## Kontekst

- Hva er problemet eller muligheten?
- Hvorfor må vi ta en beslutning nå?
- Hvilke begrensninger gjelder (regulatorisk, plattform, team-kapasitet)?

## Beslutning

Vi har besluttet å {konkret valg}.

## Alternativer vurdert

### Alternativ A: {navn} (valgt)

**Beskrivelse:** ...

**Fordeler:**
- ...

**Ulemper:**
- ...

### Alternativ B: {navn}

**Beskrivelse:** ...

**Fordeler:**
- ...

**Ulemper:**
- ...

### Alternativ C: Gjøre ingenting

**Beskrivelse:** Beholde nåværende løsning.

**Fordeler:**
- Ingen endringskostnad.

**Ulemper:**
- {konsekvens av å ikke gjøre noe}

## Nav-spesifikke vurderinger

### Sikkerhet og personvern
- **Dataklassifisering:** Åpen / Intern / Fortrolig / Strengt fortrolig
- **Auth-mekanisme:** ID-porten / Azure AD / TokenX / Maskinporten
- **PII-håndtering:** {hvordan personopplysninger beskyttes i logg, lagring, transport}
- **Tilgangsstyring:** {accessPolicy-strategi — inngang og utgang}
- **Personvern:** {DPIA-vurdert? kontaktet personvernombud? behandlingsgrunnlag?}

### Plattform (Nais/GCP)
- **Infrastrukturkrav:** {Cloud SQL / Kafka / Redis / Bucket / ...}
- **Ressursbehov:** {CPU/minne-requests, replicas — husk: ikke sett CPU-limits på Nais}
- **Observerbarhet:** {metrikker, strukturert logging uten PII, tracing, alerts}
- **CI/CD-endringer:** {nye workflows, deploy-strategi, feature toggles}

### Team og organisasjon
- **Berørte team:** {konsumenter, produsenter, plattformteam}
- **Architecture Advice:** {hvem er rådspurt, når, hva var tilbakemeldingen}
- **Migrasjonsstrategi:** {nåtilstand → måltilstand}
- **Tilbakerulling:** {rollback-plan uten datatap}
- **Tidsramme:** {når skal dette være på plass}

## Migrasjon (ved endring av eksisterende system)
- **Bakoverkompatibilitet:** {kan gammel kode kjøre med nytt skjema?}
- **Utrullingsstrategi:** big bang / gradvis / parallell drift
- **Feature toggle:** {toggle-navn og strategi}
- **Rollback-trigger:** {hva utløser rollback}
- **Exit criteria:** {når er migreringen ferdig}
- **Dekommisjonering:** {plan for gammel løsning}
- **Migrasjons-observerbarhet:** {gammel vs ny path, avviksteller, rekonsiliering}

## Konsekvenser

### Positive
- ...

### Negative
- ...

### Risiko

| Risiko | Sannsynlighet | Konsekvens | Mitigering |
|--------|--------------|------------|-----------|
| ... | Lav/Middels/Høy | ... | ... |

## Aksjonspunkter

- [ ] {oppgave} — {eier} — {frist}
- [ ] Oppdater Nais-manifest (inkl. `accessPolicy`)
- [ ] Sett opp observerbarhet (metrikker, logg, alerts)
- [ ] Informer berørte team
- [ ] Oppdater dokumentasjon / runbooks
```

## Tips

- Hold ADR-er korte og fokuserte — én beslutning per ADR.
- "Gjøre ingenting" er alltid et alternativ.
- Skriv for fremtidige lesere som ikke kjenner konteksten.
- Oppdater status når beslutningen er tatt.
- Bruk "Erstattet av ADR-{n}" når en beslutning revideres.
- Ikke legg PII eller hemmeligheter i selve ADR-en — referer til riktig kilde i stedet.
