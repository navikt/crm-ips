import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getWorkThemes from '@salesforce/apex/CE_NewOpportunityController.getWorkThemes';
import { registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ROW_ACTIONS = [{ label: 'Slett', name: 'delete' }];

const COLUMNS = [
    {
        label: 'Navn',
        type: 'button',
        typeAttributes: { label: { fieldName: 'name' }, name: 'view', variant: 'base' }
    },
    {
        label: 'Antall muligheter',
        fieldName: 'opportunityCount',
        type: 'number',
        editable: false,
        cellAttributes: { alignment: 'left' },
        typeAttributes: { maximumFractionDigits: 0 }
    },
    { type: 'action', typeAttributes: { rowActions: ROW_ACTIONS } }
];

function getErrorMessage(error) {
    const message = error?.body?.message || error?.message;
    return typeof message === 'string' ? message : 'Det oppstod en uventet feil.';
}

export default class CeWorkThemesRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;

    columns = COLUMNS;
    records = [];
    loadError;
    hasLoaded = false;
    refreshHandlerId;

    connectedCallback() {
        this.refreshHandlerId = registerRefreshHandler(this, this.handleRefresh.bind(this));
    }

    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshHandlerId);
    }

    @wire(getWorkThemes, { workTrailId: '$recordId' })
    wiredWorkThemes(result) {
        this.workThemesResult = result;
        const { data, error } = result;
        if (data) {
            this.records = data.map((record) => ({
                Id: record.recordId,
                name: record.name || '',
                opportunityCount: record.opportunityCount
            }));
            this.loadError = undefined;
            this.hasLoaded = true;
        } else if (error) {
            this.records = [];
            this.loadError = getErrorMessage(error);
            this.hasLoaded = true;
        }
    }

    get hasRecords() {
        return this.records.length > 0;
    }

    get showEmptyState() {
        return this.hasLoaded && !this.loadError && !this.hasRecords;
    }

    async handleRefresh() {
        if (!this.workThemesResult) {
            return true;
        }
        try {
            await refreshApex(this.workThemesResult);
            return true;
        } catch (error) {
            this.showToast('Kunne ikke oppdatere yrkestemaene', getErrorMessage(error), 'error');
            return false;
        }
    }

    async handleRowAction(event) {
        if (event.detail.action.name === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.row.Id,
                    objectApiName: 'CE_Work_Theme__c',
                    actionName: 'view'
                }
            });
        } else if (event.detail.action.name === 'delete') {
            await this.deleteWorkTheme(event.detail.row);
        }
    }

    async deleteWorkTheme(row) {
        let confirmed;
        try {
            confirmed = await LightningConfirm.open({
                message: `Vil du slette yrkestemaet «${row.name}»?`,
                label: 'Slett yrkestema',
                theme: 'warning'
            });
        } catch (error) {
            this.showToast('Kunne ikke bekrefte slettingen', getErrorMessage(error), 'error');
            return;
        }
        if (!confirmed) {
            return;
        }

        try {
            await deleteRecord(row.Id);
            this.records = this.records.filter((record) => record.Id !== row.Id);
            this.showToast('Yrkestema slettet', 'Yrkestemaet ble slettet.', 'success');
        } catch (error) {
            this.showToast('Kunne ikke slette yrkestemaet', getErrorMessage(error), 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
