import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUserWorkProfile from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkProfileIPS';
import USER_ID from '@salesforce/user/Id';


/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';


export default class Ips_myWorkProfile extends NavigationMixin(LightningElement) {
    myWorkProfileIPS = IPS_HOME_LOGOS + '/EmployerFilled.svg';
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

     get age(){
            return this.record?.IPS_Participant_age__c;
     }

     get participantHomeAddress(){
        return this.record?.IPS_Participants_home_address__c;
     }

     get participantEmail(){
        return this.record?.IPS_Participant_email_address__c;
     }

     get participantPhoneNumber(){
        return this.record?.IPS_Partticipant_phone_number__c;
     }

     get referredDate(){
        return this.formatDate(this.record?.ips_Referred_date__c);
     }

     get startDate(){
        return this.formatDate(this.record?.Oppstartsdato__c);
     }

     get contNoShow(){
        return this.record?.ips_Contact_when_not_showing__c;
     }

     get IPSung(){
        return this.record?.IPS_Ung__c;
     }

     get transparencyDate(){
        return this.record?.ips_Transparency_consent_obtained_date__c;
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

     get transparencyEmployerOpenessBenefit(){
        return this.record?.ips_Benefits_of_openness_to_the_employer__c;
     }

     get transparencyEmployerOpenessDisadvantage(){
        return this.record?.ips_Disadvantages_of_openness_employe__c;
     }

     get shareHealt(){
        return this.record?.ips_Health_service__c;
     }

     get treatmentTeam(){
        return this.record?.ips_Behandlingsteam__c;
     }

     get navSupervisor(){
        return this.record?.ips_NAV_supervisor__c;
     }

     get network(){
        return this.record?.ips_Network_partner__c;
     }

     get framesBeforeWork(){
        return this.record?.ips_Financialframework_before_start_work__c;
     }

     get planWhenWork(){
        return this.record?.ips_Plan__c;
     }

     get transitionToWork(){
        return this.record?.ips_Transition_to_work__c;
     }

     get interestHobbies(){
        return this.record?.ips_Interests_Hobbies__c;
     }

     get personalQualities(){
        return this.record?.Personal_Qualities__c;
     }

     get culturalBackground(){
        return this.record?.ips_Cultural_background__c;
     }

     get environmentalConditions(){
        return this.record?.ips_Environmental_conditions__c;
     }

     get economy(){
        return this.record?.ips_Economy__c;
     }

     get health(){
        return this.record?.ips_Health__c;
     }

     get education(){
        return this.record?.ips_Education__c;
     }

     get workExperiance(){
        return this.record?.ips_Work_experience__c;
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