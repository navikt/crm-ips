
@isTest
private class IPS_reportPDFServiceTest {

   @IsTest
    static void buildSummary_shouldSummarizeMeetingsCorrectly() {
        List<Event> meetings = new List<Event>{
            new Event(
                IPS_Status1__c = 'Completed',
                IPS_participant_related_to_meeting__c = true,
                IPS_educationInstitution__c = 'Aremark VGS'
            ),
            new Event(
                IPS_Status1__c = 'Completed',
                IPS_participant_related_to_meeting__c = false,
                IPS_educationInstitution__c = 'Aremark VGS'
            ),
            new Event(
                IPS_Status1__c = 'Cancelled',
                IPS_participant_related_to_meeting__c = false
            ),
            new Event(
                IPS_Status1__c = 'Participant Absent',
                IPS_participant_related_to_meeting__c = true
            )
        };

        IPS_educationInstitutionMeetingSummary summary =
            IPS_reportPDFService.buildSummary(meetings);

        Assert.areEqual(4, summary.totalMeetings);
        Assert.areEqual(2, summary.completedMeetings);
        Assert.areEqual(1, summary.cancelledMeetings);
        Assert.areEqual(1, summary.participantsRelatedToMeeting);
        Assert.areEqual(1, summary.participantsRelatedToMeetingCancelled);
        Assert.areEqual(1, summary.institutionNames.size());
        Assert.isTrue(summary.institutionNames.contains('aremark vgs'));
    }

    @IsTest
    static void getEducationMeetingsCompletedWithinInterval_shouldReturnOnlyCompletedWithinDates() {
        Date fromDate = Date.newInstance(2026, 6, 1);
        Date endDate = Date.newInstance(2026, 6, 30);

        List<Event> meetings = new List<Event>{
            new Event(
                ActivityDate = Date.newInstance(2026, 6, 10),
                IPS_Status1__c = 'Completed'
            ),
            new Event(
                ActivityDate = Date.newInstance(2026, 6, 20),
                IPS_Status1__c = 'Cancelled'
            ),
            new Event(
                ActivityDate = Date.newInstance(2026, 7, 1),
                IPS_Status1__c = 'Completed'
            ),
            new Event(
                ActivityDate = Date.newInstance(2026, 5, 31),
                IPS_Status1__c = 'Completed'
            )
        };

        List<Event> result =
            IPS_reportPDFService.getEducationMeetingsCompletedWithinInterval(
                meetings,
                fromDate,
                endDate
            );

        Assert.areEqual(1, result.size());
        Assert.areEqual(Date.newInstance(2026, 6, 10), result[0].ActivityDate);
        Assert.areEqual('Completed', result[0].IPS_Status1__c);
    }

    @IsTest
    static void getEducationMeetingsCompletedWithinInterval_shouldThrowWhenDatesAreNull() {
        Boolean exceptionThrown = false;

        try {
            IPS_reportPDFService.getEducationMeetingsCompletedWithinInterval(
                new List<Event>(),
                null,
                Date.today()
            );
        } catch (IllegalArgumentException e) {
            exceptionThrown = true;
            Assert.areEqual(
                'Interval report from date and end date cannot be null',
                e.getMessage()
            );
        }

        Assert.isTrue(exceptionThrown);
    }

    @IsTest
    static void getEducationMeetingsCompletedWithinInterval_shouldThrowWhenActivityDateIsNull() {
        Boolean exceptionThrown = false;

        try {
            IPS_reportPDFService.getEducationMeetingsCompletedWithinInterval(
                new List<Event>{
                    new Event(
                        IPS_Status1__c = 'Completed'
                    )
                },
                Date.today().addDays(-1),
                Date.today()
            );
        } catch (IllegalArgumentException e) {
            exceptionThrown = true;
            Assert.areEqual(
                'Meeting activity date cannot be null',
                e.getMessage()
            );
        }

        Assert.isTrue(exceptionThrown);
    }
}