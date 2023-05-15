@IsTest
private class IPS_ManagerEventControllerTest {
    
    @TestSetup
    private static void makeData(){
        Person__c person=IPS_TestDataFactory.createPerson('12047823564');
        insert person;
        Person__c personWithAccount=[SELECT CRM_Account__c, CRM_Account__r.PersonContactId FROM Person__C LIMIT 1];
        Id accountId=personWithAccount.CRM_Account__c;
        Id contactId= personWithAccount.CRM_Account__r.PersonContactId;

        Account employer=IPS_TestDataFactory.createEmployerAccount();
        insert employer;
        Work_Trail__C trail=IPS_TestDataFactory.createJobbspor(accountId);
        insert trail;
                
        User employeeUser=IPS_TestDataFactory.createInternalUserWithManager('test.employee@nav.no',UserInfo.getUserId());
        insert employeeUser;
        
        List<Event> events=new List<Event>();
        Event eventAssignedToManagersEmployees=IPS_TestDataFactory.createEmployerEventWithParticipant(employer.Id,employeeUser.Id,trail.Id);
        events.add(eventAssignedToManagersEmployees);

        Event eventAssignedToOtherUser=IPS_TestDataFactory.createEmployerEventWithParticipant(employer.Id,UserInfo.getUserId(),trail.Id);
        events.add(eventAssignedToOtherUser);

        Event eventAssignedParticipant=IPS_TestDataFactory.createParticipantEvent(employeeUser.Id,trail.Id);
        events.add(eventAssignedParticipant);

        insert events;
    }

    @IsTest
    private static void testGetEventsForCurrentWeekEmployer(){
        List<IPS_ManagerEvent> events=IPS_ManagerEventController.getEventsForCurrentWeekEmployer();
        System.assertEquals(1, events.size(), 'Expect only event assigned to managers employee to be retuned');

        //verify properties are set
        System.assertEquals('Møte med Arbeidsgiver', events[0].subject);
        System.assertEquals('Kontoret', events[0].location);
        System.assertEquals('12047823564', events[0].participantIdent);
        System.assertEquals('First12047823564 Last', events[0].participantName);
    }  
    
    @IsTest
    private static void testGetEventsForCurrentWeek(){
        List<IPS_ManagerEvent> events=IPS_ManagerEventController.getEventsForCurrentWeek();
        System.assertEquals(1, events.size(), 'Expect only event assigned to managers employee to be retuned');

        //verify properties are set
        System.assertEquals('Møte med deltaker', events[0].subject);
    }  
}
