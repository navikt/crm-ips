import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Work_Trail__c.Name',
    'Work_Trail__c.IPS_participant_skjerming_address__c'
];

export default class Ips_showParticipantDetail extends LightningElement {
    //With this flag we can hide and show the Modal in html file
    @track isOpen = false;
    @api recordId;
    @api default = false;
    detail;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            this.error = undefined;
        } else if (data) {
            this.detail = data;
            this.name = this.detail.fields.Name.value;
            this.adress = this.detail.fields.IPS_participant_skjerming_address__c.value;
        }
    }

    showModal() {
        this.isOpen = true;
    }

    hideModal() {
        this.isOpen = false;
    }

    save() {
        this.isOpen = false;
    }
}