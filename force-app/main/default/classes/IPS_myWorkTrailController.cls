public with sharing class IPS_myWorkTrailController {

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkTrailId(String userId) {

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<work_trail__c>();
                }
            String accountId = userList[0]?.AccountId;
            List<Work_Trail__c> mytrail = new List<Work_Trail__c>();
            mytrail = [
                SELECT id,ips_Participant__r.PersonContactId
                FROM Work_Trail__c 
                WHERE ips_Participant__c = :accountId AND ips_Status__c !='Ended'
                LIMIT 1];
            
            return mytrail;
    }

}