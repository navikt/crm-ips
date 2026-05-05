---
description: "Definerer korte, obligatoriske klarspråk-regler for norsk markdown-tekst i Nav-repoer og peker til /klarsprak for dypdykk"
applyTo: "**/*.md"
---

# Norsk tekstkvalitet (lean)

Disse reglene gjelder all norsk markdown-tekst i Nav-repoer. For dypere veiledning på mikrotekst, feilmeldinger, labels og PR-tekst — bruk `/klarsprak`.

## AI-markører å unngå

- Overforbruk av em-dash (`—`) i løpende tekst og kulepunkter
- Formler som "ikke bare X, men også Y"
- Klisjeer som "i et stadig skiftende landskap"
- Overdrevne adjektiver: "banebrytende", "revolusjonerende", "sømløs", "robust"
- Oppsummeringspåheng som "kort sagt" når setningen ikke tilfører ny info

Skriv heller konkret hva som skjer, hvem som gjør det, og hva leseren skal gjøre.

## Det viktigste først

Start med konklusjon eller beslutning. Bakgrunn og begrunnelse kommer etterpå.
Målet er forventningsstyring: leseren skal forstå utfallet tidlig, ikke bygges opp mot det.

## Unngå substantivsyke

```text
❌ Vi foretar en vurdering av implementasjonen.
✅ Vi vurderer implementasjonen.
```

Foretrekk verb og aktiv form. Kutt unødvendige hjelpeord.

## Anglisismer og Nav-språkpraksis

Bruk norsk når det finnes naturlige ord, men behold etablerte fagtermer.
Vanlige feller:

- "adressere et problem" → "løse" / "ta tak i"
- "ta eierskap til" → "ha ansvar for"
- "har du noen input?" → "har du innspill?"
- "shippe" / "deploye" → "levere" / "rulle ut"
- "på slutten av dagen" → dropp eller skriv poenget direkte

I sammensatte ord med engelsk fagterm: bruk bindestrek (`CI-pipeline`, `API-kall`).

## Tredjeperson i description-felt

Når du skriver `description` i `SKILL.md` eller instruction-frontmatter, bruk tredjeperson.
Skriv hva filen gjør, ikke hva "jeg" eller "du" gjør.

```text
✅ "Gir retningslinjer for ..."
❌ "Jeg hjelper deg med ..."
```
