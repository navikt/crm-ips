@isTest
public class IPS_viewReportPDFControllerTest {
    
   @TestSetup
    static void makeData(){
        
        Person__c participant = IPS_TestDataFactory.createPerson();
        insert participant;
        
        String participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name='12069755555']?.CRM_Account__c;
        Work_Trail__c jobbspor = IPS_TestDataFactory.createJobbspor(participantId);
        insert jobbspor;
        
    }
    
    @isTest
    static void intervallReport(){
        
        ID workTrailId = [SELECT id FROM Work_Trail__c LIMIT 1]?.id;
        
        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport(workTrailId);
        insert intervallReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(intervallReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(intervallReport);
     	IPS_viewReportPDFController testIntervallReport = new IPS_viewReportPDFController(sc);
    }
    
    @isTest
    static void endReport(){
        
         ID workTrailId = [SELECT id FROM Work_Trail__c LIMIT 1]?.id;
        
		ips_report__c endReport = IPS_TestDataFactory.createEndReport(workTrailId);
        insert endReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(endReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(endReport);
     	IPS_viewReportPDFController testEndReport = new IPS_viewReportPDFController(sc);
        
    }
}