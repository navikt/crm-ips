import { LightningElement,track,wire } from 'lwc';
import { getFieldDisplayValue, getFieldValue, getRecord} from 'lightning/uiRecordApi';
/* work_trail__c */
import getUserWorkTrailId from '@salesforce/apex/IPS_myWorkTrailController.getUserWorkTrailId';
import FIELD_RECORDTYPENAME from '@salesforce/schema/Work_Trail__c.RecordType.DeveloperName';
import FIELD_NAME from '@salesforce/schema/Work_Trail__c.Name';
import FIELD_PARTNAME from '@salesforce/schema/Work_Trail__c.ips_Participant__c';
import FIELD_MAINGOAL from '@salesforce/schema/Work_Trail__c.ips_Main_goal__c';
import FIELD_CAREERWISHES from '@salesforce/schema/Work_Trail__c.ips_Priority_career_wishes__c';
import FIELD_FRAMEWORKJOBSEARCH from '@salesforce/schema/Work_Trail__c.ips_Framework_for_job_development_search__c';
import FIELD_PREFERREDWORKINGHOURS from '@salesforce/schema/Work_Trail__c.ips_Preferred_working_hours__c';
import FIELD_NETWORK from '@salesforce/schema/Work_Trail__c.ips_Network__c';
import FIELD_GEOGRAPHY from '@salesforce/schema/Work_Trail__c.ips_Geography__c';
import FIELD_TREATMENTTEAM from '@salesforce/schema/Work_Trail__c.ips_Behandlingsteam__c';
import FIELD_IPSUNG from '@salesforce/schema/Work_Trail__c.IPS_Ung__c';
import FIELD_REFFEREDDATE from '@salesforce/schema/Work_Trail__c.ips_Referred_date__c';
import FIELD_STARTDATE from '@salesforce/schema/Work_Trail__c.Oppstartsdato__c';
import FIELD_CONTACTNOSHOW from '@salesforce/schema/Work_Trail__c.ips_Contact_when_not_showing__c';
import FIELD_HOBBIES from '@salesforce/schema/Work_Trail__c.ips_Interests_Hobbies__c';
import FIELD_PERSQUALITY from '@salesforce/schema/Work_Trail__c.Personal_Qualities__c';
import FIELD_CULTURALBACKGROUND from '@salesforce/schema/Work_Trail__c.ips_Cultural_background__c';
import FIELD_ENVIRONMENTALCON from '@salesforce/schema/Work_Trail__c.ips_Environmental_conditions__c';
import FIELD_ECONOMY from '@salesforce/schema/Work_Trail__c.ips_Economy__c';
import FIELD_HEALTH from '@salesforce/schema/Work_Trail__c.ips_Health__c';
import FIELD_EDUCATION from '@salesforce/schema/Work_Trail__c.ips_Education__c';
import FIELD_WORKEXPERIANCE from '@salesforce/schema/Work_Trail__c.ips_Work_experience__c';
import FIELD_CONVERSATIONPREVIOUS from '@salesforce/schema/Work_Trail__c.ips_Conversation_with_previous_employers__c';
import FIELD_TRANSPARENCYDATE from '@salesforce/schema/Work_Trail__c.ips_Transparency_consent_obtained_date__c';
import FIELD_TRANSPARENCYCONTACT from '@salesforce/schema/Work_Trail__c.ips_Can_the_employer_be_contacted__c';
import FIELD_TRANSPARENCYEMPLOYERSHARE from '@salesforce/schema/Work_Trail__c.ips_What_can_be_shared_with_the_employer__c';
import FIELD_TRANSPARENCYEMPLOYERNOTSHARE from '@salesforce/schema/Work_Trail__c.What_cannot_be_shared_with_the_employer__c';
import FIELD_SUPERVISOR from '@salesforce/schema/Work_Trail__c.ips_NAV_supervisor__c';
import FIELD_FRAMEWORKBEFORE from '@salesforce/schema/Work_Trail__c.ips_Financialframework_before_start_work__c';
import FIELD_PLANWHENWORK from '@salesforce/schema/Work_Trail__c.ips_Plan__c';
import FIELD_TRANSITIONTOWORK from '@salesforce/schema/Work_Trail__c.ips_Transition_to_work__c';
import FIELD_APPLYINGDEPARTMENT from '@salesforce/schema/Work_Trail__c.ips_Applying_Department__c';
import FIELD_DESIREDPROFESSION from '@salesforce/schema/Work_Trail__c.ips_Desired_profession_industry_career__c';
import FIELD_DESIREDWORKINGENVIRONMENT from '@salesforce/schema/Work_Trail__c.ips_Desired_working_environment__c';
import FIELD_DESIREDWORKTASK from '@salesforce/schema/Work_Trail__c.ips_Desired_work_tasks__c';
import FIELD_MOBILITY from '@salesforce/schema/Work_Trail__c.ips_Mobility__c';
import FIELD_ECONOMYCONDITION from '@salesforce/schema/Work_Trail__c.ips_Economic_conditions__c';
import FIELD_SOCIALCONDITION from '@salesforce/schema/Work_Trail__c.ips_Social_conditions__c';
import FIELD_OTHER from '@salesforce/schema/Work_Trail__c.ips_Other__c';

/* Event/task */
import getEmployerActivity from '@salesforce/apex/IPS_myActivityController.getEmployerActivity';
import getParticipantActivity from '@salesforce/apex/IPS_myActivityController.getParticipantActivity';
import getParticipantGoal from '@salesforce/apex/IPS_myActivityController.getParticipantsGoal';

/* Worktrail fields */
const WORKTRAIL_FIELDS = [
    FIELD_NAME,
    FIELD_RECORDTYPENAME,
    FIELD_PARTNAME,
    FIELD_MAINGOAL,
    FIELD_CAREERWISHES,
    FIELD_FRAMEWORKJOBSEARCH,
    FIELD_PREFERREDWORKINGHOURS,
    FIELD_NETWORK,
    FIELD_GEOGRAPHY,
    FIELD_TREATMENTTEAM,
    FIELD_IPSUNG,
    FIELD_REFFEREDDATE,
    FIELD_STARTDATE,
    FIELD_CONTACTNOSHOW,
    FIELD_HOBBIES,
    FIELD_PERSQUALITY,
    FIELD_CULTURALBACKGROUND,
    FIELD_ENVIRONMENTALCON,
    FIELD_ECONOMY,
    FIELD_HEALTH,
    FIELD_EDUCATION,
    FIELD_WORKEXPERIANCE,
    FIELD_CONVERSATIONPREVIOUS,
    FIELD_TRANSPARENCYDATE,
    FIELD_TRANSPARENCYCONTACT,
    FIELD_TRANSPARENCYEMPLOYERSHARE,
    FIELD_TRANSPARENCYEMPLOYERNOTSHARE,
    FIELD_SUPERVISOR,
    FIELD_FRAMEWORKBEFORE,
    FIELD_PLANWHENWORK,
    FIELD_TRANSITIONTOWORK,
    FIELD_APPLYINGDEPARTMENT,
    FIELD_DESIREDPROFESSION,
    FIELD_DESIREDWORKINGENVIRONMENT,
    FIELD_DESIREDWORKTASK,
    FIELD_MOBILITY,
    FIELD_ECONOMYCONDITION,
    FIELD_SOCIALCONDITION,
    FIELD_OTHER
];

/* task/goal fields */
const COLUMNS =[
    {label: 'Forfallsdato', fieldName: 'ActivityDate',type: 'text',hideDefaultActions:true},
    {label: 'Emne', fieldName:'Subject',type: 'text',hideDefaultActions:true },
    {label: 'Beskrivelse', fieldName: 'Description',type: 'text',hideDefaultActions:true}
];

/* all logos related to IPS/UO portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_myTrail extends LightningElement {
myWorkDevelopmentIPS = IPS_HOME_LOGOS + '/EmployerFilled.svg';
myActivityImg = IPS_HOME_LOGOS + '/CalenderFilled.svg';
myGoalImg = IPS_HOME_LOGOS + '/TaskFilled.svg';
myPlanImg = IPS_HOME_LOGOS + '/DirectionSignFilled.svg';
@track currentuser = '0051X00000DtVvmQAF';
recordId;
recordtypename;
contactId;
@track record;
@track workTrailWire;
@track activityPartRecord;
@track activityEmplRecord;
@track participantGoalRecord;
isActivity = false;
isEmployer = false;
columns = COLUMNS;

get isMobile() {
    return window.screen.width < 576;
  }
  
  /* Fetch recordId from logged in user */
  @wire(getUserWorkTrailId,{userId:'$currentuser'})
  wiredtrail({ error, data }) {
        if (data) {
            this.record = data[0];
            this.recordId = this.record?.Id;
            this.contactId = this.record?.ips_Participant__r.PersonContactId;
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }


    /* Fetch all worktrail fields by getrecord */
    @wire(getRecord, { recordId: '$recordId', fields: WORKTRAIL_FIELDS })
    workTrail({error,data}){
        if(data){
            this.workTrailWire = data;
        }else if(error){
            console.log(error);
        }
    }

    get isIPS(){
        this.recordtypename = getFieldValue(this.workTrailWire,FIELD_RECORDTYPENAME);
        if(this.recordtypename === 'IPS'){
            return true;
        }
        if(this.recortypename === 'ips_Supported_Employment'){
            return false;
        }
    }

    @wire(getParticipantActivity, {workTrailId:'$recordId'})
    userPartActivity({error,data}){
       if(data){
        if(data.length >0){
            this.activityPartRecord = data;
            this.isActivity = true;
        }
       }else if(error){
           console.log('An error has ocurred');
           console.log(error);
       }
    }

    @wire(getEmployerActivity, {workTrailId:'$recordId',contactId: '$contactId'})
    userEmpActivity({error,data}){
       if(data){
        if(data.length>0){
            this.activityEmplRecord = data;
            this.isEmployer = true;
        }
       }else if(error){
           console.log('An error has ocurred');
           console.log(error);
       }
    }

    @wire(getParticipantGoal,{workTrailId:'$recordId'})
    userParGoal({error,data}){
        if(data){
             this.participantGoalRecord = data;
        }else if(error){
            console.log('An error has ocurred');
            console.log(error);
        }
    }

    /* UO and IPS fields */
    
    get namefield(){
        return getFieldValue(this.workTrailWire,FIELD_NAME);
    };

    get participantname(){
        return getFieldValue(this.workTrailWire,FIELD_PARTNAME);
    }

    get mainGoal() {
        return getFieldValue(this.workTrailWire,FIELD_MAINGOAL);
    }

    get treatmentteam(){
        return getFieldValue(this.workTrailWire,FIELD_TREATMENTTEAM);
    }


    /* IPS fields */
    get geography(){
        return getFieldValue(this.workTrailWire,FIELD_GEOGRAPHY);
    }

    get ipsnetwork(){
        return getFieldValue(this.workTrailWire,FIELD_NETWORK);
    }

    get prefferedworkinghours(){
        return getFieldValue(this.workTrailWire,FIELD_PREFERREDWORKINGHOURS);
    }

    get frameworkjobdevelopment(){
        return getFieldValue(this.workTrailWire,FIELD_FRAMEWORKJOBSEARCH);
    }

    get careerwishes(){
        return getFieldValue(this.workTrailWire,FIELD_CAREERWISHES);
    }

    get IPSung(){
        return getFieldValue(this.workTrailWire,FIELD_IPSUNG);
    }

    get referredDate(){
        return getFieldDisplayValue(this.workTrailWire,FIELD_REFFEREDDATE);
    }

    get startDate(){
        return getFieldValue(this.workTrailWire,FIELD_STARTDATE);
    }

    get contNoShow(){
        return getFieldValue(this.workTrailWire,FIELD_CONTACTNOSHOW);
    }

    get interestHobbies(){
        return getFieldValue(this.workTrailWire,FIELD_HOBBIES);
    }

    get personalQualities(){
        return getFieldValue(this.workTrailWire,FIELD_PERSQUALITY);
    }

    get culturalBackground(){
        return getFieldValue(this.workTrailWire,FIELD_CULTURALBACKGROUND);
    }

    get environmentalConditions(){
        return getFieldValue(this.workTrailWire,FIELD_ENVIRONMENTALCON);
    }

    get economy(){
        return getFieldValue(this.workTrailWire,FIELD_ECONOMY);
    }

    get health(){
        return getFieldValue(this.workTrailWire,FIELD_HEALTH);
    }

    get education(){
        return getFieldValue(this.workTrailWire,FIELD_EDUCATION);
    }

    get workExperiance(){
        return getFieldValue(this.workTrailWire,FIELD_WORKEXPERIANCE);
    }

    get conversationPreviousEmployer(){
        return getFieldValue(this.workTrailWire,FIELD_CONVERSATIONPREVIOUS);
    }

    get transparencyDate(){
        return getFieldDisplayValue(this.workTrailWire,FIELD_TRANSPARENCYDATE);
    }

    get transparencyEmployerContact(){
        return getFieldValue(this.workTrailWire,FIELD_TRANSPARENCYCONTACT);
    }

    get transparencyEmployerShare(){
        return getFieldValue(this.workTrailWire,FIELD_TRANSPARENCYEMPLOYERSHARE);
    }

    get transparencyEmployerNotShare(){
        return getFieldValue(this.workTrailWire,FIELD_TRANSPARENCYEMPLOYERNOTSHARE);
    }

    get navSupervisor(){
        return getFieldValue(this.workTrailWire,FIELD_SUPERVISOR);
    }

    get framesBeforeWork(){
        return getFieldValue(this.workTrailWire,FIELD_FRAMEWORKBEFORE);
    }

    get planWhenWork(){
        return getFieldValue(this.workTrailWire,FIELD_PLANWHENWORK);
    }

    get transitionToWork(){
        return getFieldValue(this.workTrailWire,FIELD_TRANSITIONTOWORK);
    }

    get applyingDepartment(){
        return getFieldValue(this.workTrailWire,FIELD_APPLYINGDEPARTMENT);
    }

    get desiredProfession(){
        return getFieldValue(this.workTrailWire,FIELD_DESIREDPROFESSION);
    }

    get desiredWorkingEnvironment(){
        return getFieldValue(this.workTrailWire,FIELD_DESIREDWORKINGENVIRONMENT);
    }

    get desiredWorkTask(){
        return getFieldValue(this.workTrailWire,FIELD_DESIREDWORKTASK);
    }

    get ipsMobility(){
        return getFieldValue(this.workTrailWire,FIELD_MOBILITY);
    }

    get economicCondition(){
        return getFieldValue(this.workTrailWire,FIELD_ECONOMYCONDITION);
    }

    get socialCondition(){
        return getFieldValue(this.workTrailWire,FIELD_SOCIALCONDITION);
    }

    get other(){
        return getFieldValue(this.workTrailWire,FIELD_OTHER);
    }

}