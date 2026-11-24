@IsTest
private class CE_NewOpportunityControllerTest {
    private static final String MAIN_THEME = 'Landbruk';
    private static final String OTHER_MAIN_THEME = 'Transport';

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
            new CE_Work_Theme__c(Name = MAIN_THEME, Main_Theme__c = MAIN_THEME, Work_Trail__c = trail.Id),
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
        return [
            SELECT Id, Name, Main_Theme__c, Work_Trail__c, LastModifiedDate
            FROM CE_Work_Theme__c
            WHERE Main_Theme__c = :mainTheme
            LIMIT 1
        ];
    }

    private static CE_NewOpportunityController.CreateRequest request(Id trailId, Id themeId) {
        CE_NewOpportunityController.CreateRequest request = new CE_NewOpportunityController.CreateRequest();
        request.workTrailId = trailId;
        request.themeId = themeId;
        request.name = '  Butikkmedarbeider  ';
        request.accountId = [SELECT Id FROM Account WHERE Name LIKE 'Røre Pinne%' LIMIT 1].Id;
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

    private static List<CE_NewOpportunityController.WorkThemeRow> getWorkThemesAsCe(Id recordId) {
        List<CE_NewOpportunityController.WorkThemeRow> themes;
        System.runAs(getCeUser()) {
            themes = CE_NewOpportunityController.getWorkThemes(recordId);
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

        Assert.areEqual(1, themes.size(), 'Bare yrkestema på dette jobbsporet skal vises');
        Assert.areEqual(getTheme(MAIN_THEME).Id, themes[0].recordId, 'Valget skal bruke ID-en til yrkestemaet');
        Assert.areEqual(MAIN_THEME, themes[0].mainTheme, 'Yrkestemaet skal returneres');
        Assert.areEqual(MAIN_THEME, themes[0].name, 'Yrkestemaets navn skal returneres');
    }

    @IsTest
    static void getWorkThemes_returnsOnlyThemesOnWorkTrail() {
        Work_Trail__c trail = getTrail();

        Test.startTest();
        List<CE_NewOpportunityController.WorkThemeRow> themes = getWorkThemesAsCe(trail.Id);
        Test.stopTest();

        Assert.areEqual(1, themes.size(), 'Bare temaer på dette jobbsporet skal vises');
        Assert.areEqual(getTheme(MAIN_THEME).Id, themes[0].recordId, 'Riktig tema skal returneres');
        Assert.areEqual(MAIN_THEME, themes[0].name, 'Temaets navn skal returneres');
        Assert.areEqual(0, themes[0].opportunityCount, 'Tema uten muligheter skal vise null');
    }

    @IsTest
    static void getWorkThemes_countsOpportunitiesPerTheme() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        Assert.isNotNull(runAsCe(request(trail.Id, theme.Id)).opportunityId);
        Assert.isNotNull(runAsCe(request(trail.Id, theme.Id)).opportunityId);
        CE_Work_Theme__c otherTheme = getTheme(OTHER_MAIN_THEME);
        insert new CE_Discovery_Opportunity__c(
            Name = 'Mulighet på et annet jobbspor',
            Work_Trail__c = otherTheme.Work_Trail__c,
            CE_Work_Theme__c = otherTheme.Id
        );

        Test.startTest();
        List<CE_NewOpportunityController.WorkThemeRow> themes = getWorkThemesAsCe(trail.Id);
        Test.stopTest();

        Assert.areEqual(2, themes[0].opportunityCount, 'Begge muligheter skal telles');
        Assert.areEqual(
            1,
            getWorkThemesAsCe(otherTheme.Work_Trail__c)[0].opportunityCount,
            'Bare muligheten på det andre jobbsporet skal telles der'
        );
    }

    @IsTest
    static void getWorkThemes_deletedOpportunity_isNotCounted() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id));
        Assert.isNotNull(result.opportunityId, 'Muligheten skal opprettes før sletting');
        delete new CE_Discovery_Opportunity__c(Id = result.opportunityId);

        Test.startTest();
        List<CE_NewOpportunityController.WorkThemeRow> themes = getWorkThemesAsCe(trail.Id);
        Test.stopTest();

        Assert.areEqual(1, themes.size(), 'Yrkestemaet skal fortsatt vises etter sletting av muligheten');
        Assert.areEqual(0, themes[0].opportunityCount, 'Slettede muligheter skal ikke telles');
    }

    @IsTest
    static void getWorkThemes_countsOpportunitiesCreatedByOtherUsers() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        CE_Discovery_Opportunity__c otherUserOpportunity = new CE_Discovery_Opportunity__c(
            Name = 'Mulighet opprettet av en annen bruker',
            Work_Trail__c = trail.Id,
            CE_Work_Theme__c = theme.Id
        );
        insert otherUserOpportunity;
        Assert.isNotNull(runAsCe(request(trail.Id, theme.Id)).opportunityId);

        CE_Discovery_Opportunity__c stored = [
            SELECT CreatedById
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :otherUserOpportunity.Id
        ];
        Assert.areNotEqual(getCeUser().Id, stored.CreatedById, 'Testdata skal ha en annen oppretter enn leseren');

        Test.startTest();
        List<CE_NewOpportunityController.WorkThemeRow> themes = getWorkThemesAsCe(trail.Id);
        Test.stopTest();

        Assert.areEqual(2, themes[0].opportunityCount, 'Muligheter skal telles uavhengig av oppretter');
    }

    @IsTest
    static void getWorkThemes_deletedWorkTrail_throws() {
        Work_Trail__c trail = getTrail();
        delete trail;
        Boolean thrown = false;

        Test.startTest();
        try {
            getWorkThemesAsCe(trail.Id);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown, 'Telling skal kreve et jobbspor som brukeren har tilgang til');
    }

    @IsTest
    static void getWorkThemes_countsOpportunitiesPerThemeOnWorkTrail() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        CE_Work_Theme__c otherTheme = getTheme(OTHER_MAIN_THEME);
        CE_Work_Theme__c secondTheme = new CE_Work_Theme__c(
            Name = OTHER_MAIN_THEME,
            Main_Theme__c = OTHER_MAIN_THEME,
            Work_Trail__c = trail.Id
        );
        insert secondTheme;
        insert new List<CE_Discovery_Opportunity__c>{
            new CE_Discovery_Opportunity__c(Name = 'Mulighet 1', Work_Trail__c = trail.Id, CE_Work_Theme__c = theme.Id),
            new CE_Discovery_Opportunity__c(
                Name = 'Mulighet 2',
                Work_Trail__c = trail.Id,
                CE_Work_Theme__c = theme.Id,
                OwnerId = getCeUser().Id
            ),
            new CE_Discovery_Opportunity__c(
                Name = 'Mulighet 3',
                Work_Trail__c = trail.Id,
                CE_Work_Theme__c = secondTheme.Id
            ),
            new CE_Discovery_Opportunity__c(
                Name = 'Annet jobbspor',
                Work_Trail__c = otherTheme.Work_Trail__c,
                CE_Work_Theme__c = otherTheme.Id
            )
        };

        Test.startTest();
        List<CE_NewOpportunityController.WorkThemeRow> themes = getWorkThemesAsCe(trail.Id);
        Test.stopTest();

        Map<Id, Integer> counts = new Map<Id, Integer>();
        for (CE_NewOpportunityController.WorkThemeRow row : themes) {
            counts.put(row.recordId, row.opportunityCount);
        }
        Assert.areEqual(2, themes.size(), 'Bare temaer på dette jobbsporet skal vises');
        Assert.areEqual(2, counts.get(theme.Id), 'Alle muligheter på temaet skal telles uavhengig av eier');
        Assert.areEqual(1, counts.get(secondTheme.Id), 'Hvert tema skal ha sin egen telling');
        Assert.isFalse(counts.containsKey(otherTheme.Id), 'Temaer på andre jobbspor skal ikke tas med');
    }

    @IsTest
    static void getWorkThemes_wrongIdType_throws() {
        Id themeId = getTheme(MAIN_THEME).Id;
        Boolean thrown = false;

        Test.startTest();
        try {
            getWorkThemesAsCe(themeId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown, 'Bare ID til jobbspor skal godtas');
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
    static void createOpportunity_createsOpportunityWithoutChangingTheme() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        Account employer = [SELECT Id FROM Account WHERE Name LIKE 'Røre Pinne%' LIMIT 1];
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id);
        request.description = 'Prøve ut arbeid i butikk';
        request.accountId = employer.Id;

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Lagringen skal lykkes');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Name, Work_Trail__c, CE_Work_Theme__c, Main_Theme__c, Description__c, CE_RelatedToAccount__c, OwnerId
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual('Butikkmedarbeider', opportunity.Name, 'Navnet skal lagres uten mellomrom rundt');
        Assert.areEqual(trail.Id, opportunity.Work_Trail__c, 'Muligheten skal knyttes til jobbsporet');
        Assert.areEqual(theme.Id, opportunity.CE_Work_Theme__c, 'Muligheten skal knyttes til yrkestemaet');
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Yrkestema skal kopieres til muligheten');
        Assert.areEqual('Prøve ut arbeid i butikk', opportunity.Description__c, 'Beskrivelsen skal lagres');
        Assert.areEqual(employer.Id, opportunity.CE_RelatedToAccount__c, 'Arbeidsgiveren skal lagres');
        Assert.areEqual(trail.OwnerId, opportunity.OwnerId, 'Eier skal være den samme som på jobbsporet');

        CE_Work_Theme__c storedTheme = getTheme(MAIN_THEME);
        Assert.areEqual(theme.Name, storedTheme.Name, 'Yrkestemaets navn skal ikke endres');
        Assert.areEqual(theme.Main_Theme__c, storedTheme.Main_Theme__c, 'Yrkestemaet skal ikke endres');
        Assert.areEqual(theme.Work_Trail__c, storedTheme.Work_Trail__c, 'Jobbsporet skal ikke endres');
        Assert.areEqual(theme.LastModifiedDate, storedTheme.LastModifiedDate, 'Yrkestemaet skal ikke oppdateres');
    }

    @IsTest
    static void createOpportunity_withoutOptionalFields_createsOpportunity() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id));
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Valgfrie felt skal kunne stå tomme');
        Assert.isNotNull(result.opportunityId, 'Muligheten skal opprettes');
        Assert.areEqual(MAIN_THEME, getTheme(MAIN_THEME).Main_Theme__c, 'Yrkestemaet skal ikke endres');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT
                Main_Theme__c,
                Description__c,
                CE_RelatedToAccount__c,
                Information_to_share__c,
                Information_not_to_share__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.isNull(opportunity.Description__c, 'Tom beskrivelse skal ikke lagres');
        Assert.isNull(opportunity.Information_to_share__c, 'Tomt kildefelt skal gi tom informasjon som kan deles');
        Assert.isNull(
            opportunity.Information_not_to_share__c,
            'Tomt kildefelt skal gi tom informasjon som ikke skal deles'
        );
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Yrkestema skal kopieres til muligheten');
        Assert.isNotNull(opportunity.CE_RelatedToAccount__c, 'Arbeidsgiver skal lagres selv om valgfrie felt er tomme');
    }

    @IsTest
    static void createOpportunity_copiesSharingInformationAtMaximumLength() {
        Work_Trail__c trail = getTrail();
        trail.Information_to_share__c = 'a'.repeat(999) + '\n' + 'a'.repeat(1000);
        trail.Information_not_to_share__c = 'b'.repeat(2000);
        update trail;
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, getTheme(MAIN_THEME).Id);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Kopiering av felt med maksimal lengde skal lykkes');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Information_to_share__c, Information_not_to_share__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual(
            trail.Information_to_share__c,
            opportunity.Information_to_share__c,
            'Informasjon som kan deles skal kopieres uten forkorting eller fjerning av linjeskift'
        );
        Assert.areEqual(
            trail.Information_not_to_share__c,
            opportunity.Information_not_to_share__c,
            'Informasjon som ikke skal deles skal kopieres i sin helhet'
        );
    }

    @IsTest
    static void createOpportunity_withOneSharingField_copiesFieldsIndependently() {
        Work_Trail__c trail = getTrail();
        trail.Information_not_to_share__c = 'Dette skal ikke deles med arbeidsgiver.';
        update trail;
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, getTheme(MAIN_THEME).Id);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Opprettelsen skal lykkes selv om bare ett kildefelt er fylt ut');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Information_to_share__c, Information_not_to_share__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.isNull(opportunity.Information_to_share__c, 'Tomt kildefelt skal forbli tomt');
        Assert.areEqual(
            trail.Information_not_to_share__c,
            opportunity.Information_not_to_share__c,
            'Utfylt kildefelt skal kopieres uavhengig av det andre feltet'
        );
    }

    @IsTest
    static void createOpportunity_sharingInformationChanges_doNotSynchronize() {
        Work_Trail__c trail = getTrail();
        trail.Information_to_share__c = 'Opprinnelig informasjon som kan deles';
        trail.Information_not_to_share__c = 'Opprinnelig informasjon som ikke skal deles';
        update trail;
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, getTheme(MAIN_THEME).Id);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Assert.isNull(result.errorMessage, 'Muligheten skal opprettes');
        trail.Information_to_share__c = 'Endret informasjon på jobbsporet';
        trail.Information_not_to_share__c = null;
        update trail;
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Information_to_share__c, Information_not_to_share__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual(
            'Opprinnelig informasjon som kan deles',
            opportunity.Information_to_share__c,
            'Endringer på jobbsporet skal ikke overskrive engangskopien'
        );
        Assert.areEqual(
            'Opprinnelig informasjon som ikke skal deles',
            opportunity.Information_not_to_share__c,
            'Tømming av et kildefelt skal ikke tømme engangskopien'
        );
        opportunity.Information_to_share__c = 'Tilpasset informasjon på muligheten';
        opportunity.Information_not_to_share__c = 'Tilpasset begrensning på muligheten';
        update opportunity;
        Test.stopTest();

        Work_Trail__c storedTrail = [
            SELECT Information_to_share__c, Information_not_to_share__c
            FROM Work_Trail__c
            WHERE Id = :trail.Id
        ];
        Assert.areEqual(
            trail.Information_to_share__c,
            storedTrail.Information_to_share__c,
            'Endringer på muligheten skal ikke kopieres tilbake til jobbsporet'
        );
        Assert.isNull(
            storedTrail.Information_not_to_share__c,
            'Endringer på muligheten skal ikke fylle ut jobbsporets tomme felt'
        );
        opportunity = [
            SELECT Information_to_share__c, Information_not_to_share__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual(
            'Tilpasset informasjon på muligheten',
            opportunity.Information_to_share__c,
            'Mulighetens informasjon skal kunne redigeres uavhengig'
        );
        Assert.areEqual(
            'Tilpasset begrensning på muligheten',
            opportunity.Information_not_to_share__c,
            'Mulighetens begrensning skal kunne redigeres uavhengig'
        );
    }

    @IsTest
    static void createOpportunity_missingEmployer_returnsErrorWithoutChanges() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        List<CE_NewOpportunityController.CreateRequest> requests = new List<CE_NewOpportunityController.CreateRequest>();
        for (String accountId : new List<String>{ null, '', '   ' }) {
            CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id);
            request.accountId = accountId;
            requests.add(request);
        }

        Test.startTest();
        List<CE_NewOpportunityController.CreateResult> results = CE_NewOpportunityController.createOpportunity(
            requests
        );
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Alle forespørsler skal få et resultat');
        for (CE_NewOpportunityController.CreateResult result : results) {
            Assert.areEqual(
                CE_NewOpportunityController.ERROR_ACCOUNT_REQUIRED,
                result.errorMessage,
                'Arbeidsgiver er påkrevd'
            );
            Assert.isNull(result.opportunityId, 'Ingen mulighet skal opprettes uten arbeidsgiver');
        }
        Assert.areEqual(MAIN_THEME, getTheme(MAIN_THEME).Main_Theme__c, 'Yrkestemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_themeChanges_doNotChangeSnapshot() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, theme.Id));
        update new CE_Work_Theme__c(Id = theme.Id, Main_Theme__c = OTHER_MAIN_THEME);
        Test.stopTest();

        Assert.isNull(result.errorMessage, 'Muligheten skal opprettes');
        CE_Discovery_Opportunity__c opportunity = [
            SELECT Main_Theme__c, CE_Work_Theme__c
            FROM CE_Discovery_Opportunity__c
            WHERE Id = :result.opportunityId
        ];
        Assert.areEqual(MAIN_THEME, opportunity.Main_Theme__c, 'Snapshot skal beholde opprinnelig yrkestema');
        Assert.areEqual(theme.Id, opportunity.CE_Work_Theme__c, 'Koblingen til yrkestemaet skal beholdes');
    }

    @IsTest
    static void createOpportunity_themeFromOtherWorkTrail_returnsErrorWithoutChanges() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c otherTheme = getTheme(OTHER_MAIN_THEME);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request(trail.Id, otherTheme.Id));
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_THEME, result.errorMessage, 'Feil jobbspor skal avvises');
        Assert.isNull(result.opportunityId, 'Ingen mulighet skal opprettes');
        Assert.areEqual(OTHER_MAIN_THEME, getTheme(OTHER_MAIN_THEME).Main_Theme__c, 'Yrkestemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_invalidInput_returnsErrors() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);

        CE_NewOpportunityController.CreateRequest blankName = request(trail.Id, theme.Id);
        blankName.name = '   ';
        CE_NewOpportunityController.CreateRequest badTrail = request(theme.Id, theme.Id);
        CE_NewOpportunityController.CreateRequest badTheme = request(trail.Id, null);
        badTheme.themeId = 'ikke-en-id';
        CE_NewOpportunityController.CreateRequest badAccount = request(trail.Id, theme.Id);
        badAccount.accountId = trail.Id;

        Test.startTest();
        List<CE_NewOpportunityController.CreateResult> results = CE_NewOpportunityController.createOpportunity(
            new List<CE_NewOpportunityController.CreateRequest>{ blankName, badTrail, badTheme, badAccount }
        );
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_NAME, results[0].errorMessage, 'Navn er påkrevd');
        Assert.areEqual(CE_NewOpportunityController.ERROR_WORK_TRAIL, results[1].errorMessage, 'Ugyldig jobbspor');
        Assert.areEqual(CE_NewOpportunityController.ERROR_THEME, results[2].errorMessage, 'Ugyldig yrkestema');
        Assert.areEqual(CE_NewOpportunityController.ERROR_ACCOUNT, results[3].errorMessage, 'Ugyldig arbeidsgiver');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_insertFails_savesNothing() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id);
        // Description__c is a 255 character text area, so the insert fails.
        request.description = 'x'.repeat(300);

        Test.startTest();
        CE_NewOpportunityController.CreateResult result = runAsCe(request);
        Test.stopTest();

        Assert.areEqual(CE_NewOpportunityController.ERROR_SAVE, result.errorMessage, 'Lagringsfeil skal vises');
        Assert.isNull(result.opportunityId, 'Ingen ID skal returneres');
        Assert.areEqual(MAIN_THEME, getTheme(MAIN_THEME).Main_Theme__c, 'Yrkestemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }

    @IsTest
    static void createOpportunity_userWithoutAccess_savesNothing() {
        Work_Trail__c trail = getTrail();
        CE_Work_Theme__c theme = getTheme(MAIN_THEME);
        User user = IPS_TestDataFactory.getStandardUser('Uten', 'Tilgang');
        insert user;
        CE_NewOpportunityController.CreateRequest request = request(trail.Id, theme.Id);

        CE_NewOpportunityController.CreateResult result;
        Test.startTest();
        System.runAs(user) {
            result = run(request);
        }
        Test.stopTest();

        Assert.isNotNull(result.errorMessage, 'Bruker uten tilgang skal få feilmelding');
        Assert.isNull(result.opportunityId, 'Ingen mulighet skal opprettes');
        Assert.areEqual(MAIN_THEME, getTheme(MAIN_THEME).Main_Theme__c, 'Yrkestemaet skal ikke endres');
        Assert.areEqual(0, [SELECT COUNT() FROM CE_Discovery_Opportunity__c], 'Ingen mulighet skal finnes');
    }
}
