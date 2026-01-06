/**
 * @description       : Seeds Scratch Org with test data
 * @author            : hkavli
 * @last modified on  : 11-10-2025
 * @last modified by  : hkavli
**/
// Create persons
List<Person__c> persons = new List<Person__c>();
persons.add(new Person__c(
    Name = '14099998767',
    INT_LastName__c = 'Pannacotta',
    INT_Confidential__c = 'UGRADERT',
    INT_DateOfBirth__c = '1999-09-14',
    INT_ResidentialAddress__c = 'Pannacottaveien 2',
    INT_ResidentialZipCode__c = '1300'
));
persons.add(new Person__c(
    Name = '12069755555',
    INT_LastName__c = 'Kake',
    INT_Confidential__c = 'UGRADERT',
    INT_DateOfBirth__c = '1997-06-12',
    INT_ResidentialAddress__c = 'Kakevegen 3',
    INT_ResidentialZipCode__c = '1400'
));
persons.add(new Person__c(
    Name = '24069755555',
    INT_LastName__c = 'Brownies',
    INT_Confidential__c = 'UGRADERT',
    INT_DateOfBirth__c = '1997-06-24',
    INT_ResidentialAddress__c = 'Browniesalleen 6',
    INT_ResidentialZipCode__c = '1500'
));
persons.add(new Person__c(
    Name = '30120144345',
    INT_LastName__c = 'Wienebrød',
    INT_Confidential__c = 'UGRADERT',
    INT_DateOfBirth__c = '2010-12-30',
    INT_ResidentialAddress__c = 'Wienerstangvegen 5',
    INT_ResidentialZipCode__c = '1600'
)); 

insert persons;

// Create Work Trails
List<Work_Trail__c> workTrails = new List<Work_Trail__c>();        
Id workTrailRecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();

for (Account personAccounts : [SELECT Id, PersonContactId, Name FROM Account WHERE CRM_Person__c IN :persons]) {
    Work_Trail__c workTrail = new Work_Trail__c(
        Name = 'Jobbsporet - ' + personAccounts.Name,
        ips_Participant__c =  personAccounts.Id, 
        RecordTypeId = workTrailRecordTypeId,
        ips_Status__c = 'In Education',
        ips_Passive__c = false,
        IPS_Partticipant_phone_number__c = '98765431');
    workTrails.add(workTrail);
}

insert workTrails;

