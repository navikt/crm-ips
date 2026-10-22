/**
 * Controller for creating new opportunities and managing themes.
 * Handles the retrieval of registered themes and the creation of new opportunities.
 * Provides methods for validating input and handling errors related to opportunities and themes.
 * @author Balendra Sounthararajan / Copilot
 */

public with sharing class CE_NewOpportunityController {
    @TestVisible
    private static final String ERROR_WORK_TRAIL = 'Fant ikke jobbsporet. Lukk vinduet og prøv igjen.';
    @TestVisible
    private static final String ERROR_THEME = 'Velg et hovedtema som er registrert på dette jobbsporet.';
    @TestVisible
    private static final String ERROR_NAME = 'Skriv inn navn på muligheten.';
    @TestVisible
    private static final String ERROR_SUB_THEMES = 'Ett eller flere undertemaer passer ikke til hovedtemaet. Velg undertemaer på nytt.';
    @TestVisible
    private static final String ERROR_ACCOUNT = 'Fant ikke arbeidsgiveren. Velg arbeidsgiver på nytt.';
    @TestVisible
    private static final String ERROR_ACCESS = 'Du har ikke tilgang til å opprette muligheter.';
    @TestVisible
    private static final String ERROR_SAVE = 'Muligheten ble ikke lagret, og hovedtemaet ble ikke endret. Prøv igjen, eller kontakt brukerstøtte.';
    private static final String ERROR_LOAD = 'Kunne ikke hente hovedtemaene. Prøv igjen, eller kontakt brukerstøtte.';
    private static final String HEX_DIGITS = '0123456789abcdef';

    @AuraEnabled(cacheable=true)
    public static List<WorkThemeRow> getWorkThemes(Id workTrailId) {
        if (workTrailId == null || workTrailId.getSObjectType() != Work_Trail__c.SObjectType) {
            throw new AuraHandledException(ERROR_WORK_TRAIL);
        }
        List<Work_Trail__c> trails = [
            SELECT Id
            FROM Work_Trail__c
            WHERE Id = :workTrailId
            WITH USER_MODE
            LIMIT 1
        ];
        if (trails.isEmpty()) {
            throw new AuraHandledException(ERROR_WORK_TRAIL);
        }
        List<CE_Work_Theme__c> themes = [
            SELECT Id, Name
            FROM CE_Work_Theme__c
            WHERE Work_Trail__c = :workTrailId
            WITH USER_MODE
            ORDER BY Name ASC
        ];
        Set<Id> themeIds = new Map<Id, CE_Work_Theme__c>(themes).keySet();
        Map<Id, Integer> countsByThemeId = new Map<Id, Integer>();
        if (!themeIds.isEmpty()) {
            countsByThemeId = new OpportunityCounter().countByTheme(workTrailId, themeIds);
        }
        List<WorkThemeRow> rows = new List<WorkThemeRow>();
        for (CE_Work_Theme__c theme : themes) {
            WorkThemeRow row = new WorkThemeRow();
            row.recordId = theme.Id;
            row.name = theme.Name;
            row.opportunityCount = countsByThemeId.containsKey(theme.Id) ? countsByThemeId.get(theme.Id) : 0;
            rows.add(row);
        }
        return rows;
    }

    // Only aggregate counts, after Work Trail access has been checked.
    private without sharing class OpportunityCounter {
        public Map<Id, Integer> countByTheme(Id workTrailId, Set<Id> themeIds) {
            if (!CE_Discovery_Opportunity__c.Work_Trail__c.getDescribe().isAccessible()) {
                throw new AuraHandledException(ERROR_LOAD);
            }
            Map<Id, Integer> countsByThemeId = new Map<Id, Integer>();
            for (AggregateResult result : [
                SELECT CE_Work_Theme__c themeId, COUNT(Id) opportunityCount
                FROM CE_Discovery_Opportunity__c
                WHERE Work_Trail__c = :workTrailId AND CE_Work_Theme__c IN :themeIds
                WITH SECURITY_ENFORCED
                GROUP BY CE_Work_Theme__c
            ]) {
                countsByThemeId.put((Id) result.get('themeId'), (Integer) result.get('opportunityCount'));
            }
            return countsByThemeId;
        }
    }

    /** Related-list values, including all linked opportunities */
    public class WorkThemeRow {
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public Integer opportunityCount { get; set; }
    }

    @AuraEnabled
    public static List<ThemeOption> getRegisteredThemes(Id workTrailId) {
        if (workTrailId == null || workTrailId.getSobjectType() != Work_Trail__c.SObjectType) {
            throw new AuraHandledException(ERROR_WORK_TRAIL);
        }
        try {
            List<ThemeOption> options = new List<ThemeOption>();
            for (CE_Work_Theme__c theme : [
                SELECT Id, Name, Main_Theme__c, Sub_Theme__c
                FROM CE_Work_Theme__c
                WHERE Work_Trail__c = :workTrailId
                WITH USER_MODE
                ORDER BY Main_Theme__c ASC NULLS LAST, Name ASC
            ]) {
                ThemeOption option = new ThemeOption();
                option.recordId = theme.Id;
                option.name = theme.Name;
                option.mainTheme = theme.Main_Theme__c;
                option.subThemes = splitValues(theme.Sub_Theme__c);
                options.add(option);
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_LOAD);
        }
    }

    @InvocableMethod(
        label='CE - Opprett mulighet og oppdater undertemaer'
        description='Lagrer undertemaene på det registrerte hovedtemaet og oppretter muligheten i samme transaksjon.'
        category='Jobbsporet'
    )
    public static List<CreateResult> createOpportunity(List<CreateRequest> requests) {
        List<CreateResult> results = new List<CreateResult>();
        // The screen flow sends one request per interview, so each request gets its own savepoint.
        for (CreateRequest request : requests) {
            results.add(create(request));
        }
        return results;
    }

    private static CreateResult create(CreateRequest request) {
        CreateResult result = new CreateResult();
        String validationError = validate(request);
        if (validationError != null) {
            result.errorMessage = validationError;
            return result;
        }

        Id workTrailId = Id.valueOf(request.workTrailId);
        List<Work_Trail__c> trails = [
            SELECT Id, OwnerId
            FROM Work_Trail__c
            WHERE Id = :workTrailId
            WITH USER_MODE
            LIMIT 1
        ];
        if (trails.isEmpty()) {
            result.errorMessage = ERROR_WORK_TRAIL;
            return result;
        }

        Id themeId = Id.valueOf(request.themeId);
        List<CE_Work_Theme__c> themes = [
            SELECT Id, Main_Theme__c, Sub_Theme__c
            FROM CE_Work_Theme__c
            WHERE Id = :themeId AND Work_Trail__c = :workTrailId
            WITH USER_MODE
            LIMIT 1
        ];
        if (themes.isEmpty()) {
            result.errorMessage = ERROR_THEME;
            return result;
        }

        CE_Work_Theme__c theme = themes[0];
        List<String> selectedSubThemes = splitValues(request.subThemes);
        if (!getValidSubThemes(theme.Main_Theme__c).containsAll(selectedSubThemes)) {
            result.errorMessage = ERROR_SUB_THEMES;
            return result;
        }

        Id accountId = String.isBlank(request.accountId) ? null : Id.valueOf(request.accountId);
        if (accountId != null && [SELECT COUNT() FROM Account WHERE Id = :accountId WITH USER_MODE] == 0) {
            result.errorMessage = ERROR_ACCOUNT;
            return result;
        }

        Savepoint savepoint = Database.setSavepoint();
        try {
            String newSubThemes = selectedSubThemes.isEmpty() ? null : String.join(selectedSubThemes, ';');
            if (!sameValues(splitValues(theme.Sub_Theme__c), selectedSubThemes)) {
                Database.update(
                    new CE_Work_Theme__c(Id = theme.Id, Sub_Theme__c = newSubThemes),
                    AccessLevel.USER_MODE
                );
            }
            CE_Discovery_Opportunity__c opportunity = buildOpportunity(request, trails[0], theme.Id, accountId);
            opportunity.Main_Theme__c = theme.Main_Theme__c;
            opportunity.Sub_Theme__c = selectedSubThemes.isEmpty() ? null : String.join(selectedSubThemes, '\n');
            insert opportunity;
            result.opportunityId = opportunity.Id;
        } catch (Exception e) {
            Database.rollback(savepoint);
            result.opportunityId = null;
            result.errorMessage = ERROR_SAVE;
        }
        return result;
    }

    private static String validate(CreateRequest request) {
        if (request == null || !isIdOfType(request.workTrailId, Work_Trail__c.SObjectType)) {
            return ERROR_WORK_TRAIL;
        }
        if (!isIdOfType(request.themeId, CE_Work_Theme__c.SObjectType)) {
            return ERROR_THEME;
        }
        if (String.isBlank(request.name)) {
            return ERROR_NAME;
        }
        if (String.isNotBlank(request.accountId) && !isIdOfType(request.accountId, Account.SObjectType)) {
            return ERROR_ACCOUNT;
        }
        if (!canCreateOpportunity(request)) {
            return ERROR_ACCESS;
        }
        return null;
    }

    private static Boolean canCreateOpportunity(CreateRequest request) {
        Schema.DescribeSObjectResult opportunityDescribe = CE_Discovery_Opportunity__c.SObjectType.getDescribe();
        if (!opportunityDescribe.isCreateable()) {
            return false;
        }
        List<Schema.SObjectField> userFields = new List<Schema.SObjectField>{
            CE_Discovery_Opportunity__c.Name,
            CE_Discovery_Opportunity__c.CE_Work_Theme__c
        };
        if (String.isNotBlank(request.description)) {
            userFields.add(CE_Discovery_Opportunity__c.Description__c);
        }
        if (String.isNotBlank(request.status)) {
            userFields.add(CE_Discovery_Opportunity__c.Status__c);
        }
        if (String.isNotBlank(request.accountId)) {
            userFields.add(CE_Discovery_Opportunity__c.CE_RelatedToAccount__c);
        }
        for (Schema.SObjectField field : userFields) {
            if (!field.getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }

    private static CE_Discovery_Opportunity__c buildOpportunity(
        CreateRequest request,
        Work_Trail__c trail,
        Id themeId,
        Id accountId
    ) {
        CE_Discovery_Opportunity__c opportunity = new CE_Discovery_Opportunity__c(
            Name = request.name.trim(),
            Work_Trail__c = trail.Id,
            CE_Work_Theme__c = themeId,
            Description__c = String.isBlank(request.description) ? null : request.description.trim(),
            Status__c = String.isBlank(request.status) ? null : request.status.trim(),
            CE_RelatedToAccount__c = accountId
        );

        if (trail.OwnerId != null && trail.OwnerId.getSobjectType() == User.SObjectType) {
            opportunity.OwnerId = trail.OwnerId;
        }
        return opportunity;
    }

    /**
     * Returns the active Sub_Theme__c values that are valid for the given Main_Theme__c value,
     * based on the validFor bitmap in the dependent picklist describe.
     */
    @TestVisible
    private static Set<String> getValidSubThemes(String mainTheme) {
        Set<String> validValues = new Set<String>();
        if (String.isBlank(mainTheme)) {
            return validValues;
        }
        List<Schema.PicklistEntry> controllerEntries = CE_Work_Theme__c.Main_Theme__c.getDescribe().getPicklistValues();
        Integer controllerIndex = -1;
        for (Integer i = 0; i < controllerEntries.size(); i++) {
            if (controllerEntries[i].getValue() == mainTheme) {
                controllerIndex = i;
                break;
            }
        }
        if (controllerIndex < 0) {
            return validValues;
        }
        for (Schema.PicklistEntry entry : CE_Work_Theme__c.Sub_Theme__c.getDescribe().getPicklistValues()) {
            if (entry.isActive() && isValidFor(entry, controllerIndex)) {
                validValues.add(entry.getValue());
            }
        }
        return validValues;
    }

    private static Boolean isValidFor(Schema.PicklistEntry entry, Integer controllerIndex) {
        Map<String, Object> entryJson = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry));
        String validFor = (String) entryJson.get('validFor');
        if (String.isBlank(validFor)) {
            return false;
        }
        String hex = EncodingUtil.convertToHex(EncodingUtil.base64Decode(validFor)).toLowerCase();
        Integer byteIndex = controllerIndex / 8;
        if (hex.length() < (byteIndex + 1) * 2) {
            return false;
        }
        Integer byteValue =
            HEX_DIGITS.indexOf(hex.substring(byteIndex * 2, byteIndex * 2 + 1)) * 16 +
            HEX_DIGITS.indexOf(hex.substring(byteIndex * 2 + 1, byteIndex * 2 + 2));
        Integer mask = 128 >> Math.mod(controllerIndex, 8);
        return (byteValue & mask) != 0;
    }

    private static Boolean isIdOfType(String value, Schema.SObjectType expectedType) {
        if (String.isBlank(value)) {
            return false;
        }
        try {
            return Id.valueOf(value).getSobjectType() == expectedType;
        } catch (Exception e) {
            return false;
        }
    }

    private static List<String> splitValues(String value) {
        List<String> values = new List<String>();
        if (String.isBlank(value)) {
            return values;
        }
        Set<String> seen = new Set<String>();
        for (String part : value.split(';')) {
            String trimmed = part.trim();
            if (String.isNotBlank(trimmed) && seen.add(trimmed)) {
                values.add(trimmed);
            }
        }
        return values;
    }

    private static Boolean sameValues(List<String> first, List<String> second) {
        return new Set<String>(first).equals(new Set<String>(second));
    }

    public class ThemeOption {
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String mainTheme;
        @AuraEnabled
        public List<String> subThemes;
    }

    public class CreateRequest {
        @InvocableVariable(label='Jobbspor-ID' required=true)
        public String workTrailId;
        @InvocableVariable(label='Hovedtema-ID')
        public String themeId;
        @InvocableVariable(label='Undertemaer (semikolonseparert)')
        public String subThemes;
        @InvocableVariable(label='Navn på muligheten')
        public String name;
        @InvocableVariable(label='Beskrivelse')
        public String description;
        @InvocableVariable(label='Status')
        public String status;
        @InvocableVariable(label='Arbeidsgiver-ID')
        public String accountId;
    }

    public class CreateResult {
        @InvocableVariable(label='Mulighet-ID')
        public String opportunityId;
        @InvocableVariable(label='Feilmelding')
        public String errorMessage;
    }
}
