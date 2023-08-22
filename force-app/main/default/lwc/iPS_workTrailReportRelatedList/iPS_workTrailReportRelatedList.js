import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import { getRecord } from 'lightning/uiRecordApi'; 
import allReports from '@salesforce/apex/IPS_ParticipantsReportsController.allReports';


const COLUMNS = [
    {
        type: "button", initialWidth: 80, typeAttributes: {
            name: 'view',
            title: 'Åpne',
            disabled: false,
            value: 'Åpne',
            iconPosition: 'left',
            iconName:'action:edit',
        }
    },
    { label: 'RapportNr', fieldName: 'Name' },
    { label: 'Type', fieldName: 'IPS_report_Type__c', type: 'text' },
    { label: 'Status', fieldName: 'IPS_status__c', type: 'text' },
    { label: 'Opprettet dato', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Dato fra', fieldName: 'IPS_intervallDateFrom__c', type: 'date' },
    { label: 'Dato til', fieldName: 'IPS_intervallDateTo__c', type: 'date' },
    
];


export default class IPS_workTrailReportRelatedList extends NavigationMixin(LightningElement) {

    @api recordId;
    reportId;
    @track userId = Id;
    @track recordTypeNameWorkTrail;
    @track intervallDateFrom;
    @track intervallDateTo;
    @track isIntervall = false;
    @track isEnd = false;
    reportType;
    reportStatus ='Open';
    columns = COLUMNS;
    records;
    trail;
    error;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: ['Work_Trail__c.Name'] })
    wiredtrail({ error, data }) {
        if (data) {
            this.trail = data;
            this.recordTypeNameWorkTrail = data.recordTypeInfo.name;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.trail = undefined;
        }
    }

    @wire(allReports,{workTrailId: '$recordId'})
    wiredReports({data, error}){
        console.log('Data: '+JSON.stringify(data));
        if(data){
            this.records = data;
            this.error = undefined;
        }else if(error){
            this.error = error;
            this.records = undefined;
        }
    }

    get isIPS(){
        if(this.recordTypeNameWorkTrail === 'IPS'){
            return true;
        }
        if(this.recordTypeNameWorkTrail === 'Supported Employment'){
            return false;
        }
    }
    
    handleButtonClick(event) {
        switch (event.target.label) {
            case 'Opprett Underveisnotat':
                this.isIntervall = true;
                this.isEnd = false;
                this.reportType = 'Intervall';
                break;
            case 'Opprett Underveisrapport':
                this.isIntervall = true;
                this.isEnd = false;
                this.reportType = 'Intervall';
                break;
            case 'Opprett Avslutningsnotat':
                this.isIntervall = false;
                this.isEnd = true;
                this.reportType = 'End report';

                break;
            case 'Opprett Sluttrapport':
                this.isEnd = true;    
                this.isIntervall = false;
                this.reportType = 'End report';
                break;
            default:
              return;
          }
    }

    submitEnd(event){
        this.intervallDateFrom = null;
        this.intervallDateTo = null;
        this.reportType = 'End report';

        const recordInput= { 
            "apiName": "ips_report__c",
            "fields" :{
                "IPS_intervallDateTo__c":this.intervallDateTo,
                "IPS_intervallDateFrom__c":this.intervallDateFrom,
                "IPS_report_Type__c":this.reportType,
                "IPS_status__c":this.reportStatus,
                "IPS_workTrailName__c":this.recordId,
                "IPS_worktrail_Type__c":this.recordTypeNameWorkTrail,
                "OwnerId":this.userId
            } };
        console.log(recordInput);
        createRecord(recordInput)
        .then((ips_report_c) =>{
            this.reportId = ips_report_c.id;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                  recordId: this.reportId,
                  actionName: 'view'
                }
              });
            console.log('Rapport id er: '+this.reportId);
        })
        .catch(error => {
            console.log(error);
        })
    }


    submitIntervall(event){
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name==="intervallDateFrom")
                this.intervallDateFrom = element.value;
            if(element.name==='intervallDateTo')
                this.intervallDateTo = element.value;
        },this);

        const recordInput= { 
            "apiName": "ips_report__c",
            "fields" :{
                "IPS_intervallDateTo__c":this.intervallDateTo,
                "IPS_intervallDateFrom__c":this.intervallDateFrom,
                "IPS_report_Type__c":this.reportType,
                "IPS_status__c":this.reportStatus,
                "IPS_workTrailName__c":this.recordId,
                "IPS_worktrail_Type__c":this.recordTypeNameWorkTrail,
                "OwnerId":this.userId
            } };
        console.log(recordInput);
        createRecord(recordInput)
        .then((ips_report_c) =>{
            this.reportId = ips_report_c.id;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                  recordId: this.reportId,
                  actionName: 'view'
                }
              });
            console.log('Rapport id er: '+this.reportId);
        })
        .catch(error => {
            console.log(error);
        })
    }

    navigateToRecordViewPage(event){
        const row = event.detail.row;
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: row.Id,
            actionName: 'view'
          }
        });
    }

}