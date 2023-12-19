@IsTest
private with sharing class IPS_CVControllerTest {
    @IsTest
    static void getCVTestOnSuccuss() {
        ApiMock.setTestMock('GET_CV', 200, 'OK');
        CV testCV;
        Test.startTest();
        testCV = IPS_CVController.getCV('12345678910');
        Test.stopTest();

        System.assertNotEquals(null, testCV, 'Did not expect null');
        System.assertEquals(false, testCV.sistEndretAvNav, 'Excpected result was false');
    }

    @isTest
    static void getCVTestOnBlankPersonIdent() {
        Boolean hasCVException = false;

        Test.startTest();
        try {
            IPS_CVController.getCV('');
        } catch (IPS_CVController.CVException ex) {
            hasCVException = true;
        } catch (Exception e) {
            System.assert(false, 'Did not throw correct exception');
        }
        Test.stopTest();

        System.assert(hasCVException, 'Did not catch correct exception');
        System.assertEquals(1, [SELECT Id FROM Application_Log__c].size(), 'Excpected error to be recorded');
    }

    @isTest
    static void getCVTestOnUnauthorizedError() {
        Boolean hasCVException = false;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(401, 'Unauthorized', '', null));

        Test.startTest();
        try {
            IPS_CVController.getCV('12345678910');
        } catch (IPS_CVController.CVException ex) {
            hasCVException = true;
        } catch (Exception e) {
            System.assert(false, 'Did not throw correct exception');
        }
        Test.stopTest();

        System.assert(hasCVException, 'Did not catch correct exception');
        System.assertEquals(1, [SELECT Id FROM Application_Log__c].size(), 'Excpected error to be recorded');
    }

    @isTest
    static void getCVTestOnNotFoundError() {
        Boolean hasCVException = false;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(404, 'Not Found', '', null));

        Test.startTest();
        try {
            IPS_CVController.getCV('12345678910');
        } catch (IPS_CVController.CVException ex) {
            hasCVException = true;
        } catch (Exception e) {
            System.assert(false, 'Did not throw correct exception');
        }
        Test.stopTest();

        System.assert(hasCVException, 'Did not catch correct exception');
    }

    @isTest
    static void getCVTestOnInternalServerError() {
        Boolean hasCVException = false;

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Internal Server Error', '', null));

        Test.startTest();
        try {
            IPS_CVController.getCV('12345678910');
        } catch (IPS_CVController.CVException ex) {
            hasCVException = true;
        } catch (Exception e) {
            System.assert(false, 'Did not throw correct exception');
        }
        Test.stopTest();

        System.assert(hasCVException, 'Did not catch correct exception');
        System.assertEquals(1, [SELECT Id FROM Application_Log__c].size(), 'Excpected error to be recorded');
    }
}