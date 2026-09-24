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
            		ips_Applying_Department__c,
            		ips_Behandlingsteam__c,
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
                eventJobbspor.JobbsporApplyingDepartment__c =t.ips_Applying_Department__c;
                eventJobbspor.JobbsporService__c = 'AMS';
                eventJobbspor.ParticipantsMainGoal__c = translateFieldValue(t.ips_UO_Service__c, 'MAINGOAL');
            }
            if(t.recordtype.developername == 'IPS'){
                eventJobbspor.JobbsporApplyingDepartment__c =t.ips_Behandlingsteam__c;
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
    
    public static Integer getMinutesIncludingLastDay20Hours() {
        
        Date inputDate = Date.today() ;
        // Get the first day of the next month
        Date firstDayOfNextMonth = inputDate.toStartOfMonth().addMonths(1);
        // Subtract one day to get the last day of the current month
        Date lastDateOfMonth = firstDayOfNextMonth.addDays(-1);
        
       //Integer totalDaysInBetween = lastDateOfMonth.day()-inputDate.day();
       Integer totalDaysInBetween = firstDayOfNextMonth.day()-inputDate.day();
 	   Integer totalMinutesIn = totalDaysInBetween * 1440;        

        Integer additionalMinutes = 12 * 60;

        // Return the total minutes including the additional 20 hours
        return totalMinutesIn - additionalMinutes;
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