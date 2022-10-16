public with sharing class IPS_myWorkTrailController {

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkTrail(String userId) {
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<Work_Trail__c>();
                }
            String accountId = userList[0]?.AccountId;
            mytrail =[
                    SELECT 
                    id,
                    ips_Priority_career_wishes__c, 
                    ips_Framework_for_job_development_search__c,
                    ips_Preferred_working_hours__c, 
                    ips_Network__c, 
                    ips_Geography__c,
                    RecordTypeId,
                    RecordType.DeveloperName
                    FROM Work_Trail__c
                    WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
                    ];
            return mytrail;
    } 

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkProfileIPS(String userId) {
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<Work_Trail__c>();
                }
            String accountId = userList[0]?.AccountId;
                mytrail =[
                    SELECT 
                    id,IPS_Ung__c,
                    IPS_Participant_age__c,IPS_Participants_home_address__c,IPS_Participant_email_address__c,IPS_Partticipant_phone_number__c,ips_Referred_date__c,Oppstartsdato__c,ips_Contact_when_not_showing__c,
                    ips_Transparency_consent_obtained_date__c, ips_Can_the_employer_be_contacted__c, ips_What_can_be_shared_with_the_employer__c, What_cannot_be_shared_with_the_employer__c, ips_Benefits_of_openness_to_the_employer__c, ips_Disadvantages_of_openness_employe__c,
                    ips_Health_service__c,ips_Behandlingsteam__c, NAV__c, ips_NAV_supervisor__c, ips_Network_partner__c,
                    ips_Financialframework_before_start_work__c, ips_Plan__c, ips_Transition_to_work__c,
                    ips_Interests_Hobbies__c, Personal_Qualities__c, ips_Cultural_background__c, ips_Environmental_conditions__c, ips_Economy__c, ips_Health__c, 
                    ips_Education__c, ips_Work_experience__c,ips_Conversation_with_previous_employers__c
                    FROM Work_Trail__c
                    WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
                    ];
            return mytrail;
    } 

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkDevelopment(String userId){
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

        List<User> userList = IPS_Utility.getPersonAccountId(userId);
            if(userList.isEmpty()){
                system.debug('No accountId found on user');
                return new List<Work_Trail__c>();
            }
        String accountId = userList[0]?.AccountId;
        mytrail =[
            SELECT 
            id,ips_Main_Goal_list__c, ips_Main_goal__c,ips_Priority_career_wishes__c, ips_Framework_for_job_development_search__c, ips_Preferred_working_hours__c, ips_Network__c,ips_Geography__c 
            FROM work_trail__c
            WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
        ];
        return mytrail; 
    }


    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkProfileUO(String userId) {
        List<Work_Trail__c> mytrail = new List<Work_Trail__c>();

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<Work_Trail__c>();
                }
            String accountId = userList[0]?.AccountId;
                mytrail =[
                    SELECT 
                    id,
                    ips_Referred_date__c, Oppstartsdato__c, ips_Applying_Department__c, ips_NAV_supervisor__c, ips_Behandlingsteam__c,
                    ips_Desired_profession_industry_career__c, ips_Desired_working_environment__c, ips_Desired_work_tasks__c, Personal_Qualities__c, ips_Mobility__c, ips_Economic_conditions__c, ips_Health__c, ips_Social_conditions__c, ips_Interests_Hobbies__c, ips_Other__c, ips_Network_partner__c,
                    ips_Education__c, ips_Work_experience__c,
                    ips_Can_the_employer_be_contacted__c, ips_What_can_be_shared_with_the_employer__c, What_cannot_be_shared_with_the_employer__c, ips_Transparency_consent_obtained_date__c
                    FROM Work_Trail__c
                    WHERE ips_Participant__c = :accountId 
                    AND ips_Status__c !='Ended'
                    LIMIT 1
                    ];
            return mytrail;
    } 
}