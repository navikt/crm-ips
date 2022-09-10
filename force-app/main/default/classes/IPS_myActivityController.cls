public with sharing class IPS_myActivityController {
    @AuraEnabled(cacheable=true)
    public static List<Event>(String userId,Boolean weekly){
        String participantId = [SELECT AccountId FROM User WHERE ID= :userId]?.AccountId;
        String workTrailId =[SELECT id FROM work_trail__c WHERE ips_Participant__c= :participantId]?.id;
        
        if(workTrailId !=null && weekly==true){
            return getWeeklyActivity(workTrailId);
        }else if(workTrailId !=null && weekly==false){
            return getAllActivity(workTrailId);
        }else{
            return new List<Event>();
        }
    }
    
    private static List<Event> getWeeklyActivity(String workTrailId){
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService =true AND IPS_Status__c ='Open'
        ];
        return userActivity;
    }
    
    private static List<Event> getAllActivity(String workTrailId){
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService =true AND IPS_Status__c ='Open'
        ];
        return userActivity;
    }

}