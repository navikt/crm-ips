/**
 * @description Service class for managing IPS_Manager_Daily_Follow_Up permission set
 *              based on Work Trail manager change events. Called from the
 *              IPS_ManagerChange_UpdatePermissions platform event-triggered flow.
 *
 *              Logic:
 *              - New manager: assign IPS_Manager_Daily_Follow_Up if not already assigned.
 *              - Former manager: remove IPS_Manager_Daily_Follow_Up if they no longer
 *                manage any active Work Trail users (users with IPS_Is_Work_Trail_User).
 *
 *              Uses @future to avoid MIXED_DML when called from non-platform-event contexts.
 * @author Håkon Kavli
 */
public without sharing class IPS_ManagerPermissionService {
    @TestVisible
    private static final String MANAGER_PERM_SET = 'IPS_Manager_Daily_Follow_Up';
    @TestVisible
    private static final String WORK_TRAIL_PERM_SET = 'IPS_Is_Work_Trail_User';

    public class ManagerChangeRequest {
        @InvocableVariable(label='New Manager Id' description='Salesforce User Id of the new manager' required=true)
        public String newManagerId;

        @InvocableVariable(label='Former Manager Id' description='Salesforce User Id of the former manager')
        public String formerManagerId;
    }

    /**
     * @description Invocable entry point called by IPS_ManagerChange_UpdatePermissions flow.
     *              Delegates to @future to handle PermissionSetAssignment DML safely.
     * @param requests List of ManagerChangeRequest with newManagerId and formerManagerId
     */
    @InvocableMethod(
        label='Update Manager Daily Follow Up Permission'
        description='Assigns IPS_Manager_Daily_Follow_Up to new manager if missing; removes it from former manager if they have no remaining Work Trail users'
        category='IPS Permission Management'
    )
    public static void updateManagerPermissions(List<ManagerChangeRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }

        Set<String> newManagerIds = new Set<String>();
        Set<String> formerManagerIds = new Set<String>();

        for (ManagerChangeRequest req : requests) {
            if (String.isNotBlank(req.newManagerId)) {
                newManagerIds.add(req.newManagerId);
            }
            if (String.isNotBlank(req.formerManagerId)) {
                formerManagerIds.add(req.formerManagerId);
            }
        }

        handlePermissionChanges(new List<String>(newManagerIds), new List<String>(formerManagerIds));
    }

    @future
    @TestVisible
    private static void handlePermissionChanges(
        List<String> newManagerIdList,
        List<String> formerManagerIdList
    ) {
        Map<String, Id> permSetIdByName = new Map<String, Id>();
        for (PermissionSet ps : [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :new Set<String>{ MANAGER_PERM_SET, WORK_TRAIL_PERM_SET }
        ]) {
            permSetIdByName.put(ps.Name, ps.Id);
        }

        if (
            !permSetIdByName.containsKey(MANAGER_PERM_SET) ||
            !permSetIdByName.containsKey(WORK_TRAIL_PERM_SET)
        ) {
            return;
        }

        Id managerPermSetId = permSetIdByName.get(MANAGER_PERM_SET);
        Id workTrailPermSetId = permSetIdByName.get(WORK_TRAIL_PERM_SET);

        Set<Id> newManagerIds = toIdSet(newManagerIdList);
        Set<Id> formerManagerIds = toIdSet(formerManagerIdList);

        assignToNewManagers(newManagerIds, managerPermSetId);
        removeFromFormerManagersIfNoWorkTrailUsers(formerManagerIds, managerPermSetId, workTrailPermSetId);
    }

    private static void assignToNewManagers(Set<Id> newManagerIds, Id managerPermSetId) {
        if (newManagerIds.isEmpty()) {
            return;
        }

        Set<Id> alreadyAssigned = new Set<Id>();
        for (PermissionSetAssignment psa : [
            SELECT AssigneeId
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSetId AND AssigneeId IN :newManagerIds
        ]) {
            alreadyAssigned.add(psa.AssigneeId);
        }

        List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
        for (Id managerId : newManagerIds) {
            if (!alreadyAssigned.contains(managerId)) {
                toInsert.add(
                    new PermissionSetAssignment(
                        AssigneeId = managerId,
                        PermissionSetId = managerPermSetId
                    )
                );
            }
        }

        if (!toInsert.isEmpty()) {
            CRM_DatabaseOperations cdo = new CRM_DatabaseOperations()
                .setDomain(CRM_ApplicationDomain.Domain.IPS);
            cdo.insertRecords(toInsert);
        }
    }

    private static void removeFromFormerManagersIfNoWorkTrailUsers(
        Set<Id> formerManagerIds,
        Id managerPermSetId,
        Id workTrailPermSetId
    ) {
        if (formerManagerIds.isEmpty()) {
            return;
        }

        // Map each active reportee to their manager among former managers
        Map<Id, Id> managerByUser = new Map<Id, Id>();
        for (User u : [
            SELECT Id, ManagerId
            FROM User
            WHERE ManagerId IN :formerManagerIds AND IsActive = TRUE
        ]) {
            managerByUser.put(u.Id, u.ManagerId);
        }

        // Count active Work Trail users per former manager
        Map<Id, Integer> workTrailCountByManager = new Map<Id, Integer>();
        for (Id mgr : formerManagerIds) {
            workTrailCountByManager.put(mgr, 0);
        }

        if (!managerByUser.isEmpty()) {
            for (PermissionSetAssignment psa : [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE PermissionSetId = :workTrailPermSetId AND AssigneeId IN :managerByUser.keySet()
            ]) {
                Id managerId = managerByUser.get(psa.AssigneeId);
                workTrailCountByManager.put(managerId, workTrailCountByManager.get(managerId) + 1);
            }
        }

        // Collect managers who have zero remaining Work Trail users
        Set<Id> managersToRemoveFrom = new Set<Id>();
        for (Id managerId : workTrailCountByManager.keySet()) {
            if (workTrailCountByManager.get(managerId) == 0) {
                managersToRemoveFrom.add(managerId);
            }
        }

        if (managersToRemoveFrom.isEmpty()) {
            return;
        }

        List<PermissionSetAssignment> toDelete = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :managerPermSetId AND AssigneeId IN :managersToRemoveFrom
        ];
        if (!toDelete.isEmpty()) {
            CRM_DatabaseOperations cdo = new CRM_DatabaseOperations()
                .setDomain(CRM_ApplicationDomain.Domain.IPS);
            cdo.deleteRecords(toDelete);
        }
    }

    private static Set<Id> toIdSet(List<String> idStrings) {
        Set<Id> idSet = new Set<Id>();
        for (String s : idStrings) {
            if (String.isNotBlank(s)) {
                try {
                    idSet.add((Id) s);
                } catch (Exception e) {
                    // Skip malformed IDs
                }
            }
        }
        return idSet;
    }
}
