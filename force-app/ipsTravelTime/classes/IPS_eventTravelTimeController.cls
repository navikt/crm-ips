/**
 * @description  : Controller class for handling travel time calculations for events in the IPS application. This class contains methods to create and delete travel time events based on the start and end times of the main event, as well as the specified travel time before and after the event. The controller is designed to be invoked from a flow, allowing for seamless integration with the event management process in the IPS application.
 * @author       : Ann-Kristin Olsen
 * @author       : Håkon Kavli
 * @since        : 0.536.0
 * @version      : 0.536.0
 **/
public class IPS_eventTravelTimeController {
    @InvocableMethod(label='IPS Traveltime' description='Create or update traveltime')
    public static void invokeTravelTime(List<evenctRequest> request) {
        //parse inputs and variables
        Datetime eventStartDate = request.get(0).startDate;
        Datetime eventEndDate = request.get(0).endDate;
        Id currentEventId = request.get(0).currentRecord;
        Integer eventTraveltimeBefore = request.get(0).travelTimeBefore;
        Integer eventTraveltimeAfter = request.get(0).travelTimeAfter;
        String eventStatus = request.get(0).status;
        Id eventOwnerId = request.get(0).ownerId;
        Id recordTypeId = request.get(0).recordtypeId;

        if (eventTraveltimeBefore == null || eventTraveltimeBefore <= 0) {
            eventTraveltimeBefore = 0;
        }

        if (eventTraveltimeAfter == null || eventTraveltimeAfter <= 0) {
            eventTraveltimeAfter = 0;
        }
        //delete all travel time
        deleteTravelTime(currentEventId);

        //create travel time
        createTravelTime(
            eventStartDate,
            eventEndDate,
            currentEventId,
            eventTraveltimeBefore,
            eventTraveltimeAfter,
            recordTypeId,
            eventStatus,
            eventOwnerId
        );
    }

    //Input variables from flow
    public class evenctRequest {
        @InvocableVariable(required=true)
        public dateTime startDate;

        @InvocableVariable(required=true)
        public dateTime endDate;

        @InvocableVariable(required=true)
        public Id currentRecord;

        @InvocableVariable
        public Integer travelTimeBefore;

        @InvocableVariable
        public Integer travelTimeAfter;

        @InvocableVariable(required=true)
        public Id ownerId;

        @InvocableVariable(required=true)
        public Id recordtypeId;

        @InvocableVariable(required=true)
        public String status;
    }

    @TestVisible
    private static void createTravelTime(
        dateTime startDate,
        dateTime endDate,
        id currentRecord,
        Integer travelTimeBefore,
        Integer travelTimeAfter,
        Id recordTypeId,
        String eventStatus,
        id ownerId
    ) {
        // If both travel times are 0 or less, do not create any travel time events
        if (travelTimeBefore <= 0 && travelTimeAfter <= 0) {
            return;
        }
        // Calculate start and end times for travel time events
        dateTime startTimeBefore = startDate.addMinutes(-travelTimeBefore);
        dateTime startTimeAfter = startDate;
        dateTime endTimeBefore = endDate;
        dateTime endTimeAfter = endDate.addMinutes(travelTimeAfter);
        List<Event> eventsToInsert = new List<Event>();

        //create before traveltime
        if (travelTimeBefore > 0) {
            Event eBefore = new Event();
            eBefore.StartDateTime = startTimeBefore;
            eBefore.EndDateTime = startTimeAfter;
            eBefore.Subject = 'Reisetid';
            eBefore.Description = 'Traveltime before';
            eBefore.TAG_NoPersonInformation__c = true;
            eBefore.OwnerId = ownerId;
            eBefore.RecordTypeId = recordTypeId;
            eBefore.IPS_eventId__c = currentRecord;
            eBefore.IPS_Status1__c = eventStatus;
            eBefore.Location = 'Reisetid';
            eBefore.IPS_isFromTimeline__c = true;
            eventsToInsert.add(eBefore);
        }

        //create after traveltime
        if (travelTimeAfter > 0) {
            Event eAfter = new Event();
            eAfter.StartDateTime = endTimeBefore;
            eAfter.EndDateTime = endTimeAfter;
            eAfter.Subject = 'Reisetid';
            eAfter.Description = 'Traveltime after';
            eAfter.TAG_NoPersonInformation__c = true;
            eAfter.OwnerId = ownerId;
            eAfter.RecordTypeId = recordTypeId;
            eAfter.IPS_eventId__c = currentRecord;
            eAfter.IPS_Status1__c = eventStatus;
            eAfter.Location = 'Reisetid';
            eAfter.IPS_isFromTimeline__c = true;
            eventsToInsert.add(eAfter);
        }
        if (!eventsToInsert.isEmpty()) {
            CRM_DatabaseOperations cdoInsertEvents = new CRM_DatabaseOperations()
                .setDomain(CRM_ApplicationDomain.Domain.IPS);
            cdoInsertEvents.insertRecords(eventsToInsert);
        }
    }
    @TestVisible
    private static void deleteTravelTime(id currentRecord) {
        List<Event> deleteTravelTime = new List<Event>();
        List<Event> delList = [SELECT Id FROM Event WHERE IPS_eventId__c = :currentRecord WITH SYSTEM_MODE];
        deleteTravelTime.addAll(delList);
        if (deleteTravelTime.size() > 0) {
            CRM_DatabaseOperations cdoDeleteEvents = new CRM_DatabaseOperations()
                .setDomain(CRM_ApplicationDomain.Domain.IPS);
            cdoDeleteEvents.deleteRecords(deleteTravelTime);
        }
    }
}
