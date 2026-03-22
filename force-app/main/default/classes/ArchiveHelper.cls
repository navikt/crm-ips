public inherited sharing class ArchiveHelper {
    @InvocableMethod(label='Convert SObject to JSON' description='Converts records of any SObject to JSON format.')
    public static List<String> convertRecordsToJson(List<List<SObject>> recordsList) {
        List<String> jsonResults = new List<String>();

        for (List<SObject> records : recordsList) {
            String jsonString = JSON.serialize(records);
            jsonResults.add(jsonString);
        }
        return jsonResults;
    }
}
