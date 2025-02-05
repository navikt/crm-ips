/*
* wrapperclass used by IPS_ParticipantPortalActivityController
* experience cloud for participant
**/

public class IPS_ParticipantPortalEducation {
    @AuraEnabled public Date UtdanningStart{get; set;}
    @AuraEnabled public Date UtdanningSlutt{get; set;}
    @AuraEnabled public String Utdanningsform{get; set;}
    @AuraEnabled public String Plan{get; set;}
    @AuraEnabled public String UtdanningId{get; set;}
    @AuraEnabled public String UtdanningNavn{get; set;}
    @AuraEnabled public String UtdanningSted{get; set;}
   
}