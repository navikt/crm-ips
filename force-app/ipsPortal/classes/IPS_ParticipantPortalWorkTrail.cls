public class IPS_ParticipantPortalWorkTrail{
    //Joint fields for IPS and AMS
    @AuraEnabled public String jobbsporNavn{get;set;}
    @AuraEnabled public String jobbsporPostTypeNavn{get;set;}
    @AuraEnabled public String jobbsporEierNavn{get;set;}
    @AuraEnabled public String jobbsporStatus{get;set;}
    @AuraEnabled public String jobbsporId{get;set;}
    @AuraEnabled public String jobbsporHenvistDato{get;set;}
    @AuraEnabled public String jobbsporHovedmaalBeskrivelse{get;set;}
    @AuraEnabled public String jobbsporNettverkPartner{get;set;}
    @AuraEnabled public String jobbsporPersonligeEgenskaper{get;set;}
    
    @AuraEnabled public String jobbsporHelse{get;set;}
    @AuraEnabled public String jobbsporHobbyInteresse{get;set;}
    @AuraEnabled public String jobbsporAapenhetDato{get;set;}//IPS - åpenhet
    @AuraEnabled public String jobbsporKanDelesMedArbeidsgiver{get;set;}//IPS - åpenhet
    @AuraEnabled public String jobbsporKanIkkeDelesMedArbeidsgiver{get;set;}//IPS - åpenhet
    @AuraEnabled public String jobbsporVeileder{get;set;}//IPS -samarbeid
    @AuraEnabled public String jobbsporUtdanning{get;set;}
    @AuraEnabled public String jobbsporArbeidserfaring{get;set;}

    
    //Fields for AMS
    @AuraEnabled public String amsHovedmaal{get;set;}

    //yrkesprofil
    @AuraEnabled public String amsYrkeBransjeKarriere{get;set;}
    @AuraEnabled public String amsArbeidsmiljoe{get;set;}
    @AuraEnabled public String amsArbeidsoppgaver{get;set;}
    @AuraEnabled public String amsMobilitet{get;set;}
    @AuraEnabled public String amsOkonomiskeForhold{get;set;}
    @AuraEnabled public String amsSosialeForhold{get;set;}
    @AuraEnabled public String amsAnnet{get;set;}
    
    //Fields for IPS
    //jobbutvikling
    @AuraEnabled public String ipsHovedmaal{get;set;}
    @AuraEnabled public String ipsPrioriterteOnsker{get;set;}
    @AuraEnabled public String ipsRammerJobbUtvikling{get;set;}
    @AuraEnabled public String ipsArbeidstid{get;set;}
    @AuraEnabled public String ipsGeografi{get;set;}
    @AuraEnabled public String ipsNettverk{get;set;}
    //kartlegging
    @AuraEnabled public String ipsKulturBakgrunn{get;set;}
    @AuraEnabled public String ipsOekonomi{get;set;}
    @AuraEnabled public String ipsOmgivelser{get;set;}
    
    //jobb og utdanningstøtte
    @AuraEnabled public String ipsStrategiForJobb{get;set;}
    @AuraEnabled public String ipsBehovForTillrettelegging{get;set;}
    @AuraEnabled public String ipsTidligSymptomTrykk{get;set;}
    @AuraEnabled public String ipsMestringStrategi{get;set;}
    @AuraEnabled public String ipsNettverkUtdanningJobb{get;set;}

    //Samarbeid
    @AuraEnabled public String ipsAapenhetFordeler{get;set;}
    @AuraEnabled public String ipsAapenhetUlemper{get;set;}

    //Åpenhet
    @AuraEnabled public String ipsBehandlingsTeam{get;set;}

    //Økonomi
    @AuraEnabled public String ipsOkonomiskeRammerVedOvergang{get;set;}
    @AuraEnabled public String ipsRaadgivningGjeld{get;set;}
    @AuraEnabled public String ipsOvergangTilJobb{get;set;}

  
}