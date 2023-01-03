import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserEducation from '@salesforce/apex/IPS_myWorkTrailController.getUserEducation';

export default class Ips_education extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    @api header;
    error;
    @track userEducation;
   
    @wire(getUserEducation, {recId:'$recordId'})
    wirededucation({ error, data }) {
        if (data) {
            this.record = data[0];
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }
    
    get type(){
        return this.record?.ips_What_did_not_work_with_thiseducation__c;
    }

    get notworked(){
        return this.record?.ips_What_did_work_with_this_education__c;
    }

    get worked(){
        return this.record?.ips_What_did_work_with_this_education__c;
    }


    get supportplan(){
        return this.record?.ips_Education_Support_Plan__c;
    }

    get startdate(){
        return this.formatDate(this.record?.ips_Start_Date__c);
    }

    get enddate(){
        return this.formatDate(this.record?.ips_End_Date__c);
    }
    
    get educationtitle(){
        return this.record?.Name;
    }

    get institutename(){
        return this.record?.ips_Name_of_the_Education_Institution__c;
    }

    formatDate(date) {
        return new Date(date).toLocaleDateString(); 
     }

     navigateToPage(event) {
        const page = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
            name: page
            }
        });
    }

}