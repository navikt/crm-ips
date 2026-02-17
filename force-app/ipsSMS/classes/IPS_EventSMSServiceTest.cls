/**
 * @description  : Test class for IPS_EventSMSService
 * @author       : Carl Huseby Fosli
 * @since        : Version 0.1
 * @author       : Håkon Kavli
 * @since        : 0.522.0
 * @version      : 0.2
 * @see          : IPS_EventSMSService
 **/
@IsTest
public with sharing class IPS_EventSMSServiceTest {
    @IsTest
    public static void createTestData() {
        List<Account> accountsInTest = new List<Account>();
        Map<Id, Account> accountsByAccountIds = new Map<Id, Account>();

        // Create Persons
        List<Person__c> persons = new List<Person__c>();
        persons.add(IPS_TestDataFactory.createPerson('G54321'));
        persons.add(IPS_TestDataFactory.createPerson('G54322'));

        insert persons;

        List<Work_trail__c> workTrails = new List<Work_Trail__c>();

        // Create Work Trails
        for (Account personAccounts : [SELECT Id, PersonContactId FROM Account WHERE CRM_Person__c IN :persons]) {
            Work_Trail__c workTrail = IPS_TestDataFactory.createJobbspor(personAccounts.Id);
            workTrails.add(workTrail);
            accountsByAccountIds.put(personAccounts.Id, personAccounts);
        }

        insert workTrails;

        // Create Events
        List<Event> eventList = new List<Event>();
        for (Work_Trail__c workTrail : workTrails) {
            System.Assert.isNotNull(
                accountsByAccountIds.get(workTrail.ips_Participant__c).PersonContactId,
                'PersonContactId should not be null'
            );
            Event eventRecord = IPS_TestDataFactory.createParticipantEvent(
                accountsByAccountIds.get(workTrail.ips_Participant__c).PersonContactId,
                workTrail.Id
            );
            // Ensure SMS flags are false initially
            eventRecord.IPS_isCreatedSMSSendt__c = false;
            eventRecord.IPS_isReminderSMSSendt__c = false;
            eventList.add(eventRecord);
        }
        insert eventList;

        System.Assert.isNotNull(persons, 'Persons should be created for testing');
        System.Assert.isNotNull(workTrails, 'Work Trails should be created for testing');
        System.Assert.isNotNull(eventList, 'Events should be created for testing');
    }

    @IsTest
    public static void formatTimePeriodTest() {
        // Given
        Datetime startDateTime1 = Datetime.newInstance(2025, 11, 23, 14, 30, 0);
        Datetime startDateTime2 = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        // When
        String formattedTime1 = IPS_EventSMSService.formatTimePeriod(startDateTime1);
        String formattedTime2 = IPS_EventSMSService.formatTimePeriod(startDateTime2);

        // Then
        System.Assert.areEqual(
            formattedTime1,
            '23.11.2025, kl 14:30',
            'Expected formatted time period to be "23.11.2025, kl 14:30"'
        );
        System.Assert.isTrue(
            formattedTime2 == '01.01.2026, kl 09:00',
            'Expected formatted time period to be "01.01.2026, kl 09:00'
        );
    }

    @IsTest
    public static void setLocationTest() {
        // Given
        Event eventWithLocation = new Event(Location = 'Oslo Office, Meeting Room 123');
        Event eventWithChannel = new Event(ips_uo_Kanal__c = 'Video Call via Teams');
        Event eventWithNeither = new Event();

        // When
        String location1 = IPS_EventSMSService.setLocation(eventWithLocation);
        String location2 = IPS_EventSMSService.setLocation(eventWithChannel);
        String location3 = IPS_EventSMSService.setLocation(eventWithNeither);

        // Then
        System.Assert.areEqual(
            location1,
            'Oslo Office, Meeting Room 123',
            'Expected Location to be set from Event.Location'
        );
        System.Assert.areEqual(
            location2,
            'Video Call via Teams',
            'Expected Location to be set from Event.ips_uo_Kanal__c'
        );
        System.Assert.areEqual(
            location3,
            'Ikke oppgitt',
            'Expected Location to be "Ikke oppgitt" when neither field is set'
        );
    }

    @IsTest
    public static void constructCreatedMessageTest() {
        // Given
        Event testEvent = new Event(
            ips_uo_Kanal__c = 'Fysisk',
            StartDateTime = Datetime.newInstance(2025, 12, 5, 10, 0, 0)
        );

        // When
        String createdMessage = IPS_EventSMSService.constructCreatedMessage(testEvent);

        // Then
        System.Assert.isTrue(
            createdMessage.contains('Det er satt opp et fysisk møte med jobbspesialisten din.'),
            'Created message should contain the correct meeting setup text'
        );
        System.Assert.isTrue(
            createdMessage.contains('Tidspunkt: 05.12.2025, kl 10:00'),
            'Created message should contain the correctly formatted date and time'
        );
        System.Assert.isTrue(
            createdMessage.contains('Logg inn på NAV for detaljer. Du kan ikke svare på denne meldingen.'),
            'Created message should inform that replies are not possible'
        );
    }

    @IsTest
    public static void constructReminderMessageTest() {
        // Given
        Event testEvent = new Event(
            ips_uo_Kanal__c = 'Fysisk',
            StartDateTime = Datetime.newInstance(2025, 12, 5, 10, 0, 0)
        );

        // When
        String reminderMessage = IPS_EventSMSService.constructReminderMessage(testEvent);

        // Then
        System.Assert.isTrue(
            reminderMessage.contains('Husk møte med jobbspesialisten din.'),
            'Reminder message should contain the correct reminder text'
        );
        System.Assert.isTrue(
            reminderMessage.contains('Tidspunkt: 05.12.2025, kl 10:00'),
            'Reminder message should contain the correctly formatted date and time'
        );
        System.Assert.isTrue(
            reminderMessage.contains('Logg inn på NAV for detaljer.'),
            'Reminder message should prompt to log in for details'
        );
        System.Assert.isTrue(
            reminderMessage.contains('Du kan ikke svare på denne meldingen.'),
            'Reminder message should inform that replies are not possible'
        );
    }
    @IsTest
    public static void getMinutesUntilNextSMSBatchTest() {
        // Given
        Long minutes = IPS_EventSMSService.getMinutesUntilNextSMSBatch();

        // Then
        System.Assert.isInstanceOfType(minutes, Long.class, 'Expected minutes to be of type Long');
        System.Assert.isNotNull(minutes, 'Expected minutes to be not null');
        System.Assert.isTrue(minutes > 0, 'Minutes until next SMS batch should be greater than 0');
    }

    @IsTest
    public static void createEventSMSWrapperTest() {
        // Given
        createTestData();
        List<Event> events = [SELECT Id, StartDateTime, Location, ips_uo_Kanal__c, WhatId FROM Event LIMIT 2];

        // When
        IPS_EventSMSService.EventSMSWrapper createdWrapper = IPS_EventSMSService.createEventSMSWrapper(
            events,
            IPS_EventSMSService.SMSType.CREATED
        );
        IPS_EventSMSService.EventSMSWrapper reminderWrapper = IPS_EventSMSService.createEventSMSWrapper(
            events,
            IPS_EventSMSService.SMSType.REMINDER
        );
        IPS_EventSMSService.EventSMSWrapper changedWrapper = IPS_EventSMSService.createEventSMSWrapper(
            events,
            IPS_EventSMSService.SMSType.CHANGED
        );

        // Then
        System.Assert.isNotNull(reminderWrapper, 'Expected EventSMSWrapper to be not null');
        System.Assert.isNotNull(createdWrapper, 'Expected EventSMSWrapper to be not null');
        System.Assert.isNotNull(changedWrapper, 'Expected EventSMSWrapper to be not null');

        System.Assert.isInstanceOfType(
            createdWrapper.eventList,
            List<Event>.class,
            'Expected eventList to be of type List<Event>'
        );
        System.Assert.isInstanceOfType(
            reminderWrapper.eventList,
            List<Event>.class,
            'Expected eventList to be of type List<Event>'
        );
        System.Assert.isInstanceOfType(
            changedWrapper.eventList,
            List<Event>.class,
            'Expected eventList to be of type List<Event>'
        );

        System.Assert.isInstanceOfType(
            createdWrapper.smsType,
            IPS_EventSMSService.SMSType.class,
            'Expected smsType to be of type SMSType'
        );
        System.Assert.isInstanceOfType(
            reminderWrapper.smsType,
            IPS_EventSMSService.SMSType.class,
            'Expected smsType to be of type SMSType'
        );
        System.Assert.isInstanceOfType(
            changedWrapper.smsType,
            IPS_EventSMSService.SMSType.class,
            'Expected smsType to be of type SMSType'
        );

        System.Assert.areEqual(
            createdWrapper.smsList.size(),
            events.size(),
            'Expected number of SMS records to match number of Events'
        );
        System.Assert.areEqual(
            reminderWrapper.smsList.size(),
            events.size(),
            'Expected number of SMS records to match number of Events'
        );
        System.Assert.areEqual(
            changedWrapper.smsList.size(),
            events.size(),
            'Expected number of SMS records to match number of Events'
        );
    }

    @IsTest
    public static void getEventWorkTailMapTest() {
        // Given
        createTestData();
        List<Event> events = [SELECT Id, WhatId FROM Event LIMIT 2];

        // When
        Map<Event, Work_Trail__c> eventWorkTrailMap = IPS_EventSMSService.getWorktrailByEventMap(events);

        // Then
        System.Assert.isNotNull(eventWorkTrailMap, 'Expected eventWorkTrailMap to be not null');
        System.Assert.areEqual(
            eventWorkTrailMap.values().size(),
            events.size(),
            'Expected eventWorkTrailMap size to match number of Events'
        );
        for (Work_Trail__c workTrail : eventWorkTrailMap.values()) {
            System.Assert.isNotNull(workTrail, 'Expected Work_Trail__c to be not null');
        }
    }

    @IsTest
    public static void createdSMSIntegrationTest() {
        // Given
        createTestData();
        Map<Id, Event> eventsPriorMap = new Map<Id, Event>();
        Map<Id, Boolean> createdSentFlagByEventId = new Map<Id, Boolean>();

        for (Event eventPrior : [
            SELECT
                Id,
                StartDateTime,
                Location,
                ips_uo_Kanal__c,
                WhatId,
                IPS_IsCreatedSMSSendt__c,
                IPS_IsReminderSMSSendt__c
            FROM Event
            LIMIT 2
        ]) {
            eventPrior.IPS_IsCreatedSMSSendt__c = false;
            createdSentFlagByEventId.put(eventPrior.Id, eventPrior.IPS_IsReminderSMSSendt__c);
            eventsPriorMap.put(eventPrior.Id, eventPrior);
        }
        update eventsPriorMap.values();

        // When
        Test.startTest();
        IPS_EventSMSService.createSMS(eventsPriorMap.values());
        Test.stopTest();

        // Then
        List<SMS__c> createdSMSMessages = [
            SELECT Id, Message__c, EventId__c, Status__c
            FROM SMS__c
            WHERE EventId__c IN :eventsPriorMap.keySet()
        ];
        System.Assert.areEqual(
            createdSMSMessages.size(),
            eventsPriorMap.size(),
            'Expected number of sent SMS records to match number of Events created'
        );
        for (SMS__c sms : createdSMSMessages) {
            System.Assert.areEqual('Could not send', sms.Status__c, 'Expected SMS status to be "Could not send"');
        }
        // Verify that the IPS_IsCreatedSMSSendt__c field is updated
        List<Event> updatedEvents = [
            SELECT Id, IPS_IsCreatedSMSSendt__c, IPS_IsReminderSMSSendt__c
            FROM Event
            WHERE Id IN :eventsPriorMap.keySet()
        ];
        for (Event eventAfter : updatedEvents) {
            System.Assert.areNotEqual(
                createdSentFlagByEventId.get(eventAfter.Id),
                eventAfter.IPS_IsCreatedSMSSendt__c,
                'Did not expect IPS_IsCreatedSMSSendt__c to match after update'
            );
            System.Assert.isTrue(
                eventAfter.IPS_IsCreatedSMSSendt__c,
                'Expected IPS_IsCreatedSMSSendt__c to be true for the Event'
            );
            System.Assert.isFalse(
                eventAfter.IPS_IsReminderSMSSendt__c,
                'Expected IPS_IsReminderSMSSendt__c to be false for the Event'
            );
        }
    }
    @IsTest
    public static void reminderSMSIntegrationTest() {
        // Given
        createTestData();
        Map<Id, Event> eventsPriorMap = new Map<Id, Event>();
        Map<Id, Boolean> reminderSentFlagByEventId = new Map<Id, Boolean>();

        for (Event eventPrior : [
            SELECT
                Id,
                StartDateTime,
                Location,
                ips_uo_Kanal__c,
                WhatId,
                IPS_IsCreatedSMSSendt__c,
                IPS_IsReminderSMSSendt__c
            FROM Event
            LIMIT 2
        ]) {
            eventPrior.IPS_IsReminderSMSSendt__c = false;
            reminderSentFlagByEventId.put(eventPrior.Id, eventPrior.IPS_IsReminderSMSSendt__c);
            eventsPriorMap.put(eventPrior.Id, eventPrior);
        }
        update eventsPriorMap.values();

        // When
        Test.startTest();
        IPS_EventSMSService.reminderSMS(eventsPriorMap.values());
        Test.stopTest();

        // Then
        List<SMS__c> createdSMSMessages = [
            SELECT Id, Message__c, EventId__c, Status__c
            FROM SMS__c
            WHERE EventId__c IN :eventsPriorMap.keySet()
        ];
        System.Assert.areEqual(
            createdSMSMessages.size(),
            eventsPriorMap.size(),
            'Expected number of sent SMS records to match number of Events created'
        );
        for (SMS__c sms : createdSMSMessages) {
            System.Assert.areEqual('Could not send', sms.Status__c, 'Expected SMS status to be "Could not send"');
        }

        // Verify that the IPS_IsCreatedSMSSendt__c field is updated
        for (Event eventAfter : [
            SELECT Id, IPS_IsCreatedSMSSendt__c, IPS_IsReminderSMSSendt__c
            FROM Event
            WHERE Id IN :eventsPriorMap.keySet()
        ]) {
            System.Assert.areEqual(
                eventsPriorMap.get(eventAfter.Id).IPS_IsCreatedSMSSendt__c,
                eventAfter.IPS_IsCreatedSMSSendt__c,
                'Epected IPS_IsCreatedSMSSendt__c to match after update'
            );
            System.Assert.isFalse(
                eventAfter.IPS_IsCreatedSMSSendt__c,
                'Expected IPS_IsCreatedSMSSendt__c to be false for the Event'
            );
            System.Assert.isTrue(
                eventAfter.IPS_IsReminderSMSSendt__c,
                'Expected IPS_IsReminderSMSSendt__c to be true for the Event'
            );
            System.Assert.isFalse(
                reminderSentFlagByEventId.get(eventAfter.Id),
                'Expected prior IPS_IsReminderSMSSendt__c status to be false for the Event'
            );
            System.Assert.areNotEqual(
                reminderSentFlagByEventId.get(eventAfter.Id),
                eventAfter.IPS_IsReminderSMSSendt__c,
                'Did not expect IPS_IsReminderSMSSendt__c to match after update'
            );
        }
    }

    @IsTest
    public static void changedSMSIntegrationTest() {
        // Given
        createTestData();
        Map<Id, Event> eventsPriorMap = new Map<Id, Event>();
        Map<Id, Boolean> changeFlagByEventId = new Map<Id, Boolean>();

        for (Event eventPrior : [
            SELECT Id, StartDateTime, Location, ips_uo_Kanal__c, WhatId, IPS_IsSendChangeSMS__c
            FROM Event
            LIMIT 2
        ]) {
            eventPrior.IPS_IsSendChangeSMS__c = true;
            changeFlagByEventId.put(eventPrior.Id, eventPrior.IPS_IsSendChangeSMS__c);
            eventsPriorMap.put(eventPrior.Id, eventPrior);
        }
        update eventsPriorMap.values();

        // When
        Test.startTest();
        IPS_EventSMSService.changeSMS(eventsPriorMap.values());
        Test.stopTest();

        // Then
        List<SMS__c> createdSMSMessages = [
            SELECT Id, Message__c, EventId__c, Status__c
            FROM SMS__c
            WHERE EventId__c IN :eventsPriorMap.keySet()
        ];
        System.Assert.areEqual(
            createdSMSMessages.size(),
            eventsPriorMap.size(),
            'Expected number of sent SMS records to match number of Events created'
        );
        for (SMS__c sms : createdSMSMessages) {
            System.Assert.areEqual('Could not send', sms.Status__c, 'Expected SMS status to be "Could not send"');
        }

        // Verify that the IPS_IsSendChangeSMS__c field is updated to false
        List<Event> updatedEvents = [
            SELECT Id, IPS_IsSendChangeSMS__c
            FROM Event
            WHERE Id IN :eventsPriorMap.keySet()
        ];
        for (Event eventAfter : updatedEvents) {
            System.Assert.isFalse(
                eventAfter.IPS_IsSendChangeSMS__c,
                'Expected IPS_IsSendChangeSMS__c to be false for the Event'
            );
            System.Assert.isTrue(
                changeFlagByEventId.get(eventAfter.Id),
                'Expected prior IPS_IsSendChangeSMS__c status to be true for the Event'
            );
            System.Assert.areNotEqual(
                changeFlagByEventId.get(eventAfter.Id),
                eventAfter.IPS_IsSendChangeSMS__c,
                'Did not expect IPS_IsSendChangeSMS__c to match after update'
            );
        }
    }
}
