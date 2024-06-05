import { LightningElement,track, wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ["Work_Trail__c.Name", "Work_Trail__c.IPS_Participant_email_address__c", "Work_Trail__c.IPS_participants_age__c", "Work_Trail__c.IPS_Participants_home_address__c","Work_Trail__c.IPS_Partticipant_phone_number__c" ];

export default class Ips_showParticipantDetail extends LightningElement {
    //With this flag we can hide and show the Modal in html file
    @track isOpen = false;
    @api recordId;
    detail;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }){
        if (error) {

        } else if (data) {
        this.detail = data;
        this.name = this.detail.fields.Name.value;
        this.age = this.detail.fields.IPS_participants_age__c.value;
        this.adress = this.detail.fields.IPS_Participants_home_address__c.value;
        this.email = this.detail.fields.IPS_Participant_email_address__c.value;
        this.phone = this.detail.fields.IPS_Partticipant_phone_number__c.value;
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