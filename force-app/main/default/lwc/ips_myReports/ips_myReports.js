import { LightningElement, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import templateEnd from './ips_myEndReport.html';
import templateIntervall from './ips_myIntervallReport.html';
import REPORT_OBJECT from '@salesforce/schema/ips_report__c';

import NAV_LOGOS from '@salesforce/resourceUrl/logos';
import COMMENT_FIELD from '@salesforce/schema/ips_report__c.IPS_participantsComment__c';
import getReport from '@salesforce/apex/IPS_ParticipantsReportsController.getParticipantsReport';


export default class Ips_myReports extends NavigationMixin(LightningElement) {
    
    participantComment = COMMENT_FIELD;
    recordId='a0d1w00000JJgI7AAL';
    @track reportRecord;
    isReport = false;
    isIPS = false;
    isUO = false;
    isEnd = true;
    isIntervall = false;
    recordtypename;
    reportType;

    navLogo = NAV_LOGOS + '/navLogoRed.svg';
  
    objectApiName = REPORT_OBJECT;

    @wire(getReport,{recordId:'@recordId'})
    reportWire({error,data}){
        if(data){
                this.reportRecord = data;
                /*
                this.recordtypename= this.reportRecord.IPS_worktrail_Type__c;
                    if(recordtypename==='IPS'){
                        isIPS = true;
                    }
                    if(recordtypename==='Utvidet oppfølging'){
                        isUO = true;
                    }
                this.reportType = this.reportRecord.IPS_report_Type__c;
                    if(reportType==='End report'){
                        isEnd = true;
                    }
                    if(reportType==='Intervall'){
                        isIntervall = true;
                    }*/
                this.isReport = true;
           }else if(error){
               console.log('An error has ocurred');
               console.log(error);
           }
    }

    render(){
        return this.isEnd ? templateEnd : templateIntervall;
    }
  
}