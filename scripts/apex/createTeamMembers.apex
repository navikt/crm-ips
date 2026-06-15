/**
 * @description  : Oppretter ips_Team_Member__c-oppføringer for aktive brukere
 *                 med IPS/UO-profiler, koblet til riktig team via UserRole.Name
 *                 og riktig rolle via Profile.Name.
 *
 *                 Forutsetninger:
 *                   - UserRole.Name samsvarer med ips_Team__c.Name (f.eks. "IPS Ålesund")
 *                   - Teams er allerede opprettet i org
 *
 *                 Kjør: sf apex run --file scripts/apex/createTeamMembers.apex
 **/

final Set<String> TARGET_PROFILES = new Set<String>{
    'NAV IPS Jobbspesialist',
    'NAV IPS Metodeveileder',
    'NAV UO Jobbspesialist',
    'NAV UO Metodeveileder'
};

// --- Hent brukere ---
List<User> users = [
    SELECT Id, Name, CRM_NAV_Ident__c, UserRole.Name, Profile.Name
    FROM User
    WHERE IsActive = TRUE
        AND Profile.Name IN :TARGET_PROFILES
        AND UserRoleId != NULL
        AND CRM_NAV_Ident__c != NULL
];

System.debug('Fant ' + users.size() + ' brukere med aktuelle profiler');

// --- Hent alle relevante teams (nøkkel = Name) ---
Map<String, Id> teamIdByName = new Map<String, Id>();
for (ips_Team__c team : [SELECT Id, Name FROM ips_Team__c]) {
    teamIdByName.put(team.Name, team.Id);
}

// --- Profil → ips_Role__c ---
Map<String, String> profileToRole = new Map<String, String>{
    'NAV IPS Jobbspesialist' => 'Jobbspesialist',
    'NAV IPS Metodeveileder' => 'Metodeveileder',
    'NAV UO Jobbspesialist'  => 'Jobbspesialist',
    'NAV UO Metodeveileder'  => 'Metodeveileder'
};

// --- Bygg Team Member-records ---
List<ips_Team_Member__c> toUpsert = new List<ips_Team_Member__c>();
List<String> skipped = new List<String>();

for (User u : users) {
    String roleName = u.UserRole?.Name;
    String profileName = u.Profile?.Name;

    Id teamId = teamIdByName.get(roleName);
    String role = profileToRole.get(profileName);

    if (teamId == null) {
        skipped.add(u.Name + ' – fant ikke team med navn: "' + roleName + '"');
        continue;
    }
    if (role == null) {
        skipped.add(u.Name + ' – ukjent profil: "' + profileName + '"');
        continue;
    }

    toUpsert.add(new ips_Team_Member__c(
        ips_User__c = u.Id,
        ips_Team__c = teamId,
        ips_Role__c = role,
        ips_NAV_Ident__c = u.CRM_NAV_Ident__c,
        // Unik nøkkel per bruker+team — gjør operasjonen idempotent
        ips_Unique_User_Key__c = u.Id + '_' + teamId
    ));
}

// --- Logg hoppede over ---
if (!skipped.isEmpty()) {
    System.debug('⚠️  Hoppet over ' + skipped.size() + ' bruker(e):');
    for (String msg : skipped) {
        System.debug('   - ' + msg);
    }
}

// --- Upsert (trygt å kjøre flere ganger) ---
if (!toUpsert.isEmpty()) {
    Database.UpsertResult[] results = Database.upsert(toUpsert, ips_Team_Member__c.ips_Unique_User_Key__c, false);

    Integer success = 0;
    Integer errors = 0;
    for (Database.UpsertResult r : results) {
        if (r.isSuccess()) {
            success++;
        } else {
            errors++;
            for (Database.Error e : r.getErrors()) {
                System.debug('❌ Feil: ' + e.getMessage() + ' | Felt: ' + e.getFields());
            }
        }
    }
    System.debug('✅ Ferdig — opprettet/oppdatert: ' + success + ', feil: ' + errors + ', hoppet over: ' + skipped.size());
} else {
    System.debug('Ingen records å upserte.');
}
