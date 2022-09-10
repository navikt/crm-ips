public with sharing class IPS_myWorkTrailController {
    private static final String IPSRECORDTYPEID = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
    private static final String UORECORDTYPEID = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('ips_Supported_Employment').getRecordTypeId();

@AuraEnabled(cacheAble = true)
public static List<Work_Trail__c> getUserGoal(){
    Id userId = UserInfo.getUserId();
    User user = IPS_Utility.getPersonAccount(userId);
    if(user.AccountId!=null){
        try{
            return[
            SELECT 
            id,
            ips_Main_goal__c,
            ips_Main_Goal_list__c,
            UO_Main_Goal_list__c
            FROM work_trail__c
            WHERE ips_Participant__c = :user.AccountId AND ips_Status__c !='Ended'
            ];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }else {
        return null;
    }
}

    @AuraEnabled
    public static List<work_trail__c> getUOUserWorkTrail() {
    Id userId = UserInfo.getUserId();
    User user = IPS_accountSelector.getPersonAccount(userId);
        return[
            SELECT 
            Id
            FROM work_trail__c
            WHERE ips_Participant__c = :user.AccountId AND ips_Status__c !='Ended'
        ];
    }
}