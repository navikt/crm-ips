/*
* wrapperclass used by IPS_ParticipantPortalActivityController
* experience cloud for participant
**/
public class IPS_ParticipantPortalJob {
    @AuraEnabled public Date StartDato{get; set;}
    @AuraEnabled public Date SluttDato{get; set;}
    @AuraEnabled public Decimal AntallTimerUke{get; set;}
    @AuraEnabled public String Arbeidsform{get; set;}
    @AuraEnabled public String Arbeidsoppgaver{get; set;}
    @AuraEnabled public String Plan{get; set;}
    @AuraEnabled public String JobbId{get; set;}
    @AuraEnabled public String Emne{get; set;}
}