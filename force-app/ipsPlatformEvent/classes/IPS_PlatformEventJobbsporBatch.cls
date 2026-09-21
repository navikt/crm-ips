public with sharing class IPS_PlatformEventJobbsporBatch implements Database.Batchable<sObject>,Schedulable{
    public static void scheduleMonthly() {
        String jobName = 'IPS_PlatformEventJobbsporBatch_Monthly';
        String cronExpression = '0 45 23 L * ?';

        List<CronTrigger> existingJobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
        ];

        if (!existingJobs.isEmpty()) {
            return;
        }

        System.schedule(jobName, cronExpression, new IPS_PlatformEventJobbsporBatch());
    }

    public void execute(SchedulableContext sc){
        IPS_PlatformEventJobbsporBatch instance = new IPS_PlatformEventJobbsporBatch();
        database.executebatch(instance, 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date monthStart = Date.today().toStartOfMonth();
        Date monthEnd = monthStart.addMonths(1).addDays(-1);

        return Database.getQueryLocator([
            SELECT Id, OwnerId
            FROM Work_Trail__c
            WHERE ips_Status__c != 'Ended'
                OR (
                    ips_Status__c = 'Ended'
                    AND ips_End_Date__c >= :monthStart
                    AND ips_End_Date__c <= :monthEnd
                )
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
                //System.scheduleBatch(new IPS_PlatformEventJobbsporBatch(), 'IPS_PlatformEventJobbsporBatch', (Integer) minutes, 100);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
                logger.publishSynch();
            }
        }
        
    }

}