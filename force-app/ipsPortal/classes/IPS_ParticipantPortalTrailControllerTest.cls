/**
 * @description  : Test class for IPS_ParticipantPortalTrailController, which manages the retrieval of Work Trail data for participants in the IPS portal.
 * @author       : Ann Kristin Olsen
 * @date         : Jan 24, 2025
 * @author       : Håkon Kavli
 * @since        : 0.531.0
 **/
@IsTest
public class IPS_ParticipantPortalTrailControllerTest {
    // Class variables to hold test data that can be used across multiple test methods
    static Id workTrailId;
    static Id contactId;
    static User testUser;

    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;

        Account acc1 = IPS_TestDataFactory.createEmployerAccount();
        insert acc1;

        User testUserToCreate = IPS_TestDataFactory.getStandardUser('Sankt', 'Claus');
        insert testUserToCreate;

        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;

        workTrailId = jobbspor.Id;

        List<Task> tasksToInsert = new List<Task>();
        // Create Log
        Task logToCreate = new Task(
            ActivityDate = System.today(),
            IsVisibleInSelfService = true,
            Type_of_Task_IPSUO__c = 'Logg kontakt',
            Subject = 'Oppgave logg',
            WhatId = workTrailId,
            Samtalereferat__c = true,
            Status = 'Completed'
        );
        // Create goals
        Task delmaal = IPS_TestDataFactory.creategoal(workTrailId);
        Task delmaal2 = IPS_TestDataFactory.creategoal(workTrailId);
        tasksToInsert.add(logToCreate);
        tasksToInsert.add(delmaal);
        tasksToInsert.add(delmaal2);
        insert tasksToInsert;

        delmaal2.Status = 'Completed';
        update delmaal2;

        List<Event> eventsToInsert = new List<Event>();
        Event meeting = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, testUser.id, workTrailId);
        Event meeting2 = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, testUser.id, workTrailId);
        eventsToInsert.add(meeting);
        eventsToInsert.add(meeting2);
        insert eventsToInsert;

        meeting2.ips_Status1__c = 'Completed';
        update meeting2;

        List<ips_Job__c> jobsToInsert = new List<ips_Job__c>();
        ips_job__c job1 = IPS_TestDataFactory.createJob(acc1.id, workTrailId, 'Ongoing');
        ips_job__c job2 = IPS_TestDataFactory.createJob(acc1.id, workTrailId, 'Ongoing');
        jobsToInsert.add(job1);
        jobsToInsert.add(job2);
        insert jobsToInsert;

        job2.ips_Form_of_Employment__c = 'work training';
        update job2;

        ips_education__c edu1 = IPS_TestDataFactory.createEducation(workTrailId);
        insert edu1;

        AMS_Vocational_education_and_training__c eduAMS = IPS_TestDataFactory.createEducationAMS(workTrailId);
        insert eduAMS;
    }

    @IsTest
    public static void getTrailTest() {
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;

        List<IPS_ParticipantPortalWorkTrail> trail = null;
        List<IPS_ParticipantPortalWorkTrail> trail2 = null;
        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            trail = IPS_ParticipantPortalTrailController.getTrailWrapperClassList(participantId);
            trail2 = IPS_ParticipantPortalTrailController.getTrail(participantId);
        }
        Test.stopTest();

        System.Assert.isNotNull(trail, 'Trail should not be null');
        System.Assert.isNotNull(trail2, 'Trail2 should not be null');
    }

    @IsTest
    public static void getParticipantsLogsTest() {
        List<IPS_ParticipantPortalTask> logToRetrieve = new List<IPS_ParticipantPortalTask>();
        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            logToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsLogs(workTrailId);
        }
        Test.stopTest();
        System.Assert.isNotNull(logToRetrieve, 'Logs should not be null');
    }

    @IsTest
    public static void getParticipantsGoalsTest() {
        workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalTask> goalsToRetrieve = null;
        List<IPS_ParticipantPortalTask> completedGoalToRetrieve = null;
        User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            goalsToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsOpenGoals(workTrailId);
            completedGoalToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals(
                workTrailId
            );
        }
        Test.stopTest();

        System.Assert.isNotNull(goalsToRetrieve, 'Open goals should not be null');
        System.Assert.isNotNull(completedGoalToRetrieve, 'Expected to find a completed goal');
    }

    @IsTest
    public static void getParticipantOpenMeetingsTest() {
        workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        contactId = [SELECT CRM_Account__r.PersonContactId FROM Person__c WHERE Name = '12069755555']
        ?.CRM_Account__r.PersonContactId;
        List<IPS_ParticipantPortalEvent> meeting = null;
        List<IPS_ParticipantPortalEvent> meeting2 = null;
        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');
        System.runAs(testUser) {
            meeting = IPS_ParticipantPortalActivityController.getParticipantOpenMeetings(workTrailId, contactId);
            meeting2 = IPS_ParticipantPortalActivityController.getParticipantCompletedMeetings(workTrailId, contactId);
        }
        Test.stopTest();

        System.Assert.isNotNull(meeting, 'Open meetings should not be null');
        System.Assert.isNotNull(meeting2, 'Completed meetings should not be null');
    }

    @IsTest
    public static void getParticipantOpenJobsTest() {
        ID workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = null;
        User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            job = IPS_ParticipantPortalActivityController.getParticipantOpenJobs(workTrailId);
        }
        Test.stopTest();
        System.Assert.isNotNull(job, 'Open jobs should not be null');
    }

    @IsTest
    public static void getJobTrainings() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = null;
        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            job = IPS_ParticipantPortalActivityController.getParticipantOpenJobTrainings(workTrailId);
        }
        Test.stopTest();
        System.Assert.isNotNull(job, 'Open job trainings should not be null');
    }

    @IsTest
    public static void getEducationIPS() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        List<IPS_ParticipantPortalEducation> edu = null;

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');

        System.runAs(testUser) {
            edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducations(workTrailId);
        }
        Test.stopTest();

        System.Assert.isNotNull(edu, 'Education IPS should not be null');
    }

    @IsTest
    public static void getParticipantOpenEducationTrainingAMSTest() {
        List<IPS_ParticipantPortalEducation> educationToRetrieve = null;

        workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Jobbspesialist');
        System.runAs(testUser) {
            educationToRetrieve = IPS_ParticipantPortalActivityController.getParticipantOpenEducationTrainingAMS(
                workTrailId
            );
        }
        Test.stopTest();

        System.Assert.isNotNull(educationToRetrieve, 'Education AMS should not be null');
    }
}
