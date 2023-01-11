public without sharing class IPS_myActivityController {
    
    /* All open goals that is connected with worktrail */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsGoals(String workTrailId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT 
                id,
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
                ips_Due_Date_Time__c,
                Subject,
                Type_of_Task_IPSUO__c,
                Description,
                Status
            FROM Task 
            WHERE WhatId = :workTrailId 
            AND Type_of_Task_IPSUO__c ='Delmål (av hovedmål)'
            AND Status = 'Completed'
            ORDER BY ActivityDate ASC
        ];
        return userGoal;
    }

    /* Detail on task row */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getTaskDetail(String recId){

        List<Task> taskDetail = new List<Task>();
        taskDetail =[
            SELECT 
                id,
                ActivityDate,
                ips_Due_Date_Time__c,
                Subject,
                Type_of_Task_IPSUO__c,
                Description,
                Samtalereferat__c,
                Status
            FROM Task 
            WHERE Id =:recId
        ];
        return taskDetail;
    }

    /* All Completed Logs that is connected with worktrail */
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsLogs(String workTrailId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT 
                id,
                ActivityDate,
                ips_Due_Date_Time__c,
                Subject,
                Type_of_Task_IPSUO__c,
                Description,
                Samtalereferat__c,
                Status
            FROM Task 
            WHERE WhatId = :workTrailId 
            AND Type_of_Task_IPSUO__c ='Logg kontakt'  
            AND Samtalereferat__c = true
            AND Status ='Completed'
            ORDER BY ActivityDate ASC
        ];
        return userGoal;
    }


//DELETE
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsGoal(String recId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT 
                id,
                ActivityDate,
                ips_Due_Date_Time__c,
                Subject,
                Type_of_Task_IPSUO__c,
                Description,
                Status
            FROM Task 
            WHERE Id =:recId
        ];
        return userGoal;
    }

    

    @AuraEnabled(cacheable = true)    
    public static List<Event> getEmployerActivity(String workTrailId,String contactId){
        Date todaysDate = System.today();
        List<Event> emplActivity = new List<Event>();
        emplActivity =[
            SELECT 
                id,
                Subject, 
                ActivityDate, 
                EndDateTime, 
                StartDateTime, 
                Description,
                IPS_Type__c,
                toLabel(IPS_Status1__c) 
            FROM event 
            WHERE 
                ActivityDate >=: todaysDate  
                AND WhatId = :workTrailId 
                AND WhoId= :contactId 
                AND IsVisibleInSelfService__c =true 
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
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description,IPS_Type__c,toLabel(IPS_Status1__c )
            FROM event 
            WHERE ActivityDate >=: todaysDate AND WhatId = :workTrailId AND IsVisibleInSelfService__c =true AND IPS_Type__c ='Meeting with Participant'
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Event> getAllActivity(String workTrailId){
        Date todaysDate = System.today();
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT 
                id,
                Subject, 
                ActivityDate, 
                EndDateTime, 
                StartDateTime, 
                Description,
                IPS_Type__c,
                IPS_Status1__c
            FROM event 
            WHERE 
                WhatId = :workTrailId 
                AND IsVisibleInSelfService__c =true 
                AND (IPS_Type__c ='Meeting with Participant' OR IPS_Type__c='Meeting with Employer')
        ];
        return userActivity;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Event> getMeeting(String recId){
        List<Event> userMeeting = new List<Event>();
        userMeeting =[
            SELECT id,Subject, ActivityDate,EndDate, EndDateTime, StartDateTime, Description,toLabel(IPS_Type__c),toLabel(IPS_Status1__c),RelatedToAccount__c 
            FROM event 
            WHERE Id = :recId
        ];
        return userMeeting;
    }
}