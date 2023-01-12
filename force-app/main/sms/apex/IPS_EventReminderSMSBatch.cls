public without sharing class IPS_EventReminderSMSBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        IPS_EventReminderSMSBatch instance = new IPS_EventReminderSMSBatch();
        database.executebatch(instance, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        Date horizonDate = Date.today().addDays(2);
        if (now.format('EEEE') == 'Friday') {
            horizonDate = Date.today().addDays(4);
        }
        String query = 'SELECT ';
        query += 'Id, WhatId, WhoId, StartDateTime, EndDateTime ';
        query += 'FROM Event ';
        query += 'WHERE StartDate < :horizonDate ';
        query += 'AND StartDate > :now ';
        query += 'AND RecordType.DeveloperName = \'IPS_Event\' ';
        query += 'AND WhoId != null ';
        //query += 'AND WhatId.Account.CRM_Person__r.IPS_IsReservationAgainstSMS__c = FALSE '; hvordan best hente info om bruker?
        query += 'AND IPS_IsReminderSMSSendt__c = FALSE';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Event> records) {
        try {
            IPS_EventSMSService.reminderSMS(records);
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
            logger.publish();
        }
    }

    public void finish(Database.BatchableContext bc) {
        Long minutes = getMinutesUntilNextSMSBatch();
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(
                    new IPS_EventReminderSMSBatch(),
                    'IPS_EventReminderSMSBatch',
                    (Integer) minutes,
                    10
                );
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
                logger.publishSynch();
            }
        }
    }

    private static Long getMinutesUntilNextSMSBatch() {
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
