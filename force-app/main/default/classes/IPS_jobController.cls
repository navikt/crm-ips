public with sharing class IPS_jobController {

    /******************************** Work *******************************************/
    /* All completed jobs for participants */
    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getCompletedUserJobs(String workTrailId){
        try {
            List<ips_Job__c> myJobs = new List<ips_Job__c>();
            myJobs =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c,
                IPS_jobSubject__c, 
                IPS_UO_Stillingsbeskrivelse__c,
                ips_End_Date__c, 
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:workTrailId
                AND ips_Form_of_Employment__c !='work training'
                AND ips_Status__c ='Completed'
                ];

                return myJobs;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* All ongoing jobs for participants */
    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getActiveUserJobs(String workTrailId){
        try {
            List<ips_Job__c> myJobs = new List<ips_Job__c>();
            myJobs =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                IPS_jobSubject__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_End_Date__c, 
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c
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
    /* All ongoing worktrainings for participants */
    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getActiveUserWorkTrainings(String workTrailId){
        try {
            List<ips_Job__c> mytraining = new List<ips_Job__c>();
            mytraining =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c,
                IPS_jobSubject__c, 
                IPS_UO_Stillingsbeskrivelse__c,
                ips_End_Date__c, 
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c
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

    /* All completed worktrainings for participants */
    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getCompletedUserWorkTrainings(String workTrailId){
        try {
            List<ips_Job__c> mytraining = new List<ips_Job__c>();
            mytraining =[
                SELECT 
                Id, 
                Name, 
                ips_Work_Trail__c, 
                ips_End_Date__c, 
                IPS_jobSubject__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_Form_of_Employment__c, 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c
                FROM ips_Job__c 
                WHERE ips_Work_Trail__c =:workTrailId
                AND ips_Form_of_Employment__c ='work training'
                AND ips_Status__c ='Completed'
                ];

                return mytraining;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ips_Job__c> getUserWorkDetail(String recId){
        try {

            List<ips_Job__c> mytraining = new List<ips_Job__c>();
            mytraining =[
                SELECT 
                Id, 
                Name,
                IPS_jobSubject__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_Work_Trail__c, 
                ips_End_Date__c, 
                toLabel(ips_Form_of_Employment__c), 
                ips_Job_Support__c, 
                ips_Number_of_hours__c, 
                ips_Start_Date__c, 
                ips_Status__c, 
                ips_What_did_not_work_at_the_workplace__c, 
                ips_What_did_work_at_the_workplace__c 
                FROM ips_Job__c 
                WHERE Id =:recId
                ];

                return mytraining;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}