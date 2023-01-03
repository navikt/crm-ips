import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkTraining from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkDetail';

export default class Ips_myWorkTraining extends NavigationMixin(LightningElement) {
    @api recordId;
    @track record;
    isWorkTraining = false;
    error;
   
    @wire(getUserWorkTraining, {recId:'$recordId'})
    wiredtraining({ error, data }) {
        if (data) {
            console.log(data);
            this.record = data[0];
            //this.accountId = this.record?.ips_Employer__c;
            //this.accountContactId = this.record?.ips_Employer_contact__c;
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }

    get type(){
        let empltype = this.record?.ips_Form_of_Employment__c;
        if(this.empltype==='Arbeidstrening' || this.empltype ==='work training' ){
            this.isWorkTraining = true;
        }
        return this.empltype;
        /*
        if(this.record?.ips_Form_of_Employment__c ==='Freelance / self-employed'){
            return 'Freelance/selvstendig næringsdrivende';
        }
        if(this.record?.ips_Form_of_Employment__c ==='Permanent employment'){
            return 'Fast ansettelse';
        }
        if(this.record?.ips_Form_of_Employment__c ==='Temporary employment'){
            return 'Tidsbegrenset ansettelse';
        }
        if(this.record?.ips_Form_of_Employment__c ==='Zero hours contrac'){
            return 'Tilkalling ekstrajobb';
        }*/
    }

    get workName(){
        return this.record?.Name;
    }

    get worked(){
        return this.record?.ips_What_did_work_at_the_workplace__c;
    }

    get notworked(){
        return this.record?.ips_What_did_not_work_at_the_workplace__c;
    }

    get jobsupport(){
        return this.record?.ips_Job_Support__c;
    }

    get hours(){
        return this.record?.ips_Number_of_hours__c;
    }

    get status(){
        let goalStatus = this.record?.ips_Status__c;
        if(goalStatus==='Ongoing'){
            return 'Pågående'
        }
        if(goalStatus==='Completed'){
            this.isClosed = true;
            return 'Fullført';
        }
        if(goalStatus==='Planned'){
            return 'Planlagt'
        }
    }
    get startdate(){
        return this.formatDate(this.record?.ips_Start_Date__c);
    }

    get enddate(){
        return this.formatDate(this.record?.ips_End_Date__c);
    }

    formatDate(initialDate) {
        if (initialDate === undefined) {
            return null;
        }
        let date = new Date(initialDate);
        return date.toLocaleDateString();
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