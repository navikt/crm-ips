public without sharing class IPS_Utility { 
    
    
    public static List<User> getPersonAccountId(String userId) {
        List<User> userList = new List<User>();
        String confidential = 'UGRADERT';
        String query = 'SELECT AccountId FROM User WHERE Id = :userId AND Account.CRM_Person__r.INT_Confidential__C =:confidential LIMIT 1';
        if(userId!=null){
            userList = Database.query(query);
        }
        return userList;
    }
}