public with sharing class IPS_PlatformEventJobbsporAllBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, OwnerId
            FROM Work_Trail__c
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Work_trail__c> records){
        try{
            IPS_PlatformEventJobbsporService.getWorkTrailToPlatformEvent(records);
        }catch (Exception e){
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
            logger.publish();
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
        if (!Test.isRunningTest()) {
            try {
                //System.scheduleBatch(new IPS_PlatformEventJobbsporAllBatch(), 'IPS_PlatformEventJobbsporAllBatch', (Integer) minutes, 100);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
                logger.publishSynch();
            }
        }
        
    }

}