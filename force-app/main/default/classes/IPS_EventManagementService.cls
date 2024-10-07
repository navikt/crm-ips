public without sharing class IPS_EventManagementService {
    /**
     * Fetches a list of custom events happening within the next 7 days, starting from today.
     * @return  list of custom events.
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerEvent> getEventsForCurrentWeek() {
        List<IPS_ManagerEvent> managerEvents = new List<IPS_ManagerEvent>();
        Set<Id> workTrailIds = new Set<Id>();
        DateTime startTime = date.today();
        DateTime endTime = date.today().addDays(7);
        for (Event employeeEvent : [
            SELECT
                Id,
                WhatId,
                Subject,
                Owner.Name,
                Owner.Profile.Name,
                Location,
                StartDateTime,
                toLabel(IPS_Type__c),
                IPS_employerName__c,
                Konto_kontakt__r.name,
                IPS_participant_related_to_meeting__c
            FROM Event
            WHERE
                OwnerId IN :IPS_Utility.getMyEmployeesUserId()
                AND StartDateTime > :startTime
                AND StartDateTime < :endTime
                AND WhatID != NULL
            ORDER BY StartDateTime, OwnerId
        ]) {
            if (employeeEvent.WhatID.getSObjectType().getDescribe().getName() == 'Work_Trail__c') {
                IPS_ManagerEvent managerEvent = new IPS_ManagerEvent();
                managerEvent.eventId = employeeEvent.Id;
                managerEvent.employeeName = employeeEvent.Owner.Name;
                managerEvent.profileName = employeeEvent.Owner.Profile.Name;
                managerEvent.subject = employeeEvent.Subject;
                managerEvent.location = employeeEvent.Location;
                managerEvent.meetingCategory = employeeEvent.IPS_Type__c;
                managerEvent.accountName = employeeEvent.IPS_employerName__c;
                managerEvent.accountContactName = employeeEvent.Konto_kontakt__r.name;
                managerEvent.isParticipantAttending = employeeEvent.IPS_participant_related_to_meeting__c;
                managerEvent.workTrailId = employeeEvent.WhatId;
                Datetime eventTime = employeeEvent.StartDateTime;
                managerEvent.startTime =
                    eventTime.format('dd') +
                    '.' +
                    eventTime.format('MM') +
                    '.' +
                    eventTime.format('yyyy') +
                    ' ' +
                    eventTime.format('HH') +
                    ':' +
                    eventTime.format('mm');
                managerEvents.add(managerEvent);
                workTrailIds.add(employeeEvent.WhatId);
            }
        }

        Map<Id, Work_Trail__c> workTrailIdByWorkTrail = new Map<Id, Work_Trail__c>();
        for (Work_Trail__c workTrail : [
            SELECT id, IPS_Participants_home_address__c, ips_Participant__r.INT_PersonIdent__c, ips_Participant__r.Name
            FROM Work_Trail__c
            WHERE Id IN :workTrailIds
        ]) {
            workTrailIdByWorkTrail.put(workTrail.Id, workTrail);
        }

        //loop trough all events and add informaration obut participants
        for (IPS_ManagerEvent me : managerEvents) {
            Work_Trail__C realtedWorkTrail = workTrailIdByWorkTrail.get(me.workTrailId);
            me.participantIdent = realtedWorkTrail.ips_Participant__r.INT_PersonIdent__c;
            me.participantName = realtedWorkTrail.ips_Participant__r.Name;
            me.participantAddress = realtedWorkTrail.IPS_Participants_home_address__c;
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
