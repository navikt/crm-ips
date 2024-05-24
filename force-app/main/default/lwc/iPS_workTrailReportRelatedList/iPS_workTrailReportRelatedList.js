import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import STATUS_FIELD from "@salesforce/schema/Work_Trail__c.ips_Status__c";
import NAME_FIELD from "@salesforce/schema/Work_Trail__c.Name";
import OWNERNAME_FIELD from "@salesforce/schema/Work_Trail__c.IPS_ownerName__c";
import OWNERID_FIELD from "@salesforce/schema/Work_Trail__c.OwnerId";
import RECORDTYPENAME_FIELD from "@salesforce/schema/Work_Trail__c.RecordType.Name";
import { getRecord,getFieldValue } from 'lightning/uiRecordApi'; 
import allReports from '@salesforce/apex/IPS_ParticipantsReportsController.allReports';

const fields =[STATUS_FIELD,NAME_FIELD,OWNERNAME_FIELD,RECORDTYPENAME_FIELD,OWNERID_FIELD];

const COLUMNS = [
    {
        type: "button", initialWidth: 80, typeAttributes: {
            name: 'view',
            title: 'Åpne',
            disabled: false,
            value: 'Åpne',
            iconPosition: 'left',
            iconName:'utility:preview',
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
    @track isDatesNull = false;
    @track isDateError = false;
    reportType;
    reportStatus ='Open';
    columns = COLUMNS;
    records;
    trail;
    error;
    isLoading = false;
    trail;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredtrail;

    @wire(allReports,{workTrailId: '$recordId'})
    wiredReports({data, error}){
        if(data){
            this.records = data;
            this.error = undefined;
        }else if(error){
            this.error = error;
            this.records = undefined;
        }
    }

    defaultStartDate(){
        var startDate = new Date(new Date().getTime());
        return startDate.toISOString();
    }

    defaultEndDate(){
        var endDate = new Date(new Date().getTime());
        return endDate.toISOString();
    }

    get isIPS(){
        this.recordTypeNameWorkTrail = getFieldValue(this.wiredtrail.data,RECORDTYPENAME_FIELD);
        if(this.recordTypeNameWorkTrail === 'IPS'){
            return true;
        }
        if(this.recordTypeNameWorkTrail === 'Supported Employment'){
            return false;
        }
    }

    get isDisabled(){
        this.recordStatus = getFieldValue(this.wiredtrail.data, STATUS_FIELD);
        if(this.recordStatus ==='Ended'){
            return false ;
        }else{return true;}
    }

    get ownername(){
        return getFieldValue(this.wiredtrail.data, OWNERNAME_FIELD);
    }

    get ownerid(){
        return getFieldValue(this.wiredtrail.data, OWNERID_FIELD);
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
            default:
              return;
          }
    }

    submitEnd(event){
        this.intervallDateFrom =null;
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
                "IPS_workTrailOwner__c":this.ownername
            } };
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

        if(this.intervallDateFrom && this.intervallDateTo){
            if(this.intervallDateFrom >= this.intervallDateTo){
                this.isDateError = true;
            }else{
                const recordInput= { 
                    "apiName": "ips_report__c",
                    "fields" :{
                        "IPS_intervallDateTo__c":this.intervallDateTo,
                        "IPS_intervallDateFrom__c":this.intervallDateFrom,
                        "IPS_report_Type__c":this.reportType,
                        "IPS_status__c":this.reportStatus,
                        "IPS_workTrailName__c":this.recordId,
                        "IPS_worktrail_Type__c":this.recordTypeNameWorkTrail,
                        "IPS_workTrailOwner__c":this.ownername
                    } };
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
                })
                .catch(error => {
                    console.log(error);
                })
            }
        }else{
            this.isDatesNull = true;  
        }     
    }

    handleCancel(event){
        this.isIntervall = false;
    }

    // Navigates to the chosen jobbspor rapport record page.
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