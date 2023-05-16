@isTest
public class IPS_MangagerTrailControllerTest {

    @TestSetup
    private static void makeData(){
        
        Person__c person=IPS_TestDataFactory.createPerson('12050923564');
        insert person;
        
        Person__c personWithAccount=[SELECT CRM_Account__c, CRM_Account__r.PersonContactId FROM Person__C LIMIT 1];
        Id accountId=personWithAccount.CRM_Account__c;
        Id contactId= personWithAccount.CRM_Account__r.PersonContactId;

        Account employer=IPS_TestDataFactory.createEmployerAccount();
        insert employer;
        
        User employeeUser=IPS_TestDataFactory.createInternalUserWithManager('test.trail@nav.no',UserInfo.getUserId());
        insert employeeUser;
        
        Work_Trail__c trail = new Work_Trail__c();
        Work_Trail__c uoTrail = new Work_Trail__c();
        
        System.runAs(employeeUser){
            trail=IPS_TestDataFactory.createJobbspor(accountId);
        	insert trail;
            uoTrail = IPS_TestDataFactory.createUOJobbspor(accountId);
        }  
    }
    
    
    @IsTest
    private static void getUserTrails(){
        List<IPS_ManagerTrail> allTrails=IPS_ManagerTrailController.getAggregatedTrailStatus();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');
    } 
    
    @IsTest
    private static void getAggregatedTrailJobbspesialist(){
        List<IPS_ManagerTrail> allTrails=IPS_ManagerTrailController.getAggregatedTrailJobbspesialist();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');
    }
    
    
    @IsTest
    private static void getUOTraining(){
        List<IPS_ManagerTrail> allTrails=IPS_ManagerTrailController.getUOTraining();
        System.assertEquals(1, allTrails.size(), 'Expect trail in UO training');
    }
    
    @IsTest
    private static void getAggregatedEndedTrail(){
        Work_Trail__c t = [SELECT id FROM Work_Trail__c];
        t.ips_Status__c='Ended';
        update t;
        
        List<IPS_ManagerTrail> allTrails=IPS_ManagerTrailController.getAggregatedEndedTrail();
        System.assertEquals(1, allTrails.size(), 'Expect only trail assigned to managers employee to be retuned');

        List<IPS_ManagerTrail> endedTrail=IPS_ManagerTrailController.getReferredTrails();
        System.assertEquals(1, endedTrail.size(),'Expect only ended trail');
    }
    
    @isTest
    private static void testSubCategory(){
        String work;
        String other;
        work = IPS_ManagerTrailController.getSubCause('work', null);
        other = IPS_ManagerTrailController.getSubCause(null, 'other');
        
        System.assertEquals('work', work,'Expect work as output');
        System.assertEquals('other', other,'Expect other as output');
    }
    
    @isTest
    private static void testStatusConversion(){
        IPS_ManagerTrailController.convertStatus('Referred');
        IPS_ManagerTrailController.convertStatus('Career mapping and career planning');
        IPS_ManagerTrailController.convertStatus('Education and training in and/ or outside the workplace');
        IPS_ManagerTrailController.convertStatus('Ended');
        IPS_ManagerTrailController.convertStatus('Find a suitable job/ Collaborate with AG');
        IPS_ManagerTrailController.convertStatus('In Education');
        IPS_ManagerTrailController.convertStatus('Initial contact');
        IPS_ManagerTrailController.convertStatus('Mapping');
        IPS_ManagerTrailController.convertStatus('Passive');
        IPS_ManagerTrailController.convertStatus('Working');
        IPS_ManagerTrailController.convertStatus('Job development');
        IPS_ManagerTrailController.convertStatus('Downsizing');
        IPS_ManagerTrailController.convertStatus('Ett eller annet');
    }
    
    @isTest
    private static void testMonthConversion(){
        IPS_ManagerTrailController.convertMonthNumberToString(1);
        IPS_ManagerTrailController.convertMonthNumberToString(2);
        IPS_ManagerTrailController.convertMonthNumberToString(3);
        IPS_ManagerTrailController.convertMonthNumberToString(4);
        IPS_ManagerTrailController.convertMonthNumberToString(5);
        IPS_ManagerTrailController.convertMonthNumberToString(6);
        IPS_ManagerTrailController.convertMonthNumberToString(7);
        IPS_ManagerTrailController.convertMonthNumberToString(8);
        IPS_ManagerTrailController.convertMonthNumberToString(9);
        IPS_ManagerTrailController.convertMonthNumberToString(10);
        IPS_ManagerTrailController.convertMonthNumberToString(11);
        IPS_ManagerTrailController.convertMonthNumberToString(12);
    }
}