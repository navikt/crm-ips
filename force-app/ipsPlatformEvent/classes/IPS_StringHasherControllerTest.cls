@isTest
public with sharing class IPS_StringHasherControllerTest {
    @isTest
    static void hashString(){
        String testString = 'Test String for Hashing';
        List<IPS_StringHasherController.eventRequest> request = new List<IPS_StringHasherController.eventRequest>();
        IPS_StringHasherController.eventRequest req = new IPS_StringHasherController.eventRequest();
        req.inputString = testString;
        request.add(req);
        Test.startTest();
        List<IPS_StringHasherController.FlowOutput> output = IPS_StringHasherController.hashString(request);
        Test.stopTest();
        System.assertEquals(1, output.size(), 'Confirm that there is 1 output');
        System.assertNotEquals(null, output[0].hashString, 'Confirm that the hash string is not null');
    }
}