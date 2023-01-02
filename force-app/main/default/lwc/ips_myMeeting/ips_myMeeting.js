import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMeeting from '@salesforce/apex/IPS_myActivityController.getMeeting';
import { refreshApex } from '@salesforce/apex';

export default class Ips_myMeeting extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    @api header;
    //testId = '00U1X000004FRJ3UAO';
    error;
    @track userActivity;
   
    @wire(getMeeting, {recId:'$recordId'})
    wiredmeeting({ error, data }) {
        if (data) {
            this.record = data[0];
            /*
            this.activitydate = this.record?.ActivityDate;
            this.recordId = this.record?.Id;
            this.contactId = this.record?.ips_Participant__r.PersonContactId;
            */
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    get activitydate(){
        return this.formatDate(this.record?.ActivityDate);
    }

    get timefrom(){
        return this.record?.StartDateTime;
    }

    get timeto(){
        return this.record?.EndDateTime;
    }

    get type(){
        if(this.record?.IPS_Type__c ==='Meeting with Employer'){
            return 'møte med arbeidstaker';
        }
        
        if(this.record?.IPS_Type__c ==='Meeting with Participant'){
            return 'møte med jobbspesialist';
        }
    }

    get subject(){
        return this.record?.Subject;
    }

    get description(){
        return this.record?.Description;
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