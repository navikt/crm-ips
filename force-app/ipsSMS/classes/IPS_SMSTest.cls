@isTest
private class IPS_SMSTest {
    @isTest
    static void createSMSRecordTest() {
        IPS_SMS.createSMSRecord('IPS', 'Meeting Created', null, null, 'recipient', 'message', null);
    }
}
