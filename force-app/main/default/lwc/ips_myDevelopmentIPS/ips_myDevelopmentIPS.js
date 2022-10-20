import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkDevelopment from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrail';

import USER_ID from '@salesforce/user/Id';
/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myDevelopmentIPS extends NavigationMixin(LightningElement) {
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


   get mainGoalList(){
        return this.record?.ips_Main_Goal_list__c;
     }

     get mainGoal(){
        return this.record?.ips_Main_goal__c;
     }

     get careerWishes(){
        return this.record?.ips_Priority_career_wishes__c;
     }

     get frameworkJobDevelopment(){
        return this.record?.ips_Framework_for_job_development_search__c;
     }

     get prefferedWorkingHours(){
        return this.record?.ips_Preferred_working_hours__c;
     }

     get ipsNetwork(){
        return this.record?.ips_Network__c;
     }

     get geography(){
        return this.record?.ips_Geography__c;
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

    formatDate(date) {
        var formatDate = new Date(date);
        var year = formatDate.getFullYear();
        var dag = formatDate.getDay();
        var dato = formatDate.getDate();
        var maaned = formatDate.getMonth();
        return [dato,maaned,year];
     }
}