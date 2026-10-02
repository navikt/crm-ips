/**
 * @description  : Fanger endringer i leder på ips_Team_Member__c og starter synkronisering.
 * @author       : Håkon Kavli
 * @since        : 0.550.0
 **/
trigger IPS_TeamMemberManagerSync on ips_Team_Member__c (after insert, after update) {
    List<ips_Team_Member__c> relevant = new List<ips_Team_Member__c>();
    for (Id recordId : Trigger.newMap.keySet()) {
        ips_Team_Member__c newRecord = Trigger.newMap.get(recordId);
        if (Trigger.isInsert) {
            relevant.add(newRecord);
            continue;
        }
        ips_Team_Member__c oldRecord = Trigger.oldMap.get(recordId);
        // Uvedkomende feltendringer skal ikke sette i gang synkronisering.
        if (
            newRecord.ips_User__c != oldRecord.ips_User__c ||
            newRecord.ips_Manager_Id__c != oldRecord.ips_Manager_Id__c
        ) {
            relevant.add(newRecord);
        }
    }
    if (!relevant.isEmpty()) {
        IPS_TeamMemberManagerSyncService.run(relevant);
    }
}
