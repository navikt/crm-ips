@isTest
public class IPS_ParticipantPortalReportContTest {
    
    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;
        
        Account businessAccount = IPS_TestDataFactory.createEmployerAccount();
        insert businessAccount;
        
        User userId = IPS_TestDataFactory.getAdminUser('Sankt','Claus');
        insert userId;        
        
        /***** IPS *****/
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;
        
        jobbspor.ips_Passive__c = true;
        update jobbspor;
        
        Task taskActive = IPS_TestDataFactory.createPassiveActivateGoal(jobbspor.Id);
        insert taskActive;
        
        jobbspor.ips_Passive__c = false;
        update jobbspor;
        
        Task taskDeactive = IPS_TestDataFactory.createPassiveDeactivateGoal(jobbspor.Id);
        insert taskDeactive;
        
         Event participantMeetingCompleted = IPS_TestDataFactory.createParticipantEvent(contactId, jobbspor.Id);
        insert participantMeetingCompleted;

        participantMeetingCompleted.IPS_Status1__c = 'Completed';
        update participantMeetingCompleted;

        Event participantMeetingAbsent = IPS_TestDataFactory.createParticipantEvent(contactId, jobbspor.Id);
        insert participantMeetingAbsent;

        participantMeetingAbsent.IPS_Status1__c = 'Participant Absent';
        update participantMeetingAbsent;

        ips_job__c jobOngoingIPS = IPS_TestDataFactory.createJob(businessAccount.id, jobbspor.id, 'Ongoing');
        insert jobOngoingIPS;

        ips_job__c jobPlannedIPS = IPS_TestDataFactory.createJob(businessAccount.id, jobbspor.id, 'Planned');
        insert jobPlannedIPS;

        ips_Education__c eduOngoingIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduOngoingIPS;

        ips_Education__c eduPlannedIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduPlannedIPS;

        eduPlannedIPS.ips_Status__c = 'Planned';
        eduPlannedIPS.ips_Start_Date__c = System.today().addDays(7);
        update eduPlannedIPS;

        ips_Education__c eduCompletedIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduCompletedIPS;

        eduCompletedIPS.ips_Status__c = 'Completed';
        eduCompletedIPS.ips_Start_Date__c = System.today().addDays(-7);
        eduCompletedIPS.ips_End_Date__c = System.today().addDays(30);
        update eduCompletedIPS;
        
        
        /***** AMS *****/
        Work_Trail__c jobbsporAMS = IPS_TestDataFactory.createUOJobbspor(participantId);
        insert jobbsporAMS;
        
         AMS_Vocational_education_and_training__c eduOngoingAMS = IPS_TestDataFactory.createEducationAMS(jobbsporAMS.id);
        insert eduOngoingAMS;

        AMS_Vocational_education_and_training__c eduPlannedAMS = IPS_TestDataFactory.createEducationAMS(jobbsporAMS.id);
        insert eduPlannedAMS;

        eduPlannedAMS.AMS_Status__c = 'Planned';
        eduPlannedAMS.AMS_Start_Date__c = System.today().addDays(7);
        eduPlannedAMS.AMS_End_Date__c = System.today().addDays(30);
        update eduPlannedAMS;

        AMS_Vocational_education_and_training__c eduCompletedAMS = IPS_TestDataFactory.createEducationAMS(
            jobbsporAMS.id
        );
        insert eduCompletedAMS;

        eduCompletedAMS.AMS_Status__c = 'Completed';
        eduCompletedAMS.AMS_Start_Date__c = System.today().addDays(-7);
        eduCompletedAMS.AMS_End_Date__c = System.today();
        update eduCompletedAMS;
        
       
    }

	@isTest
    static void getReportPortalIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        intervallReport.IPS_worktrail_Type__c = 'IPS';
        intervallReport.IPS_status__c='Shared report';
        update intervallReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(workTrailId,'TRAIL');
    }
    
    @isTest
    static void getReportPortalAMS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        intervallReport.IPS_worktrail_Type__c = 'Supported Employment';
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
    
    @isTest
    static void intervallReportIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;

        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(intervallReport.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(intervallReport);
        IPS_viewReportPDFController testIntervallReport = new IPS_viewReportPDFController(sc);
    }

    @isTest
    static void endReportIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        insert endReport;

        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(endReport.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(endReport);
        IPS_viewReportPDFController testEndReport = new IPS_viewReportPDFController(sc);
    }

}