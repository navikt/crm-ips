# NAV Domenekontekst: Etterlevelse av lover og regler

Generert: 2026-08-06  
Navet-fagområde: https://navno.sharepoint.com/sites/intranett-utvikling/SitePages/Etterlevelseskrav.aspx  
Gjelder systemer: etterlevelse-frontend, etterlevelse-backend, nav-etterlevelse-mcp, og andre systemer som støtter etterlevelsesarbeid i NAV.

> Deles av alle systemer innenfor fagområdet. Oppdater ved regelverksendringer
> eller endringer i faglige retningslinjer. Ikke system-spesifikk informasjon her.

---

## 1. Hva er etterlevelse i NAV

NAV har etterlevelseskrav for systemutvikling innenfor flere områder: personvern, sikkerhet, arkiv, universell utforming, saksbehandling og økonomi. Kravene er juridiske rammer og føringer fra regelverk som gjelder på tvers av hele NAV, omdannet til konkrete, testbare krav tilpasset systemutvikling.

**Etterlevelsesløsningen** er NAVs primære verktøy for å dokumentere at systemer og produkter oppfyller disse kravene. Den lar team dokumentere kravbesvarelser per suksesskriterium, gjennomføre PVK/DPIA og koble til Behandlingskatalogen.

**Behandlingskatalogen** er NAVs oversikt over alle behandlinger av personopplysninger — formål, rettslig grunnlag, personkategorier, databehandlere og lagringstider.

**Eierskap til rammeverket:** Seksjon informasjonsforvaltning (Arbeidsavdelingen) har ansvar for rammeverket og etterlevelsesløsningen. Fagansvarlig: Daniel Engehagen.

**Eierskap til kravene:** Etterlevelseskravene eies av direktørene i NAVs ledergruppe (jf. ansvarsdokumentet) og er delegert videre til tolkingsansvarlige og kraveiere.

---

## 2. Kravkategorier og rettslig grunnlag

### Personvern (K101–K116, K154, K187–K198, K229, K255, K262)

Hjemmel: **GDPR** (Personvernforordningen), **Personopplysningsloven** (2018-06-15-38).

- **GDPR art. 6(1)(c)** — Rettslig forpliktelse. Primærgrunnlag for dokumentasjon av compliance etter art. 24.
- **GDPR art. 6(1)(e)** — Offentlig myndighetsutøvelse. Primærgrunnlag for ytelsesbehandlinger.
- **GDPR art. 24** — Plikt til å kunne dokumentere at behandling av personopplysninger skjer i samsvar med forordningen. Etterlevelsesløsningen er NAVs primære verktøy for å oppfylle denne plikten.

Sentrale krav: formål (K102), lovlig behandling (K107), informasjonsplikt (K108), retting (K103), sletting (K104), innsyn (K113), nødvendighet og proporsjonalitet (K111), lagringstid (K191), behandlingsansvar og databehandlerrelasjon (K190), adressebeskyttelse (K255), auditlogging (K253).

### Sikkerhet (K245, K267)

Hjemmel: **Sikkerhetsloven** § 4-3 (plikt til sikkerhetstiltak), **NSM grunnprinsipper for IKT-sikkerhet**.

- **K245** — Krav til risikovurdering (ROS-analyse) for applikasjoner, systemer og plattformer.
- **K267** — Applikasjoner skal ha et forsvarlig sikkerhetsnivå (sårbarhetshåndtering, oppdatering, tilgangskontroll, logging, hemmeligheter, backup).

Risikovurderinger gjennomføres i **TryggNok** og lenkes til etterlevelsesdokumentasjonen.

### Arkiv (K128, K130, K171, K212, K214, K215, K219–K223, K226, K230)

Hjemmel: **Arkivlova** (1992-12-04-126), **Riksarkivets forskrifter**.

Arkiv er all dokumentasjon skapt som ledd i virksomheten — ikke bare saksmapper. Moderne arkivforvaltning omfatter alle data, all informasjon og all dokumentasjon som er saksbehandlet eller brukt som dokumentasjon.

Arkivformål kan overstyre GDPR og annen lovgivning når det gjelder plikt til å bevare data.

Sentrale krav: melde systemer til Arkivverket (K171), arkivere informasjon som har vært saksbehandlet (K212), ekte og pålitelig dokumentasjon (K220, K221), integritetssikring (K222), lagringstid og kassasjon (K230).

### Universell utforming (K195–K197, K231)

Hjemmel: **Likestillings- og diskrimineringsloven** § 17, **WCAG 2.1** (A- og AA-nivå).

Gjelder systemer med intern og/eller ekstern brukerflate.

### Saksbehandling og vedtak (K119–K155, K183–K186, K193, K199, K203–K211, K216, K218, K251, K254)

Hjemmel: **Forvaltningsloven**, **NAV-loven**, **eForvaltningsforskriften**.

Gjelder systemer som fatter vedtak eller behandler saker. Ikke relevant for rene interne støtteverktøy uten vedtaksfunksjon.

### Økonomi (K119–K127, K233–K236, K240, K248)

Hjemmel: **Statlige økonomireglement (ØR)**, **Skattebetalingsforskriften**.

Gjelder kun for økonomi- og utbetalingssystemer (ØSA-systemer).

### Statistikk og datadeling (K219, K263–K266)

Hjemmel: **Statistikkloven**, **Digitaliseringsrundskrivet**.

Sentrale krav: avlevere data til offisiell statistikk (K219), viderebruk og gjenbruk av informasjon (K263), bruk av autoritative kilder (K264), nasjonale felleskomponenter (K265).

---

## 3. Sentrale roller og aktører

| Rolle | Ansvar |
|---|---|
| **Kraveier** | Eier og vedlikeholder ett eller flere krav. Kan opprette, endre og slette krav i etterlevelsesløsningen. |
| **Etterlever** | Teamet som dokumenterer at et system oppfyller kravene. Alle NAV-ansatte kan lese; kun teamets medlemmer kan redigere sin dokumentasjon. |
| **Risikoeier** | Typisk seksjonsleder. Godkjenner risikonivå i PVK og etterlevelsesdokumentasjon. |
| **PVO** | Personvernombudet. Vurderer og kommenterer PVK-dokumenter etter innsending. |
| **Admin** | Kan administrere alle krav og etterlevelser. Begrenset til et fåtall i seksjon informasjonsforvaltning. |

---

## 4. Personopplysninger i etterlevelsesdomenet

Systemer innenfor dette domenet behandler primært **ansatteopplysninger** (NAV-ansatte), ikke innbyggeropplysninger:

- NAV-ident (ansattnummer) — beholdes permanent
- Navn og e-post fra Azure AD/NOM — knyttes til ansettelsesforholdet; vedlikeholdes og slettes som del av dette
- Azure AD-gruppetilhørighet — brukes til tilgangskontroll

Dette skiller seg vesentlig fra ytelsessystemer som behandler brukeres personopplysninger. GDPR art. 6(1)(c) er primærgrunnlag (jf. art. 24 om dokumentasjonsplikt).

---

## 5. PVK / DPIA

En **personvernkonsekvensvurdering (PVK/DPIA)** er påkrevd etter GDPR art. 35 dersom behandlingen sannsynligvis medfører høy risiko for de registrerte. Etterlevelsesløsningen har et eget PVK-modul for å dokumentere dette.

**Typiske triggere for høy risiko** (jf. Datatilsynets veileder):
- Systematisk profilering eller automatiserte beslutninger med rettsvirkning
- Behandling av særlige kategorier (art. 9) eller straffedommer i stor skala
- Systematisk overvåking av offentlig tilgjengelige områder i stor skala
- Ny teknologi kombinert med andre risikofaktorer
- Sårbare registrerte (barn, pasienter, ansatte)

**For interne støtteverktøy** som kun behandler ansatteidentitetsdata til tilgangskontroll er PVK normalt ikke nødvendig — lav risiko, ikke særlige kategorier, ikke stor skala av innbyggerdata.

Fullstendig vurderingsveiledning (blacklist, unntaksregler, art. 35 nr. 7-krav, prosess og roller) ligger i **nav-pvk-skillen** og i Datatilsynets veileder:
https://www.datatilsynet.no/rettigheter-og-plikter/virksomhetenes-plikter/vurdering-av-personvernkonsekvenser/

---

## 6. Etterlevelsesløsningens krav-nummerering

Krav er nummerert K101–K270+ og versjonert (K102.1, K102.2, K102.3 osv.). Nyere versjoner erstatter ikke alltid eldre — begge kan eksistere parallelt i en overgangsfase.

`relevansFor`-kodelista styrer hvilke krav som vises for et system:
- `PERSONOPPLYSNINGER` — behandler personopplysninger
- `INTERN_SKJERMFLATE` — har intern brukerflate
- `EKSTERN_SKJERMFLATE` — har ekstern brukerflate
- `EGETUTVIKLETSYSTEM` — drifter egetutviklet system
- `VEDTAKSBEHANDLING` — fatter vedtak
- `OKONOMISYSTEM` — behandler økonomi

`irrelevansFor` i etterlevelsesdokumentasjonen angir hvilke egenskaper som **ikke** er relevante — kun krav fra de valgte egenskapene vises.

---

## 7. Nyttige referanser

- Etterlevelsesløsningen (prod): https://etterlevelse.ansatt.nav.no
- Behandlingskatalogen (prod): https://behandlingskatalog.ansatt.nav.no
- TryggNok (ROS-verktøy): https://apps.powerapps.com/play/e/default-62366534-1ec3-4962-8869-9b5535279d0b/a/f8517640-ea01-46e2-9c09-be6b05013566
- Navet — Etterlevelse av lover og regler: https://navno.sharepoint.com/sites/intranett-utvikling/SitePages/Etterlevelseskrav.aspx
- Navet — Arkivkrav: https://navno.sharepoint.com/sites/intranett-utvikling/SitePages/Etterlevelseskrav-for-arkiv-og-arkivdokumentasjon.aspx
- Ansvarsdokumentet: [Distribuert via seksjon informasjonsforvaltning]
