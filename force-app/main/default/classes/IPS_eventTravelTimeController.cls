public class IPS_eventTravelTimeController {
    @InvocableMethod(label='IPS Traveltime' description='Create or update traveltime')
    public static void invokeTravelTime(List<evenctRequest> request) {
        //parse inputs and variables
        Boolean isEventUpdate = request.get(0).isUpdate;
        Datetime eventStartDate = request.get(0).startDate;
        Datetime eventEndDate = request.get(0).endDate;
        Id currentEventId = request.get(0).currentRecord;
        Integer eventTraveltimeBefore = request.get(0).travelTimeBefore;
        Integer eventTraveltimeAfter = request.get(0).travelTimeAfter;
        String eventStatus = request.get(0).status;
        String beforeOrAfter;
        if (eventTraveltimeBefore <= 0 || eventTraveltimeBefore == null) {
            eventTraveltimeBefore = 0;
        }

        if (eventTraveltimeAfter <= 0 || eventTraveltimeAfter == null) {
            eventTraveltimeAfter = 0;
        }

        //Id eventRelatedTo = request.get(0).relatedTo;
        Id eventOwnerId = request.get(0).ownerId;
        Id recordTypeId = request.get(0).recordtypeId;
        
        //create travel time
        if (isEventUpdate == false) {
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

        //update travel time
        if (isEventUpdate == true) {
                updateTravelTime(beforeOrAfter,eventStartDate, eventEndDate, currentEventId, eventTraveltimeBefore, eventTraveltimeAfter,eventStatus);
            }
    }

    //Input variables from flow
    public class evenctRequest {

        @InvocableVariable(required=true)
        public boolean isUpdate;

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
            insert eAfter;
        }
    }

    private static void updateTravelTime(
        String beforeOrAfter,
        dateTime startDate,
        dateTime endDate,
        id currentRecord,
        Integer travelTimeBefore,
        Integer travelTimeAfter,
        String eventStatus
    ) {
    
        dateTime startTimeBefore = startDate.addMinutes(-travelTimeBefore);
        dateTime startTimeAfter = startDate;
        dateTime endTimeBefore = endDate;
        dateTime endTimeAfter = endDate.addMinutes(travelTimeAfter);

        List<Event> travelList = [
            SELECT id, ips_Travel_time__c, IPS_travelTimeFrom__c, StartDateTime, EndDateTime, Subject, description
            FROM Event
            WHERE IPS_eventId__c = :currentRecord
        ];
        for (Event l : travelList) {
            if (l.Description == 'Traveltime before') {
                l.StartDateTime = startTimeBefore;
                l.EndDateTime = startTimeAfter;
                l.IPS_Status1__c = eventStatus;
                update l;
            }
            if (l.Description == 'Traveltime after') {
                l.StartDateTime = endTimeBefore;
                l.EndDateTime = endTimeAfter;
                l.IPS_Status1__c = eventStatus;
                update l;
            }

            if(travelTimeBefore==0){
                beforeOrAfter = 'Traveltime before';
                deleteTravelTime(currentRecord,beforeOrAfter);
            }
            if(travelTimeAfter==0){
                beforeOrAfter ='Traveltime after';
                deleteTravelTime(currentRecord,beforeOrAfter);
            }
        }
    }
    
    private static void deleteTravelTime(
        id currentRecord,
        String beforeOrAfter
    ){
        Datetime startDateTime = [SELECT StartDateTime FROM Event WHERE id=:currentRecord].StartDateTime;
        Datetime endDateTime = [SELECT EndDateTime FROM Event WHERE id=:currentRecord].EndDateTime;
        List<SObject> deleteTravelTime = new List<Event>();
            if(beforeOrAfter =='Traveltime before'){
                List<sObject> beforeList = Database.query('SELECT Id FROM Event WHERE IPS_eventId__c = :currentRecord AND EndDateTime= :startDateTime');
                deleteTravelTime.addAll(beforeList);
            }
            if(beforeOrAfter =='Traveltime after'){
                List<sObject> afterList = Database.query('SELECT Id FROM Event WHERE IPS_eventId__c = :currentRecord AND StartDateTime = :endDateTime');
                deleteTravelTime.addAll(afterList);
            }
        
        if(deleteTravelTime.size()>0){
            delete deleteTravelTime;
        }
    }
}