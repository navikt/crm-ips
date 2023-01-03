import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getParticipantsGoal from '@salesforce/apex/IPS_myActivityController.getParticipantsGoal';

export default class Ips_myGoal extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    error;
   
    @wire(getParticipantsGoal, {recId:'$recordId'})
    wiredgoal({ error, data }) {
        if (data) {
            this.record = data[0];
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    get activitydate(){
        return this.formatDate(this.record?.ActivityDate);
    }

    get subject(){
        return this.record?.Subject;
    }

    get description(){
        return this.record?.Description;
    }

    get status(){
        let goalStatus = this.record?.Status;
        if(goalStatus==='Open'){
            return 'Åpen'
        }
        if(goalStatus==='Completed'){
            return 'Fullført';
        }
        if(goalStatus==='Not applicable'){
            return 'Ingen status'
        }
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