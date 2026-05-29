/**
 * @description  : Test class for IPS_ManagerTrailController, which manages aggregated Work Trail data for managers in IPS. This test class includes various test methods to validate the functionality of the controller, ensuring that it correctly retrieves and processes Work Trail data based on different criteria and scenarios.
 * @author       : Ann Kristin Olsen, Balendra Sounthararajan
 * @author       : Håkon Kavli
 * @since        : 0.533.0
 * @version      : 0.533.0
 **/
@isTest
public class IPS_MangagerTrailControllerTest {
    @TestSetup
    private static void makeData() {
        Person__c person = IPS_TestDataFactory.createPerson('12050923564');
        insert person;

        Person__c personWithAccount = [SELECT CRM_Account__c, CRM_Account__r.PersonContactId FROM Person__C LIMIT 1];
        Id accountId = personWithAccount.CRM_Account__c;
        Id contactId = personWithAccount.CRM_Account__r.PersonContactId;

        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;

        User employeeUser = IPS_TestDataFactory.createInternalUserWithManager(
            'test.trail@nav.no',
            UserInfo.getUserId()
        );
        insert employeeUser;

        List<Work_Trail__c> trails = new List<Work_Trail__c>();

        System.runAs(employeeUser) {
            Work_Trail__c trail = IPS_TestDataFactory.createJobbspor(accountId);
            Work_Trail__c uoTrail = IPS_TestDataFactory.createUOJobbspor(accountId);
            trails.add(trail);
            trails.add(uoTrail);
            insert trails;
        }
    }

    @IsTest
    private static void testEmptyLists() {
        // Given
        List<Work_Trail__c> trails = [SELECT Id FROM Work_Trail__c];
        delete trails;

        // When
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedTrailStatus();
        List<IPS_ManagerTrail> referredTrails = IPS_ManagerTrailController.getReferredTrails();
        List<IPS_ManagerTrail> jobbspesialistTrails = IPS_ManagerTrailController.getAggregatedTrailJobbspesialist();
        List<IPS_ManagerTrail> uoTrainingTrails = IPS_ManagerTrailController.getUOTraining();
        List<IPS_ManagerTrail> endedTrails = IPS_ManagerTrailController.getAggregatedEndedTrail();

        // Then
        System.Assert.isNull(allTrails, 'Expected null to be returned when there are no trails');
        System.Assert.isNull(referredTrails, 'Expected null to be returned when there are no trails');
        System.Assert.isNull(jobbspesialistTrails, 'Expected null to be returned when there are no trails');
        System.Assert.isNull(uoTrainingTrails, 'Expected null to be returned when there are no trails');
        System.Assert.isNull(endedTrails, 'Expected null to be returned when there are no trails');
    }

    @IsTest
    private static void getUserTrails() {
        // When
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedTrailStatus();

        // Then
        System.Assert.areEqual(2, allTrails.size(), 'Expected two trails assigned to managers employee to be returned');
        System.Assert.areNotEqual(
            allTrails[0].service,
            allTrails[1].service,
            'Expected trails to have different services'
        );
    }

    @IsTest
    private static void getAggregatedTrailJobbspesialist() {
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedTrailJobbspesialist();
        System.Assert.areEqual(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');
    }

    @IsTest
    private static void getUOTraining() {
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getUOTraining();
        System.Assert.areEqual(1, allTrails.size(), 'Expect trail in UO training');
    }

    @IsTest
    private static void getAggregatedEndedTrail() {
        String expectedCause = 'Other end causes';
        String expectedSubCause = 'Illness';
        String expectedStatus = 'Ended';

        Work_Trail__c t = [SELECT Id, ips_Status__c, End_Cause__c, ips_Other_end_cases__c FROM Work_Trail__c LIMIT 1];
        t.ips_Status__c = expectedStatus;
        t.End_Cause__c = expectedCause;
        t.ips_Other_end_cases__c = expectedSubCause;
        update t;

        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedEndedTrail();
        System.Assert.areEqual(
            1,
            allTrails[0].numberOfTrail,
            'Expected one trail assigned to managers employee to be returned'
        );
        System.Assert.areEqual(expectedCause, allTrails[0].cause, 'Expected cause to be Other end causes');
        System.Assert.areEqual(expectedSubCause, allTrails[0].subCause, 'Expected sub cause to be Illness');
    }

    @isTest
    private static void testMonthMapConversion() {
        // Given
        String expectedJanuary = 'Januar';
        String expectedFebruary = 'Februar';
        String expectedMarch = 'Mars';
        String expectedApril = 'April';
        String expectedMay = 'Mai';
        String expectedJune = 'Juni';
        String expectedJuly = 'Juli';
        String expectedAugust = 'August';
        String expectedSeptember = 'September';
        String expectedOctober = 'Oktober';
        String expectedNovember = 'November';
        String expectedDecember = 'Desember';

        // When
        Test.startTest();
        String actualJanuary = IPS_ManagerTrailController.monthNumberMap.get(1);
        String actualFebruary = IPS_ManagerTrailController.monthNumberMap.get(2);
        String actualMarch = IPS_ManagerTrailController.monthNumberMap.get(3);
        String actualApril = IPS_ManagerTrailController.monthNumberMap.get(4);
        String actualMay = IPS_ManagerTrailController.monthNumberMap.get(5);
        String actualJune = IPS_ManagerTrailController.monthNumberMap.get(6);
        String actualJuly = IPS_ManagerTrailController.monthNumberMap.get(7);
        String actualAugust = IPS_ManagerTrailController.monthNumberMap.get(8);
        String actualSeptember = IPS_ManagerTrailController.monthNumberMap.get(9);
        String actualOctober = IPS_ManagerTrailController.monthNumberMap.get(10);
        String actualNovember = IPS_ManagerTrailController.monthNumberMap.get(11);
        String actualDecember = IPS_ManagerTrailController.monthNumberMap.get(12);
        Test.stopTest();

        // Then
        System.Assert.areEqual(expectedJanuary, actualJanuary, 'Expect January to be converted to ' + expectedJanuary);
        System.Assert.areEqual(
            expectedFebruary,
            actualFebruary,
            'Expect February to be converted to ' + expectedFebruary
        );
        System.Assert.areEqual(expectedMarch, actualMarch, 'Expect March to be converted to ' + expectedMarch);
        System.Assert.areEqual(expectedApril, actualApril, 'Expect April to be converted to ' + expectedApril);
        System.Assert.areEqual(expectedMay, actualMay, 'Expect May to be converted to ' + expectedMay);
        System.Assert.areEqual(expectedJune, actualJune, 'Expect June to be converted to ' + expectedJune);
        System.Assert.areEqual(expectedJuly, actualJuly, 'Expect July to be converted to ' + expectedJuly);
        System.Assert.areEqual(expectedAugust, actualAugust, 'Expect August to be converted to ' + expectedAugust);
        System.Assert.areEqual(
            expectedSeptember,
            actualSeptember,
            'Expect September to be converted to ' + expectedSeptember
        );
        System.Assert.areEqual(expectedOctober, actualOctober, 'Expect October to be converted to ' + expectedOctober);
        System.Assert.areEqual(
            expectedNovember,
            actualNovember,
            'Expect November to be converted to ' + expectedNovember
        );
        System.Assert.areEqual(
            expectedDecember,
            actualDecember,
            'Expect December to be converted to ' + expectedDecember
        );
    }
}
