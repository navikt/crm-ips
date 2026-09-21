@isTest
public class IPS_PlatformEventJobbsporBatchTest {

    @isTest
    static void testPlatformEventJobbsporBatch() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        insert workTrail;
        
        Test.startTest();

        IPS_PlatformEventJobbsporBatch batch = new IPS_PlatformEventJobbsporBatch();
        Database.executeBatch(batch);

        Test.stopTest();
    }

    @isTest
    static void testScheduleMonthlyDoesNotCreateDuplicateJobs() {
        Test.startTest();
        IPS_PlatformEventJobbsporBatch.scheduleMonthly();
        IPS_PlatformEventJobbsporBatch.scheduleMonthly();
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'IPS_PlatformEventJobbsporBatch_Monthly'
        ];

        System.assertEquals(1, jobs.size(), 'Only one monthly cron job should exist');
    }

    @isTest
    static void testBatchFiltersCurrentMonthEndedAndActiveTrails() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c activeTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        activeTrail.ips_Status__c = 'In Education';
        insert activeTrail;

        Work_Trail__c endedThisMonth = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        endedThisMonth.ips_Status__c = 'Ended';
        endedThisMonth.ips_End_Date__c = Date.today();
        insert endedThisMonth;

        Work_Trail__c endedLastMonth = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        endedLastMonth.ips_Status__c = 'Ended';
        endedLastMonth.ips_End_Date__c = Date.today().addMonths(-1);
        insert endedLastMonth;

        IPS_PlatformEventJobbsporBatch batch = new IPS_PlatformEventJobbsporBatch();
        Database.QueryLocator locator = batch.start(null);

        Set<Id> returnedIds = new Set<Id>();
        for (sObject record : Database.query(locator.getQuery())) {
            returnedIds.add(record.Id);
        }

        System.assert(returnedIds.contains(activeTrail.Id), 'Active trails should be included');
        System.assert(returnedIds.contains(endedThisMonth.Id), 'Ended trails from this month should be included');
        System.assert(!returnedIds.contains(endedLastMonth.Id), 'Ended trails from previous months should not be included');
    }
}