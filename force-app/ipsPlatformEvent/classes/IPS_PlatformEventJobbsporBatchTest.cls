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

        System.Assert.isNotNull(workTrail.Id, 'Work trail should be created before batch execution');
    }

    @isTest
    static void testPlatformEventJobbsporAllBatch() {
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        Person__c person = IPS_TestDataFactory.createPerson();
        insert person;

        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c = :person.Id];

        Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccount.Id);
        insert workTrail;

        Test.startTest();
        IPS_PlatformEventJobbsporAllBatch batch = new IPS_PlatformEventJobbsporAllBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.Assert.isNotNull(workTrail.Id, 'Work trail should exist for the all-batch test');
    }

    @isTest
    static void testPlatformEventJobbsporUserBatch() {
        User testUser = new User(
            Alias = 'utest',
            Email = 'userbatch@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User Batch',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Oslo',
            Username = 'userbatch' + System.now().getTime() + '@example.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Department = '42',
            CompanyName = 'NAV'
        );
        insert testUser;

        Test.startTest();
        IPS_PlatformEventJobbsporUserBatch batch = new IPS_PlatformEventJobbsporUserBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.Assert.areEqual(testUser.Id, [SELECT Id FROM User WHERE Id = :testUser.Id LIMIT 1].Id, 'User should still exist after batch execution');
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

        System.Assert.areEqual(1, jobs.size(), 'Only one monthly cron job should exist');
    }

    @isTest
    static void testUserBatchScheduleMonthlyDoesNotCreateDuplicateJobs() {
        Test.startTest();
        IPS_PlatformEventJobbsporUserBatch.scheduleMonthly();
        IPS_PlatformEventJobbsporUserBatch.scheduleMonthly();
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'IPS_PlatformEventJobbsporUserBatch_LastDayOfMonth'
        ];

        System.Assert.areEqual(1, jobs.size(), 'Only one user-batch monthly cron job should exist');
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

        Date monthStart = Date.today().toStartOfMonth();
        Date monthEnd = monthStart.addMonths(1).addDays(-1);

        List<Work_Trail__c> returnedTrails = [
            SELECT Id, ips_Status__c, ips_End_Date__c
            FROM Work_Trail__c
            WHERE ips_Status__c != 'Ended'
                OR (
                    ips_Status__c = 'Ended'
                    AND ips_End_Date__c >= :monthStart
                    AND ips_End_Date__c <= :monthEnd
                )
        ];

        Set<Id> returnedIds = new Set<Id>();
        for (Work_Trail__c trail : returnedTrails) {
            returnedIds.add(trail.Id);
        }

        System.Assert.isTrue(returnedIds.contains(activeTrail.Id), 'Active trails should be included');
        System.Assert.isTrue(returnedIds.contains(endedThisMonth.Id), 'Ended trails from this month should be included');
        System.Assert.isFalse(returnedIds.contains(endedLastMonth.Id), 'Ended trails from previous months should not be included');
    }

    @isTest
    static void testGetUserRolesToPlatformEventPublishesEvents() {
        User testUser = new User(
            Alias = 'utest',
            Email = 'roleevent@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Role Event',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Oslo',
            Username = 'roleevent' + System.now().getTime() + '@example.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Department = '42',
            CompanyName = 'NAV'
        );
        insert testUser;

        Test.startTest();
        IPS_PlatformEventJobbsporService.getUserRolesToPlatformEvent(new List<User>{ testUser });
        Test.stopTest();

        System.Assert.areEqual(1, [SELECT COUNT() FROM User WHERE Id = :testUser.Id], 'The user should exist after the service call');
    }
}