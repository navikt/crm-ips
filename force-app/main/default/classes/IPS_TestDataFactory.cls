@istest
public with sharing class IPS_TestDataFactory {
    public static Person__c createPerson() {
        return createPerson('12069755555');
    }

    public static Person__c createPerson(String ident) {
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.Name = ident;
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First' + ident;

        return person;
    }

    public static User getStandardUser(String firstname, String lastname) {
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user = new User(
            FirstName = firstname,
            LastName = lastname,
            Email = firstname + '.' + lastname + '@nav.no',
            Username = firstname + '.' + lastname + '@nav.no',
            Alias = firstname.substring(0, 2) + lastname.substring(0, 2),
            LanguageLocaleKey = 'no',
            LocaleSidKey = 'no_NO',
            TimeZoneSidKey = 'Europe/Paris',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            Department = '1',
            CRM_NAV_Ident__c = firstname.substring(0, 2) + lastname.substring(0, 2) + '123'
        );
        return user;
    }

    public static User getAdminUser(String firstname, String lastname) {
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = 'System administrator' LIMIT 1];
        User user = new User(
            FirstName = firstname,
            LastName = lastname,
            Email = firstname + '.' + lastname + '@nav.no',
            Username = firstname + '.' + lastname + '@nav.no',
            Alias = firstname.substring(0, 2) + lastname.substring(0, 2),
            LanguageLocaleKey = 'no',
            LocaleSidKey = 'no_NO',
            TimeZoneSidKey = 'Europe/Paris',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            Department = '1',
            CRM_NAV_Ident__c = firstname.substring(0, 2) + lastname.substring(0, 2) + '123'
        );
        return user;
    }

    public static Account createEmployerAccount() {
        Integer intrandomNumber = Integer.valueof((Math.random() * 1000));
        Account acct = new Account();
        acct.Name = 'Røre Pinne' + intrandomNumber;
        acct.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
        return acct;
    }

    public static Work_Trail__c createJobbspor(String participantId) {
        Work_Trail__c trail = new Work_Trail__c();
        trail.ips_Participant__c = participantId;
        trail.ips_Status__c = 'In Education';
        trail.ips_Passive__c = false;
        trail.IPS_Partticipant_phone_number__c = '987 65 432';
        trail.RecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName().get('IPS').getRecordTypeId();
        return trail;
    }

    public static Work_Trail__c createUOJobbspor(String participantId) {
        Work_Trail__c trailUO = new Work_Trail__c();
        trailUO.ips_Participant__c = participantId;
        trailUO.ips_Status__c = 'Initial contact';
        trailUO.ips_UO_Service__c = 'AMS';
        trailUO.IPS_Partticipant_phone_number__c = '987 65 432';
        trailUO.RecordTypeId = SObjectType.Work_Trail__c.getRecordTypeInfosByDeveloperName()
            .get('ips_Supported_Employment')
            .getRecordTypeId();
        return trailUO;
    }

    public static Event createEmployerEventWithoutParticipant(String employerId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            RelatedToAccount__c = employerId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med Arbeidsgiver',
            Description = 'Møte',
            IPS_isFromTimeline__c = true,
            IPS_Type__c = 'Meeting with Employer',
            ips_uo_Kanal__c = 'Fysisk',
            Location = 'Møte ett sted',
            ips_Subcategory_Type_IPS__c = 'Job support',
            F_rste_arbeidsgiverm_te__c = 'Nei',
            ips_Out_in_the_field__c = true,
            IPS_Status1__c = 'Open'
        );
        return createEvent;
    }

    /**
     * Creates task delmål
     * Activities related to worktrail
     * @param jobbsporId worktrail id of the task
     * @return  `Task`
     */
    public static Task creategoal(String jobbsporId) {
        Id devRecordTypeId1 = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();
       
        Task taskGoal = new Task(
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId1,
            Type_of_Task_IPSUO__c = 'Delmål (av hovedmål)',
            ips_Due_Date_Time__c = system.Datetime.now().addMonths(1),
            ActivityDate = system.Date.today().addMonths(1),
            Subject = 'Ett delmål',
            Status = 'Open' 
        );
        return taskGoal;
    }

    /**
     * Creates task for passive participant in IPS
     * This simulates a passiv participant in worktrail
     * @param jobbsporId worktrail id of the task
     * @return  `Task`
     */
    public static Task createPassiveActivateGoal(String jobbsporId) {
        Id devRecordTypeId1 = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();

        Task taskGoal = new Task(
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId1,
            ips_Due_Date_Time__c = system.Datetime.now(),
            Type_of_Task_IPSUO__c = 'Historikk',
            Subject = 'Passiv tilstand aktivert',
            Status = 'Completed'
        );
        return taskGoal;
    }

    /**
     * Creates task for participant who is deactiverted from passive period in IPS
     * This simulates a participant who is deactiverted from passive period in worktrail
     * @param jobbsporId worktrail id of the task
     * @return  `Task`
     */
    public static Task createPassiveDeactivateGoal(String jobbsporId) {
        Id devRecordTypeId1 = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();

        Task taskGoal = new Task(
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId1,
            ips_Due_Date_Time__c = system.Datetime.now().addDays(1),
            Type_of_Task_IPSUO__c = 'Historikk',
            subject = 'Passiv tilstand deaktivert',
            Status = 'Completed'
        );
        return taskGoal;
    }

    public static Task createhistory(String jobbsporId) {
        Id devRecordTypeId1 = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('IPS_Task').getRecordTypeId();

        Task taskGoal = new Task(
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId1,
            Type_of_Task_IPSUO__c = 'Historikk',
            Subject = 'Endre eier',
            Status = 'Completed'
        );
        return taskGoal;
    }

    public static Event createEmployerEventWithParticipant(String employerId, Id ownerId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName().get('IPS_Event').getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            IPS_participant_related_to_meeting__c = true,
            WhatId = jobbsporId,
            RelatedToAccount__c = employerId,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            Subject = 'Møte med Arbeidsgiver',
            Description = 'Møte',
            IPS_isFromTimeline__c = true,
            IPS_Type__c = 'Meeting with Employer',
            ips_uo_Kanal__c = 'Fysisk',
            ips_Subcategory_Type_IPS__c = 'Job support',
            IPS_Status1__c = 'Open',
            OwnerId = ownerId,
            ips_Out_in_the_field__c = true,
            Location = 'Kontoret'
        );
        return createEvent;
    }

     /**
     * Creates Event, type Meeting with Participant
     * Activities related to worktrail
     * @param contactid, jobbsporId,status worktrail id of the event
     * @return  `Event`
     */
    public static Event createParticipantEvent(String contactId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName()
            .get('Ips_uo_Deltakermote')
            .getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            IPS_participant_related_to_meeting__c = true,
            WhatId = jobbsporId,
            WhoId = contactId,
            RecordTypeId = devRecordTypeId,
            StartDateTime = system.Datetime.now().addHours(-1),
            EndDateTime = system.Datetime.now(),
            IPS_travelTimeFrom__c = 20,
            Subject = 'Møte med deltaker',
            IPS_isFromTimeline__c = true,
            Description = 'Møte',
            IPS_Type__c = 'Meeting with Participant',
            IPS_Status1__c = 'Open',
            ips_uo_Kanal__c = 'Fysisk',
            ips_Out_in_the_field__c = true,
            Location = 'Kontoret'
        );
        return createEvent;
    }

    public static Event createParticipantEventWithOwner(String ownerId, String jobbsporId) {
        Id devRecordTypeId = SObjectType.Event.getRecordTypeInfosByDeveloperName()
            .get('Ips_uo_Deltakermote')
            .getRecordTypeId();

        Event createEvent = new Event(
            ips_Travel_time__c = 15,
            IPS_participant_related_to_meeting__c = true,
            WhatId = jobbsporId,
            RecordTypeId = devRecordTypeId,
            IPS_travelTimeFrom__c = 20,
            StartDateTime = system.Datetime.now(),
            EndDateTime = system.Datetime.now().addHours(1),
            Subject = 'Møte med deltaker',
            IPS_isFromTimeline__c = true,
            Description = 'Møte',
            IPS_Type__c = 'Meeting with Participant',
            IPS_Status1__c = 'Open',
            OwnerId = ownerId,
            ips_uo_Kanal__c = 'Fysisk',
            ips_Out_in_the_field__c = true,
            Location = 'Kontoret'
        );
        return createEvent;
    }

    public static ips_Job__c createJob(ID employerId, ID worktrailId, String status) {
        Date endDate;
        Date startDate = System.today();
        if (status == 'Ongoing' || status == 'Planned') {
            endDate = startDate.addMonths(1);
        } else {
            startDate = startDate.addMonths(-1);
            endDate = startDate.addDays(-1);
        }

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Jobb nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = startDate,
            ips_End_Date__c = endDate,
            ips_Form_of_Employment__c = 'Permanent employment',
            ips_Job_Support__c = 'Dette er jobbstøtte',
            ips_Number_of_hours__c = 40,
            ips_Status__c = status,
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke',
            ips_What_did_work_at_the_workplace__c = 'Fungerte'
        );
        return createJob;
    }

    public static ips_Job__c createWorkTraining(ID employerId, ID worktrailId, String status) {
        Date endDate;
        Date startDate = System.today();
        if (status == 'Ongoing' || status == 'Planned') {
            endDate = startDate.addMonths(1);
        } else {
            startDate = startDate.addMonths(-1);
            endDate = startDate.addDays(-1);
        }

        ips_Job__c createJob = new ips_Job__c(
            Name = 'Arbeidstrening nr 1',
            ips_Employer__c = employerId,
            ips_Work_Trail__c = worktrailId,
            ips_Start_Date__c = startDate,
            ips_End_Date__c = endDate,
            ips_Form_of_Employment__c = 'work training',
            ips_Job_Support__c = 'Dette er jobbstøtte',
            ips_Number_of_hours__c = 40,
            ips_Status__c = status,
            ips_What_did_not_work_at_the_workplace__c = 'Fungerte ikke',
            ips_What_did_work_at_the_workplace__c = 'Fungerte'
        );
        return createJob;
    }

    public static ips_report__c createEndReport(ID workTrailId) {
        ips_report__c endReport = new ips_report__c(
            IPS_endReport__c = 'Avslutningsnotat IPS',
            IPS_report_Type__c = 'End report',
            IPS_workTrailName__c = workTrailId
        );
        return endReport;
    }

    public static ips_report__c createIntervallReport(ID workTrailId) {
        ips_report__c intervallReport = new ips_report__c(
            IPS_intervallReport__c = 'Underveisnotat',
            IPS_report_Type__c = 'Intervall',
            IPS_workTrailName__c = workTrailId,
            IPS_intervallDateFrom__c =System.today().addMonths(-3),
            IPS_intervallDateTo__c = System.today().addDays(-1)
        );
        return intervallReport;
    }

    public static ips_Education__c createEducation(ID workTrailId) {
        ips_Education__c educationList = new ips_Education__c(
            ips_Work_Trail__c = workTrailId,
            ips_Education_Subject__c = 'Emne på utdanningen',
            ips_Contact_at_the_Education_Institution__c = 'Utdanningsinstitusjon',
            ips_Form_of_Education__c = 'Full-time Study',
            ips_Status__c = 'Ongoing',
            ips_Start_Date__c = System.today(),
            ips_End_Date__c = System.today().addDays(30)
        );
        return educationList;
    }

    public static AMS_Vocational_education_and_training__c createEducationAMS(ID workTrailId) {
        AMS_Vocational_education_and_training__c educationAMS = new AMS_Vocational_education_and_training__c(
            AMS_Work_Trail__c = workTrailId,
            AMS_Name_of_the_Education_institution__c = 'Navnet på utdanningsinstitusjon',
            AMS_Description__c = 'Beskrivelse av utdanningen',
            AMS_Educational_program__c = 'Building and Construction',
            AMS_Status__c = 'Ongoing',
            AMS_Start_Date__c = System.today(),
            AMS_End_Date__c = System.today().addDays(30),
            AMS_Form_of_Study__c = 'practice candidate'
        );
        return educationAMS;
    }

    public static User createInternalUserWithManager(String username, Id managerId) {
        Profile platformProfile = [SELECT Id FROM Profile WHERE Name = 'System administrator' LIMIT 1];

        User platformUser = new User();
        platformUser.FirstName = 'User';
        platformUser.LastName = 'Test';
        platformUser.Email = username;
        platformUser.UserName = username;
        platformUser.ProfileId = platformProfile.Id;
        platformUser.CRM_Nav_Ident__c = 'A123456';
        platformUser.Alias = 'plattest';
        platformUser.TimeZoneSidKey = 'Europe/Paris';
        platformUser.LocaleSidKey = 'no_NO';
        platformUser.EmailEncodingKey = 'ISO-8859-1';
        platformUser.LanguageLocaleKey = 'no';
        platformUser.ManagerId = managerId;
        return platformUser;
    }

    public static void addPermissionsetUser(String userId) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'IPS_Jobbspesialist'];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
    }
}