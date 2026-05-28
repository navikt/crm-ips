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
        Work_Trail__c t = [SELECT Id, ips_Status__c, End_Cause__c, ips_Other_end_cases__c FROM Work_Trail__c LIMIT 1];
        t.ips_Status__c = 'Ended';
        t.End_Cause__c = 'Other end causes';
        t.ips_Other_end_cases__c = 'Illness';
        update t;

        List<IPS_ManagerTrail> allTrails = IPS_ManagerTrailController.getAggregatedEndedTrail();
        System.Assert.areEqual(
            1,
            allTrails[0].numberOfTrail,
            'Expected one trail assigned to managers employee to be returned'
        );
        System.Assert.areEqual(
            IPS_ManagerTrailController.mainEndCauseMap.get('Other end causes'),
            allTrails[0].cause,
            'Expected cause to be Other end causes'
        );
        System.Assert.areEqual(
            IPS_ManagerTrailController.subEndCauseMap.get('Illness'),
            allTrails[0].subCause,
            'Expected sub cause to be Illness'
        );
    }

    @isTest
    private static void testMainEndCauseMap() {
        // Given
        String expectedWork = 'Arbeid';
        String expectedOther = 'Andre sluttårsaker';
        String expectedEducation = 'Utdanning';

        // When
        Test.startTest();
        String actualWork = IPS_ManagerTrailController.mainEndCauseMap.get('Work');
        String actualOther = IPS_ManagerTrailController.mainEndCauseMap.get('Other end causes');
        String actualEducation = IPS_ManagerTrailController.mainEndCauseMap.get('Education');
        Test.stopTest();

        // Then
        System.Assert.areEqual(expectedWork, actualWork, 'Expect Work to be converted to ' + expectedWork);
        System.Assert.areEqual(
            expectedOther,
            actualOther,
            'Expect Other end causes to be converted to ' + expectedOther
        );
        System.Assert.areEqual(
            expectedEducation,
            actualEducation,
            'Expect Education to be converted to ' + expectedEducation
        );
    }

    @isTest
    private static void testOtherEndCauseMap() {
        // Given
        String expected_AppliedGrantedDisabilityBenefits = 'Søkt/innvilget uføretrygd';
        String expected_AppliedForGrantedOldAgePensionAFP = 'Søkt/innvilget alderspensjon/AFP';
        String expected_ChainingForOtherWorkOrientedMeasuresUnderTheAuspicesOfNAV = 'Kjeding til andre arbeidsrettede tiltak i regi av NAV';
        String expected_EducationCoveredByNAV = 'Utdanning - dekket av NAV';
        String expected_Illness = 'Sykdom';
        String expected_NotApplicable = 'Ikke aktuell';
        String expected_OtherMilitaryPregnancyRelocationEtc = 'Annet (militær, svangerskap, flytting mm)';
        String expected_OtherActiveMeasuresInConsultationWithNAV = 'Andre aktive tiltak i samråd med NAV (eks medisinsk behandling eller kommunale tiltak)';
        String expected_WorkInCombinationWithAGraduatedDisabilityPension = 'Arbeid i kombinasjon med gradert uførepensjon';
        String expected_WorkInCombinationWithOtherBenefitsFromNAV = 'Arbeid i kombinasjon med andre ytelser fra NAV';
        String expected_WorkWithWageSubsidiesFromNAV = 'Arbeid med lønnstilskudd fra NAV';
        String expected_WorkWithoutWageSubsidy = 'Arbeid uten lønnstilskudd';
        String expected_UnknownSubcategory = 'Ukjent underkategori';

        // When
        Test.startTest();
        String actual_AppliedGrantedDisabilityBenefits = IPS_ManagerTrailController.subEndCauseMap.get(
            'Applied / granted disability benefits'
        );
        String actual_AppliedForGrantedOldAgePensionAFP = IPS_ManagerTrailController.subEndCauseMap.get(
            'Applied for / granted old age pension / AFP'
        );
        String actual_ChainingForOtherWorkOrientedMeasuresUnderTheAuspicesOfNAV = IPS_ManagerTrailController.subEndCauseMap.get(
            'Chaining for other work-oriented measures under the auspices of NAV'
        );
        String actual_EducationCoveredByNAV = IPS_ManagerTrailController.subEndCauseMap.get(
            'Education - covered by NAV'
        );
        String actual_Illness = IPS_ManagerTrailController.subEndCauseMap.get('Illness');
        String actual_NotApplicable = IPS_ManagerTrailController.subEndCauseMap.get('Not applicable');
        String actual_OtherMilitaryPregnancyRelocationEtc = IPS_ManagerTrailController.subEndCauseMap.get(
            'Other (military, pregnancy, relocation, etc.)'
        );
        String actual_OtherActiveMeasuresInConsultationWithNAV = IPS_ManagerTrailController.subEndCauseMap.get(
            'Other active measures in consultation with NAV (eg medical treatment, or municipal measures)'
        );
        String actual_WorkInCombinationWithAGraduatedDisabilityPension = IPS_ManagerTrailController.subEndCauseMap.get(
            'Work in combination with a graduated disability pension'
        );
        String actual_WorkInCombinationWithOtherBenefitsFromNAV = IPS_ManagerTrailController.subEndCauseMap.get(
            'Work in combination with other benefits from NAV'
        );
        String actual_WorkWithWageSubsidiesFromNAV = IPS_ManagerTrailController.subEndCauseMap.get(
            'Work with wage subsidies from NAV'
        );
        String actual_WorkWithoutWageSubsidy = IPS_ManagerTrailController.subEndCauseMap.get(
            'Work without wage subsidy'
        );
        String actual_UnknownSubcategory = IPS_ManagerTrailController.subEndCauseMap.get('');

        Test.stopTest();

        // Then
        System.Assert.areEqual(
            expected_AppliedGrantedDisabilityBenefits,
            actual_AppliedGrantedDisabilityBenefits,
            'Expect Applied / granted disability benefits to be converted to ' +
            expected_AppliedGrantedDisabilityBenefits
        );
        System.Assert.areEqual(
            expected_AppliedForGrantedOldAgePensionAFP,
            actual_AppliedForGrantedOldAgePensionAFP,
            'Expect Applied for / granted old age pension / AFP to be converted to ' +
            expected_AppliedForGrantedOldAgePensionAFP
        );
        System.Assert.areEqual(
            expected_ChainingForOtherWorkOrientedMeasuresUnderTheAuspicesOfNAV,
            actual_ChainingForOtherWorkOrientedMeasuresUnderTheAuspicesOfNAV,
            'Expect Chaining for other work-oriented measures under the auspices of NAV to be converted to ' +
            expected_ChainingForOtherWorkOrientedMeasuresUnderTheAuspicesOfNAV
        );
        System.Assert.areEqual(
            expected_EducationCoveredByNAV,
            actual_EducationCoveredByNAV,
            'Expect Education - covered by NAV to be converted to ' + expected_EducationCoveredByNAV
        );
        System.Assert.areEqual(
            expected_Illness,
            actual_Illness,
            'Expect Illness to be converted to ' + expected_Illness
        );
        System.Assert.areEqual(
            expected_NotApplicable,
            actual_NotApplicable,
            'Expect Not applicable to be converted to ' + expected_NotApplicable
        );
        System.Assert.areEqual(
            expected_OtherMilitaryPregnancyRelocationEtc,
            actual_OtherMilitaryPregnancyRelocationEtc,
            'Expect Other (military, pregnancy, relocation, etc.) to be converted to ' +
            expected_OtherMilitaryPregnancyRelocationEtc
        );
        System.Assert.areEqual(
            expected_OtherActiveMeasuresInConsultationWithNAV,
            actual_OtherActiveMeasuresInConsultationWithNAV,
            'Expect Other active measures in consultation with NAV (eg medical treatment, or municipal measures) to be converted to ' +
            expected_OtherActiveMeasuresInConsultationWithNAV
        );
        System.Assert.areEqual(
            expected_WorkInCombinationWithAGraduatedDisabilityPension,
            actual_WorkInCombinationWithAGraduatedDisabilityPension,
            'Expect Work in combination with a graduated disability pension to be converted to ' +
            expected_WorkInCombinationWithAGraduatedDisabilityPension
        );
        System.Assert.areEqual(
            expected_WorkInCombinationWithOtherBenefitsFromNAV,
            actual_WorkInCombinationWithOtherBenefitsFromNAV,
            'Expect Work in combination with other benefits from NAV to be converted to ' +
            expected_WorkInCombinationWithOtherBenefitsFromNAV
        );
        System.Assert.areEqual(
            expected_WorkWithWageSubsidiesFromNAV,
            actual_WorkWithWageSubsidiesFromNAV,
            'Expect Work with wage subsidies from NAV to be converted to ' + expected_WorkWithWageSubsidiesFromNAV
        );
        System.Assert.areEqual(
            expected_WorkWithoutWageSubsidy,
            actual_WorkWithoutWageSubsidy,
            'Expect Work without wage subsidy to be converted to ' + expected_WorkWithoutWageSubsidy
        );
        System.Assert.areEqual(
            expected_UnknownSubcategory,
            actual_UnknownSubcategory,
            'Expect empty string to be converted to ' + expected_UnknownSubcategory
        );
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
        System.Assert.areEqual(
            expectedReferred,
            actualReferred,
            'Expect referred to be converted to ' + expectedReferred
        );
        System.Assert.areEqual(
            expectedCareerMapping,
            actualCareerMapping,
            'Expect career mapping to be converted to ' + expectedCareerMapping
        );
        System.Assert.areEqual(
            expectedEducation,
            actualEducation,
            'Expect education to be converted to ' + expectedEducation
        );
        System.Assert.areEqual(expectedEnded, actualEnded, 'Expect ended to be converted to ' + expectedEnded);
        System.Assert.areEqual(expectedFindJob, actualFindJob, 'Expect find job to be converted to ' + expectedFindJob);
        System.Assert.areEqual(
            expectedInEducation,
            actualInEducation,
            'Expect in education to be converted to ' + expectedInEducation
        );
        System.Assert.areEqual(
            expectedInitialContact,
            actualInitialContact,
            'Expect initial contact to be converted to ' + expectedInitialContact
        );
        System.Assert.areEqual(expectedMapping, actualMapping, 'Expect mapping to be converted to ' + expectedMapping);
        System.Assert.areEqual(expectedPassive, actualPassive, 'Expect passive to be converted to ' + expectedPassive);
        System.Assert.areEqual(expectedWorking, actualWorking, 'Expect working to be converted to ' + expectedWorking);
        System.Assert.areEqual(
            expectedJobDevelopment,
            actualJobDevelopment,
            'Expect job development to be converted to ' + expectedJobDevelopment
        );
        System.Assert.areEqual(
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
