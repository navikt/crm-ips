public with sharing class IPS_myActivityController {
    
    /* All open goals that is connected with worktrail */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsGoals(String workTrailId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT 
                id,
                CreatedDate,
                ActivityDate,
                ips_Due_Date_Time__c,
                Subject,
                Description,
                Status
            FROM Task 
            WHERE WhatId = :workTrailId 
            AND Type_of_Task_IPSUO__c ='Delmål (av hovedmål)'  
            AND Status ='Open'
            ORDER BY ActivityDate ASC
        ];
        return userGoal;
    }

    /* History of all completed goals connected with worktrail */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getAllGoals(String workTrailId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT 
                id,
                ActivityDate,
                CreatedDate,
                CompletedDateTime,
                ips_Due_Date_Time__c,
                Subject,
                Type_of_Task_IPSUO__c,
                Description,
                Status
            FROM Task 
            WHERE WhatId = :workTrailId 
            AND Type_of_Task_IPSUO__c ='Delmål (av hovedmål)'
            AND Status = 'Completed'
            ORDER BY CompletedDateTime DESC
        ];
        return userGoal;
    }

    /* All Completed Logs that is connected with worktrail */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsLogs(String workTrailId){

        List<Task> userLogs = new List<Task>();
        userLogs =[
            SELECT 
                id,
                ActivityDate,
                CreatedDate,
                Subject,
                IPS_subjectAndDate__c,
                Type_of_Task_IPSUO__c,
                Description,
                Samtalereferat__c,
                WhatId,
                Status
            FROM Task 
            WHERE WhatId = :workTrailId 
            AND Type_of_Task_IPSUO__c ='Logg kontakt'  
            AND Samtalereferat__c = true
            AND Status ='Completed'
            ORDER BY ActivityDate DESC
        ];
        return userLogs;
    }

    @AuraEnabled(cacheable = true)    
    public static List<Event> getEmployerActivity(String workTrailId,String contactId){
        Date todaysDate = System.today();
        List<Event> emplActivity = new List<Event>();
        emplActivity =[
            SELECT 
                id,
                Subject,
                CreatedDate,
                Location,
                IPS_subjectAndDate__c, 
                ActivityDate,
                ActivityDateTime,
                IPS_timeFrom__c,
                IPS_timeTo__c,
                Description,
                IPS_employerName__c,
                IPS_Type__c,
                toLabel(IPS_Status1__c) 
            FROM event 
            WHERE 
                ActivityDate >=: todaysDate  
                AND WhatId = :workTrailId 
                AND WhoId= :contactId 
                AND IPS_Type__c ='Meeting with Employer'
            ORDER BY ActivityDate DESC
        ];
        return emplActivity;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Event> getParticipantActivity(String workTrailId){
        Date todaysDate = System.today();
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT 
                id,
                Subject,
                CreatedDate,
                Location, 
                IPS_subjectAndDate__c,
                ActivityDate,
                ActivityDateTime,
                IPS_timeFrom__c,
                IPS_timeTo__c,
                Description,
                IPS_Type__c,
                toLabel(IPS_Status1__c )
            FROM event 
            WHERE 
                ActivityDate >=: todaysDate 
                AND WhatId = :workTrailId 
                AND IPS_Type__c ='Meeting with Participant'
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Event> getAllActivity(String workTrailId,String contactId){
        Date todaysDate = System.today();
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT 
                id,
                IPS_subjectAndDate__c,
                Location,
                IPS_timeFrom__c,
                IPS_timeTo__c, 
                Description,
                IPS_Type__c,
                IPS_Status1__c,
                IPS_employerName__c
            FROM event 
            WHERE 
                WhatId = :workTrailId
                AND WhoId= :contactId
                AND IPS_Status1__c ='Completed'
                AND (IPS_Type__c ='Meeting with Participant' OR IPS_Type__c='Meeting with Employer')
                ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }
}