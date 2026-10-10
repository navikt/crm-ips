@IsTest
private class IPS_NewActivityControllerTest {
    @TestSetup
    static void makeData() {
        insert IPS_TestDataFactory.createPerson();
        Id participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555'].CRM_Account__c;

        Work_Trail__c ceTrail = IPS_TestDataFactory.createJobbspor(participantId);
        ceTrail.RecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName()
            .get('CE_Customized_Employment')
            .getRecordTypeId();
        ceTrail.ips_Status__c = 'Referred';

        Work_Trail__c ipsTrail = IPS_TestDataFactory.createJobbspor(participantId);
        insert new List<Work_Trail__c>{ ceTrail, ipsTrail };
    }

    private static Id getTrailId(String recordTypeName) {
        return [SELECT Id FROM Work_Trail__c WHERE RecordType.DeveloperName = :recordTypeName LIMIT 1].Id;
    }

    private static Map<String, IPS_NewActivityController.MenuGroup> byKey(
        List<IPS_NewActivityController.MenuGroup> groups
    ) {
        Map<String, IPS_NewActivityController.MenuGroup> result = new Map<String, IPS_NewActivityController.MenuGroup>();
        for (IPS_NewActivityController.MenuGroup menuGroup : groups) {
            result.put(menuGroup.key, menuGroup);
        }
        return result;
    }

    @IsTest
    static void getMenu_ceWorkTrail_returnsGroupedActivitiesLinkedToWorkTrail() {
        Id trailId = getTrailId('CE_Customized_Employment');

        Test.startTest();
        List<IPS_NewActivityController.MenuGroup> groups = IPS_NewActivityController.getMenu(trailId);
        Test.stopTest();

        Map<String, IPS_NewActivityController.MenuGroup> groupsByKey = byKey(groups);
        Assert.areEqual('Meeting', groups[0].key, 'Møte skal komme først');
        Assert.areEqual(3, groupsByKey.get('Meeting').options.size(), 'Møte skal ha tre typer');
        Assert.areEqual(1, groupsByKey.get('Task').options.size(), 'Oppgave skal ha ett valg');
        Assert.areEqual(1, groupsByKey.get('SubGoal').options.size(), 'Delmål skal ha ett valg');
        Assert.areEqual(1, groupsByKey.get('ContactLog').options.size(), 'Kontaktlogg skal ha ett valg');

        for (IPS_NewActivityController.MenuGroup menuGroup : groups) {
            for (IPS_NewActivityController.MenuOption option : menuGroup.options) {
                if (option.flowApiName != null) {
                    continue;
                }
                Assert.areEqual(
                    String.valueOf(trailId),
                    option.defaultFieldValues.get('WhatId'),
                    'Aktiviteten skal knyttes til jobbsporet'
                );
                Assert.isNotNull(option.recordTypeId, 'Postype skal være satt for ' + option.key);
                Assert.isNotNull(option.label, 'Tekst skal være satt for ' + option.key);
            }
        }

        IPS_NewActivityController.MenuOption subGoal = groupsByKey.get('SubGoal').options[0];
        Assert.areEqual('Task', subGoal.objectApiName, 'Delmål skal opprette Task');
        Assert.areEqual(
            'Delmål (av hovedmål)',
            subGoal.defaultFieldValues.get('Type_of_Task_IPSUO__c'),
            'Delmål skal ha riktig type'
        );

        IPS_NewActivityController.MenuOption contactLog = groupsByKey.get('ContactLog').options[0];
        Assert.areEqual(
            String.valueOf(Date.today()),
            contactLog.defaultFieldValues.get('ActivityDate'),
            '{today} skal byttes ut med dagens dato'
        );
    }

    @IsTest
    static void getMenu_ceWorkTrail_includesOpportunityScreenFlow() {
        Test.startTest();
        List<IPS_NewActivityController.MenuGroup> groups = IPS_NewActivityController.getMenu(
            getTrailId('CE_Customized_Employment')
        );
        Test.stopTest();

        IPS_NewActivityController.MenuGroup opportunity = byKey(groups).get('Opportunity');
        Assert.isNotNull(opportunity, 'Ny mulighet skal være tilgjengelig på CE-jobbspor');
        Assert.areEqual(1, opportunity.options.size(), 'Ny mulighet skal ha ett valg');
        IPS_NewActivityController.MenuOption option = opportunity.options[0];
        Assert.areEqual('Ny mulighet', opportunity.label, 'Gruppen skal vise Ny mulighet');
        Assert.areEqual('Ny mulighet', option.label, 'Knappen skal vise Ny mulighet');
        Assert.areEqual('CE_New_Opportunity', option.flowApiName, 'Valget skal åpne skjermflyten');
        Assert.areEqual('utility:light_bulb', option.icon, 'Valget skal ha et ikon');
        Assert.isNull(option.objectApiName, 'Flytvalget skal ikke åpne et skjema for ny post');
        Assert.areEqual('Opportunity', groups[groups.size() - 1].key, 'Ny mulighet skal komme sist');
    }

    @IsTest
    static void getMenu_oppstartsdatoFilled_hidesStartupMeeting() {
        Work_Trail__c trail = new Work_Trail__c(
            Id = getTrailId('CE_Customized_Employment'),
            Oppstartsdato__c = Datetime.now()
        );
        update trail;

        Test.startTest();
        List<IPS_NewActivityController.MenuGroup> groups = IPS_NewActivityController.getMenu(trail.Id);
        Test.stopTest();

        List<IPS_NewActivityController.MenuOption> meetings = byKey(groups).get('Meeting').options;
        Assert.areEqual(2, meetings.size(), 'Oppstartsmøte skal skjules når oppstartsdato er satt');
        for (IPS_NewActivityController.MenuOption option : meetings) {
            Assert.areNotEqual('CE_Startup_Meeting', option.key, 'Oppstartsmøte skal ikke vises');
        }
    }

    @IsTest
    static void getMenu_workTrailWithoutMenu_returnsEmptyList() {
        Id trailId = getTrailId('IPS');

        Test.startTest();
        List<IPS_NewActivityController.MenuGroup> groups = IPS_NewActivityController.getMenu(trailId);
        Test.stopTest();

        Assert.isTrue(groups.isEmpty(), 'IPS-jobbspor skal ikke ha meny ennå');
    }

    @IsTest
    static void getMenu_invalidRecordId_returnsEmptyList() {
        Id accountId = [SELECT CRM_Account__c FROM Person__c LIMIT 1].CRM_Account__c;

        Test.startTest();
        List<IPS_NewActivityController.MenuGroup> nullGroups = IPS_NewActivityController.getMenu(null);
        List<IPS_NewActivityController.MenuGroup> accountGroups = IPS_NewActivityController.getMenu(accountId);
        Test.stopTest();

        Assert.isTrue(nullGroups.isEmpty(), 'Tom recordId skal gi tom meny');
        Assert.isTrue(accountGroups.isEmpty(), 'Andre objekter enn jobbspor skal gi tom meny');
    }

    @IsTest
    static void getDefaultFieldValues_skipsInvalidValuesAndReplacesToday() {
        Id trailId = getTrailId('CE_Customized_Employment');
        TimelineParent__mdt parent = new TimelineParent__mdt(SObjectRelationshipField__c = 'WhatId');
        TimelineChild__mdt child = new TimelineChild__mdt(
            SObjectTypeField__c = 'Type_of_Task_IPSUO__c',
            SObjectTypeValue__c = 'Oppgave',
            CreateableObject_Field1__c = 'ActivityDate',
            CreateableObject_Value1__c = '{today}',
            CreateableObject_Field2__c = 'Status',
            CreateableObject_Value2__c = 'null',
            CreateableObject_Field3__c = 'Multi__c',
            CreateableObject_Value3__c = 'a;b'
        );

        Test.startTest();
        Map<String, String> values = IPS_NewActivityController.getDefaultFieldValues(parent, child, trailId);
        Test.stopTest();

        Assert.areEqual(3, values.size(), 'Kun gyldige verdier skal tas med');
        Assert.areEqual(String.valueOf(trailId), values.get('WhatId'), 'Relasjonsfeltet skal peke til jobbsporet');
        Assert.areEqual('Oppgave', values.get('Type_of_Task_IPSUO__c'), 'Typefeltet skal settes');
        Assert.areEqual(String.valueOf(Date.today()), values.get('ActivityDate'), '{today} skal byttes ut');
    }
}