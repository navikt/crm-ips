/**
 * @description       : Test class for IPS_EventSMSService
 * @author            : hkavli
 * @group             : ipsSMS
 * @last modified on  : 11-25-2025
 * @last modified by  : hkavli
 **/
@IsTest
public with sharing class IPS_EventSMSServiceTest {
    /*    @IsTest
    public static void createTestData() {
        List<Person__c> persons = new List<Person__c>();
        persons.add(IPS_TestDataFactory.createPersons('G54321'));
        persons.add(IPS_TestDataFactory.createPersons('G54322'));

        List
        Event testEvent = IPS_TestDataFactory.createParticipantEvent();

        List<Work_Trail__c> workTrailList = new List<Work_Trail__c>();
        IPS_TestDataFactory.createWorkTrails(workTrailList, personList);
        insert workTrailList;

        List<Event> eventList = new List<Event>();
        IPS_TestDataFactory.createEvents(eventList, workTrailList);
        insert eventList;
    } */

    @IsTest
    public static void construcChangedMessageTest() {
        // Given
        List<Person__c> persons = new List<Person__c>();
        //   persons.add(IPS_TestDataFactory.createPersons('G54321'));
        //   persons.add(IPS_TestDataFactory.createPersons('G54322'));

        //        insert persons;

        //  List<
        //  Event testEvent = IPS_TestDataFactory.createParticipantEvent();

        // When
        //  String actualMessage = IPS_EventSMSService.constructChangedMessage(testEvent);

        // Then
        //Assert.isTrue(actualMessage.contains('Din avtale er endret'), 'Message should contain notification of change');
    }

    @IsTest
    public static void formatTimePeriodTest() {
        // Given
        Datetime startDateTime1 = Datetime.newInstance(2025, 11, 23, 14, 30, 0);
        Datetime startDateTime2 = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        // When
        String formattedTime1 = IPS_EventSMSService.formatTimePeriod(startDateTime1);
        String formattedTime2 = IPS_EventSMSService.formatTimePeriod(startDateTime2);

        // Then
        Assert.areEqual(
            formattedTime1,
            '23.11.2025, kl 14:30',
            'Expected formatted time period to be "23.11.2025, kl 14:30"'
        );
        Assert.isTrue(
            formattedTime2 == '01.01.2026, kl 09:00',
            'Expected formatted time period to be "01.01.2026, kl 09:00'
        );
    }

    @IsTest
    public static void setLocationTest() {
        // Given
        Event eventWithLocation = new Event(Location = 'Oslo Office, Meeting Room 123');
        Event eventWithChannel = new Event(ips_uo_Kanal__c = 'Video Call via Teams');
        Event eventWithNeither = new Event();

        // When
        String location1 = IPS_EventSMSService.setLocation(eventWithLocation);
        String location2 = IPS_EventSMSService.setLocation(eventWithChannel);
        String location3 = IPS_EventSMSService.setLocation(eventWithNeither);

        // Then
        Assert.areEqual(location1, 'Oslo Office, Meeting Room 123', 'Expected Location to be set from Event.Location');
        Assert.areEqual(location2, 'Video Call via Teams', 'Expected Location to be set from Event.ips_uo_Kanal__c');
        Assert.areEqual(location3, 'Ikke oppgitt', 'Expected Location to be "Ikke oppgitt" when neither field is set');
    }

    @IsTest
    public static void constructReminderMessageTest() {
        // Given
        Event testEvent = new Event(
            ips_uo_Kanal__c = 'Fysisk',
            StartDateTime = Datetime.newInstance(2025, 12, 5, 10, 0, 0)
        );

        // When
        String reminderMessage = IPS_EventSMSService.constructReminderMessage(testEvent);

        // Then
        Assert.isTrue(
            reminderMessage.contains('Husk fysisk møte med jobbspesialisten din.'),
            'Reminder message should contain the correct reminder text'
        );
        Assert.isTrue(
            reminderMessage.contains('Tidspunkt: 05.12.2025, kl 10:00'),
            'Reminder message should contain the correctly formatted date and time'
        );
        Assert.isTrue(
            reminderMessage.contains('Du kan ikke svare på denne meldingen.'),
            'Reminder message should inform that replies are not possible'
        );
    }
}
