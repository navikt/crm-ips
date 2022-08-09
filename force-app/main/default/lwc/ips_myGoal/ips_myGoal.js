import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MAIN_GOAL from '@salesforce/schema/Work_Trail__c.ips_Main_goal__c';

const fields = [MAIN_GOAL];

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myGoal extends LightningElement {

    @api recordId;
    /*fetch name from logged in user */
    @wire(getRecord, { recordId: '$recordId', fields })
    Work_Trail__c;
    
    get goal() {
        return getFieldValue(this.Work_Trail__c.data, MAIN_GOAL);
    }  
}