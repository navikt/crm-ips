import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkDevelopment from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';

import USER_ID from '@salesforce/user/Id';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myDevelopmentUO extends NavigationMixin(LightningElement) {
    myWorkDevelopmentIPS = IPS_HOME_LOGOS + '/EmployerFilled.svg';
    @api recordId;
    record;
    activityRecord;
    //@track userIds = USER_ID;
    @track userIds = '0051X00000DAHjSQAX';
    isWeekly = false;
    workTrailId;

    @wire(getUserWorkDevelopment,{userId:'$userIds'})
    UserWorkDevelopment({error,data}){
            if(data){
                this.record = data[0];
            }else if(error){
                console.log('Something went wrong: '+error);
            }
    }

     get mainGoal(){
        return this.record?.ips_Main_goal__c;
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