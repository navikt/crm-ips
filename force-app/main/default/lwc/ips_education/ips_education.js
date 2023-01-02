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