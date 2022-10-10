import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkProfile from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkProfileUO';
import USER_ID from '@salesforce/user/Id';


/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myWorkProfileUO extends NavigationMixin(LightningElement) {
    myWorkProfileUO = IPS_HOME_LOGOS + '/EmployerFilled.svg';
    @api recordId;
    record;
    @track userIds = USER_ID;
    //@track userIds = '0051X00000DAHjSQAX';


    @wire(getUserWorkProfile,{userId:'$userIds'})
    userworkprofile({error,data}){
        console.log('Dette er data fra wire: '+JSON.stringify(data));
            if(data){
                this.record = data[0];
            }else if(error){
                console.log('Something went wrong: '+error);
            }
    }

     get referredDate(){
        return this.formatDate(this.record?.ips_Referred_date__c);
     }

     get startDate(){
        return this.formatDate(this.record?.Oppstartsdato__c);
     }

     get applyingDepartment(){
        return this.record?.ips_Applying_Department__c;
     }

     get navSupervisor(){
        return this.record?.ips_NAV_supervisor__c;
     }

     get treatmentTeam(){
        return this.record?.ips_Behandlingsteam__c;
     }

     get desiredProfession(){
        return this.record?.ips_Desired_profession_industry_career__c;
     }

     get desiredWorkingEnvironment(){
        return this.record?.ips_Desired_working_environment__c;
     }

     get desiredWorkTask(){
        return this.record?.ips_Desired_work_tasks__c;
     }

     get personalQualities(){
        return this.record?.Personal_Qualities__c;
     }

     get ipsMobility(){
        return this.record?.ips_Mobility__c;
     }

     get economicCondition(){
        return this.record?.ips_Economic_conditions__c;
     }

     get economicCondition(){
        return this.record?.ips_Economic_conditions__c;
     }

     get health(){
        return this.record?.ips_Health__c;
     }

     get socialCondition(){
        return this.record?.ips_Social_conditions__c;
     }

     get interestHobbies(){
        return this.record?.ips_Interests_Hobbies__c;
     }

     get other(){
        return this.record?.ips_Other__c;
     }

     get network(){
        return this.record?.ips_Network_partner__c;
     }

     get education(){
        return this.record?.ips_Education__c;
     }

     get workExperience(){
        return this.record?.ips_Work_experience__c;
     }

     get transparencyEmployerContact(){
        return this.record?.ips_Can_the_employer_be_contacted__c;
     }

     get transparencyEmployerShare(){
        return this.record?.ips_What_can_be_shared_with_the_employer__c;
     }

     get transparencyEmployerNotShare(){
        return this.record?.What_cannot_be_shared_with_the_employer__c;
     }

     get transparencyDate(){
        return this.formatDate(this.record?.ips_Transparency_consent_obtained_date__c);
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