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
/******************************** Education *******************************************/
    /* Ongoing education on main page */
    @AuraEnabled(cacheable = true)
    public static List<ips_Education__c> getUserEducations(String workTrailId){
        try {
            List<ips_Education__c> myEducation = new List<ips_Education__c>();
            myEducation =[
                SELECT 
                id,
                Name,
                ips_Work_Trail__c,
                ips_Name_of_the_Education_Institution__c,
                toLabel(ips_Form_of_Education__c),
                toLabel(ips_Status__c)
                FROM ips_Education__c
                WHERE ips_Work_Trail__c =:workTrailId AND ips_Status__c = 'Ongoing'
                ];

                return myEducation;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*All completed educations */
    @AuraEnabled(cacheable = true)
    public static List<ips_Education__c> getallEducations(String workTrailId){
        try {
            List<ips_Education__c> myEducation = new List<ips_Education__c>();
            myEducation =[
                SELECT 
                id,
                Name,
                ips_Work_Trail__c,
                ips_Name_of_the_Education_Institution__c,
                toLabel(ips_Form_of_Education__c),
                toLabel(ips_Status__c)
                FROM ips_Education__c
                WHERE ips_Work_Trail__c =:workTrailId
                AND ips_Status__c ='Completed'
                ];

                return myEducation;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Education details */
    @AuraEnabled(cacheable = true)
    public static List<ips_Education__c> getUserEducation(String recId){
        try {
            List<ips_Education__c> myEducation = new List<ips_Education__c>();
            myEducation =[
                SELECT 
                id,
                Name,
                ips_Work_Trail__c,
                ips_Name_of_the_Education_Institution__c,
                toLabel(ips_Form_of_Education__c),
                ips_Start_Date__c, 
                ips_End_Date__c,
                toLabel(ips_Status__c), 
                ips_Education_Support_Plan__c, 
                ips_What_did_work_with_this_education__c, 
                ips_What_did_not_work_with_thiseducation__c 
                FROM ips_Education__c
                WHERE Id =:recId
                ];

                return myEducation;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



}