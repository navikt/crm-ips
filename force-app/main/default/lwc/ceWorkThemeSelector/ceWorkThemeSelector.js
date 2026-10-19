import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRegisteredThemes from '@salesforce/apex/CE_NewOpportunityController.getRegisteredThemes';
import WORK_THEME_OBJECT from '@salesforce/schema/CE_Work_Theme__c';
import MAIN_THEME_FIELD from '@salesforce/schema/CE_Work_Theme__c.Main_Theme__c';

const ERROR_LOAD = 'Kunne ikke laste inn tilgjengelige yrkestemaer. Prøv igjen.';
const ERROR_REQUIRED = 'Velg minst ett yrkestema.';

function splitValues(value) {
    if (typeof value !== 'string') {
        return [];
    }
    return [
        ...new Set(
            value
                .split(';')
                .map((item) => item.trim())
                .filter(Boolean)
        )
    ];
}

export default class CeWorkThemeSelector extends LightningElement {
    @api recordId;
    @api availableActions = [];

    selectedThemeValues = [];
    existingThemeValues = new Set();
    picklistOptions = [];
    existingThemesLoaded = false;
    picklistLoaded = false;
    loadError;
    validationError;
    recordTypeId;

    @api
    get selectedThemes() {
        return this.selectedThemeValues.join(';');
    }
    set selectedThemes(value) {
        this.selectedThemeValues = splitValues(value);
        this.retainAvailableSelections();
    }

    connectedCallback() {
        this.loadExistingThemes();
    }

    @wire(getObjectInfo, { objectApiName: WORK_THEME_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.loadError = ERROR_LOAD;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MAIN_THEME_FIELD })
    wiredMainThemes({ data, error }) {
        if (data) {
            this.picklistOptions = data.values.map(({ label, value }) => ({ label, value }));
            this.picklistLoaded = true;
            this.retainAvailableSelections();
        } else if (error) {
            this.loadError = ERROR_LOAD;
        }
    }

    async loadExistingThemes() {
        try {
            const themes = await getRegisteredThemes({ workTrailId: this.recordId });
            this.existingThemeValues = new Set(themes.map((theme) => theme.mainTheme).filter(Boolean));
            this.existingThemesLoaded = true;
            this.retainAvailableSelections();
        } catch {
            this.loadError = ERROR_LOAD;
        }
    }

    get isLoading() {
        return !this.loadError && (!this.existingThemesLoaded || !this.picklistLoaded);
    }

    get availableOptions() {
        return this.picklistOptions.filter(({ value }) => !this.existingThemeValues.has(value));
    }

    get hasAvailableThemes() {
        return this.availableOptions.length > 0;
    }

    get noThemesAvailable() {
        return this.existingThemesLoaded && this.picklistLoaded && !this.hasAvailableThemes;
    }

    get showSelectButton() {
        return !this.isLoading && !this.loadError && this.hasAvailableThemes;
    }

    handleNext() {
        const result = this.validate();
        this.reportValidity();
        if (!result.isValid) {
            return;
        }
        if (this.availableActions.includes('NEXT') || this.availableActions.includes('FINISH')) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }

    handleSelectionChange(event) {
        this.selectedThemeValues = event.detail.value || [];
        if (this.validationError) {
            this.reportValidity();
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('selectedThemes', this.selectedThemes));
    }

    retainAvailableSelections() {
        if (!this.existingThemesLoaded || !this.picklistLoaded) {
            return;
        }
        const availableValues = new Set(this.availableOptions.map(({ value }) => value));
        const retainedValues = this.selectedThemeValues.filter((value) => availableValues.has(value));
        if (retainedValues.length !== this.selectedThemeValues.length) {
            this.selectedThemeValues = retainedValues;
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedThemes', this.selectedThemes));
        }
        if (this.validationError) {
            this.reportValidity();
        }
    }

    @api
    reportValidity() {
        const result = this.validate();
        this.validationError = result.isValid ? undefined : result.errorMessage;
    }

    @api
    validate() {
        if (this.isLoading) {
            return { isValid: false, errorMessage: 'Vent til yrkestemaene er ferdig lastet inn.' };
        }
        if (this.loadError) {
            return { isValid: false, errorMessage: this.loadError };
        }
        if (!this.hasAvailableThemes) {
            return { isValid: true };
        }
        if (!this.selectedThemeValues.length) {
            return { isValid: false, errorMessage: ERROR_REQUIRED };
        }
        return { isValid: true };
    }
}
