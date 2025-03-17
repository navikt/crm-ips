public with sharing class IPS_ParticipantPortalTrailController {

    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalWorkTrail> getTrail(Id recordId){
        Id currentRecordId = recordId;
        List<IPS_ParticipantPortalWorkTrail> wrapperList =  new List<IPS_ParticipantPortalWorkTrail>();
    wrapperList = getTrailId(currentRecordId);
    return wrapperList;
   }

   private static List<IPS_ParticipantPortalWorkTrail> getTrailId(Id currentRecordId){
    List<IPS_ParticipantPortalWorkTrail> wrapperTempList = new List<IPS_ParticipantPortalWorkTrail>();
    List <Work_Trail__c> tempTrailList = new List<Work_Trail__c>();
    tempTrailList =[
        SELECT id
        FROM Work_Trail__c
        WHERE  ips_Participant__c  = :currentRecordId
        AND (ips_End_Date__c = LAST_N_DAYS:365 OR ips_End_Date__c =NULL)
        ORDER BY CreatedDate DESC 
        LIMIT 1];

        for(Work_Trail__c t :tempTrailList){
                
            IPS_ParticipantPortalWorkTrail tempList = new IPS_ParticipantPortalWorkTrail();
            tempList.jobbsporId = t.id;
            wrapperTempList.add(tempList);
            }
            return wrapperTempList;
    

}

  
    @AuraEnabled(cacheable=true)
   public static List<IPS_ParticipantPortalWorkTrail> getTrailWrapperClassList(Id recordId){
    Id currentRecordId = recordId;
     
    List<IPS_ParticipantPortalWorkTrail> wrapperList =  new List<IPS_ParticipantPortalWorkTrail>();
    wrapperList = getWorkTrailWrapperList(currentRecordId);
    return wrapperList;
   }

   private static List<IPS_ParticipantPortalWorkTrail> getWorkTrailWrapperList(Id currentRecordId){
    List<IPS_ParticipantPortalWorkTrail> wrapperTempList = new List<IPS_ParticipantPortalWorkTrail>();
        
    List <Work_Trail__c> tempTrailList = new List<Work_Trail__c>();
        tempTrailList =[
            SELECT id,
            Name,
            RecordType.DeveloperName,
            IPS_ownerName__c,
            ips_End_Date__c,
            End_Cause__c,
            ips_Other_end_cases__c,
            ips_Status__c,
            ips_Referred_date__c,
            ips_Main_Goal_list__c,
            ips_Main_goal__c,
            ips_Priority_career_wishes__c,
            ips_Framework_for_job_development_search__c,
            ips_Preferred_working_hours__c,
            ips_Network__c,
            ips_Geography__c,
            ips_Interests_Hobbies__c,
            Personal_Qualities__c,
            ips_Cultural_background__c,
            ips_Environmental_conditions__c,
            ips_Economy__c,
            ips_Health__c,
            ips_Strategy_before_and_after_work__c,
            ips_Facilitation_needs__c,
            ips_Early_signs_increased_symptompressur__c,
            ips_What_coping_strategies_are_there__c,
            ips_job_edu_support_network__c,
            ips_Transparency_consent_obtained_date__c,
            ips_What_can_be_shared_with_the_employer__c,
            What_cannot_be_shared_with_the_employer__c,
            ips_NAV_supervisor__c,
            ips_Behandlingsteam__c,
            ips_Network_partner__c,
            ips_Financialframework_before_start_work__c,
            ips_Plan__c,
            ips_Transition_to_work__c,
            ips_Benefits_of_openness_to_the_employer__c,
            ips_Disadvantages_of_openness_employe__c,
            ips_Desired_profession_industry_career__c,
            ips_Desired_working_environment__c,
            ips_Desired_work_tasks__c,
            ips_UO_Service__c,
            ips_Mobility__c,
            ips_Economic_conditions__c,
            ips_Social_conditions__c,
            ips_Other__c,
            ips_Education__c,
            ips_Work_experience__c
            FROM Work_Trail__c
            WHERE  ips_Participant__c  = :currentRecordId
            AND (ips_End_Date__c = LAST_N_DAYS:365 OR ips_End_Date__c =NULL)
            ORDER BY CreatedDate DESC 
            LIMIT 1];

            for(Work_Trail__c t :tempTrailList){
                
                IPS_ParticipantPortalWorkTrail tempList = new IPS_ParticipantPortalWorkTrail();
                tempList.jobbsporId = t.id;
                tempList.jobbsporNavn = t.Name;
                tempList.jobbsporPostTypeNavn = t.RecordType.DeveloperName;
                tempList.jobbsporEierNavn = t.IPS_ownerName__c;
                tempList.jobbsporStatus = t.ips_Status__c;
                tempList.jobbsporHenvistDato =  IPS_ParticipantPortalUtility.formatDate(t.ips_Referred_date__c);
                tempList.ipsHovedmaal = IPS_ParticipantPortalUtility.formatMainGoal(t.ips_Main_Goal_list__c);
                tempList.jobbsporHovedmaalBeskrivelse = t.ips_Main_goal__c;
                tempList.ipsPrioriterteOnsker = t.ips_Priority_career_wishes__c;
                tempList.ipsRammerJobbUtvikling = t.ips_Framework_for_job_development_search__c;
                tempList.ipsArbeidstid = t.ips_Preferred_working_hours__c;
                tempList.ipsNettverk = t.ips_Network__c;
                tempList.ipsGeografi = t.ips_Geography__c;
                tempList.jobbsporHobbyInteresse = t.ips_Interests_Hobbies__c;
                tempList.jobbsporPersonligeEgenskaper = t.Personal_Qualities__c;
                tempList.ipsKulturBakgrunn = t.ips_Cultural_background__c;
                tempList.ipsOmgivelser = t.ips_Environmental_conditions__c;
                tempList.ipsOekonomi = t.ips_Economy__c;
                tempList.jobbsporHelse = t.ips_Health__c;
                tempList.ipsStrategiForJobb = t.ips_Strategy_before_and_after_work__c;
                tempList.ipsBehovForTillrettelegging = t.ips_Facilitation_needs__c;
                tempList.ipsTidligSymptomTrykk = t.ips_Early_signs_increased_symptompressur__c;
                tempList.ipsMestringStrategi = t.ips_What_coping_strategies_are_there__c;
                tempList.ipsNettverkUtdanningJobb = t.ips_job_edu_support_network__c;
                tempList.jobbsporAapenhetDato = IPS_ParticipantPortalUtility.formatDate(t.ips_Transparency_consent_obtained_date__c);
                tempList.jobbsporKanDelesMedArbeidsgiver =t.ips_What_can_be_shared_with_the_employer__c;
                tempList.jobbsporKanIkkeDelesMedArbeidsgiver = t.What_cannot_be_shared_with_the_employer__c;
                tempList.jobbsporVeileder = t.ips_NAV_supervisor__c;
                tempList.ipsBehandlingsTeam = t.ips_Behandlingsteam__c;
                tempList.jobbsporNettverkPartner =t.ips_Network_partner__c;
                tempList.ipsOkonomiskeRammerVedOvergang = t.ips_Financialframework_before_start_work__c;
                tempList.ipsRaadgivningGjeld = t.ips_Plan__c;
                tempList.ipsOvergangTilJobb = t.ips_Transition_to_work__c;
                tempList.ipsAapenhetFordeler = t.ips_Benefits_of_openness_to_the_employer__c;
                tempList.ipsAapenhetUlemper = t.ips_Disadvantages_of_openness_employe__c;
                tempList.amsYrkeBransjeKarriere = t.ips_Desired_profession_industry_career__c;
                tempList.amsArbeidsmiljoe = t.ips_Desired_working_environment__c;
                tempList.amsArbeidsoppgaver = t.ips_Desired_work_tasks__c;
                tempList.amsHovedmaal = IPS_ParticipantPortalUtility.formatMainGoal(t.ips_UO_Service__c);
                tempList.amsMobilitet = t.ips_Mobility__c;
                tempList.amsOkonomiskeForhold = t.ips_Economic_conditions__c;
                tempList.amsSosialeForhold = t.ips_Social_conditions__c;
                tempList.amsAnnet = t.ips_Other__c;
                tempList.jobbsporUtdanning =t.ips_Education__c;
                tempList.jobbsporArbeidserfaring = t.ips_Work_experience__c;
                wrapperTempList.add(tempList);
            }
            return wrapperTempList;
        }
    }