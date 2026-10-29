/**
 * Backs the "New Activity" quick action on Worktrail records.
 * The menu is configured in IPS_Activity_Menu__mdt. Rows either launch a screen flow or point to
 * TimelineParent__mdt for the same record type and defaults as the "New" buttons in the timeline.
 * The menu dynamically adapts based on the configuration and the current state of the record.
 */
public with sharing class IPS_NewActivityController {
    private static final String TODAY_MACRO = '{today}';
    private static final Map<String, String> GROUP_ICONS = new Map<String, String>{
        'Meeting' => 'utility:event',
        'Task' => 'utility:task',
        'SubGoal' => 'utility:apps',
        'ContactLog' => 'utility:talent_development',
        'Opportunity' => 'utility:light_bulb'
    };

    @AuraEnabled
    public static List<MenuGroup> getMenu(Id recordId) {
        try {
            String recordTypeName = getWorkTrailRecordType(recordId);
            if (String.isBlank(recordTypeName)) {
                return new List<MenuGroup>();
            }
            return buildMenu(recordId, recordTypeName);
        } catch (Exception e) {
            throw new AuraHandledException('Kunne ikke hente aktivitetene. Prøv igjen, eller kontakt brukerstøtte.');
        }
    }

    @TestVisible
    private static List<MenuGroup> buildMenu(Id recordId, String recordTypeName) {
        List<IPS_Activity_Menu__mdt> menuRows = [
            SELECT
                DeveloperName,
                Group__c,
                Sort_Order__c,
                Label__c,
                Help_Text__c,
                Flow_API_Name__c,
                Timeline_Parent__c,
                Hide_When_Field_Has_Value__c
            FROM IPS_Activity_Menu__mdt
            WHERE Work_Trail_Record_Type__c = :recordTypeName AND Is_Active__c = TRUE
            ORDER BY Sort_Order__c ASC
        ];
        if (menuRows.isEmpty()) {
            return new List<MenuGroup>();
        }

        Set<String> parentNames = new Set<String>();
        for (IPS_Activity_Menu__mdt row : menuRows) {
            if (String.isNotBlank(row.Timeline_Parent__c)) {
                parentNames.add(row.Timeline_Parent__c);
            }
        }
        Map<String, TimelineParent__mdt> parentsByName = getTimelineParents(parentNames);
        Map<String, String> groupLabels = getGroupLabels();
        Set<String> filledFields = getFilledFields(recordId, menuRows);

        Map<String, MenuGroup> groupsByKey = new Map<String, MenuGroup>();
        List<MenuGroup> groups = new List<MenuGroup>();
        for (IPS_Activity_Menu__mdt row : menuRows) {
            if (
                String.isNotBlank(row.Hide_When_Field_Has_Value__c) &&
                filledFields.contains(row.Hide_When_Field_Has_Value__c.trim().toLowerCase())
            ) {
                continue;
            }
            TimelineParent__mdt parent = parentsByName.get(row.Timeline_Parent__c);
            MenuOption option = toOption(row, parent, recordId);
            if (option == null) {
                continue;
            }
            MenuGroup menuGroup = groupsByKey.get(row.Group__c);
            if (menuGroup == null) {
                menuGroup = new MenuGroup();
                menuGroup.key = row.Group__c;
                menuGroup.label = groupLabels.containsKey(row.Group__c) ? groupLabels.get(row.Group__c) : row.Group__c;
                menuGroup.icon = GROUP_ICONS.get(row.Group__c);
                groupsByKey.put(row.Group__c, menuGroup);
                groups.add(menuGroup);
            }
            menuGroup.options.add(option);
        }
        for (MenuGroup menuGroup : groups) {
            if (menuGroup.icon == null) {
                menuGroup.icon = menuGroup.options[0].icon;
            }
        }
        return groups;
    }

    /**
     * Returns the lower-case API names of the configured Work_Trail__c fields that have a value.
     * Field names are validated against the describe, so only real, readable fields end up in the query.
     * Unknown or unreadable fields are ignored, which means the option is shown.
     */
    private static Set<String> getFilledFields(Id recordId, List<IPS_Activity_Menu__mdt> menuRows) {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Work_Trail__c.fields.getMap();
        Set<String> fieldNames = new Set<String>();
        for (IPS_Activity_Menu__mdt row : menuRows) {
            if (String.isBlank(row.Hide_When_Field_Has_Value__c)) {
                continue;
            }
            Schema.SObjectField field = fieldMap.get(row.Hide_When_Field_Has_Value__c.trim());
            if (field != null && field.getDescribe().isAccessible()) {
                fieldNames.add(field.getDescribe().getName());
            }
        }
        Set<String> filledFields = new Set<String>();
        if (fieldNames.isEmpty()) {
            return filledFields;
        }
        List<Work_Trail__c> trails = Database.queryWithBinds(
            'SELECT ' +
                String.join(new List<String>(fieldNames), ', ') +
                ' FROM Work_Trail__c WHERE Id = :recordId LIMIT 1',
            new Map<String, Object>{ 'recordId' => recordId },
            AccessLevel.USER_MODE
        );
        if (trails.isEmpty()) {
            return filledFields;
        }
        for (String fieldName : fieldNames) {
            Object value = trails[0].get(fieldName);
            if (value != null && !(value instanceof Boolean && !((Boolean) value))) {
                filledFields.add(fieldName.toLowerCase());
            }
        }
        return filledFields;
    }

    private static String getWorkTrailRecordType(Id recordId) {
        if (recordId == null || recordId.getSobjectType() != Work_Trail__c.SObjectType) {
            return null;
        }
        List<Work_Trail__c> trails = [
            SELECT RecordType.DeveloperName
            FROM Work_Trail__c
            WHERE Id = :recordId
            WITH USER_MODE
            LIMIT 1
        ];
        return trails.isEmpty() ? null : trails[0].RecordType.DeveloperName;
    }

    private static Map<String, TimelineParent__mdt> getTimelineParents(Set<String> parentNames) {
        Map<String, TimelineParent__mdt> parentsByName = new Map<String, TimelineParent__mdt>();
        for (TimelineParent__mdt parent : [
            SELECT
                DeveloperName,
                SObjectRelationshipField__c,
                CreateableObject_NoOverride__c,
                Timeline_Child__r.SObjectName__c,
                Timeline_Child__r.CreateableObject_RecordType__c,
                Timeline_Child__r.CreateableObject_TextNorwegian__c,
                Timeline_Child__r.SLDS_Dropdown_Icon__c,
                Timeline_Child__r.SObjectTypeField__c,
                Timeline_Child__r.SObjectTypeValue__c,
                Timeline_Child__r.CreateableObject_Field1__c,
                Timeline_Child__r.CreateableObject_Value1__c,
                Timeline_Child__r.CreateableObject_Field2__c,
                Timeline_Child__r.CreateableObject_Value2__c,
                Timeline_Child__r.CreateableObject_Field3__c,
                Timeline_Child__r.CreateableObject_Value3__c,
                Timeline_Child__r.CreateableObject_Field4__c,
                Timeline_Child__r.CreateableObject_Value4__c,
                Timeline_Child__r.CreateableObject_Field5__c,
                Timeline_Child__r.CreateableObject_Value5__c
            FROM TimelineParent__mdt
            WHERE DeveloperName IN :parentNames AND IsActive__c = TRUE AND CreateableObject_Checkbox__c = TRUE
        ]) {
            parentsByName.put(parent.DeveloperName, parent);
        }
        return parentsByName;
    }

    private static MenuOption toOption(IPS_Activity_Menu__mdt row, TimelineParent__mdt parent, Id recordId) {
        if (String.isNotBlank(row.Flow_API_Name__c)) {
            MenuOption flowOption = new MenuOption();
            flowOption.key = row.DeveloperName;
            flowOption.label = row.Label__c;
            flowOption.helpText = row.Help_Text__c;
            flowOption.icon = GROUP_ICONS.get(row.Group__c);
            flowOption.flowApiName = row.Flow_API_Name__c.trim();
            return flowOption;
        }
        if (parent == null) {
            return null;
        }
        TimelineChild__mdt child = parent.Timeline_Child__r;
        if (child == null) {
            return null;
        }
        Schema.DescribeSObjectResult objectDescribe = describe(child.SObjectName__c);
        if (objectDescribe == null || !objectDescribe.isCreateable()) {
            return null;
        }

        Id recordTypeId = null;
        if (String.isNotBlank(child.CreateableObject_RecordType__c)) {
            Schema.RecordTypeInfo recordTypeInfo = objectDescribe.getRecordTypeInfosByDeveloperName()
                .get(child.CreateableObject_RecordType__c);
            if (recordTypeInfo == null || !recordTypeInfo.isActive() || !recordTypeInfo.isAvailable()) {
                return null;
            }
            recordTypeId = recordTypeInfo.getRecordTypeId();
        }

        MenuOption option = new MenuOption();
        option.key = row.DeveloperName;
        option.label = String.isNotBlank(row.Label__c) ? row.Label__c : child.CreateableObject_TextNorwegian__c;
        option.helpText = row.Help_Text__c;
        option.icon = child.SLDS_Dropdown_Icon__c == null ? null : child.SLDS_Dropdown_Icon__c.toLowerCase();
        option.objectApiName = child.SObjectName__c;
        option.recordTypeId = recordTypeId;
        option.noOverride = parent.CreateableObject_NoOverride__c != false;
        option.defaultFieldValues = getDefaultFieldValues(parent, child, recordId);
        return option;
    }

    @TestVisible
    private static Map<String, String> getDefaultFieldValues(
        TimelineParent__mdt parent,
        TimelineChild__mdt child,
        Id recordId
    ) {
        Map<String, String> values = new Map<String, String>();
        putIfValid(values, parent.SObjectRelationshipField__c, recordId);
        putIfValid(values, child.SObjectTypeField__c, child.SObjectTypeValue__c);
        putIfValid(values, child.CreateableObject_Field1__c, child.CreateableObject_Value1__c);
        putIfValid(values, child.CreateableObject_Field2__c, child.CreateableObject_Value2__c);
        putIfValid(values, child.CreateableObject_Field3__c, child.CreateableObject_Value3__c);
        putIfValid(values, child.CreateableObject_Field4__c, child.CreateableObject_Value4__c);
        putIfValid(values, child.CreateableObject_Field5__c, child.CreateableObject_Value5__c);
        return values;
    }

    // Mirrors the timeline: skip empty values and multi-select values (containing ';').
    private static void putIfValid(Map<String, String> values, String field, String value) {
        if (isInvalid(field) || isInvalid(value)) {
            return;
        }
        values.put(field, value.replace(TODAY_MACRO, String.valueOf(Date.today())));
    }

    private static Boolean isInvalid(String input) {
        return String.isBlank(input) || input == 'null' || input.contains(';');
    }

    private static Schema.DescribeSObjectResult describe(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return null;
        }
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
        return objectType == null ? null : objectType.getDescribe();
    }

    private static Map<String, String> getGroupLabels() {
        Map<String, String> labels = new Map<String, String>();
        for (Schema.PicklistEntry entry : IPS_Activity_Menu__mdt.Group__c.getDescribe().getPicklistValues()) {
            labels.put(entry.getValue(), entry.getLabel());
        }
        return labels;
    }

    public class MenuGroup {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public List<MenuOption> options = new List<MenuOption>();
    }

    public class MenuOption {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String helpText;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String flowApiName;
        @AuraEnabled
        public Id recordTypeId;
        @AuraEnabled
        public Boolean noOverride;
        @AuraEnabled
        public Map<String, String> defaultFieldValues;
    }
}
