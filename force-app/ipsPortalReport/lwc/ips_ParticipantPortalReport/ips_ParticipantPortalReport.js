import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import formFactorPropertyName from '@salesforce/client/formFactor';
import templateEnd from './ips_ParticipantPortalReportEnd.html';
import templateIntervall from './ips_ParticipantPortalReportIntervall.html';
import templateDefault from './ips_ParticipantPortalReportDefault.html';
import getParticipantEducations from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantEducations';
import getParticipantJobs from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantJobs';
import getParticipantReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
import getParticipantCompletedGoals from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals';
import getParticipantCompletedMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings';
import getParticipantAbsentMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings';
import getParticipantCompletedEmployeeMetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings';
import getParticipantOpenMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings';
import getParticipantCancelledMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReportCancelledMeetings';
import getParticipantOpenGoals from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportOpenGoals';

import mainGoalSection from '@salesforce/label/c.IPS_main_goal_section_report';
import summarizeSectionReport from '@salesforce/label/c.IPS_summarize_section_report';
import cooperationParticipantSection from '@salesforce/label/c.IPS_cooperation_with_participant_section';
import cooperationEmployerSection from '@salesforce/label/c.IPS_cooperation_with_employer_section';
import planNextPeriodeSection from '@salesforce/label/c.IPS_plan_for_next_periode';
import participantCommentSection from '@salesforce/label/c.IPS_participants_comment_section';
import priorityWorkSection from '@salesforce/label/c.IPS_priority_work_section_IPS';
import participantWorkTraining from '@salesforce/label/c.IPS_participant_ork_training';
import completedGoalsInPeriodeSection from '@salesforce/label/c.IPS_completed_goals_in_periode';
import participantEducationSection from '@salesforce/label/c.IPS_participant_education_section';
/* all logos related to IPS/AMS portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_ParticipantPortalReport extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeName;
    @api isActive = false;
    @api isIPS = false;
    reportList;
    @track goalList;
    @track absentMeetingsList;
    @track cancelledMeetingsList;
    @track jobsList;
    @track educationList;
    @track completedMeetingsList;
    @track employeeMeetingsList;
    @track openMeetingsList;
    @track openGoalsList;
    @track completedGoalsList;
    @track reportTypeName;
    @track reportTrailRecordId;
    @track reportDateFrom;
    @track reportDateTo;
    @track reportRecordTypeName;
    isAMS = false;
    isIPS = false;
    isGoal = false;
    isOpenGoal = false;
    isAbsent = false;
    isCompleted = false;
    isCancel = false;
    isTrail = false;
    isEmployeeCompleted = false;
    isOpenMeeting = false;
    isJob = false;
    isEducation = false;
    error;
    numPops = 2;
    warningText ='Her skjedde det en feil.';

    breadcrumbs = [
        {
            label: 'Mitt jobbspor',
            href: ''
        },
        {
            label: 'veilederrapport',
            href: ''
        }
    ];

    homeImg = IPS_HOME_LOGOS + '/House.svg';

    label = {
        mainGoalSection,
        summarizeSectionReport,
        cooperationParticipantSection,
        cooperationEmployerSection,
        planNextPeriodeSection,
        participantCommentSection,
        priorityWorkSection,
        completedGoalsInPeriodeSection,
        participantWorkTraining,
        participantEducationSection
    };

    @wire(getParticipantReport, {
        recordId: '$recordId',
        typeOfId: 'REPORT'
    })
    reportListHandler({ data, error }) {
        console.log(JSON.stringify(data));
        if (data) {
            if (data.length > 0) {
            this.reportList = data;
            this.reportTypeName = this.reportList[0].reportType;
            this.reportTrailRecordId = this.reportList[0].reportTrailId;
            this.reportDateFrom = this.reportList[0].reportNotFormatFromDate;
            this.reportDateTo = this.reportList[0].reportNotFormatToDate;
            this.reportRecordTypeName = this.reportList[0].reportTrailType;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    get typeValue(){
        if(this.reportRecordTypeName ==='IPS'){
            return true;
        }if(this.reportRecordTypeName ==='AMS'){
            return false;
        }else{
            return false;
        }
    }

    get isDesktop(){
        if (formFactorPropertyName === 'Large') {
            return true;
        } else if (formFactorPropertyName === 'Medium') {
            return true;
        } else {
            return false;
        }
    }

    get isMobile() {
        if (formFactorPropertyName === 'Small') {
            return true;
        } else {
            return false;
        }
    }

    @wire(getParticipantOpenMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })
    openMeetingsHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
            this.openMeetingsList = data;
            this.isOpenMeeting = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantCancelledMeetings, {
            recordId: '$reportTrailRecordId',
            typeOfReport: '$reportTypeName',
            recordDateFrom: '$reportDateFrom',
            recordDateTo: '$reportDateTo'
        })
    cancelledMeetingsListHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
                this.cancelledMeetingsList = data;
                this.isCancel = true;
            }   
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantEducations, {
            recordId: '$reportTrailRecordId',
            typeOfReport: '$reportTypeName',
            recordDateFrom: '$reportDateFrom',
            recordDateTo: '$reportDateTo'
        })educationHandler({data,error}){
        if(data){
            if(data.length>0){
                this.educationList = data;
                this.isEducation = true;
            }
            if(error){
                this.error = error;
            }
        }
    }

    @wire(getParticipantJobs,{
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })jobsHandler({data,error}){
        if (data) {
            if (data.length > 0) {
            this.jobsList = data;
            this.isJob = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantCompletedEmployeeMetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    completeEmployeeHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
            this.employeeMeetingsList = data;
            this.isEmployeeCompleted = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantAbsentMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    absentListHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
            this.absentMeetingsList = data;
            this.isAbsent = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantCompletedMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    completedListHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
            this.completedMeetingsList = data;
            this.isCompleted = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantCompletedGoals, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    goalListHandler({ data, error }) {
        if (data) {
            if (data.length > 0) {
            this.goalList = data;
            this.isGoal = true;
            }
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantOpenGoals, {
            recordId: '$reportTrailRecordId',
            typeOfReport: '$reportTypeName',
            recordDateFrom: '$reportDateFrom',
            recordDateTo: '$reportDateTo'
        })
        openGoalsListHandler({ data, error }) {
            if (data) {
                if (data.length > 0) {
                    this.openGoalsList = data;  
                    this.isOpenGoal = true;
                }
            }
            if (error) {
                this.error = error;
            }
        }

    get showtemplate() {
        if (this.reportTypeName === 'Intervall') {
            return templateIntervall;
        }
        if (this.reportTypeName === 'End report') {
            return templateEnd;
        }
        if (this.reportTypeName === undefined) {
            return templateDefault;
        } else {
            return templateDefault;
        }
    }

    render() {
        return this.showtemplate;
    }
}
