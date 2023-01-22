import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTaskDetail from '@salesforce/apex/IPS_myActivityController.getTaskDetail';

export default class Ips_taskDetail extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    error;
    isloading = true;
   
    @wire(getTaskDetail, {recId:'$recordId'})
    wireddetail({ error, data }) {
        if (data) {
            this.record = data[0];
            this.isloading = false;
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
        if(this.record?.Type_of_Task_IPSUO__c==='Logg kontakt' && this.record?.Samtalereferat__c === true){
            return this.record?.Description;
        }
        if(this.record?.Type_of_Task_IPSUO__c==='Delmål (av hovedmål)'){
            return this.record?.Description;
        }else{
            return null;
        }
        
    }

    get status(){
        let taskStatus = this.record?.Status;
        if(taskStatus==='Open'){
            return 'Åpen'
        }
        if(taskStatus==='Completed'){
            return 'Fullført';
        }
        if(taskStatus==='Not applicable'){
            return 'Ingen status'
        }
    }

    get type(){
        return this.record?.Type_of_Task_IPSUO__c;
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