@istest
public with sharing class IPS_TestDataFactory {
    
    public static Person__c createPerson(){
        return createPerson('12069755555');
    }

    public static Person__c createPerson(String ident) {
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = ident;
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';

        return person;
    }
    
    public static Account createEmployerAccount(){
        Account acct = new Account();
        acct.Name='Røre Pinne';
        acct.RecordTypeId=SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
        return acct;
    }
    
    public static Work_Trail__c createJobbspor(String participantId){
        Work_Trail__c trail = new Work_Trail__c();
        trail.ips_Participant__c = participantId;
        trail.ips_Status__c ='Referred';
        trail.ips_Passive__c=false;
        return trail;
    }
    
    public static Event createEmployerEventWithoutParticipant(String employerId){
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName()
      .get('IPS_Event')
      .getRecordTypeId();
        
        Event createEvent = new Event(
          ips_Travel_time__c = 15,
          RelatedToAccount__c = employerId,
          RecordTypeId =devRecordTypeId,
          IPS_travelTimeFrom__c = 20,
          ActivityDateTime = system.Datetime.now(),
          StartDateTime = system.Datetime.now(),
          EndDateTime = system.Datetime.now()+(60/1440),
          Subject = 'Møte med Arbeidsgiver',
          IPS_Type__c = 'Meeting with Employer',
          ips_Subcategory_Type_IPS__c = 'Job support',
          ips_Subcategory_Type__c ='Job support',
          IPS_Subcategory_Type_UO__c='Follow-up',
          F_rste_arbeidsgiverm_te__c='Nei',
          ips_Completed__c =true);
        return createEvent;
    }
    
    public static Event createParticipantEvent(String participantId,String jobbsporId){
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName()
      .get('IPS_Event')
      .getRecordTypeId();
        
        Event createEvent = new Event(
          ips_Travel_time__c = 15,
          whoId = participantId,
          WhatId = jobbsporId,
          ActivityDateTime = system.Datetime.now(),
          RecordTypeId =devRecordTypeId,
          IPS_travelTimeFrom__c = 20,
          StartDateTime = system.Datetime.now(),
          EndDateTime = system.Datetime.now()+(60/1440),
          Subject = 'Møte med deltaker',
          Description ='Møte',
          IPS_Type__c = 'Meeting with Participant',
          ips_Completed__c =false);
        return createEvent;
    }
}