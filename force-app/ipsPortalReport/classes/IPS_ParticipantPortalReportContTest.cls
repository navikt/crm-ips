@isTest
public class IPS_ParticipantPortalReportContTest {
    
    
    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        Account businessAccount = IPS_TestDataFactory.createEmployerAccount();
        insert businessAccount;
        
        
        
        User userId = IPS_TestDataFactory.getAdminUser('Sankt','Claus');
        insert userId;        
        
        /***** IPS *****/
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;
        
        jobbspor.ips_Passive__c = true;
        update jobbspor;

       /***** AMS *****/
       Work_Trail__c jobbsporAMS = IPS_TestDataFactory.createUOJobbspor(participantId);
       insert jobbsporAMS;
       
   
    }

	@isTest
    static void getParticipantReportIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        intervallReport.IPS_worktrail_Type__c = 'IPS';
        intervallReport.IPS_status__c='Shared report';
        insert intervallReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(workTrailId,'TRAIL');
    }
    
    @isTest
    static void getParticipantReportAMS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        intervallReport.IPS_worktrail_Type__c = 'Supported Employment';
        intervallReport.IPS_status__c='Shared report';
        insert intervallReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(workTrailId,'TRAIL');
    }
    
    @isTest
    static void getReportDetailIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        intervallReport.IPS_status__c='Shared report';
        intervallReport.IPS_worktrail_Type__c = 'IPS';
        insert intervallReport;

        ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        endReport.IPS_status__c='Shared report';
        endReport.IPS_worktrail_Type__c = 'IPS';
        insert endReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(intervallReport.id,'REPORT');
        List<IPS_ParticipantPortalReport> listReportEnd = IPS_ParticipantPortalReportController.getParticipantReport(endReport.id,'REPORT');
    }

    @isTest
    static void getReportDetailAMS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        intervallReport.IPS_status__c='Shared report';
        intervallReport.IPS_worktrail_Type__c = 'Supported Employment';
        insert intervallReport;

        ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        endReport.IPS_status__c='Shared report';
        endReport.IPS_worktrail_Type__c = 'Supported Employment';
        insert endReport;

        List<IPS_ParticipantPortalReport> listReport = IPS_ParticipantPortalReportController.getParticipantReport(intervallReport.id,'REPORT');
        List<IPS_ParticipantPortalReport> listReportEnd = IPS_ParticipantPortalReportController.getParticipantReport(endReport.id,'REPORT');
    }

    
    @isTest
    static void getCompletedGoals() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;

        Task participantGoalsCompleted = IPS_TestDataFactory.creategoal(workTrailId);
        participantGoalsCompleted.ips_Due_Date_Time__c = System.today().addDays(-7);
        participantGoalsCompleted.ActivityDate = System.today().addDays(-7);
        participantGoalsCompleted.Status = 'Completed' ;
        insert participantGoalsCompleted;

        List<IPS_ParticipantPortalTask> tasks = IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoals(
            workTrailId,
            Date.today().addDays(-30),
            Date.today()
        );

        List<IPS_ParticipantPortalTask> tasksEnd = IPS_ParticipantPortalReportController.getParticipantsReportCompletedGoalsEnd(
            workTrailId
        );

        // Assert
        System.assertNotEquals(0, tasks.size(), 'Completed goals should be returned');
        System.assertNotEquals(0, tasksEnd.size(), 'Completed goals should be returned');

    }

    @isTest
    static void getOpenGoals() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;

        Task participantGoalsCompleted = IPS_TestDataFactory.creategoal(workTrailId);
        participantGoalsCompleted.ips_Due_Date_Time__c = System.today().addDays(-7);
        participantGoalsCompleted.ActivityDate = System.today().addDays(-7);
        participantGoalsCompleted.Status = 'Open' ;
        insert participantGoalsCompleted;

        List<IPS_ParticipantPortalTask> tasksOpen = IPS_ParticipantPortalReportController.getParticipantsReportOpenGoals(
            workTrailId,
            'Intervall',
            Date.today().addDays(-30)
        );


        // Assert
        System.assertNotEquals(0, tasksOpen.size(), 'Open goals should be returned');

    }

    @isTest
    static void getCompletedMeetings() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;

        Event participantMeetingCompleted = IPS_TestDataFactory.createParticipantEvent(contactId, workTrailId);
            participantMeetingCompleted.IPS_Status1__c = 'Completed';
            insert participantMeetingCompleted;

        List<IPS_ParticipantPortalEvent> meetings = IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetings(
            workTrailId,
            'Intervall',
            Date.today().addDays(-30),
            Date.today()
        );

        List<IPS_ParticipantPortalEvent> meetingsEnd = IPS_ParticipantPortalReportController.getParticipantsReportCompletedMeetingsEnd(
            workTrailId
        );

        // Assert
        System.assertNotEquals(0, meetings.size(), 'Completed meetings should be returned');
        System.assertNotEquals(0, meetingsEnd.size(), 'Completed meetings should be returned');
    }

    @isTest
    static void getCancelledMeetings() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;

        Event participantMeetingCompleted = IPS_TestDataFactory.createParticipantEvent(contactId, workTrailId);
            participantMeetingCompleted.IPS_Status1__c = 'Cancelled';
            insert participantMeetingCompleted;

        List<IPS_ParticipantPortalEvent> meetingsCancel = IPS_ParticipantPortalReportController.getParticipantReportCancelledMeetings(
            workTrailId,
            Date.today().addDays(-30),
            Date.today()
        );

        // Assert
        System.assertNotEquals(0, meetingsCancel.size(), 'Cancelled meetings should be returned');
    }

    @isTest
    static void getOpenMeetings() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;

        Event participantMeetingCompleted = IPS_TestDataFactory.createParticipantEvent(contactId, workTrailId);
            participantMeetingCompleted.IPS_Status1__c = 'Open';
            insert participantMeetingCompleted;

        List<IPS_ParticipantPortalEvent> meetingsOpen = IPS_ParticipantPortalReportController.getParticipantsReportOpenMeetings(
            workTrailId,
            'Intervall',
            Date.today().addDays(-30)
        );

        // Assert
        System.assertNotEquals(0, meetingsOpen.size(), 'Open meetings should be returned');
    }

    

    @isTest
    static void getCompletedEmployeeMeetingsIPS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        ID businessAccountId = [SELECT id FROM Account WHERE recordtype.developername ='Employer' LIMIT 1]?.id;
        ID ownerId = [SELECT id FROM User WHERE firstname ='Sankt' and lastname ='Claus' LIMIT 1]?.id;

            Event participantMeetingCompleted = IPS_TestDataFactory.createEmployerEventWithParticipant(businessAccountId,ownerId, workTrailId);
            participantMeetingCompleted.IPS_Status1__c = 'Completed';
            insert participantMeetingCompleted;

        List<IPS_ParticipantPortalEvent> meetings = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings(
            workTrailId,
            Date.today().addDays(-30),
            Date.today()
        );

        List<IPS_ParticipantPortalEvent> meetingsEnd = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetingsNo(
            workTrailId
        );

        List<String> meetingsName = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeNameMeetings(
            workTrailId
        );

        

        // Assert
        System.assertNotEquals(0, meetings.size(), 'Completed meetings should be returned');
        System.assertNotEquals(0, meetingsEnd.size(), 'Completed meetings should be returned');
        System.assertNotEquals(0, meetingsName.size(), 'Meetingname should be returned');
    }

    @isTest
    static void getCompletedEmployeeMeetingsAMS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment' LIMIT 1]?.id;
        ID businessAccountId = [SELECT id FROM Account WHERE recordtype.developername ='Employer' LIMIT 1]?.id;
        ID ownerId = [SELECT id FROM User WHERE firstname ='Sankt' and lastname ='Claus' LIMIT 1]?.id;

            Event participantMeetingCompleted = IPS_TestDataFactory.createEmployerEventWithParticipant(businessAccountId,ownerId, workTrailId);
            participantMeetingCompleted.IPS_Status1__c = 'Completed';
            participantMeetingCompleted.IPS_Subcategory_Type_UO__c = 'Relationship building';
            insert participantMeetingCompleted;

        List<IPS_ParticipantPortalEvent> meetings = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetings(
            workTrailId,
            Date.today().addDays(-30),
            Date.today()
        );

        List<IPS_ParticipantPortalEvent> meetingsEnd = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeCompletedMeetingsNo(
            workTrailId
        );

        List<String> meetingsName = IPS_ParticipantPortalReportController.getParticipantsReportEmployeeNameMeetings(
            workTrailId
        );

        

        // Assert
        System.assertNotEquals(0, meetings.size(), 'Completed meetings should be returned');
        System.assertNotEquals(0, meetingsEnd.size(), 'Completed meetings should be returned');
        System.assertNotEquals(0, meetingsName.size(), 'Meetingname should be returned');
    }

    @isTest
    static void getReportAllPassivPeriods() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        Task taskActive = IPS_TestDataFactory.createPassiveActivateGoal(workTrailId);
        insert taskActive;
        
        Task taskDeactive = IPS_TestDataFactory.createPassiveDeactivateGoal(workTrailId);
        insert taskDeactive;

        Task followUpTask = IPS_TestDataFactory.creategoal(workTrailId);
        followUpTask.subject = 'Oppfølging av passiv deltaker';
        followUpTask.Status = 'Open';
        insert followUpTask;

        List<IPS_ParticipantPortalTask> passivePeriods = IPS_ParticipantPortalReportController.getParticipantsReportAllPassivPeriods(workTrailId);

        // Assert
        System.assertNotEquals(0, passivePeriods.size(), 'Passive periods should be returned');
    }

    @isTest
    static void getParticipantJobs() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        ID businessAccountId = [SELECT id FROM Account WHERE recordtype.developername ='Employer' LIMIT 1]?.id;
        

        ips_job__c jobOngoingIPS = IPS_TestDataFactory.createJob(businessAccountId, workTrailId, 'Ongoing');
        upsert jobOngoingIPS;

        ips_job__c jobCompletedIPS = IPS_TestDataFactory.createJob(businessAccountId, workTrailId, 'Completed');
        upsert jobOngoingIPS;

        ips_job__c jobPlannedIPS = IPS_TestDataFactory.createJob(businessAccountId, workTrailId, 'Planned');
        upsert jobPlannedIPS;

        List<IPS_ParticipantPortalJob> jobs = IPS_ParticipantPortalReportController.getParticipantJobs(
            workTrailId,
            Date.today().addMonths(-1),
            Date.today()
        );
        List<IPS_ParticipantPortalJob> jobsEnd = IPS_ParticipantPortalReportController.getParticipantJobsEnd(workTrailId);

        // Assert
        System.assertNotEquals(0, jobs.size(), 'Jobs should be returned');
        System.assertNotEquals(0, jobsEnd.size(), 'Jobs should be returned');
    }

    

    @isTest
    static void getParticipantEducations() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_Education__c eduOngoingIPS = IPS_TestDataFactory.createEducation(workTrailId);
        insert eduOngoingIPS;

        ips_Education__c eduPlannedIPS = IPS_TestDataFactory.createEducation(workTrailId);
        eduPlannedIPS.ips_Status__c = 'Planned';
        eduPlannedIPS.ips_Start_Date__c = System.today().addDays(7);
        insert eduPlannedIPS;

        ips_Education__c eduCompletedIPS = IPS_TestDataFactory.createEducation(workTrailId);
        eduCompletedIPS.ips_Status__c = 'Completed';
        eduCompletedIPS.ips_Start_Date__c = System.today().addDays(-7);
        eduCompletedIPS.ips_End_Date__c = System.today().addDays(30);
        insert eduCompletedIPS;

        List<IPS_ParticipantPortalEducation> educations = IPS_ParticipantPortalReportController.getParticipantEducations(
            workTrailId,
            Date.today().addMonths(-6),
            Date.today()
        );
        List<IPS_ParticipantPortalEducation> educationsEnd = IPS_ParticipantPortalReportController.getParticipantEducationsEnd(
            workTrailId
        );

        // Assert
        System.assertNotEquals(0, educations.size(), 'Educations should be returned');
        System.assertNotEquals(0, educationsEnd.size(), 'Educations should be returned');
    }

    @isTest
    static void getParticipantEducationsAMS() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'ips_Supported_Employment'  LIMIT 1]?.id;

        AMS_Vocational_education_and_training__c  eduOngoingAMS = IPS_TestDataFactory.createEducationAMS(workTrailId);
        insert eduOngoingAMS;

        AMS_Vocational_education_and_training__c  eduPlannedAMS = IPS_TestDataFactory.createEducationAMS(workTrailId);
        eduPlannedAMS.ams_Status__c = 'Planned';
        eduPlannedAMS.ams_Start_Date__c = System.today().addDays(60);
        eduPlannedAMS.ams_End_Date__c = null;
        insert eduPlannedAMS;

        AMS_Vocational_education_and_training__c  eduCompletedAMS = IPS_TestDataFactory.createEducationAMS(workTrailId);
        eduCompletedAMS.ams_Status__c = 'Completed';
        eduCompletedAMS.ams_Start_Date__c = System.today().addDays(-7);
        eduCompletedAMS.ams_End_Date__c = System.today().addDays(30);
        insert eduCompletedAMS;

        List<IPS_ParticipantPortalEducation> educations = IPS_ParticipantPortalReportController.getParticipantEducations(
            workTrailId,
            Date.today().addMonths(-1),
            Date.today()
        );
        List<IPS_ParticipantPortalEducation> educationsEnd = IPS_ParticipantPortalReportController.getParticipantEducationsEnd(
            workTrailId
        );

        // Assert
        System.assertNotEquals(0, educations.size(), 'Educations should be returned');
        System.assertNotEquals(0, educationsEnd.size(), 'Educations should be returned');
    }


    @isTest
    static void getParticipantsReportAbsentMeetings() {
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        String contactId = [SELECT PersonContactId FROM Account WHERE INT_PersonIdent__c  ='12069755555']?.PersonContactId;

        Event participantMeetingAbsent = IPS_TestDataFactory.createParticipantEvent(contactId, workTrailId);
        insert participantMeetingAbsent;

        participantMeetingAbsent.IPS_Status1__c = 'Participant Absent';
        update participantMeetingAbsent;

        List<IPS_ParticipantPortalEvent> absentMeetings = IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetings(
            workTrailId,
            Date.today().addMonths(-1),
            Date.today()
        );

        List<IPS_ParticipantPortalEvent> absentMeetingsEnd = IPS_ParticipantPortalReportController.getParticipantsReportAbsentMeetingsEndNo(
            workTrailId
        );

        // Assert
        System.assertNotEquals(0, absentMeetings.size(), 'Absent meetings should be returned');
        System.assertNotEquals(0, absentMeetingsEnd.size(), 'Absent meetings should be returned');
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