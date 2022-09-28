@isTest
public class IPS_myWorkTrailControllerTest {
@TestSetup
    static void makeTrailData(){
        
        Account acc1 = new Account();
            acc1.FirstName='Petter';
            acc1.LastName='Putte';
        	acc1.INT_PersonIdent__c ='12069712345';
        	//acc1.CRM_Person__c =pers.Id;
        	acc1.RecordTypeId=SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert acc1;
        
        Person__c pers = new Person__c();
        	pers.Name=acc1.INT_PersonIdent__c;
            pers.INT_LastName__c =acc1.LastName;
        	pers.INT_Confidential__c ='UGRADERT';
        	pers.CRM_Account__c = acc1.Id;
        insert pers;
               
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Trial Customer Portal User' LIMIT 1];
            User user = new User(
              FirstName = 'John',
              LastName = 'Doe',
              Email = 'John.Doe@nav.no',
              Username = 'John.Doe@nav.no',
              Alias = 'j.doe',
              LanguageLocaleKey = 'no',
              LocaleSidKey = 'no_NO',
              TimeZoneSidKey = 'Europe/Paris',
              EmailEncodingKey = 'UTF-8',
              ProfileId = profile.Id,
              Department = '1',
              ContactId = acc1.PersonContactId,
              CRM_NAV_Ident__c = 'test123'
            );
              
        Work_Trail__c trail = new Work_Trail__c(
        ips_Participant__c = acc1.id,
        ips_Status__c ='Referred',
        ips_Passive__c=false);
        insert trail;
    }
    
    @isTest
    static void getWorkTrail(){
        String userId = [SELECT id FROM User LIMIT 1].id;
        Test.startTest();
        	List<Work_Trail__c> wList = new List<Work_Trail__c>();
        	wList = IPS_myWorkTrailController.getUserWorkTrail(userId);
        Test.stopTest(); 
        
        System.assertEquals(wList.size(), 0, 'List should not be empty');
        
    }
}