@isTest
public with sharing class IPS_TestDataFactory {
    
    public static Person__c createPerson(String ident) {
        Person__c person = new Person__c(
        INT_Confidential__c = 'UGRADERT',
        Name = ident,
        INT_LastName__c = 'Last',
        INT_FirstName__c = 'First');
        return person;
    }
    
    public static Account createPersonAccount(String ident){
        Account accPerson = new Account(
        FirstName='First',
        LastName='Last',
        INT_PersonIdent__c =ident,
        RecordTypeId=SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
    return accPerson;
    }
    
    public static User createUser( Account account) {
        User user = createStandardUser('Last');
        user.ContactId = account.PersonContactId;

        return user;
    }
    
    public static User createUserCommunity( Account account) {
        User user = createCommunityUser('Last',account.PersonContactId);
        //user.ContactId = account.PersonContactId;

        return user;
    }
    
    public static User createCommunityUser(String lastName,ID contactId) {
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Customer Community Plus User' LIMIT 1];
        User user = new User(
            Username = 'IPS.' + lastName + '@nav.ips.no',
            LastName = lastName,
            Email = 'IPS_testuser@nav.ips.no',
            Alias = lastName,
            CommunityNickname = lastName,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = profile.id,
            Department = '1',
          	CRM_NAV_Ident__c = 'test123',
            ContactId = contactId
        );
        return user;
    }
    
    public static User createStandardUser(String lastName) {
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user = new User(
            Username = 'IPS.' + lastName + '@nav.ips.no',
            LastName = lastName,
            Email = 'IPS_testuser@nav.ips.no',
            Alias = lastName,
            CommunityNickname = lastName,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = profile.id,
            Department = '1',
          	CRM_NAV_Ident__c = 'test123'
        );
        return user;
    }
    
    public static Account createEmployerAccount(String employerName){
        ID recordType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IPS_UO_account_recordpage').getRecordTypeId();
        Account accEmpl = new Account(
        	Name=employerName,
        	RecordTypeId=recordType
        );
    return accEmpl;
    }
    
    public static Work_Trail__c getWorkTrail(Account account){
        Work_Trail__c trail = new Work_Trail__c(
        ips_Participant__c = account.id,
        ips_Status__c ='Referred',
        ips_Main_goal__c ='Dette er mitt mål',
        ips_Passive__c=false);
        return trail;
    }
}