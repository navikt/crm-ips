@IsTest
private class CE_NewOpportunityControllerTest {
    private static final String MAIN_THEME = 'Aktivitet og ledelse';
    private static final String OTHER_MAIN_THEME = 'Drift og mobilitet';

    @TestSetup
    static void makeData() {
        IPS_TestDataFactory.createAdminUserWithPermissionSet('Ce', 'Manager', 'CE_management');
        insert IPS_TestDataFactory.createPerson();
        Id participantId = [SELECT CRM_Account__c FROM Person__c WHERE Name = '12069755555'].CRM_Account__c;
        Id ceRecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName()
            .get('CE_Customized_Employment')
            .getRecordTypeId();

        Work_Trail__c trail = IPS_TestDataFactory.createJobbspor(participantId);
        trail.RecordTypeId = ceRecordTypeId;
        trail.ips_Status__c = 'Referred';
        Work_Trail__c otherTrail = IPS_TestDataFactory.createJobbspor(participantId);
        insert new List<Work_Trail__c>{ trail, otherTrail };

        insert new List<CE_Work_Theme__c>{
            new CE_Work_Theme__c(
                Name = MAIN_THEME,
                Main_Theme__c = MAIN_THEME,
                Sub_Theme__c = 'Ledelse',
                Work_Trail__c = trail.Id
            ),
            new CE_Work_Theme__c(
                Name = OTHER_MAIN_THEME,
                Main_Theme__c = OTHER_MAIN_THEME,
                Work_Trail__c = otherTrail.Id
            )
        };
        insert IPS_TestDataFactory.createEmployerAccount();
    }

    private static Work_Trail__c getTrail() {
        return [
            SELECT Id, OwnerId
            FROM Work_Trail__c
            WHERE Id IN (SELECT Work_Trail__c FROM CE_Work_Theme__c WHERE Main_Theme__c = :MAIN_THEME)
            LIMIT 1
        ];
    }

    private static CE_Work_Theme__c getTheme(String mainTheme) {
        return [SELECT Id, Sub_Theme__c, Work_Trail__c FROM CE_Work_Theme__c WHERE Main_Theme__c = :mainTheme LIMIT 1];
    }

    private static CE_NewOpportunityController.CreateRequest request(Id trailId, Id themeId, String subThemes) {
        CE_NewOpportunityController.CreateRequest request = new CE_NewOpportunityController.CreateRequest();
        request.workTrailId = trailId;
        request.themeId = themeId;
        request.subThemes = subThemes;
        request.name = '  Butikkmedarbeider  ';
        return request;
    }

    private static User getCeUser() {
        return [SELECT Id FROM User WHERE Username LIKE 'Ce.Manager.%' LIMIT 1];
    }

    private static List<CE_NewOpportunityController.ThemeOption> getThemesAsCe(Id recordId) {
        List<CE_NewOpportunityController.ThemeOption> themes;
        System.runAs(getCeUser()) {
            themes = CE_NewOpportunityController.getRegisteredThemes(recordId);
        }
        return themes;
    }

    private static CE_NewOpportunityController.CreateResult run(CE_NewOpportunityController.CreateRequest request) {
        return CE_NewOpportunityController.createOpportunity(
            new List<CE_NewOpportunityController.CreateRequest>{ request }
        )[0];
    }

    private static CE_NewOpportunityController.CreateResult runAsCe(CE_NewOpportunityController.CreateRequest request) {
        CE_NewOpportunityController.CreateResult result;
        System.runAs(getCeUser()) {
            result = run(request);
        }
        return result;
    }

    @IsTest
    static void getRegisteredThemes_returnsOnlyThemesOnWorkTrail() {
        Work_Trail__c trail = getTrail();

        Test.startTest();
        List<CE_NewOpportunityController.ThemeOption> themes = getThemesAsCe(trail.Id);
        Test.stopTest();

        Assert.areEqual(1, themes.size(), 'Bare hovedtema på dette jobbsporet skal vises');
        Assert.areEqual(getTheme(MAIN_THEME).Id, themes[0].recordId, 'Valget skal bruke ID-en til hovedtemaet');
        Assert.areEqual(MAIN_THEME, themes[0].mainTheme, 'Hovedtemaet skal returneres');
        Assert.areEqual(new List<String>{ 'Ledelse' }, themes[0].subThemes, 'Lagrede undertemaer skal returneres');
    }

    @IsTest
    static void getRegisteredThemes_wrongIdType_throws() {
        Id themeId = getTheme(MAIN_THEME).Id;
        Boolean thrown = false;

        Test.startTest();
        try {
            getThemesAsCe(themeId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown, 'Bare ID til jobbspor skal godtas');
    }

    @IsTest
    static void createOpportunity_updatesThemeAndCreatesOpportunity() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        Account employer = [SELECT Id FROM Account WHERE Name LIKE 'Røre Pinne%' LIMIT 1];
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id, 'Ledelse;Idrett og aktivitet');
        request.description = 'Prøve ut arbeid i butikk';
        request.status = 'Ny';
        request.accountId = employer.Id;

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Lagringen skal lykkes');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT
                Name,
                Work_Trail__c,
                CE_Work_Theme__c,
                Main_Theme__c,
                Sub_Theme__c,
                Description__c,
                Status__c,
                CE_RelatedToAccount__c,
                OwnerId
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual('Butikkmedarbeider', opportunity.Name, 'Navnet skal lagres uten mellomrom rundt');
        Assert.areEqual(trail.Id, opportunity.Work_Trail__c, 'Muligheten skal knyttes til jobbsporet');
        Assert.areEqual(theme.Id, opportunity.CE_Work_Theme__c, 'Muligheten skal knyttes til hovedtemaet');
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Hovedtema skal kopieres til muligheten');
        Assert.areEqual(
            new Set<String>{ 'Ledelse', 'Idrett og aktivitet' },
            new Set<String>(opportunity.Sub_Theme__c.split('\n')),
            'Valgte undertemaer skal kopieres til muligheten'
        );
        Assert.areEqual(
            'Ledelse\nIdrett og aktivitet',
            opportunity.Sub_Theme__c,
            'Hvert undertema skal lagres på egen linje'
        );
        Assert.areEqual('Prøve ut arbeid i butikk', opportunity.Description__c, 'Beskrivelsen skal lagres');
        Assert.areEqual('Ny', opportunity.Status__c, 'Status skal lagres');
        Assert.areEqual(employer.Id, opportunity.CE_RelatedToAccount__c, 'Arbeidsgiveren skal lagres');
        Assert.areEqual(trail.OwnerId, opportunity.OwnerId, 'Eier skal være den samme som på jobbsporet');

        Set<String> storedSubThemes = new Set<String>(getTheme(MAIN_THEME).Sub_Theme__c.split(';'));
        Assert.areEqual(
            new Set<String>{ 'Ledelse', 'Idrett og aktivitet' },
            storedSubThemes,
            'Undertemaene skal lagres på hovedtemaet'
        );
    }

    @IsTest
    static void createOpportunity_withoutOptionalFields_clearsSubThemes() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id, null));
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Valgfrie felt skal kunne stå tomme');
        Assert.isNotNull(result.opportunityId, 'Muligheten skal opprettes');
        Assert.isNull(getTheme(MAIN_THEME).Sub_Theme__c, 'Fjernede undertemaer skal fjernes fra hovedtemaet');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Main_Theme__c, Sub_Theme__c, Description__c, Status__c, CE_RelatedToAccount__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.isNull(opportunity.Description__c, 'Tom beskrivelse skal ikke lagres');
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Hovedtema skal kopieres uten undertemaer');
        Assert.isNull(opportunity.Sub_Theme__c, 'Ingen valgte undertemaer skal gi tomt snapshot');
        Assert.isNull(opportunity.Status__c, 'Tom status skal ikke lagres');
        Assert.isNull(opportunity.CE_RelatedToAccount__c, 'Arbeidsgiver er valgfri');
    }

    @IsTest
    static void createOpportunity_themeChanges_doNotChangeSnapshot() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id, 'Ledelse'));
        update new CE_Work_Theme__c(Id = theme.Id, Main_Theme__c = OTHER_MAIN_THEME, Sub_Theme__c = 'Transport');
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Muligheten skal opprettes');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Main_Theme__c, Sub_Theme__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Snapshot skal beholde opprinnelig hovedtema');
        Assert.areEqual('Ledelse', opportunity.Sub_Theme__c, 'Snapshot skal beholde opprinnelige undertemaer');
    }

    @IsTest
    static void createOpportunity_themeFromOtherWorkTrail_returnsErrorWithoutChanges() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c otherTheme = getTheme(OTHER_MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, otherTheme.Id, 'Transport'));
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_THEME, result.errorMessage, 'Feil jobbspor skal avvises');
        Assert.isNull(result.opportunityId, 'Ingen mulighet skal opprettes');
        Assert.isNull(getTheme(OTHER_MAIN_THEME).Sub_Theme__c, 'Hovedtemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_subThemeForOtherMainTheme_returnsErrorWithoutChanges() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id, 'Ledelse;Transport'));
        Test.stopTest();

        Assert.areEqual(
            CE_NewOpportunityController.ERROR_SUB_THEMES,
            result.errorMessage,
            'Undertema fra et annet hovedtema skal avvises'
        );
        Assert.areEqual('Ledelse', getTheme(MAIN_THEME).Sub_Theme__c, 'Hovedtemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_invalidInput_returnsErrors() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        CE_NewOpportunityController.CreateRequest blankName = request(trail.Id, theme.Id, 'Ledelse');
        blankName.name = '   ';
        CE_NewOpportunityController.CreateRequest badTrail = request(theme.Id, theme.Id, 'Ledelse');
        CE_NewOpportunityController.CreateRequest badTheme = request(trail.Id, null, 'Ledelse');
        badTheme.themeId = 'ikke-en-id';
        CE_NewOpportunityController.CreateRequest badAccount = request(trail.Id, theme.Id, 'Ledelse');
        badAccount.accountId = trail.Id;

        Test.startTest();
        List<CE_NewOpportunityController.CreateResult> results = CE_NewOpportunityController.createOpportunity(
            new List<CE_NewOpportunityController.CreateRequest>{ blankName, badTrail, badTheme, badAccount }
        );
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_NAME, results[0].errorMessage, 'Navn er påkrevd');
        Assert.areEqual(CE_NewOpportunityController.ERROR_WORK_TRAIL, results[1].errorMessage, 'Ugyldig jobbspor');
        Assert.areEqual(CE_NewOpportunityController.ERROR_THEME, results[2].errorMessage, 'Ugyldig hovedtema');
        Assert.areEqual(CE_NewOpportunityController.ERROR_ACCOUNT, results[3].errorMessage, 'Ugyldig arbeidsgiver');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_insertFails_rollsBackThemeUpdate() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id, 'Idrett og aktivitet');
        // Description__c is a 255 character text area, so the insert fails after the theme is updated.
        request.description = 'x'.repeat(300);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_SAVE, result.errorMessage, 'Lagringsfeil skal vises');
        Assert.isNull(result.opportunityId, 'Ingen ID skal returneres');
        Assert.areEqual('Ledelse', getTheme(MAIN_THEME).Sub_Theme__c, 'Endringen i hovedtemaet skal rulles tilbake');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_userWithoutAccess_savesNothing() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        User user = IPS_TestDataFactory.getStandardUser('Uten', 'Tilgang');
        insert user;

        CE_NewOpportunityController.CreateResult result;
        Test.startTest();
        System.runAs(user) {
            result = run(request(trail.Id, theme.Id, 'Idrett og aktivitet'));
        }
        Test.stopTest();

        Assert.isNotNull(result.errorMessage, 'Bruker uten tilgang skal få feilmelding');
        Assert.isNull(result.opportunityId, 'Ingen mulighet skal opprettes');
        Assert.areEqual('Ledelse', getTheme(MAIN_THEME).Sub_Theme__c, 'Hovedtemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void getValidSubThemes_followsPicklistDependency() {
        Set<String> valid = CE_NewOpportunityController.getValidSubThemes(MAIN_THEME);

        Assert.isTrue(valid.contains('Ledelse'), 'Ledelse hører til Aktivitet og ledelse');
        Assert.isTrue(valid.contains('Idrett og aktivitet'), 'Idrett og aktivitet hører til Aktivitet og ledelse');
        Assert.isFalse(valid.contains('Transport'), 'Transport hører til et annet hovedtema');
        Assert.isTrue(CE_NewOpportunityController.getValidSubThemes(null).isEmpty(), 'Uten hovedtema er ingen gyldige');
    }
}
