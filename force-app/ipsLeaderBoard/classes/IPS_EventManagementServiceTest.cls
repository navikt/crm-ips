/**
 * @description  : Test class for IPS_EventManagementService, including setup of test data and test methods for extracting Work Trail Ids and creating Manager Event DTOs.
 * @author       : Håkon Kavli
 * @since        : 0.533.0
 * @version      : 0.533.0
 **/
@IsTest
public with sharing class IPS_EventManagementServiceTest {
    @TestSetup
    static void makeData() {
        Person__c person = IPS_TestDataFactory.createPerson('12047823564');
        insert person;
        Person__c personWithAccount = [SELECT CRM_Account__c, CRM_Account__r.PersonContactId FROM Person__C LIMIT 1];
        Id accountId = personWithAccount.CRM_Account__c;
        Id contactId = personWithAccount.CRM_Account__r.PersonContactId;

        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;
        Work_Trail__C trail = IPS_TestDataFactory.createJobbspor(accountId);
        insert trail;

        User employeeUser = IPS_TestDataFactory.createInternalUserWithManager(
            'test.employee@nav.no',
            UserInfo.getUserId()
        );
        insert employeeUser;

        List<Event> events = new List<Event>();
        Event eventAssignedToManagersEmployees = IPS_TestDataFactory.createEmployerEventWithParticipant(
            employer.Id,
            employeeUser.Id,
            trail.Id
        );
        events.add(eventAssignedToManagersEmployees);

        Event eventAssignedToOtherUser = IPS_TestDataFactory.createEmployerEventWithParticipant(
            employer.Id,
            UserInfo.getUserId(),
            trail.Id
        );
        events.add(eventAssignedToOtherUser);

        Event eventAssignedParticipant = IPS_TestDataFactory.createParticipantEventWithOwner(employeeUser.Id, trail.Id);
        events.add(eventAssignedParticipant);

        insert events;
    }

    @isTest
    private static void testExtractWorkTrailIds() {
        // Arrange
        List<Work_Trail__c> expectedWorkTrails = [SELECT Id FROM Work_Trail__c LIMIT 10];
        List<Event> events = [
            SELECT Id, WhatId, RecordType.DeveloperName
            FROM Event
            WHERE WhatId != NULL AND WhatId IN :expectedWorkTrails
            LIMIT 10
        ];

        // Act
        Test.startTest();
        Set<Id> workTrailIds = IPS_EventManagementService.extractWorkTrailIds(events);
        Test.stopTest();

        // Assert
        System.Assert.isNotNull(workTrailIds, 'Extracted Work Trails to be created');
        System.Assert.isTrue(workTrailIds.size() > 0, 'Extracted Work Trails should not be empty');
        System.Assert.isTrue(
            workTrailIds.contains(expectedWorkTrails[0].Id),
            'Extracted Work Trails should contain expected Work Trail Ids'
        );
    }
    /*     @isTest
    private static void extractWorkTrailIds_shouldReturnCorrectIds() {
        // Arrange
        String participantIdent1 = '12069755555';
        String participantIdent2 = '12069755556';
        Work_Trail__c trail1 = IPS_TestDataFactory.createJobbspor(participantIdent1);
        Work_Trail__c trail2 = IPS_TestDataFactory.createJobbspor(participantIdent2);
        insert new List<Work_Trail__c>{ trail1, trail2 };

        List<Event> events = new List<Event>();
        Event event1 = IPS_TestDataFactory.createParticipantEventWithOwner(UserInfo.getUserId(), trail1.Id);
        Event event2 = IPS_TestDataFactory.createParticipantEventWithOwner(UserInfo.getUserId(), trail2.Id);
        event1.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Event' AND DeveloperName = 'Ips_uo_Deltakermote'
            LIMIT 1
        ]
        .Id;
        event2.RecordTypeId = event1.RecordTypeId;
        events.add(event1);
        events.add(event2);

        // Act
        Test.startTest();
        Set<Id> extractedWorktrailIds = IPS_EventManagementService.extractWorkTrailIds(events);
        Test.stopTest();

        // Assert
        System.Assert.areEqual(
            new Set<Id>{ trail1.Id, trail2.Id },
            extractedWorktrailIds,
            'extractWorkTrailIds should return all valid WhatIds from events with correct record types'
        );
    }

    @isTest
    private static void createManagerEventsDTO_shouldReturnDTOsForValidEvents() {
        // Arrange
        String participantIdent = '12069755555';
        Work_Trail__c trail = IPS_TestDataFactory.createJobbspor(participantIdent);
        insert trail;

        Event event = IPS_TestDataFactory.createParticipantEventWithOwner(UserInfo.getUserId(), trail.Id);
        event.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Event' AND DeveloperName = 'Ips_uo_Deltakermote'
            LIMIT 1
        ]
        .Id;
        insert event;

        List<Event> events = [
            SELECT
                Id,
                WhatId,
                Subject,
                Owner.Name,
                Owner.Profile.Name,
                Location,
                StartDateTime,
                IPS_Type__c,
                IPS_employerName__c,
                Konto_kontakt__r.Name,
                IPS_participant_related_to_meeting__c,
                RecordType.DeveloperName
            FROM Event
            WHERE Id = :event.Id
        ];

        // Act
        Test.startTest();
        List<IPS_ManagerEvent> dtos = IPS_EventManagementService.createManagerEventsDTO(events);
        Test.stopTest();

        // Assert
        System.Assert.areEqual(1, dtos.size(), 'Should return one DTO for one valid event');
        System.Assert.areEqual(event.Id, dtos[0].eventId, 'DTO eventId should match event');
        System.Assert.areEqual(trail.Id, dtos[0].workTrailId, 'DTO workTrailId should match trail');
    }

    @isTest
    private static void createEmployeeEvent_shouldMapFieldsCorrectly() {
        // Arrange
        String participantIdent = '12069755555';
        Work_Trail__c trail = IPS_TestDataFactory.createJobbspor(participantIdent);
        trail.IPS_Participants_home_address__c = 'Testveien 1';
        insert trail;

        List<Event> eventsToInsert = new List<Event>();

        Event event = IPS_TestDataFactory.createParticipantEventWithOwner(UserInfo.getUserId(), trail.Id);
        event.Subject = 'Testmøte';
        event.Location = 'Testlokasjon';
        event.IPS_Type__c = 'Meeting with Participant';
        event.IPS_participant_related_to_meeting__c = true;
        event.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Event' AND DeveloperName = 'Ips_uo_Deltakermote'
            LIMIT 1
        ]
        .Id;
        eventsToInsert.add(event);
        insert eventsToInsert;

        // Reload with relationships
        Event insertedEvent = [
            SELECT
                Id,
                WhatId,
                Subject,
                Owner.Name,
                Owner.Profile.Name,
                Location,
                StartDateTime,
                IPS_Type__c,
                IPS_employerName__c,
                Konto_kontakt__r.Name,
                IPS_participant_related_to_meeting__c,
                RecordType.DeveloperName
            FROM Event
            WHERE Id = :event.Id
        ];
        Work_Trail__c insertedTrail = [
            SELECT
                Id,
                IPS_Participants_home_address__c,
                ips_Participant__r.INT_PersonIdent__c,
                ips_Participant__r.Name,
                RecordType.DeveloperName
            FROM Work_Trail__c
            WHERE Id = :trail.Id
        ];

        // Act
        Test.startTest();
        List<IPS_ManagerEvent> managerEvents = IPS_EventManagementService.createManagerEventsDTO(events);
        Test.stopTest();

        // Assert
        System.Assert.areEqual(insertedEvent.Id, managerEvents[0].eventId, 'eventId should match');
        System.Assert.areEqual(insertedTrail.Id, managerEvents[0].workTrailId, 'workTrailId should match');
        System.Assert.areEqual('Testmøte', managerEvents[0].subject, 'Subject should be mapped');
        System.Assert.areEqual('Testlokasjon', managerEvents[0].location, 'Location should be mapped');
        System.Assert.areEqual('Testveien 1', managerEvents[0].participantAddress, 'Address should be mapped');
        System.Assert.isTrue(managerEvents[0].isParticipantAttending, 'isParticipantAttending should be true');
    }

    @isTest
    private static void getEventsForCurrentWeek_shouldReturnEventsForEmployees() {
        // Arrange
        String participantIdent = '12069755555';
        Work_Trail__c trail = IPS_TestDataFactory.createJobbspor(participantIdent);
        insert trail;

        Event event = IPS_TestDataFactory.createParticipantEventWithOwner(UserInfo.getUserId(), trail.Id);
        event.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Event' AND DeveloperName = 'Ips_uo_Deltakermote'
            LIMIT 1
        ]
        .Id;
        insert event;

        // Act
        Test.startTest();
        List<IPS_ManagerEvent> dtos = IPS_EventManagementService.getEventsForCurrentWeek();
        Test.stopTest();

        // Assert
        System.Assert.areEqual(1, dtos.size(), 'getEventsForCurrentWeek should return one event for the current user');
        System.Assert.areEqual(event.Id, dtos[0].eventId, 'Returned eventId should match inserted event');
    } */
}
