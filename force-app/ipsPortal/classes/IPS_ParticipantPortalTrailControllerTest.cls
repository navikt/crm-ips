/**
 * @description  : Test class for IPS_ParticipantPortalTrailController, which manages the retrieval of Work Trail data for participants in the IPS portal.
 * @author       : Ann Kristin Olsen
 * @date         : Jan 24, 2025
 * @author       : Håkon Kavli
 * @since        : 0.530.0
 **/
@isTest
public class IPS_ParticipantPortalTrailControllerTest {
    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;

        Account acc1 = IPS_TestDataFactory.createEmployerAccount();
        insert acc1;

        User usr1 = IPS_TestDataFactory.getAdminUser('Sankt', 'Claus');
        insert usr1;

        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;

        List<Task> tasksToInsert = new List<Task>();
        Task delmaal = IPS_TestDataFactory.creategoal(jobbspor.id);
        Task delmaal2 = IPS_TestDataFactory.creategoal(jobbspor.id);
        tasksToInsert.add(delmaal);
        tasksToInsert.add(delmaal2);
        insert tasksToInsert;

        delmaal2.Status = 'Completed';
        update delmaal2;

        Task log = new task();
        log.ActivityDate = system.today();
        log.IsVisibleInSelfService = true;
        log.Type_of_Task_IPSUO__c = 'Logg kontakt';
        log.Subject = 'Oppgave logg';
        log.WhatId = jobbspor.id;
        log.Samtalereferat__c = true;
        log.Status = 'Completed';
        insert log;

        List<Event> eventsToInsert = new List<Event>();
        Event meeting = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, usr1.id, jobbspor.id);
        eventsToInsert.add(meeting);

        Event meeting2 = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, usr1.id, jobbspor.id);
        eventsToInsert.add(meeting2);
        insert eventsToInsert;

        meeting2.ips_Status1__c = 'Completed';
        update meeting2;

        List<ips_Job__c> jobsToInsert = new List<ips_Job__c>();
        ips_job__c job1 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Ongoing');
        jobsToInsert.add(job1);

        ips_job__c job2 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Ongoing');
        jobsToInsert.add(job2);
        insert jobsToInsert;

        job2.ips_Form_of_Employment__c = 'work training';
        update job2;

        ips_education__c edu1 = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert edu1;

        AMS_Vocational_education_and_training__c eduAMS = IPS_TestDataFactory.createEducationAMS(jobbspor.id);
        insert eduAMS;
    }

    @isTest
    static void getTrail() {
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;

        List<IPS_ParticipantPortalWorkTrail> trail = IPS_ParticipantPortalTrailController.getTrailWrapperClassList(
            participantId
        );
        List<IPS_ParticipantPortalWorkTrail> trail2 = IPS_ParticipantPortalTrailController.getTrail(participantId);
        System.Assert.isNotNull(trail, 'Trail should not be null');
        System.Assert.isNotNull(trail2, 'Trail2 should not be null');
    }

    @isTest
    static void getLog() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalTask> log = IPS_ParticipantPortalActivityController.getParticipantsLogs(workTrailId);
        System.Assert.isNotNull(log, 'Logs should not be null');
    }

    @isTest
    static void getGoals() {
        ID workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalTask> goal = IPS_ParticipantPortalActivityController.getParticipantsOpenGoals(
            workTrailId
        );
        List<IPS_ParticipantPortalTask> goalCompleted = IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals(
            workTrailId
        );

        System.Assert.isNotNull(goal, 'Open goals should not be null');
        System.Assert.isNotNull(goalCompleted, 'Completed goals should not be null');
    }

    @isTest
    static void getMeeting() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        Id contactId = [SELECT CRM_Account__r.PersonContactId FROM Person__c WHERE Name = '12069755555']
        ?.CRM_Account__r.PersonContactId;
        List<IPS_ParticipantPortalEvent> meeting = IPS_ParticipantPortalActivityController.getParticipantOpenMeetings(
            workTrailId,
            contactId
        );
        List<IPS_ParticipantPortalEvent> meeting2 = IPS_ParticipantPortalActivityController.getParticipantCompletedMeetings(
            workTrailId,
            contactId
        );
        System.Assert.isNotNull(meeting, 'Open meetings should not be null');
        System.Assert.isNotNull(meeting2, 'Completed meetings should not be null');
    }

    @isTest
    static void getJob() {
        ID workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = IPS_ParticipantPortalActivityController.getParticipantOpenJobs(
            workTrailId
        );
        System.Assert.isNotNull(job, 'Open jobs should not be null');
    }

    @isTest
    static void getJobTrainings() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalJob> job = IPS_ParticipantPortalActivityController.getParticipantOpenJobTrainings(
            workTrailId
        );
        System.Assert.isNotNull(job, 'Open job trainings should not be null');
    }

    @isTest
    static void getEducationIPS() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalEducation> edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducations(
            workTrailId
        );
        System.Assert.isNotNull(edu, 'Education IPS should not be null');
    }

    @isTest
    static void getEducationAMS() {
        Id workTrailId = [SELECT Id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.Id;
        List<IPS_ParticipantPortalEducation> edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducationTrainingAMS(
            workTrailId
        );
        System.Assert.isNotNull(edu, 'Education AMS should not be null');
    }
}
