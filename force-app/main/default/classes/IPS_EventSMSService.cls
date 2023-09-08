public without sharing class IPS_EventSMSService {
    private static Map<Event, Work_Trail__c> getEventWorkTailMap(List<Event> eventList) {
        Set<Id> workTrailIdSet = new Set<Id>();
        for (Event event : eventList) {
            workTrailIdSet.add(event.WhatId);
        }

        List<Work_Trail__c> workTrailList = [
            SELECT
                Id,
                ips_Participant__c,
                ips_Participant__r.CRM_Person__r.IPS_IsReservationAgainstSMS__c,
                ips_Participant__r.CRM_Person__r.INT_KrrMobilePhone__c,
                IPS_Partticipant_phone_number__c
            FROM Work_Trail__c
            WHERE Id IN :workTrailIdSet
        ];

        Map<Id, Work_Trail__c> workTrailMap = new Map<Id, Work_Trail__c>();

        for (Work_Trail__c workTrail : workTrailList) {
            workTrailMap.put(workTrail.Id, workTrail);
        }

        Map<Event, Work_Trail__c> eventWorkTailMap = new Map<Event, Work_Trail__c>();

        for (Event event : eventList) {
            eventWorkTailMap.put(event, workTrailMap.get(event.WhatId));
        }
        return eventWorkTailMap;
    }

    public static void createSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();
        Map<Event, Work_Trail__c> eventWorkTailMap = getEventWorkTailMap(eventList);

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
        Database.update(eventList, true);
        Database.insert(smsList, true);
    }

    private static String constructCreatedMessage(Event event) {
        String message = 'Det er satt opp et '+event.ips_uo_Kanal__c +' møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nLogg inn på nav.no for detaljer. Du kan ikke svare på denne meldingen.';
        return message;
    }

    public static void reminderSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();
        Map<Event, Work_Trail__c> eventWorkTailMap = getEventWorkTailMap(eventList);

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
                        '24 Hour Scheduled Reminder',
                        workTrail.ips_Participant__c,
                        event.Id,
                        workTrail.IPS_Partticipant_phone_number__c,
                        constructReminderMessage(event),
                        workTrail.Id
                    )
                );
                event.IPS_IsReminderSMSSendt__c = true;
            }
        }
        Database.update(eventList, true);
        Database.insert(smsList, true);
    }

    private static String constructReminderMessage(Event event) {
        String message = 'Husk '+ event.ips_uo_Kanal__c + ' møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nDu kan ikke svare på denne meldingen.';
        return message;
    }

    public static void changeSMS(List<Event> eventList) {
        List<SMS__c> smsList = new List<SMS__c>();
        Map<Event, Work_Trail__c> eventWorkTailMap = getEventWorkTailMap(eventList);

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
                        construcChangedMessage(event),
                        workTrail.Id
                    )
                );
                event.IPS_IsSendChangeSMS__c = false;
            }
        }
        Database.update(eventList, true);
        Database.insert(smsList, true);
    }

    private static String construcChangedMessage(Event event) {
        String message = 'Møte er endret. Ny tid for'+ event.ips_uo_Kanal__c + ' møte med jobbspesialisten din.';
        message += '\n\nTidspunkt: ' + formatTimePeriod(event.StartDateTime);
        message += '\n\nDu kan ikke svare på denne meldingen.';
        return message;
    }

    private static String formatTimePeriod(Datetime startDate) {
        String timePeriod =
            startDate.date().format() +
            ', kl ' +
            (startDate.hour() < 10 ? '0' + String.valueOf(startDate.hour()) : String.valueOf(startDate.hour())) +
            ':' +
            (startDate.minute() < 10 ? '0' + String.valueOf(startDate.minute()) : String.valueOf(startDate.minute()));

        return timePeriod;
    }

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
