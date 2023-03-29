@isTest
public class IPS_viewReportPDFControllerTest {
    
    @isTest
    static void intervallReport(){
        ips_report__c intervallReport = IPS_TestDataFactory.createIntervallReport();
        insert intervallReport;
        
         PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(intervallReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(intervallReport);
     	IPS_viewReportPDFController testIntervallReport = new IPS_viewReportPDFController(sc);
    }
    
    @isTest
    static void endReport(){
        
		ips_report__c endReport = IPS_TestDataFactory.createEndReport();
        insert endReport;
        
        PageReference pageRef = Page.IPS_viewReportPDF;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id', String.valueOf(endReport.Id));
     	ApexPages.StandardController sc = new ApexPages.StandardController(endReport);
     	IPS_viewReportPDFController testEndReport = new IPS_viewReportPDFController(sc);
        
    }
}