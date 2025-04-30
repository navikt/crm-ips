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
import participantGoalTitle from '@salesforce/label/c.IPS_participant_goals_title_IPS';
import participantGoalTitleAMS from '@salesforce/label/c.IPS_participant_goals_title_AMS';
import participantCareerPlanTitleAMS from '@salesforce/label/c.IPS_participant_career_plan_title_AMS';
import partcicipantGoalSection from '@salesforce/label/c.IPS_participant_goal_section';
import employerCooperationSection from '@salesforce/label/c.IPS_employer_cooperation_section';
import participantCooperationSection from '@salesforce/label/c.IPS_participant_cooperation_section';
/* all logos related to IPS/AMS portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

const REPORT_TYPE_INTERVAL = 'Intervall';
const REPORT_TYPE_END = 'End report';
const REPORT_TYPE_UNDEFINED = undefined;
const REPORT_TYPE_AMS = 'AMS';
const REPORT_TYPE_IPS = 'IPS';
const REPORT_TYPE_REPORT = 'REPORT';

export default class Ips_ParticipantPortalReport extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeName;
    @api isActive = false;
    @api isIPS = false;
    @track reportList;
    @track goalList;
    @track absentMeetingsList;
    @track cancelledMeetingsNumber;
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
    @track isReportDataLoaded = false;
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
    isPassiv = false;
    error;
    numPops = 2;
    warningText = 'Her skjedde det en feil.';

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
        participantEducationSection,
        participantGoalTitle,
        participantGoalTitleAMS,
        participantCareerPlanTitleAMS,
        partcicipantGoalSection,
        employerCooperationSection,
        participantCooperationSection
    };

    handleWireResponse(data, listProperty, flagProperty) {
        if (data && data.length > 0) {
            this[listProperty] = data;
            this[flagProperty] = true;
        }
    }

    get showtemplate() {
        if (this.reportTypeName === REPORT_TYPE_INTERVAL) {
            return templateIntervall;
        }
        if (this.reportTypeName === REPORT_TYPE_END) {
            return templateEnd;
        }
        if (this.reportTypeName === REPORT_TYPE_UNDEFINED) {
            return templateDefault;
        } else {
            return templateDefault;
        }
    }

    render() {
        return this.showtemplate;
    }

    connectedCallback() {
        this.loadParticipantReport();
    }

    async loadParticipantReport() {
        try {
            const data = await getParticipantReport({ recordId: this.recordId, typeOfId: REPORT_TYPE_REPORT });
            if (data && data.length > 0) {
                this.reportList = data;
                this.reportTypeName = this.reportList[0].reportType;
                this.reportRecordTypeName = this.reportList[0].reportTrailType;
                this.reportTrailRecordId = this.reportList[0].reportTrailId;
                this.reportDateFrom = this.reportList[0].reportNotFormatFromDate;
                this.reportDateTo = this.reportList[0].reportNotFormatToDate;
                this.isReportDataLoaded = true;
            }
            
        } catch (error) {
            this.error = error;
            this.isReportDataLoaded = false;
        }
    }

    get typeValue() {
        if (this.reportRecordTypeName === REPORT_TYPE_IPS) {
            return true;
        }
        if (this.reportRecordTypeName === REPORT_TYPE_AMS) {
            return false;
        } else {
            return false;
        }
    }

    get isDesktop() {
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

    @wire(getParticipantCompletedGoals, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    goalListHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'completedGoalsList', 'isGoal');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantCancelledMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    cancelledMeetingsListHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                if (data.length > 0) {
                    this.cancelledMeetingsNumber = data[0].AntallCancelledMeeting;
                    if (this.cancelledMeetingsNumber > 0) {
                        this.isCancel = true;
                    }
                }
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantEducations, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    educationHandler({ data, error }) {
        console.log(JSON.stringify(data));
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'educationList', 'isEducation');
            }

            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantJobs, {
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })
    jobsHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'jobsList', 'isJob');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantCompletedEmployeeMetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    completeEmployeeHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'employeeMeetingsList', 'isEmployeeCompleted');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantAbsentMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    absentListHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'absentMeetingsList', 'isAbsent');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantCompletedMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    completedListHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'completedMeetingsList', 'isCompleted');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantOpenGoals, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    openGoalsListHandler({ data, error }) {
        if (this.isReportDataLoaded) {
            if (data) {
                this.handleWireResponse(data, 'openGoalsList', 'isOpenGoal');
            }
            if (error) {
                this.error = error;
            }
        }
    }

    @wire(getParticipantOpenMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })
    openMeetingsHandler({ data, error }) {
        if (this.isReportDataLoaded ) {
            if (data) {
                this.handleWireResponse(data, 'openMeetingsList', 'isOpenMeeting');
            }
            if (error) {
                this.error = error;
            }
        }
    }
}
