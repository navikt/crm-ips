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

        ips_Job__c activeJob = IPS_TestDataFactory.createJob(employerAccount.Id, jobbspor.Id, 'Ongoing');
        insert activeJob;

        ips_Job__c activeWorkTraining = IPS_TestDataFactory.createWorkTraining(employerAccount.Id, jobbspor.Id, 'Ongoing');
        insert activeWorkTraining;
    }

    @isTest
    static void getEmptyListsWhenNoJobsExist() {
   
        List<ips_Job__c> jobs = [SELECT Id FROM ips_Job__c];
        delete jobs;

        List<IPS_ManagerJob> jobCategories = IPS_ManagerJobController.totalJobsByCategory();
        List<IPS_ManagerJob> jobTrainings = IPS_ManagerJobController.totalJobTraining();

        Assert.isNotNull(jobCategories, 'Expected an empty list to be returned when there are no jobs');
        Assert.areEqual(0, jobCategories.size(), 'Expected an empty list to be returned when there are no jobs');

        Assert.isNotNull(jobTrainings, 'Expected an empty list to be returned when there are no work trainings');
        Assert.areEqual(0, jobTrainings.size(), 'Expected an empty list to be returned when there are no work trainings');
    }

    @isTest
    static void getAggregatedJobCategory() {
        List<IPS_ManagerJob> jobs;

        Test.startTest();
        jobs = IPS_ManagerJobController.totalJobsByCategory();
        Test.stopTest();

        Assert.areEqual(1, jobs.size(), 'Confirm that there is 1 aggregated job category for the manager');
    }

    @isTest
    static void getAggregatedJobTraining() {
        List<IPS_ManagerJob> jobs;

        Test.startTest();
        jobs = IPS_ManagerJobController.totalJobTraining();
        Test.stopTest();

        Assert.areEqual(1, jobs.size(), 'Confirm that there is 1 aggregated work training for the manager');
    }
}
