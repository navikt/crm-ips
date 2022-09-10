public without sharing class IPS_Utility { 
    
    public static User getPersonAccount(String userId) {
        User user = [
            SELECT AccountId, Account.CRM_Person__r.CRM_FullName__c, Account.CRM_Person__r.INT_KrrMobilePhone__c
            FROM User
            WHERE Id = :UserInfo.getUserId() AND Account.CRM_Person__r.INT_Confidential__C = 'UGRADERT'
        ];
        return user;
    }
}