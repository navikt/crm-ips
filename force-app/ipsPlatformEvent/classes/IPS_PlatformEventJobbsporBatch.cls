public without sharing class IPS_PlatformEventJobbsporBatch implements Database.Batchable<sObject>,Schedulable{
    public void execute(SchedulableContext sc){
        IPS_PlatformEventJobbsporBatch instance = new IPS_PlatformEventJobbsporBatch();
        database.executebatch(instance, 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ';
        query += 'Id ';
        query += 'FROM Work_Trail__c ';
        
        return Database.getQueryLocator(query);
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
        
        //Long minutes = IPS_PlatformEventJobbsporService.getMinutesIncludingLastDay20Hours();
        if (!Test.isRunningTest()) {
            try {
                //System.scheduleBatch(new IPS_PlatformEventJobbsporBatch(), 'IPS_PlatformEventJobbsporBatch', (Integer) minutes, 100);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
                logger.publishSynch();
            }
        }
        
    }

}