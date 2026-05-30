# Dulting — referansekatalog

Teknikkatalog, etiske vurderinger og måleprinsipper for `/dulting`.

## Status

- Eksemplene er designhypoteser fra oppfølgingsplan-kontekst — ikke testet i produksjon.
- Bruk dem som inspirasjon og utgangspunkt, ikke som bevis for effekt.
- DellaVigna & Linos (2022) viser at nudge-effekter ikke alltid replikerer i stor skala.

## Barriere → teknikk

Bruk denne tabellen for rask lookup etter at du har diagnostisert hovedbarrieren (Steg 2 i SKILL.md):

| Barriere | Førstevalg-teknikker | Unngå |
|----------|---------------------|-------|
| **Lav motivasjon** | Sosial norm, tapsframing (varsomt), vis gevinst, personalisering | Friksjonsfjerning alene løser ikke motivasjon |
| **Lav evne / for vanskelig** | Forenkling, defaults, stegvis avsløring, friksjonsfjerning | Tapsframing (skaper press uten å gjøre det enklere) |
| **Manglende prompt** | Triggere/påminnelser, salience, handlingsrettet språk | For mange samtidige prompter (notifikasjonstretthet) |
| **Lav tillit** | Åpenhet, forklar defaults, vis kilde for normer, empatisk tone | Tidspress, sosial norm (oppleves som manipulasjon) |
| **Sårbar situasjon** | Lav friksjon, empatisk tone, tydelig «hopp over», små steg | Tapsframing, sterke defaults, tidspress |
| **Vet ikke at de skal** | Tydelig informasjon, prompt i riktig øyeblikk | Dulting (informasjon først, dulting deretter) |

## Teknikkatalog

### 1. Defaults (forhåndsvalg)

**Prinsipp**: Folk holder seg til det som er forhåndsvalgt.

**Eksempler (oppfølgingsplan-kontekst):**
- Forhåndsutfyll arbeidsoppgaver fra siste kjente stilling
- Foreslå tilretteleggingstiltak basert på type sykmelding
- Forhåndsfyll dato for neste oppfølging basert på fristene

**Nav-guardrails:**
- ⚠️ Defaults som deler personopplysninger krever personvern-/juridisk vurdering
- Opt-out skal alltid være like enkelt som opt-in (ett klikk)
- Forklar alltid hva som er forhåndsvalgt og hvorfor: «Vi har foreslått X — du kan endre det»

### 2. Fremdrift og commitment

**Prinsipp**: Folk fullfører det de har begynt (endowment effect). Synlig fremdrift motiverer.

**Eksempler (oppfølgingsplan-kontekst):**
- Vis fremdriftslinje: «Planen er 60 % ferdig»
- «Du har allerede fylt ut arbeidsoppgaver — neste steg er tilrettelegging»
- Bryt opp i 3-4 tydelige steg

**Nav-guardrails:**
- Ikke vis fremdrift som press — særlig for sårbare brukere med lav energi
- Fremdrift skal motivere, ikke straffe («du ligger etter»)

### 3. Tidspress og frister

**Prinsipp**: Konkrete frister skaper handling. Abstrakte tidsrom gjør det ikke.

**Eksempler (oppfølgingsplan-kontekst):**
- ❌ «Planen skal lages innen 4 uker»
- ✅ «Fristen for oppfølgingsplanen er 15. februar»
- Vis nedtelling: «5 dager til fristen»

**Nav-guardrails:**
- ⚠️ Bruk aldri falsk tidspress
- ⚠️ Når konsekvensen er tap av rettigheter (sykepengestopp, sanksjoner): krev fag-/juridisk avklaring før bruk
- Fristen må være reell og korrekt

### 4. Tapsframing (loss aversion)

**Prinsipp**: Tap oppleves sterkere enn gevinst. Vis hva brukeren risikerer.

**Eksempler (oppfølgingsplan-kontekst):**
- ❌ «Det er lurt å lage en oppfølgingsplan»
- ✅ «Uten oppfølgingsplan kan Nav be om en forklaring ved 8 ukers sykefravær»

**Nav-guardrails:**
- 🛑 **Høyrisiko-teknikk.** Bruk sparsomt og kun når påstanden er sann.
- Bruk ALDRI tapsframing mot brukere i akutt krise eller alvorlig sykdom
- Unngå formuleringer som oppleves som trusler i sårbare situasjoner
- Vurder alltid: ville brukeren føle seg presset eller informert?

### 5. Sosial norm

**Prinsipp**: Folk gjør det andre gjør. Normative utsagn motiverer handling.

**Eksempler (oppfølgingsplan-kontekst):**
- «De fleste arbeidsgivere lager oppfølgingsplanen i løpet av de 2 første ukene»
- «9 av 10 som lager plan, opplever bedre dialog med den ansatte»

**Nav-guardrails:**
- 🛑 Normative utsagn **må** baseres på faktiske data. Aldri fiktive tall.
- Oppgi kilde og tidsperiode: «Basert på data fra 2024»
- Normen må gjelde brukerens faktiske situasjon (ikke generaliser fra store bedrifter til små)
- LLM-en skal ALDRI generere konkrete prosenttall — brukeren må oppgi datagrunnlag

### 6. Forenkling og friksjonsfjerning

**Prinsipp**: Hver ekstra handling reduserer gjennomføring. Fjern alt som kan fjernes.

**Eksempler (oppfølgingsplan-kontekst):**
- Én primærhandling per side/steg
- Fjern bekreftelsesdialog når handlingen er enkel å angre
- Forhåndsutfyll alt som kan utledes fra kontekst
- Progressive disclosure — vis detaljer kun ved behov

**Nav-guardrails:**
- Friksjonsfjerning er den tryggeste dulte-teknikken — bruk den først
- Skill mellom nødvendig friksjon (juridisk/faglig) og unødvendig friksjon (historisk/intern)

### 7. Prompt-design (triggere)

**Prinsipp**: Riktig prompt til riktig tid utløser handling (Fogg). For tidlig = ignorert. For sent = irrelevant.

**Eksempler på triggerpunkter (oppfølgingsplan-kontekst):**

| Hendelse | Prompt | Kanal |
|----------|--------|-------|
| Ny sykmelding mottatt | «Du har en ny sykmeldt ansatt — start oppfølgingsplan» | Notifikasjon |
| 2 uker uten aktivitet | «Fristen nærmer seg — ta neste steg» | Varsel |
| Dialogmøte nærmer seg | «Planen bør være klar til dialogmøte 1» | Påminnelse |
| Plan ferdigstilt | «Del planen med legen for bedre oppfølging» | I flyten |

**Nav-guardrails:**
- Ikke overdriv antall påminnelser — notifikasjonstretthet er reelt
- Respekter brukerens kanalprefranser

### 8. Personalisering

**Prinsipp**: Personlige budskap er mer effektive enn generelle.

**Eksempler (oppfølgingsplan-kontekst):**
- Bruk den ansattes fornavn i påminnelser
- Tilpass budskap til fase i sykefraværet
- Vis relevant info basert på type sykmelding

**Nav-guardrails:**
- Personaliser bare med data brukeren vet at Nav har
- Ikke personaliser på måter som avslører sensitive opplysninger

### 9. Handlingsrettet språk

**Prinsipp**: Fortell brukeren hva de skal *gjøre*, ikke bare hva som *er*.

| ❌ Passivt | ✅ Handlingsrettet |
|-----------|-------------------|
| «Oppfølgingsplanen er et verktøy» | «Start oppfølgingsplanen nå» |
| «Det er viktig med tilrettelegging» | «Beskriv hva du kan tilby av tilpasninger» |
| «Planen skal sendes til Nav» | «Del planen med Nav — trykk her» |
| «Fristen er 4 uker» | «Fullfør innen 15. februar» |

### 10. Stegvis avsløring (progressive disclosure)

**Prinsipp**: For mye informasjon overvelder. Vis litt om gangen.

**Eksempler (oppfølgingsplan-kontekst):**
- Vis kun neste steg tydelig — resten som liste
- Ekspander detaljer ved behov
- Bruk veiviser-mønster for første gangs utfylling
- Gi hjelp kontekstuelt, ikke som lang instruksjon på toppen

## Digital EAST Cards

BITs Digital EAST Cards (2024) bryter ned digitale brukerreiser for å finne dultepunkter:

1. Kartlegg én handling brukeren skal gjennomføre
2. Marker beslutningspunkter, venting, frister og avbrudd
3. Vurder hvert punkt med EAST: enklere? mer attraktivt? mer sosialt? mer tidsriktig?
4. Koble til Fogg: mangler motivasjon, evne eller prompt?
5. Test én endring om gangen

## Sludge audit

Mills et al. (2024): kartlegg unødvendig friksjon og mørke mønstre i samme brukerreise.

1. Kartlegg hele brukerreisen (også vei ut, hjelp, analog kanal, angre)
2. List alle klikk, ventepunkter, bekreftelser, dokumentkrav
3. Marker hva som er juridisk nødvendig vs. historisk/intern friksjon
4. Se særlig etter sludge i opt-out, sletting, kontakt og hjelp til sårbare brukere
5. Fjern sludge før sterkere dulting

## Dulting vs. mørke mønstre

| Dulting (OK) | Mørkt mønster / sludge (ALDRI) |
|---|---|
| Foreslå beste alternativ som default | Skjule alternativet brukeren vil |
| Vise sosial norm basert på ekte tall | Fabrikkere statistikk |
| Gjøre handling enklere | Gjøre det vanskelig å *ikke* handle |
| Påminne om frister | Skape falsk tidspress |
| Vise konsekvens av inaktivitet | Overdrive konsekvenser for å skremme |

## FORGOOD — utdypet

FORGOOD (Lades & Delaney, 2022) er et etisk rammeverk for atferdsintervensjoner, publisert i *Behavioural Public Policy* og brukt i OECD- og UNICEF-veiledning.

### F — Fairness
Rammer dultingen noen grupper urettferdig? Eksempel: en norm som gjelder store bedrifter bør ikke presenteres til små bedrifter.

### O — Openness
Er dultingen synlig? Transparente dulter er ofte like effektive som skjulte (Paunov et al., 2019). Forklar defaults og normkilder.

### R — Respect
Respekteres autonomi og verdighet? Bruk aldri skyldfølelse. «Hopp over» skal alltid være tilgjengelig.

### G — Goals
Er målet i brukerens interesse, ikke bare systemets? Når målene spriker, prioriter brukerens mål.

### O — Opinions
Ville brukerne akseptere dette? Test med brukergrupper ved tvil.

### O — Options
Bevares reell valgfrihet? Defaults skal kunne endres med ett klikk. Papir/telefon/digital skal alle være tilgjengelige.

### D — Delegation
Er det riktig instans? Nav kan dulte om plikter. Nav skal IKKE dulte om helsebeslutninger (legens rolle).

## Måling og guardrails

### Primærmetrikker
- Konvertering (starter / fullfører / deler)
- Tid til handling
- Gjennomføringsgrad

### Guardrail-metrikker (like viktige)
- Feilutfylling / korrigeringer
- Klager, henvendelser og misforståelser
- Opplevd press/stress (brukertest)
- Forskjeller mellom brukergrupper
- Kvalitet på innhold (ikke bare utfylt)
- Om brukeren forsto at valget var frivillig

A/B-test nye dulter isolert. Én endring om gangen. Mål guardrails, ikke bare konvertering.

## Akademisk grunnlag

| Kilde | Nøkkelkonsept |
|-------|---------------|
| Thaler & Sunstein (2008) — *Nudge* | Choice architecture, libertarian paternalism |
| BIT (2014, oppdatert 2024) — *EAST* + *Digital EAST Cards* | Easy, Attractive, Social, Timely |
| Fogg (2009) — *Behavior Model* | B=MAP (Motivation, Ability, Prompt) |
| Kahneman (2011) — *Thinking, Fast and Slow* | System 1 vs System 2 |
| Hertwig & Grüne-Yanoff (2017) | Boosts vs nudges |
| Lades & Delaney (2022) — *Nudge FORGOOD* | Etisk vurdering, 7 dimensjoner |
| DellaVigna & Linos (2022) — *RCTs to Scale* | Effekter replikerer ikke alltid i skala |
| Mills et al. (2024) — *Dark patterns and sludge audits* | Integrert analyse av friksjon |

## Kilder

- Thaler, R. H., & Sunstein, C. R. (2008). *Nudge*. Yale University Press.
- Behavioural Insights Team. (2014, oppdatert 2024). *EAST: Four Simple Ways to Apply Behavioural Insights*.
- Behavioural Insights Team. (2024). *Digital EAST Cards*.
- Fogg, B. J. (2009). *A Behavior Model for Persuasive Design*. Persuasive '09.
- Kahneman, D. (2011). *Thinking, Fast and Slow*. Farrar, Straus and Giroux.
- Hertwig, R., & Grüne-Yanoff, T. (2017). Nudging and boosting. *Perspectives on Psychological Science*, 12(6), 973–986.
- Lades, L. K., & Delaney, L. (2022). Nudge FORGOOD. *Behavioural Public Policy*, 6(1), 75–94.
- Johnson, E. J. et al. (2012). Beyond Nudges: Tools of a Choice Architecture. *Marketing Letters*, 23(2), 487–504.
- Mills, S. (2022). Personalized nudging. *Behavioural Public Policy*, 6(1), 150–159.
- Sunstein, C. R. (2018). Do People Like Nudges? *Administrative Law Review*, 68(2), 177–232.
- Thaler, R. H. (2018). Nudge, not sludge. *Science*, 361(6401), 431.
- Paunov, Y. et al. (2019). Transparency in nudging. *J. Exp. Psychology: Applied*, 25(3), 485–502.
- DellaVigna, S., & Linos, E. (2022). RCTs to Scale. *Econometrica*, 90(1), 81–116.
- Mills, S. et al. (2024). Dark patterns and sludge audits. *Behavioural Public Policy*.
- OECD. (2022). *BASIC Toolkit for Behavioural Insights Practitioners*.
- UNICEF. (2021/2022). *The BASIC Toolkit* og *Ethics Toolkit for Applied Behavioural Science*.
- Nav. *Slik følger du opp sykmeldte* / *Oppfølgingsplan*. nav.no.
