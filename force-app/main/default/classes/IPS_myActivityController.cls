public without sharing class IPS_myActivityController {
    
    @AuraEnabled(cacheable = true)    
    public static List<Task> getParticipantsGoal(String workTrailId){

        List<Task> userGoal = new List<Task>();
        userGoal =[
            SELECT id,ActivityDate, Subject,Type_of_Task_IPSUO__c,Description,toLabel(IPS_Status1__c )
            FROM Task 
            WHERE WhatId = :workTrailId AND IPS_Status1__c ='Open' AND Type_of_Task_IPSUO__c ='Delmål (av hovedmål)'
        ];
        return userGoal;
    }

    @AuraEnabled(cacheable = true)    
    public static List<Event> getEmployerActivity(String workTrailId,String contactId){
        Date todaysDate = System.today();
        List<Event> emplActivity = new List<Event>();
        emplActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description,IPS_Type__c,toLabel(IPS_Status1__c) 
            FROM event 
            WHERE ActivityDate >=: todaysDate  AND WhatId = :workTrailId AND WhoId= :contactId AND IsVisibleInSelfService__c =true AND IPS_Type__c ='Meeting with Employer'
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
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description,IPS_Type__c,toLabel(IPS_Status1__c) 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService__c =true AND (IPS_Type__c ='Meeting with Participant' OR IPS_Type__c='Meeting with Employer')
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }
}