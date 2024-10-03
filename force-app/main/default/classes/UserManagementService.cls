public without sharing class UserManagementService {
    /**
     * Retunrs list of users managed by the current user according the given profile.
     * @param profileName profile of the user
     * @return  List of users
     */
    private static List<IPS_ManagerUsers> getUsersManagedByCurrentUser(String profileName) {
        List<IPS_ManagerUsers> usersList = new List<IPS_ManagerUsers>();

        List<User> fetchedUsers = [
            SELECT Id, Name, Profile.Name
            FROM User
            WHERE isActive = TRUE AND Id IN :IPS_Utility.getMyEmployeesUserId(profileName)
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
        return getUsersManagedByCurrentUser('NAV IPS Jobbspesialist');
    }

    /**
     * Returns list of AMS jobbspecialists managed by the current user.
     * @return List of AMS jobbspecialist
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerUsers> getAMSUsersManagedByCurrentUser() {
        return getUsersManagedByCurrentUser('NAV UO Jobbspesialist');
    }
}
