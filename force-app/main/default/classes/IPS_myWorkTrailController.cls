public with sharing class IPS_myWorkTrailController {
    private static final String IPSRECORDTYPEID = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
    private static final String UORECORDTYPEID = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('ips_Supported_Employment').getRecordTypeId();

    
    @AuraEnabled(cacheAble = true)
    public static List<Work_Trail__c> getUserGoal(String userId){
    List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

    try{
        List<User> userList = IPS_Utility.getPersonAccountId(userId);
            if(userList.isEmpty()){
                system.debug('No accountId found on user');
                return new List<Work_Trail__c>();
            }
        String accountId = userList[0]?.AccountId;
        mytrail =[
                SELECT 
                id,
                ips_Main_goal__c,
                ips_Main_Goal_list__c,
                UO_Main_Goal_list__c
                FROM work_trail__c
                WHERE ips_Participant__c = :accountId 
                AND ips_Status__c !='Ended'
                LIMIT 1
                ];
        }catch(Exception e){
            LoggerUtility logger = new LoggerUtility();
            logger.error(e.getMessage(), null);
            logger.publish();
            throw new AuraHandledException(e.getMessage());
            }
        if(!myTrail.isEmpty()){
            return myTrail;
        }else{
            return new List<Work_Trail__c>();
        }
        
    }

    @AuraEnabled
    public static List<work_trail__c> getUOUserWorkTrail(String userId) {
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

        try{
            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<Work_Trail__c>();
                }
            String accountId = userList[0]?.AccountId;
            mytrail =[
                    SELECT 
                    id,
                    ips_Main_goal__c,
                    ips_Main_Goal_list__c,
                    UO_Main_Goal_list__c
                    FROM work_trail__c
                    WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
                    ];
            }catch(Exception e){
                LoggerUtility logger = new LoggerUtility();
                logger.error(e.getMessage(), null);
                logger.publish();
                throw new AuraHandledException(e.getMessage());
                }
            return myTrail;
    } 
}