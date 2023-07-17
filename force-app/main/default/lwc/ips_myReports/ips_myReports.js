import { LightningElement, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldValue, getRecord} from 'lightning/uiRecordApi';
import templateEnd from './ips_myEndReport.html';
import templateIntervall from './ips_myIntervallReport.html';

import NAV_LOGOS from '@salesforce/resourceUrl/logos';
/* Report */
import COMMENT_FIELD from '@salesforce/schema/ips_report__c.IPS_participantsComment__c';
import REPORTTYPE_FIELD from '@salesforce/schema/ips_report__c.IPS_report_Type__c';
import RECORDTYPE_FIELD from '@salesforce/schema/ips_report__c.IPS_worktrail_Type__c';
import SUBJECT_FIELD from '@salesforce/schema/ips_report__c.IPS_subject__c';
import DUEDATE_FIELD from '@salesforce/schema/ips_report__c.IPS_dueDateBack__c';
import WORKTRAILID_FIELD from '@salesforce/schema/ips_report__c.IPS_workTrailName__c';
import SUMMARIZE1_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm1__c';
import SUMMARIZE2_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm2__c';
import SUMMARIZE3_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm3__c';
import SUMMARIZE4_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm4__c';
import SUMMARIZE5_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm5__c';
import SUMMARIZE6_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm6__c';
import SUMMARIZE7_FIELD from '@salesforce/schema/ips_report__c.IPS_endReportSumm7__c';

/* worktrail */
import FIELD_CAREERWISHES from '@salesforce/schema/Work_Trail__c.ips_Priority_career_wishes__c';

const REPORT_FIELDS =[
    COMMENT_FIELD,
    REPORTTYPE_FIELD,
    RECORDTYPE_FIELD,
    SUBJECT_FIELD,
    DUEDATE_FIELD,
    WORKTRAILID_FIELD,
    SUMMARIZE1_FIELD,
    SUMMARIZE2_FIELD,
    SUMMARIZE3_FIELD,
    SUMMARIZE4_FIELD,
    SUMMARIZE5_FIELD,
    SUMMARIZE6_FIELD,
    SUMMARIZE7_FIELD

];

const WORKTRAIL_FIELDS = [
    FIELD_CAREERWISHES
];

export default class Ips_myReports extends NavigationMixin(LightningElement) {
    
    participantComment = COMMENT_FIELD;
    recordId='a0j7a000006s3jCAAQ';
    @track reportRecord;
    @track worktrailRecord;
    @track reportType;
    @track service;
    isReport =false;
    navLogo = NAV_LOGOS + '/navLogoRed.svg';

    @wire(getRecord, { recordId: '$recordId', fields: REPORT_FIELDS })
    reportWire({error,data}){
        if(data){
            this.reportRecord = data;
            this.isReport = true;
        }else if(error){
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$workTrailId', fields: WORKTRAIL_FIELDS })
    worktrailWire({error,data}){
        if(data){
            this.worktrailRecord = data;
            this.isReport = true;
        }else if(error){
            console.log(error);
        }
    }


    get isEnd(){
        this.reportType = getFieldValue(this.reportRecord,REPORTTYPE_FIELD);
        if(this.reportType==='End report'){
            return true;
        }else{
            return false;
        }
    }

    render(){
        return this.isEnd ? templateEnd : templateIntervall;
    }

    

    get isIPS(){
        this.service = getFieldValue(this.reportRecord,RECORDTYPE_FIELD);
        if(this.service ==='IPS'){
            return true;
        }else{
            return false;
        }
    }

    get isUO(){
        this.service = getFieldValue(this.reportRecord,RECORDTYPE_FIELD);
        if(this.service ==='Utvidet oppfølging'){
            return true;
        }else{
            return false;
        }
    }

    get reportSubject(){
        return getFieldValue(this.reportRecord,SUBJECT_FIELD);
    }

    get workTrailId(){
        return getFieldValue(this.reportRecord,WORKTRAILID_FIELD);
    }

    get careerWishes(){
        return getFieldValue(this.worktrailRecord,FIELD_CAREERWISHES);
    }
  
}