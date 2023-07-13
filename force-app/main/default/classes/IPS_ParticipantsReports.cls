public class IPS_ParticipantsReports {
 	@AuraEnabled
    public Id reportId;
    
    @AuraEnabled
    public String type;
    
    @AuraEnabled
    public DateTime createdDate;
    
    @AuraEnabled
    public Date fromDate;
    
    @AuraEnabled
    public Date toDate;

    @AuraEnabled
    public String subject;
    
}