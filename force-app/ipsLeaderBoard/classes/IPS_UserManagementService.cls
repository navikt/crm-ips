/**
 * @description  : Retrieves lists of users managed by the current user based on their profile. This service class provides methods to fetch IPS and AMS jobbspecialists that report to the manager currently using the "Jobbsporet Lederbrett". The methods utilize the IPS_Utility class to filter users based on their profiles and return structured data for use in the application.
 * @author       : Balendra Sounthararajan
 * @since        : v1.0.0
 * @author       : Håkon Kavli
 * @since        : 0.536.0
 * @version      : 0.536.0
 **/
public without sharing class IPS_UserManagementService {
    /**
     * Returns list of users managed by the current user according to the given profiles.
     * @param profileNames list of profiles of the users
     * @return  List of users
     */
    private static List<IPS_ManagerUsers> getUsersManagedByCurrentUser(List<String> profileNames) {
        List<IPS_ManagerUsers> usersList = new List<IPS_ManagerUsers>();

        List<User> fetchedUsers = [
            SELECT Id, Name, Profile.Name
            FROM User
            WHERE isActive = TRUE AND Id IN :IPS_Utility.getMyEmployeesUserIds(profileNames)
            WITH SYSTEM_MODE
        ];

        for (User user : fetchedUsers) {
            IPS_ManagerUsers tempUsersList = new IPS_ManagerUsers();
            tempUsersList.employeeId = user.Id;
            tempUsersList.employeeName = user.Name;
            tempUsersList.profileName = user.Profile.Name;
            usersList.add(tempUsersList);
        }
        return usersList;
    }

    /**
     * Returns list of IPS jobbspecialists managed by the current user.
     * @return  List of IPS jobbspecialist
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerUsers> getIPSUsersManagedByCurrentUser() {
        return getUsersManagedByCurrentUser(new List<String>{ 'NAV IPS Jobbspesialist', 'NAV IPS Metodeveileder' });
    }

    /**
     * Returns list of AMS jobbspecialists managed by the current user.
     * @return List of AMS jobbspecialist
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerUsers> getAMSUsersManagedByCurrentUser() {
        return getUsersManagedByCurrentUser(new List<String>{ 'NAV UO Jobbspesialist', 'NAV UO Metodeveileder' });
    }
}
