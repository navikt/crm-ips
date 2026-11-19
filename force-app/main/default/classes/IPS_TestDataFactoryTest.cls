@IsTest
private class IPS_TestDataFactoryTest {
    @IsTest
    static void test_factoryMethods_assignExpectedRecordTypes() {
        Set<String> developerNames = new Set<String>{
            'Employer', 'IPS', 'ips_Supported_Employment', 'IPS_Event', 'Ips_uo_Deltakermote', 'IPS_Task'
        };
        Map<String, Id> recordTypeIds = new Map<String, Id>();
        for (RecordType recordType : [
            SELECT Id, SObjectType, DeveloperName
            FROM RecordType
            WHERE DeveloperName IN :developerNames
        ]) {
            recordTypeIds.put(recordType.SObjectType + '.' + recordType.DeveloperName, recordType.Id);
        }

        Test.startTest();
        Account employer = IPS_TestDataFactory.createEmployerAccount();
        Integer queriesAfterCacheLoad = Limits.getQueries();
        Work_Trail__c ipsTrail = IPS_TestDataFactory.createJobbspor(null);
        Work_Trail__c uoTrail = IPS_TestDataFactory.createUOJobbspor(null);
        Event employerEvent = IPS_TestDataFactory.createEmployerEventWithoutParticipant(null);
        Event employerParticipantEvent = IPS_TestDataFactory.createEmployerEventWithParticipant(null, null, null);
        Event participantEvent = IPS_TestDataFactory.createParticipantEvent(null, null);
        Event participantOwnerEvent = IPS_TestDataFactory.createParticipantEventWithOwner(null, null);
        Task goal = IPS_TestDataFactory.creategoal(null);
        Task passiveActivation = IPS_TestDataFactory.createPassiveActivateGoal(null);
        Task passiveDeactivation = IPS_TestDataFactory.createPassiveDeactivateGoal(null);
        Task history = IPS_TestDataFactory.createhistory(null);
        Assert.areEqual(queriesAfterCacheLoad, Limits.getQueries(), 'Factory calls should reuse the record type cache');
        Test.stopTest();

        Assert.areEqual(recordTypeIds.get('Account.Employer'), employer.RecordTypeId, 'Employer record type');
        Assert.areEqual(recordTypeIds.get('Work_Trail__c.IPS'), ipsTrail.RecordTypeId, 'IPS trail record type');
        Assert.areEqual(
            recordTypeIds.get('Work_Trail__c.ips_Supported_Employment'),
            uoTrail.RecordTypeId,
            'Supported employment trail record type'
        );
        Assert.areEqual(recordTypeIds.get('Event.IPS_Event'), employerEvent.RecordTypeId, 'Employer event record type');
        Assert.areEqual(
            recordTypeIds.get('Event.IPS_Event'),
            employerParticipantEvent.RecordTypeId,
            'Employer event with participant record type'
        );
        Assert.areEqual(
            recordTypeIds.get('Event.Ips_uo_Deltakermote'),
            participantEvent.RecordTypeId,
            'Participant event record type'
        );
        Assert.areEqual(
            recordTypeIds.get('Event.Ips_uo_Deltakermote'),
            participantOwnerEvent.RecordTypeId,
            'Participant event with owner record type'
        );
        Assert.areEqual(recordTypeIds.get('Task.IPS_Task'), goal.RecordTypeId, 'Goal record type');
        Assert.areEqual(
            recordTypeIds.get('Task.IPS_Task'),
            passiveActivation.RecordTypeId,
            'Passive activation record type'
        );
        Assert.areEqual(
            recordTypeIds.get('Task.IPS_Task'),
            passiveDeactivation.RecordTypeId,
            'Passive deactivation record type'
        );
        Assert.areEqual(recordTypeIds.get('Task.IPS_Task'), history.RecordTypeId, 'History record type');
    }
}
