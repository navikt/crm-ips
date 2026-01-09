/**
 * @description       : 
 * @author            : hkavli
 * @group             : 
 * @last modified on  : 11-21-2025
 * @last modified by  : hkavli
**/
List<Work_Trail__c> workTrailsToUpdate = new List<Work_Trail__c>();

for (Work_Trail__c workTrail : [SELECT Id, IPS_Partticipant_phone_number__c, ips_Participant__r.INT_KrrMobilePhone__c FROM Work_Trail__c WHERE ips_Status__c NOT IN('Ended') AND ips_Participant__r.INT_KrrMobilePhone__c != null AND IPS_Partticipant_phone_number__c  = null  AND IPS_isSMSReserved__c = false LIMIT 2000]) {
    workTrail.IPS_Partticipant_phone_number__c  = workTrail.ips_Participant__r.INT_KrrMobilePhone__c;
    workTrailsToUpdate.add(workTrail);
}

CRM_DatabaseOperations cdo = new CRM_DatabaseOperations().setDomain(CRM_ApplicationDomain.Domain.IPS);
cdo.updateRecords(workTrailsToUpdate);