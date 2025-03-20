import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import templateIPS from './ips_ParticipantPortalIPS.html';
import templateAMS from './ips_ParticipantPortalAMS.html';
import defaultTemplate from './ips_ParticipantPortalDefault.html';
import Id from '@salesforce/user/Id';
import USER_ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import getTrailWrapperClassList from '@salesforce/apex/IPS_ParticipantPortalTrailController.getTrailWrapperClassList';
import getParticipantSharedReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
import getTaskOpenGoals from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantsOpenGoals';
import getEventOpenMeetings from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantOpenMeetings';
import getJobOpenJobs from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantOpenJobs';
import getJobOpenJobTrainings from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantOpenJobTrainings';
import getEducationOpenEducations from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantOpenEducations';
import getEducationOpenEduTrainingAMS from '@salesforce/apex/IPS_ParticipantPortalActivityController.getParticipantOpenEducationTrainingAMS';
import getReportSharedReports from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
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
    currentUser = Id;
    error;
    @track recordTypeName;
    @track recordId;
    @track recordTrailId;
    @track isActive = true;
    trailClassList;
    participantSharedReportList;
    participantOpenGoalList;
    participantOpenEventList;
    participantOpenJobList;
    participantOpenJobTrainingList;
    participantOpenEducationList;
    participantOpenEducationTrainingAMSList;
    recordOwnerName;
    isGoal = false;
    isMeeting = false;
    isJob = false;
    isTraining = false;
    isEducation = false;
    isEducationAMS = false;
    isReport = false;
    isTrail = false;

    label = {
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
        workProfileTextAMS
    };
    // warning icon and text used in default page
    warningIcon = IPS_HOME_LOGOS + '/ExclamationmarkTriangle.svg';
    warningText =
        'Du må være aktiv deltaker i et av arbeidsmarkedstiltakene, individuell jobbstøtte eller arbeid med støtte, for tilgang til denne siden.';
    ipsLogoImg = IPS_HOME_LOGOS + '/IPSikon.svg';
    phoneImg = IPS_HOME_LOGOS + '/Phone.svg';
    meetingImg = IPS_HOME_LOGOS + '/MeetingSmall.svg';
    goalImg = IPS_HOME_LOGOS + '/ClipboardCheckmark.svg';
    jobsImg = IPS_HOME_LOGOS + '/Briefcase.svg';
    trainingImg = IPS_HOME_LOGOS + '/Buildings2.svg';
    educationImg = IPS_HOME_LOGOS + '/PencilBoard.svg';

    // end of warning icon and text used in default page
    // used in default page

    @wire(getRecord, {
        recordId: '$currentUser',
        fields: [USER_ACCOUNT_FIELD, USER_CONTACT_FIELD]
    })
    userContactAccount;

    get userAccountId() {
        return getFieldValue(this.userContactAccount.data, USER_ACCOUNT_FIELD);
    }

    get userContactId() {
        return getFieldValue(this.userContactAccount.data, USER_CONTACT_FIELD);
    }

    @wire(getTrailWrapperClassList, {
        recordId: '$userAccountId'
    })
    trailClassListHandler({ data, error }) {
        if (data) {
            this.trailClassList = data[0];
            this.recordId = this.trailClassList?.jobbsporId;
            this.recordTypeName = this.trailClassList?.jobbsporPostTypeNavn;
            this.isTrail = true;
        }
        if (error) {
            this.error = error;
        }
    }

    get isDesktop() {
        if (formFactorPropertyName === 'Large') {
            return true;
        } else if (formFactorPropertyName === 'Medium') {
            return true;
        } else if (formFactorPropertyName === 'Small') {
            return false;
        } else {
            return false;
        }
    }

    get showtemplate() {
        switch (this.recordTypeName) {
            case 'IPS':
                return templateIPS;
                break;
            case 'ips_Supported_Employment':
                return templateAMS;
                break;
            case 'default':
                return defaultTemplate;
                break;
            default:
                return defaultTemplate;
        }
    }

    render() {
        return this.showtemplate;
    }

    navigateToReport(event) {
        let reportRecordId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: "ips_min_veilederrapport__c"
            },

                state: {
                        recordId: reportRecordId
            }
        })
    }

    @wire(getParticipantSharedReport, {
        recordId: '$recordId'
    })
    participantReportHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantSharedReportList = data;
                this.isReport = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getTaskOpenGoals, {
        recordId: '$recordId'
    })
    participantOpenGoalHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenGoalList = data;
                this.isGoal = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getEventOpenMeetings, {
        recordId: '$recordId',
        contactId: '$userContactId'
    })
    participantOpenEventHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenEventList = data;
                this.isMeeting = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getJobOpenJobs, {
        recordId: '$recordId'
    })
    participantOpenJobHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenJobList = data;
                this.isJob = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getJobOpenJobTrainings, {
        recordId: '$recordId'
    })
    participantOpenJobTrainingHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenJobTrainingList = data;
                this.isTraining = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getEducationOpenEducations, {
        recordId: '$recordId'
    })
    participantOpenEducationHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenEducationList = data;
                this.isEducation = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getEducationOpenEduTrainingAMS, {
        recordId: '$recordId'
    })
    participantOpenEducationTrainingHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantOpenEducationTrainingAMSList = data;
                this.isEducationAMS = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getReportSharedReports, {
        recordId: '$recordId',
        typeOfId: 'TRAIL'
    })
    sharedReportHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.participantSharedReportList = data;
                this.isReport = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }
} //end of class
