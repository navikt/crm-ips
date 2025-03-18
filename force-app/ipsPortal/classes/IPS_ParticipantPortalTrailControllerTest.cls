@isTest
public class IPS_ParticipantPortalTrailControllerTest {

    @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        
        Account acc1 = IPS_TestDataFactory.createEmployerAccount();
        insert acc1;
        
        User usr1 = IPS_TestDataFactory.getAdminUser('Sankt','Claus');
        insert usr1;        
        
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor; 
        
        Task delmaal = IPS_TestDataFactory.creategoal(jobbspor.id);
        insert delmaal;
        
        Task delmaal2 = IPS_TestDataFactory.creategoal(jobbspor.id);
        insert delmaal2;
        delmaal2.Status = 'Completed';
        update delmaal2;
        
        Task logg = new task();
        logg.ActivityDate = system.today();
        logg.IsVisibleInSelfService = true;
        logg.Type_of_Task_IPSUO__c ='Logg kontakt';
        logg.Subject = 'Oppgave logg';
        logg.WhatId =jobbspor.id;
        logg.Samtalereferat__c = true;
        logg.Status = 'Completed';
        insert logg;
        
        
        Event meeting = IPS_TestDataFactory.createEmployerEventWithParticipant(acc1.id, usr1.id, jobbspor.id);
        insert meeting;
        
        ips_job__c job1 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Ongoing');
        insert job1;
        
        ips_job__c job2 = IPS_TestDataFactory.createJob(acc1.id, jobbspor.id, 'Ongoing');
        insert job2;
        job2.ips_Form_of_Employment__c = 'work training';
        update job2;
        
        ips_education__c edu1 = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert edu1;
        
        AMS_Vocational_education_and_training__c eduAMS = IPS_TestDataFactory.createEducationAMS(jobbspor.id);
        insert eduAMS;
    }
        
    
    @isTest
    static void getTrail(){
       
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        
         List<IPS_ParticipantPortalWorkTrail> trail = IPS_ParticipantPortalTrailController.getTrailWrapperClassList(participantId);  
            List<IPS_ParticipantPortalWorkTrail> trail2 = IPS_ParticipantPortalTrailController.getTrail(participantId);  
        System.assert.isNotNull(trail);
        System.assert.isNotNull(trail2);
        
    }
    
     @isTest
    static void getLogg(){
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalTask> logg = IPS_ParticipantPortalActivityController.getParticipantsLogs(workTrailId);
        System.assert.isNotNull(logg);
        
    }
    
    @isTest
    static void getGoals(){
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalTask> goal = IPS_ParticipantPortalActivityController.getParticipantsOpenGoals(workTrailId);
        List<IPS_ParticipantPortalTask> goalCompleted = IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals(workTrailId);
        
        System.assert.isNotNull(goal);
        
    }
    
     @isTest
    static void getCompletedGoals(){
          String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        List<IPS_ParticipantPortalTask> goalCompleted = IPS_ParticipantPortalActivityController.getParticipantsCompletedGoals(participantId);
        
        System.assert.isNotNull(goalCompleted);
        
    }
    
    
    
    @isTest
    static void getMeeting(){
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        ID contactId = [SELECT CRM_Account__r.PersonContactId  FROM Person__c WHERE Name = '12069755555']?.CRM_Account__r.PersonContactId;
		List<IPS_ParticipantPortalEvent> meeting = IPS_ParticipantPortalActivityController.getParticipantOpenMeetings(workTrailId, contactId);
        System.assert.isNotNull(meeting);        
    }
    
    @isTest
    static void getJob(){
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalJob> job = IPS_ParticipantPortalActivityController.getParticipantOpenJobs(workTrailId);
        System.assert.isNotNull(job); 
    }
    
    
    @isTest
    static void getJobTrainings(){
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalJob> job = IPS_ParticipantPortalActivityController.getParticipantOpenJobTrainings(workTrailId);
        System.assert.isNotNull(job); 
    }
    
    @isTest
    static void getEducationIPS(){
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalEducation> edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducations(workTrailId);
        System.assert.isNotNull(edu); 
    }
    
    @isTest
    static void getEducationAMS(){
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;
        List<IPS_ParticipantPortalEducation> edu = IPS_ParticipantPortalActivityController.getParticipantOpenEducationTrainingAMS(workTrailId);
        System.assert.isNotNull(edu); 
    }
}