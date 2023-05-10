@isTest
public class IPS_jobControllerTest {
    @TestSetup
    static void makeData(){
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        
        User jobUser=IPS_TestDataFactory.createInternalUserWithManager('test.jobs@nav.no',UserInfo.getUserId());
        insert jobUser;

        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name='12069755555']?.CRM_Account__c;

        Account employerAccount = IPS_TestDataFactory.createEmployerAccount();
        insert employerAccount;
        
        Work_Trail__c jobbspor = new Work_Trail__c();
        
        System.runAs(jobUser){
            jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        	insert jobbspor;
        }
        
        ips_Job__c completedJob = IPS_TestDataFactory.createJob(employerAccount.id,jobbspor.id,'Completed');
        insert completedJob;
        
        ips_Job__c activeJob = IPS_TestDataFactory.createJob(employerAccount.id,jobbspor.id,'Ongoing');
        insert activeJob;

        ips_Job__c completedWorkTraining = IPS_TestDataFactory.createWorkTraining(employerAccount.id,jobbspor.id,'Completed');
        insert completedWorkTraining;
        
        ips_Job__c activeWorkTraining = IPS_TestDataFactory.createWorkTraining(employerAccount.id,jobbspor.id,'Ongoing');
        insert activeWorkTraining;
    }

    @isTest
    static void getCompletedJobs(){
        Work_Trail__c worktrail = [SELECT Id FROM Work_Trail__c];
        List<ips_Job__c> jobs;
        
        Test.startTest();
        jobs = IPS_jobController.getCompletedUserJobs(worktrail.id);
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 completed job');
    }

    @isTest
    static void getCompletedWorkTraining(){
        Work_Trail__c worktrail = [SELECT Id FROM Work_Trail__c];
        List<ips_Job__c> jobs;
        
        Test.startTest();
        jobs = IPS_jobController.getCompletedUserWorkTrainings(worktrail.id);
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 completed worktraining');
    }
    
    @isTest
    static void getActiveJobs(){
        Work_Trail__c worktrail = [SELECT Id FROM Work_Trail__c];
        List<ips_Job__c> jobs;
        
        Test.startTest();
        jobs = IPS_jobController.getActiveUserJobs(worktrail.id);
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 active job');
    }

    @isTest
    static void getActiveWorkTraining(){
        Work_Trail__c worktrail = [SELECT Id FROM Work_Trail__c];
        List<ips_Job__c> jobs;
        
        Test.startTest();
        jobs = IPS_jobController.getActiveUserWorkTrainings(worktrail.id);
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 active worktraining');
    }
    
    @isTest
    static void getDetail(){
        ips_Job__c job = [SELECT Id FROM ips_Job__c LIMIT 1];
        List<ips_Job__c> jobs;
        
        Test.startTest();
        jobs = IPS_jobController.getUserWorkDetail(job.id);
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 detail job');
    }
    
    @isTest
    static void getaggregatedJobTraining(){
        ips_Job__c job = [SELECT Id FROM ips_Job__c WHERE ips_Status__c ='Ongoing' AND ips_Form_of_Employment__c = 'work training'];
        List<IPS_job> jobs = new List<IPS_job>();
        
        Test.startTest();
        jobs = IPS_jobController.totalJobTraining();
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there is 1 work training');
    }
    
    @isTest
    static void getaggregatedJobCategory(){
        ips_Job__c job = [SELECT Id FROM ips_Job__c WHERE ips_Status__c ='Ongoing' AND ips_Form_of_Employment__c = 'Permanent employment'];
        List<IPS_job> jobs = new List<IPS_job>();
        
        Test.startTest();
        jobs = IPS_jobController.totalJobsByCategory();
        Test.stopTest();

        System.assertEquals(1, jobs.size(),'Confirm that there i 1 active jobs');
    }
    
    
}