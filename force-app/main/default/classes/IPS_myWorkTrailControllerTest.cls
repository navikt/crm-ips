@isTest
public class IPS_myWorkTrailControllerTest {

    @isTest
    static void getUserWorkTrail(){
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;

        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c,CRM_Person__r.INT_Confidential__C
            FROM Account
            WHERE LastName = :'Last' 
            LIMIT 1];
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];
        User userExperian = new User(
            Username = 'IPS.' + person.INT_LastName__c + '@nav.ips.no',
            LastName = person.INT_LastName__c,
            Email = 'IPS_testuser@nav.ips.no',
            Alias = person.INT_LastName__c,
            CommunityNickname = person.INT_LastName__c,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = communityProfile.id,
            ContactId = account.PersonContactId 
        );
        insert userExperian;
        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        Test.startTest();
            List<Work_Trail__c> userTrailList = IPS_myWorkTrailController.getUserWorkTrail(userExperian.id);
            System.assertEquals(true,userTrailList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }

    @isTest
    static void getWorkTrail(){
        ID recTypeIdAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account account = new Account(
            LastName = 'Last',
            FirstName = 'First',
            RecordTypeId =  recTypeIdAccount
        );
        insert account;

        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        Test.startTest();
            List<Work_Trail__c> workTrailList = IPS_myWorkTrailController.UserWorkTrail(account.id);
            System.assertEquals(false,workTrailList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }

    @isTest
    static void employerEvent(){

        ID recTypeIdAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account account = new Account(
            LastName = 'Last',
            FirstName = 'First',
            RecordTypeId =  recTypeIdAccount
        );
        insert account;

        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event eventEmployer = new Event(
                    Subject = 'Event ',
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event ',
                    IPS_Type__c = 'Meeting with Employer',
                    ips_Completed__c = false,
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
        );
        insert eventEmployer;
            
            Test.startTest();
            List<Event>  eList = IPS_myActivityController.getEmployerActivity(trailIPS.id);
            System.assertEquals(false,eList.isEmpty() , 'List should not be empty');
            Test.stopTest();
    }

    @isTest
    static void participantEvent(){

        ID recTypeIdAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account account = new Account(
            LastName = 'Last',
            FirstName = 'First',
            RecordTypeId =  recTypeIdAccount
        );
        insert account;

        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event eventEmployer = new Event(
                    Subject = 'Event ',
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event ',
                    IPS_Type__c = 'Meeting with Participant',
                    ips_Completed__c = false,
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
        );
        insert eventEmployer;
            
            Test.startTest();
            List<Event>  pList = IPS_myActivityController.getParticipantActivity(trailIPS.id);
            System.assertEquals(false,pList.isEmpty() , 'List should not be empty');
            Test.stopTest();
    }

    @isTest
    static void weeklyEvent(){

        ID recTypeIdAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account account = new Account(
            LastName = 'Last',
            FirstName = 'First',
            RecordTypeId =  recTypeIdAccount
        );
        insert account;

        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event eventEmployer = new Event(
                    Subject = 'Event ',
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event ',
                    IPS_Type__c = 'Meeting with Participant',
                    ips_Completed__c = false,
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
        );
        insert eventEmployer;
            
            Test.startTest();
            List<Event>  weekList = IPS_myActivityController.getWeeklyActivity(trailIPS.id);
            System.assertEquals(false,weekList.isEmpty() , 'List should not be empty');
            Test.stopTest();
    }

    @isTest
    static void getUserEvent(){
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;

        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c,CRM_Person__r.INT_Confidential__C
            FROM Account
            WHERE LastName = :'Last' 
            LIMIT 1];
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];
        User userExperian = new User(
            Username = 'IPS.' + person.INT_LastName__c + '@nav.ips.no',
            LastName = person.INT_LastName__c,
            Email = 'IPS_testuser@nav.ips.no',
            Alias = person.INT_LastName__c,
            CommunityNickname = person.INT_LastName__c,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = communityProfile.id,
            ContactId = account.PersonContactId 
        );
        insert userExperian;
        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        Test.startTest();
        List<Event> userEventList = IPS_myActivityController.getUserActivity(userExperian.id,'Weekly');
            System.assertEquals(false,userEventList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }
}