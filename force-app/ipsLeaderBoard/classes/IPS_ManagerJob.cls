/**
 * @description  : DTO representing aggregated ips_Job__c data for display on the manager's leaderboard.
 * @author       : Balendra Sounthararajan
 **/
public with sharing class IPS_ManagerJob {
    @AuraEnabled
    public String typeOfEmployment;

    @AuraEnabled
    public String status;

    @AuraEnabled
    public Integer totalNumber;

    @AuraEnabled
    public Id jobId;
}
