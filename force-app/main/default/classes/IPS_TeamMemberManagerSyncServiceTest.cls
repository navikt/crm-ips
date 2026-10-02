/**
 * @description  : Tester synkronisering av leder på tvers av teammedlemmer og til User.ManagerId.
 * @author       : Håkon Kavli
 * @since        : 0.550.0
 *
 *                Merk: System.Transaction.AfterCommit kjører ikke i Apex-tester,
 *                fordi testtransaksjonen aldri committes. Derfor kaller testene
 *                IPS_UpdateUserManagerIdAfterCommit.run() direkte. Selve
 *                Database.registerAfterCommit-kallet er dermed ikke dekket av testene.
 **/
@isTest
private class IPS_TeamMemberManagerSyncServiceTest {
    private static Id profileId;
    private static User manager;
    private static User otherManager;
    private static User inactiveManager;
    private static User teamMemberUser;
    private static User secondTeamMemberUser;

    @TestSetup
    static void createUsers() {
        profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        manager = createUser('leder01');
        otherManager = createUser('leder02');
        inactiveManager = createUser('leder03');
        teamMemberUser = createUser('medlem01');
        secondTeamMemberUser = createUser('medlem02');
        // Fan-outen kjører uansett toggle, så standardverdien påvirker bare
        // testene som skriver User.ManagerId.
        IPS_TeamMemberManagerSyncService.userManagerWriteOverride = true;
    }

    private static User createUser(String name) {
        User created = new User(
            ProfileId = profileId,
            LastName = name,
            Alias = name.left(8),
            Username = name + '@crm-ips.test',
            Email = name + '@crm-ips.test',
            TimeZoneSidKey = 'Europe/Oslo',
            LocaleSidKey = 'nb_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'nb_NO'
        );
        insert created;
        return created;
    }

    private static ips_Team_Member__c newTeamMember(Id userId, Id managerId) {
        return new ips_Team_Member__c(ips_User__c = userId, ips_Manager_Id__c = managerId);
    }

    private static void enableUserManagerWrite(Boolean enabled) {
        IPS_TeamMemberManagerSyncService.userManagerWriteOverride = enabled;
    }

    private static Id managerIdOf(Id userId) {
        return [SELECT ManagerId FROM User WHERE Id = :userId].ManagerId;
    }

    @isTest
    static void triggerFansOutManagerToSiblingRecords() {
        insert new List<ips_Team_Member__c>{
            newTeamMember(teamMemberUser.Id, null),
            newTeamMember(teamMemberUser.Id, null)
        };

        List<ips_Team_Member__c> members = [
            SELECT Id, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c = :teamMemberUser.Id
        ];
        members[1].ips_Manager_Id__c = manager.Id;
        update members;

        for (ips_Team_Member__c member : [
            SELECT Id, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c = :teamMemberUser.Id
        ]) {
            Assert.areEqual(
                manager.Id,
                member.ips_Manager_Id__c,
                'Alle søsinger skal stå med samme leder'
            );
        }
    }

    @isTest
    static void triggerIgnoresUnrelatedFieldChanges() {
        ips_Team_Member__c member = newTeamMember(teamMemberUser.Id, null);
        insert member;

        member.ips_Is_Temporary_Position__c = true;
        update member;

        Assert.isNull(
            [SELECT ips_Manager_Id__c FROM ips_Team_Member__c WHERE Id = :member.Id].ips_Manager_Id__c,
            'Uvedkomende feltendringer skal ikke sette i gang synkronisering'
        );
    }

    @isTest
    static void blankManagerFansOutToSiblings() {
        insert new List<ips_Team_Member__c>{
            newTeamMember(teamMemberUser.Id, manager.Id),
            newTeamMember(teamMemberUser.Id, manager.Id)
        };
        List<ips_Team_Member__c> members = [
            SELECT Id, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c = :teamMemberUser.Id
        ];
        members[1].ips_Manager_Id__c = null;
        update members;

        for (ips_Team_Member__c member : [
            SELECT Id, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c = :teamMemberUser.Id
        ]) {
            Assert.isNull(member.ips_Manager_Id__c, 'Blank leder skal spres til søsinger');
        }
    }

    @isTest
    static void conflictingManagersInOneBatchPickHighestId() {
        List<ips_Team_Member__c> members = new List<ips_Team_Member__c>{
            newTeamMember(teamMemberUser.Id, null),
            newTeamMember(teamMemberUser.Id, null)
        };
        insert members;
        Id lowerId = members[0].Id;
        Id higherId = members[1].Id;

        members[0].ips_Manager_Id__c = manager.Id;
        members[1].ips_Manager_Id__c = otherManager.Id;
        update members;

        Assert.areEqual(
            otherManager.Id,
            [SELECT ips_Manager_Id__c FROM ips_Team_Member__c WHERE Id = :higherId].ips_Manager_Id__c,
            'Posten med høyest Id skal vinne'
        );
        Assert.areEqual(
            otherManager.Id,
            [SELECT ips_Manager_Id__c FROM ips_Team_Member__c WHERE Id = :lowerId].ips_Manager_Id__c,
            'Fan-out skal gjøre alle søsinger like'
        );
    }

    @isTest
    static void guardBlocksNestedInvocation() {
        ips_Team_Member__c member = newTeamMember(teamMemberUser.Id, null);
        insert member;
        ips_Team_Member__c sibling = newTeamMember(teamMemberUser.Id, null);
        insert sibling;

        // Etterligner et nestet trigger-kall under fan-outens egen DML.
        IPS_TeamMemberManagerSyncService.fanOutInProgress = true;
        List<ips_Team_Member__c> nested = new List<ips_Team_Member__c>{ member };
        nested[0].ips_Manager_Id__c = manager.Id;
        IPS_TeamMemberManagerSyncService.run(nested);
        IPS_TeamMemberManagerSyncService.fanOutInProgress = false;

        Assert.isNull(
            [SELECT ips_Manager_Id__c FROM ips_Team_Member__c WHERE Id = :sibling.Id].ips_Manager_Id__c,
            'Guard skal stoppe et nestet kjør fra å skrive videre'
        );
    }

    @isTest
    static void isAfterComparesIdsAsText() {
        // Sammenligner som streng, så resultatet er uavhengig av Id-lengde.
        Id lowest = '005000000000001AAA';
        Id highest = '005000000000002AAA';

        Assert.isTrue(
            IPS_TeamMemberManagerSyncService.isAfter(highest, lowest),
            'Høyere Id skal sorteres etter lavere'
        );
        Assert.isFalse(
            IPS_TeamMemberManagerSyncService.isAfter(lowest, highest),
            'Lavere Id skal ikke sorteres etter høyere'
        );
        Assert.isFalse(
            IPS_TeamMemberManagerSyncService.isAfter(lowest, lowest),
            'Samme Id skal ikke telle som etter'
        );
        Assert.isTrue(
            IPS_TeamMemberManagerSyncService.isAfter(highest, '005000000000001'),
            'Ulik Id-lengde skal ikke gi feil svar'
        );
    }

    @isTest
    static void triggerQueuesAffectedUsers() {
        insert newTeamMember(teamMemberUser.Id, manager.Id);

        Assert.areEqual(
            1,
            IPS_UpdateUserManagerIdAfterCommit.queuedUserIds.size(),
            'Triggeren skal legge nøyaktig én bruker i køen'
        );
        Assert.isTrue(
            IPS_UpdateUserManagerIdAfterCommit.queuedUserIds.contains(teamMemberUser.Id),
            'Køen skal inneholde brukeren som ble lagret'
        );
    }

    @isTest
    static void queueIgnoresEmptySet() {
        IPS_UpdateUserManagerIdAfterCommit.queuedUserIds = new Set<Id>();
        IPS_UpdateUserManagerIdAfterCommit.queue(new Set<Id>());

        Assert.areEqual(
            0,
            IPS_UpdateUserManagerIdAfterCommit.queuedUserIds.size(),
            'Tom mengde skal ikke legge noe i køen'
        );
    }

    @isTest
    static void runWithoutQueuedUsersDoesNothing() {
        IPS_UpdateUserManagerIdAfterCommit.queuedUserIds = new Set<Id>();
        Integer dmlBefore = Limits.getDmlStatements();

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.areEqual(
            dmlBefore,
            Limits.getDmlStatements(),
            'Uten køede brukere skal det ikke skje DML'
        );
    }

    @isTest
    static void afterCommitWritesManagerIdOnUser() {
        insert newTeamMember(teamMemberUser.Id, manager.Id);

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.areEqual(
            manager.Id,
            managerIdOf(teamMemberUser.Id),
            'User.ManagerId skal settes fra teammedlemmets leder'
        );
    }

    @isTest
    static void afterCommitSkipsWriteWhenToggleDisabled() {
        enableUserManagerWrite(false);
        insert newTeamMember(teamMemberUser.Id, manager.Id);

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.isNull(
            managerIdOf(teamMemberUser.Id),
            'Avstengt toggle skal ikke skrive User.ManagerId'
        );
    }

    @isTest
    static void featureFlagDefaultsToDisabled() {
        IPS_TeamMemberManagerSyncService.userManagerWriteOverride = null;

        Assert.isFalse(
            IPS_TeamMemberManagerSyncService.isUserManagerWriteEnabled(),
            'Uten en aktiv Feature_Flag__mdt-post skal skrivingen være av'
        );
    }

    @isTest
    static void blankManagerKeepsExistingUserManagerId() {
        teamMemberUser.ManagerId = otherManager.Id;
        update teamMemberUser;
        insert newTeamMember(teamMemberUser.Id, null);

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.areEqual(
            otherManager.Id,
            managerIdOf(teamMemberUser.Id),
            'Blank leder skal aldri tømme User.ManagerId'
        );
    }

    @isTest
    static void selfReferenceIsRejected() {
        insert newTeamMember(teamMemberUser.Id, teamMemberUser.Id);

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.isNull(managerIdOf(teamMemberUser.Id), 'Brukeren skal ikke bli sin egen leder');
    }

    @isTest
    static void inactiveManagerIsRejected() {
        inactiveManager.IsActive = false;
        update inactiveManager;
        insert newTeamMember(teamMemberUser.Id, inactiveManager.Id);

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.isNull(managerIdOf(teamMemberUser.Id), 'Inaktiv leder skal avvises');
    }

    @isTest
    static void noDmlWhenManagerIdAlreadyMatches() {
        teamMemberUser.ManagerId = manager.Id;
        update teamMemberUser;
        insert newTeamMember(teamMemberUser.Id, manager.Id);
        Integer dmlBefore = Limits.getDmlStatements();

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.areEqual(
            dmlBefore,
            Limits.getDmlStatements(),
            'Ingen DML når lederen allerede er riktig'
        );
    }

    @isTest
    static void syncHandlesSeveralUsersInOneCall() {
        insert new List<ips_Team_Member__c>{
            newTeamMember(teamMemberUser.Id, manager.Id),
            newTeamMember(secondTeamMemberUser.Id, otherManager.Id)
        };

        new IPS_UpdateUserManagerIdAfterCommit().run();

        Assert.areEqual(
            manager.Id,
            managerIdOf(teamMemberUser.Id),
            'Første bruker skal få sin egen leder'
        );
        Assert.areEqual(
            otherManager.Id,
            managerIdOf(secondTeamMemberUser.Id),
            'Andre bruker skal få sin egen leder, ikke den førstes'
        );
    }
}
