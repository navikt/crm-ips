@isTest
private class IPS_SMSTest {
    @isTest
    static void createSMSRecordTest() {
        IPS_SMSService.createSMSRecord('IPS', 'Meeting Created', null, null, 'recipient', 'message');
    }
}
