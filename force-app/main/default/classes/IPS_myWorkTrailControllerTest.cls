@isTest
public class IPS_myWorkTrailControllerTest {

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
            ips_Participant__c = accountID,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;

        Test.startTest();
            List<Work_Trail__c> workTrailList = IPS_myWorkTrailController.UserWorkTrail(accountID);
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
            ips_Participant__c = accountID,
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
            ips_Participant__c = accountID,
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
            ips_Participant__c = accountID,
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
}