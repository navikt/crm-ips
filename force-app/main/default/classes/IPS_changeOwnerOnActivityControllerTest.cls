@isTest
public class IPS_changeOwnerOnActivityControllerTest {
    @TestSetup
    static void makeData(){
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;

        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name='12069755555']?.CRM_Account__c;
        String contactId = [select id from contact where AccountId =:participantId].id;

        Account employerAccount = IPS_TestDataFactory.createEmployerAccount();
        insert employerAccount;
        
        User u = IPS_TestDataFactory.getAdminUser('Per','Nilsen');
        insert u;
        
        System.runAs(u) {
            
            Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        	insert jobbspor;
            
            Event meetEmp1 = IPS_TestDataFactory.createEmployerEventWithParticipant(employerAccount.id,u.id,jobbspor.id);
            insert meetEmp1;
        	Event meetEmp2 = IPS_TestDataFactory.createEmployerEventWithParticipant(employerAccount.id,u.id,jobbspor.id);
            insert meetEmp2;
            
            Task tgoal = IPS_TestDataFactory.createGoal(jobbspor.id);
            insert tgoal;
        }
    }
        
    
    @isTest
    static void changeOwnerOnWorktrail(){
        
    	User u2 =IPS_TestDataFactory.getAdminUser('Hanne','Persen');
        insert u2;
        List<Work_Trail__c> worktrailList = [SELECT id,OwnerId FROM Work_Trail__c];
        for(Work_Trail__c w:worktrailList){
            w.OwnerId = u2.Id;
        }
        update worktrailList;
    }
}