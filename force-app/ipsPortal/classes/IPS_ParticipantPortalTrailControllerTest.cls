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

        List<Work_Trail__c> workTrailsToCreate = new List<Work_Trail__c>();
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        Work_Trail__c amsWorkTrail = IPS_TestDataFactory.createUOJobbspor(participantId);
        workTrailsToCreate.add(jobbspor);
        workTrailsToCreate.add(amsWorkTrail);
        insert workTrailsToCreate;

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
        delmaal.Subject = 'Få en jobb';
        delmaal2.Subject = 'Lage en bra test';
        tasksToInsert.add(logToCreate);
        tasksToInsert.add(delmaal);
        tasksToInsert.add(delmaal2);
        insert tasksToInsert;

        // Set one goal to completed to test retrieval of both open and completed goals
        delmaal2.Status = 'Completed';
        update delmaal2;

        List<Event> eventsToInsert = new List<Event>();
        Event meeting = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, testUser.id, workTrailId);
        Event meeting2 = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, testUser.id, workTrailId);
        eventsToInsert.add(meeting);
        eventsToInsert.add(meeting2);
        insert eventsToInsert;

        // Complete one meeting to test retrieval of both open and completed meetings
        meeting2.IPS_Status1__c = 'Completed';
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

        AMS_Vocational_education_and_training__c eduAMS = IPS_TestDataFactory.createEducationAMS(amsWorkTrail.Id);
        insert eduAMS;
    }

    @IsTest
    public static void getTrailTest() {
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;

        List<IPS_ParticipantPortalWorkTrail> trails1 = null;
        List<IPS_ParticipantPortalWorkTrail> trails2 = null;
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];

        List<Work_Trail__c> jobbspor = [
            SELECT Id, Name, ips_Participant__c, ips_End_Date__c
            FROM Work_Trail__c
            WHERE ips_Participant__c = :participantId
            LIMIT 1
        ];

        Test.startTest();
        // Run as system user and Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            trails1 = IPS_ParticipantPortalTrailController.getTrailWrapperClassList(participantId);
            trails2 = IPS_ParticipantPortalTrailController.getTrail(participantId);
        }
        Test.stopTest();

        Work_Trail__c expectedTrail = [
            SELECT Id, Name, ips_Participant__c, ips_End_Date__c, RecordType.DeveloperName, IPS_ownerName__c
            FROM Work_Trail__c
            WHERE ips_Participant__c = :participantId
            LIMIT 1
        ];
        System.Assert.isNotNull(trails1, 'Trail should not be null');
        System.Assert.isNotNull(trails2, 'Trail2 should not be null');
        System.Assert.areEqual(1, trails1.size(), 'Expected to find one trail');
        System.Assert.areEqual(1, trails2.size(), 'Expected to find one Id');
        System.Assert.areEqual(expectedTrail.Id, trails1[0].jobbsporId, 'Expected Jobbspor Id to match');
        System.Assert.areEqual(expectedTrail.Id, trails2[0].jobbsporId, 'Expected Jobbspor Id to match');
        System.Assert.areEqual('Jobb', trails1[0].ipsHovedmaal, 'Expected IPS Hovedmål to be Jobb');
        System.Assert.areEqual(
            'Ingen hovedmål valgt',
            trails1[0].amsHovedmaal,
            'Expected AMS Hovedmål to be Ingen hovedmål valgt'
        );
        System.Assert.areEqual(
            expectedTrail.IPS_ownerName__c,
            trails1[0].jobbsporEierNavn,
            'Expected Jobbspor owner name to match'
        );
        System.Assert.areEqual(
            expectedTrail.RecordType.DeveloperName,
            trails1[0].jobbsporPostTypeNavn,
            'Expected Jobbspor post type to match'
        );
        System.Assert.areEqual(
            'In Education',
            trails1[0].jobbsporStatus,
            'Expected Jobbspor status to be In Education'
        );
    }

    @IsTest
    public static void getParticipantsLogsTest() {
        List<IPS_ParticipantPortalTask> logToRetrieve = new List<IPS_ParticipantPortalTask>();
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            logToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsLogs(workTrailId);
        }
        Test.stopTest();
        System.Assert.isNotNull(logToRetrieve, 'Logs should not be null');
    }

    @IsTest
    public static void getParticipantsGoalsTest() {
        workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalTask> goalsToRetrieve = null;
        List<IPS_ParticipantPortalTask> completedGoalToRetrieve = null;
        // User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            goalsToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsOpenGoals(workTrailId);
            completedGoalToRetrieve = IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals(
                workTrailId
            );
        }
        Test.stopTest();

        Task expectedCompletedGoal = [
            SELECT Id, Subject, CompletedDateTime, ActivityDate, CreatedDate, Description
            FROM Task
            WHERE WhatId = :workTrailId AND Status = 'Completed' AND Type_of_Task_IPSUO__c = 'Delmål (av hovedmål)'
            LIMIT 1
        ];

        Task expectedOpenGoal = [
            SELECT Id, Subject, Status, CompletedDateTime, ActivityDate, CreatedDate, Description
            FROM Task
            WHERE WhatId = :workTrailId AND Status = 'Open' AND Type_of_Task_IPSUO__c = 'Delmål (av hovedmål)'
            LIMIT 1
        ];

        System.Assert.isNotNull(goalsToRetrieve, 'Open goals should not be null');
        System.Assert.isNotNull(completedGoalToRetrieve, 'Expected to find a completed goal');

        System.Assert.areEqual(1, goalsToRetrieve.size(), 'Expected to find one open goal');
        System.Assert.areEqual(1, completedGoalToRetrieve.size(), 'Expected to find one completed goal');

        System.Assert.areEqual(
            expectedOpenGoal.Id,
            goalsToRetrieve[0].OppgaveId,
            'Expected open goal Id to match the open one created in test setup'
        );
        System.Assert.areEqual(
            expectedOpenGoal.Subject,
            goalsToRetrieve[0].Emne,
            'Expected open goal subject to match the one created in test setup'
        );

        System.Assert.areEqual(
            expectedCompletedGoal.Id,
            completedGoalToRetrieve[0].OppgaveId,
            'Expected completed goal Id to match the completed one created in test setup'
        );
        System.Assert.areEqual(
            expectedCompletedGoal.Subject,
            completedGoalToRetrieve[0].Emne,
            'Expected completed goal subject to match the one created in test setup'
        );
        /*   TODO: fix discrepancies   
        System.Assert.areEqual(
            IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(expectedCompletedGoal.CompletedDateTime)),
            completedGoalToRetrieve[0].UtfoertDato,
            'Expected completed date to match the one created in test setup'
        );
        System.Assert.areEqual(
            IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(expectedCompletedGoal.ActivityDate)),
            completedGoalToRetrieve[0].ForfallsDato,
            'Expected due date to match the one created in test setup'
        );
        System.Assert.areEqual(
            IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(expectedCompletedGoal.CreatedDate)),
            completedGoalToRetrieve[0].OpprettelsesDato,
            'Expected created date to match the one created in test setup'
        );  */
    }

    @IsTest
    public static void getParticipantOpenMeetingsTest() {
        workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = 'IPS' LIMIT 1]?.Id;
        contactId = [SELECT CRM_Account__r.PersonContactId FROM Person__c WHERE Name = '12069755555']
        ?.CRM_Account__r.PersonContactId;
        List<IPS_ParticipantPortalEvent> meeting = null;
        List<IPS_ParticipantPortalEvent> meeting2 = null;
        // User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');
        System.runAs(testUser) {
            meeting = IPS_ParticipantPortalActivityController.getParticipantOpenMeetings(workTrailId, contactId);
            meeting2 = IPS_ParticipantPortalActivityController.getParticipantCompletedMeetings(workTrailId, contactId);
        }
        Test.stopTest();

        System.Assert.isNotNull(meeting, 'Open meetings should not be null');
        System.Assert.isNotNull(meeting2, 'Completed meetings should not be null');
        System.Assert.areEqual(1, meeting.size(), 'Expected to find 1 open meeting');
        System.Assert.areEqual(1, meeting2.size(), 'Expected to find 1 completed meeting');
    }

    @IsTest
    public static void getParticipantOpenJobsTest() {
        ID workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = null;
        // User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test users
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            job = IPS_ParticipantPortalActivityController.getParticipantOpenJobs(workTrailId);
        }
        Test.stopTest();
        List<ips_Job__c> expectedJobs = [
            SELECT Id, Name, ips_Form_of_Employment__c
            FROM ips_Job__c
            WHERE ips_Work_Trail__c = :workTrailId AND ips_Status__c = 'Ongoing'
            LIMIT 1
        ];
        System.Assert.isNotNull(job, 'Open jobs should not be null');
        System.Assert.areNotEqual(0, job.size(), 'Expected at least one open job');
        System.Assert.areEqual(
            expectedJobs[0].Id,
            job[0].JobbId,
            'Expected job Id to match the one created in test setup'
        );
    }

    @IsTest
    public static void getJobTrainings() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = null;
        //testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            job = IPS_ParticipantPortalActivityController.getParticipantOpenJobTrainings(workTrailId);
        }
        Test.stopTest();
        ips_Job__c expectedJob = [
            SELECT Id, Name, ips_Form_of_Employment__c
            FROM ips_Job__c
            WHERE ips_Work_Trail__c = :workTrailId AND ips_Form_of_Employment__c = 'work training'
            LIMIT 1
        ];

        System.Assert.isNotNull(job, 'Open job trainings should not be null');
        System.Assert.areNotEqual(0, job.size(), 'Expected at least one open job training');
        System.Assert.areEqual(
            expectedJob.Id,
            job[0].JobbId,
            'Expected job training Id to match the one created in test setup'
        );
    }

    @IsTest
    public static void getEducationIPS() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = 'IPS' LIMIT 1]?.Id;
        //        User testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        List<IPS_ParticipantPortalEducation> edu = null;

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');

        System.runAs(testUser) {
            edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducations(workTrailId);
        }
        Test.stopTest();

        System.Assert.isNotNull(edu, 'Education IPS should not be null');
        System.Assert.areNotEqual(0, edu.size(), 'Expected at least one open education IPS');
    }

    @IsTest
    public static void getParticipantOpenEducationTrainingAMSTest() {
        List<IPS_ParticipantPortalEducation> educationToRetrieve = null;

        workTrailId = [SELECT Id FROM Work_Trail__c WHERE ips_UO_Service__c = 'AMS' LIMIT 1]?.Id;
        // testUser = [SELECT Id FROM User WHERE Name = 'Sankt Claus' LIMIT 1];
        testUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];

        Test.startTest();
        // Give IPS Jobbspesialist profile access to the test user
        IPS_TestDataFactory.givePermissionSetToUserByName(testUser.Id, 'IPS_Deltaker');
        System.runAs(testUser) {
            educationToRetrieve = IPS_ParticipantPortalActivityController.getParticipantOpenEducationTrainingAMS(
                workTrailId
            );
        }
        Test.stopTest();

        List<AMS_Vocational_education_and_training__c> expectedEducation = [
            SELECT Id, AMS_Start_Date__c
            FROM AMS_Vocational_education_and_training__c
            WHERE AMS_Work_Trail__c = :workTrailId AND AMS_Status__c = 'Ongoing'
        ];

        System.Assert.isNotNull(educationToRetrieve, 'Education AMS should not be null');
        System.Assert.areNotEqual(0, educationToRetrieve.size(), 'Expected at least one open education AMS');
        System.Assert.areEqual(
            expectedEducation[0].Id,
            educationToRetrieve[0].UtdanningId,
            'Expected education AMS Id to match the one created in test setup'
        );
        System.Assert.areEqual(
            expectedEducation[0].AMS_Start_Date__c,
            educationToRetrieve[0].UtdanningStart,
            'Expected education AMS start date to match the one created in test setup'
        );
    }
}
