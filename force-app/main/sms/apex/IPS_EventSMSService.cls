public without sharing class IPS_EventSMSService {
    public static void createSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();

        for (Event event : eventList) {
            smsList.add(
                IPS_SMS.createSMSRecord(
                    'IPS',
                    'Meeting Created',
                    event.WhoId, //TODO hente ut accountId
                    event.Id,
                    event.WhatId, //IPS_Partticipant_phone_number__c,
                    constructCreatedMessage(event)
                )
            );
            event.IPS_IsReminderSMSSendt__c = true;
        }
        CRM_DatabaseOperations cdo = new CRM_DatabaseOperations();
        cdo.setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdo.insertRecords(smsList);
        cdo.updateRecords(eventList);
    }

    private static String constructCreatedMessage(Event event) {
        String message = 'INFO\nDitt møte med jobbspesialisten er opprettet. Tidspunktet er:\n';
        message += '\nDato: ' + formatTimePeriod(event.StartDateTime, event.EndDateTime);
        message += '\n\nFor mer informasjon, se www.nav.no. Du kan ikke svare på denne meldingen.';
        message += '\nMvh jobbspesialisten i NAV';
        return message;
    }

    public static void reminderSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();

        for (Event event : eventList) {
            smsList.add(
                IPS_SMS.createSMSRecord(
                    'IPS',
                    '24 Hour Scheduled Reminder',
                    event.WhoId, //TODO hente ut accountId
                    event.Id,
                    event.WhatId, //IPS_Partticipant_phone_number__c,
                    constructReminderMessage(event)
                )
            );
            event.IPS_IsReminderSMSSendt__c = true;
        }
        CRM_DatabaseOperations cdo = new CRM_DatabaseOperations();
        cdo.setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdo.insertRecords(smsList);
        cdo.updateRecords(eventList);
    }

    private static String constructReminderMessage(Event event) {
        String message = 'PÅMINNELSE\nVi minner om møte med jobbspesialisten din:\n';
        message += 'Dato: ' + formatTimePeriod(event.StartDateTime, event.EndDateTime) + '\n';
        message += '\n\nFor mer informasjon, se www.nav.no. Du kan ikke svare på denne meldingen.';
        message += '\nMvh jobbspesialisten i NAV';
        return message;
    }

    public static void updateSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();

        for (Event event : eventList) {
            smsList.add(
                IPS_SMS.createSMSRecord(
                    'IPS',
                    'Meeting Updated',
                    event.WhoId, //TODO hente ut accountId
                    event.Id,
                    event.WhatId, //IPS_Partticipant_phone_number__c,
                    construcChangedMessage(event)
                )
            );
            //event.IPS_IsUpdateSMSSendt__c = true;
            //datofelt?
        }
        CRM_DatabaseOperations cdo = new CRM_DatabaseOperations();
        cdo.setDomain(CRM_ApplicationDomain.Domain.IPS);
        cdo.insertRecords(smsList);
        //cdo.updateRecords(eventList);
    }

    private static String construcChangedMessage(Event event) {
        String message = 'INFO\nDitt møte med jobbspesialisten er endret. Nytt tidspunkt er:\n';
        message += '\nDato: ' + formatTimePeriod(event.StartDateTime, event.EndDateTime);
        message += '\n\nFor mer informasjon, se www.nav.no. Du kan ikke svare på denne meldingen.';
        message += '\nMvh jobbspesialisten i NAV';
        return message;
    }

    private static String formatTimePeriod(Datetime startDate, Datetime endDate) {
        String timePeriod =
            startDate.date().format() +
            '\nKlokkeslett: ' +
            (startDate.hour() < 10 ? '0' + String.valueOf(startDate.hour()) : String.valueOf(startDate.hour())) +
            '.' +
            (startDate.minute() < 10 ? '0' + String.valueOf(startDate.minute()) : String.valueOf(startDate.minute())) +
            ' - ' +
            (endDate.hour() < 10 ? '0' + String.valueOf(endDate.hour()) : String.valueOf(endDate.hour())) +
            '.' +
            (endDate.minute() < 10 ? '0' + String.valueOf(endDate.minute()) : String.valueOf(endDate.minute()));

        return timePeriod;
    }
}
