/**
 * @description  : Controller for the IPS Participant Portal, responsible for retrieving work trail information for a given participant record. This controller includes methods to fetch the most recent work trail and its details, which are then used to display relevant information on the participant portal.
 * @author       :  Ann-Kristin Olsen
 **/
public with sharing class IPS_ParticipantPortalTrailController {
    /**
     * @description Returns a list of IPS_ParticipantPortalWorkTrail wrappers for a given participant record. This method is used to fetch the most recent work trail and its details for display on the participant portal.
     * @author Ann-Kristin Olsen | 01-06-2025
     * @param recordId The ID of the participant record for which to retrieve the work trail details.
     * @return List<IPS_ParticipantPortalWorkTrail> A list of IPS_ParticipantPortalWorkTrail wrappers containing the details of the most recent work trail for the specified participant.
     **/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalWorkTrail> getTrail(Id recordId) {
        Id currentRecordId = recordId;
        List<IPS_ParticipantPortalWorkTrail> wrapperList = new List<IPS_ParticipantPortalWorkTrail>();
        wrapperList = getTrailId(currentRecordId);
        return wrapperList;
    }

    /**
     * @description Returns a list of IPS_ParticipantPortalWorkTrail wrappers containing the most recent work trail ID for a given participant record. This method queries the Work_Trail__c object to find the most recent work trail associated with the participant, filtering for those that have ended within the last 365 days or have no end date. The results are ordered by creation date in descending order, ensuring that the most recent work trail is retrieved. The wrapper class is then populated with the ID of the work trail, which can be used to fetch additional details for display on the participant portal.
     * @author Ann-Kristin Olsen | 01-06-2025
     * @param currentRecordId The ID of the participant record for which to retrieve the most recent work trail.
     * @return List<IPS_ParticipantPortalWorkTrail> A list of IPS_ParticipantPortalWorkTrail wrappers containing the most recent work trail ID for the specified participant.
     **/
    private static List<IPS_ParticipantPortalWorkTrail> getTrailId(Id currentRecordId) {
        List<IPS_ParticipantPortalWorkTrail> wrapperTempList = new List<IPS_ParticipantPortalWorkTrail>();
        Work_Trail__c tempWorkTrail = [
            SELECT Id
            FROM Work_Trail__c
            WHERE
                ips_Participant__c = :currentRecordId
                AND (ips_End_Date__c = LAST_N_DAYS:365
                OR ips_End_Date__c = NULL)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        IPS_ParticipantPortalWorkTrail tempListItem = new IPS_ParticipantPortalWorkTrail();
        tempListItem.jobbsporId = tempWorkTrail.Id;
        wrapperTempList.add(tempListItem);

        return wrapperTempList;
    }

    /**
     * @description Returns a list of IPS_ParticipantPortalWorkTrail wrappers for a given participant record. This method is used to fetch the most recent work trail and its details for display on the participant portal.
     * @author Ann-Kristin Olsen | 01-06-2025
     * @param recordId The ID of the participant record for which to retrieve the work trail details.
     * @return List<IPS_ParticipantPortalWorkTrail> A list of IPS_ParticipantPortalWorkTrail wrappers containing the details of the most recent work trail for the specified participant.
     **/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalWorkTrail> getTrailWrapperClassList(Id recordId) {
        Id currentRecordId = recordId;

        List<IPS_ParticipantPortalWorkTrail> wrapperList = new List<IPS_ParticipantPortalWorkTrail>();
        wrapperList = getWorkTrailWrapperList(currentRecordId);
        return wrapperList;
    }

    /**
     * @description Returns a wrapper with the most recent work trail for a given participant record, including all relevant details for display on the participant portal. The method queries the Work_Trail__c object for records associated with the participant, filtering for those that have ended within the last 365 days or have no end date. The results are ordered by creation date in descending order, ensuring that the most recent work trail is retrieved. The wrapper class is then populated with the details of the work trail, which can be used to display comprehensive information about the participant's work history and current status on the portal.
     * @author Ann-Kristin Olsen | January 6th, 2025
     * @param currentRecordId The Work_Trail__c record ID for which to retrieve the work trail details. This ID is used to query the Work_Trail__c object and fetch the relevant information for the participant portal.
     * @return List<IPS_ParticipantPortalWorkTrail> A list of IPS_ParticipantPortalWorkTrail wrappers containing the details of the most recent work trail for the specified participant.
     **/
    private static List<IPS_ParticipantPortalWorkTrail> getWorkTrailWrapperList(Id currentRecordId) {
        List<IPS_ParticipantPortalWorkTrail> wrapperTempList = new List<IPS_ParticipantPortalWorkTrail>();

        Work_Trail__c tempWorkTrail = [
            SELECT
                Id,
                End_Cause__c,
                ips_Behandlingsteam__c,
                ips_Benefits_of_openness_to_the_employer__c,
                ips_Cultural_background__c,
                ips_Desired_profession_industry_career__c,
                ips_Desired_work_tasks__c,
                ips_Desired_working_environment__c,
                ips_Disadvantages_of_openness_employe__c,
                ips_Early_signs_increased_symptompressur__c,
                ips_Economic_conditions__c,
                ips_Economy__c,
                ips_Education__c,
                ips_End_Date__c,
                ips_Environmental_conditions__c,
                ips_Facilitation_needs__c,
                ips_Financialframework_before_start_work__c,
                ips_Framework_for_job_development_search__c,
                ips_Geography__c,
                ips_Health__c,
                ips_Interests_Hobbies__c,
                ips_job_edu_support_network__c,
                ips_Main_goal__c,
                ips_Main_Goal_list__c,
                ips_Mobility__c,
                ips_NAV_supervisor__c,
                ips_Network__c,
                ips_Network_partner__c,
                ips_Other__c,
                ips_Other_end_cases__c,
                IPS_ownerName__c,
                ips_Plan__c,
                ips_Preferred_working_hours__c,
                ips_Priority_career_wishes__c,
                ips_Referred_date__c,
                ips_Social_conditions__c,
                ips_Status__c,
                ips_Strategy_before_and_after_work__c,
                ips_Transition_to_work__c,
                ips_Transparency_consent_obtained_date__c,
                ips_UO_Service__c,
                ips_What_can_be_shared_with_the_employer__c,
                ips_What_coping_strategies_are_there__c,
                ips_Work_experience__c,
                Name,
                Personal_Qualities__c,
                RecordType.DeveloperName,
                What_cannot_be_shared_with_the_employer__c
            FROM Work_Trail__c
            WHERE
                ips_Participant__c = :currentRecordId
                AND (ips_End_Date__c = LAST_N_DAYS:365
                OR ips_End_Date__c = NULL)
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        ips_ParticipantPortalWorkTrail tempListItem = new ips_ParticipantPortalWorkTrail();
        tempListItem.jobbsporId = tempWorkTrail.id;
        tempListItem.jobbsporNavn = tempWorkTrail.Name;
        tempListItem.jobbsporPostTypeNavn = tempWorkTrail.RecordType.DeveloperName;
        tempListItem.jobbsporEierNavn = tempWorkTrail.ips_ownerName__c;
        tempListItem.jobbsporStatus = tempWorkTrail.ips_Status__c;
        tempListItem.jobbsporHenvistDato = ips_ParticipantPortalUtility.formatDate(tempWorkTrail.ips_Referred_date__c);
        tempListItem.ipsHovedmaal = ips_ParticipantPortalUtility.formatMainGoal(tempWorkTrail.ips_Main_Goal_list__c);
        tempListItem.jobbsporHovedmaalBeskrivelse = tempWorkTrail.ips_Main_goal__c;
        tempListItem.ipsPrioriterteOnsker = tempWorkTrail.ips_Priority_career_wishes__c;
        tempListItem.ipsRammerJobbUtvikling = tempWorkTrail.ips_Framework_for_job_development_search__c;
        tempListItem.ipsArbeidstid = tempWorkTrail.ips_Preferred_working_hours__c;
        tempListItem.ipsNettverk = tempWorkTrail.ips_Network__c;
        tempListItem.ipsGeografi = tempWorkTrail.ips_Geography__c;
        tempListItem.jobbsporHobbyInteresse = tempWorkTrail.ips_Interests_Hobbies__c;
        tempListItem.jobbsporPersonligeEgenskaper = tempWorkTrail.Personal_Qualities__c;
        tempListItem.ipsKulturBakgrunn = tempWorkTrail.ips_Cultural_background__c;
        tempListItem.ipsOmgivelser = tempWorkTrail.ips_Environmental_conditions__c;
        tempListItem.ipsOekonomi = tempWorkTrail.ips_Economy__c;
        tempListItem.jobbsporHelse = tempWorkTrail.ips_Health__c;
        tempListItem.ipsStrategiForJobb = tempWorkTrail.ips_Strategy_before_and_after_work__c;
        tempListItem.ipsBehovForTillrettelegging = tempWorkTrail.ips_Facilitation_needs__c;
        tempListItem.ipsTidligSymptomTrykk = tempWorkTrail.ips_Early_signs_increased_symptompressur__c;
        tempListItem.ipsMestringStrategi = tempWorkTrail.ips_What_coping_strategies_are_there__c;
        tempListItem.ipsNettverkUtdanningJobb = tempWorkTrail.ips_job_edu_support_network__c;
        tempListItem.jobbsporAapenhetDato = ips_ParticipantPortalUtility.formatDate(
            tempWorkTrail.ips_Transparency_consent_obtained_date__c
        );
        tempListItem.jobbsporKanDelesMedArbeidsgiver = tempWorkTrail.ips_What_can_be_shared_with_the_employer__c;
        tempListItem.jobbsporKanIkkeDelesMedArbeidsgiver = tempWorkTrail.What_cannot_be_shared_with_the_employer__c;
        tempListItem.jobbsporVeileder = tempWorkTrail.ips_NAV_supervisor__c;
        tempListItem.ipsBehandlingsTeam = tempWorkTrail.ips_Behandlingsteam__c;
        tempListItem.jobbsporNettverkPartner = tempWorkTrail.ips_Network_partner__c;
        tempListItem.ipsOkonomiskeRammerVedOvergang = tempWorkTrail.ips_Financialframework_before_start_work__c;
        tempListItem.ipsRaadgivningGjeld = tempWorkTrail.ips_Plan__c;
        tempListItem.ipsOvergangTilJobb = tempWorkTrail.ips_Transition_to_work__c;
        tempListItem.ipsAapenhetFordeler = tempWorkTrail.ips_Benefits_of_openness_to_the_employer__c;
        tempListItem.ipsAapenhetUlemper = tempWorkTrail.ips_Disadvantages_of_openness_employe__c;
        tempListItem.amsYrkeBransjeKarriere = tempWorkTrail.ips_Desired_profession_industry_career__c;
        tempListItem.amsArbeidsmiljoe = tempWorkTrail.ips_Desired_working_environment__c;
        tempListItem.amsArbeidsoppgaver = tempWorkTrail.ips_Desired_work_tasks__c;
        tempListItem.amsHovedmaal = IPS_ParticipantPortalUtility.formatMainGoal(tempWorkTrail.ips_UO_Service__c);
        tempListItem.amsMobilitet = tempWorkTrail.ips_Mobility__c;
        tempListItem.amsOkonomiskeForhold = tempWorkTrail.ips_Economic_conditions__c;
        tempListItem.amsSosialeForhold = tempWorkTrail.ips_Social_conditions__c;
        tempListItem.amsAnnet = tempWorkTrail.ips_Other__c;
        tempListItem.jobbsporUtdanning = tempWorkTrail.ips_Education__c;
        tempListItem.jobbsporArbeidserfaring = tempWorkTrail.ips_Work_experience__c;
        wrapperTempList.add(tempListItem);

        return wrapperTempList;
    }
}
