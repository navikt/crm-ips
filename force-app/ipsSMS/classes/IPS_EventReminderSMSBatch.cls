/**
 * @description       : Batch class to schedule SMS reminders for upcoming Events.
 * @author            : Carl Huseby Fosli
 * @group             : IPS
 * @last modified on  : 11-18-2025
 * @last modified by  : hkavli
 **/
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
        query += 'Id, WhatId, WhoId, StartDateTime, EndDateTime, ips_uo_Kanal__c, Location ';
        query += 'FROM Event ';
        query += 'WHERE StartDateTime < :horizonDate ';
        query += 'AND StartDateTime > :now ';
        query += 'AND RecordType.DeveloperName IN (\'IPS_Event\', \'Ips_uo_Deltakermote\', \'ips_UO_m_ter\') ';
        query += 'AND WhoId != null ';
        query += 'AND WhatId != null ';
        query += 'AND IPS_Status1__c = \'Open\' ';
        query += 'AND IPS_IsReminderSMSSendt__c = false';

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
        Long minutes = IPS_EventSMSService.getMinutesUntilNextSMSBatch();
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
}
