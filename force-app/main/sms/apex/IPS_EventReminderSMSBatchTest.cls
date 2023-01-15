@isTest
private class IPS_EventReminderSMSBatchTest {
    @isTest
    static void eventWithin24hoursTest() {
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
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(1);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(1);
        insert participantEvent;

        IPS_EventReminderSMSBatch instance = new IPS_EventReminderSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        List<Event> eventList = [SELECT Id, IPS_IsReminderSMSSendt__c FROM Event WHERE Id = :participantEvent.Id];
        System.assertEquals(1, smsList.size(), 'One SMS should be created');
        System.assertEquals(true, eventList[0].IPS_IsReminderSMSSendt__c, 'Should be true since the sms was created');
    }

    @isTest
    static void eventOutside24hoursTest() {
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

        Event participantEvent2 = IPS_TestDataFactory.createParticipantEvent(
            personAccount.PersonContactId,
            workTrail.Id
        );
        participantEvent2.StartDateTime = participantEvent2.StartDateTime.addDays(+7);
        participantEvent2.EndDateTime = participantEvent2.EndDateTime.addDays(+7);
        insert participantEvent2;

        IPS_EventReminderSMSBatch instance = new IPS_EventReminderSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        List<Event> eventList = [
            SELECT Id, IPS_IsReminderSMSSendt__c
            FROM Event
            WHERE Id = :participantEvent.Id OR Id = :participantEvent2.Id
        ];
        System.assertEquals(0, smsList.size(), 'No SMS should be created');
        System.assertEquals(
            false,
            eventList[0].IPS_IsReminderSMSSendt__c,
            'Should be false since the sms was not created'
        );
        System.assertEquals(
            false,
            eventList[1].IPS_IsReminderSMSSendt__c,
            'Should be false since the sms was not created'
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
        participantEvent.IPS_IsReminderSMSSendt__c = true;
        insert participantEvent;

        IPS_EventReminderSMSBatch instance = new IPS_EventReminderSMSBatch();
        Test.startTest();
        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        System.assertEquals(0, smsList.size(), 'No SMS should be created since its already sent');
    }

    @isTest
    static void schedulableTest() {
        String cron_exp = '0 0 0 3 9 ? 2024';
        Test.startTest();
        String jobId = System.schedule('IPS_EventReminderSMSBatch', cron_exp, new IPS_EventReminderSMSBatch());
        Test.stopTest();
        System.assert(jobId != null);
    }
}
