public with sharing class IPS_PlatformEventJobbsporUserBatch implements Database.Batchable<sObject>, Schedulable {
    public static void scheduleMonthly() {
        String jobName = 'IPS_PlatformEventJobbsporUserBatch_LastDayOfMonth';
        String cronExpression = '0 0 22 L * ?';

        List<CronTrigger> existingJobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
        ];

        if (!existingJobs.isEmpty()) {
            return;
        }

        System.schedule(jobName, cronExpression, new IPS_PlatformEventJobbsporUserBatch());
    }

    public void execute(SchedulableContext sc) {
        IPS_PlatformEventJobbsporUserBatch instance = new IPS_PlatformEventJobbsporUserBatch();
        Database.executeBatch(instance, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT
                Id,
                Profile.Name,
                IsActive,
                UserRoleId,
                UserRole.Name,
                Department,
                CompanyName
            FROM User
            WHERE Profile.Name IN (
                'NAV IPS Jobbspesialist',
                'NAV IPS Metodeveileder',
                'NAV UO Jobbspesialist',
                'NAV UO Metodeveileder'
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<User> records) {
        try {
            IPS_PlatformEventJobbsporService.getUserRolesToPlatformEvent(records);
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.IPS);
            logger.publish();
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Intentionally left empty for now.
    }
}
