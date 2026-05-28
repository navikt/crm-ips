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
    private static void getUserTrails() {
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedTrailStatus();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');
    }

    @IsTest
    private static void getAggregatedTrailJobbspesialist() {
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedTrailJobbspesialist();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');
    }

    @IsTest
    private static void getUOTraining() {
        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getUOTraining();
        System.assertEquals(1, allTrails.size(), 'Expect trail in UO training');
    }

    @IsTest
    private static void getAggregatedEndedTrail() {
        Work_Trail__c t = [SELECT id FROM Work_Trail__c];
        t.ips_Status__c = 'Ended';
        t.End_Cause__c = 'Other end causes';
        t.ips_Other_end_cases__c = 'Illness';
        update t;

        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedEndedTrail();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');

        List<IPS_ManagerTrail> endedTrail = IPS_ManagerTrailController.getReferredTrails();
        System.assertEquals(1, endedTrail.size(), 'Expect only ended trail');
    }

    @isTest
    private static void testSubCategory() {
        String other;
        other = IPS_ManagerTrailController.getSubCause('other');
        System.assertEquals('other', other, 'Expect other as output');
    }

    @isTest
    private static void testStatusConversion() {
        // Given
        String expectedReferred = 'Henvist';
        String expectedCareerMapping = 'Yrkeskartlegging og karriereplanlegging';
        String expectedEducation = 'Opplæring og trening på og/eller utenom arbeidsplassen';
        String expectedEnded = 'Sluttet';
        String expectedFindJob = 'Finne en passende jobb/samarbeid med arbeidsgiver';
        String expectedInEducation = 'I utdannelse';
        String expectedInitialContact = 'Innledende kontakt';
        String expectedMapping = 'Kartlegging';
        String expectedPassive = 'Nedtrapping'; // Passive is deactivated per 28.05.2026, and is thus converted to 'Nedtrapping' to avoid confusion for end users.
        String expectedWorking = 'Jobber';
        String expectedJobDevelopment = 'Jobbutvikling';
        String expectedDownsizing = 'Nedtrapping';

        // When
        Test.startTest();
        String actualReferred = IPS_ManagerTrailController.statusMap.get('Referred');
        String actualCareerMapping = IPS_ManagerTrailController.statusMap.get('Career mapping and career planning');
        String actualEducation = IPS_ManagerTrailController.statusMap.get(
            'Education and training in and/ or outside the workplace'
        );
        String actualEnded = IPS_ManagerTrailController.statusMap.get('Ended');
        String actualFindJob = IPS_ManagerTrailController.statusMap.get('Find a suitable job/ Collaborate with AG');
        String actualInEducation = IPS_ManagerTrailController.statusMap.get('In Education');
        String actualInitialContact = IPS_ManagerTrailController.statusMap.get('Initial contact');
        String actualMapping = IPS_ManagerTrailController.statusMap.get('Mapping');
        String actualPassive = IPS_ManagerTrailController.statusMap.get('Passive');
        String actualWorking = IPS_ManagerTrailController.statusMap.get('Working');
        String actualJobDevelopment = IPS_ManagerTrailController.statusMap.get('Job development');
        String actualDownsizing = IPS_ManagerTrailController.statusMap.get('Downsizing');
        Test.stopTest();

        //Then
        System.assertEquals(expectedReferred, actualReferred, 'Expect referred to be converted to ' + expectedReferred);
        System.assertEquals(
            expectedCareerMapping,
            actualCareerMapping,
            'Expect career mapping to be converted to ' + expectedCareerMapping
        );
        System.assertEquals(
            expectedEducation,
            actualEducation,
            'Expect education to be converted to ' + expectedEducation
        );
        System.assertEquals(expectedEnded, actualEnded, 'Expect ended to be converted to ' + expectedEnded);
        System.assertEquals(expectedFindJob, actualFindJob, 'Expect find job to be converted to ' + expectedFindJob);
        System.assertEquals(
            expectedInEducation,
            actualInEducation,
            'Expect in education to be converted to ' + expectedInEducation
        );
        System.assertEquals(
            expectedInitialContact,
            actualInitialContact,
            'Expect initial contact to be converted to ' + expectedInitialContact
        );
        System.assertEquals(expectedMapping, actualMapping, 'Expect mapping to be converted to ' + expectedMapping);
        System.assertEquals(expectedPassive, actualPassive, 'Expect passive to be converted to ' + expectedPassive);
        System.assertEquals(expectedWorking, actualWorking, 'Expect working to be converted to ' + expectedWorking);
        System.assertEquals(
            expectedJobDevelopment,
            actualJobDevelopment,
            'Expect job development to be converted to ' + expectedJobDevelopment
        );
        System.assertEquals(
            expectedDownsizing,
            actualDownsizing,
            'Expect downsizing to be converted to ' + expectedDownsizing
        );
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
        System.assertEquals(expectedJanuary, actualJanuary, 'Expect January to be converted to ' + expectedJanuary);
        System.assertEquals(expectedFebruary, actualFebruary, 'Expect February to be converted to ' + expectedFebruary);
        System.assertEquals(expectedMarch, actualMarch, 'Expect March to be converted to ' + expectedMarch);
        System.assertEquals(expectedApril, actualApril, 'Expect April to be converted to ' + expectedApril);
        System.assertEquals(expectedMay, actualMay, 'Expect May to be converted to ' + expectedMay);
        System.assertEquals(expectedJune, actualJune, 'Expect June to be converted to ' + expectedJune);
        System.assertEquals(expectedJuly, actualJuly, 'Expect July to be converted to ' + expectedJuly);
        System.assertEquals(expectedAugust, actualAugust, 'Expect August to be converted to ' + expectedAugust);
        System.assertEquals(
            expectedSeptember,
            actualSeptember,
            'Expect September to be converted to ' + expectedSeptember
        );
        System.assertEquals(expectedOctober, actualOctober, 'Expect October to be converted to ' + expectedOctober);
        System.assertEquals(expectedNovember, actualNovember, 'Expect November to be converted to ' + expectedNovember);
        System.assertEquals(expectedDecember, actualDecember, 'Expect December to be converted to ' + expectedDecember);
    }
}
