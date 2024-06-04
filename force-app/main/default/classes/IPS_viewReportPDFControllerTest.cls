@isTest
public class IPS_viewReportPDFControllerTest {
    
   @TestSetup
    static void makeData(){
        
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        
        String UserId = UserInfo.getUserId();
        
        Account businessAccount = IPS_TestDataFactory.createEmployerAccount();
        insert businessAccount;
        
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name='12069755555']?.CRM_Account__c;
        String contactId =[SELECT PersonContactId FROM Account WHERE CRM_Person__c =: participant.Id]?.PersonContactId;
        
        /* ********IPS*********** */
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;
        
        Event participantMeetingCompleted = IPS_TestDataFactory.createParticipantEvent(contactId,jobbspor.Id);
        insert participantMeetingCompleted;
        
        participantMeetingCompleted.IPS_Status1__c ='Completed';
        update participantMeetingCompleted;
        
        Event participantMeetingAbsent = IPS_TestDataFactory.createParticipantEvent(contactId,jobbspor.Id);
        insert participantMeetingAbsent;
        
        participantMeetingAbsent.IPS_Status1__c ='Participant Absent';
        update participantMeetingAbsent;
              
        Event employerMeetingCompletedIPS = IPS_TestDataFactory.createEmployerEventWithParticipant(businessAccount.id, UserId, jobbspor.id);
        insert employerMeetingCompletedIPS;
        
		employerMeetingCompletedIPS.IPS_Status1__c ='Completed';
        update employerMeetingCompletedIPS;
        
        Event employerMeetingAbsentIPS = IPS_TestDataFactory.createEmployerEventWithParticipant(businessAccount.id,UserId, jobbspor.id);
        insert employerMeetingAbsentIPS;
        
        employerMeetingAbsentIPS.IPS_Status1__c ='Participant Absent';
        update employerMeetingAbsentIPS;
        
        ips_job__c jobOngoingIPS = IPS_TestDataFactory.createJob(businessAccount.id, jobbspor.id, 'Ongoing');
        insert jobOngoingIPS;
        
        ips_job__c jobPlannedIPS = IPS_TestDataFactory.createJob(businessAccount.id, jobbspor.id, 'Planned');
        insert jobPlannedIPS; 
        
        ips_Education__c eduOngoingIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduOngoingIPS;
        
        ips_Education__c eduPlannedIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduPlannedIPS;
        
        eduPlannedIPS.ips_Status__c ='Planned';
        eduPlannedIPS.ips_Start_Date__c = System.today().addDays(7) ;
        update eduPlannedIPS;
        
        ips_Education__c eduCompletedIPS = IPS_TestDataFactory.createEducation(jobbspor.id);
        insert eduCompletedIPS;
        
        eduCompletedIPS.ips_Status__c ='Completed';
        eduCompletedIPS.ips_Start_Date__c = System.today().addDays(-7) ;
        eduCompletedIPS.ips_End_Date__c = System.today().addDays(30) ;
        update eduCompletedIPS;
        
                 /* ********AMS*********** */
        
        Work_Trail__c jobbsporAMS = IPS_TestDataFactory.createUOJobbspor(participantId);
        insert jobbsporAMS;
        
        AMS_Vocational_education_and_training__c eduOngoingAMS = IPS_TestDataFactory.createEducationAMS(jobbsporAMS.id);
        insert eduOngoingAMS;
        
        AMS_Vocational_education_and_training__c eduPlannedAMS = IPS_TestDataFactory.createEducationAMS(jobbsporAMS.id);
        insert eduPlannedAMS;
        
        eduPlannedAMS.AMS_Status__c ='Planned';
        eduPlannedAMS.AMS_Start_Date__c = System.today().addDays(7);
        eduPlannedAMS.AMS_End_Date__c = System.today().addDays(30);
        update eduPlannedAMS;
        
        AMS_Vocational_education_and_training__c eduCompletedAMS = IPS_TestDataFactory.createEducationAMS(jobbsporAMS.id);
        insert eduCompletedAMS;
        
        eduCompletedAMS.AMS_Status__c ='Completed';
        eduCompletedAMS.AMS_Start_Date__c = System.today().addDays(-7);
        eduCompletedAMS.AMS_End_Date__c = System.today();
        update eduCompletedAMS;
        
        
    }
    
    @isTest
    static void intervallReportIPS(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername ='IPS' LIMIT 1]?.id;
        
        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(intervallReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(intervallReport);
     	IPS_viewReportPDFController testIntervallReport = new IPS_viewReportPDFController(sc);
    }
    
    @isTest
    static void intervallReportAMS(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername ='ips_Supported_Employment' LIMIT 1]?.id;
        
        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(intervallReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(intervallReport);
     	IPS_viewReportPDFController testIntervallReport = new IPS_viewReportPDFController(sc);
    }
    
    @isTest
    static void endReportIPS(){
        
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername ='IPS' LIMIT 1]?.id;
        
		ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        insert endReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(endReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(endReport);
     	IPS_viewReportPDFController testEndReport = new IPS_viewReportPDFController(sc);
        
    }
    
    @isTest
    static void endReportAMS(){
        
         ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername ='ips_Supported_Employment' LIMIT 1]?.id;
        
		ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        insert endReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(endReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(endReport);
     	IPS_viewReportPDFController testEndReport = new IPS_viewReportPDFController(sc);
        
    }
}