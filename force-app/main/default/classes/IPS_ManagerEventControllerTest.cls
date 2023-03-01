@IsTest
private class IPS_ManagerEventControllerTest {
    
    @TestSetup
    private static void makeData(){
        Person__c person=IPS_TestDataFactory.createPerson();
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
        Event eventAssignedToManagersEmployees=IPS_TestDataFactory.createEmployerEventWithParticipant(employer.Id,contactId,trail.Id, employeeUser.Id);
        events.add(eventAssignedToManagersEmployees);

        Event eventAssignedToOtherUser=IPS_TestDataFactory.createEmployerEventWithParticipant(employer.Id,contactId,trail.Id, UserInfo.getUserId());
        events.add(eventAssignedToOtherUser);

        insert events;
    }

    @IsTest
    private static void testGetEventsForCurrentWeek(){
        List<IPS_ManagerEvent> events=IPS_ManagerEventController.getEventsForCurrentWeek();
        System.assertEquals(1, events.size(), 'Expect only event assigned to managers employee to be retuned');

        //verify properties are set
        System.assertEquals('Møte med Arbeidsgiver', events[0].subject);
        System.assertEquals('Kontoret', events[0].location);
        System.assertEquals('12069755555', events[0].participantIdent);
        System.assertEquals('First Last', events[0].participantName);
        System.assertEquals('Storgata 1', events[0].participantAddress);

    }    
}