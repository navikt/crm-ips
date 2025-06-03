import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import formFactorPropertyName from '@salesforce/client/formFactor';
import templateEnd from './ips_ParticipantPortalReportEnd.html';
import templateIntervall from './ips_ParticipantPortalReportIntervall.html';
import templateDefault from './ips_ParticipantPortalReportDefault.html';

/* Intervall report */
import getParticipantOpenGoals from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportOpenGoals';
import getParticipantOpenMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings';
import getParticipantCancelledMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReportCancelledMeetings';
import getParticipantCompletedMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings';
import getParticipantCompletedGoals from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals';
import getParticipantJobs from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantJobs';
import getParticipantEducations from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantEducations';
import getParticipantAbsentMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings';

/* End report */
import getParticipantReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
import getParticipantReportCompletedGoalsEnd from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoalsEnd';
import getParticipantCompletedMeetingsEnd from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetingsEnd';
import getCompletedEmployeeMeetingsNo from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetingsNo';
import getCompletedEmployeeName from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportEmployeeNameMeetings';
import getParticipantJobsEnd from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantJobsEnd';
import getParticipantEducationsEnd from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantEducationsEnd';
import getParticipantAbsentMeetingsEndNo from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetingsEndNo';



import getParticipantCompletedEmployeeMetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings';


/* End and Intervall report */
import getParticipantPassivePeriods from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportAllPassivPeriods';




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
import participantPassiveSection from '@salesforce/label/c.IPS_Participant_passive_section_IPS';
import errorMessage from '@salesforce/label/c.IPS_error_message';
/* all logos related to IPS/AMS portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

const REPORT_TYPE_INTERVAL = 'Intervall';
const REPORT_TYPE_END = 'End report';
const REPORT_TYPE_IPS = 'IPS';
const REPORT_TYPE_REPORT = 'REPORT';

export default class Ips_ParticipantPortalReport extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeName;
    @api isActive = false;
    @api isIPS = false;
    reportList;
    goalList;
    absentMeetingsList;
    absentMeetingsListEndNo;
    cancelledMeetingsNumber;
    jobsList;
    jobsListEnd;
    educationList;
    educationListEnd;
    completedMeetingsList;
    completedMeetingsListEnd;
    employeeMeetingsList;
    employeeMeetingsListNo;
    employeeNameList;
    openMeetingsList;
    openGoalsList;
    completedGoalsList;
    completedGoalsListEnd;
    passivePeriodeList;
    reportTypeName;
    reportTrailRecordId;
    reportDateFrom = null;
    reportDateTo = null;
    reportRecordTypeName;
    isReportDataLoaded = false;
    isAMS = false;
    isGoal = false;
    isGoalEnd = false;
    isOpenGoal = false;
    isAbsent = false;
    isAbsentEnd = false;
    isCompleted = false;
    isCompletedEnd = false;
    isCancel = false;
    isEmployeeCompleted = false;
    isEmployeeCompletedNo = false;
    isEmployeeName = false;
    isOpenMeeting = false;
    isJob = false;
    isJobEnd = false;
    isEducation = false;
    isEducationEnd = false;
    isPassiv = false;
    numPops = 2;
    error;
    warningText = errorMessage;

    breadcrumbs = [
        {label: 'Mitt jobbspor',href: ''},
        {label: 'veilederrapport',href: ''}
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
        participantCooperationSection,
        participantPassiveSection
    };

    handleWireResponse(data, listProperty, flagProperty) {
        if (data && data.length > 0) {
            this[listProperty] = data;
            this[flagProperty] = true;
        }
    }

    handleWireError(error) {
        console.error('Wire error:', error);
        this.error = error;
    }


    render() {
        
        switch (this.reportTypeName) {
            case REPORT_TYPE_INTERVAL:
                return templateIntervall;
            case REPORT_TYPE_END:
                return templateEnd;
            default:
                return templateDefault;
        }
    }

    connectedCallback() {
        this.loadParticipantReport();
    }

    async loadParticipantReport() {
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
    }

    get typeValue() {
        return this.reportRecordTypeName === REPORT_TYPE_IPS;
    }

    get isDesktop() {
        return formFactorPropertyName === 'Large' || formFactorPropertyName === 'Medium';
    }

    get isMobile() {
        return formFactorPropertyName === 'Small'
    }
        

    

    @wire(getParticipantCancelledMeetings, {
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    cancelledMeetingsListHandler({ data, error }) {
        if (this.isReportDataLoaded ) {
            if (data) {
                if (data.length > 0) {
                    this.cancelledMeetingsNumber = data?.[0]?.AntallCancelledMeeting || 0;;
                    if (this.cancelledMeetingsNumber > 0) {
                        this.isCancel = true;
                    }
                }
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantEducations, {
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    educationHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'educationList', 'isEducation');
            }

            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantEducationsEnd, {
        recordId: '$reportTrailRecordId'
    })
    educationHandlerEnd({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'educationListEnd', 'isEducationEnd');
            }

            if (error) {
                this.handleWireError(error);
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
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'jobsList', 'isJob');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantJobsEnd, {
        recordId: '$reportTrailRecordId'
    })
    jobsHandlerEnd({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'jobsListEnd', 'isJobEnd');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

   

    @wire(getParticipantAbsentMeetings, {
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    absentListHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'absentMeetingsList', 'isAbsent');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    
    @wire(getParticipantAbsentMeetingsEndNo, {
        recordId: '$reportTrailRecordId'
    })
    absentListHandlerEnd({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'absentMeetingsListEndNo', 'isAbsentEnd');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }
   

    

    @wire(getParticipantOpenMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })
    openMeetingsHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'openMeetingsList', 'isOpenMeeting');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantPassivePeriods, {
        recordId: '$reportTrailRecordId'
    })
    passivePeriodHandler({ data, error }) {
        if (this.isReportDataLoaded && this.typeValue) {
            if (data) {
                this.handleWireResponse(data, 'passivePeriodeList', 'isPassiv');
            }
            if (error) {
                this.handleWireError(error);
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
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'openGoalsList', 'isOpenGoal');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantCompletedEmployeeMetings, {
        recordId: '$reportTrailRecordId',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    completeEmployeeHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'employeeMeetingsList', 'isEmployeeCompleted');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

@wire(getCompletedEmployeeName,{
    recordId: '$reportTrailRecordId'              
})
    employeeNameHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'employeeNameList', 'isEmployeeName');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }


    @wire(getCompletedEmployeeMeetingsNo, {
        recordId: '$reportTrailRecordId'
    })
    completeEmployeeNoHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'employeeMeetingsListNo', 'isEmployeeCompletedNo');
            }
            if (error) {
                this.handleWireError(error);
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
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL)  {
            if (data) {
                this.handleWireResponse(data, 'completedMeetingsList', 'isCompleted');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }
    

    @wire(getParticipantCompletedMeetingsEnd, {
        recordId: '$reportTrailRecordId'
    })
    completedListHandlerEnd({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) { {
            if (data) {
                this.handleWireResponse(data, 'completedMeetingsListEnd', 'isCompletedEnd');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }
}
    

    @wire(getParticipantCompletedGoals, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateFrom: '$reportDateFrom',
        recordDateTo: '$reportDateTo'
    })
    goalListHandler({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_INTERVAL) {
            if (data) {
                this.handleWireResponse(data, 'completedGoalsList', 'isGoal');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }

    @wire(getParticipantReportCompletedGoalsEnd, {
        recordId: '$reportTrailRecordId'
    })
    goalListHandlerEnd({ data, error }) {
        if (this.isReportDataLoaded && this.reportTypeName === REPORT_TYPE_END) {
            if (data) {
                this.handleWireResponse(data, 'completedGoalsListEnd', 'isGoalEnd');
            }
            if (error) {
                this.handleWireError(error);
            }
        }
    }
}
