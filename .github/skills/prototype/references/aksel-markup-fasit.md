# Aksel markup-fasit (ekte ds-react-output)

> **Generert** av `scripts/generate_markup_fasit.mjs` via `@navikt/ds-react@8.12.0` +
> `react-dom/server`. Hver kodeblokk er ds-reacts **egen** statiske HTML — garantert
> korrekt DOM som rendrer autentisk Aksel med `@navikt/ds-css` lastet. Ikke rediger
> for hånd; kjør generatoren på nytt ved Aksel-oppgradering.

Dette er Visual Companion-sidens **fasit**: bruk denne ekte `.aksel-*`-markupen i
VC-skissene i stedet for `.mock-*`-tilnærminger. Da rendrer skissen ekte Aksel —
riktige farger, fasonger, ikoner og struktur — uten React, build eller CDN.

## Slik bruker du fasiten

1. VC-siden MÅ ha rot-konteksten under (setter standard fargekontekst = `accent`, så
   primærknapper blir blå). `@navikt/ds-css` lastes via `/aksel.css` (allerede i
   frame-malen).
2. Lim inn komponentens markup fra tabellen under, bytt teksten til ditt innhold.
3. Komponenter som setter egen `data-color` (LocalAlert, GlobalAlert, Tag …)
   overstyrer rot-konteksten — det er meningen (nøstede fargekontekster).
4. Ikon-SVG-er er inkludert for eksakthet; bytt fritt til andre Aksel-ikoner.

### Rot-kontekst (wrap alt innhold i denne)

```html
<div class="aksel-theme light" data-background="true" data-color="accent">
    {{INNHOLD}}
</div>
```

## Skjema og input

### Button

variant: primary | secondary | tertiary | danger. size: medium | small | xsmall. Primær er blå (accent) via rot-konteksten.

```html
<div style="display:flex;gap:12px">
  <button data-variant="primary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Lagre</span>
  </button>
  <button data-variant="secondary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Avbryt</span>
  </button>
  <button data-variant="tertiary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Tilbake</span>
  </button>
  <button data-color="danger" data-variant="primary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Slett</span>
  </button>
</div>
```

### TextField

Bytt label/description. error-prop gir rød ramme + feilmelding.

```html
<div class="aksel-form-field aksel-form-field--medium">
  <label for="textField-R0" class="aksel-form-field__label aksel-label">Fornavn</label>
  <div id="textField-description-R0" class="aksel-form-field__description aksel-body-short aksel-body-short--medium">Slik det står i passet ditt</div>
  <input id="textField-R0" aria-describedby="textField-description-R0" type="text" class="aksel-text-field__input aksel-body-short aksel-body-short--medium"/>
  <div class="aksel-form-field__error" id="textField-error-R0" aria-relevant="additions removals" aria-live="polite">
  </div>
</div>
```

### Textarea

Flerlinjet fritekst. maxLength gir teller.

```html
<div class="aksel-form-field aksel-form-field--medium">
  <label for="textarea-R0" class="aksel-form-field__label aksel-label">Begrunnelse</label>
  <div id="textarea-description-R0" class="aksel-form-field__description aksel-body-short aksel-body-short--medium">Maks 200 tegn</div>
  <textarea rows="3" style="--__axc-textarea-height:auto" id="textarea-R0" aria-describedby="textarea-description-R0" class="aksel-textarea__input aksel-body-short aksel-body-short--medium">
  </textarea>
  <textarea aria-hidden="true" class="aksel-textarea__input aksel-body-short aksel-body-short--medium" readonly="" tabindex="-1" style="visibility:hidden;position:absolute;overflow:hidden;height:0;top:0;left:0;transform:translateZ(0)">
  </textarea>
  <div class="aksel-form-field__error" id="textarea-error-R0" aria-relevant="additions removals" aria-live="polite">
  </div>
</div>
```

### Select

Nedtrekksvalg for korte lister.

```html
<div class="aksel-form-field aksel-form-field--medium">
  <label for="select-R0" class="aksel-form-field__label aksel-label">Land</label>
  <div class="aksel-select__container">
    <select id="select-R0" class="aksel-select__input aksel-body-short aksel-body-short--medium">
      <option value="no">Norge</option>
      <option value="se">Sverige</option>
    </select>
    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" class="aksel-select__chevron" aria-hidden="true">
      <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
    </path>
  </svg>
</div>
<div class="aksel-form-field__error" id="select-error-R0" aria-relevant="additions removals" aria-live="polite">
</div>
</div>
```

### Search

Fritekstsøk (ikke verdivalg → bruk Combobox).

```html
<div class="aksel-form-field aksel-form-field--medium aksel-search">
  <label for="searchfield-R0" class="aksel-form-field__label aksel-sr-only aksel-label">Søk</label>
  <div class="aksel-search__wrapper">
    <div class="aksel-search__wrapper-inner">
      <input id="searchfield-R0" type="search" class="aksel-search__input aksel-search__input--primary aksel-text-field__input aksel-body-short aksel-body-short--medium" value=""/>
    </div>
    <button data-variant="primary" type="submit" class="aksel-search__button-search aksel-button aksel-button--medium aksel-button--icon-only">
      <span class="aksel-button__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-labelledby="title-R37">
          <title id="title-R37">Søk</title>
          <path fill="currentColor" fill-rule="evenodd" d="M10.5 3.25a7.25 7.25 0 1 0 4.569 12.88l5.411 5.41a.75.75 0 1 0 1.06-1.06l-5.41-5.411A7.25 7.25 0 0 0 10.5 3.25M4.75 10.5a5.75 5.75 0 1 1 11.5 0 5.75 5.75 0 0 1-11.5 0" clip-rule="evenodd">
        </path>
      </svg>
    </span>
  </button>
</div>
<div class="aksel-form-field__error" id="searchfield-error-R0" aria-relevant="additions removals" aria-live="polite">
</div>
</div>
```

### Checkbox / CheckboxGroup

Grupper alltid i CheckboxGroup med legend.

```html
<fieldset aria-labelledby="R0" class="aksel-checkbox-group aksel-checkbox-group--medium aksel-fieldset aksel-fieldset--medium">
  <legend id="R0" class="aksel-fieldset__legend aksel-label">Hvilke ytelser søker du om?</legend>
  <div class="aksel-checkboxes">
    <div class="aksel-checkbox aksel-checkbox--medium">
      <div class="aksel-checkbox__input-wrapper" data-standalone="false">
        <input id="checkbox-Rn" class="aksel-checkbox__input" type="checkbox" value="dp"/>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 13 10" fill="none" focusable="false" role="img" aria-hidden="true" class="aksel-checkbox__icon">
          <path d="M4.03524 6.41478L10.4752 0.404669C11.0792 -0.160351 12.029 -0.130672 12.5955 0.47478C13.162 1.08027 13.1296 2.03007 12.5245 2.59621L5.02111 9.59934C4.74099 9.85904 4.37559 10 4.00025 10C3.60651 10 3.22717 9.84621 2.93914 9.56111L0.439143 7.06111C-0.146381 6.47558 -0.146381 5.52542 0.439143 4.93989C1.02467 4.35437 1.97483 4.35437 2.56036 4.93989L4.03524 6.41478Z" fill="currentColor">
        </path>
      </svg>
    </div>
    <label for="checkbox-Rn" class="aksel-checkbox__label aksel-body-short aksel-body-short--medium">Dagpenger</label>
  </div>
  <div class="aksel-checkbox aksel-checkbox--medium">
    <div class="aksel-checkbox__input-wrapper" data-standalone="false">
      <input id="checkbox-R17" class="aksel-checkbox__input" type="checkbox" value="aap"/>
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 13 10" fill="none" focusable="false" role="img" aria-hidden="true" class="aksel-checkbox__icon">
        <path d="M4.03524 6.41478L10.4752 0.404669C11.0792 -0.160351 12.029 -0.130672 12.5955 0.47478C13.162 1.08027 13.1296 2.03007 12.5245 2.59621L5.02111 9.59934C4.74099 9.85904 4.37559 10 4.00025 10C3.60651 10 3.22717 9.84621 2.93914 9.56111L0.439143 7.06111C-0.146381 6.47558 -0.146381 5.52542 0.439143 4.93989C1.02467 4.35437 1.97483 4.35437 2.56036 4.93989L4.03524 6.41478Z" fill="currentColor">
      </path>
    </svg>
  </div>
  <label for="checkbox-R17" class="aksel-checkbox__label aksel-body-short aksel-body-short--medium">Arbeidsavklaringspenger</label>
</div>
</div>
<div id="fieldset-error-R0H1" aria-relevant="additions removals" aria-live="polite" class="aksel-fieldset__error">
</div>
</fieldset>
```

### Radio / RadioGroup

Ett valg av flere gjensidig utelukkende.

```html
<fieldset role="radiogroup" aria-labelledby="R1" class="aksel-radio-group aksel-radio-group--medium aksel-fieldset aksel-fieldset--medium">
  <legend id="R1" class="aksel-fieldset__legend aksel-label">Er du norsk statsborger?</legend>
  <div class="aksel-radio-buttons">
    <div class="aksel-radio aksel-radio--medium">
      <input id="radio-R1f" name="radioGroupName-R0" type="radio" class="aksel-radio__input" data-standalone="false" value="ja"/>
      <label for="radio-R1f" class="aksel-radio__label aksel-body-short aksel-body-short--medium">Ja</label>
    </div>
    <div class="aksel-radio aksel-radio--medium">
      <input id="radio-R2f" name="radioGroupName-R0" type="radio" class="aksel-radio__input" data-standalone="false" value="nei"/>
      <label for="radio-R2f" class="aksel-radio__label aksel-body-short aksel-body-short--medium">Nei</label>
    </div>
  </div>
  <div id="fieldset-error-R1H1" aria-relevant="additions removals" aria-live="polite" class="aksel-fieldset__error">
  </div>
</fieldset>
```

### Switch

På/av-bryter for innstillinger.

```html
<div class="aksel-switch aksel-switch--medium aksel-switch--left">
  <input id="switch-R0" type="checkbox" class="aksel-switch__input"/>
  <span class="aksel-switch__track">
    <span class="aksel-switch__thumb">
    </span>
  </span>
  <label for="switch-R0" class="aksel-switch__label-wrapper">
    <span class="aksel-switch__content">
      <span class="aksel-switch__label aksel-body-short aksel-body-short--medium">Få varsler på SMS</span>
    </span>
  </label>
</div>
```

### Combobox

Søkbar liste / flervalg for >7 alternativer.

```html
<div class="aksel-form-field aksel-form-field--medium">
  <label for="comboboxfield-R0" class="aksel-form-field__label aksel-label">Velg kommune</label>
  <div class="aksel-combobox__wrapper">
    <div class="aksel-combobox__wrapper-inner aksel-text-field__input">
      <ul data-type="single" class="aksel-chips aksel-combobox__selected-options aksel-chips--medium aksel-body-short aksel-body-short--small">
        <li>
          <input id="comboboxfield-R0" type="text" role="combobox" autoComplete="off" class="aksel-combobox__input aksel-body-short aksel-body-short--medium" aria-controls="comboboxfield-R0-filtered-options" aria-expanded="false" aria-autocomplete="list" value=""/>
        </li>
      </ul>
      <div class="aksel-combobox__button-toggle-list" aria-hidden="true">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img">
          <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
        </path>
      </svg>
    </div>
  </div>
  <div data-aksel-floating-content-wrapper="" style="position:fixed;left:0;top:0;transform:translate(0, -200%);min-width:max-content;z-index:9999999;--__axc-floating-transform-origin:" dir="ltr">
    <div data-side="bottom" data-align="center" class="aksel-combobox__list aksel-combobox__list--closed" id="comboboxfield-R0-filtered-options" tabindex="-1" style="max-height:316px;animation:none">
      <ul role="listbox" class="aksel-combobox__list-options">
        <li class="aksel-combobox__list-item" id="comboboxfield-r0-option-oslo" tabindex="-1" role="option" aria-selected="false">
          <p aria-label="Oslo" class="aksel-body-short aksel-body-short--medium">Oslo</p>
        </li>
        <li class="aksel-combobox__list-item" id="comboboxfield-r0-option-bergen" tabindex="-1" role="option" aria-selected="false">
          <p aria-label="Bergen" class="aksel-body-short aksel-body-short--medium">Bergen</p>
        </li>
        <li class="aksel-combobox__list-item" id="comboboxfield-r0-option-trondheim" tabindex="-1" role="option" aria-selected="false">
          <p aria-label="Trondheim" class="aksel-body-short aksel-body-short--medium">Trondheim</p>
        </li>
      </ul>
    </div>
  </div>
</div>
<div class="aksel-form-field__error" id="comboboxfield-error-R0" aria-relevant="additions removals" aria-live="polite">
</div>
</div>
```

### Chips (Toggle)

Filtrering. selected markerer aktivt valg.

```html
<ul class="aksel-chips aksel-chips--medium aksel-body-short aksel-body-short--small">
  <li>
    <button class="aksel-chips__chip aksel-chips__toggle aksel-chips__toggle--with-checkmark" aria-pressed="true" data-pressed="true">
      <svg aria-hidden="true" class="aksel-chips__toggle-icon" width="1.25em" height="1.25em" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" focusable="false" role="img">
        <path fill-rule="evenodd" clip-rule="evenodd" d="M10 18.125C14.4873 18.125 18.125 14.4873 18.125 10C18.125 5.51269 14.4873 1.875 10 1.875C5.51269 1.875 1.875 5.51269 1.875 10C1.875 14.4873 5.51269 18.125 10 18.125ZM14.128 7.72904C14.3695 7.44357 14.3339 7.01635 14.0485 6.7748C13.763 6.53326 13.3358 6.56886 13.0942 6.85432L8.60428 12.1606L6.41627 9.97263C6.15185 9.70822 5.72315 9.70822 5.45873 9.97263C5.19431 10.2371 5.19431 10.6658 5.45873 10.9302L8.16706 13.6385C8.30095 13.7724 8.48479 13.8441 8.67397 13.8362C8.86316 13.8284 9.0404 13.7416 9.16271 13.5971L14.128 7.72904Z" fill="currentColor">
      </path>
    </svg>
    <span class="aksel-chips__chip-text">Åpne</span>
  </button>
</li>
<li>
  <button class="aksel-chips__chip aksel-chips__toggle aksel-chips__toggle--with-checkmark">
    <svg aria-hidden="true" class="aksel-chips__toggle-icon" width="1.25em" height="1.25em" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" focusable="false" role="img">
      <path fill-rule="evenodd" clip-rule="evenodd" d="M10 3.125C6.20304 3.125 3.125 6.20304 3.125 10C3.125 13.797 6.20304 16.875 10 16.875C13.797 16.875 16.875 13.797 16.875 10C16.875 6.20304 13.797 3.125 10 3.125ZM1.875 10C1.875 5.51269 5.51269 1.875 10 1.875C14.4873 1.875 18.125 5.51269 18.125 10C18.125 14.4873 14.4873 18.125 10 18.125C5.51269 18.125 1.875 14.4873 1.875 10Z" fill="var(--ax-text-default)">
    </path>
  </svg>
  <span class="aksel-chips__chip-text">Under behandling</span>
</button>
</li>
<li>
  <button class="aksel-chips__chip aksel-chips__toggle aksel-chips__toggle--with-checkmark">
    <svg aria-hidden="true" class="aksel-chips__toggle-icon" width="1.25em" height="1.25em" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" focusable="false" role="img">
      <path fill-rule="evenodd" clip-rule="evenodd" d="M10 3.125C6.20304 3.125 3.125 6.20304 3.125 10C3.125 13.797 6.20304 16.875 10 16.875C13.797 16.875 16.875 13.797 16.875 10C16.875 6.20304 13.797 3.125 10 3.125ZM1.875 10C1.875 5.51269 5.51269 1.875 10 1.875C14.4873 1.875 18.125 5.51269 18.125 10C18.125 14.4873 14.4873 18.125 10 18.125C5.51269 18.125 1.875 14.4873 1.875 10Z" fill="var(--ax-text-default)">
    </path>
  </svg>
  <span class="aksel-chips__chip-text">Avsluttet</span>
</button>
</li>
</ul>
```

### ToggleGroup

Segmentert valg, fast antall.

```html
<div class="aksel-toggle-group__wrapper">
  <div id="R0" class="aksel-toggle-group__label aksel-label">Vis per</div>
  <div aria-labelledby="R0" class="aksel-toggle-group aksel-toggle-group--medium" role="radiogroup" data-aksel-toggle-group="true">
    <button class="aksel-toggle-group__button" type="button" tabindex="0" aria-checked="true" data-selected="true" data-aksel-toggle-item="" role="radio">
      <span class="aksel-toggle-group__button-inner aksel-body-short aksel-body-short--medium">Uke</span>
    </button>
    <button class="aksel-toggle-group__button" type="button" tabindex="-1" aria-checked="false" data-selected="false" data-aksel-toggle-item="" role="radio">
      <span class="aksel-toggle-group__button-inner aksel-body-short aksel-body-short--medium">Måned</span>
    </button>
  </div>
</div>
```

### CopyButton

Kopierer tekst til utklippstavle.

```html
<button data-color="neutral" data-variant="tertiary" type="button" data-active="false" class="aksel-copybutton aksel-button aksel-button--medium">
  <span class="aksel-button__icon">
    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true" class="aksel-copybutton__icon">
      <path fill="currentColor" fill-rule="evenodd" d="M8.25 3.5c0-.69.56-1.25 1.25-1.25H14a.75.75 0 0 1 .53.22l5 5c.141.14.22.331.22.53v8.5c0 .69-.56 1.25-1.25 1.25h-9c-.69 0-1.25-.56-1.25-1.25zm6.25 5.25c-.69 0-1.25-.56-1.25-1.25V3.75h-3.5v12.5h8.5v-7.5zm.25-3.94 2.44 2.44h-2.44zM6.502 7.75H5.75v12.5h8.5v-.748a.75.75 0 0 1 1.5 0v.998c0 .69-.56 1.25-1.25 1.25h-9c-.69 0-1.25-.56-1.25-1.25v-13c0-.69.56-1.25 1.25-1.25h1.002a.75.75 0 1 1 0 1.5" clip-rule="evenodd">
    </path>
  </svg>
</span>
<span class="aksel-label">Kopier fødselsnummer</span>
</button>
```

### ConfirmationPanel

Bekreftelse/samtykke før innsending.

```html
<div class="aksel-confirmation-panel aksel-form-field" data-color="warning">
  <div class="aksel-confirmation-panel__inner">
    <div id="confirmation-panel-R0H1" class="aksel-confirmation-panel__content aksel-body-long aksel-body-long--medium">Du er ansvarlig for at svarene stemmer.</div>
    <div class="aksel-checkbox aksel-checkbox--medium">
      <div class="aksel-checkbox__input-wrapper" data-standalone="false">
        <input id="confirmation-panel-R0" aria-describedby="confirmation-panel-R0H1" class="aksel-checkbox__input" type="checkbox"/>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 13 10" fill="none" focusable="false" role="img" aria-hidden="true" class="aksel-checkbox__icon">
          <path d="M4.03524 6.41478L10.4752 0.404669C11.0792 -0.160351 12.029 -0.130672 12.5955 0.47478C13.162 1.08027 13.1296 2.03007 12.5245 2.59621L5.02111 9.59934C4.74099 9.85904 4.37559 10 4.00025 10C3.60651 10 3.22717 9.84621 2.93914 9.56111L0.439143 7.06111C-0.146381 6.47558 -0.146381 5.52542 0.439143 4.93989C1.02467 4.35437 1.97483 4.35437 2.56036 4.93989L4.03524 6.41478Z" fill="currentColor">
        </path>
      </svg>
    </div>
    <label for="confirmation-panel-R0" class="aksel-checkbox__label aksel-body-short aksel-body-short--medium">Jeg bekrefter at opplysningene er riktige</label>
  </div>
</div>
<div class="aksel-form-field__error" id="confirmation-panel-error-R0" role="alert">
</div>
</div>
```

### Fieldset

Grupperer relaterte felt med felles legend.

```html
<fieldset aria-labelledby="R0" class="aksel-fieldset aksel-fieldset--medium">
  <legend id="R0" class="aksel-fieldset__legend aksel-label">Kontaktinformasjon</legend>
  <div class="aksel-form-field aksel-form-field--medium">
    <label for="textField-Rn" class="aksel-form-field__label aksel-label">E-post</label>
    <input id="textField-Rn" type="text" class="aksel-text-field__input aksel-body-short aksel-body-short--medium"/>
    <div class="aksel-form-field__error" id="textField-error-Rn" aria-relevant="additions removals" aria-live="polite">
    </div>
  </div>
  <div class="aksel-form-field aksel-form-field--medium">
    <label for="textField-R17" class="aksel-form-field__label aksel-label">Telefon</label>
    <input id="textField-R17" type="text" class="aksel-text-field__input aksel-body-short aksel-body-short--medium"/>
    <div class="aksel-form-field__error" id="textField-error-R17" aria-relevant="additions removals" aria-live="polite">
    </div>
  </div>
  <div id="fieldset-error-R0H1" aria-relevant="additions removals" aria-live="polite" class="aksel-fieldset__error">
  </div>
</fieldset>
```

### FormProgress

Søknadssteg — bruk denne, IKKE Stepper for søknadsflyt.

```html
<div>
  <div class="aksel-progress-bar aksel-progress-bar--medium aksel-form-progress__bar" aria-valuemax="4" aria-valuenow="2" aria-valuetext="2 av 4" role="progressbar" aria-hidden="true">
    <div class="aksel-progress-bar__foreground" style="--__axc-progress-bar-translate:-50%">
    </div>
  </div>
  <div data-state="closed">
    <div style="--__axc-stack-direction-xs:row;--__axc-stack-align-xs:center;--__axc-stack-justify-xs:space-between" class="aksel-stack aksel-hstack aksel-stack-align aksel-stack-justify aksel-stack-direction aksel-stack-wrap">
      <span class="aksel-body-short aksel-body-short--medium">Steg 2 av 4</span>
      <button data-variant="tertiary" type="button" data-state="closed" id="collapsible-trigger-R2" class="aksel-form-progress__button aksel-button aksel-button--small">
        <span class="aksel-button__icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
            <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
          </path>
        </svg>
      </span>
      <span class="aksel-label aksel-label--small">
        <span class="aksel-form-progress__btn-txt-hide">Skjul alle steg</span>
        <span class="aksel-form-progress__btn-txt-show">Vis alle steg</span>
      </span>
    </button>
  </div>
  <div class="aksel-form-progress__collapsible" data-state="closed" hidden="" id="collapsible-content-R2">
    <div class="aksel-form-progress__collapsible-content">
      <div class="aksel-form-progress__stepper">
        <ol class="aksel-stepper" data-orientation="vertical">
          <li class="aksel-stepper__item" data-interactive="true">
            <span class="aksel-stepper__line aksel-stepper__line--1">
            </span>
            <a href="#1" class="aksel-stepper__step aksel-stepper__step--behind" data-active="false" data-completed="false" data-interactive="true">
              <span aria-hidden="true" class="aksel-stepper__circle aksel-label">1</span>
              <span class="aksel-stepper__content aksel-label">Om deg</span>
            </a>
            <span class="aksel-stepper__line aksel-stepper__line--2">
            </span>
          </li>
          <li class="aksel-stepper__item" data-interactive="true">
            <span class="aksel-stepper__line aksel-stepper__line--1">
            </span>
            <a href="#2" aria-current="step" class="aksel-stepper__step aksel-stepper__step--active" data-active="true" data-completed="false" data-interactive="true">
              <span aria-hidden="true" class="aksel-stepper__circle aksel-label">2</span>
              <span class="aksel-stepper__content aksel-label">Inntekt</span>
            </a>
            <span class="aksel-stepper__line aksel-stepper__line--2">
            </span>
          </li>
          <li class="aksel-stepper__item" data-interactive="true">
            <span class="aksel-stepper__line aksel-stepper__line--1">
            </span>
            <a href="#3" class="aksel-stepper__step" data-active="false" data-completed="false" data-interactive="true">
              <span aria-hidden="true" class="aksel-stepper__circle aksel-label">3</span>
              <span class="aksel-stepper__content aksel-label">Vedlegg</span>
            </a>
            <span class="aksel-stepper__line aksel-stepper__line--2">
            </span>
          </li>
          <li class="aksel-stepper__item" data-interactive="true">
            <span class="aksel-stepper__line aksel-stepper__line--1">
            </span>
            <a href="#4" class="aksel-stepper__step" data-active="false" data-completed="false" data-interactive="true">
              <span aria-hidden="true" class="aksel-stepper__circle aksel-label">4</span>
              <span class="aksel-stepper__content aksel-label">Oppsummering</span>
            </a>
            <span class="aksel-stepper__line aksel-stepper__line--2">
            </span>
          </li>
        </ol>
      </div>
    </div>
  </div>
</div>
</div>
```

### FileUpload

Opplasting + liste over filer.

```html
<div class="aksel-file-item">
  <div class="aksel-file-item__inner">
    <div class="aksel-file-item__file-info aksel-body-long aksel-body-long--medium">
      <span class="aksel-file-item__link">
        <div class="aksel-file-item__icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" font-size="2rem" aria-hidden="true">
            <path fill="currentColor" d="M7.7 14.835q.336 0 .532.189a.63.63 0 0 1 .203.49.65.65 0 0 1-.203.497q-.196.182-.532.182h-.693v-1.358zM12.002 14.87q.323 0 .518.182a.62.62 0 0 1 .196.476v1.827q0 .3-.196.483a.73.73 0 0 1-.518.182h-.609v-3.15z">
          </path>
          <path fill="currentColor" fill-rule="evenodd" d="M5.25 4.5c0-.69.56-1.25 1.25-1.25H14a.75.75 0 0 1 .53.22l4 4c.141.14.22.331.22.53v4.25H21a.75.75 0 0 1 .75.75v7a.75.75 0 0 1-.75.75H3a.75.75 0 0 1-.75-.75v-7a.75.75 0 0 1 .75-.75h2.25zm9.25 4.25c-.69 0-1.25-.56-1.25-1.25V4.75h-6.5v7.5h10.5v-3.5zm.25-2.94 1.44 1.44h-1.44zm-6.112 8.283a2.04 2.04 0 0 0-.938-.203H5.957V19h1.05v-1.862H7.7q.54 0 .938-.203.4-.203.623-.567a1.6 1.6 0 0 0 .224-.854q0-.49-.224-.854a1.47 1.47 0 0 0-.623-.567m4.288 0a2 2 0 0 0-.924-.203h-1.659V19h1.66q.531 0 .923-.203.4-.21.616-.581.224-.37.224-.861v-1.827a1.6 1.6 0 0 0-.224-.861 1.47 1.47 0 0 0-.616-.574M14.8 19v-5.11h3.29v.98h-2.254v1.134h2.072v.98H15.85V19z" clip-rule="evenodd">
        </path>
      </svg>
    </div>vedlegg.pdf</span>
    <div class="aksel-body-short aksel-body-short--small">0,03 MB</div>
    <div class="aksel-file-item__error" aria-relevant="additions removals" aria-live="polite">
    </div>
  </div>
</div>
</div>
```

### ErrorSummary

Samlet valideringsoversikt med lenker til felt.

```html
<div class="aksel-error-summary aksel-error-summary--medium" tabindex="-1">
  <h2 tabindex="-1" class="aksel-error-summary__heading aksel-heading aksel-heading--small">Du må rette opp følgende:</h2>
  <ul class="aksel-error-summary__list aksel-body-short aksel-body-short--medium">
    <li>
      <a href="#fnr" class="aksel-error-summary__item aksel-link">Fødselsnummer mangler</a>
    </li>
    <li>
      <a href="#epost" class="aksel-error-summary__item aksel-link">E-post er ugyldig</a>
    </li>
  </ul>
</div>
```

### FormSummary

Oppsummering av svar før innsending. (Dette er komponenten som startet fidelity-arbeidet.)

```html
<div class="aksel-form-summary">
  <div class="aksel-form-summary__header">
    <h2 class="aksel-heading aksel-heading--medium">Dine svar</h2>
  </div>
  <dl class="aksel-form-summary__answers">
    <div data-color="accent" class="aksel-form-summary__answer">
      <dt class="aksel-label">Navn</dt>
      <dd class="aksel-form-summary__value aksel-body-long aksel-body-long--medium">Kari Nordmann</dd>
    </div>
    <div data-color="accent" class="aksel-form-summary__answer">
      <dt class="aksel-label">Fødselsnummer</dt>
      <dd class="aksel-form-summary__value aksel-body-long aksel-body-long--medium">00000000000</dd>
    </div>
  </dl>
</div>
```

### HelpText

Hjelpetekst i popover (trigger vises; innhold er interaktivt).

```html
<div class="aksel-help-text" data-color="info">
  <button class="aksel-help-text__button" type="button" aria-expanded="false" aria-label="Hva betyr dette?">
    <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" focusable="false" role="img" class="aksel-help-text__icon" aria-hidden="true">
      <circle cx="12" cy="12" r="11" stroke-width="1.5" stroke="currentColor" fill="transparent">
      </circle>
      <path fill-rule="evenodd" clip-rule="evenodd" d="M9.75 9C9.75 7.75736 10.7574 6.75 12 6.75H12.1716C13.3195 6.75 14.25 7.68054 14.25 8.82843C14.25 9.37966 14.031 9.90832 13.6412 10.2981L12.6412 11.2981C11.7504 12.1889 11.25 13.3971 11.25 14.6569C11.25 15.0711 11.5858 15.4069 12 15.4069C12.4142 15.4069 12.75 15.0711 12.75 14.6569C12.75 13.7949 13.0924 12.9682 13.7019 12.3588L14.7019 11.3588C15.373 10.6877 15.75 9.77748 15.75 8.82843C15.75 6.85212 14.1479 5.25 12.1716 5.25H12C9.92893 5.25 8.25 6.92893 8.25 9V9.5C8.25 9.91421 8.58579 10.25 9 10.25C9.41421 10.25 9.75 9.91421 9.75 9.5V9ZM12 16.5C11.4477 16.5 11 16.9477 11 17.5C11 18.0523 11.4477 18.5 12 18.5C12.5523 18.5 13 18.0523 13 17.5C13 16.9477 12.5523 16.5 12 16.5Z" fill="currentColor">
    </path>
  </svg>
  <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" focusable="false" role="img" class="aksel-help-text__icon aksel-help-text__icon--filled" aria-hidden="true">
    <circle cx="12" cy="12" r="11" stroke-width="1.5" stroke="currentColor" fill="currentColor">
    </circle>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M9.75 9C9.75 7.75736 10.7574 6.75 12 6.75H12.1716C13.3195 6.75 14.25 7.68054 14.25 8.82843C14.25 9.37966 14.031 9.90832 13.6412 10.2981L12.6412 11.2981C11.7504 12.1889 11.25 13.3971 11.25 14.6569C11.25 15.0711 11.5858 15.4069 12 15.4069C12.4142 15.4069 12.75 15.0711 12.75 14.6569C12.75 13.7949 13.0924 12.9682 13.7019 12.3588L14.7019 11.3588C15.373 10.6877 15.75 9.77748 15.75 8.82843C15.75 6.85212 14.1479 5.25 12.1716 5.25H12C9.92893 5.25 8.25 6.92893 8.25 9V9.5C8.25 9.91421 8.58579 10.25 9 10.25C9.41421 10.25 9.75 9.91421 9.75 9.5V9ZM12 16.5C11.4477 16.5 11 16.9477 11 17.5C11 18.0523 11.4477 18.5 12 18.5C12.5523 18.5 13 18.0523 13 17.5C13 16.9477 12.5523 16.5 12 16.5Z" fill="var(--ax-text-accent-contrast)">
  </path>
</svg>
</button>
<div class="aksel-popover aksel-help-text__popover aksel-popover--hidden" style="position:absolute;left:0;top:0" data-placement="top" aria-hidden="true">
  <div class="aksel-popover__content aksel-body-short">Vi bruker dette til å beregne ytelsen.</div>
</div>
</div>
```

## Tilbakemelding og status

### LocalAlert

Lokalt varsel nær en hendelse. status: announcement | success | warning | error (ingen 'info' — announcement = nøytral/info). Erstatter deprecated Alert. Komponer med .Header/.Title/.Content.

```html
<div style="display:flex;flex-direction:column;gap:12px">
  <section aria-label="Kunngjøring" class="aksel-base-alert" data-size="medium" data-color="neutral" data-variant="strong" data-global="false">
    <div role="alert">
      <div data-color="neutral" class="aksel-base-alert__header">
        <div class="aksel-base-alert__icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
            <path fill="currentColor" fill-rule="evenodd" d="M19.03 6.03a.75.75 0 0 0-1.06-1.06l-1.5 1.5a.75.75 0 0 0 1.06 1.06zm-4.743-.723A.75.75 0 0 1 14.75 6v12a.75.75 0 0 1-1.28.53l-.615-.614a7.26 7.26 0 0 0-3.89-2.017.256.256 0 0 1-.215-.251V8.352c0-.125.091-.23.214-.251a7.3 7.3 0 0 0 3.891-2.017l.615-.614a.75.75 0 0 1 .817-.163M6 15.75a3.75 3.75 0 1 1 0-7.5h1a.25.25 0 0 1 .25.25v7a.25.25 0 0 1-.25.25zm-.46.978a.26.26 0 0 0-.29.256V19c0 .414.336.75.75.75h2a.75.75 0 0 0 .75-.75v-1.985a.16.16 0 0 0-.137-.16l-.432-.061a4 4 0 0 0-.614-.044H6q-.232 0-.46-.022M18.25 12a.75.75 0 0 1 .75-.75h2a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1-.75-.75m-.72 4.47a.75.75 0 1 0-1.06 1.06l1.5 1.5a.75.75 0 1 0 1.06-1.06z" clip-rule="evenodd">
          </path>
        </svg>
      </div>
      <p id="R1" aria-hidden="true" class="aksel-body-short aksel-body-short--medium aksel-typo--visually-hidden">Kunngjøring: </p>
      <h2 id="R6p" aria-labelledby="R1 R6p" class="aksel-base-alert__title aksel-body-short aksel-body-short--large aksel-typo--semibold">Vi har mottatt søknaden din</h2>
    </div>
    <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Du hører fra oss innen tre uker.</div>
  </div>
</section>
<section aria-label="Suksess" class="aksel-base-alert" data-size="medium" data-color="success" data-variant="strong" data-global="false">
  <div role="alert">
    <div data-color="success" class="aksel-base-alert__header">
      <div class="aksel-base-alert__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
          <path fill="currentColor" fill-rule="evenodd" d="M12 21.75c5.385 0 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25 2.25 6.615 2.25 12s4.365 9.75 9.75 9.75m4.954-12.475a.813.813 0 0 0-1.24-1.05l-5.389 6.368L7.7 11.967a.812.812 0 0 0-1.15 1.15l3.25 3.25a.81.81 0 0 0 1.195-.05z" clip-rule="evenodd">
        </path>
      </svg>
    </div>
    <p id="R2" aria-hidden="true" class="aksel-body-short aksel-body-short--medium aksel-typo--visually-hidden">Suksess: </p>
    <h2 id="R6q" aria-labelledby="R2 R6q" class="aksel-base-alert__title aksel-body-short aksel-body-short--large aksel-typo--semibold">Søknaden er sendt</h2>
  </div>
  <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Du kan logge inn for å se status.</div>
</div>
</section>
<section aria-label="Advarsel" class="aksel-base-alert" data-size="medium" data-color="warning" data-variant="strong" data-global="false">
  <div role="alert">
    <div data-color="warning" class="aksel-base-alert__header">
      <div class="aksel-base-alert__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
          <path fill="currentColor" fill-rule="evenodd" d="M12 2.25a.75.75 0 0 1 .656.387l9.527 17.25A.75.75 0 0 1 21.526 21H2.474a.75.75 0 0 1-.657-1.113l9.526-17.25A.75.75 0 0 1 12 2.25M12 8.75a.75.75 0 0 1 .75.75v4a.75.75 0 0 1-1.5 0v-4a.75.75 0 0 1 .75-.75m-1 7.75a1 1 0 1 1 2 0 1 1 0 0 1-2 0" clip-rule="evenodd">
        </path>
      </svg>
    </div>
    <p id="R3" aria-hidden="true" class="aksel-body-short aksel-body-short--medium aksel-typo--visually-hidden">Advarsel: </p>
    <h2 id="R6r" aria-labelledby="R3 R6r" class="aksel-base-alert__title aksel-body-short aksel-body-short--large aksel-typo--semibold">Fristen nærmer seg</h2>
  </div>
  <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Du har tre dager igjen på å svare.</div>
</div>
</section>
<section aria-label="Feil" class="aksel-base-alert" data-size="medium" data-color="danger" data-variant="strong" data-global="false">
  <div role="alert">
    <div data-color="danger" class="aksel-base-alert__header">
      <div class="aksel-base-alert__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
          <path fill="currentColor" fill-rule="evenodd" d="M7.742 2.47a.75.75 0 0 1 .53-.22h7.456a.75.75 0 0 1 .53.22l5.272 5.272c.141.14.22.331.22.53v7.456a.75.75 0 0 1-.22.53l-5.272 5.272a.75.75 0 0 1-.53.22H8.272a.75.75 0 0 1-.53-.22L2.47 16.258a.75.75 0 0 1-.22-.53V8.272a.75.75 0 0 1 .22-.53zm1.288 5.5a.75.75 0 0 0-1.06 1.06L10.94 12l-2.97 2.97a.75.75 0 1 0 1.06 1.06L12 13.06l2.97 2.97a.75.75 0 1 0 1.06-1.06L13.06 12l2.97-2.97a.75.75 0 0 0-1.06-1.06L12 10.94z" clip-rule="evenodd">
        </path>
      </svg>
    </div>
    <p id="R4" aria-hidden="true" class="aksel-body-short aksel-body-short--medium aksel-typo--visually-hidden">Feil: </p>
    <h2 id="R6s" aria-labelledby="R4 R6s" class="aksel-base-alert__title aksel-body-short aksel-body-short--large aksel-typo--semibold">Noe gikk galt</h2>
  </div>
  <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Vi kunne ikke lagre svaret. Prøv igjen.</div>
</div>
</section>
</div>
```

### GlobalAlert

Varsel for hele løsningen — full bredde, øverst. status: announcement | success | warning | error. Komponer med .Header/.Title/.Content.

```html
<section aria-label="Kunngjøring" data-centered="true" class="aksel-base-alert" data-size="medium" data-color="neutral" data-variant="strong" data-global="true">
  <div role="alert">
    <div data-color="neutral" class="aksel-base-alert__header">
      <div class="aksel-base-alert__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true">
          <path fill="currentColor" fill-rule="evenodd" d="M19.03 6.03a.75.75 0 0 0-1.06-1.06l-1.5 1.5a.75.75 0 0 0 1.06 1.06zm-4.743-.723A.75.75 0 0 1 14.75 6v12a.75.75 0 0 1-1.28.53l-.615-.614a7.26 7.26 0 0 0-3.89-2.017.256.256 0 0 1-.215-.251V8.352c0-.125.091-.23.214-.251a7.3 7.3 0 0 0 3.891-2.017l.615-.614a.75.75 0 0 1 .817-.163M6 15.75a3.75 3.75 0 1 1 0-7.5h1a.25.25 0 0 1 .25.25v7a.25.25 0 0 1-.25.25zm-.46.978a.26.26 0 0 0-.29.256V19c0 .414.336.75.75.75h2a.75.75 0 0 0 .75-.75v-1.985a.16.16 0 0 0-.137-.16l-.432-.061a4 4 0 0 0-.614-.044H6q-.232 0-.46-.022M18.25 12a.75.75 0 0 1 .75-.75h2a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1-.75-.75m-.72 4.47a.75.75 0 1 0-1.06 1.06l1.5 1.5a.75.75 0 1 0 1.06-1.06z" clip-rule="evenodd">
        </path>
      </svg>
    </div>
    <p id="R0" aria-hidden="true" class="aksel-body-short aksel-body-short--medium aksel-typo--visually-hidden">Kunngjøring: </p>
    <h2 id="Rr" aria-labelledby="R0 Rr" class="aksel-base-alert__title aksel-body-short aksel-body-short--large aksel-typo--semibold">Planlagt vedlikehold</h2>
  </div>
  <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Tjenesten er nede lørdag kl. 02–04. Søknader lagres som kladd.</div>
</div>
</section>
```

### InlineMessage

Kort statusmelding i kontekst. Har Info-variant.

```html
<div variant="info" data-size="medium" class="aksel-inline-message aksel-body-long aksel-body-long--medium">
  <span data-color="accent">Lagret automatisk</span>
</div>
```

### Tag

Status-merkelapp. variant: neutral | info | success | warning | error + variant outline/moderate/strong.

```html
<div style="display:flex;gap:8px">
  <span data-color="success" data-variant="outline" class="aksel-tag aksel-tag--medium aksel-body-short aksel-body-short--medium">Innvilget</span>
  <span data-color="warning" data-variant="outline" class="aksel-tag aksel-tag--medium aksel-body-short aksel-body-short--medium">Under behandling</span>
  <span data-color="danger" data-variant="outline" class="aksel-tag aksel-tag--medium aksel-body-short aksel-body-short--medium">Avslått</span>
</div>
```

### InfoCard

Fremhever innhold (ikke varsel).

```html
<div class="aksel-base-alert" data-size="medium" data-color="info" data-variant="moderate" data-global="false">
  <div data-color="accent" class="aksel-base-alert__content aksel-body-long aksel-body-long--medium">Du kan endre svarene fram til fristen.</div>
</div>
```

### ProgressBar

Kjent varighet/progresjon. Søknad → FormProgress.

```html
<div class="aksel-progress-bar aksel-progress-bar--medium" aria-valuemax="100" aria-valuenow="60" aria-valuetext="60 av 100" role="progressbar" aria-label="60% fullført">
  <div class="aksel-progress-bar__foreground" style="--__axc-progress-bar-translate:-40%">
  </div>
</div>
```

### Loader

Ubestemt lasting >1s.

```html
<svg aria-labelledby="loader-R0" class="aksel-loader aksel-loader--large aksel-loader--neutral" focusable="false" viewBox="0 0 50 50" preserveAspectRatio="xMidYMid" data-color="neutral" data-variant="neutral">
  <title id="loader-R0">Laster</title>
  <circle class="aksel-loader__background" xmlns="http://www.w3.org/2000/svg" cx="25" cy="25" r="20" fill="none">
  </circle>
  <circle class="aksel-loader__foreground" cx="25" cy="25" r="20" fill="none" stroke-dasharray="50 155">
  </circle>
</svg>
```

### Skeleton

Plassholder mens innhold lastes.

```html
<div style="display:flex;flex-direction:column;gap:8px">
  <div class="aksel-skeleton aksel-skeleton--text aksel-skeleton--no-height" style="width:60%" aria-hidden="true">
  </div>
  <div class="aksel-skeleton aksel-skeleton--rectangle aksel-skeleton--no-width" style="height:80px" aria-hidden="true">
  </div>
</div>
```

### Tooltip

Hint ved hover/fokus (trigger vises; tooltip er interaktiv).

```html
<button data-variant="tertiary" aria-label="Logg ut" class="aksel-button aksel-button--medium">
  <span class="aksel-label">Meny</span>
</button>
```

### Pagination

Sidenavigasjon for lange lister.

```html
<nav aria-label="Sidenavigasjon" data-color="neutral" class="aksel-pagination aksel-pagination--medium">
  <ul class="aksel-pagination__list">
    <li>
      <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="1" page="1" type="button" class="aksel-pagination__item aksel-button aksel-button--medium aksel-button--icon-only">
        <span class="aksel-button__icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-labelledby="title-R1d">
            <title id="title-R1d">Forrige</title>
            <path fill="currentColor" fill-rule="evenodd" d="M14.53 5.97a.75.75 0 0 1 0 1.06L9.56 12l4.97 4.97a.75.75 0 1 1-1.06 1.06l-5.5-5.5a.75.75 0 0 1 0-1.06l5.5-5.5a.75.75 0 0 1 1.06 0" clip-rule="evenodd">
          </path>
        </svg>
      </span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="1" page="1" type="button" class="aksel-pagination__item aksel-button aksel-button--medium">
      <span class="aksel-label">1</span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="true" data-pressed="true" data-page="2" page="2" type="button" class="aksel-pagination__item aksel-pagination__item--selected aksel-button aksel-button--medium">
      <span class="aksel-label">2</span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="3" page="3" type="button" class="aksel-pagination__item aksel-button aksel-button--medium">
      <span class="aksel-label">3</span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="4" page="4" type="button" class="aksel-pagination__item aksel-button aksel-button--medium">
      <span class="aksel-label">4</span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="5" page="5" type="button" class="aksel-pagination__item aksel-button aksel-button--medium">
      <span class="aksel-label">5</span>
    </button>
  </li>
  <li class="aksel-pagination__ellipsis">
    <span class="aksel-body-short aksel-body-short--medium">...</span>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="8" page="8" type="button" class="aksel-pagination__item aksel-button aksel-button--medium">
      <span class="aksel-label">8</span>
    </button>
  </li>
  <li>
    <button data-color="neutral" data-variant="tertiary" aria-current="false" data-pressed="false" data-page="3" page="3" type="button" class="aksel-pagination__item aksel-button aksel-button--medium aksel-button--icon-only">
      <span class="aksel-button__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-labelledby="title-R4t">
          <title id="title-R4t">Neste</title>
          <path fill="currentColor" fill-rule="evenodd" d="M9.47 5.97a.75.75 0 0 1 1.06 0l5.5 5.5a.75.75 0 0 1 0 1.06l-5.5 5.5a.75.75 0 1 1-1.06-1.06L14.44 12 9.47 7.03a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
        </path>
      </svg>
    </span>
  </button>
</li>
</ul>
</nav>
```

## Layout og innholdsgruppering

### Accordion

Sammenleggbare seksjoner. defaultOpen på første.

```html
<div class="aksel-accordion aksel-accordion--medium aksel-accordion--indent">
  <div class="aksel-accordion__item aksel-accordion__item--open" data-expanded="true">
    <button class="aksel-accordion__header" aria-expanded="true" type="button">
      <span class="aksel-accordion__icon-wrapper">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" class="aksel-accordion__header-chevron" aria-hidden="true">
          <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
        </path>
      </svg>
    </span>
    <span class="aksel-heading aksel-heading--xsmall">Hva er dagpenger?</span>
  </button>
  <div class="aksel-accordion__content aksel-body-long aksel-body-long--medium">
    <div class="aksel-accordion__content-inner" data-color="accent">Dagpenger er en ytelse hvis du er arbeidsledig.</div>
  </div>
</div>
<div class="aksel-accordion__item" data-expanded="false">
  <button class="aksel-accordion__header" aria-expanded="false" type="button">
    <span class="aksel-accordion__icon-wrapper">
      <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" class="aksel-accordion__header-chevron" aria-hidden="true">
        <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
      </path>
    </svg>
  </span>
  <span class="aksel-heading aksel-heading--xsmall">Hvem kan få?</span>
</button>
<div class="aksel-accordion__content aksel-accordion__content--closed aksel-body-long aksel-body-long--medium">
  <div class="aksel-accordion__content-inner" data-color="accent">Du må være registrert som arbeidssøker.</div>
</div>
</div>
</div>
```

### ExpansionCard

Utvidbart kort med tittel + beskrivelse.

```html
<section data-color="neutral" aria-label="Om søknaden" class="aksel-expansioncard aksel-expansioncard--medium">
  <div class="aksel-expansioncard__header" data-open="false">
    <div>
      <h3 class="aksel-expansioncard__title aksel-expansioncard__title--medium aksel-heading aksel-heading--medium">Om søknaden</h3>
      <p class="aksel-link-panel__description aksel-body-long aksel-body-long--medium">Les mer om hva du må fylle ut.</p>
    </div>
    <button class="aksel-expansioncard__header-button" type="button" aria-expanded="false">
      <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-labelledby="title-R9" class="aksel-expansioncard__header-chevron">
        <title id="title-R9">Vis mer</title>
        <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
      </path>
    </svg>
  </button>
</div>
<div aria-hidden="true" data-open="false" class="aksel-expansioncard__content aksel-expansioncard__content--closed aksel-body-long aksel-body-long--medium">
  <div class="aksel-expansioncard__content-inner" data-color="accent">Detaljert innhold her.</div>
</div>
</section>
```

### ReadMore

Forklare begreper inline.

```html
<div class="aksel-read-more aksel-read-more--medium" data-variant="ghost" data-state="closed">
  <button type="button" class="aksel-read-more__button aksel-body-short" aria-expanded="false">
    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" class="aksel-read-more__expand-icon" aria-hidden="true">
      <path fill="currentColor" fill-rule="evenodd" d="M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06" clip-rule="evenodd">
    </path>
  </svg>
  <span>Hva betyr inntektsgrunnlag?</span>
</button>
<div class="aksel-read-more__content aksel-body-long aksel-body-long--medium">Inntektsgrunnlaget er ...</div>
</div>
```

### GuidePanel

Vennlig intro/veiledning øverst på side.

```html
<div data-color="info" class="aksel-guide-panel" data-responsive="true">
  <div class="aksel-guide">
    <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg" aria-label="Illustrasjon av veileder" focusable="false" role="img">
      <g clip-path="url(#clip0_1387_21067)">
        <rect width="80" height="80" rx="40" fill="var(--ax-bg-moderate)">
        </rect>
        <path fill-rule="evenodd" clip-rule="evenodd" d="M55.1888 40.4309C53.795 44.9809 51.0663 48.7578 47.5693 51.0691L47.7484 53.0953L47.7474 53.1777L45.857 69.8798H33.8679L33.8181 69.5289L31.5004 53.149L31.5862 51.1003C28.0715 48.7951 25.3274 45.012 23.9257 40.4499C23.8781 40.4544 23.83 40.4567 23.7812 40.4567C22.8745 40.4567 22.1562 39.6596 22.1562 38.694V33.2299C22.1562 32.5826 22.479 32.0107 22.9648 31.704C23.7229 21.5029 30.8443 13.4856 39.554 13.4856C48.2401 13.4856 55.3472 21.4598 56.1376 31.6212C56.7049 31.8987 57.0938 32.5185 57.0938 33.2299V38.694C57.0938 39.6601 56.3765 40.4567 55.4688 40.4567C55.3731 40.4567 55.2796 40.4479 55.1888 40.4309Z" fill="#F5F6F7">
      </path>
      <path fill-rule="evenodd" clip-rule="evenodd" d="M47.1471 51.6344C47.0789 55.2818 43.7373 59.0238 39.625 59.0238C35.4948 59.0238 32.142 55.2492 32.1022 51.5868C29.9622 52.1324 26.6956 53.778 23.9995 56.528C21.3885 59.191 19.3125 63.194 19.3125 66.2992V85H59.9375V66.2992C59.9375 63.1877 57.8167 59.1779 55.1575 56.5118C52.4983 53.8457 49.3007 52.2224 47.1471 51.6344Z" fill="#156389">
    </path>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M31.9671 51.7135C29.9959 52.4334 26.6891 54.0069 24.1875 56.3965C16.875 54.7596 13.625 50.8701 13.625 50.8701C13.625 50.8701 20.3621 44.2597 20.3662 32.698V32.6858C20.3662 19.1479 27.6319 9.80769 39.6022 9.80769C51.5742 9.80769 58.8399 19.1479 58.8399 32.6858H58.883C58.883 44.2556 65.625 50.8701 65.625 50.8701C65.625 50.8701 62.375 54.7596 55.0625 56.3942L55.0515 56.3965C52.6353 54.1854 49.1309 52.48 47.2243 51.759L47.2265 51.7583L47.1508 50.9013L47.1917 50.8303C50.7891 48.5155 53.5804 44.616 54.9262 39.904C55.0909 39.9962 55.277 40.0481 55.4739 40.0481C56.1476 40.0481 56.6928 39.4432 56.6928 38.694V33.2299C56.6928 32.5888 56.2936 32.0529 55.7564 31.9115C55.7559 31.9041 55.7554 31.8967 55.7549 31.8893C38.7466 33.7984 32.6199 22.0681 32.117 22.0673C32.117 22.0673 26.4686 26.1538 23.769 31.0125C23.769 31.0125 23.3576 31.9297 23.3556 31.9605C22.8934 32.1528 22.5637 32.648 22.5637 33.2299V38.694C22.5637 39.4432 23.1103 40.0481 23.7826 40.0481C23.9316 40.0481 24.0743 40.0185 24.2062 39.9643C25.5668 44.6786 28.3759 48.5739 31.9901 50.8733L32.0035 50.9013L31.9695 51.7135H31.9671Z" fill="#A93D70">
  </path>
  <path fill-rule="evenodd" clip-rule="evenodd" d="M33.8159 35.8563C32.766 35.9417 32.4722 34.2696 32.7885 33.1775C32.848 32.9706 33.1956 32.0283 33.8109 32.0283C34.4254 32.0283 34.6968 32.5433 34.7345 32.6319C35.1865 33.6965 34.9645 35.7622 33.8159 35.8563" fill="#202733">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M45.9927 35.8563C47.0425 35.9417 47.3364 34.2696 47.0201 33.1775C46.9606 32.9706 46.613 32.0283 45.9977 32.0283C45.3832 32.0283 45.1118 32.5433 45.0741 32.6319C44.6221 33.6965 44.8441 35.7622 45.9927 35.8563" fill="#202733">
</path>
<path d="M40.2935 37.5041C40.9213 37.396 41.3501 37.4638 41.5036 37.6748C42.0833 38.4721 41.8979 39.3156 40.9035 40.0081C40.3806 40.372 39.661 40.5001 39.28 40.3114C39.0937 40.2191 38.8758 40.3133 38.7934 40.5218C38.7109 40.7304 38.7951 40.9742 38.9814 41.0665C39.6111 41.3784 40.5794 41.206 41.2931 40.7092C42.6445 39.7682 42.9537 38.3611 42.0758 37.1534C41.7042 36.643 41.0465 36.5389 40.1812 36.688C39.9799 36.7227 39.8418 36.9335 39.8728 37.1589C39.9038 37.3842 40.0921 37.5388 40.2935 37.5041Z" fill="#202733">
</path>
<path d="M44.8337 42.9837C44.7968 43.0623 44.7122 43.2128 44.5763 43.4111C44.3463 43.7466 44.0574 44.083 43.7066 44.3967C42.6611 45.3315 41.3002 45.8721 39.5683 45.8226C37.8795 45.7744 36.5247 45.2422 35.4626 44.384C35.0726 44.0689 34.7506 43.7315 34.4933 43.3951C34.3415 43.1967 34.2468 43.0464 34.2053 42.968C34.1056 42.7795 33.8606 42.7019 33.6581 42.7946C33.4555 42.8874 33.3721 43.1154 33.4718 43.3039C33.5318 43.4175 33.6487 43.6029 33.8273 43.8364C34.1206 44.2197 34.4852 44.6019 34.9266 44.9585C36.1256 45.9273 37.6579 46.5293 39.5432 46.5831C41.5064 46.6391 43.0759 46.0157 44.273 44.9453C44.6733 44.5875 45.0023 44.2043 45.2656 43.8203C45.4257 43.5868 45.5298 43.4015 45.5829 43.2882C45.6733 43.0956 45.5788 42.8714 45.3719 42.7873C45.165 42.7033 44.924 42.7912 44.8337 42.9837Z" fill="#202733">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M53.8629 70.5H42.8865C42.3966 70.5 42 70.0974 42 69.6V63.609C42 63.1117 42.3966 62.7083 42.8865 62.7083H53.8629C54.3527 62.7083 54.75 63.1117 54.75 63.609V69.6C54.75 70.0974 54.3527 70.5 53.8629 70.5" fill="white">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M49.0346 63.9451H47.8971C47.8128 63.9451 47.7449 63.8775 47.7449 63.7937V63.6029C47.7449 63.5197 47.8128 63.4515 47.8971 63.4515H49.0346C49.1188 63.4515 49.1867 63.5197 49.1867 63.6029V63.7937C49.1867 63.8775 49.1188 63.9451 49.0346 63.9451" fill="#202733">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M48.1365 63.7708H48.7955V62H48.1365V63.7708Z" fill="#818997">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M52.5417 65.5H51.6457C51.6457 65.5 51.5839 65.5 51.5621 65.5545L51.0662 67.0725L50.5708 65.5545C50.5489 65.5 50.4868 65.5 50.4868 65.5H48.764C48.7267 65.5 48.6954 65.5311 48.6954 65.5682V66.0837C48.6954 65.6748 48.2603 65.5 48.0055 65.5C47.4349 65.5 47.053 65.8758 46.934 66.4472C46.9276 66.0681 46.8961 65.9323 46.794 65.7932C46.7471 65.7251 46.6793 65.6678 46.6055 65.6204C46.4535 65.5314 46.317 65.5 46.0237 65.5H45.6794C45.6794 65.5 45.6171 65.5 45.5952 65.5545L45.2818 66.331V65.5682C45.2818 65.5311 45.2508 65.5 45.2136 65.5H44.4167C44.4167 65.5 44.3552 65.5 44.3328 65.5545L44.0071 66.362C44.0071 66.362 43.9746 66.4427 44.0489 66.4427H44.3552V67.9813C44.3552 68.0195 44.3853 68.0497 44.4236 68.0497H45.2136C45.2508 68.0497 45.2818 68.0195 45.2818 67.9813V66.4427H45.5898C45.7664 66.4427 45.8039 66.4475 45.8726 66.4796C45.914 66.4952 45.9513 66.5268 45.9716 66.5633C46.0133 66.6417 46.0237 66.7359 46.0237 67.0135V67.9813C46.0237 68.0195 46.0544 68.0497 46.0923 68.0497H46.8494C46.8494 68.0497 46.935 68.0497 46.9688 67.9652L47.1366 67.5505C47.3597 67.863 47.7269 68.0497 48.1833 68.0497H48.283C48.283 68.0497 48.3691 68.0497 48.4032 67.9652L48.6954 67.2415V67.9813C48.6954 68.0195 48.7267 68.0497 48.764 68.0497H49.5368C49.5368 68.0497 49.6221 68.0497 49.6564 67.9652C49.6564 67.9652 49.9655 67.1978 49.9667 67.192H49.9671C49.979 67.1281 49.8983 67.1281 49.8983 67.1281H49.6225V65.8113L50.4904 67.9652C50.5243 68.0497 50.6097 68.0497 50.6097 68.0497H51.5228C51.5228 68.0497 51.6087 68.0497 51.6426 67.9652L52.6048 65.5826C52.6381 65.5 52.5417 65.5 52.5417 65.5V65.5ZM48.6954 67.128H48.1763C47.9696 67.128 47.8015 66.9607 47.8015 66.7538C47.8015 66.5473 47.9696 66.3789 48.1763 66.3789H48.3215C48.5276 66.3789 48.6954 66.5473 48.6954 66.7538V67.128Z" fill="#C30000">
</path>
</g>
<defs>
  <clipPath id="clip0_1387_21067">
    <rect width="80" height="80" rx="40" fill="white">
    </rect>
  </clipPath>
</defs>
</svg>
</div>
<div class="aksel-guide-panel__content">
  <svg viewBox="0 0 33 22" width="33" height="22" fill="none" xmlns="http://www.w3.org/2000/svg" class="aksel-guide-panel__tail">
    <path d="M8.74229e-08 22L0 20L33 20V22L8.74229e-08 22Z" fill="var(--ax-bg-raised)">
  </path>
  <path d="M31 20.0001L2 20.0001C2.09817 10.0296 3 7.00011 6 2.00011C8 12.5001 20 20.0001 31 20.0001Z" fill="var(--ax-bg-raised)">
</path>
<path fill-rule="evenodd" clip-rule="evenodd" d="M0 20C-2.87106e-10 19.9934 3.21047e-05 19.987 9.68646e-05 19.9804C0.0494722 14.9659 0.299239 11.5341 0.964025 8.68212C1.64231 5.77217 2.72947 3.56367 4.28501 0.971094C4.71185 0.259692 5.53358 -0.114327 6.35038 0.0310157C7.16718 0.176359 7.80944 0.810884 7.96467 1.62586C8.84145 6.22896 11.9453 10.3172 16.2599 13.2908C20.5715 16.2623 25.9294 18.0001 31 18.0001C32.1046 18.0001 33 18.8954 33 20L0 20ZM6.755 4.70521C8.97688 10.7068 14.4934 15.469 20.8803 18.0001C24.1345 19.2897 27.6146 20.0001 31 20.0001L2 20.0001C2.00689 19.3003 2.01774 18.6346 2.033 18.0001C2.19625 11.2107 2.86405 7.98363 4.58479 4.54371C4.9944 3.72487 5.46367 2.89399 6 2.00011C6.17639 2.92619 6.43058 3.82889 6.755 4.70521Z" fill="var(--ax-border-default)">
</path>
</svg>
<div class="aksel-guide-panel__content-inner" data-color="accent">Her søker du om dagpenger. Det tar ca. 10 minutter.</div>
</div>
</div>
```

### LinkCard

Fremhevet lenke med kontekst.

```html
<div data-color="neutral" data-align-arrow="baseline" class="aksel-link-anchor__overlay aksel-link-card aksel-link-card--medium aksel-body-long aksel-body-long--medium">
  <span class="aksel-link-card__title aksel-heading aksel-heading--small">
    <a href="#" class="aksel-link-anchor">Søk om dagpenger</a>
  </span>
  <div class="aksel-link-card__description">Start en ny søknad.</div>
  <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-hidden="true" class="aksel-link-anchor__arrow aksel-link-card__arrow" font-size="1.75rem">
    <path fill="currentColor" d="M14.088 6.873a.75.75 0 0 1 .942.097l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 0 1-1.06-1.06l3.22-3.22H5a.75.75 0 0 1-.75-.74V12a.75.75 0 0 1 .75-.75h12.19l-3.22-3.22a.75.75 0 0 1 .118-1.157">
  </path>
</svg>
</div>
```

### Box

Layout-primitiv med bakgrunn/ramme/padding via tokens.

```html
<div style="--__axc-r-p-xs:var(--ax-6);--__axc-box-background:var(--ax-bg-surface-subtle);--__axc-box-radius-xs:var(--ax-radius-large)" class="aksel-r-p aksel-box aksel-box-bg aksel-box-radius">
  <p class="aksel-body-short aksel-body-short--medium">Innhold i en Box.</p>
</div>
```

## Overlegg (modaler, popovere)

### Modal

Dialog over innholdet. open vises her; i VC vis åpen tilstand inline.

```html
<dialog aria-label="Bekreft" class="aksel-modal aksel-modal--medium aksel-modal--autowidth">
  <div class="aksel-modal__header">
    <button data-color="neutral" data-variant="tertiary" type="button" class="aksel-modal__button aksel-button aksel-button--small aksel-button--icon-only">
      <span class="aksel-button__icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 24 24" focusable="false" role="img" aria-labelledby="title-R1b">
          <title id="title-R1b">Lukk</title>
          <path fill="currentColor" d="M6.53 5.47a.75.75 0 0 0-1.06 1.06L10.94 12l-5.47 5.47a.75.75 0 1 0 1.06 1.06L12 13.06l5.47 5.47a.75.75 0 1 0 1.06-1.06L13.06 12l5.47-5.47a.75.75 0 0 0-1.06-1.06L12 10.94z">
        </path>
      </svg>
    </span>
  </button>
  <h1 id="R0" class="aksel-heading aksel-heading--medium">Bekreft innsending</h1>
</div>
<div class="aksel-modal__body">
  <p class="aksel-body-long aksel-body-long--medium">Vil du sende søknaden nå?</p>
</div>
<div class="aksel-modal__footer">
  <button data-variant="primary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Send</span>
  </button>
  <button data-variant="secondary" class="aksel-button aksel-button--medium">
    <span class="aksel-label">Avbryt</span>
  </button>
</div>
</dialog>
```

## Navigasjon

### Tabs

Faner. Fast antall.

```html
<div class="aksel-tabs aksel-tabs--medium">
  <div class="aksel-tabs__tablist-wrapper">
    <div class="aksel-tabs__tablist" role="tablist" aria-orientation="horizontal">
      <button class="aksel-tabs__tab aksel-tabs__tab--medium aksel-tabs__tab-icon--left" type="button" id="tabs-R0--tab-soknader" aria-controls="tabs-R0--tabpanel-soknader" tabindex="0" aria-selected="true" data-state="active" role="tab" data-aksel-tab="">
        <span class="aksel-tabs__tab-inner aksel-body-short aksel-body-short--medium">
          <span aria-hidden="true">
          </span>
          <span>Søknader</span>
        </span>
      </button>
      <button class="aksel-tabs__tab aksel-tabs__tab--medium aksel-tabs__tab-icon--left" type="button" id="tabs-R0--tab-vedtak" aria-controls="tabs-R0--tabpanel-vedtak" tabindex="-1" aria-selected="false" data-state="inactive" role="tab" data-aksel-tab="">
        <span class="aksel-tabs__tab-inner aksel-body-short aksel-body-short--medium">
          <span aria-hidden="true">
          </span>
          <span>Vedtak</span>
        </span>
      </button>
    </div>
  </div>
  <div class="aksel-tabs__tabpanel" role="tabpanel" tabindex="0" aria-labelledby="tabs-R0--tab-soknader" id="tabs-R0--tabpanel-soknader" data-state="active">Dine søknader</div>
</div>
```

### Link

Navigasjon (ikke handling → Button).

```html
<a href="#" class="aksel-link">Les mer om dagpenger</a>
```

### Stepper

Generell stegindikator. Søknad → bruk FormProgress.

```html
<ol class="aksel-stepper" data-orientation="vertical">
  <li class="aksel-stepper__item" data-interactive="true">
    <span class="aksel-stepper__line aksel-stepper__line--1">
    </span>
    <a class="aksel-stepper__step aksel-stepper__step--behind" data-active="false" data-completed="false" data-interactive="true">
      <span aria-hidden="true" class="aksel-stepper__circle aksel-label">1</span>
      <span class="aksel-stepper__content aksel-label">Om deg</span>
    </a>
    <span class="aksel-stepper__line aksel-stepper__line--2">
    </span>
  </li>
  <li class="aksel-stepper__item" data-interactive="true">
    <span class="aksel-stepper__line aksel-stepper__line--1">
    </span>
    <a aria-current="step" class="aksel-stepper__step aksel-stepper__step--active" data-active="true" data-completed="false" data-interactive="true">
      <span aria-hidden="true" class="aksel-stepper__circle aksel-label">2</span>
      <span class="aksel-stepper__content aksel-label">Inntekt</span>
    </a>
    <span class="aksel-stepper__line aksel-stepper__line--2">
    </span>
  </li>
  <li class="aksel-stepper__item" data-interactive="true">
    <span class="aksel-stepper__line aksel-stepper__line--1">
    </span>
    <a class="aksel-stepper__step" data-active="false" data-completed="false" data-interactive="true">
      <span aria-hidden="true" class="aksel-stepper__circle aksel-label">3</span>
      <span class="aksel-stepper__content aksel-label">Oppsummering</span>
    </a>
    <span class="aksel-stepper__line aksel-stepper__line--2">
    </span>
  </li>
</ol>
```

### Timeline

Tidslinje — kun interne flater, ikke mobil.

```html
<div>
  <div class="aksel-timeline">
    <div class="aksel-timeline__axislabels" aria-hidden="true">
      <div style="justify-content:flex-start;left:96.9696970037071%;width:3.0303030313658468%" class="aksel-timeline__axislabels-label aksel-detail">02.02</div>
      <div style="justify-content:flex-start;left:84.84848487824371%;width:3.030303031365861%" class="aksel-timeline__axislabels-label aksel-detail">29.01</div>
      <div style="justify-content:flex-start;left:72.72727275278032%;width:3.030303031365861%" class="aksel-timeline__axislabels-label aksel-detail">25.01</div>
      <div style="justify-content:flex-start;left:60.606060627316936%;width:3.030303031365861%" class="aksel-timeline__axislabels-label aksel-detail">21.01</div>
      <div style="justify-content:flex-start;left:48.48484850185355%;width:3.0303030313658468%" class="aksel-timeline__axislabels-label aksel-detail">17.01</div>
      <div style="justify-content:flex-start;left:36.36363637639016%;width:3.030303031365854%" class="aksel-timeline__axislabels-label aksel-detail">13.01</div>
      <div style="justify-content:flex-start;left:24.242424250926774%;width:3.0303030313658503%" class="aksel-timeline__axislabels-label aksel-detail">09.01</div>
      <div style="justify-content:flex-start;left:12.121212125463387%;width:3.0303030313658468%" class="aksel-timeline__axislabels-label aksel-detail">05.01</div>
    </div>
    <h3 class="aksel-timeline__row-label aksel-body-short aksel-body-short--small">Saksbehandling</h3>
    <div class="aksel-timeline__row aksel-timeline__row--active" tabindex="-1" data-timeline-row="true">
      <ol aria-label="01.01.2024 til 01.02.2024" class="aksel-timeline__row-periods">
        <li>
          <div data-timeline-period="true" tabindex="-1" data-color="success" class="aksel-timeline__period aksel-timeline__period--success" style="width:96.96969696863415%;left:0%">
            <span class="aksel-timeline__period--inner">
              <span class="aksel-sr-only">Suksess fra 01.01.2024 til 01.02.2024</span>
            </span>
          </div>
        </li>
      </ol>
    </div>
  </div>
</div>
```

## Typografi

### Heading

size: xlarge | large | medium | small | xsmall. level styrer h1–h6.

```html
<div style="display:flex;flex-direction:column;gap:8px">
  <h1 class="aksel-heading aksel-heading--large">Sidetittel</h1>
  <h2 class="aksel-heading aksel-heading--medium">Seksjonstittel</h2>
</div>
```

### BodyLong / BodyShort

Brødtekst. BodyLong for avsnitt, BodyShort for korte linjer.

```html
<div style="display:flex;flex-direction:column;gap:8px">
  <p class="aksel-body-long aksel-body-long--medium">Et lengre avsnitt med brødtekst som forklarer noe.</p>
  <p class="aksel-body-short aksel-body-short--medium">Kort tekstlinje.</p>
</div>
```

### Ingress

Ledetekst/ingress under tittel.

```html
<p class="aksel-ingress">Her søker du om dagpenger hvis du er arbeidsledig.</p>
```

### Label

Frittstående label/etikett.

```html
<label class="aksel-label">Beløp</label>
```

### Detail

Liten metadata-tekst.

```html
<p class="aksel-detail">Sist oppdatert 1. mars 2024</p>
```

### List

Punktliste eller nummerert liste.

```html
<div title="Du trenger:" class="aksel-list aksel-list--medium aksel-body-long aksel-body-long--medium">
  <ul role="list">
    <li class="aksel-list__item">
      <div class="aksel-list__item-marker aksel-list__item-marker--bullet">
        <svg viewBox="0 0 6 6" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" role="img">
          <rect width="6" height="6" rx="3" fill="currentColor">
          </rect>
        </svg>
      </div>
      <div>Fødselsnummer</div>
    </li>
    <li class="aksel-list__item">
      <div class="aksel-list__item-marker aksel-list__item-marker--bullet">
        <svg viewBox="0 0 6 6" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" role="img">
          <rect width="6" height="6" rx="3" fill="currentColor">
          </rect>
        </svg>
      </div>
      <div>Kontonummer</div>
    </li>
  </ul>
</div>
```

## Data og tabeller

### Table

Tabell med header + rader. Bruk Zebra for lange tabeller.

```html
<table class="aksel-table aksel-table--medium">
  <thead class="aksel-table__header">
    <tr class="aksel-table__row aksel-table__row--shade-on-hover" data-interactive="false">
      <th class="aksel-table__header-cell aksel-label">Periode</th>
      <th class="aksel-table__header-cell aksel-label">Beløp</th>
    </tr>
  </thead>
  <tbody class="aksel-table__body">
    <tr class="aksel-table__row aksel-table__row--shade-on-hover" data-interactive="false">
      <td class="aksel-table__data-cell aksel-body-short aksel-body-short--medium">Januar 2024</td>
      <td class="aksel-table__data-cell aksel-body-short aksel-body-short--medium">12 340 kr</td>
    </tr>
  </tbody>
</table>
```

## Dekoratør og interne flater

### InternalHeader

Header for interne Nav-flater.

```html
<header class="aksel-theme dark aksel-internalheader" data-background="false" data-color="accent">
  <a href="#" class="aksel-internalheader__title aksel-body-short">
    <span>Saksbehandling</span>
  </a>
  <div class="aksel-internalheader__user">
    <div>
      <div class="aksel-body-short aksel-body-short--small">Ola Saksbehandler</div>
    </div>
  </div>
</header>
```

## Dekning og vedlikehold

Generert fra 48 representative komponent-eksempler som speiler
`aksel-figma-katalog.md`. Interaktive overlegg (Modal/Tooltip/HelpText/Combobox)
vises i åpen/statisk tilstand — i VC viser du dem inline. Komponenter som krever
hooks (DatePicker/MonthPicker) rendrer som et felt med kalenderknapp; selve
kalenderen er interaktiv og hører hjemme i Figma-katalogen eller en ds-react-prototype.

Regenerer ved Aksel-oppgradering: `node scripts/generate_markup_fasit.mjs`.
