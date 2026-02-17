/**
 * Wrapper class for Apprentice job details in the Participant Portal.
 */

public class IPS_ParticipantPortalApprentice {
    @AuraEnabled
    public String Id {get; set;}
    @AuraEnabled
    public String Name {get; set;}
    @AuraEnabled
    public Date StartDate {get; set;}
    @AuraEnabled
    public Date EndDate {get; set;}
    @AuraEnabled
    public String Employer {get; set;}
    @AuraEnabled
    public String Status {get; set;}
    @AuraEnabled
    public String FormOfEmployment {get; set;}
    @AuraEnabled
    public String SupportPlan {get; set;}   
    @AuraEnabled
    public Decimal NoOfHours {get; set;}
    @AuraEnabled
    public String Subject {get; set;}  
}