public with sharing class IPS_ParticipantPortalTrailController {
        
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getTrailAndRecordtype(Id accountId){
        Id currentAccountId = accountId;

        Work_Trail__c activeTrail =[
            SELECT Id, RecordType.DeveloperName,Owner.Name
            FROM Work_Trail__c 
            WHERE  ips_Participant__c = :currentAccountId  
            AND (ips_End_Date__c = LAST_N_DAYS:365 OR ips_End_Date__c =NULL) 
            ORDER BY CreatedDate DESC LIMIT 1];

        Map<String,String> trailMap = new Map<String,String>();
        trailMap.put('jobbsporId',activeTrail.Id);
        trailMap.put('jobbsporPostTypeNavn',activeTrail.RecordType.DeveloperName);
        trailMap.put('jobbsporJobbspesialist',activeTrail.Owner.Name);
        return trailMap;
    }
    
    @AuraEnabled(cacheable=true)
   public static List<IPS_ParticipantPortalWorkTrail> getTrailWrapperClassList(Id recordId){
    Id currentRecordId = recordId;
     
    List<IPS_ParticipantPortalWorkTrail> wrapperList =  new List<IPS_ParticipantPortalWorkTrail>();
    wrapperList = getWorkTrailWrapperList(currentRecordId);
    return wrapperList;
   }

   private static List<IPS_ParticipantPortalWorkTrail> getWorkTrailWrapperList(Id currentRecordId){
    List<IPS_ParticipantPortalWorkTrail> wrapperTempList = new List<IPS_ParticipantPortalWorkTrail>();
        
    List <Work_Trail__c> tempTrailList = new List<Work_Trail__c>();
        tempTrailList =[
            SELECT id,
            Name,
            RecordType.DeveloperName,
            IPS_ownerName__c,
            ips_End_Date__c,
            End_Cause__c,
            ips_Other_end_cases__c,
            ips_Status__c
            FROM Work_Trail__c
            WHERE  Id = :currentRecordId];

            for(Work_Trail__c t :tempTrailList){
                
                IPS_ParticipantPortalWorkTrail tempList = new IPS_ParticipantPortalWorkTrail();
                tempList.jobbsporId = t.id;
                tempList.jobbsporNavn = t.Name;
                tempList.jobbsporPostTypeNavn = t.RecordType.DeveloperName;
                tempList.jobbsporEierNavn = t.IPS_ownerName__c;
                tempList.jobbsporStatus = t.ips_Status__c;
                wrapperTempList.add(tempList);
            }
            return wrapperTempList;
        }
    }