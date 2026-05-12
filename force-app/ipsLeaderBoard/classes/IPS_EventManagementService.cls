/**
 * @description  : Service class for handling Event management in IPS, including fetching events for the current week and related participant information.
 * @author       : Balendra Sounthararajan
 * @since        : 0.522.0
 * @author       : Håkon Kavli
 **/
public without sharing class IPS_EventManagementService {
    public static final List<String> IPS_WHATID_RECORD_TYPES = new List<String>{ 'IPS', 'ips_Supported_Employment' };
    public static final List<String> IPS_EVENT_RECORD_TYPES = new List<String>{
        'IPS_Event',
        'IPS_UO_Arbeidsgiver',
        'ips_UO_m_ter'
    };

    /**
     * Fetches a list of custom events happening within the next 7 days, starting from today.
     * @return  list of custom events.
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerEvent> getEventsForCurrentWeek() {
        List<Event> employeeEvents = getEventsForEmployeesCurrentWeek();
        return createManagerEventsDTO(employeeEvents);
    }

    @TestVisible
    private static List<IPS_ManagerEvent> createManagerEventsDTO(List<Event> employeeEvents) {
        List<IPS_ManagerEvent> managerEvents = new List<IPS_ManagerEvent>();
        Set<Id> workTrailIds = extractWorkTrailIds(employeeEvents);
        Map<Id, Work_Trail__c> workTrailMap = getRelatedWorkTrailMap(workTrailIds);

        for (Event employeeEvent : employeeEvents) {
            IPS_ManagerEvent managerEvent = new IPS_ManagerEvent();
            managerEvent.eventId = employeeEvent.Id;
            managerEvent.employeeName = employeeEvent.Owner.Name;
            managerEvent.profileName = employeeEvent.Owner.Profile.Name;
            managerEvent.subject = employeeEvent.Subject;
            managerEvent.location = employeeEvent.Location;
            managerEvent.meetingCategory = employeeEvent.IPS_Type__c;
            managerEvent.accountName = employeeEvent.IPS_employerName__c;
            managerEvent.accountContactName = employeeEvent.Konto_kontakt__r.Name;
            managerEvent.isParticipantAttending = employeeEvent.IPS_participant_related_to_meeting__c;
            managerEvent.workTrailId = employeeEvent.WhatId;
            managerEvent.startTime = formatTime(employeeEvent.StartDateTime);
            if (workTrailMap.get(employeeEvent.WhatId) != null) {
                managerEvent.participantIdent = workTrailMap.get(employeeEvent.WhatId)
                    .ips_Participant__r.INT_PersonIdent__c;
                managerEvent.participantName = workTrailMap.get(employeeEvent.WhatId).ips_Participant__r.Name;
                managerEvent.participantAddress = workTrailMap.get(employeeEvent.WhatId)
                    .IPS_Participants_home_address__c;
            }

            managerEvents.add(managerEvent);
        }
        return managerEvents;
    }

    @TestVisible
    private static List<Event> getEventsForEmployeesCurrentWeek() {
        return [
            SELECT
                Id,
                WhatId,
                Subject,
                Owner.Name,
                Owner.Profile.Name,
                Location,
                StartDateTime,
                IPS_Type__c,
                IPS_employerName__c,
                Konto_kontakt__r.name,
                IPS_participant_related_to_meeting__c,
                RecordType.DeveloperName
            FROM Event
            WHERE
                OwnerId IN :IPS_Utility.getMyEmployeesUserId()
                AND StartDateTime >= :date.today()
                AND StartDateTime <= :date.today().addDays(7)
                AND WhatId != NULL
                AND RecordType.DeveloperName IN :IPS_EVENT_RECORD_TYPES
            ORDER BY StartDateTime, OwnerId
        ];
    }

    @TestVisible
    private static Set<Id> extractWorkTrailIds(List<Event> events) {
        Set<Id> workTrailIds = new Set<Id>();
        for (Event event : events) {
            if (event.WhatId != null && IPS_EVENT_RECORD_TYPES.contains(event.RecordType.DeveloperName)) {
                workTrailIds.add(event.WhatId);
            }
        }
        return workTrailIds;
    }

    @TestVisible
    private static Map<Id, Work_Trail__c> getRelatedWorkTrailMap(Set<Id> workTrailIds) {
        return new Map<Id, Work_Trail__c>(
            [
                SELECT
                    Id,
                    IPS_Participants_home_address__c,
                    ips_Participant__r.INT_PersonIdent__c,
                    ips_Participant__r.Name
                FROM Work_Trail__c
                WHERE Id IN :workTrailIds
            ]
        );
    }

    /**
     * @description Simple utility method to format Datetime into a readable string format for display purposes.
     * @author Håkon Kavli | 05-12-2026
     * @param dt The Datetime value to be formatted.
     * @return String The formatted Datetime string.
     **/
    private static String formatTime(Datetime dt) {
        return dt.format('dd') +
            '.' +
            dt.format('MM') +
            '.' +
            dt.format('yyyy') +
            ' ' +
            dt.format('HH') +
            ':' +
            dt.format('mm');
    }
}
