@isTest
public class IPS_ParticipantsReportControllerTest {
    
     @TestSetup
    static void makeData() {
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555']?.CRM_Account__c;
        
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;
        
        
    }
    
    @isTest
    static void getReport1(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        List<ips_report__c> report1 = IPS_ParticipantsReportsController.getParticipantsReport(workTrailId);
        
        System.assert.isNotNull(report1);
        
    }
    
     @isTest
    static void getReport2(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        List<ips_report__c> report2 = IPS_ParticipantsReportsController.getAllReports(workTrailId);
        
        System.assert.isNotNull(report2);
        
    }
    
     @isTest
    static void getReport3(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c WHERE RecordType.developername = 'IPS' LIMIT 1]?.id;

        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        List<ips_report__c> report3 = IPS_ParticipantsReportsController.allReports(workTrailId);
        
        System.assert.isNotNull(report3);
        
    }

}