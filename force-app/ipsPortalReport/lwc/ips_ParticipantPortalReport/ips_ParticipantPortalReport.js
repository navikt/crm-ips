import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import templateEnd from './ips_ParticipantPortalReportEnd.html';
import templateIntervall from './ips_ParticipantPortalReportIntervall.html';
import templateDefault from './ips_ParticipantPortalReportDefault.html';
import getParticipantReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
import getParticipantCompletedGoals from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals';
import getParticipantCompletedMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings';
import getParticipantAbsentMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings';
import getParticipantCompletedEmployeeMetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings';
import getParticipantOpenMeetings from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings';

import mainGoalSection from '@salesforce/label/c.IPS_main_goal_section_report';
import summarizeSectionReport from '@salesforce/label/c.IPS_summarize_section_report';
import cooperationParticipantSection from '@salesforce/label/c.IPS_cooperation_with_participant_section';
import cooperationEmployerSection from '@salesforce/label/c.IPS_cooperation_with_employer_section';
import planNextPeriodeSection from '@salesforce/label/c.IPS_plan_for_next_periode';
import participantCommentSection from '@salesforce/label/c.IPS_participants_comment_section';
import priorityWorkSection from '@salesforce/label/c.IPS_priority_work_section_IPS';
/* all logos related to IPS/AMS portal */
import IPS_HOME_LOGOS from '@salesforce/resourceUrl/ips_home_logo';

export default class Ips_ParticipantPortalReport extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeName;
    @api isActive = false;
    @api isIPS = false;
    reportList;
    goalList;
    @track absentMeetingsList;
    @track completedMeetingsList;
    @track employeeMeetingsList;
    @track openMeetingsList;
    @track reportTypeName;
    @track reportTrailRecordId;
    @track reportDateFrom;
    @track reportDateTo;
    isAMS = false;
    isIPS = false;
    isGoal = false;
    isAbsent = false;
    isCompleted = false;
    isTrail = false;
    isEmployeeCompleted = false;
    isOpenMeeting = false;
    error;
    numPops = 2;

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
        priorityWorkSection
    };

    @wire(getParticipantReport, {
        recordId: '$recordId',
        typeOfId: 'REPORT'
    })
    reportListHandler({ data, error }) {
        if (data) {
            this.reportList = data;
            this.reportTypeName = this.reportList[0].reportType;
            this.reportTrailRecordId = this.reportList[0].reportTrailId;
            this.reportDateFrom = this.reportList[0].reportNotFormatFromDate;
            this.reportDateTo = this.reportList[0].reportNotFormatToDate;
        }
        if (error) {
            this.error = error;
        }
    }

    @wire(getParticipantOpenMeetings, {
        recordId: '$reportTrailRecordId',
        typeOfReport: '$reportTypeName',
        recordDateTo: '$reportDateTo'
    })
    openMeetingsHandler({ data, error }) {
        if (data) {
            this.openMeetingsList = data;
            this.isOpenMeeting = true;
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
            this.employeeMeetingsList = data;
            this.isEmployeeCompleted = true;
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
            this.absentMeetingsList = data;
            this.isAbsent = true;
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
        console.log(JSON.stringify('Møter: ' + data));
        if (data) {
            this.completedMeetingsList = data;
            this.isCompleted = true;
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
            this.goalList = data;
            this.isGoal = true;
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
