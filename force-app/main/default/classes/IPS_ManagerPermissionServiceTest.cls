/**
 * @description Test class for IPS_ManagerPermissionService.
 *              Tests assign and remove of IPS_Manager_Daily_Follow_Up permission set
 *              based on Work Trail manager change events.
 * @author Håkon Kavli
 */
@IsTest
private class IPS_ManagerPermissionServiceTest {
    private static final String MANAGER_PERM_SET = IPS_ManagerPermissionService.MANAGER_PERM_SET;
    private static final String WORK_TRAIL_PERM_SET = IPS_ManagerPermissionService.WORK_TRAIL_PERM_SET;

    @TestSetup
    static void setupData() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User newManager = buildUser('new.manager@test.ips', standardProfile.Id);
        User formerManager = buildUser('former.manager@test.ips', standardProfile.Id);
        User workTrailUser = buildUser('worktrail.user@test.ips', standardProfile.Id);
        insert new List<User>{ newManager, formerManager, workTrailUser };
    }

    @IsTest
    static void assignsPermissionSetToNewManagerWhoDoesNotHaveIt() {
        User newManager = getUser('new.manager@test.ips');
        PermissionSet managerPermSet = getPermissionSet(MANAGER_PERM_SET);

        IPS_ManagerPermissionService.ManagerChangeRequest req = new IPS_ManagerPermissionService.ManagerChangeRequest();
        req.newManagerId = newManager.Id;
        req.formerManagerId = null;

        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(
            new List<IPS_ManagerPermissionService.ManagerChangeRequest>{ req }
        );
        Test.stopTest();

        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSet.Id AND AssigneeId = :newManager.Id
        ];
        Assert.areEqual(1, assignments.size(), 'New manager should have IPS_Manager_Daily_Follow_Up assigned');
    }

    @IsTest
    static void doesNotDuplicatePermissionSetWhenNewManagerAlreadyHasIt() {
        User newManager = getUser('new.manager@test.ips');
        PermissionSet managerPermSet = getPermissionSet(MANAGER_PERM_SET);

        insert new PermissionSetAssignment(
            AssigneeId = newManager.Id,
            PermissionSetId = managerPermSet.Id
        );

        IPS_ManagerPermissionService.ManagerChangeRequest req = new IPS_ManagerPermissionService.ManagerChangeRequest();
        req.newManagerId = newManager.Id;
        req.formerManagerId = null;

        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(
            new List<IPS_ManagerPermissionService.ManagerChangeRequest>{ req }
        );
        Test.stopTest();

        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSet.Id AND AssigneeId = :newManager.Id
        ];
        Assert.areEqual(1, assignments.size(), 'Should not duplicate permission set assignment');
    }

    @IsTest
    static void removesPermissionSetFromFormerManagerWithNoRemainingWorkTrailUsers() {
        User formerManager = getUser('former.manager@test.ips');
        PermissionSet managerPermSet = getPermissionSet(MANAGER_PERM_SET);

        insert new PermissionSetAssignment(
            AssigneeId = formerManager.Id,
            PermissionSetId = managerPermSet.Id
        );

        IPS_ManagerPermissionService.ManagerChangeRequest req = new IPS_ManagerPermissionService.ManagerChangeRequest();
        req.newManagerId = null;
        req.formerManagerId = formerManager.Id;

        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(
            new List<IPS_ManagerPermissionService.ManagerChangeRequest>{ req }
        );
        Test.stopTest();

        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSet.Id AND AssigneeId = :formerManager.Id
        ];
        Assert.areEqual(
            0,
            assignments.size(),
            'Former manager with no Work Trail users should have permission set removed'
        );
    }

    @IsTest
    static void keepsPermissionSetOnFormerManagerWhoStillHasWorkTrailUsers() {
        User formerManager = getUser('former.manager@test.ips');
        User workTrailUser = getUser('worktrail.user@test.ips');
        PermissionSet managerPermSet = getPermissionSet(MANAGER_PERM_SET);
        PermissionSet workTrailPermSet = getPermissionSet(WORK_TRAIL_PERM_SET);

        // Assign former manager the manager permission set
        insert new PermissionSetAssignment(
            AssigneeId = formerManager.Id,
            PermissionSetId = managerPermSet.Id
        );

        // Assign work trail user the work trail permission set and set their manager
        insert new PermissionSetAssignment(
            AssigneeId = workTrailUser.Id,
            PermissionSetId = workTrailPermSet.Id
        );
        workTrailUser.ManagerId = formerManager.Id;
        update workTrailUser;

        IPS_ManagerPermissionService.ManagerChangeRequest req = new IPS_ManagerPermissionService.ManagerChangeRequest();
        req.newManagerId = null;
        req.formerManagerId = formerManager.Id;

        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(
            new List<IPS_ManagerPermissionService.ManagerChangeRequest>{ req }
        );
        Test.stopTest();

        List<PermissionSetAssignment> assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSet.Id AND AssigneeId = :formerManager.Id
        ];
        Assert.areEqual(
            1,
            assignments.size(),
            'Former manager who still manages Work Trail users should keep permission set'
        );
    }

    @IsTest
    static void handlesEmptyRequestListGracefully() {
        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(
            new List<IPS_ManagerPermissionService.ManagerChangeRequest>()
        );
        Test.stopTest();

        Assert.isTrue(true, 'Empty request list should not throw exception');
    }

    @IsTest
    static void handlesNullRequestListGracefully() {
        Test.startTest();
        IPS_ManagerPermissionService.updateManagerPermissions(null);
        Test.stopTest();

        Assert.isTrue(true, 'Null request list should not throw exception');
    }

    // --- Helpers ---

    private static User buildUser(String username, Id profileId) {
        return new User(
            FirstName = 'Test',
            LastName = username.substringBefore('@'),
            Email = username,
            Username = username + '.sandbox',
            Alias = username.left(8),
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId
        );
    }

    private static User getUser(String email) {
        return [SELECT Id FROM User WHERE Email = :email LIMIT 1];
    }

    private static PermissionSet getPermissionSet(String name) {
        return [SELECT Id FROM PermissionSet WHERE Name = :name LIMIT 1];
    }
}
