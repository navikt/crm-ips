/**
 * @description  : Synkroniserer leder på tvers av alle teammedlemmer for samme bruker,
 *                og køer en oppdatering av User.ManagerId til etter commit.
 * @author       : Håkon Kavli
 * @since        : 0.550.0
 **/
public without sharing class IPS_TeamMemberManagerSyncService {
    /** @description Navnet på Feature_Flag__mdt-posten som styrer skriving av User.ManagerId. */
    public static final String USER_MANAGER_SYNC_FLAG = 'Sync_User_Manager_Id';

    private static final String LOG_DOMAIN = 'IPS';
    private static final String SOURCE_FUNCTION = 'IPS_TeamMemberManagerSyncService';

    /** @description Setter når fan-out er i gang. Blokkerer at fan-out-en rekurserer via sin egen DML. */
    @TestVisible
    private static Boolean fanOutInProgress = false;

    /** @description Overstyring av feature toggle i tester. null betyr at vi spør pakken. */
    @TestVisible
    private static Boolean userManagerWriteOverride = null;

    /**
     * @description Slår på eller av skriving av User.ManagerId.
     *              Standard er av. FeatureToggleBase returnerer false når
     *              Feature_Flag__mdt-posten mangler, så en manglende post slår av.
     * @return true når User.ManagerId skal skrives.
     */
    public static Boolean isUserManagerWriteEnabled() {
        if (userManagerWriteOverride != null) {
            return userManagerWriteOverride;
        }
        return new FeatureToggleBase().isFeatureEnabled(USER_MANAGER_SYNC_FLAG);
    }

    /**
     * @description Kjører synkronisering for de gitt teammedlemmene.
     * @param changedRecords Teammedlemmer som ble lagret i denne transaksjonen.
     */
    public static void run(List<ips_Team_Member__c> changedRecords) {
        if (fanOutInProgress || changedRecords == null || changedRecords.isEmpty()) {
            return;
        }
        fanOutInProgress = true;
        try {
            Map<Id, Id> managerByUser = resolveManagerByUser(changedRecords);
            if (managerByUser.isEmpty()) {
                return;
            }
            fanOutToSiblings(managerByUser);
            // Køes først etter at fan-out er konvergert, slik at User.ManagerId
            // skrives fra endelig tilstand og ikke fra et mellomresultat.
            IPS_UpdateUserManagerIdAfterCommit.queue(managerByUser.keySet());
        } catch (Exception e) {
            // Logg og swallow. En synkroniseringsfeil skal ikke blokkere
            // administratorflyten som lagret teammedlemmet.
            // Følgen er at queue() aldri kalles, så User.ManagerId beholdes
            // uendrett. Loggen er eneste signalet om at noe ble stående igjen.
            publishLogEvent(
                'Fan-out av leder feilet: ' + e.getTypeName() + ' ' + e.getMessage(),
                changedRecords[0].Id
            );
        } finally {
            fanOutInProgress = false;
        }
    }

    /**
     * @description Slår sammen endringene til én leder per bruker.
     *              Ved konflikt i samme batch vinner posten med høyest Id,
     *              slik at resultatet er deterministisk uansett rekkefølge.
     * @return Map fra bruker-Id til leder-Id. Verdien kan være null (blank leder).
     */
    private static Map<Id, Id> resolveManagerByUser(List<ips_Team_Member__c> records) {
        Map<Id, ips_Team_Member__c> winnerByUser = new Map<Id, ips_Team_Member__c>();
        for (ips_Team_Member__c record : records) {
            if (record.Id == null || record.ips_User__c == null) {
                continue;
            }
            ips_Team_Member__c current = winnerByUser.get(record.ips_User__c);
            if (current == null || isAfter(record.Id, current.Id)) {
                winnerByUser.put(record.ips_User__c, record);
            }
        }
        Map<Id, Id> managerByUser = new Map<Id, Id>();
        for (Id userId : winnerByUser.keySet()) {
            managerByUser.put(userId, winnerByUser.get(userId).ips_Manager_Id__c);
        }
        return managerByUser;
    }

    /**
     * @description Skriver lederen videre til alle søsinger for samme bruker.
     * @param managerByUser Map fra bruker-Id til leder-Id.
     */
    private static void fanOutToSiblings(Map<Id, Id> managerByUser) {
        List<ips_Team_Member__c> siblings = [
            SELECT Id, ips_User__c, ips_Manager_Id__c
            FROM ips_Team_Member__c
            WHERE ips_User__c IN :managerByUser.keySet()
            WITH SYSTEM_MODE
        ];
        Map<Id, ips_Team_Member__c> toUpdateById = new Map<Id, ips_Team_Member__c>();
        for (ips_Team_Member__c sibling : siblings) {
            if (sibling.ips_Manager_Id__c == managerByUser.get(sibling.ips_User__c)) {
                continue;
            }
            sibling.ips_Manager_Id__c = managerByUser.get(sibling.ips_User__c);
            toUpdateById.put(sibling.Id, sibling);
        }
        if (!toUpdateById.isEmpty()) {
            logSaveResults(
                Database.update(toUpdateById.values(), false, AccessLevel.SYSTEM_MODE),
                'Fan-out av leder'
            );
        }
    }

    /**
     * @description Logger delvise DML-feil. Med allOrNone = false kaster ikke Apex,
     *                så uten denne sjekken ville feil blitt helt stille.
     */
    public static void logSaveResults(List<Database.SaveResult> results, String context) {
        List<String> failures = new List<String>();
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                continue;
            }
            for (Database.Error error : result.getErrors()) {
                failures.add(error.getStatusCode() + ' ' + error.getMessage());
            }
        }
        if (failures.isEmpty()) {
            return;
        }
        List<String> reported = failures.size() > 20 ? failures.subList(0, 20) : failures;
        publishLogEvent(
            context + ' feilet for ' + failures.size() + ' av ' + results.size() + ' poster: ' +
                String.join(reported, ' | '),
            null
        );
    }

    /**
     * @description Sammenligner to Ids. Id har ingen definert rekkefølgeoperator,
     *              så vi sammenligner som tekst for å få stabil høyest Id.
     * @return true når candidate har høyere Id enn current.
     */
    public static Boolean isAfter(Id candidate, Id current) {
        return String.valueOf(candidate).compareTo(String.valueOf(current)) > 0;
    }

    /**
     * @description Publiserer en logglinje til IPS_Application_Log_Event__e.
     *                Kun tekniske ID-er, aldri persondata.
     */
    public static void publishLogEvent(String message, Id recordId) {
        List<IPS_Application_Log_Event__e> events = new List<IPS_Application_Log_Event__e>();
        events.add(
            new IPS_Application_Log_Event__e(
                Application_Domain__c = LOG_DOMAIN,
                Source_Function__c = SOURCE_FUNCTION,
                Log_Message__c = String.left(message, 32768),
                Record_Id__c = recordId == null ? null : String.left(String.valueOf(recordId), 18)
            )
        );
        Database.insert(events, false);
    }
}
