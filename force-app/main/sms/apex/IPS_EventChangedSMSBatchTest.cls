@isTest
private class IPS_EventChangedSMSBatchTest {
    @isTest
    static void eventChangedTest() {
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

        IPS_EventChangedSMSBatch instance = new IPS_EventChangedSMSBatch();
        Test.startTest();
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(1);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(1);
        update participantEvent;

        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id, EventId__c FROM SMS__c];
        System.assertEquals(1, smsList.size(), 'One SMS should be created');
        List<Event> eventList = [SELECT Id, IPS_IsSendChangeSMS__c FROM Event WHERE Id = :participantEvent.Id];
        System.assertEquals(false, eventList[0].IPS_IsSendChangeSMS__c, 'Should be false since the sms was created');
    }

    @isTest
    static void createdSMSNotSentTest() {
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
        participantEvent.IPS_IsCreatedSMSSendt__c = false;
        insert participantEvent;

        IPS_EventChangedSMSBatch instance = new IPS_EventChangedSMSBatch();
        Test.startTest();
        participantEvent.StartDateTime = participantEvent.StartDateTime.addDays(1);
        participantEvent.EndDateTime = participantEvent.EndDateTime.addDays(1);
        update participantEvent;

        database.executebatch(instance);
        Test.stopTest();

        List<SMS__c> smsList = [SELECT Id FROM SMS__c];
        List<Event> eventList = [
            SELECT Id, IPS_IsSendChangeSMS__c, IPS_IsCreatedSMSSendt__c
            FROM Event
            WHERE Id = :participantEvent.Id
        ];
        System.assertEquals(0, smsList.size(), 'No SMS should be created');
        System.assertEquals(
            false,
            eventList[0].IPS_IsSendChangeSMS__c,
            'Should be false since the create sms was not sent'
        );
        System.assertEquals(
            false,
            eventList[0].IPS_IsCreatedSMSSendt__c,
            'Should be false since the sms was not created'
        );
    }

    @isTest
    static void schedulableTest() {
        String cron_exp = '0 0 0 30 9 ? 2030';
        Test.startTest();
        String jobId = System.schedule('IPS_EventChangedSMSBatch', cron_exp, new IPS_EventChangedSMSBatch());
        Test.stopTest();
        System.assert(jobId != null);
    }
}
