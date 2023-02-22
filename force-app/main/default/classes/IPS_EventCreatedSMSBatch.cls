public without sharing class IPS_EventCreatedSMSBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        IPS_EventCreatedSMSBatch instance = new IPS_EventCreatedSMSBatch();
        database.executebatch(instance, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        String query = 'SELECT ';
        query += 'Id, WhatId, WhoId, StartDateTime, EndDateTime ';
        query += 'FROM Event ';
        query += 'WHERE StartDateTime > :now ';
        query += 'AND (RecordType.DeveloperName = \'IPS_Event\' OR RecordType.DeveloperName = \'Ips_uo_Deltakermote\' OR RecordType.DeveloperName = \'ips_UO_m_ter\') ';
        query += 'AND WhoId != null ';
        query += 'AND WhatId != null ';
        query += 'AND IPS_Status1__c = \'Open\' ';
        query += 'AND IPS_IsCreatedSMSSendt__c = false';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Event> records) {
        try {
            IPS_EventSMSService.createSMS(records);
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
                System.scheduleBatch(new IPS_EventCreatedSMSBatch(), 'IPS_EventCreatedSMSBatch', (Integer) minutes, 10);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
                logger.publishSynch();
            }
        }
    }
}
