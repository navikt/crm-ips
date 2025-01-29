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
import getTaskOpenGoals from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantsOpenGoals';
/* label IPS */
import informationTextIPS from '@salesforce/label/c.IPS_Information_text_IPS';
import titleTextIPS from '@salesforce/label/c.IPS_title_text_IPS';
import jobDevelopmentTitle from '@salesforce/label/c.IPS_job_development_title_IPS';
import careerProfileTitle from '@salesforce/label/c.IPS_career_profile_title_IPS';
import workEducationSupportTitle from '@salesforce/label/c.IPS_education_and_work_support_title_IPS';
import cooperationTitle from '@salesforce/label/c.IPS_cooperation_title_IPS';
import cooperationText from '@salesforce/label/c.IPS_cooperation_text_IPS';
import economyTitle from '@salesforce/label/c.IPS_economy_title_IPS';
/* label AMS */
import informationTextAMS from '@salesforce/label/c.IPS_Information_text_AMS';
import titleTextAMS from '@salesforce/label/c.IPS_title_text_AMS';
import workProfileAMS from '@salesforce/label/c.IPS_work_profile_AMS';
import workProfileTextAMS from '@salesforce/label/c.IPS_work_profile_text_AMS';
import educationExperienceAMS from '@salesforce/label/c.IPS_educattion_and_experience_AMS';
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


export default class Ips_ParticipantPortal extends NavigationMixin(LightningElement) {
//currentUser = USER_ID;
//currentUser ='005KF000006zTHqYAM';//ips
currentUser ='005KF000006zS0YYAU';//ams
error;
@track recordTypeName;
@track participantSharedReportList;
@track recordId;
recordOwnerName;
@track isActive = false;
isGoal = false;
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
        workEducationSupportTitle,
        cooperationText,
        workProfileAMS,
        educationExperienceAMS,
        workProfileTextAMS,
};
// warning icon and text used in default page
warningIcon = IPS_HOME_LOGOS + '/ExclamationmarkTriangle.svg';
warningText ='Du må være aktiv deltaker i et av arbeidsmarkedstiltakene, individuell jobbstøtte eller arbeid med støtte, for tilgang til denne siden.';
ipsLogoImg = IPS_HOME_LOGOS + '/IPSikon.svg';
phoneImg = IPS_HOME_LOGOS + '/Phone.svg';
meetingImg = IPS_HOME_LOGOS + '/MeetingSmall.svg'
goalImg = IPS_HOME_LOGOS + '/ClipboardCheckmark.svg';
jobsImg = IPS_HOME_LOGOS + '/Briefcase.svg';
trainingImg = IPS_HOME_LOGOS + '/Buildings2.svg';
educationImg = IPS_HOME_LOGOS + '/PencilBoard.svg';



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

@wire(getTaskOpenGoals,{
    recordId:'$recordId'})
    participantOpenGoalHandler
    ({data,error}){
        if(data){
            this.participantOpenGoalList = data;
            this.isGoal = true;
        }
        if(error){
            this.error = error;
        }
    }
    
}//end of class
