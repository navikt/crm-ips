public without sharing class IPS_EventChangedSMSBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        // IPS_EventChangedSMSBatch instance = new IPS_EventChangedSMSBatch();
        // database.executebatch(instance, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Datetime now = Datetime.now();
        String query = 'SELECT ';
        // query += 'Id, HOT_Request__r.Orderer__c, HOT_Request__r.OrdererPhone__c, HOT_Request__r.Type__c, Status, StartDate, EndDate, HOT_Request__r.IsOrdererWantStatusUpdateOnSMS__c, AccountId, Account.CRM_Person__c, Account.CRM_Person__r.INT_KrrMobilePhone__c ';
        // query += 'FROM WorkOrder ';
        // query += 'WHERE HOT_SendSMSNotificationOnStatusChanged__c = TRUE ';

        // IPS_IsSendChangeSMS__c

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> records) {
        // try {
        //     IPS_EventSMSService.sendSMSToOrdererOnStatusUpdate(records);
        // } catch (Exception e) {
        //     LoggerUtility logger = new LoggerUtility();
        //     logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
        //     logger.publish();
        // }
    }

    public void finish(Database.BatchableContext bc) {
        // Long minutes = HOT_Utility.getMinutesUntilNextSMSBatch();
        // if (!Test.isRunningTest()) {
        //     try {
        //         System.scheduleBatch(
        //             new IPS_EventChangedSMSBatch(),
        //             'IPS_EventChangedSMSBatch',
        //             (Integer) minutes,
        //             10
        //         );
        //     } catch (Exception e) {
        //         LoggerUtility logger = new LoggerUtility();
        //         logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
        //         logger.publishSynch();
        //     }
        // }
    }
}
