/*
* wrapperclass used by IPS_ParticipantPortalActivityController
* experience cloud for participant
**/

public class IPS_ParticipantPortalTask {
    @AuraEnabled public String OppgaveId{get;set;}
    @AuraEnabled public Integer IndexNummer{get;set;}
    @AuraEnabled public String Emne{get;set;}
    @AuraEnabled public String EmneOgDato{get;set;}
    @AuraEnabled public String ForfallsDato{get;set;}
    @AuraEnabled public String OpprettelsesDato{get;set;}
    @AuraEnabled public String UtfoertDato{get;set;}
    @AuraEnabled public String ReferatKommentar{get;set;}
    

}