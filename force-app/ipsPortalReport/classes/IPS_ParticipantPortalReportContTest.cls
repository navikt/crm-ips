@isTest
public class IPS_ParticipantPortalReportContTest {
    
    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;
        
        Account acc1 = IPS_TestDataFactory.createEmployerAccount();
        insert acc1;
        
        User usr1 = IPS_TestDataFactory.getAdminUser('Sankt','Claus');
        insert usr1;        
        
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor; 
        
        Task delmaal = IPS_TestDataFactory.creategoal(jobbspor.id);
        insert delmaal;
        
        Event meeting = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, usr1.id, jobbspor.id);
        insert meeting;
        
        Event meeting1 = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, usr1.id, jobbspor.id);
        insert meeting1;
        meeting1.ips_status1__c = 'Completed';
        update meeting1;
        
        Event meetingPart = IPS_TestDataFactory.createParticipantEvent(contactId, jobbspor.id);
        insert meetingPart;
        meetingPart.IPS_Status1__c ='Completed';
        update meetingPart;
        
        Event meetingPart1 = IPS_TestDataFactory.createParticipantEvent(contactId, jobbspor.id);
        insert meetingPart1;
        meetingPart1.IPS_Status1__c ='Cancelled';
        update meetingPart1;
        
        ips_job__c job1 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Completed');
        insert job1;
        
        ips_job__c job3 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Planned');
        insert job3;
        
        ips_job__c job2 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Ongoing');
        insert job2;
        job2.ips_Form_of_Employment__c = 'work training';
        update job2;
        
        ips_education__c edu1 = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert edu1;
        edu1.ips_Status__c ='Ongoing';
        update edu1;
        
        ips_education__c edu2 = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert edu2;
         edu2.ips_Status__c ='Completed';
        update edu2;
        
        ips_education__c edu3 = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert edu3;
         edu3.ips_Status__c ='Planned';
        update edu3;
        
        AMS_Vocational_education_and_training__c eduAMS = IPS_TestDataFactory.createEducationAMS(jobbspor.id);
        insert eduAMS;
        eduAMS.AMS_Status__c ='Ongoing';
        update eduAMS;
        
        AMS_Vocational_education_and_training__c eduAMS1 = IPS_TestDataFactory.createEducationAMS(jobbspor.id);
        insert eduAMS1;
        eduAMS1.AMS_Status__c ='Completed';
        update eduAMS1;
        
    }

	@isTest
    static void getReportPortal() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        intervallReport.IPS_status__c='Shared report';
        update intervallReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(workTrailId,'TRAIL');
    }
    
    @isTest
    static void getReportDetail() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        intervallReport.IPS_status__c='Shared report';
        update intervallReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(intervallReport.id,'REPORT');
    }
    
    @isTest
    static void intervallReport(){
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        intervallReport.IPS_status__c='Shared report';
        update intervallReport;

        List<IPS_ParticipantPortalTask> goal = IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalTask> openGoal = IPS_ParticipantPortalReportController.getParticipantsReportOpenGoals(intervallReport.id, 'Intervall', intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> meeting =  IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> absent = IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> cancelled = IPS_ParticipantPortalReportController.getParticipantReportCancelledMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> employee =  IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> openmeeting =  IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalJob> jobs = IPS_ParticipantPortalReportController.getParticipantJobs(workTrailId,intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<ips_ParticipantPortalEducation> edu = IPS_ParticipantPortalReportController.getParticipantEducations(workTrailId,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
    }
    
     @isTest
    static void EndReport(){
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        insert endReport;
        endReport.IPS_status__c='Shared report';
        update endReport;

        List<IPS_ParticipantPortalTask> goal = IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals(endReport.id,'End report',null,null);
        List<IPS_ParticipantPortalEvent> meeting =  IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings(endReport.id,'End report',null,null);
        List<IPS_ParticipantPortalEvent> absent = IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings(endReport.id,'End report',null,null);
        List<IPS_ParticipantPortalEvent> cancelled = IPS_ParticipantPortalReportController.getParticipantReportCancelledMeetings(endReport.id,'End report',null,null);
        /*
        List<IPS_ParticipantPortalEvent> employee =  IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalEvent> openmeeting =  IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings(intervallReport.id,'Intervall',intervallReport.IPS_intervallDateTo__c);
        List<IPS_ParticipantPortalJob> jobs = IPS_ParticipantPortalReportController.getParticipantJobs(workTrailId,intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
        List<ips_ParticipantPortalEducation> edu = IPS_ParticipantPortalReportController.getParticipantEducations(workTrailId,'Intervall',intervallReport.IPS_intervallDateFrom__c,intervallReport.IPS_intervallDateTo__c);
*/
    }

}