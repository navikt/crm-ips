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
                ];

                return myEducation;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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

    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getUserWorks(String workTrailId){
        try {
            List<ips_Job__c> myJobs = new List<ips_Job__c>();
            myJobs =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                ips_Employer__c, 
                ips_Employer_contact__c, 
                ips_End_Date__c, 
                toLabel(ips_Form_of_Employment__c), 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Paid_work__c, 
                ips_Participant__c, 
                ips_Start_Date__c, 
                toLabel(ips_Status__c), 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c, 
                IPS_Participants__c 
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:workTrailId
                AND ips_Form_of_Employment__c !='work training'
                AND ips_Status__c ='Ongoing'
                ];

                return myJobs;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getUserWork(String recId){
        try {
            List<ips_Job__c> myJobs = new List<ips_Job__c>();
            myJobs =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                ips_Employer__c, 
                ips_Employer_contact__c, 
                ips_End_Date__c, 
                toLabel(ips_Form_of_Employment__c), 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Paid_work__c, 
                ips_Participant__c, 
                ips_Start_Date__c, 
                toLabel(ips_Status__c), 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c, 
                IPS_Participants__c 
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:recId
                AND ips_Form_of_Employment__c !='work training'
                ];
                return myJobs;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getUserWorkTrainings(String workTrailId){
        try {
            List<ips_Job__c> mytraining = new List<ips_Job__c>();
            mytraining =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                ips_Employer__c, 
                ips_Employer_contact__c, 
                ips_End_Date__c, 
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Paid_work__c, 
                ips_Participant__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c, 
                IPS_Participants__c 
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:workTrailId
                AND ips_Form_of_Employment__c ='work training'
                AND ips_Status__c ='Ongoing'
                ];

                return mytraining;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getUserWorkTraining(String recId){
        try {
            List<ips_Job__c> mytraining = new List<ips_Job__c>();
            mytraining =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                ips_Employer__c, 
                ips_Employer_contact__c, 
                ips_End_Date__c, 
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Paid_work__c, 
                ips_Participant__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c, 
                IPS_Participants__c 
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:recId
                AND ips_Form_of_Employment__c ='work training'
                ];

                return mytraining;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}