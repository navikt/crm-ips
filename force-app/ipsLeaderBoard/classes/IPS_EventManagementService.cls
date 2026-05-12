/**
 * @description  : Service class for handling Event management in IPS, including fetching events for the current week and related participant information.
 * @author       : Balendra Sounthararajan
 * @since        : 0.522.0
 * @author       : Håkon Kavli
 **/
public with sharing class IPS_EventManagementService {
    public static final List<String> IPS_WHATID_RECORD_TYPES = new List<String>{ 'IPS', 'ips_Supported_Employment' };
    public static final List<String> IPS_EVENT_RECORD_TYPES = new List<String>{
        'IPS_Event',
        'IPS_UO_Arbeidsgiver',
        'ips_UO_m_ter'
    };

    /**
     * @description Returns a list of IPS_ManagerEvent DTOs for the events that are scheduled for the current week and are owned by the employees reporting to the manager currently using the "Jobbsporet Lederbrett". The method retrieves the relevant Event records, transforms them into IPS_ManagerEvent DTOs, and enriches the data with related Work_Trail__c information to provide a comprehensive view of the events for display on the manager's leaderboard.
     * @author Håkon Kavli | 05-12-2026
     * @return List<IPS_ManagerEvent> The resulting list of IPS_ManagerEvent DTOs that contain enriched information for display on the manager's leaderboard for the current week's events.
     **/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerEvent> getEventsForCurrentWeek() {
        return createManagerEventsDTO(getEventsForEmployeesCurrentWeek());
    }

    /**
     * @description Transforms a list of Event records into a list of IPS_ManagerEvent DTOs, enriching the data with related Work_Trail__c information. The method first extracts unique WhatId values from the events to query related Work_Trail__c records in bulk, avoiding SOQL queries inside loops. It then iterates through the events, creating manager event DTOs only for those that are linked to the specified WhatId record types and populating the DTO fields with relevant information from both the Event and related Work_Trail__c records.
     * @author Håkon Kavli | 05-12-2026
     * @param employeeEvents The list of Event records to be transformed into IPS_ManagerEvent DTOs.
     * @return List<IPS_ManagerEvent> The resulting list of IPS_ManagerEvent DTOs that contain enriched information for display on the manager's leaderboard.
     **/
    @TestVisible
    private static List<IPS_ManagerEvent> createManagerEventsDTO(List<Event> employeeEvents) {
        // Prepare a list to hold the resulting manager event DTOs
        List<IPS_ManagerEvent> managerEvents = new List<IPS_ManagerEvent>();

        // Extract unique WhatId values from the events to query related Work_Trail__c records in bulk
        Set<Id> workTrailIds = extractWorkTrailIds(employeeEvents);

        // Fetch related Work_Trail__c records in bulk to avoid SOQL queries inside loops
        Map<Id, Work_Trail__c> workTrailMap = getRelatedWorkTrailMap(workTrailIds);

        // Iterate through the events and create manager event DTOs, linking them to the related Work_Trail__c records
        for (Event employeeEvent : employeeEvents) {
            // Skip events that are not related to the specified WhatId record types
            if (
                workTrailMap.get(employeeEvent.WhatId) == null ||
                IPS_WHATID_RECORD_TYPES.contains(workTrailMap.get(employeeEvent.WhatId).RecordType.DeveloperName) ==
                false
            ) {
                continue;
            }
            managerEvents.add(createEmployeeEvent(employeeEvent, workTrailMap.get(employeeEvent.WhatId)));
        }

        return managerEvents;
    }

    /**
     * @description Returns a list of Event records for the current week that are owned by the employees reporting to the manager thats currently using the "Jobbsporet Lederbrett". The events are filtered based on specific criteria, including the WhatId, StartDateTime, and RecordType.
     * @author Håkon Kavli | 05-12-2026
     * @return List<Event> Resulting list of Event records that match the specified criteria for the current week.
     **/
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
                AND StartDateTime < :date.today().addDays(8)
                AND WhatId != NULL
                AND RecordType.DeveloperName IN :IPS_EVENT_RECORD_TYPES
                AND IPS_Status1__c = 'Open'
            WITH USER_MODE
            ORDER BY StartDateTime, OwnerId
        ];
    }

    /**
     * @description Creates a map of Work_Trail__c records keyed by their Ids. This method retrieves the Work_Trail__c records based on the provided set of workTrailIds and organizes them into a map for easy access.
     * @author Håkon Kavli | 05-12-2026
     * @param workTrailIds The set of Work_Trail__c Ids for which to retrieve the records and create the map.
     * @return Map<Id, Work_Trail__c> The resulting map of Work_Trail__c records keyed by their Ids, allowing for efficient lookup when creating IPS_ManagerEvent DTOs.
     * @Todo add the WITH_SHARING keyboard to enforce sharing rules once a new permission set is created for the Managers that will use the "Jobbsporet Lederbrett". This will ensure that managers only see events for their direct reports and not for all employees in the organization.
     **/
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
                WITH USER_MODE
                ORDER BY CreatedDate DESC
            ]
        );
    }

    /**
     * @description Creates an IPS_ManagerEvent DTO from a given Event record and its related Work_Trail__c record. The method populates the fields of the IPS_ManagerEvent with relevant information from both the Event and Work_Trail__c records, such as employee name, profile, event details, participant information, and formatted start time. This transformation allows for a comprehensive representation of the event data for display on the manager's leaderboard.
     * @author Håkon Kavli | 05-12-2026
     * @param employeeEvent The Event record from which to create the IPS_ManagerEvent DTO, containing details about the event and its owner.
     * @param relatedWorkTrail The related Work_Trail__c record that provides additional context about the participant associated with the event, including their name, address, and participant identifier.
     * @return IPS_ManagerEvent The resulting IPS_ManagerEvent DTO that encapsulates the combined information from the Event and related Work_Trail__c records for display purposes.
     **/
    @TestVisible
    private static IPS_ManagerEvent createEmployeeEvent(Event employeeEvent, Work_Trail__c relatedWorkTrail) {
        IPS_ManagerEvent managerEvent = new IPS_ManagerEvent();
        managerEvent.eventId = employeeEvent.Id;
        managerEvent.employeeName = employeeEvent.Owner.Name;
        managerEvent.profileName = employeeEvent.Owner.Profile.Name;
        managerEvent.subject = employeeEvent.Subject;
        managerEvent.location = employeeEvent.Location ?? 'Sted ikke oppgitt';
        managerEvent.meetingCategory = employeeEvent.IPS_Type__c;
        managerEvent.accountName = employeeEvent.IPS_employerName__c ?? 'Arbeidsgiver ikke oppgitt';
        managerEvent.accountContactName = employeeEvent.Konto_kontakt__r.Name ?? 'Navn ikke oppgitt';
        managerEvent.isParticipantAttending = employeeEvent.IPS_participant_related_to_meeting__c;
        managerEvent.workTrailId = employeeEvent.WhatId;
        managerEvent.startTime = formatTime(employeeEvent.StartDateTime);
        managerEvent.participantIdent = relatedWorkTrail.ips_Participant__r.INT_PersonIdent__c ?? 'Fødselsnummer ikke oppgitt';
        managerEvent.participantName = relatedWorkTrail.ips_Participant__r.Name;
        managerEvent.participantAddress = relatedWorkTrail.IPS_Participants_home_address__c ?? 'Adresse ikke oppgitt';
        return managerEvent;
    }
    /**
     * @description Creates a set of unique WhatId values from the provided list of Event records that are associated with the specified IPS_EVENT_RECORD_TYPES. This method iterates through the list of events, checks if the WhatId is not null and if the RecordType of the event matches one of the specified types, and collects the unique WhatId values into a set for further processing.
     * @author Håkon Kavli | 05-12-2026
     * @param events The list of Event records to process.
     * @return Set<Id> A set of unique Work_Trail__c Id values from the provided Event records.
     **/
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
