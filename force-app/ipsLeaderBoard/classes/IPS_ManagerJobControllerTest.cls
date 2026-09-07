/**
 * @description  : Test class for IPS_ManagerJobController, which manages aggregated Job data for managers.
 * @author       : Balendra Sounthararajan
 **/
@isTest
public class IPS_ManagerJobControllerTest {
    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;

        User jobUser = IPS_TestDataFactory.createInternalUserWithManager('test.managerjobs@nav.no', UserInfo.getUserId());
        insert jobUser;

        participant = [SELECT CRM_Account__c FROM Person__c WHERE Id = :participant.Id];
        String participantId = participant.CRM_Account__c;

        Account employerAccount = IPS_TestDataFactory.createEmployerAccount();
        insert employerAccount;

        Work_Trail__c jobbspor = new Work_Trail__c();

        System.runAs(jobUser) {
            jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
            insert jobbspor;
        }

        ips_Job__c completedJob = IPS_TestDataFactory.createJob(employerAccount.Id, jobbspor.Id, 'Completed');
        insert completedJob;

        ips_Job__c activeJob = IPS_TestDataFactory.createJob(employerAccount.Id, jobbspor.Id, 'Ongoing');
        insert activeJob;

        ips_Job__c completedWorkTraining = IPS_TestDataFactory.createWorkTraining(employerAccount.Id, jobbspor.Id, 'Completed');
        insert completedWorkTraining;

        ips_Job__c activeWorkTraining = IPS_TestDataFactory.createWorkTraining(employerAccount.Id, jobbspor.Id, 'Ongoing');
        insert activeWorkTraining;
    }

    @isTest
    static void getAggregatedJobCategory() {
        List<IPS_ManagerJob> jobs;

        Test.startTest();
        jobs = IPS_ManagerJobController.totalJobsByCategory();
        Test.stopTest();

        Assert.areEqual(1, jobs.size(), 'Confirm that 1 employment-type group is returned');
        Assert.areEqual(1, jobs[0].totalNumber, 'Confirm that only the 1 Ongoing job is counted, excluding the Completed job');
    }

    @isTest
    static void getAggregatedJobTraining() {
        List<IPS_ManagerJob> jobs;

        Test.startTest();
        jobs = IPS_ManagerJobController.totalJobTraining();
        Test.stopTest();

        Assert.areEqual(1, jobs.size(), 'Confirm that 1 aggregate row is returned');
        Assert.areEqual(1, jobs[0].totalNumber, 'Confirm that only the 1 Ongoing work training is counted, excluding the Completed work training');
    }
}
