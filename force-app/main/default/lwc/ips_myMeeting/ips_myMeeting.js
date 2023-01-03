import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMeeting from '@salesforce/apex/IPS_myActivityController.getMeeting';

export default class Ips_myMeeting extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    @api header;
    error;
   
    @wire(getMeeting, {recId:'$recordId'})
    wiredmeeting({ error, data }) {
        if (data) {
            this.record = data[0];
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    get activitydate(){
        return this.formatDate(this.record?.ActivityDate);
    }

    get status(){
        let goalStatus = this.record?.IPS_Status1__c;
        if(goalStatus==='Open'){
            return 'Åpen'
        }
        if(goalStatus==='Completed'){
            return 'Lukket';
        }
        if(goalStatus==='Not applicable'){
            return 'Ingen status'
        }
    }

    get timefrom(){
        return this.formatDateTimeToTime(this.record?.StartDateTime);
    }

    get timeto(){
        return this.formatDateTimeToTime(this.record?.EndDateTime);
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

    formatDate(initialDate) {
        if (initialDate === undefined) {
            return null;
        }
        let date = new Date(initialDate);
        return date.toLocaleDateString();
     }

    formatDateTime(initialDatetime){
        if (initialDatetime === undefined) {
            return null;
        }
        let datetime = new Date(initialDatetime);
        return (
            datetime.toLocaleDateString() + ', ' + datetime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        );
    }

    formatDateTimeToTime(initialDatetime){
        if (initialDatetime === undefined) {
            return null;
        }
        let datetime = new Date(initialDatetime);
        return (
            datetime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        );
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