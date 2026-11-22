import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import WORK_THEME_OBJECT from '@salesforce/schema/CE_Work_Theme__c';
import MAIN_THEME_FIELD from '@salesforce/schema/CE_Work_Theme__c.Main_Theme__c';
import getRegisteredThemes from '@salesforce/apex/CE_NewOpportunityController.getRegisteredThemes';

export const NAME_MAX_LENGTH = 80;
export const TEXT_MAX_LENGTH = 255;

const ERROR_LOAD = 'Kunne ikke hente yrkestemaene. Lukk vinduet og prøv igjen, eller kontakt brukerstøtte.';
const ERROR_LOADING = 'Vent til skjemaet er ferdig lastet.';
const ERROR_NO_THEMES = 'Du kan ikke opprette en mulighet før jobbsporet har et registrert yrkestema.';
const ERROR_REQUIRED = 'Fyll ut de obligatoriske feltene som er markert.';
const ERROR_NAME_BLANK = 'Skriv inn navn på muligheten.';
const ERROR_ACCOUNT_REQUIRED = 'Velg en arbeidsgiver.';

export default class CeNewDiscoveryOpportunity extends LightningElement {
    @api recordId;
    @api errorMessage;
    // Retained for older Flow versions; no longer displayed or saved.
    @api status;

    selectedThemeId = '';
    nameValue = '';
    descriptionValue = '';
    accountValue = null;

    themes = [];
    themesLoaded = false;
    picklistsLoaded = false;
    selectionInitialized = false;
    loadError;
    serverErrorHidden = false;
    recordTypeId;
    mainThemeLabels = {};

    @api
    get themeId() {
        return this.selectedThemeId;
    }
    set themeId(value) {
        this.selectedThemeId = value || '';
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

    @wire(getPicklistValues, { fieldApiName: MAIN_THEME_FIELD, recordTypeId: '$recordTypeId' })
    wiredPicklistValues({ data, error }) {
        if (data) {
            this.mainThemeLabels = Object.fromEntries(data.values.map(({ label, value }) => [value, label]));
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
        if (this.selectedThemeId && !this.selectedTheme) {
            this.selectedThemeId = '';
            this.notifyFlow('themeId', '');
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

    handleAccountChange(event) {
        this.accountValue = event.detail.recordId || null;
        event.target.setCustomValidity('');
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
        const accountInput = this.template.querySelector('lightning-record-picker[data-id="account"]');
        if (accountInput) {
            accountInput.setCustomValidity(this.accountValue ? '' : ERROR_ACCOUNT_REQUIRED);
        }
        this.template
            .querySelectorAll('lightning-combobox, lightning-input, lightning-textarea, lightning-record-picker')
            .forEach((input) => input.reportValidity());

        const isValid =
            this.hasSelectedTheme &&
            Boolean(this.accountValue) &&
            Boolean(this.nameValue.trim()) &&
            this.nameValue.trim().length <= NAME_MAX_LENGTH &&
            this.descriptionValue.length <= TEXT_MAX_LENGTH;
        return isValid ? { isValid: true } : { isValid: false, errorMessage: ERROR_REQUIRED };
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
