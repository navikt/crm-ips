public class IPS_viewReportPDFController {
    
    public String currentRecordId {get; set;}
    public ips_report__c currentRecord {get; set;}
    public boolean isIPS {get; set;}
    public boolean isUO {get; set;}
    public boolean isEndReport {get; set;}
    public boolean isIntervallReport {get; set;}
    
    public IPS_viewReportPDFController(ApexPages.StandardController sc){
        this.currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        this.isEndReport = false;
        this.isIntervallReport = true;
        this.isIPS = false;
        this.isUO = false;
        
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Rapportering_deltaker.pdf');
        
        this.currentRecord = getReport(this.currentRecordId);
  }
    
    public ips_report__c getReport(string currRecordId){
        ips_report__c reportingParticipant =  [SELECT
                                                IPS_endReport__c,
                                                IPS_report_Type__c,
                                                IPS_intervallReport__c
                                                FROM ips_report__c
                                                WHERE id = :currRecordId
                                              ];
        If(reportingParticipant.IPS_report_Type__c == 'Intervall'){
            this.isIntervallReport = true;
            reportingParticipant.IPS_intervallReport__c = reportingParticipant.IPS_intervallReport__c.replace('font-size: 14px;','font-size: 18px;');
        }
        
        IF(reportingParticipant.IPS_report_Type__c == 'End report'){
            this.isEndReport = true;
            reportingParticipant.IPS_endReport__c = reportingParticipant.IPS_endReport__c.replace('font-size: 12px;','font-size: 18px;');
            
        } 
        return reportingParticipant;
    }
}