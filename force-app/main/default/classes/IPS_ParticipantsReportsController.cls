public with sharing class IPS_ParticipantsReportsController {

    @AuraEnabled(cacheable=true)
    /* Get a user report and show in experience cloud */
    public static List<ips_report__c> getParticipantsReport(String recordId){
        Date todaysDate = System.today();
        List<ips_report__c> reportList = new List<ips_report__c>();

        reportList = [SELECT id,
            IPS_report_Type__c,
            CreatedDate,
            IPS_dueDateBack__c,
            IPS_subject__c,
            IPS_worktrail_Type__c 
        FROM ips_report__c 
        WHERE 
        IPS_status__c = 'Open'
        AND IPS_workTrailName__c =:recordId]; 

        return reportList;
    }

    /* Get all reports and show it in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<ips_report__c> getAllReports(String workTrailId){
        List<ips_report__c> reportLists = new List<ips_report__c>();

        reportLists = [
            SELECT  id,
                    IPS_report_Type__c,
                    IPS_dueDateBack__c,
                    IPS_subject__c
            FROM ips_report__c 
            WHERE 
                IPS_status__c = 'Open'
                AND IPS_workTrailName__c =:workTrailId];

        return reportLists;
    }

    /* Get all reports and show it in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<ips_report__c> allReports(String workTrailId){
        List<ips_report__c> reportLists = new List<ips_report__c>();

        reportLists = [
            SELECT  Id,
                    Name,
                    IPS_report_Type__c,
                    CreatedDate,
                    IPS_status__c,
                    IPS_intervallDateFrom__c, 
                    IPS_intervallDateTo__c
            FROM ips_report__c 
            WHERE 
                IPS_workTrailName__c =:workTrailId
            ORDER BY CreatedDate DESC];

        return reportLists;
    }

    @AuraEnabled
    public static void createIntervallReport(Date dateTo, Date dateFrom, String recTrail,String userId,String workTrailId){
        String status = 'Open';
        String type = 'Intervall';
        try {
            ips_report__c report = new ips_report__c(
                IPS_intervallDateFrom__c = dateFrom,
                IPS_intervallDateTo__c = dateTo,
                IPS_status__c = status,
                IPS_report_Type__c = type,
                IPS_workTrailName__c = workTrailId,
                IPS_worktrail_Type__c =recTrail,
                OwnerId = userId
    );
    insert report;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createEndReport(String recTrail,String userId,String workTrailId){
        String status = 'Open';
        String type = 'End report';
        try {
            ips_report__c report = new ips_report__c(
                IPS_status__c = status,
                IPS_report_Type__c = type,
                IPS_workTrailName__c = workTrailId,
                IPS_worktrail_Type__c =recTrail,
                OwnerId = userId
    );
    insert report;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}