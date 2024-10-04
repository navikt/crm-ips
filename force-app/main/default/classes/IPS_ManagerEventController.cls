public without sharing class IPS_ManagerEventController {
    /**
     * Returns list of IPS jobbspecialists managed by the current user.
     * @return  List of IPS jobbspecialist
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerUsers> getIPSUsersManagedByCurrentUser() {
        return IPS_UserManagementService.getIPSUsersManagedByCurrentUser();
    }

    /**
     * Returns list of AMS jobbspecialists managed by the current user.
     * @return List of AMS jobbspecialist
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerUsers> getAMSUsersManagedByCurrentUser() {
        return IPS_UserManagementService.getAMSUsersManagedByCurrentUser();
    }

    /**
     * Returns events for the current week for users managed by the current user.
     * @return List of events
     */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerEvent> getEventsForCurrentWeek() {
        return IPS_EventManagementService.getEventsForCurrentWeek();
    }
}
