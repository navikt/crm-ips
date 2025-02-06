import { LightningElement,wire,track,api} from 'lwc';
import templateEnd from       './ips_ParticipantPortalReportEnd.html';
import templateIntervall from './ips_ParticipantPortalReportIntervall.html';
import templateDefault from   './ips_ParticipantPortalReportDefault.html';
import getParticipantReport from '@salesforce/apex/IPS_ParticipantPortalReportController.getParticipantReport';
import mainGoalSection from '@salesforce/label/c.IPS_main_goal_section_report';
import summarizeSectionReport from '@salesforce/label/c.IPS_summarize_section_report';
import cooperationParticipantSection from '@salesforce/label/c.IPS_cooperation_with_participant_section';
import cooperationEmployerSection from '@salesforce/label/c.IPS_cooperation_with_employer_section';
import planNextPeriodeSection from '@salesforce/label/c.IPS_plan_for_next_periode';
import participantCommentSection from '@salesforce/label/c.IPS_participants_comment_section';
import priorityWorkSection from '@salesforce/label/c.IPS_priority_work_section_IPS';

export default class Ips_ParticipantPortalReport extends LightningElement {

    @api recordId;
    reportTypeName ='Intervall';
    isAMS = true;
    isIPS = false;

    reportList;
    isTrail = false;
    error;
    
    label ={
        mainGoalSection,
        summarizeSectionReport,
        cooperationParticipantSection,
        cooperationEmployerSection,
        planNextPeriodeSection,
        participantCommentSection,
        priorityWorkSection,
    };

    @wire(getParticipantReport,{
        recordId: '$recordId'})
        reportListHandler
        ({data,error}){
            if(data){
                console.log(JSON.stringify(data));
                this.reportList = data;
                console.log(JSON.stringify(this.reportList));
                this.isTrail = true;
            }
            if(error){
                this.error = error;
            }
        }

        get showtemplate(){
            if(this.reportTypeName ==='Intervall'){
                return templateIntervall;
            }
            if(this.reportTypeName ==='End report'){
                return templateEnd;
            }
            if(this.reportTypeName === undefined){
                return templateDefault;
            }else{
                return templateDefault;
            }
        }



        render(){
            return this.showtemplate;
          }
}