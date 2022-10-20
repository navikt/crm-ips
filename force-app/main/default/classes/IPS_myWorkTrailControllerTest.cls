@isTest
public class IPS_myWorkTrailControllerTest {

    @TestSetup
    static void makeData(){
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Plus' LIMIT 1];
                
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        System.debug('Dette er person: '+person);

        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c,CRM_Person__r.INT_Confidential__C
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
        System.debug('Dette er account: '+account);

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

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@nav.ips.no';
        Profile p = [select id from profile where name='System Administrator'];

        User u = new User(
            Alias = 'standt', Email='standarduser@nav.ips.no',
            EmailEncodingKey='UTF-8', 
            LastName='Standard', 
            LanguageLocaleKey='no',
            LocaleSidKey='no_NO', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Paris',
            UserName=uniqueUserName);


        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
            
            Work_Trail__c trailIPS = new Work_Trail__c(
            ips_Participant__c = account.id,
            recordTypeId = recTypeIdIPS,
            ips_Status__c ='Referred',
            ips_Passive__c=false);
            insert trailIPS;

            ID recTypeIdEvent = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

            Integer numberOfRecords = 5;
            List<Event> listEventParticipant = new List<Event>();
            for(Integer i=0;i<numberOfRecords;i++){
                Event eventParticipant = new Event(
                    Subject = 'Event '+i,
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event '+i,
                    IPS_Type__c = 'Meeting with Participant',
                    IPS_Status__c ='Åpen',
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
                );
                listEventParticipant.add(eventParticipant);
            }
            if(!listEventParticipant.isEmpty()){
                insert listEventParticipant;
             }

             Integer numberOfRecords = 5;
            List<Event> listEventEmployer = new List<Event>();
            for(Integer i=0;i<numberOfRecords;i++){
                Event eventEmployer = new Event(
                    Subject = 'Event '+i,
                    StartDateTime = System.today(),
                    EndDateTime = System.today()+1,
                    Description = 'Møte handler om event '+i,
                    IPS_Type__c = 'Meeting with Employer',
                    IPS_Status__c ='Åpen',
                    IsVisibleInSelfService__c =true,
                    WhatId = trailIPS.id,
                    RecordTypeId = recTypeIdEvent
                );
                listEventEmployer.add(eventEmployer);
            }
            if(!listEventEmployer.isEmpty()){
                insert listEventEmployer;
             }
    }
 
    @isTest
    static void getWorkTrail(){
        List<Work_Trail__c> wList = new List<Work_Trail__c>();
            User user =[SELECT id FROM User WHERE LastName='Standard'];
            

            Account account = [
                SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c,CRM_Person__r.INT_Confidential__C
                FROM Account
                WHERE LastName = 'Last' 
                ORDER BY createddate desc
                LIMIT 1];


                    Test.startTest();
                    wList = IPS_myWorkTrailController.getUserWorkTrail(account.id);
                    Test.stopTest();

        System.assertNotEquals(wList.size(), 0, 'List should not be empty');
    }


    @isTest
    static void employerEvent(){
            List<Event> eList = new List<Event>();
        
            ID accountID = [SELECT id FROM Account WHERE lastName ='Last']?.id;
            String workTrailId =[SELECT id FROM work_trail__c WHERE ips_Participant__c= :accountID]?.id;
     
                    Test.startTest();
                    eList = IPS_myActivityController.getEmployerActivity(workTrailId);
                    Test.stopTest();

        System.assertNotEquals(eList.size(), 0, 'List should not be empty');
    }

    @isTest
    static void participantEvent(){

            List<Event> eList = new List<Event>();
        
            ID accountID = [SELECT id FROM Account WHERE lastName ='Last']?.id;
            String workTrailId =[SELECT id FROM work_trail__c WHERE ips_Participant__c= :accountID]?.id;
     
                    Test.startTest();
                    eList = IPS_myActivityController.getParticipantActivity(workTrailId);
                    Test.stopTest();

        System.assertNotEquals(eList.size(), 0, 'List should not be empty');
    }

}