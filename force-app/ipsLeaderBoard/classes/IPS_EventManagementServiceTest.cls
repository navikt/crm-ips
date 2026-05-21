/**
 * @description  : Test class for IPS_EventManagementService.
 * @author       : Håkon Kavli
 * @since        : 0.533.0
 * @version      : 0.533.0
 **/
@IsTest
public with sharing class IPS_EventManagementServiceTest {
    private static final String MANAGED_EMPLOYER_EVENT_SUBJECT = 'Managed employer meeting';
    private static final String MANAGED_PARTICIPANT_EVENT_SUBJECT = 'Managed participant meeting';
    private static final String UNMANAGED_EVENT_SUBJECT = 'Unmanaged employer meeting';
    private static final String FUTURE_EVENT_SUBJECT = 'Managed future meeting';
    private static final String EVENT_WITHOUT_WORKTRAIL_SUBJECT = 'Managed no whatId meeting';
    private static final Integer EXPECTED_MANAGED_EVENT_COUNT = 2;

    @TestSetup
    static void makeData() {
        Person__c person = IPS_TestDataFactory.createPerson('12047823564');
        insert person;
        Person__c personWithAccount = [SELECT CRM_Account__c FROM Person__C LIMIT 1];
        Id accountId = personWithAccount.CRM_Account__c;

        Account employer = IPS_TestDataFactory.createEmployerAccount();
        insert employer;
        Work_Trail__C ipsTypeTrail = IPS_TestDataFactory.createJobbspor(accountId);
        ipsTypeTrail.IPS_Participants_home_address__c = 'Eksempelveien 1';
        insert ipsTypeTrail;
        Work_Trail__c uoTypeTrail = IPS_TestDataFactory.createUOJobbspor(accountId);
        insert uoTypeTrail;

        User employeeUser = IPS_TestDataFactory.createInternalUserWithManager(
            'test.employee@nav.no',
            UserInfo.getUserId()
        );
        insert employeeUser;

        List<Event> events = new List<Event>();
        Event eventAssignedToManagersEmployees = IPS_TestDataFactory.createEmployerEventWithParticipant(
            employer.Id,
            employeeUser.Id,
            ipsTypeTrail.Id
        );
        eventAssignedToManagersEmployees.Subject = MANAGED_EMPLOYER_EVENT_SUBJECT;
        events.add(eventAssignedToManagersEmployees);

        Event participantEventAssignedToManagersEmployees = IPS_TestDataFactory.createParticipantEventWithOwner(
            employeeUser.Id,
            uoTypeTrail.Id
        );
        participantEventAssignedToManagersEmployees.Subject = MANAGED_PARTICIPANT_EVENT_SUBJECT;
        events.add(participantEventAssignedToManagersEmployees);

        Event eventAssignedToCurrentUser = IPS_TestDataFactory.createEmployerEventWithParticipant(
            employer.Id,
            UserInfo.getUserId(),
            ipsTypeTrail.Id
        );
        eventAssignedToCurrentUser.Subject = UNMANAGED_EVENT_SUBJECT;
        events.add(eventAssignedToCurrentUser);

        Event eventOutsideCurrentWeek = IPS_TestDataFactory.createEmployerEventWithParticipant(
            employer.Id,
            employeeUser.Id,
            ipsTypeTrail.Id
        );
        eventOutsideCurrentWeek.Subject = FUTURE_EVENT_SUBJECT;
        eventOutsideCurrentWeek.StartDateTime = DateTime.now().addDays(9);
        eventOutsideCurrentWeek.EndDateTime = DateTime.now().addDays(9).addHours(1);
        events.add(eventOutsideCurrentWeek);

        Event eventWithoutWhatId = IPS_TestDataFactory.createEmployerEventWithoutParticipant(employer.Id);
        eventWithoutWhatId.Subject = EVENT_WITHOUT_WORKTRAIL_SUBJECT;
        eventWithoutWhatId.OwnerId = employeeUser.Id;
        events.add(eventWithoutWhatId);

        insert events;
    }

    private static List<Event> getEventsBySubject(Set<String> subjects) {
        return [
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
            WHERE Subject IN :subjects
        ];
    }

    @isTest
    private static void getEventsForEmployeesCurrentWeek_returnsOnlyManagedEventsInCurrentWeek() {
        Test.startTest();
        List<Event> events = IPS_EventManagementService.getEventsForEmployeesCurrentWeek();
        Test.stopTest();

        System.Assert.areEqual(
            EXPECTED_MANAGED_EVENT_COUNT,
            events.size(),
            'Expected only events owned by managed employee in current week'
        );
        Set<String> subjects = new Set<String>();
        for (Event event : events) {
            subjects.add(event.Subject);
        }
        System.Assert.areEqual(
            new Set<String>{ MANAGED_EMPLOYER_EVENT_SUBJECT, MANAGED_PARTICIPANT_EVENT_SUBJECT },
            subjects,
            'Expected exactly the managed employee events in current week'
        );
    }

    @isTest
    private static void extractWorkTrailIds_returnsUniqueWorkTrailIdsForValidEvents() {
        List<Event> events = [
            SELECT Id, WhatId, Subject, RecordType.DeveloperName
            FROM Event
            WHERE
                Subject IN :new Set<String>{
                    MANAGED_EMPLOYER_EVENT_SUBJECT,
                    MANAGED_PARTICIPANT_EVENT_SUBJECT,
                    EVENT_WITHOUT_WORKTRAIL_SUBJECT
                }
        ];
        Event duplicatedManagedEmployerEvent;
        for (Event event : events) {
            if (event.Subject == MANAGED_EMPLOYER_EVENT_SUBJECT) {
                duplicatedManagedEmployerEvent = event;
                break;
            }
        }
        System.Assert.isNotNull(
            duplicatedManagedEmployerEvent,
            'Expected to find managed employer event for duplication'
        );
        events.add(duplicatedManagedEmployerEvent);

        Test.startTest();
        Set<Id> workTrailIds = IPS_EventManagementService.extractWorkTrailIds(events);
        Test.stopTest();

        Set<Id> expectedWorkTrailIds = new Set<Id>();
        for (Event event : events) {
            if (event.WhatId != null && IPS_Utility.EVENT_RECORD_TYPES.contains(event.RecordType.DeveloperName)) {
                expectedWorkTrailIds.add(event.WhatId);
            }
        }
        System.Assert.areEqual(
            expectedWorkTrailIds,
            workTrailIds,
            'Expected unique Work Trail Ids from valid events only'
        );
        System.Assert.areEqual(
            expectedWorkTrailIds.size(),
            workTrailIds.size(),
            'Expected duplicate WhatId values to be deduplicated'
        );
    }

    @isTest
    private static void getRelatedWorkTrailMap_returnsMatchingTrailRecords() {
        List<Work_Trail__c> trails = [SELECT Id FROM Work_Trail__c LIMIT 2];
        Set<Id> trailIds = new Set<Id>{ trails[0].Id, trails[1].Id };

        Test.startTest();
        Map<Id, Work_Trail__c> workTrailMap = IPS_EventManagementService.getRelatedWorkTrailMap(trailIds);
        Test.stopTest();

        System.Assert.areEqual(
            trailIds.size(),
            workTrailMap.size(),
            'Expected all requested Work Trails to be returned'
        );
        System.Assert.isTrue(workTrailMap.containsKey(trails[0].Id), 'Expected first Work Trail to be in map');
        System.Assert.isTrue(workTrailMap.containsKey(trails[1].Id), 'Expected second Work Trail to be in map');
    }

    @isTest
    private static void createManagerEventsDTO_returnsOnlyEventsWithSupportedWorkTrailRecordType() {
        List<Event> events = getEventsBySubject(
            new Set<String>{
                MANAGED_EMPLOYER_EVENT_SUBJECT,
                MANAGED_PARTICIPANT_EVENT_SUBJECT,
                EVENT_WITHOUT_WORKTRAIL_SUBJECT
            }
        );

        Test.startTest();
        List<IPS_ManagerEvent> managerEvents = IPS_EventManagementService.createManagerEventsDTO(events);
        Test.stopTest();

        Set<String> returnedSubjects = new Set<String>();
        for (IPS_ManagerEvent managerEvent : managerEvents) {
            returnedSubjects.add(managerEvent.subject);
        }
        System.Assert.areEqual(
            EXPECTED_MANAGED_EVENT_COUNT,
            managerEvents.size(),
            'Expected only events with supported Work Trail to be transformed'
        );
        System.Assert.areEqual(
            new Set<String>{ MANAGED_EMPLOYER_EVENT_SUBJECT, MANAGED_PARTICIPANT_EVENT_SUBJECT },
            returnedSubjects,
            'Expected DTOs for supported Work Trail events only'
        );
    }

    @isTest
    private static void createEmployeeEvent_mapsFields() {
        Event managedEvent = getEventsBySubject(new Set<String>{ MANAGED_EMPLOYER_EVENT_SUBJECT })[0];
        Work_Trail__c relatedWorkTrail = [
            SELECT
                Id,
                IPS_Participants_home_address__c,
                ips_Participant__r.INT_PersonIdent__c,
                ips_Participant__r.Name,
                RecordType.DeveloperName
            FROM Work_Trail__c
            WHERE Id = :managedEvent.WhatId
            LIMIT 1
        ];

        Test.startTest();
        IPS_ManagerEvent managerEvent = IPS_EventManagementService.createEmployeeEvent(managedEvent, relatedWorkTrail);
        Test.stopTest();

        System.Assert.areEqual(managedEvent.Id, managerEvent.eventId, 'Expected event Id to be mapped');
        System.Assert.areEqual(managedEvent.WhatId, managerEvent.workTrailId, 'Expected Work Trail Id to be mapped');
        System.Assert.areEqual(managedEvent.Subject, managerEvent.subject, 'Expected subject to be mapped');
        System.Assert.areEqual(
            relatedWorkTrail.IPS_Participants_home_address__c,
            managerEvent.participantAddress,
            'Expected participant address to be mapped'
        );
        System.Assert.isNotNull(managerEvent.startTime, 'Expected formatted start time');
        System.Assert.isNotNull(managerEvent.employeeName, 'Expected employee name');
    }

    @isTest
    private static void createEmployeeEvent_usesFallbackValuesWhenFieldsAreNull() {
        Event fallbackEvent = getEventsBySubject(new Set<String>{ MANAGED_EMPLOYER_EVENT_SUBJECT })[0];
        fallbackEvent.Location = null;
        fallbackEvent.IPS_employerName__c = null;
        fallbackEvent.Konto_kontakt__c = null;
        Work_Trail__c fallbackWorkTrail = [
            SELECT Id, IPS_Participants_home_address__c, ips_Participant__c
            FROM Work_Trail__c
            WHERE Id = :fallbackEvent.WhatId
            LIMIT 1
        ];
        fallbackWorkTrail.IPS_Participants_home_address__c = null;
        fallbackWorkTrail.ips_Participant__c = null;
        Test.startTest();
        IPS_ManagerEvent managerEventWithFallbacks = IPS_EventManagementService.createEmployeeEvent(
            fallbackEvent,
            fallbackWorkTrail
        );
        Test.stopTest();

        System.Assert.areEqual(
            'Sted ikke oppgitt',
            managerEventWithFallbacks.location,
            'Expected fallback location value'
        );
        System.Assert.areEqual(
            'Arbeidsgiver ikke oppgitt',
            managerEventWithFallbacks.accountName,
            'Expected fallback account value'
        );
        System.Assert.areEqual(
            'Navn ikke oppgitt',
            managerEventWithFallbacks.accountContactName,
            'Expected fallback contact value'
        );
        System.Assert.areEqual(
            'Fødselsnummer ikke oppgitt',
            managerEventWithFallbacks.participantIdent,
            'Expected fallback participant ident value'
        );
        System.Assert.areEqual(
            'Navn ikke oppgitt',
            managerEventWithFallbacks.participantName,
            'Expected fallback participant name value'
        );
        System.Assert.areEqual(
            'Adresse ikke oppgitt',
            managerEventWithFallbacks.participantAddress,
            'Expected fallback participant address value'
        );
    }

    @isTest
    private static void getEventsForCurrentWeek_returnsManagerDtosForManagedEmployeeEvents() {
        Test.startTest();
        List<IPS_ManagerEvent> managerEvents = IPS_EventManagementService.getEventsForCurrentWeek();
        Test.stopTest();

        Set<String> subjects = new Set<String>();
        for (IPS_ManagerEvent managerEvent : managerEvents) {
            subjects.add(managerEvent.subject);
        }

        System.Assert.areEqual(
            EXPECTED_MANAGED_EVENT_COUNT,
            managerEvents.size(),
            'Expected DTOs for managed employee events in current week'
        );
        System.Assert.areEqual(
            new Set<String>{ MANAGED_EMPLOYER_EVENT_SUBJECT, MANAGED_PARTICIPANT_EVENT_SUBJECT },
            subjects,
            'Expected manager DTO subjects to match managed employee events'
        );
    }
}
