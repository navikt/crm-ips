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
                    toLabel(IPS_report_Type__c),
                    CreatedDate,
                    toLabel(IPS_status__c),
                    IPS_intervallDateFrom__c, 
                    IPS_intervallDateTo__c
            FROM ips_report__c 
            WHERE 
                IPS_workTrailName__c =:workTrailId
            ORDER BY CreatedDate DESC];

        return reportLists;
    }
}