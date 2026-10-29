import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getWorkThemes from '@salesforce/apex/CE_NewOpportunityController.getWorkThemes';
import { registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CeCreateWorkThemeModal from 'c/ceCreateWorkThemeModal';

function getErrorMessage(error) {
    const message = error?.body?.message || error?.message;
    return typeof message === 'string' ? message : 'Det oppstod en uventet feil.';
}

function getDeleteErrorMessage(error) {
    const errors = [
        ...(Array.isArray(error?.body) ? error.body : [error?.body]),
        ...(error?.body?.output?.errors || [])
    ];
    const hasLinkedOpportunities = errors.some(
        (item) =>
            item?.errorCode === 'DEPENDENCY_EXISTS' ||
            (item?.errorCode === 'DELETE_FAILED' &&
                /CE_Discovery_Opportunity__c|Discovery Opportunit|mulighet/i.test(item.message || ''))
    );
    return hasLinkedOpportunities
        ? 'Yrkestemaet kan ikke slettes fordi det er knyttet til muligheter.'
        : getErrorMessage(error);
}

export default class CeWorkThemesRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;

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
            this.records = data.map((row) => ({
                Id: row.recordId,
                Name: row.name,
                opportunityCount: row.opportunityCount
            }));
            this.loadError = undefined;
            this.hasLoaded = true;
        } else if (error) {
            this.records = [];
            this.loadError = getErrorMessage(error);
            this.hasLoaded = true;
        }
    }

    get listTitle() {
        return this.hasLoaded && !this.loadError ? `Yrkestema (${this.records.length})` : 'Yrkestema';
    }

    get hasRecords() {
        return this.records.length > 0;
    }

    get showEmptyState() {
        return this.hasLoaded && !this.loadError && !this.hasRecords;
    }

    /** Opens the work-theme creation flow and refreshes the list when it completes. */
    async handleCreateClick() {
        try {
            const result = await CeCreateWorkThemeModal.open({
                label: 'Nytt yrkestema',
                size: 'medium',
                recordId: this.recordId
            });
            if (result === 'created') {
                await this.handleRefresh();
            }
        } catch (error) {
            this.showToast('Kunne ikke åpne skjemaet', getErrorMessage(error), 'error');
        }
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

    handleViewClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.recordId,
                objectApiName: 'CE_Work_Theme__c',
                actionName: 'view'
            }
        });
    }

    async handleMenuSelect(event) {
        if (event.detail.value === 'delete') {
            const row = this.records.find((record) => record.Id === event.currentTarget.dataset.recordId);
            await this.deleteWorkTheme(row);
        }
    }

    async deleteWorkTheme(row) {
        let confirmed;
        try {
            confirmed = await LightningConfirm.open({
                message: `Vil du slette yrkestemaet «${row.Name}»?`,
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
            this.showToast('Kunne ikke slette yrkestemaet', getDeleteErrorMessage(error), 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
