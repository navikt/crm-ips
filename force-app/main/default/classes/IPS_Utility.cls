public without sharing class IPS_Utility {
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
     * List all active employees id reporting to the current user filtered by profile
     * @param employerProfile profile of the employer
     * @return  id of the employees reporting to the current user
     */
    public static List<Id> getMyEmployeesUserId(String employerProfile) {
        List<Id> userIds = new List<Id>();
        for (User u : [
            SELECT Id
            FROM USER
            WHERE ManagerId = :UserInfo.getUserId() AND IsActive = TRUE AND Profile.Name = :employerProfile
        ]) {
            userIds.add(u.Id);
        }
        return userIds;
    }
}
