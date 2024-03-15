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
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;
        String userId;

        Test.startTest();
            List<Work_Trail__c> workTrailList = IPS_myWorkTrailController.getUserWorkTrailId(userId);
            System.assertEquals(true,workTrailList.isEmpty() , 'List should not be empty');
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

        Account employer=IPS_TestDataFactory.createEmployerAccount();
        insert employer;
        
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
                    IPS_isFromTimeline__c = true,
                    ips_Completed__c = false,
                    ips_uo_Kanal__c ='Fysisk',
                    Location ='Møte ett sted',
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RelatedToAccount__c = employer.id,
                    RecordTypeId = recTypeIdEvent
        );
        insert eventEmployer;
        String contactId;
            
            Test.startTest();
            List<Event>  eList = IPS_myActivityController.getEmployerActivity(trailIPS.id,contactId);
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

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Ips_uo_Deltakermote').getRecordTypeId();

        Event eventEmployer = new Event(
                    Subject = 'Event ',
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event ',
                    IPS_Type__c = 'Meeting with Participant',
                    IPS_isFromTimeline__c = true,
                    ips_uo_Kanal__c ='Fysisk',
                    Location ='Møte ett sted',
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
    static void participantGoal(){
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
        
        ID recTypeIdTask = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();
        ID recTypeIdKontakt = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_UO_contactlog').getRecordTypeId();
        
         Task taskGoal = new Task(
                    Subject = 'Delmål ',
             		ActivityDate = System.today()+1,
                    Description = 'Møte handler om delmål ',
             		Type_of_Task_IPSUO__c ='Delmål (av hovedmål)',
                    ips_Completed__c = false,
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdTask
        );
        insert taskGoal;
        
        Task taskKontakt = new Task(
                    Subject = 'Kontaktlogg ',
             		ActivityDate = System.today()+1,
                    Description = 'Kontaktlogg ',
             		Type_of_Task_IPSUO__c ='Logg kontakt',
                    ips_Completed__c = true,
                    IsVisibleInSelfService__c =true,
            		Status ='Completed',
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdKontakt
        );
        insert taskKontakt;
        
        
        
        Test.startTest();
            List<Task>  goalList = IPS_myActivityController.getParticipantsGoals(trailIPS.id);
            System.assertEquals(false,goalList.isEmpty() , 'List should not be empty');
            List<Task>  allgoalsList = IPS_myActivityController.getAllGoals(taskGoal.id);
            System.assertEquals(true,allgoalsList.isEmpty() , 'List should not be empty');
        	List<Task>  kontaktList = IPS_myActivityController.getParticipantsLogs(trailIPS.id);
            System.assertEquals(true,kontaktList.isEmpty() , 'List should not be empty');
         Test.stopTest();
    }
    
   @isTest
    static void allEvent(){

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

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Ips_uo_Deltakermote').getRecordTypeId();

        Event allEvent = new Event(
                    Subject = 'Event ',
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event ',
                    IPS_Type__c = 'Meeting with Participant',
                    IPS_isFromTimeline__c = true,
                    ips_uo_Kanal__c ='Fysisk',
                    Location ='Møte ett sted',
                    ips_Completed__c = false,
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
        );
        insert allEvent;
            
            Test.startTest();
            List<Event>  allList = IPS_myActivityController.getAllActivity(trailIPS.id,null);
            System.assertEquals(true,allList.isEmpty() , 'List should not be empty');
            Test.stopTest();
    }
    
    @isTest
    static void getEducation(){
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
        
       ips_Education__c allEducation = new ips_Education__c(
                    Name = 'Edu1 ',
                    ips_Start_Date__c = System.today(),
                    ips_End_Date__c = System.today()+1,
                    ips_Form_of_Education__c = 'Evening Course',
                    ips_Work_Trail__c = trailIPS.id
        );
        insert allEducation;
        
        Test.startTest();
            List<ips_Education__c> educationList = IPS_myWorkTrailController.getUserEducation(trailIPS.id);
            System.assertEquals(true,educationList.isEmpty() , 'List should not be empty');
        	List<ips_Education__c> educationsList = IPS_myWorkTrailController.getUserEducations(allEducation.id);
            System.assertEquals(true,educationsList.isEmpty() , 'List should not be empty');
            List<ips_Education__c> alleducationList = IPS_myWorkTrailController.getallEducations(allEducation.id);
            System.assertEquals(true,alleducationList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }

}