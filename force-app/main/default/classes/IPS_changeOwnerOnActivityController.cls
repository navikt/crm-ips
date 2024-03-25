public without sharing class IPS_changeOwnerOnActivityController {
    @InvocableMethod(label='IPS change owner on activity' description='Change owner on all open activities when owner is changed on workt trail')
    public static void invokeChangeOwner(List<eventRequest> request){
        //parse input and variables
        Id currentId = request.get(0).currentRecord;
        Id oldOwnerId = request.get(0).oldOwnerRecord;
        Id ownerId = request.get(0).ownerRecord;
        String objectName = request.get(0).sObjectName;
        
        IF(objectName =='Task'){
            updateRelatedOwnerTask(currentId,ownerId);
            updateRelatedOwnerHistory(currentId,ownerId);
        }
        IF(objectName == 'Event'){
            updateRelatedOwnerEvent(currentId,ownerId,oldOwnerId);
        }
        IF(objectName =='ips_report__c'){
            updateRelatedOwnerReport(currentId,ownerId);
        }
    }
        
    @TestVisible
    private static void updateRelatedOwnerTask(Id currentId,Id ownerId){
        List<Task> alltasks = [SELECT 
                               id,OwnerId 
                               FROM Task 
                               WHERE Type_of_Task_IPSUO__c in('Delmål (av hovedmål)') 
                               AND whatId =:currentId 
                               AND IPS_Status1__c in ('Open')];
        if(!alltasks.isEmpty()){
            for(Task t:alltasks){
            	t.OwnerId = ownerId;
        	}
            /*Set EmailHeader.triggerUserEmail to false, this disables send Email notification. Try to prevent email sendt when task changes owner.
             * https://help.salesforce.com/s/articleView?id=000385933&type=1
             * */
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            database.update(alltasks, dmlo);
        }    
    }
    
    private static void updateRelatedOwnerHistory(Id currentId,Id ownerId){
        List<Task> allhistory = [SELECT 
                               id,OwnerId 
                               FROM Task 
                               WHERE Type_of_Task_IPSUO__c in('Historikk') 
                               AND whatId =:currentId];
        if(!allhistory.isEmpty()){
            for(Task t:allhistory){
                t.OwnerId = ownerId;
            }
            /*Set EmailHeader.triggerUserEmail to false, this disables send Email notification. Try to prevent email sendt when task changes owner.
            * https://help.salesforce.com/s/articleView?id=000385933&type=1
            * */
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            database.update(allhistory, dmlo);
        }    
    }
    
    private static void updateRelatedOwnerEvent(Id currentId,Id ownerId,Id oldOwnerId){
        List<Event> allevents = [SELECT 
                                 id,OwnerId 
                                 FROM Event 
                                 WHERE IPS_Type__c in ('Meeting with Participant','Meeting with Employer','First Meeting with Employer','Start up meeting') 
                                 AND IPS_Status1__c in ('Open')
                                 AND OwnerId =:oldOwnerId
                                 AND Owner.IsActive =true
                                 AND whatId =:currentId];
        if(!allevents.isEmpty()){
            for(Event e:allevents){
            	e.OwnerId = ownerId;
        	}
        	update allevents; 
        }    
    }

    private static void updateRelatedOwnerReport(Id currentId, Id ownerId){
        List<ips_report__c> allreport = [SELECT 
                                        id,OwnerId
                                        FROM ips_report__c
                                        WHERE IPS_workTrailName__c =:currentId];
        if(!allreport.isEmpty()){
            for(ips_report__c r:allreport){ 
                r.OwnerId = ownerId;
            }
            /*Set EmailHeader.triggerUserEmail to false, this disables send Email notification. Try to prevent email sendt when report changes owner.
             * https://help.salesforce.com/s/articleView?id=000385933&type=1
             * */
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            database.update(allreport, dmlo);
        }
    }

    	//Input variables from flow
        public class eventRequest {
            @InvocableVariable(required=true)
            public Id currentRecord;
            
            @InvocableVariable(required=true)
            public Id ownerRecord;
            
            @InvocableVariable(required=true)
            public String sObjectName;

            @InvocableVariable
            public Id oldOwnerRecord;
            
		}
}