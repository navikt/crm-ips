/**
 * @description  : Skriver User.ManagerId etter at transaksjonen er committet.
 *                Da ser vi den konvergerte lederen på teammedlemmene, ikke et mellomresultat.
 * @author       : Håkon Kavli
 * @since        : 0.550.0
 *
 *                🔴 Rød sone. User.ManagerId styrer IPS_Utility.getMyEmployeesUserIds(),
 *                altså hvem som ser «mitt team». Alle valideringsregler her går foran hastighet.
 **/
public without sharing class IPS_UpdateUserManagerIdAfterCommit implements System.Transaction.AfterCommit {
    @TestVisible
    private static Set<Id> queuedUserIds = new Set<Id>();

    @TestVisible
    private static Boolean registered = false;

    /**
     * @description Legger brukere i køen for oppdatering av User.ManagerId.
     *              Registrerer bare én instans per transaksjon.
     * @param userIds Brukere som skal vurderes.
     */
    public static void queue(Set<Id> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return;
        }
        queuedUserIds.addAll(userIds);
        // Etter commit-callbacks kjører ikke i Apex-tester, så tester kaller
        // run() direkte i stedet. Se IPS_TeamMemberManagerSyncServiceTest.
        if (registered || Test.isRunningTest()) {
            return;
        }
        Database.registerAfterCommit(new IPS_UpdateUserManagerIdAfterCommit());
        registered = true;
    }

    /**
     * @description Kjøres av plattformen etter commit. Ingen kaller dette i produksjon.
     *                Feil fanges og logges, siden plattformen ellers svelger dem stille.
     */
    public void run() {
        Set<Id> userIds = new Set<Id>(queuedUserIds);
        queuedUserIds = new Set<Id>();
        registered = false;
        if (userIds.isEmpty()) {
            return;
        }
        try {
            syncUserManagerId(userIds);
        } catch (Exception e) {
            IPS_TeamMemberManagerSyncService.publishLogEvent(
                'Oppdatering av User.ManagerId feilet: ' + e.getTypeName() + ' ' + e.getMessage(),
                null
            );
        }
    }

    /**
     * @description Leser siste committede leder per bruker og skriver den til User.ManagerId.
     * @param userIds Brukere som skal vurderes.
     */
    private static void syncUserManagerId(Set<Id> userIds) {
        if (!IPS_TeamMemberManagerSyncService.isUserManagerWriteEnabled()) {
            IPS_TeamMemberManagerSyncService.publishLogEvent(
                'Hoppet over User.ManagerId. Feature toggle ' +
                    IPS_TeamMemberManagerSyncService.USER_MANAGER_SYNC_FLAG +
                    ' er av.',
                null
            );
            return;
        }

        Map<Id, Id> managerByUser = resolveCommittedManager(userIds);
        if (managerByUser.isEmpty()) {
            return;
        }

        // Trenger både målbrukeren og lederne for å validere IsActive.
        Set<Id> idsToRead = new Set<Id>(managerByUser.keySet());
        for (Id managerId : managerByUser.values()) {
            if (managerId != null) {
                idsToRead.add(managerId);
            }
        }
        Map<Id, User> usersById = new Map<Id, User>(
            [
                SELECT Id, ManagerId, IsActive
                FROM User
                WHERE Id IN :idsToRead
                WITH SYSTEM_MODE
            ]
        );

        List<User> toUpdate = new List<User>();
        for (Id userId : managerByUser.keySet()) {
            Id managerId = managerByUser.get(userId);
            User targetUser = usersById.get(userId);
            if (targetUser == null) {
                continue;
            }
            // Blank leder sletter aldri User.ManagerId. Da står vi igjen med det brukeren hadde,
            // i stedet for å miste lederen på grunn av en delvis synkronisert batch.
            if (managerId == null) {
                logSkipped(userId, 'Leder er blank. User.ManagerId beholdes.');
                continue;
            }
            if (managerId == userId) {
                logSkipped(userId, 'Leder er brukeren selv. Avvist for å unngå selvreferanse.');
                continue;
            }
            User manager = usersById.get(managerId);
            if (manager == null || !manager.IsActive) {
                logSkipped(userId, 'Leder ' + managerId + ' er inaktiv eller finnes ikke. Avvist.');
                continue;
            }
            if (targetUser.ManagerId == managerId) {
                continue;
            }
            targetUser.ManagerId = managerId;
            toUpdate.add(targetUser);
        }

        if (!toUpdate.isEmpty()) {
            IPS_TeamMemberManagerSyncService.logSaveResults(
                Database.update(toUpdate, false, AccessLevel.SYSTEM_MODE),
                'Oppdatering av User.ManagerId'
            );
        }
    }

    /**
     * @description Leser siste committede teammedlem per bruker. Ved flere poster
     *              vinner den med høyest Id, samme regel som fan-out bruker.
     * @return Map fra bruker-Id til leder-Id. Verdien kan være null.
     */
    private static Map<Id, Id> resolveCommittedManager(Set<Id> userIds) {
        List<ips_Team_Member__c> records = [
            SELECT Id, ips_User__c, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c IN :userIds
            WITH SYSTEM_MODE
        ];
        Map<Id, ips_Team_Member__c> winnerByUser = new Map<Id, ips_Team_Member__c>();
        for (ips_Team_Member__c record : records) {
            if (record.ips_User__c == null) {
                continue;
            }
            ips_Team_Member__c current = winnerByUser.get(record.ips_User__c);
            if (current == null || IPS_TeamMemberManagerSyncService.isAfter(record.Id, current.Id)) {
                winnerByUser.put(record.ips_User__c, record);
            }
        }
        Map<Id, Id> managerByUser = new Map<Id, Id>();
        for (Id userId : winnerByUser.keySet()) {
            managerByUser.put(userId, winnerByUser.get(userId).ips_Manager_Id__c);
        }
        return managerByUser;
    }

    private static void logSkipped(Id userId, String reason) {
        IPS_TeamMemberManagerSyncService.publishLogEvent(
            reason + ' Bruker ' + userId + '.',
            userId
        );
    }
}
