public without sharing class IPS_ManagerEventController {

    @AuraEnabled(cacheable=true)
    /* Henter alle jobbspesialister tilhørende leder*/
    public static List<IPS_ManagerUsers> getManagerUsers(){
        List<IPS_ManagerUsers> usersList = new List<IPS_ManagerUsers>();
        for(User u:[SELECT Id,Name FROM User WHERE isActive = true AND id in:IPS_Utility.getMyEmployeesUserId()]){
            IPS_ManagerUsers userList = new IPS_ManagerUsers();
            userList.employeeId = u.Id;
            userList.employeeName = u.Name;
            usersList.add(userList);
        }
        return usersList;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerEvent> getEventsForCurrentWeek(){
        List<IPS_ManagerEvent> managerEvents=new List<IPS_ManagerEvent>();
        Set<Id> workTrailIds=new Set<Id>();
        DateTime startTime=date.today();
        DateTime endTime=date.today().addDays(7);
        for(Event employeeEvent:[SELECT 
                                    Id, 
                                    WhatId, 
                                    Subject, 
                                    Owner.Name, 
                                    Location, 
                                    StartDateTime, 
                                    toLabel(IPS_Type__c),
                                    IPS_employerName__c,
                                    Konto_kontakt__r.name,
                                    IPS_participant_related_to_meeting__c   
                                FROM Event 
                                WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() 
                                AND StartDateTime>:startTime 
                                AND StartDateTime<:endTime 
                                AND WhatID!=null 
                                ORDER BY StartDateTime, OwnerId ]){

            if(employeeEvent.WhatID.getSObjectType().getDescribe().getName()=='Work_Trail__c'){
                IPS_ManagerEvent managerEvent=new IPS_ManagerEvent();
                managerEvent.eventId=employeeEvent.Id;
                managerEvent.employeeName=employeeEvent.Owner.Name;
                managerEvent.subject=employeeEvent.Subject;
                managerEvent.location=employeeEvent.Location;
                managerEvent.meetingCategory = employeeEvent.IPS_Type__c;
                managerEvent.accountName = employeeEvent.IPS_employerName__c;
                managerEvent.accountContactName = employeeEvent.Konto_kontakt__r.name;
                managerEvent.isParticipantAttending = employeeEvent.IPS_participant_related_to_meeting__c;
                managerEvent.workTrailId=employeeEvent.WhatId;
                Datetime eventTime=employeeEvent.StartDateTime;
                managerEvent.startTime=eventTime.format('dd') + '.' + eventTime.format('MM') + '.' + eventTime.format('yyyy')  + ' ' + eventTime.format('HH') + ':' + eventTime.format('mm');
                managerEvents.add(managerEvent);

                workTrailIds.add(employeeEvent.WhatId);
            }
        }

        Map<Id,Work_Trail__c> workTrailIdByWorkTrail=new Map<Id,Work_Trail__c>();
        for(Work_Trail__c workTrail:[SELECT id, IPS_Participants_home_address__c, ips_Participant__r.INT_PersonIdent__c, ips_Participant__r.Name  FROM Work_Trail__c WHERE Id in:workTrailIds]){
            workTrailIdByWorkTrail.put(workTrail.Id,workTrail);
        }

        //loop trough all events and add informaration obut participants
        for(IPS_ManagerEvent me:managerEvents){
            Work_Trail__C realtedWorkTrail=workTrailIdByWorkTrail.get(me.workTrailId);
            me.participantIdent=realtedWorkTrail.ips_Participant__r.INT_PersonIdent__c;
            me.participantName=realtedWorkTrail.ips_Participant__r.Name;
            me.participantAddress=realtedWorkTrail.IPS_Participants_home_address__c;
        }
        return managerEvents;
        
    }

/*
    private static DateTime getWeekStart(Date weekDate){
        Date weekStart = weekDate.toStartofWeek();
        return DateTime.newInstance(weekStart.year(),weekStart.month(), weekStart.day());
    }
*/
}