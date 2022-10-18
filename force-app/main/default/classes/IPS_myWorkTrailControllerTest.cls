@isTest
public class IPS_myWorkTrailControllerTest {
    
    @isTest
    static void getWorkTrail(){
        Test.startTest();
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        System.debug('Dette er profilen: '+communityProfile);
        
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
                    
        User user = new User(
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
        insert user;
        System.debug('Dette er user: '+user);
            
        ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        	List<Work_Trail__c> wList = new List<Work_Trail__c>();
        	wList = IPS_myWorkTrailController.getUserWorkTrail(user.id);
        Test.stopTest(); 
        
        System.assertEquals(wList.size(), 0, 'List should not be empty');
        
    }
    

    @isTest
    static void getWorkTrailIPS(){
        Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
            
            ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        	List<Work_Trail__c> wList = new List<Work_Trail__c>();
        	wList = IPS_myWorkTrailController.getUserWorkProfileIPS(user.id);
        Test.stopTest(); 
        
        System.assertEquals(wList.size(), 0, 'List should not be empty');
        
    }

    @isTest
    static void getWorkTrailUO(){
       Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
        
        User userAcc = [
            SELECT AccountId,Account.CRM_Person__r.INT_Confidential__C FROM User WHERE Id = :user.id
        ];
        System.debug('Innhold: '+userAcc);
        
            
            ID recTypeIdUO = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('ips_Supported_Employment').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdUO,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        	List<Work_Trail__c> wList = new List<Work_Trail__c>();
        	wList = IPS_myWorkTrailController.getUserWorkProfileUO(user.id);
        Test.stopTest(); 
        
        System.assertEquals(wList.size(), 0, 'List should not be empty');
        
    }

    @isTest
    static void getWorkDevelopment(){

        Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
            
            ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        List<Work_Trail__c> wList = new List<Work_Trail__c>();
        wList = IPS_myWorkTrailController.getUserWorkDevelopment(user.id);
        Test.stopTest(); 
        
        System.assertEquals(wList.size(), 0, 'List should not be empty');
        
    }

    @isTest
    static void getParticipantsActivity(){
        Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
            
            ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        List<Event> eList = new List<Event>();
        	eList = IPS_myActivityController.getParticipantActivity(user.id);
        Test.stopTest(); 
        
        System.assertEquals(eList.size(), 0, 'List should not be empty');
        
    }

    @isTest
    static void getEmployerActivity(){
        Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
            
            ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        List<Event> eList = new List<Event>();
        	eList = IPS_myActivityController.getEmployerActivity(user.id);
        Test.stopTest(); 
        
        System.assertEquals(eList.size(), 0, 'List should not be empty');
        
    }

    @isTest
    static void getWeeklyActivity(){
        Test.startTest();
		Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
        
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = '12069712345';
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';
        insert person;
        
        Account account = [
            SELECT Id, OwnerId, PersonContactId, FirstName, LastName, PersonEmail, CRM_Person__c
            FROM Account
            WHERE LastName = :'Last' 
            ORDER BY createddate desc
            LIMIT 1];
            
            User user = new User(
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
			insert user;
            
            ID recTypeIdIPS = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
           
        Work_Trail__c trailIPS = new Work_Trail__c(
        ips_Participant__c = account.id,
       	recordTypeId = recTypeIdIPS,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trailIPS;
        
        List<Event> eList = new List<Event>();
        	eList = IPS_myActivityController.getUserActivity(user.id,true);
        Test.stopTest(); 
        
        System.assertEquals(eList.size(), 0, 'List should not be empty');
}
}