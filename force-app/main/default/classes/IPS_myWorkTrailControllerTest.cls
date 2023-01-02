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
        
        Test.startTest();
            List<Task>  goalList = IPS_myActivityController.getParticipantsGoal(trailIPS.id);
            System.assertEquals(true,goalList.isEmpty() , 'List should not be empty');
        	List<Task>  goalsList = IPS_myActivityController.getParticipantsGoals(taskGoal.id);
            System.assertEquals(true,goalsList.isEmpty() , 'List should not be empty');
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

        ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event allEvent = new Event(
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
        insert allEvent;
            
            Test.startTest();
            List<Event>  allList = IPS_myActivityController.getAllActivity(trailIPS.id);
            System.assertEquals(false,allList.isEmpty() , 'List should not be empty');
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
        Test.stopTest();
    }
    
    @isTest
    static void getjob(){
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
        
       ips_Job__c alljob = new ips_Job__c(
                    Name = 'Job1 ',
                    ips_Start_Date__c = System.today(),
                    ips_End_Date__c = System.today()+1,
                    ips_Form_of_Employment__c = 'Freelance / self-employed',
                    ips_Work_Trail__c = trailIPS.id
        );
        insert alljob;
        Test.startTest();
            List<ips_Job__c> jobList = IPS_myWorkTrailController.getUserWork(trailIPS.id);
            System.assertEquals(false,jobList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }
    
    @isTest
    static void getTraining(){
        ID recTypeIdAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Account account = new Account(
            LastName = 'Last',
            FirstName = 'First',
            RecordTypeId =  recTypeIdAccount
        );
        insert account;
        
         ID recTypeIdEmpAccount = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
        
        Account account2 = new Account(
            Name = 'FIRST AND LAST',
            RecordTypeId =  recTypeIdEmpAccount
        );
        insert account2;

        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
        Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Working',
            ips_Passive__c=false
            );
        insert trailIPS;
        
       ips_Job__c alltraining = new ips_Job__c(
                    Name = 'Job2 ',
                    ips_Start_Date__c = System.today(),
           			ips_Employer__c = account2.id,
                    ips_End_Date__c = System.today()+1,
                    ips_Form_of_Employment__c = 'work training',
                    ips_Work_Trail__c = trailIPS.id
        );
        insert alltraining;
        
        Test.startTest();
            List<ips_Job__c> trainingList = IPS_myWorkTrailController.getUserWorkTraining(trailIPS.id);
            System.assertEquals(false,trainingList.isEmpty() , 'List should not be empty');
        	List<ips_Job__c> trainingsList = IPS_myWorkTrailController.getUserWorkTrainings(alltraining.id);
            System.assertEquals(true,trainingsList.isEmpty() , 'List should not be empty');
        Test.stopTest();
    }

}