@isTest
public class IPS_ParticipantPortalTrailControllerTest {

    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor; 
    }
    
    @isTest
    static void getTrailRecordtype(){
        
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        
        Map<String,String> trailRecordtype = IPS_ParticipantPortalTrailController.getTrailAndRecordtype(participantId);        
        System.assert.isNotNull(trailRecordtype);
        
    }
    
    @isTest
    static void getTrail(){
        
      
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        
         List<IPS_ParticipantPortalWorkTrail> trail = IPS_ParticipantPortalTrailController.getTrailWrapperClassList(workTrailId);    
        System.assert.isNotNull(trail);
        
    }
    
    

}