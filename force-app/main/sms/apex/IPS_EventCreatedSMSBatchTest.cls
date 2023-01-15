@isTest
private class IPS_EventCreatedSMSBatchTest {
    @isTest
    static void participantEventTest() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        insert workTrail;

        Event participantEvent = IPS_TestDataFactory.createParticipantEvent(
            personAccount.PersonContactId,
            workTrail.Id
        );
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(7);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(7);
        insert participantEvent;

        IPS_EventCreatedSMSBatch instance = new IPS_EventCreatedSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id, EventId__c FROM SMS__c];
        System.assertEquals(1, smsList.size(), 'One SMS should be created');
        System.assertEquals(participantEvent.Id, smsList[0].EventId__c, 'Not connected to correct event');
        List<Event> eventList = [SELECT Id, IPS_IsCreatedSMSSendt__c FROM Event WHERE Id = :participantEvent.Id];
        System.assertEquals(true, eventList[0].IPS_IsCreatedSMSSendt__c, 'Should be true since the sms was created');
    }

    @isTest
    static void eventInThePastTest() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        insert workTrail;

        Event participantEvent = IPS_TestDataFactory.createParticipantEvent(
            personAccount.PersonContactId,
            workTrail.Id
        );
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(-7);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(-7);
        insert participantEvent;

        IPS_EventCreatedSMSBatch instance = new IPS_EventCreatedSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        System.assertEquals(0, smsList.size(), 'No SMS should be created');
        List<Event> eventList = [SELECT Id, IPS_IsCreatedSMSSendt__c FROM Event WHERE Id = :participantEvent.Id];
        System.assertEquals(
            false,
            eventList[0].IPS_IsCreatedSMSSendt__c,
            'Should be false since the sms not was created'
        );
    }

    @isTest
    static void smsAlreadySentTest() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        insert workTrail;

        Event participantEvent = IPS_TestDataFactory.createParticipantEvent(
            personAccount.PersonContactId,
            workTrail.Id
        );
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(7);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(7);
        participantEvent.IPS_IsCreatedSMSSendt__c = true;
        insert participantEvent;

        IPS_EventCreatedSMSBatch instance = new IPS_EventCreatedSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        System.assertEquals(0, smsList.size(), 'No SMS should be created');
    }

    @isTest
    static void employerEventWithoutParticipantTest() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Event employerEventWithoutParticipant = IPS_TestDataFactory.createEmployerEventWithoutParticipant(employer.Id);
        employerEventWithoutParticipant.StartDateTime = employerEventWithoutParticipant.StartDateTime.addDays(7);
        employerEventWithoutParticipant.EndDateTime = employerEventWithoutParticipant.EndDateTime.addDays(7);
        insert employerEventWithoutParticipant;

        IPS_EventCreatedSMSBatch instance = new IPS_EventCreatedSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        System.assertEquals(0, smsList.size(), 'No SMS should be created');
    }

    @isTest
    static void schedulableTest() {
        String cron_exp = '0 0 0 3 9 ? 2024';
        Test.startTest();
        String jobId = System.schedule('IPS_EventCreatedSMSBatch', cron_exp, new IPS_EventCreatedSMSBatch());
        Test.stopTest();
        System.assert(jobId != null);
    }
}
