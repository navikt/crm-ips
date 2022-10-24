public with sharing class IPS_myActivityController {

    @AuraEnabled(cacheable = true)
    public static List<Event> getUserActivity(String userId, String typeOfMeeting){
        List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<event>();
                }
        String participantId = userList[0]?.AccountId;
        String workTrailId =[SELECT id FROM work_trail__c WHERE ips_Participant__c= :participantId]?.id;

        System.debug('trailid: '+workTrailId);
        if(workTrailId !=null && typeOfMeeting=='Weekly'){
            return getWeeklyActivity(workTrailId);
        }else if(workTrailId !=null && typeOfMeeting =='Employer'){
            return getEmployerActivity(workTrailId);
        }else if(workTrailId !=null && typeOfMeeting =='Participant'){
            return getParticipantActivity(workTrailId);
        }else{
            return new List<Event>();
        }
    }
    
    public static List<Event> getWeeklyActivity(String workTrailId){
        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService__c =true AND IPS_Status__c ='Åpen'
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }
    
    public static List<Event> getEmployerActivity(String workTrailId){

        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description,IPS_Type__c,IPS_Status__c 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService__c =true AND IPS_Type__c ='Meeting with Employer'
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }

    public static List<Event> getParticipantActivity(String workTrailId){

        List<Event> userActivity = new List<Event>();
        userActivity =[
            SELECT id,Subject, ActivityDate, EndDateTime, StartDateTime, Description,IPS_Type__c,IPS_Status__c 
            FROM event 
            WHERE WhatId = :workTrailId AND IsVisibleInSelfService__c =true AND IPS_Type__c ='Meeting with Participant'
            ORDER BY ActivityDate DESC
        ];
        return userActivity;
    }

}