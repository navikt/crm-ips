/**
 * @description  :Oppretter ips_Team_Member__c-oppføringer for aktive brukere
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
 * @author       : Håkon Kavli
 **/
public with sharing class IPS_CreateTeamMembersHelper {
    // Hent alle teams fra org ved lasting av klassen
    public static List<ips_Team__c> teams = [SELECT Id, Name FROM ips_Team__c WITH SYSTEM_MODE];
    public static Map<String, Id> teamIdByName = getTeamIdByName();
    private static Map<Id, ips_Team__c> teamById = getTeamById();
    public static final Set<String> TARGET_PROFILES = new Set<String>{
        'NAV IPS Jobbspesialist',
        'NAV IPS Metodeveileder',
        'NAV UO Jobbspesialist',
        'NAV UO Metodeveileder'
    };

    public static final String FAGANSVARLIG_ROLE_PREFIX = 'Fagansvarlig';
    public static final String FAGANSVARLIG_ROLE_VALUE = 'Fagansvarlig';
    public static final String ULTIMATE_PARENT_ROLE_NAME = 'IPS/AMS';

    // Suffikser som kan forekomme på rollenavn under en Fagansvarlig-rolle, men
    // som ikke er en del av selve team-navnet.
    public static final List<String> ROLE_NAME_SUFFIXES = new List<String>{
        ' Jobbspesialist Ekstern',
        ' Jobbspesialist (kommune) Ekstern',
        ' Jobbspesialist (spes.helse) Ekstern',
        ' Jobbspesialist',
        ' Metodeveileder'
    };

    public static Map<String, String> profileToRole = new Map<String, String>{
        'NAV IPS Jobbspesialist' => 'Jobbspesialist',
        'NAV IPS Metodeveileder' => 'Metodeveileder',
        'NAV UO Jobbspesialist' => 'Jobbspesialist',
        'NAV UO Metodeveileder' => 'Metodeveileder'
    };

    // --- Hent alle relevante teams (nøkkel = Name) ---
    public static Map<String, Id> getTeamIdByName() {
        Map<String, Id> teamIdByName = new Map<String, Id>();
        for (ips_Team__c team : teams) {
            teamIdByName.put(team.Name, team.Id);
        }
        return teamIdByName;
    }

    private static Map<Id, ips_Team__c> getTeamById() {
        Map<Id, ips_Team__c> teamById = new Map<Id, ips_Team__c>();
        for (ips_Team__c team : teams) {
            teamById.put(team.Id, team);
        }
        return teamById;
    }

    // --- Get all relevant IPS/AMS roles in the hierarchy, skip roles without active users ---
    public static Map<Id, UserRole> salesforceRolesById = new Map<Id, UserRole>(
        [
            SELECT Id, Name, ParentRoleId
            FROM UserRole
            WHERE
                ParentRole.ParentRole.Name = :ULTIMATE_PARENT_ROLE_NAME
                OR ParentRole.ParentRole.ParentRole.Name = :ULTIMATE_PARENT_ROLE_NAME
                OR ParentRole.ParentRole.ParentRole.ParentRole.Name = :ULTIMATE_PARENT_ROLE_NAME
            WITH SYSTEM_MODE
            ORDER BY Name
        ]
    );

    // --- Get all child role IDs for each parent role ID ---
    public static Map<Id, List<Id>> childRoleIdsByParentId = new Map<Id, List<Id>>();
    static {
        for (UserRole role : salesforceRolesById.values()) {
            if (role.ParentRoleId == null) {
                continue;
            }
            if (!childRoleIdsByParentId.containsKey(role.ParentRoleId)) {
                childRoleIdsByParentId.put(role.ParentRoleId, new List<Id>());
            }
            childRoleIdsByParentId.get(role.ParentRoleId).add(role.Id);
        }
    }
    public class UnknownTeamException extends Exception {
    }

    /**
     * @description Returns the list of team members that would be created for the given users.
     * @author Håkon Kavli | 11-27-2026
     * @param usersToCreateTeamMembersFor List of users for whom team members should be created
     * @return List<ips_Team_Member__c> Resulting list of team members to be created
     **/
    public List<ips_Team_Member__c> getTeamMembersToCreate(List<User> usersToCreateTeamMembersFor) {
        return createTeamMembers(usersToCreateTeamMembersFor);
    }

    /**
     * @description Processes a list of users and creates corresponding team members based on their roles and profiles.
     * @author Håkon Kavli | 11-27-2026
     * @param usersToCreateTeamMembersFor List of users for whom team members should be created
     * @return List<ips_Team_Member__c> Resulting list of team members to be created
     **/
    public List<ips_Team_Member__c> createTeamMembers(List<User> usersToCreateTeamMembersFor) {
        List<ips_Team_Member__c> teamMembersToCreate = new List<ips_Team_Member__c>();
        Integer missingRoleCount = 0;
        Integer missingTeamCount = 0;

        for (User u : usersToCreateTeamMembersFor) {
            String salesforceRole = u.UserRole?.Name;
            if (salesforceRole == null) {
                missingRoleCount++;
                continue;
            }

            // Process fagansvarlig roles separately
            if (salesforceRole.startsWith(FAGANSVARLIG_ROLE_PREFIX)) {
                List<ips_Team_Member__c> fagansvarligTeamMembers = addFagansvarligTeamMembers(
                    u,
                    teamIdByName,
                    childRoleIdsByParentId,
                    salesforceRolesById,
                    ROLE_NAME_SUFFIXES
                );
                if (fagansvarligTeamMembers.isEmpty()) {
                    missingTeamCount++;
                }
                teamMembersToCreate.addAll(fagansvarligTeamMembers);
                // Process next user in the list
                continue;
            }
            // Determine the team role based on the user's profile name
            String teamRole = profileToRole.get(u.Profile?.Name);

            // Check if user is External
            Boolean isExternal = isExternal(salesforceRole);
            Id teamId = resolveTeamId(salesforceRole, teamIdByName, ROLE_NAME_SUFFIXES);
            if (teamId == null) {
                missingTeamCount++;
                continue;
            }
            teamMembersToCreate.add(buildTeamMember(u, teamId, teamRole, isExternal));
        }

        if (missingRoleCount > 0 || missingTeamCount > 0) {
            LoggerUtility logger = new LoggerUtility();
            logger.info(
                'Skipped users: ' +
                    missingRoleCount +
                    ' without a role, ' +
                    missingTeamCount +
                    ' without a matching team.',
                CRM_ApplicationDomain.Domain.IPS
            );
            logger.publishSynch();
        }

        return teamMembersToCreate;
    }

    /**
     * @description Helper method to determine if a Salesforce role is considered external.
     * @author Håkon Kavli | 11-27-2026
     * @param salesforceRole
     * @return Boolean true if the role is considered external, false otherwise.
     **/
    public static Boolean isExternal(String salesforceRole) {
        return salesforceRole != null && salesforceRole.endsWith('Ekstern');
    }

    /**
     * @description Helper method to remove known role suffixes (" Jobbspesialist", " Metodeveileder")
     *              from a role name and looks up the result against team names.
     */
    public static Id resolveTeamId(String roleName, Map<String, Id> teamIdByName, List<String> suffixes) {
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

    /**
     * @description Helper method to build an ips_Team_Member__c record for a given user, team, and role.
     */
    public ips_Team_Member__c buildTeamMember(User u, Id teamId, String role, Boolean isExternal) {
        ips_Team__c team = teamById.get(teamId);
        if (team == null) {
            throw new UnknownTeamException('No team was found for the supplied team Id.');
        }

        return new ips_Team_Member__c(
            ips_Is_External__c = isExternal,
            ips_NAV_Ident__c = u.CRM_NAV_Ident__c,
            ips_Role__c = role,
            ips_Start_Date__c = Date.valueOf(u.CreatedDate),
            ips_Team__c = teamId,
            // Samme unike nøkkel som aktiv Flow: ident + teamnavn.
            ips_Unique_User_Key__c = u.CRM_NAV_Ident__c + '_' + team.Name,
            ips_User__c = u.Id
        );
    }

    /**
     * @description Finds all teams under a "Fagansvarlig" role in
     *              the role hierarchy (regardless of depth), and adds one
     *              ips_Team_Member__c with the role "Fagansvarlig" per team.
     */
    public List<ips_Team_Member__c> addFagansvarligTeamMembers(
        User u,
        Map<String, Id> teamIdByName,
        Map<Id, List<Id>> childRoleIdsByParentId,
        Map<Id, UserRole> roleById,
        List<String> suffixes
    ) {
        List<ips_Team_Member__c> toUpsert = new List<ips_Team_Member__c>();
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
            // Add child roles to the queue for further processing
            if (childRoleIdsByParentId.containsKey(currentRoleId)) {
                queue.addAll(childRoleIdsByParentId.get(currentRoleId));
            }
        }

        for (Id teamId : teamIds) {
            toUpsert.add(buildTeamMember(u, teamId, FAGANSVARLIG_ROLE_VALUE, false));
        }
        return toUpsert;
    }
}
