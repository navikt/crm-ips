import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkTrail from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';
import USER_ID from '@salesforce/user/Id';

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_userWorkTrail extends NavigationMixin(LightningElement) {

    sections = [
        {
            id:1,
            label: 'Yrkesprofil'
        },
        {
            id:2,
            label: 'Handlingsplan'
        }

    ]

    myDirectionImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
    @api recordId;
    record;
    //@track userIds = USER_ID;
    @track userIds = '0051X00000DAHjSQAX';
    conversationEmployer = false;


    @wire(getUserWorkTrail,{userId:'$userIds'})
    userworkprofile({error,data}){
        console.log('Dette er data fra wire: '+JSON.stringify(data));
            if(data){
                this.record = data[0];
            }else if(error){
                console.log('Something went wrong: '+error);
            }
    }

    get mainGoal(){
        return this.record?.ips_Main_goal__c;
     }

    get referredDate(){
        return this.formatDate(this.record?.ips_Referred_date__c);
     }

    get startDate(){
        return this.formatDate(this.record?.Oppstartsdato__c);
     }

    formatDate(date) {
        return new Date(date).toLocaleDateString();; 
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