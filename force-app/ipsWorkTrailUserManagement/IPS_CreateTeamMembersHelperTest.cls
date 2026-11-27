@isTest
private class IPS_CreateTeamMembersHelperTest {
    private static final String TEAM_NAME = 'IPS Helper Test Team';

    @testSetup
    static void setup() {
        insert new ips_Team__c(Name = TEAM_NAME, ips_Methodology__c = 'IPS', ips_Region__c = 'Oslo');
    }

    @isTest
    static void test_createTeamMembers_usesFlowUniqueKeyFormat() {
        ips_Team__c team = [SELECT Id, Name FROM ips_Team__c WHERE Name = :TEAM_NAME LIMIT 1];
        IPS_CreateTeamMembersHelper helper = new IPS_CreateTeamMembersHelper();
        User user = makeUser('TEST001', team.Name, 'NAV IPS Jobbspesialist');

        Test.startTest();
        List<ips_Team_Member__c> firstResult = helper.createTeamMembers(new List<User>{ user });
        List<ips_Team_Member__c> repeatedResult = helper.createTeamMembers(new List<User>{ user });
        Test.stopTest();

        String expectedKey = 'TEST001_' + team.Name;
        Assert.areEqual(1, firstResult.size(), 'One team member should be built.');
        Assert.areEqual(
            expectedKey,
            firstResult[0].ips_Unique_User_Key__c,
            'The key should match the active Flow format.'
        );
        Assert.areEqual(
            expectedKey,
            repeatedResult[0].ips_Unique_User_Key__c,
            'Repeated processing should produce the same key used by the Flow.'
        );
    }

    @isTest
    static void test_createTeamMembers_skipsMissingRoleAndTeamAndKeepsValidUser() {
        ips_Team__c team = [SELECT Id, Name FROM ips_Team__c WHERE Name = :TEAM_NAME LIMIT 1];
        IPS_CreateTeamMembersHelper helper = new IPS_CreateTeamMembersHelper();
        List<User> users = new List<User>{
            makeUser('TEST_NO_ROLE', null, 'NAV IPS Jobbspesialist'),
            makeUser('TEST_NO_TEAM', 'Unknown Team Jobbspesialist', 'NAV IPS Jobbspesialist'),
            makeUser('TEST_NO_FAG_TEAM', 'Fagansvarlig Test', 'NAV IPS Jobbspesialist'),
            makeUser('TEST_VALID', team.Name, 'NAV IPS Jobbspesialist')
        };

        Test.startTest();
        List<ips_Team_Member__c> result = helper.createTeamMembers(users);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Only the user with a resolved team should be returned.');
        Assert.areEqual('TEST_VALID', result[0].ips_NAV_Ident__c, 'The valid user should be retained.');
    }

    @isTest
    static void test_createTeamMembers_keepsResultsIndependentAcrossCalls() {
        ips_Team__c team = [SELECT Id, Name FROM ips_Team__c WHERE Name = :TEAM_NAME LIMIT 1];
        IPS_CreateTeamMembersHelper helper = new IPS_CreateTeamMembersHelper();

        Test.startTest();
        List<ips_Team_Member__c> firstResult = helper.createTeamMembers(
            new List<User>{ makeUser('TEST_FIRST', team.Name, 'NAV IPS Jobbspesialist') }
        );
        List<ips_Team_Member__c> secondResult = helper.createTeamMembers(
            new List<User>{ makeUser('TEST_SECOND', team.Name, 'NAV IPS Jobbspesialist') }
        );
        Test.stopTest();

        Assert.areEqual('TEST_FIRST', firstResult[0].ips_NAV_Ident__c, 'The first result should remain unchanged.');
        Assert.areEqual('TEST_SECOND', secondResult[0].ips_NAV_Ident__c, 'The second call should return its own list.');
    }

    @isTest
    static void test_createTeamMembers_processes200UsersWithoutQueries() {
        ips_Team__c team = [SELECT Id, Name FROM ips_Team__c WHERE Name = :TEAM_NAME LIMIT 1];
        IPS_CreateTeamMembersHelper helper = new IPS_CreateTeamMembersHelper();
        List<User> users = new List<User>();
        for (Integer i = 0; i < 200; i++) {
            users.add(makeUser('TEST' + i, team.Name, 'NAV IPS Jobbspesialist'));
        }

        Test.startTest();
        Integer queriesBeforeProcessing = Limits.getQueries();
        List<ips_Team_Member__c> result = helper.createTeamMembers(users);
        Integer queriesDuringProcessing = Limits.getQueries() - queriesBeforeProcessing;
        Test.stopTest();

        Assert.areEqual(200, result.size(), 'All valid users should produce team members.');
        Assert.areEqual(0, queriesDuringProcessing, 'Processing in memory should not issue SOQL queries.');
    }

    private static User makeUser(String navIdent, String roleName, String profileName) {
        Map<String, Object> userData = new Map<String, Object>{
            'Id' => UserInfo.getUserId(),
            'CreatedDate' => Datetime.newInstance(2020, 1, 1, 0, 0, 0),
            'CRM_NAV_Ident__c' => navIdent,
            'Profile' => new Map<String, Object>{ 'Name' => profileName }
        };
        if (roleName != null) {
            userData.put('UserRole', new Map<String, Object>{ 'Name' => roleName });
        }
        return (User) JSON.deserialize(JSON.serialize(userData), User.class);
    }
}
