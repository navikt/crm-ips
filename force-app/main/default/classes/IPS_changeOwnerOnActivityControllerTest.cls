@isTest
public class IPS_changeOwnerOnActivityControllerTest {
    
     @testSetup
    	static void setupTestData() {
        
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
            
            Task tgoal = IPS_TestDataFactory.createGoal(jobbspor.id);
            insert tgoal;
            
            Event meetEmp1 = IPS_TestDataFactory.createEmployerEventWithParticipant(employerAccount.id,u.id,jobbspor.id);
            insert meetEmp1;
        }
    }

    @isTest
    static void testInvokeChangeOwnerForTasks() {
        ID workTrailId = [SELECT id FROM Work_Trail__c LIMIT 1]?.id;
        ID userId = [SELECT id FROM User LIMIT 1]?.id;
        User u2 = IPS_TestDataFactory.getAdminUser('Hanne','Olsen');
        insert u2;
        
        // Prepare the request
        IPS_changeOwnerOnActivityController.eventRequest request = new IPS_changeOwnerOnActivityController.eventRequest();
        request.currentRecord = workTrailId;
        request.ownerRecord = u2.Id;
        request.oldOwnerRecord = userId;
        request.sObjectName = 'Task';

        List<IPS_changeOwnerOnActivityController.eventRequest> requests = new List<IPS_changeOwnerOnActivityController.eventRequest>{request};

        // Invoke the method
        Test.startTest();
        IPS_changeOwnerOnActivityController.invokeChangeOwner(requests);
        Test.stopTest();

        // Verify the tasks' owner has been updated
        List<Task> updatedTasks = [SELECT Id, OwnerId FROM Task WHERE WhatId = :workTrailId];
        for (Task t : updatedTasks) {
            System.assertEquals(u2.id, t.OwnerId, 'Task owner should be updated to the new owner');
        }
    }


    @isTest
    static void testInvokeChangeOwnerForEvents() {
        ID workTrailId = [SELECT id FROM Work_Trail__c LIMIT 1]?.id;
        ID userId = [SELECT id FROM User WHERE name ='Per Nilsen']?.id;
        User u2 = IPS_TestDataFactory.getAdminUser('Hanne','Olsen');
        insert u2;
        
        // Prepare the request
        IPS_changeOwnerOnActivityController.eventRequest request = new IPS_changeOwnerOnActivityController.eventRequest();
        request.currentRecord = workTrailId;
        request.ownerRecord = u2.Id;
        request.oldOwnerRecord = userId;
        request.sObjectName = 'Event';

        List<IPS_changeOwnerOnActivityController.eventRequest> requests = new List<IPS_changeOwnerOnActivityController.eventRequest>{request};

        // Invoke the method
        Test.startTest();
        IPS_changeOwnerOnActivityController.invokeChangeOwner(requests);
        Test.stopTest();

        // Verify the events' owner and travel time fields have been updated
        List<Event> updatedEvents = [SELECT Id, OwnerId, ips_Travel_time__c, IPS_travelTimeFrom__c FROM Event WHERE WhatId = :workTrailId];
        for (Event e : updatedEvents) {
            System.assertEquals(u2.Id, e.OwnerId, 'Event owner should be updated to the new owner');
            System.assertEquals(0, e.ips_Travel_time__c, 'Travel time should be reset to 0');
            System.assertEquals(0, e.IPS_travelTimeFrom__c, 'Travel time from should be reset to 0');
        }
    }
    
    @isTest
    static void testInvokeChangeOwnerInvalidObjectName() {
        
        ID workTrailId = [SELECT id FROM Work_Trail__c LIMIT 1]?.id;
        ID userId = [SELECT id FROM User WHERE name ='Per Nilsen']?.id;
        User u2 = IPS_TestDataFactory.getAdminUser('Hanne','Olsen');
        insert u2;
        
        // Prepare the request with an invalid object name
        IPS_changeOwnerOnActivityController.eventRequest request = new IPS_changeOwnerOnActivityController.eventRequest();
        request.currentRecord = workTrailId;
        request.ownerRecord = u2.Id;
        request.oldOwnerRecord = userId;
        request.sObjectName = 'Account';

        List<IPS_changeOwnerOnActivityController.eventRequest> requests = new List<IPS_changeOwnerOnActivityController.eventRequest>{request};

        // Invoke the method
        Test.startTest();
        IPS_changeOwnerOnActivityController.invokeChangeOwner(requests);
        Test.stopTest();

        // Verify no changes were made
        Integer taskCount = [SELECT COUNT() FROM Task WHERE WhatId = :workTrailId AND OwnerId = :u2.Id];
        Integer eventCount = [SELECT COUNT() FROM Event WHERE WhatId = :workTrailId AND OwnerId = :u2.Id];

        System.assertEquals(0, taskCount, 'No tasks should be updated for an invalid object name');
        System.assertEquals(0, eventCount, 'No events should be updated for an invalid object name');
    }
}