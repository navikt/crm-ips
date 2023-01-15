@istest
public with sharing class IPS_TestDataFactory {
    public static Person__c createPerson() {
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

    public static Account createEmployerAccount() {
        Account acct = new Account();
        acct.Name = 'Røre Pinne';
        acct.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
        return acct;
    }

    public static Work_Trail__c createJobbspor(String participantId) {
        Work_Trail__c trail = new Work_Trail__c();
        trail.ips_Participant__c = participantId;
        trail.ips_Status__c = 'Referred';
        trail.ips_Passive__c = false;
        trail.IPS_Partticipant_phone_number__c = '987 65 432';
        return trail;
    }

    public static Event createEmployerEventWithoutParticipant(String employerId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            RelatedToAccount__c = employerId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med Arbeidsgiver',
            IPS_Type__c = 'Meeting with Employer',
            ips_Subcategory_Type_IPS__c = 'Job support',
            ips_Subcategory_Type__c = 'Job support',
            IPS_Subcategory_Type_UO__c = 'Follow-up',
            F_rste_arbeidsgiverm_te__c = 'Nei',
            ips_Completed__c = true
        );
        return createEvent;
    }

    public static Event createEmployerEventWithParticipant(String employerId, String participantId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            whoId = participantId,
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med Arbeidsgiver',
            IPS_Type__c = 'Meeting with Employer',
            ips_Subcategory_Type_IPS__c = 'Job support',
            ips_Subcategory_Type__c = 'Job support',
            IPS_Subcategory_Type_UO__c = 'Follow-up',
            F_rste_arbeidsgiverm_te__c = 'Nei',
            ips_Completed__c = true
        );
        return createEvent;
    }

    public static Event createParticipantEvent(String participantId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            whoId = participantId,
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med deltaker',
            Description = 'Møte',
            IPS_Type__c = 'Meeting with Participant',
            ips_Completed__c = false
        );
        return createEvent;
    }

    public static ips_Job__c createJob(String employerId, String worktrailId, String status){

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Jobb nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = Date.newInstance(2022, 10, 17), 
            ips_End_Date__c = Date.newInstance(2022, 12, 17), 
            ips_Form_of_Employment__c = 'Permanent employment' , 
            ips_Job_Support__c ='Dette er jobbstøtte', 
            ips_Number_of_hours__c = 40, 
            ips_Status__c = status, 
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke', 
            ips_What_did_work_at_the_workplace__c ='Fungerte'
        );
        return createJob;
    }

    public static ips_Job__c createWorkTraining(String employerId, String worktrailId,String status){

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Arbeidstrening nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = Date.newInstance(2022, 10, 17), 
            ips_End_Date__c = Date.newInstance(2022, 12, 17), 
            ips_Form_of_Employment__c = 'work training' , 
            ips_Job_Support__c ='Dette er jobbstøtte', 
            ips_Number_of_hours__c = 40, 
            ips_Status__c = status, 
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke', 
            ips_What_did_work_at_the_workplace__c ='Fungerte'
        );
        return createJob;
    }
}