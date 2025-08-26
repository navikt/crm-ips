import { LightningElement,  wire, api  } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Work_Trail__c.CE_Show_Participant_Details__c'
];

export default class Ips_showParticipantDetail extends LightningElement {
    @api recordId;
    @api default = false;
    @api toggle;
    @api sectionLabel = "Show participant details";
    detail;
    

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            this.error = undefined;
        } else if (data) {
            this.detail = data;
            this.toggle = this.detail.fields.CE_Show_Participant_Details__c.value;
           }
    }

    toggleVisibility(){
        
        const fields = {
            Id: this.recordId,
            CE_Show_Participant_Details__c: !this.toggle
        };
        updateRecord({fields})
        .then(() => {
            this.toggle = !this.toggle;
            
        });
        
        this.sectionLabel = this.toggle ? "Show participant details" : "Hide participant details";
    }
}