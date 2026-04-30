/**
 * @Description  : Test class for IPS_eventTravelTimeController. This class contains test methods to validate the functionality of the IPS_eventTravelTimeController, which is responsible for handling travel time calculations for events in the IPS application. The test methods cover scenarios such as creating events with travel time, updating events with travel time, and ensuring that events without travel time are handled correctly.
 * @author      : Ann-Kristin Olsen
 * @author       : Håkon Kavli
 * @since        : 0.531.0
 **/
@isTest
public class IPS_eventTravelTimeControllerTest {
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
            IPS_Status1__c = 'Completed'
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
    static void createEventTravelTime() {
        List<Event> travelTimeList = [SELECT Id FROM Event];
        //List should not be empty
        System.Assert.areNotEqual(0, travelTimeList.size(), 'List should not be empty');
    }

    @isTest
    static void createwithOutTravelTime() {
        List<Event> noEventTravel = [
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
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c <= 0
        ];
        for (Event j : noEventTravel) {
            System.Assert.areEqual(0, j.ips_Travel_time__c, 'No travel time before');
            System.Assert.areEqual(0, j.IPS_travelTimeFrom__c, 'No travel time after');
        }
    }

    @isTest
    static void updateEventTravelTime() {
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
        System.Assert.isFalse(updateEvent.isEmpty(), 'Event list to update should not be empty');
        update eventsToUpdate;
        List<Event> updatedEvents = [
            SELECT Id, StartDateTime
            FROM Event
            WHERE IPS_eventId__c = NULL AND ips_Travel_time__c > 0
        ];
        System.Assert.isFalse(updatedEvents.isEmpty(), 'Updated event list should not be empty');
        for (Event e : updatedEvents) {
            System.Assert.isTrue(e.StartDateTime > System.now(), 'StartDateTime should be shifted forward after update');
        }
    }

    @isTest
    static void updateEventTravelTime1() {
        Event baseEvent = [
            SELECT
                Id,
                ips_Travel_time__c,
                IPS_travelTimeFrom__c,
                StartDateTime,
                EndDateTime,
                OwnerId,
                RecordTypeId,
                IPS_Status1__c
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
        firstInput.recordtypeId = baseEvent.RecordTypeId;
        firstInput.status = baseEvent.IPS_Status1__c;

        Test.startTest();
        IPS_eventTravelTimeController.invokeTravelTime(
            new List<IPS_eventTravelTimeController.evenctRequest>{ firstInput }
        );
        Test.stopTest();

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
}
