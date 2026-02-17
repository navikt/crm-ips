/**
 * @description  : Utility class for IPS, containing common methods and constants used across multiple classes in the IPS application.
 * @author       : Ann Kristin Olsen, Balendra Sounthararajan
 * @author       : Håkon Kavli
 * @since        : 0.526.0
 **/
public without sharing class IPS_Utility {
    public static final List<String> EVENT_RECORD_TYPES = new List<String>{
        'IPS_Event',
        'Ips_uo_Deltakermote',
        'ips_UO_m_ter'
    };
    public static final List<String> WORK_TRAIL_ACTIVE_STATUSES = new List<String>{
        'Adapted training and training in the workplace',
        'Career mapping and career planning',
        'Discovery',
        'Downsizing',
        'Education and training in and / or outside the workplace',
        'Find a suitable job / Collaborate with AG',
        'In Education',
        'Information and decision support',
        'Initial contact',
        'Job development CE',
        'Job development',
        'Long-term available follow-up and career development',
        'Mapping',
        'Working'
    };
    public static final List<String> WORK_TRAIL_INACTIVE_STATUSES = new List<String>{ 'Ended', 'Refferred' };

    public static List<User> getPersonAccountId(String userId) {
        List<User> userList = new List<User>();
        String confidential = 'UGRADERT';
        //String query = 'SELECT AccountId FROM User WHERE Id = :userId AND Account.CRM_Person__r.INT_Confidential__C =:confidential LIMIT 1';
        if (userId != null) {
            //userList = Database.query(query);
            userList = [
                SELECT AccountId
                FROM User
                WHERE Id = :userId AND Account.CRM_Person__r.INT_Confidential__C = :confidential
                LIMIT 1
            ];
        }
        return userList;
    }

    /**
     * List all active employees id reporting to the current user filtered by profile.
     * @param employerProfile profile of the employer
     * @return  id of the employees reporting to the current user
     */
    public static List<Id> getMyEmployeesUserId(String employerProfile) {
        List<Id> userIds = new List<Id>();
        // If jobbspesialist of IPS/UO, metodeveilder of IPS/UO will also be added to the query.
        List<String> profilesToFetch = new List<String>();
        if (employerProfile == 'NAV UO Jobbspesialist') {
            profilesToFetch.add('NAV UO Jobbspesialist');
            profilesToFetch.add('NAV UO Metodeveileder');
        } else if (employerProfile == 'NAV IPS Jobbspesialist') {
            profilesToFetch.add('NAV IPS Jobbspesialist');
            profilesToFetch.add('NAV IPS Metodeveileder');
        }
        for (User u : [
            SELECT Id
            FROM USER
            WHERE ManagerId = :UserInfo.getUserId() AND IsActive = TRUE AND Profile.Name IN :profilesToFetch
        ]) {
            userIds.add(u.Id);
        }
        return userIds;
    }

    /**
     * List of all active employees id reporting to the current user.
     * @return id of the employees reporting to the current user.
     */
    public static List<Id> getMyEmployeesUserId() {
        List<Id> userIds = new List<Id>();
        for (User u : [SELECT Id FROM USER WHERE ManagerId = :UserInfo.getUserId() AND IsActive = TRUE]) {
            userIds.add(u.Id);
        }
        return userIds;
    }
}
