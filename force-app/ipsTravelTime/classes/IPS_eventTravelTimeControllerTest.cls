/**
 * @Description  : Test class for IPS_eventTravelTimeController. This class contains test methods to validate the functionality of the IPS_eventTravelTimeController, which is responsible for handling travel time calculations for events in the IPS application. The test methods cover scenarios such as creating events with travel time, updating events with travel time, and ensuring that events without travel time are handled correctly.
 * @author       : Ann-Kristin Olsen
 * @author       : Håkon Kavli
 * @since        : 0.536.0
 **/
@isTest
public class IPS_eventTravelTimeControllerTest {
    public static final Id TRAVEL_TIME_RECORD_ID = SObjectType.Event.getRecordTypeInfosByDeveloperName()
        .get('IPS_Traveltime')
        .getRecordTypeId();

    @TestSetup
    static void makeTrailData() {
        List<Account> accountsToInsert = new List<Account>();
        Account businessAccount = new Account();
        businessAccount.Name = 'Røre Pinne';
        businessAccount.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('IPS_UO_account_recordpage')
            .getRecordTypeId();
        accountsToInsert.add(businessAccount);

        Account personAccount = new Account();
        personAccount.FirstName = 'Petter';
        personAccount.LastName = 'Putte';
        personAccount.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();

        accountsToInsert.add(personAccount);
        insert accountsToInsert;

        Work_Trail__c trail = new Work_Trail__c(
            ips_Participant__c = personAccount.Id,
            ips_Status__c = 'Referred',
            ips_Passive__c = false
        );
        insert trail;

        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        List<Event> eventsToInsert = new List<Event>();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            WhatId = personAccount.Id,
            RelatedToAccount__c = businessAccount.Id,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addMinutes(60),
            Subject = 'Møte med Arbeidsgiver',
            IPS_isFromTimeline__c = true,
            IPS_Type__c = 'Meeting with Employer',
            ips_Subcategory_Type_IPS__c = 'Job support',
            ips_Subcategory_Type__c = 'Job support',
            IPS_Subcategory_Type_UO__c = 'Follow-up',
            F_rste_arbeIdsgiverm_te__c = 'Nei',
            Location = 'Fysisk oppmøte',
            Description = 'Møte',
            IPS_Status1__c = 'Open'
        );
        Event createEvent2 = new Event(
            ips_Travel_time__c = 0,
            RelatedToAccount__c = businessAccount.Id,
            WhatId = personAccount.Id,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 0,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addMinutes(60),
            Subject = 'Møte med Arbeidsgiver',
            IPS_isFromTimeline__c = true,
            IPS_Type__c = 'Meeting with Employer',
            ips_Subcategory_Type_IPS__c = 'Job support',
            ips_Subcategory_Type__c = 'Job support',
            IPS_Subcategory_Type_UO__c = 'Follow-up',
            F_rste_arbeIdsgiverm_te__c = 'Nei',
            Location = 'Fysisk oppmøte',
            Description = 'Møte',
            IPS_Status1__c = 'Open'
        );
        eventsToInsert.add(createEvent);
        eventsToInsert.add(createEvent2);
        insert eventsToInsert;
    }

    @isTest
    static void createWithoutTravelTime() {
        // Given
        Event baseEvent = [
            SELECT Id, StartDateTime, EndDateTime, OwnerId, IPS_Status1__c
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c <= 0
            LIMIT 1
        ];

        IPS_eventTravelTimeController.evenctRequest req = new IPS_eventTravelTimeController.evenctRequest();
        req.startDate = baseEvent.StartDateTime;
        req.endDate = baseEvent.EndDateTime;
        req.currentRecord = baseEvent.Id;
        req.travelTimeBefore = 0;
        req.travelTimeAfter = 0;
        req.ownerId = baseEvent.OwnerId;
        req.recordtypeId = TRAVEL_TIME_RECORD_ID;
        req.status = baseEvent.IPS_Status1__c;

        // When
        Test.startTest();
        IPS_eventTravelTimeController.invokeTravelTime(new List<IPS_eventTravelTimeController.evenctRequest>{ req });
        Test.stopTest();

        // Then
        List<Event> travelTimeEvents = [SELECT Id FROM Event WHERE IPS_eventId__c = :baseEvent.Id];
        System.Assert.isTrue(
            travelTimeEvents.isEmpty(),
            'Expected no travel time events to be created when travel time is 0 or less'
        );
    }

    @isTest
    static void updateEventTravelTimeUnitTest() {
        // Given
        Event baseEvent = [
            SELECT Id, ips_Travel_time__c, IPS_travelTimeFrom__c, StartDateTime, EndDateTime, OwnerId, IPS_Status1__c
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c > 0
            LIMIT 1
        ];

        IPS_eventTravelTimeController.evenctRequest firstInput = new IPS_eventTravelTimeController.evenctRequest();
        firstInput.startDate = baseEvent.StartDateTime;
        firstInput.endDate = baseEvent.EndDateTime;
        firstInput.currentRecord = baseEvent.Id;
        firstInput.travelTimeBefore = Integer.valueOf(baseEvent.ips_Travel_time__c);
        firstInput.travelTimeAfter = Integer.valueOf(baseEvent.IPS_travelTimeFrom__c);
        firstInput.ownerId = baseEvent.OwnerId;
        firstInput.recordtypeId = TRAVEL_TIME_RECORD_ID;
        firstInput.status = baseEvent.IPS_Status1__c;

        // When
        Test.startTest();
        IPS_eventTravelTimeController.invokeTravelTime(
            new List<IPS_eventTravelTimeController.evenctRequest>{ firstInput }
        );
        Test.stopTest();

        // Then - > Verify that travel time events were created with correct values
        List<Event> travelTimeEvents = [
            SELECT Id, Subject, IPS_eventId__c
            FROM Event
            WHERE IPS_eventId__c = :baseEvent.Id
        ];
        System.Assert.isFalse(travelTimeEvents.isEmpty(), 'Travel time events should have been created');
        for (Event e : travelTimeEvents) {
            System.Assert.areEqual('Reisetid', e.Subject, 'Travel time event subject should be Reisetid');
            System.Assert.areEqual(baseEvent.Id, e.IPS_eventId__c, 'Travel time event should reference the base event');
        }
    }

    @isTest
    static void updateEventTravelTimeIntegrationTest() {
        // Given
        List<Event> eventsToUpdate = new List<Event>();

        List<Event> updateEvent = [
            SELECT
                Id,
                ips_Travel_time__c,
                IPS_travelTimeFrom__c,
                StartDateTime,
                EndDateTime,
                Subject,
                Description,
                IPS_Type__c,
                ips_Subcategory_Type_IPS__c,
                WhatId,
                IPS_eventId__c,
                IPS_Status1__c
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c > 0
        ];
        for (Event i : updateEvent) {
            i.StartDateTime = i.StartDateTime.addMinutes(120);
            i.EndDateTime = i.EndDateTime.addMinutes(120);
            eventsToUpdate.add(i);
        }

        // When
        Test.startTest();
        update eventsToUpdate;
        Test.stopTest();

        // Then - > Verify that the StartDateTime and EndDateTime of the events have been updated correctly
        List<Event> updatedEvents = [
            SELECT Id, StartDateTime
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c > 0
        ];
        System.Assert.isFalse(updateEvent.isEmpty(), 'Event list to update should not be empty');
        System.Assert.isFalse(updatedEvents.isEmpty(), 'Updated event list should not be empty');
        for (Event e : updatedEvents) {
            System.Assert.isTrue(
                e.StartDateTime > System.now(),
                'StartDateTime should be shifted forward after update'
            );
        }
    }

    @isTest
    static void createFromCalendarWithTravelTime() {
        // Given — event created from calendar (IPS_isFromTimeline__c = false)
        Account businessAccount = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'IPS_UO_account_recordpage'
            LIMIT 1
        ];
        Account personAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];

        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Test.startTest();
        Event calendarEvent = new Event(
            ips_Travel_time__c = 10,
            IPS_travelTimeFrom__c = 15,
            WhatId = personAccount.Id,
            RelatedToAccount__c = businessAccount.Id,
            RecordTypeId = devRecordTypeId,
            StartDateTime = System.Datetime.now().addDays(1),
            EndDateTime = System.Datetime.now().addDays(1).addMinutes(60),
            Subject = 'Kalender-møte',
            IPS_isFromTimeline__c = false,
            IPS_Status1__c = 'Open',
            ips_Subcategory_Type_IPS__c = 'Job support'
        );
        insert calendarEvent;
        test.stopTest();
        // Then
        List<Event> travelTimeEvents = [
            SELECT Id, Subject
            FROM Event
            WHERE IPS_eventId__c = :calendarEvent.Id AND RecordTypeId = :TRAVEL_TIME_RECORD_ID
        ];
        System.Assert.isFalse(
            travelTimeEvents.isEmpty(),
            'Expected travel time events to be created for calendar event'
        );
        for (Event e : travelTimeEvents) {
            System.Assert.areEqual('Reisetid', e.Subject, 'Travel time subject should be Reisetid');
        }
    }

    @isTest
    static void createFromCalendarWithoutTravelTimeCreatesNoEvents() {
        // Given — calendar event with no travel time
        Account businessAccount = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'IPS_UO_account_recordpage'
            LIMIT 1
        ];
        Account personAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];

        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event calendarEvent = new Event(
            ips_Travel_time__c = 0,
            IPS_travelTimeFrom__c = 0,
            WhatId = personAccount.Id,
            RelatedToAccount__c = businessAccount.Id,
            RecordTypeId = devRecordTypeId,
            StartDateTime = System.Datetime.now().addDays(1),
            EndDateTime = System.Datetime.now().addDays(1).addMinutes(60),
            Subject = 'Kalender-møte uten reisetid',
            IPS_isFromTimeline__c = false,
            IPS_Status1__c = 'Open',
            ips_Subcategory_Type_IPS__c = 'Job support'
        );

        // When
        Test.startTest();
        insert calendarEvent;
        Test.stopTest();

        // Then — flow entry criteria should filter this out
        List<Event> travelTimeEvents = [SELECT Id FROM Event WHERE IPS_eventId__c = :calendarEvent.Id];
        System.Assert.isTrue(
            travelTimeEvents.isEmpty(),
            'Expected no travel time events when both travel time values are 0'
        );
    }

    @isTest
    static void deleteTravelTimeEventsOnEventDelete() {
        // Given
        Event baseEvent = [
            SELECT
                Id,
                ips_Travel_time__c,
                IPS_travelTimeFrom__c,
                StartDateTime,
                EndDateTime,
                Subject,
                Description,
                IPS_Type__c,
                ips_Subcategory_Type_IPS__c,
                WhatId,
                IPS_eventId__c,
                IPS_Status1__c,
                OwnerId
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c > 0
            LIMIT 1
        ];

        IPS_eventTravelTimeController.evenctRequest req = new IPS_eventTravelTimeController.evenctRequest();
        req.startDate = baseEvent.StartDateTime;
        req.endDate = baseEvent.EndDateTime;
        req.currentRecord = baseEvent.Id;
        req.travelTimeBefore = Integer.valueOf(baseEvent.ips_Travel_time__c);
        req.travelTimeAfter = Integer.valueOf(baseEvent.IPS_travelTimeFrom__c);
        req.ownerId = baseEvent.OwnerId;
        req.recordtypeId = TRAVEL_TIME_RECORD_ID;
        req.status = baseEvent.IPS_Status1__c;
        IPS_eventTravelTimeController.invokeTravelTime(new List<IPS_eventTravelTimeController.evenctRequest>{ req });

        List<Event> travelTimeEvents = [
            SELECT Id
            FROM Event
            WHERE IPS_eventId__c = :baseEvent.Id
        ];
        // Pre-assert to ensure that travel time events exist before deletion
        System.Assert.isFalse(travelTimeEvents.isEmpty(), 'There should have been travel time events to delete');

        // When
        Test.startTest();
        IPS_eventTravelTimeController.deleteTravelTime(baseEvent.Id);
        Test.stopTest();

        // Then
        List<Event> remainingTravelTimeEvents = [
            SELECT Id
            FROM Event
            WHERE IPS_eventId__c = :baseEvent.Id
        ];

        System.Assert.isTrue(
            remainingTravelTimeEvents.isEmpty(),
            'Expected all travel time events to be deleted when the base event is deleted'
        );
    }
}
