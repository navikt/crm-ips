@isTest
public class IPS_eventTravelTimeControllerTest {

@TestSetup
    static void makeData(){
        Account Acc = new Account(
            FirstName='Røre',
            LastName='Pinne');
            insert acc;
        
       Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName()
      .get('IPS_Event')
      .getRecordTypeId();
        
        Event createEvent = new Event(
          ips_Travel_time__c = 15,
          whatId =acc.id,
          RecordTypeId =devRecordTypeId,
          IPS_travelTimeFrom__c = 20,
          StartDateTime = system.Datetime.now(),
          EndDateTime = system.Datetime.now()+(60/1440),
          Subject = 'Møte med Arbeidsgiver',
          IPS_Type__c = 'Meeting with Employer',
          ips_Subcategory_Type_IPS__c = 'Job support');
          insert createEvent;
        
        Event createEvent2 = new Event(
          ips_Travel_time__c = 0,
          whatId =acc.id,
          RecordTypeId =devRecordTypeId,
          IPS_travelTimeFrom__c = 0,
          StartDateTime = system.Datetime.now(),
          EndDateTime = system.Datetime.now()+(60/1440),
          Subject = 'Møte med Arbeidsgiver',
          IPS_Type__c = 'Meeting with Employer',
          ips_Subcategory_Type_IPS__c = 'Job support');
          insert createEvent2; 
    }
    

@isTest
    static void createEventTravelTime(){
  
     List<Event> travelTimeList = [SELECT id FROM Event];
     //List should not be empty
    System.assertNotEquals(travelTimeList.size(), 0, 'List should not be empty');     
        
    }
    
@isTest
    static void createwithOutTravelTime(){
  
     List<Event> noEventTravel = [SELECT id,ips_Travel_time__c, IPS_travelTimeFrom__c, StartDateTime, EndDateTime,subject,description,IPS_Type__c, ips_Subcategory_Type_IPS__c,whatId, IPS_eventId__c FROM Event WHERE IPS_eventId__c=null AND ips_Travel_time__c<=0];
        for(Event j:noEventTravel){
            System.assertEquals(j.ips_Travel_time__c, 0, 'No travel time before');     
    		System.assertEquals(j.IPS_travelTimeFrom__c, 0, 'No travel time after');
        }
    }
    
    
@isTest
    static void updateEventTravelTime(){
        List<Event> updateEvent = [SELECT id,ips_Travel_time__c, IPS_travelTimeFrom__c, StartDateTime, EndDateTime,subject,description,IPS_Type__c, ips_Subcategory_Type_IPS__c,whatId, IPS_eventId__c FROM Event WHERE IPS_eventId__c=null AND ips_Travel_time__c>0];
        for(Event i:updateEvent){
            i.StartDateTime.addMinutes(120);
            i.EndDateTime.addMinutes(120);
            Update i;
        }
     List<Event> travelTimeList = [SELECT id FROM Event];
     //List should not be empty
    System.assertNotEquals(travelTimeList.size(), 0, 'List should not be empty');
    }
    
@isTest
    static void updateEventTravelTime1(){
   	IPS_eventTravelTimeController.evenctRequest firstInput = new IPS_eventTravelTimeController.evenctRequest();
        
        List<Event> updateEvent = [SELECT id,ips_Travel_time__c, IPS_travelTimeFrom__c, StartDateTime, EndDateTime,subject,description,IPS_Type__c, ips_Subcategory_Type_IPS__c,whatId, IPS_eventId__c FROM Event WHERE IPS_eventId__c!=null];
        for(Event i:updateEvent){
            firstInput.isUpdate = true;
            firstInput.startDate = i.StartDateTime;
        	firstInput.endDate = i.EndDateTime;
        	firstInput.currentRecord= i.Id;
        	firstInput.travelTimeBefore=Integer.valueOf(i.ips_Travel_time__c);
        	firstInput.travelTimeAfter= Integer.valueOf(i.IPS_travelTimeFrom__c);
        }
         Test.startTest();
        IPS_eventTravelTimeController.invokeTravelTime(new List<IPS_eventTravelTimeController.evenctRequest>{firstInput});
        Test.stopTest(); 
    }
}