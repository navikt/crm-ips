@isTest
public with sharing class ArchiveHelper_Test {
    @isTest
    static void testConvertRecordsToJson() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account 1'));
        accounts.add(new Account(Name = 'Test Account 2'));

        List<List<SObject>> recordsList = new List<List<SObject>>();
        recordsList.add(accounts);

        Test.startTest();
        List<String> jsonResults = ArchiveHelper.convertRecordsToJson(recordsList);
        Test.stopTest();

        Assert.areNotEqual(0, jsonResults.size(), 'JSON result list should not be empty');
        Assert.isTrue(
            jsonResults[0].contains('"Name":"Test Account 1"'),
            'JSON should contain the first account name'
        );
        Assert.isTrue(
            jsonResults[0].contains('"Name":"Test Account 2"'),
            'JSON should contain the second account name'
        );
        Assert.isTrue(jsonResults[0].startsWith('['), 'JSON output should be an array');
    }
}
