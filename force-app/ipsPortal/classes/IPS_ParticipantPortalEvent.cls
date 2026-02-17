/*
* wrapperclass used by IPS_ParticipantPortalActivityController
* experience cloud for participant
**/
public class IPS_ParticipantPortalEvent {
   @AuraEnabled public String EventId{get;set;}
   @AuraEnabled public String Emne{get;set;}
   @AuraEnabled public String Motedato{get;set;}
   @AuraEnabled public String Motetype{get;set;}
   @AuraEnabled public String Underkategori{get;set;}
   @AuraEnabled public Datetime TilTidDato{get;set;}
   @AuraEnabled public Datetime FraTidDato{get;set;} 
   @AuraEnabled public String ReferatKommentar{get;set;}
   @AuraEnabled public String Arbeidsgiver{get;set;}
   @AuraEnabled public String ArbeidsgiverKontakt{get;set;}
   @AuraEnabled public String DeltakerDeltatt{get;set;}
   @AuraEnabled public String Lokasjon{get;set;}
   @AuraEnabled public Integer AntallCompletedMeeting{get;set;}
   @AuraEnabled public Integer AntallAbsentMeeting{get;set;}
   @AuraEnabled public Integer AntallCancelledMeeting{get;set;}
}