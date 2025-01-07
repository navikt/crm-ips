import { LightningElement,wire,track } from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import templateIPS from './ips_ParticipantPortalIPS.html';
import templateAMS from './ips_ParticipantPortalAMS.html';
import defaultTemplate from './ips_ParticipantPortalDefault.html';
import USER_ID from '@salesforce/user/Id';
import USER_CONTACT_ACCOUNT_FIELD from '@salesforce/schema/User.Contact.AccountId';
import USER_CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import getTrailAndRecordtype from '@salesforce/apex/IPS_ParticipantPortalTrailController.getTrailAndRecordtype';
import getTrailWrapperClassList from '@salesforce/apex/IPS_ParticipantPortalTrailController.getTrailWrapperClassList';
import getParticipantSharedReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
/* label IPS */
import informationTextIPS from '@salesforce/label/c.IPS_Information_text_IPS';
import titleTextIPS from '@salesforce/label/c.IPS_title_text_IPS';
import jobDevelopmentTitle from '@salesforce/label/c.IPS_job_development_title_IPS';
import careerProfileTitle from '@salesforce/label/c.IPS_career_profile_title_IPS';
//import workEducationSupportTitle from '@salesforce/label/c.IPS_education_and_work_support_title_IPS';
import cooperationTitle from '@salesforce/label/c.IPS_cooperation_title_IPS';
import economyTitle from '@salesforce/label/c.IPS_economy_title_IPS';
/* label AMS */
import informationTextAMS from '@salesforce/label/c.IPS_Information_text_AMS';
import titleTextAMS from '@salesforce/label/c.IPS_title_text_AMS';
/* label Alle */
import careerPlanningTitle from '@salesforce/label/c.IPS_Career_Planning_Title';
import careerPlanningText from '@salesforce/label/c.IPS_Career_Planning_Text';
import transparencyTitle from '@salesforce/label/c.IPS_transparency_title';
import transparencyText from '@salesforce/label/c.IPS_transparency_text';
import historyTitle from '@salesforce/label/c.IPS_history_title';
import historyText from '@salesforce/label/c.IPS_history_text';
/* default page */
import warningText from '@salesforce/label/c.IPS_Information_message_text';

/* all logos related to IPS/AMS portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';
import State from '@salesforce/schema/Asset.State';


export default class Ips_ParticipantPortal extends NavigationMixin(LightningElement) {
//currentUser = USER_ID;
currentUser ='005KN0000018AEbYAM';
error;
@track recordTypeName;
@track participantSharedReportList;
@track recordId;
recordOwnerName;
@track isActive = false;
isGoal = true;
isMeeting = true;
isJob = true;
isTraining = true;
isEducation = true;
isReport = true;
isTrail = false;
label ={
        informationTextIPS,
        informationTextAMS,
        titleTextIPS,
        titleTextAMS,
        careerPlanningTitle,
        careerPlanningText,
        jobDevelopmentTitle,
        warningText,
        careerProfileTitle,
        transparencyTitle,
        transparencyText,
        cooperationTitle,
        economyTitle,
        historyTitle,
        historyText,
};
// warning icon and text used in default page
warningIcon = IPS_HOME_LOGOS + '/ExclamationmarkTriangle.svg';
ipsLogoImg = IPS_HOME_LOGOS + '/IPSikon.svg';
//warningText ='Du må være aktiv deltaker i et av arbeidsmarkedstiltakene, individuell jobbstøtte eller arbeid med støtte, for tilgang til denne siden.';


@wire(getRecord, {
    recordId: '$currentUser',
    optionalFields: [USER_CONTACT_ACCOUNT_FIELD,USER_CONTACT_FIELD] })
    user;

@wire(getTrailAndRecordtype,{
    accountId: '$userAccountId'})
    trailDataHandler
    ({data,error}){

        if(data){
            this.recordTypeName = data.jobbsporPostTypeNavn;
            this.recordId = data.jobbsporId;
            this.isActive = true;
        }
        if(error){
                this.error = error;
                this.isActive = false;
                this.recordTypeName = 'default';
            }
        }   

  get userAccountId() {
    return getFieldValue(this.user.data,USER_CONTACT_ACCOUNT_FIELD);
    }
  get userContactId() {
    return getFieldValue(this.user.data,USER_CONTACT_FIELD);
  }

  get showtemplate(){
    switch (this.recordTypeName) {
        case 'IPS': return templateIPS;
        break;
        case 'ips_Supported_Employment': return templateAMS;
        break;
        case 'default': return defaultTemplate;
        break;
        default: return defaultTemplate;
    }
  } 
 
  render(){
    return this.showtemplate;
  }

  navigateToReport(){
    console.log('testA');
    console.log()
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name:'ips_min_veilederrapport__c'
        },
        state: {
            recordId: 'a0qKN000000CkUIYA0'
        }
  });
}


@wire(getTrailWrapperClassList,{
    recordId: '$recordId'})
    trailClassListHandler
    ({data,error}){
        if(data){
            this.trailClassList = data[0];
            this.isTrail = true;
        }
        if(error){
            this.error = error;
        }
    }

@wire(getParticipantSharedReport,{
    recordId: '$recordId'})
    participantReportHandler
    ({data,error}){
        if(data){
            this.participantSharedReportList = data;
            this.isReport = true;

        }
        if(error){
            this.error = error;
        }
    }
    
}//end of class
