# GDPR og personvern — Nav-signal

Generisk GDPR-teori (behandlingsgrunnlag, right-to-be-forgotten, anonymisering vs. pseudonymisering, retention-job-mønstre, samtykkehistorikk) er utenfor scope. Denne referansen dekker Nav-spesifikk kategorisering og pekere til autoritative kilder.

## Nav-spesifikk kategorisering av persondata

Nav opererer med fire PII-nivåer definert i SKILL.md-tabellen: **strengt fortrolig**, **fortrolig**, **intern**, **åpen**. Viktige Nav-spesifikke presiseringer:

- **Ytelsesdata er klassifiseringsbare implisitt.** "Bruker mottar AAP" eller "uføretrygd" er implisitt helseinformasjon → strengt fortrolig. Avklar alltid per ytelse.
- **Kode 6/7** (adressesperre/fortrolig adresse) må håndteres som strengt fortrolig uansett felt.
- **Fødselsnummer og D-nummer** er fortrolige. Bruk aldri ekte fnr i kode, eksempler eller tester. Placeholder: `00000000000`. Skatteetatens syntetiske testserie kan brukes, men må merkes eksplisitt.

## Pekere til autoritative kilder

- **DPIA-prosess**: Se `references/nav-threat-model.md`. DPIA kreves ved ny behandling av personopplysninger eller vesentlig endring.
- **CEF/ArcSight auditlogg-format**: Se `references/nav-threat-model.md` (autoritativ kilde i denne skillen).
- **Retention-policy**: Dokumenteres per behandling med hjemmel. Koordiner med sikkerhetschampion og verifiser at også testdata, eksportfiler, backup og analytics-uttrekk dekkes av policyen.
- **Datatilsynet / tilsynshenvendelser**: Eskaler til sikkerhetschampion umiddelbart. Ikke svar direkte.

## Dataminimering i praksis

Ved gjennomgang: spør om hvert PII-felt i en datamodell er nødvendig for formålet. Nye felter krever oppdatert behandlingsgrunnlag, ikke bare et databasemigrasjon.
