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
        person.INT_FirstName__c = 'First'+ident;

        return person;
    }
    
    public static User getStandardUser(String firstname,String lastname) {
    Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User user = new User(
      FirstName = firstname,
      LastName = lastname,
      Email = firstname+'.'+lastname+'@nav.no',
      Username = firstname+'.'+lastname+'@nav.no',
      Alias = firstname.substring(0,2) + lastname.substring(0,2),
      LanguageLocaleKey = 'no',
      LocaleSidKey = 'no_NO',
      TimeZoneSidKey = 'Europe/Paris',
      EmailEncodingKey = 'UTF-8',
      ProfileId = profile.Id,
      Department = '1',
      CRM_NAV_Ident__c = firstname.substring(0,2) + lastname.substring(0,2) +'123'
    );
    return user;
  }
    
  public static User getAdminUser(String firstname,String lastname) {
    Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'System administrator' LIMIT 1];
    User user = new User(
      FirstName = firstname,
      LastName = lastname,
      Email = firstname+'.'+lastname+'@nav.no',
      Username = firstname+'.'+lastname+'@nav.no',
      Alias = firstname.substring(0,2) + lastname.substring(0,2),
      LanguageLocaleKey = 'no',
      LocaleSidKey = 'no_NO',
      TimeZoneSidKey = 'Europe/Paris',
      EmailEncodingKey = 'UTF-8',
      ProfileId = profile.Id,
      Department = '1',
      CRM_NAV_Ident__c = firstname.substring(0,2) + lastname.substring(0,2) +'123'
    );
    return user;
  }

    public static Account createEmployerAccount() {
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
        Account acct = new Account();
        acct.Name = 'Røre Pinne'+IntrandomNumber;
        acct.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
        return acct;
    }

    public static Work_Trail__c createJobbspor(String participantId) {
        Work_Trail__c trail = new Work_Trail__c();
        trail.ips_Participant__c = participantId;
        trail.ips_Status__c = 'Referred';
        trail.ips_Passive__c = false;
        trail.IPS_Partticipant_phone_number__c = '987 65 432';
        trail.RecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
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
            IPS_Status1__c  = 'Open'
        );
        return createEvent;
    }
    
    public static Task creategoal(String jobbsporId) {
        Id devRecordTypeId1 = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();

        Task taskGoal = new Task(
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId1,
            Type_of_Task_IPSUO__c ='Delmål (av hovedmål)', 
            Subject = 'Ett delmål',
            IPS_Status1__c  = 'Open'
        );
        return taskGoal;
    }

    public static Event createEmployerEventWithParticipant(String employerId, Id ownerId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            IPS_participant_related_to_meeting__c = true,
            WhatId = jobbsporId,
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
            IPS_Status1__c  = 'Open',
            OwnerId=ownerId,
            Location='Kontoret'
        );
        return createEvent;
    }

    public static Event createParticipantEvent(String contactId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            whoId = contactId,
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med deltaker',
            Description = 'Møte',
            IPS_Type__c = 'Meeting with Participant',
            IPS_Status1__c  = 'Open'
        );
        return createEvent;
    }
    
    public static ips_Job__c createJob(ID employerId, ID worktrailId, String status){
        Date endDate;
        if(status=='Ongoing'){
            endDate = Date.newInstance(2050, 12, 17);
        }else {
            endDate = Date.newInstance(2022, 12, 17);
        }

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Jobb nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = Date.newInstance(2022, 10, 17), 
            ips_End_Date__c = endDate, 
            ips_Form_of_Employment__c = 'Permanent employment' , 
            ips_Job_Support__c ='Dette er jobbstøtte', 
            ips_Number_of_hours__c = 40, 
            ips_Status__c = status, 
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke', 
            ips_What_did_work_at_the_workplace__c ='Fungerte'
        );
        return createJob;
    }

    public static ips_Job__c createWorkTraining(ID employerId, ID worktrailId,String status){
        Date endDate;
        if(status=='Ongoing'){
            endDate = Date.newInstance(2050, 12, 17);
        }else {
            endDate = Date.newInstance(2022, 12, 17);
        }

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Arbeidstrening nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = Date.newInstance(2022, 10, 17), 
            ips_End_Date__c = endDate, 
            ips_Form_of_Employment__c = 'work training' , 
            ips_Job_Support__c ='Dette er jobbstøtte', 
            ips_Number_of_hours__c = 40, 
            ips_Status__c = status, 
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke', 
            ips_What_did_work_at_the_workplace__c ='Fungerte'
        );
        return createJob;
    }
    
    public static ips_report__c createEndReport(){
        ips_report__c endReport = new ips_report__c(
            IPS_endReport__c = 'Avslutningsnotat IPS',
            IPS_report_Type__c = 'End report'
        );
            return endReport;
    }
    
    public static ips_report__c createIntervallReport(){
        ips_report__c intervallReport = new ips_report__c(
            IPS_intervallReport__c = 'Underveisnotat',
            IPS_report_Type__c = 'Intervall'
        );
            return intervallReport;
    }
    
    public static User createInternalUserWithManager(String username, Id managerId){
        
        Profile platformProfile=[SELECT Id FROM Profile WHERE Name='System administrator' LIMIT 1];

        User platformUser=new User();
        platformUser.FirstName='User';
        platformUser.LastName='Test';
        platformUser.Email=username;
        platformUser.UserName=username;
        platformUser.ProfileId=platformProfile.Id;
        platformUser.CRM_Nav_Ident__c='A123456';
        platformUser.Alias='plattest';
        platformUser.TimeZoneSidKey='Europe/Paris';
        platformUser.LocaleSidKey='no_NO';
        platformUser.EmailEncodingKey='ISO-8859-1';
        platformUser.LanguageLocaleKey='no';
        platformUser.ManagerId=managerId;
        return platformUser;
    }
    
   public static void addPermissionsetUser(String userId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'IPS_Jobbspesialist'];
		insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
    }
    
}
