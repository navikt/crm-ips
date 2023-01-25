public class IPS_SMS {
    public static SMS__c createSMSRecord(
        String domain,
        String type,
        Id accountId,
        Id eventId,
        String recipient,
        String message,
        Id workTrail
    ) {
        SMS__c sms = new SMS__c();
        sms.Domain__c = domain;
        sms.Type__c = type;
        sms.Account__c = accountID;
        sms.EventId__c = eventId;
        sms.Recipient__c = recipient;
        sms.Message__c = message;
        sms.IPS_WorkTrail__c = workTrail;
        return sms;
    }
}
