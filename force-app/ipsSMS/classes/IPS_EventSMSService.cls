/**
 * @description  : Service class for handling SMS related to Events in IPS, including creation of SMS messages for new Events, reminders, and changes to existing Events.
 * @author       : Carl Huseby Fosli
 * @since        : Version 0.1
 * @author       : Håkon Kavli
 * @since        : 0.522.0
 * @see          : IPS_EventSMSServices
 * @last modified on  : 11-26-2025
 * @last modified by  : hkavli
 **/
public without sharing class IPS_EventSMSService {
    public enum SMSType {
        CREATED,
        REMINDER,
        CHANGED
    }
    @TestVisible
    private static Map<Event, Work_Trail__c> getWorktrailByEventMap(List<Event> eventList) {
        // Initialize collections
        Set<Id> workTrailIdSet = new Set<Id>();
        Map<Event, Work_Trail__c> eventWorkTailMap = new Map<Event, Work_Trail__c>();

        // Collect Work_Trail__c Ids from Events
        for (Event event : eventList) {
            workTrailIdSet.add(event.WhatId);
        }

        // Cet related Work_Trail__c records
        Map<Id, Work_Trail__c> workTrailMap = new Map<Id, Work_Trail__c>(
            [
                SELECT
                    Id,
                    ips_Participant__c,
                    ips_Participant__r.CRM_Person__r.IPS_IsReservationAgainstSMS__c,
                    ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c,
                    IPS_Partticipant_phone_number__c
                FROM Work_Trail__c
                WHERE Id IN :workTrailIdSet
            ]
        );

        // Map Work Trails by their correpsonding Events
        for (Event event : eventList) {
            eventWorkTailMap.put(event, workTrailMap.get(event.WhatId));
        }
        return eventWorkTailMap;
    }

    public static void createSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();
        Map<Event, Work_Trail__c> eventWorkTailMap = getWorktrailByEventMap(eventList);

        for (Event event : eventList) {
            Work_Trail__c workTrail = eventWorkTailMap.get(event);
            if (
                workTrail.IPS_Partticipant_phone_number__c == null &&
                workTrail.ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c != null
            ) {
                workTrail.IPS_Partticipant_phone_number__c = workTrail.ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c;
            }
            if (
                workTrail.ips_Participant__c != null &&
                workTrail.ips_Participant__r.CRM_Person__r.IPS_IsReservationAgainstSMS__c == false &&
                workTrail.IPS_Partticipant_phone_number__c != null
            ) {
                smsList.add(
                    IPS_SMS.createSMSRecord(
                        'IPS',
                        'Meeting Created',
                        workTrail.ips_Participant__c,
                        event.Id,
                        workTrail.IPS_Partticipant_phone_number__c,
                        constructCreatedMessage(event),
                        workTrail.Id
                    )
                );
                event.IPS_IsCreatedSMSSendt__c = true;
            }
        }
        // Insert SMS records
        CRM_DatabaseOperations cdoSMS = new CRM_DatabaseOperations().setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdoSMS.insertRecords(smsList);

        // Loop over inserted SMS to set the created flag on Events
        CRM_DatabaseOperations cdoEvents = new CRM_DatabaseOperations().setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdoEvents.updateRecords(eventList);
    }
    @TestVisible
    private static String constructCreatedMessage(Event event) {
        String message =
            'Det er satt opp et ' +
            event.ips_uo_Kanal__c.toLowerCase() +
            ' møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nLogg inn på NAV for detaljer. Du kan ikke svare på denne meldingen.';
        return message;
    }

    /**
     * @description Creates SMS messages to remind participants of upcoming Events
     * @author Håkon Kavli | 12-17-2025
     * @param eventList List of Events to create reminder SMS messages for
     **/
    public static void reminderSMS(List<Event> eventList) {
        Map<Id, Event> eventMap = new Map<Id, Event>(eventList);
        List<Id> insertedSMSrecordIds = new List<Id>();

        List<Event> eventsToUpdate = new List<Event>();

        // Create Wrapper with SMS messages to insert and Events to update
        EventSMSWrapper wrapper = createEventSMSWrapper(eventList, SMSType.REMINDER);

        // Insert SMS records
        List<Database.SaveResult> insertedSMSRecords = Database.insert(wrapper.smsList, false);

        // Retrieve SMS Ids for sent SMS's
        for (Database.SaveResult sr : insertedSMSRecords) {
            if (sr.isSuccess()) {
                insertedSMSrecordIds.add(sr.getId());
            }
        }
        // Update Events to reflect sent SMS
        for (SMS__c smsRecord : [SELECT Id, EventId__c FROM SMS__c WHERE Id IN :insertedSMSrecordIds]) {
            Event relatedEvent = eventMap.get(smsRecord.EventId__c);
            if (relatedEvent != null) {
                relatedEvent.IPS_IsReminderSMSSendt__c = true;
                eventsToUpdate.add(relatedEvent);
            }
        }
        CRM_DatabaseOperations cdoEvents = new CRM_DatabaseOperations().setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdoEvents.updateRecords(eventsToUpdate);
    }

    @TestVisible
    private static EventSMSWrapper createEventSMSWrapper(List<Event> eventList, SMSType smsType) {
        // Initialize collections
        EventSMSWrapper wrapper = new EventSMSWrapper();
        Map<Id, Event> eventMap = new Map<Id, Event>(eventList);
        Map<Event, Work_Trail__c> eventWorkTailMap = getWorktrailByEventMap(eventList);
        List<SMS__c> smsList = new List<SMS__c>();

        // Build SMS Messages
        for (Event event : eventList) {
            Work_Trail__c workTrail = eventWorkTailMap.get(event);

            // Use phone number from KRR if not already set
            if (
                workTrail.ips_Participant__c != null &&
                workTrail.IPS_Partticipant_phone_number__c == null &&
                workTrail.ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c != null
            ) {
                workTrail.IPS_Partticipant_phone_number__c = workTrail.ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c;
            }
            if (
                workTrail.ips_Participant__c != null &&
                workTrail.ips_Participant__r.CRM_Person__r.IPS_IsReservationAgainstSMS__c == false &&
                workTrail.IPS_Partticipant_phone_number__c != null
            ) {
                smsList.add(
                    IPS_SMS.createSMSRecord(
                        'IPS',
                        '24 Hour Scheduled Reminder',
                        workTrail.ips_Participant__c,
                        event.Id,
                        workTrail.IPS_Partticipant_phone_number__c,
                        constructReminderMessage(event),
                        workTrail.Id
                    )
                );
            }
        }

        wrapper.eventList = eventList;
        wrapper.smsList = smsList;
        wrapper.smsType = smsType;
        return wrapper;
    }
    public class EventSMSWrapper {
        public List<Event> eventList = new List<Event>();
        public List<SMS__c> smsList = new List<SMS__c>();
        public IPS_EventSMSService.SMSType smsType;
    }

    @TestVisible
    private static String constructReminderMessage(Event event) {
        String message = 'Husk møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nHvor: ' + setLocation(event);
        message += '\n\nLogg inn på NAV for detaljer.';
        message += '\n\nDu kan ikke svare på denne meldingen.';
        return message;
    }

    @TestVisible
    private static String setLocation(Event event) {
        if (event.Location != null) {
            return event.Location.left(30);
        } else if (event.ips_uo_Kanal__c != null) {
            return event.ips_uo_Kanal__c;
        } else {
            return 'Ikke oppgitt';
        }
    }

    public static void changeSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();
        Map<Event, Work_Trail__c> eventWorkTailMap = getWorktrailByEventMap(eventList);

        for (Event event : eventList) {
            Work_Trail__c workTrail = eventWorkTailMap.get(event);
            if (
                workTrail.ips_Participant__c != null &&
                workTrail.ips_Participant__r.CRM_Person__r.IPS_IsReservationAgainstSMS__c == false &&
                workTrail.IPS_Partticipant_phone_number__c != null
            ) {
                smsList.add(
                    IPS_SMS.createSMSRecord(
                        'IPS',
                        'Meeting Updated',
                        workTrail.ips_Participant__c,
                        event.Id,
                        workTrail.IPS_Partticipant_phone_number__c,
                        constructChangedMessage(event),
                        workTrail.Id
                    )
                );
                event.IPS_IsSendChangeSMS__c = false;
            }
        }
        Database.insert(smsList, false);
        Database.update(eventList, false);
    }

    @TestVisible
    private static String constructChangedMessage(Event event) {
        String message =
            'Møte er endret. Ny tid for' +
            event.ips_uo_Kanal__c.toLowerCase() +
            ' møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nDu kan ikke svare på denne meldingen.';
        return message;
    }

    @TestVisible
    private static String formatTimePeriod(Datetime startDate) {
        String timePeriod =
            startDate.date().format() +
            ', kl ' +
            (startDate.hour() < 10 ? '0' + String.valueOf(startDate.hour()) : String.valueOf(startDate.hour())) +
            ':' +
            (startDate.minute() < 10 ? '0' + String.valueOf(startDate.minute()) : String.valueOf(startDate.minute()));

        return timePeriod;
    }

    @TestVisible
    public static Long getMinutesUntilNextSMSBatch() {
        Long minutes = 60;
        Datetime now = Datetime.now();
        Datetime datetime1600 = Datetime.newInstance(Date.today(), Time.newInstance(16, 0, 0, 0));
        Boolean isWithinAnHour = datetime1600.getTime() - Datetime.now().getTime() < 3600000;
        Boolean isWithinTenMin = datetime1600.getTime() - Datetime.now().getTime() < 600000;
        Boolean isFriday = now.format('EEEE') == 'Friday';
        if (isWithinTenMin) {
            Datetime nextDay = Datetime.newInstance(now.addDays(1).date(), Time.newInstance(9, 0, 0, 0));
            minutes = (nextDay.getTime() - now.getTime()) / 60000;
            if (isFriday) {
                Datetime monday = Datetime.newInstance(now.addDays(3).date(), Time.newInstance(9, 0, 0, 0));
                minutes = (monday.getTime() - now.getTime()) / 60000;
            }
        } else if (isWithinAnHour) {
            minutes = (datetime1600.getTime() - now.getTime()) / 60000;
        }
        return minutes;
    }
}
