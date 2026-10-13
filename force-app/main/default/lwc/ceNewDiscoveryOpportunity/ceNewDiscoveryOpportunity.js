import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import WORK_THEME_OBJECT from '@salesforce/schema/CE_Work_Theme__c';
import MAIN_THEME_FIELD from '@salesforce/schema/CE_Work_Theme__c.Main_Theme__c';
import SUB_THEME_FIELD from '@salesforce/schema/CE_Work_Theme__c.Sub_Theme__c';
import getRegisteredThemes from '@salesforce/apex/CE_NewOpportunityController.getRegisteredThemes';

export const NAME_MAX_LENGTH = 80;
export const TEXT_MAX_LENGTH = 255;

const ERROR_LOAD = 'Kunne ikke hente hovedtemaene. Lukk vinduet og prøv igjen, eller kontakt brukerstøtte.';
const ERROR_LOADING = 'Vent til skjemaet er ferdig lastet.';
const ERROR_NO_THEMES = 'Du kan ikke opprette en mulighet før jobbsporet har et registrert hovedtema.';
const ERROR_REQUIRED = 'Fyll ut de obligatoriske feltene som er markert.';
const ERROR_NAME_BLANK = 'Skriv inn navn på muligheten.';

function splitValues(value) {
    if (typeof value !== 'string') {
        return [];
    }
    return [
        ...new Set(
            value
                .split(';')
                .map((part) => part.trim())
                .filter(Boolean)
        )
    ];
}

export default class CeNewDiscoveryOpportunity extends LightningElement {
    @api recordId;
    @api errorMessage;

    selectedThemeId = '';
    selectedSubThemes = [];
    nameValue = '';
    descriptionValue = '';
    statusValue = '';
    accountValue = null;

    themes = [];
    themesLoaded = false;
    picklistsLoaded = false;
    selectionInitialized = false;
    loadError;
    serverErrorHidden = false;
    recordTypeId;
    mainThemeLabels = {};
    subThemeValues = [];
    subThemeControllerValues = {};

    @api
    get themeId() {
        return this.selectedThemeId;
    }
    set themeId(value) {
        this.selectedThemeId = value || '';
    }

    @api
    get subThemes() {
        return this.selectedSubThemes.join(';');
    }
    set subThemes(value) {
        this.selectedSubThemes = splitValues(value);
    }

    @api
    get opportunityName() {
        return this.nameValue;
    }
    set opportunityName(value) {
        this.nameValue = value || '';
    }

    @api
    get description() {
        return this.descriptionValue;
    }
    set description(value) {
        this.descriptionValue = value || '';
    }

    @api
    get status() {
        return this.statusValue;
    }
    set status(value) {
        this.statusValue = value || '';
    }

    @api
    get accountId() {
        return this.accountValue;
    }
    set accountId(value) {
        this.accountValue = value || null;
    }

    connectedCallback() {
        this.loadThemes();
    }

    @wire(getObjectInfo, { objectApiName: WORK_THEME_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.loadError = ERROR_LOAD;
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: WORK_THEME_OBJECT, recordTypeId: '$recordTypeId' })
    wiredPicklistValues({ data, error }) {
        if (data) {
            const mainField = data.picklistFieldValues[MAIN_THEME_FIELD.fieldApiName];
            const subField = data.picklistFieldValues[SUB_THEME_FIELD.fieldApiName];
            this.mainThemeLabels = Object.fromEntries(
                (mainField?.values || []).map(({ label, value }) => [value, label])
            );
            this.subThemeValues = subField?.values || [];
            this.subThemeControllerValues = subField?.controllerValues || {};
            this.picklistsLoaded = true;
            this.initializeSelection();
        } else if (error) {
            this.loadError = ERROR_LOAD;
        }
    }

    async loadThemes() {
        try {
            const themes = await getRegisteredThemes({ workTrailId: this.recordId });
            this.themes = Array.isArray(themes) ? themes : [];
            this.themesLoaded = true;
            this.initializeSelection();
        } catch {
            this.loadError = ERROR_LOAD;
        }
    }

    // Runs once both the themes and the picklist metadata are loaded. A theme ID from the flow means the
    // screen is shown again (for example after a failed save), so the user's earlier choices are kept.
    initializeSelection() {
        if (this.selectionInitialized || !this.themesLoaded || !this.picklistsLoaded) {
            return;
        }
        this.selectionInitialized = true;
        if (this.selectedTheme) {
            this.applySubThemes(this.selectedSubThemes);
        } else if (this.selectedThemeId || this.selectedSubThemes.length) {
            this.selectedThemeId = '';
            this.selectedSubThemes = [];
            this.notifyFlow('themeId', '');
            this.notifyFlow('subThemes', '');
        }
    }

    get isLoading() {
        return !this.loadError && (!this.themesLoaded || !this.picklistsLoaded);
    }

    get hasNoThemes() {
        return !this.isLoading && !this.loadError && this.themes.length === 0;
    }

    get showForm() {
        return !this.isLoading && !this.loadError && this.themes.length > 0;
    }

    get themeOptions() {
        return this.themes.map((theme) => ({ label: this.getThemeLabel(theme), value: theme.recordId }));
    }

    get selectedTheme() {
        return this.themes.find((theme) => theme.recordId === this.selectedThemeId);
    }

    get hasSelectedTheme() {
        return Boolean(this.selectedTheme);
    }

    get selectedThemeLabel() {
        return this.selectedTheme ? this.getThemeLabel(this.selectedTheme) : '';
    }

    get subThemeOptions() {
        const theme = this.selectedTheme;
        const controllerIndex = theme?.mainTheme ? this.subThemeControllerValues[theme.mainTheme] : undefined;
        if (controllerIndex === undefined) {
            return [];
        }
        return this.subThemeValues
            .filter((option) => (option.validFor || []).includes(controllerIndex))
            .map(({ label, value }) => ({ label, value }));
    }

    get hasSubThemeOptions() {
        return this.subThemeOptions.length > 0;
    }

    get subThemeHelpText() {
        return `Undertemaene du velger, lagres på hovedtemaet «${this.selectedThemeLabel}» på jobbsporet. Fjerner du et undertema her, blir det også fjernet fra hovedtemaet.`;
    }

    // Values stored on the theme that are no longer valid for its main theme. They are removed on save.
    get removedSubThemes() {
        const allowedValues = new Set(this.subThemeOptions.map(({ value }) => value));
        return (this.selectedTheme?.subThemes || []).filter((value) => !allowedValues.has(value));
    }

    get hasRemovedSubThemes() {
        return this.removedSubThemes.length > 0;
    }

    get removedSubThemesText() {
        return `Disse lagrede undertemaene passer ikke til hovedtemaet og blir fjernet når du lagrer: ${this.removedSubThemes.join(
            ', '
        )}.`;
    }

    get showServerError() {
        return Boolean(this.errorMessage) && !this.serverErrorHidden;
    }

    get nameMaxLength() {
        return NAME_MAX_LENGTH;
    }

    get textMaxLength() {
        return TEXT_MAX_LENGTH;
    }

    handleThemeChange(event) {
        this.selectedThemeId = event.detail.value || '';
        this.notifyFlow('themeId', this.selectedThemeId);
        this.applySubThemes(this.selectedTheme?.subThemes || []);
        this.hideServerError();
    }

    handleSubThemesChange(event) {
        this.applySubThemes(event.detail.value || []);
        this.hideServerError();
    }

    handleNameChange(event) {
        this.nameValue = event.detail.value || '';
        event.target.setCustomValidity('');
        this.notifyFlow('opportunityName', this.nameValue.trim());
        this.hideServerError();
    }

    handleDescriptionChange(event) {
        this.descriptionValue = event.detail.value || '';
        this.notifyFlow('description', this.descriptionValue);
        this.hideServerError();
    }

    handleStatusChange(event) {
        this.statusValue = event.detail.value || '';
        this.notifyFlow('status', this.statusValue);
        this.hideServerError();
    }

    handleAccountChange(event) {
        this.accountValue = event.detail.recordId || null;
        this.notifyFlow('accountId', this.accountValue || '');
        this.hideServerError();
    }

    @api
    validate() {
        if (this.isLoading) {
            return { isValid: false, errorMessage: ERROR_LOADING };
        }
        if (this.loadError) {
            return { isValid: false, errorMessage: this.loadError };
        }
        if (this.themes.length === 0) {
            return { isValid: false, errorMessage: ERROR_NO_THEMES };
        }

        const nameInput = this.template.querySelector('lightning-input[data-id="name"]');
        if (nameInput) {
            nameInput.setCustomValidity(this.nameValue && !this.nameValue.trim() ? ERROR_NAME_BLANK : '');
        }
        this.template
            .querySelectorAll('lightning-combobox, lightning-input, lightning-textarea, lightning-checkbox-group')
            .forEach((input) => input.reportValidity());

        const isValid =
            this.hasSelectedTheme &&
            Boolean(this.nameValue.trim()) &&
            this.nameValue.trim().length <= NAME_MAX_LENGTH &&
            this.descriptionValue.length <= TEXT_MAX_LENGTH &&
            this.statusValue.length <= TEXT_MAX_LENGTH;
        return isValid ? { isValid: true } : { isValid: false, errorMessage: ERROR_REQUIRED };
    }

    applySubThemes(values) {
        const allowedValues = new Set(this.subThemeOptions.map(({ value }) => value));
        this.selectedSubThemes = values.filter((value) => allowedValues.has(value));
        this.notifyFlow('subThemes', this.subThemes);
    }

    getThemeLabel(theme) {
        return (theme.mainTheme && this.mainThemeLabels[theme.mainTheme]) || theme.mainTheme || theme.name;
    }

    hideServerError() {
        this.serverErrorHidden = true;
    }

    notifyFlow(attributeName, value) {
        this.dispatchEvent(new FlowAttributeChangeEvent(attributeName, value));
    }
}
