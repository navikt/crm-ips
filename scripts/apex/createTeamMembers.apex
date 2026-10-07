/**
 * @description  : Oppretter ips_Team_Member__c-oppføringer for aktive brukere
 *                 med IPS/UO-profiler, koblet til riktig team via UserRole.Name
 *                 og riktig rolle via Profile.Name.
 *
 *                 Brukere med en rolle som starter med "Fagansvarlig" (f.eks.
 *                 "Fagansvarlig Nittedal IPS/AMS") blir i tillegg lagt til som
 *                 team member med rollen "Fagansvarlig" på alle team som ligger
 *                 under Fagansvarlig-rollen i rollehierarkiet. F.eks. skal en
 *                 bruker med rollen "Fagansvarlig Nittedal IPS/AMS" legges til
 *                 i både "AMS Nittedal"- og "IPS Nittedal"-teamet, siden rollene
 *                 "AMS Nittedal Jobbspesialist"/"Metodeveileder" og
 *                 "IPS Nittedal Jobbspesialist"/"Metodeveileder" ligger under
 *                 Fagansvarlig-rollen i hierarkiet.
 *
 *                 Forutsetninger:
 *                   - UserRole.Name samsvarer med ips_Team__c.Name (f.eks. "IPS Ålesund"),
 *                     eventuelt med suffiksene " Jobbspesialist"/" Metodeveileder" fjernet
 *                   - Teams er allerede opprettet i org
 *
 *                 Kjør: sf apex run --file scripts/apex/createTeamMembers.apex
 **/

final String FAGANSVARLIG_ROLE_PREFIX = 'Fagansvarlig';
final String FAGANSVARLIG_ROLE_VALUE = 'Fagansvarlig';

// Suffikser som kan forekomme på rollenavn under en Fagansvarlig-rolle, men
// som ikke er en del av selve team-navnet.
final List<String> ROLE_NAME_SUFFIXES = new List<String>{
    ' Jobbspesialist',
    ' Metodeveileder'
};

/**
 * @description Fjerner kjente rolle-suffikser (" Jobbspesialist", " Metodeveileder")
 *              fra et rollenavn og slår opp resultatet mot team-navn.
 */
Id resolveTeamId(String roleName, Map<String, Id> teamIdByName, List<String> suffixes) {
    if (roleName == null) {
        return null;
    }
    if (teamIdByName.containsKey(roleName)) {
        return teamIdByName.get(roleName);
    }
    for (String suffix : suffixes) {
        if (roleName.endsWith(suffix)) {
            String candidateTeamName = roleName.substring(0, roleName.length() - suffix.length());
            if (teamIdByName.containsKey(candidateTeamName)) {
                return teamIdByName.get(candidateTeamName);
            }
        }
    }
    return null;
}

ips_Team_Member__c buildTeamMember(User u, Id teamId, String role) {
    return new ips_Team_Member__c(
        ips_User__c = u.Id,
        ips_Team__c = teamId,
        ips_Role__c = role,
        ips_NAV_Ident__c = u.CRM_NAV_Ident__c,
        // Unik nøkkel per bruker+team — gjør operasjonen idempotent
        ips_Unique_User_Key__c = u.Id + '_' + teamId
    );
}

/**
 * @description Finner alle team som ligger under en Fagansvarlig-rolle i
 *              rollehierarkiet (uansett dybde), og legger til én
 *              ips_Team_Member__c med rollen "Fagansvarlig" per team.
 */
void addFagansvarligTeamMembers(
    User u,
    Map<String, Id> teamIdByName,
    Map<Id, List<Id>> childRoleIdsByParentId,
    Map<Id, UserRole> roleById,
    List<String> suffixes,
    List<ips_Team_Member__c> toUpsert,
    List<String> skipped
) {
    Set<Id> teamIds = new Set<Id>();
    Set<Id> visitedRoleIds = new Set<Id>();
    List<Id> queue = new List<Id>();
    if (childRoleIdsByParentId.containsKey(u.UserRoleId)) {
        queue.addAll(childRoleIdsByParentId.get(u.UserRoleId));
    }

    while (!queue.isEmpty()) {
        Id currentRoleId = queue.remove(0);
        if (visitedRoleIds.contains(currentRoleId)) {
            continue;
        }
        visitedRoleIds.add(currentRoleId);

        UserRole currentRole = roleById.get(currentRoleId);
        if (currentRole == null) {
            continue;
        }

        Id teamId = resolveTeamId(currentRole.Name, teamIdByName, suffixes);
        if (teamId != null) {
            teamIds.add(teamId);
        }

        if (childRoleIdsByParentId.containsKey(currentRoleId)) {
            queue.addAll(childRoleIdsByParentId.get(currentRoleId));
        }
    }

    if (teamIds.isEmpty()) {
        skipped.add(u.Name + ' – fant ingen team under Fagansvarlig-rollen: "' + u.UserRole?.Name + '"');
        return;
    }

    for (Id teamId : teamIds) {
        toUpsert.add(buildTeamMember(u, teamId, FAGANSVARLIG_ROLE_VALUE));
    }
}

final Set<String> TARGET_PROFILES = new Set<String>{
    'NAV IPS Jobbspesialist',
    'NAV IPS Metodeveileder',
    'NAV UO Jobbspesialist',
    'NAV UO Metodeveileder'
};

// --- Hent brukere ---
List<User> users = [
    SELECT Id, Name, CRM_NAV_Ident__c, UserRoleId, UserRole.Name, Profile.Name
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

// --- Hent rollehierarkiet slik at vi kan finne alle roller (og dermed team)
//     som ligger under en Fagansvarlig-rolle ---
Map<Id, UserRole> roleById = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
Map<Id, List<Id>> childRoleIdsByParentId = new Map<Id, List<Id>>();
for (UserRole role : roleById.values()) {
    if (role.ParentRoleId == null) {
        continue;
    }
    if (!childRoleIdsByParentId.containsKey(role.ParentRoleId)) {
        childRoleIdsByParentId.put(role.ParentRoleId, new List<Id>());
    }
    childRoleIdsByParentId.get(role.ParentRoleId).add(role.Id);
}

// --- Bygg Team Member-records ---
List<ips_Team_Member__c> toUpsert = new List<ips_Team_Member__c>();
List<String> skipped = new List<String>();

for (User u : users) {
    String roleName = u.UserRole?.Name;
    String profileName = u.Profile?.Name;
    String role = profileToRole.get(profileName);

    if (role == null) {
        skipped.add(u.Name + ' – ukjent profil: "' + profileName + '"');
        continue;
    }

    if (roleName != null && roleName.startsWith(FAGANSVARLIG_ROLE_PREFIX)) {
        addFagansvarligTeamMembers(u, teamIdByName, childRoleIdsByParentId, roleById, ROLE_NAME_SUFFIXES, toUpsert, skipped);
        continue;
    }

    Id teamId = resolveTeamId(roleName, teamIdByName, ROLE_NAME_SUFFIXES);
    if (teamId == null) {
        skipped.add(u.Name + ' – fant ikke team med navn: "' + roleName + '"');
        continue;
    }

    toUpsert.add(buildTeamMember(u, teamId, role));
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
