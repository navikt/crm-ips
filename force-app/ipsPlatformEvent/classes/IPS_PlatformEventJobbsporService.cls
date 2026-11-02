public without sharing class IPS_PlatformEventJobbsporService {
    public static void getWorkTrailToPlatformEvent(List<Work_Trail__c> trailList){
        
        Set<Id> workTrailIdSet = new Set<Id>();
        for (Work_Trail__c trail : trailList) {
            workTrailIdSet.add(trail.Id);
        }
        
        List<IPSJobbsporEvent__e> eventJobbsporList = new List<IPSJobbsporEvent__e>();
        Set<Id> ownerIdSet = new Set<Id>();
        for (Work_Trail__c trail : trailList) {
            ownerIdSet.add(trail.OwnerId);
        }
        Map<Id, User> ownerById = new Map<Id, User>();
        for (User userRecord : [
                SELECT Id, Department, CompanyName
                FROM User
                WHERE Id IN :ownerIdSet
        ]) {
            ownerById.put(userRecord.Id, userRecord);
        }
        
        List<Work_Trail__c> workTrailList = [
                SELECT 
                    id,
                    OwnerId,
                    CreatedDate,
                    ips_End_Date__c,
                    toLabel(End_Cause__c),
                    toLabel(ips_Other_end_cases__c),
                    ips_First_meeting_with_the_Employer_held__c,
                    recordtype.developername,
                    toLabel(ips_Status__c),
                    Passive_activate__c,
                    Passive_deactivate__c,
                    ips_Referred_date__c,
                    IPS_Personnummer__c,
                    toLabel(ips_Main_Goal_list__c),
                    toLabel(ips_UO_Service__c),
                    Oppstartsdato__c 
            FROM Work_trail__c
            WHERE Id IN :workTrailIdSet
        ];
        
        for(Work_Trail__c t:workTrailList){
            IPSJobbsporEvent__e eventJobbspor = new IPSJobbsporEvent__e();
            User ownerUser = ownerById.get(t.OwnerId);
            eventJobbspor.JobbsporId__c = hashStringWithController(t.Id);
            eventJobbspor.UserId__c = hashStringWithController(t.OwnerId);
            eventJobbspor.UserDepartmentName__c = ownerUser != null ? ownerUser.CompanyName : null;
            eventJobbspor.UserDepartmentNumber__c = ownerUser != null ? ownerUser.Department : null;
            eventJobbspor.JobbsporCreated__c = Date.valueOf(t.CreatedDate);
            eventJobbspor.JobbsporEndDate__c = t.ips_End_Date__c;
            eventJobbspor.JobbsporEndReason__c = translateFieldValue(t.End_Cause__c, 'ENDCAUSE');
            eventJobbspor.JobbsporEndReasonDetail__c = translateFieldValue(t.ips_Other_end_cases__c, 'ENDDETAILCAUSE');
            eventJobbspor.JobbsporFirstEmployeeMeeting__c = Date.valueOf(t.ips_First_meeting_with_the_Employer_held__c);
            eventJobbspor.JobbsporStatus__c = translateFieldValue(t.ips_Status__c, 'STATUS');
            eventJobbspor.ParticipantPassiveDateActivated__c = t.Passive_activate__c;
            eventJobbspor.ParticipantPassiveDateDeactivated__c = t.Passive_deactivate__c;
            eventJobbspor.ParticipantReferredDate__c = t.ips_Referred_date__c;
            eventJobbspor.ParticipantSCN__c = t.IPS_Personnummer__c;
            eventJobbspor.ParticipantStartDate__c = Date.valueOf(t.Oppstartsdato__c);
            if(t.recordtype.developername =='ips_Supported_Employment'){
                eventJobbspor.JobbsporService__c = 'AMS';
                eventJobbspor.ParticipantsMainGoal__c = translateFieldValue(t.ips_UO_Service__c, 'MAINGOAL');
            }
            if(t.recordtype.developername == 'IPS'){
                eventJobbspor.JobbsporService__c = 'IPS';
                eventJobbspor.ParticipantsMainGoal__c = translateFieldValue(t.ips_Main_Goal_list__c, 'MAINGOAL');
            }
            
            eventJobbsporList.add(eventJobbspor);
            
        }
       List<Database.SaveResult> results = EventBus.publish(eventJobbsporList);
       
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    String errormessage = 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage();
                    System.debug(errormessage);
                }
            }       
        }
    }

    public static void getUserRolesToPlatformEvent(List<User> users ){
        if (users == null || users.isEmpty()) {
            return;
        }

        List<IPSRoleUserEvent__e> eventList = new List<IPSRoleUserEvent__e>();
        for (User userRecord : users) {
            if (userRecord == null) {
                continue;
            }

            IPSRoleUserEvent__e eventUserRole = new IPSRoleUserEvent__e();
            eventUserRole.UserId__c = hashStringWithController(userRecord.Id);
            eventUserRole.UserProfileName__c = userRecord.Profile != null ? userRecord.Profile.Name : null;
            eventUserRole.isUserActive__c = userRecord.IsActive;
            eventUserRole.UserRoleName__c = getUserRoleName(userRecord);
            eventUserRole.UserRole__c = getUserRoleValue(userRecord);
            eventUserRole.UserService__c = getUserService(userRecord);
            eventUserRole.UserDepartmentNumber__c = userRecord.Department;
            eventUserRole.UserDepartmentName__c = userRecord.CompanyName;
            eventUserRole.RoleId__c = userRecord.UserRoleId;
            eventUserRole.RoleName__c = userRecord.UserRole != null ? userRecord.UserRole.Name : null;
            eventUserRole.RoleLastModifiedDate__c = userRecord.UserRole != null ? userRecord.UserRole.SystemModstamp : null;
            eventUserRole.UserStatus__c = userRecord.IsActive ? 'Active' : 'Inactive';
            eventUserRole.UserIsExternal__c = isExternalUser(userRecord.Profile != null ? userRecord.Profile.Name : null);

            eventList.add(eventUserRole);
        }

        if (eventList.isEmpty()) {
            return;
        }

        List<Database.SaveResult> results = EventBus.publish(eventList);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published user role event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
    }

    private static String getUserRoleName(User userRecord) {
        if (userRecord.UserRole == null || String.isBlank(userRecord.UserRole.Name)) {
            return null;
        }

        String roleName = userRecord.UserRole.Name;
        if (roleName.startsWith('AMS')) {
            return roleName.substring(3).replace('Jobbspesialist', '').replace('Metodeveileder', '').trim();
        }
        if (roleName.startsWith('IPS')) {
            return roleName.substring(3).replace('Jobbspesialist', '').replace('Metodeveileder', '').trim();
        }
        if (roleName.startsWith('Fagansvarlig')) {
            return roleName.substring(13).trim();
        }
        return null;
    }

    private static String getUserRoleValue(User userRecord) {
        String profileName = userRecord.Profile != null ? userRecord.Profile.Name : '';
        if (String.isBlank(profileName)) {
            return null;
        }

        if (profileName.contains('Metodeveileder')) {
            return 'Metodeveileder';
        }
        if (profileName.contains('Jobbspesialist')) {
            return 'Jobbspesialist';
        }
        return null;
    }

    private static String getUserService(User userRecord) {
        String profileName = userRecord.Profile != null ? userRecord.Profile.Name : '';
        if (String.isBlank(profileName)) {
            return null;
        }
        if (profileName.contains('IPS')) {
            return 'IPS';
        }
        if (profileName.contains('AMS')) {
            return 'AMS';
        }
        return null;
    }

    private static Boolean isExternalUser(String profileName) {
        return String.isNotBlank(profileName) && profileName.containsIgnoreCase('Ekstern');
    }
    
    
    private static String hashStringWithController(String inputString) {
        IPS_StringHasherController.eventRequest request = new IPS_StringHasherController.eventRequest();
        request.inputString = inputString;

        List<IPS_StringHasherController.FlowOutput> outputs = IPS_StringHasherController.hashString(
            new List<IPS_StringHasherController.eventRequest>{ request }
        );

        return outputs.isEmpty() ? null : outputs[0].hashString;
    }

    private static String translateFieldValue(String inputString, String fieldCategory) {
        if (String.isBlank(inputString)) {
            return '';
        }

        IPS_UtilityFlowTranslateController.Input input = new IPS_UtilityFlowTranslateController.Input();
        input.inputString = inputString;
        input.fieldCategory = fieldCategory;

        List<IPS_UtilityFlowTranslateController.Output> outputs = IPS_UtilityFlowTranslateController.translateString(
            new List<IPS_UtilityFlowTranslateController.Input>{ input }
        );

        return outputs.isEmpty() ? '' : outputs[0].outputString;
    }
}