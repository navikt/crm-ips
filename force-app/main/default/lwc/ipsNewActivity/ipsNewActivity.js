import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord } from 'lightning/uiRecordApi';
import getMenu from '@salesforce/apex/IPS_NewActivityController.getMenu';

const WORK_TRAIL_FIELDS = ['Work_Trail__c.Name'];
// Groups with fewer options than this are shown as separate buttons on the first screen.
const MIN_OPTIONS_FOR_SUBMENU = 3;

export default class IpsNewActivity extends NavigationMixin(LightningElement) {
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        const changed = value !== this._recordId;
        this._recordId = value;
        if (value && changed) {
            this.loadMenu();
        }
    }

    groups = [];
    workTrailName;
    selectedGroupKey;
    selectedFlow;
    isLoading = true;
    errorMessage;
    focusPending = false;

    async loadMenu() {
        this.isLoading = true;
        try {
            this.groups = (await getMenu({ recordId: this._recordId })) || [];
            this.errorMessage = undefined;
            this.focusPending = true;
        } catch (error) {
            this.groups = [];
            this.errorMessage = error?.body?.message || 'Kunne ikke hente aktivitetene.';
        } finally {
            this.isLoading = false;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: WORK_TRAIL_FIELDS })
    wiredWorkTrail({ data, error }) {
        if (data) {
            this.workTrailName = data.fields.Name.value;
        } else if (error) {
            this.errorMessage = 'Kunne ikke hente navnet på jobbsporet. Prøv igjen.';
        }
    }

    get menuItems() {
        const items = [];
        this.groups.forEach((group) => {
            if (group.options.length > 1 && group.options.length < MIN_OPTIONS_FOR_SUBMENU) {
                group.options.forEach((option) => {
                    items.push({ key: option.key, label: option.label, icon: option.icon, option });
                });
            } else {
                items.push({ key: group.key, label: group.label, icon: group.icon, group });
            }
        });
        return items;
    }

    get selectedGroup() {
        return this.groups.find((group) => group.key === this.selectedGroupKey);
    }

    get isOptionStep() {
        return !this.isFlowStep && !!this.selectedGroup;
    }

    get isFlowStep() {
        return !!this.selectedFlow;
    }

    get showBackButton() {
        return this.isOptionStep || this.isFlowStep;
    }

    get flowInputVariables() {
        return [{ name: 'recordId', type: 'String', value: this.recordId }];
    }

    get isGroupStep() {
        return !this.isLoading && !this.errorMessage && !this.showBackButton && this.groups.length > 0;
    }

    get isEmpty() {
        return !this.isLoading && !this.errorMessage && this.groups.length === 0;
    }

    get headerLabel() {
        if (this.isFlowStep) {
            return this.selectedFlow.label;
        }
        return this.isOptionStep ? `Ny aktivitet: ${this.selectedGroup.label}` : 'Ny aktivitet';
    }

    get stepDescription() {
        return this.isOptionStep
            ? `Velg type ${this.selectedGroup.label.toLowerCase()}.`
            : 'Velg hva du vil opprette på jobbsporet.';
    }

    renderedCallback() {
        if (this.focusPending) {
            const firstButton = this.template.querySelector('.activity-button');
            if (firstButton) {
                firstButton.focus();
                this.focusPending = false;
            }
        }
    }

    handleItemClick(event) {
        const item = this.menuItems.find((menuItem) => menuItem.key === event.currentTarget.dataset.key);
        if (!item) {
            return;
        }
        if (item.option) {
            this.selectOption(item.option);
            return;
        }
        const group = item.group;
        if (group.options.length === 1) {
            this.selectOption(group.options[0]);
            return;
        }
        this.selectedGroupKey = group.key;
        this.focusPending = true;
    }

    handleOptionClick(event) {
        const option = this.selectedGroup?.options.find((item) => item.key === event.currentTarget.dataset.key);
        if (option) {
            this.selectOption(option);
        }
    }

    handleBack() {
        if (this.isFlowStep) {
            this.selectedFlow = undefined;
            this.errorMessage = undefined;
        }
        this.selectedGroupKey = undefined;
        this.focusPending = true;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    selectOption(option) {
        if (option.flowApiName) {
            this.selectedFlow = option;
            return;
        }
        this.createRecord(option);
    }

    handleFlowStatusChange(event) {
        const status = event.detail.status;
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            this.dispatchEvent(new RefreshEvent());
            this.dispatchEvent(new CloseActionScreenEvent());
        } else if (status === 'ERROR') {
            this.errorMessage = 'Kunne ikke åpne eller fullføre skjemaet.';
        }
    }

    createRecord(option) {
        const state = {
            nooverride: option.noOverride === false ? '0' : '1',
            navigationLocation: 'RELATED_LIST',
            useRecordTypeCheck: 1,
            defaultFieldValues: encodeDefaultFieldValues(option.defaultFieldValues || {}),
            backgroundContext: `/lightning/r/Work_Trail__c/${this.recordId}/view`
        };
        if (option.recordTypeId) {
            state.recordTypeId = option.recordTypeId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: option.objectApiName,
                actionName: 'new'
            },
            state
        });
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
