public with sharing class IPS_myWorkTrailController {

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkTrail(String userId) {
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<Work_Trail__c>();
                }
            String accountId = userList[0]?.AccountId;
            mytrail =[
                    SELECT 
                    id,
                    ips_Priority_career_wishes__c, 
                    ips_Framework_for_job_development_search__c,
                    ips_Preferred_working_hours__c, 
                    ips_Network__c, 
                    ips_Geography__c,
                    RecordTypeId,
                    RecordType.DeveloperName
                    FROM Work_Trail__c
                    WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
                    ];
            return myTrail;
    } 
}
