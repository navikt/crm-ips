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
        
        if (eventTraveltimeBefore <= 0 || eventTraveltimeBefore == null) {
            eventTraveltimeBefore = 0;
        }

        if (eventTraveltimeAfter <= 0 || eventTraveltimeAfter == null) {
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
        dateTime startTimeBefore = startDate.addMinutes(-travelTimeBefore);
        dateTime startTimeAfter = startDate;
        dateTime endTimeBefore = endDate;
        dateTime endTimeAfter = endDate.addMinutes(travelTimeAfter);

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
            eBefore.Location ='Reisetid';
            eBefore.IPS_isFromTimeline__c = true;
            insert eBefore;
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
            eAfter.Location ='Reisetid';
            eAfter.IPS_isFromTimeline__c = true;
            insert eAfter;
        }
    }
    
    private static void deleteTravelTime(id currentRecord){
        List<SObject> deleteTravelTime = new List<Event>();
        List<sObject> delList = Database.query('SELECT Id FROM Event WHERE IPS_eventId__c = :currentRecord');
                deleteTravelTime.addAll(delList);
        if(deleteTravelTime.size()>0){
            Database.delete(deleteTravelTime, true);
        }
        
    }
}