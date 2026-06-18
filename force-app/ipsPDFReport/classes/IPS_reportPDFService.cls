/**
 * This class is responsible for generating a summary of education institution meetings.
 * @author Balendra Sounthararajan
 * @since 09.06.26
 */
public with sharing class IPS_reportPDFService {

     /**
      * Builds a summary of education institution meetings based on a list of Event records.
      * @param meetings The list of Event records to summarize.
      * @return An IPS_educationInstitutionMeetingSummary object containing the summary.
      */
     public static IPS_educationInstitutionMeetingSummary buildSummary(List<Event> meetings){
        IPS_educationInstitutionMeetingSummary summary = new IPS_educationInstitutionMeetingSummary();

        Set<String> uniqueInstitutionNames = new Set<String>();

        for (Event meeting : meetings) {
            summary.totalMeetings++;

            if (meeting.IPS_Status1__c == 'Completed') {
                summary.completedMeetings++;
            }

            if (meeting.IPS_Status1__c == 'Cancelled') {
                summary.cancelledMeetings++;
            }

            if(meeting.IPS_participant_related_to_meeting__c == true && meeting.IPS_Status1__c == 'Completed'){
                summary.participantsRelatedToMeeting++;
            }

            if(meeting.IPS_participant_related_to_meeting__c == true && meeting.IPS_Status1__c == 'Participant Absent'){
                summary.participantsRelatedToMeetingCancelled++;
            }

            if (String.isNotBlank(meeting.IPS_educationInstitution__c) && meeting.IPS_Status1__c == 'Completed') {
                uniqueInstitutionNames.add(
                    meeting.IPS_educationInstitution__c.trim().toLowerCase()
                );
            }
        }

        summary.institutionNames.addAll(uniqueInstitutionNames);

        return summary;
    }

    /**
     * Returns list of meetings completed within given interval
     * @param meetings List of education meetings
     * @param fromDate Start date of the interval report
     * @param endDate End date of the interval report
     * @return  `List<Event>` List of events within interval with completed status
     */
    public static List<Event> getEducationMeetingsCompletedWithinInterval(List<Event> meetings, Date fromDate, Date endDate){
        List<Event> meetingsWithinInterval = new List<Event>();
        if(fromDate == null || endDate == null){
            throw new IllegalArgumentException('Report from date and end date cannot be null');
        }
        for(Event meeting : meetings){
            if(meeting.ActivityDate == null){
                throw new IllegalArgumentException('Meeting activity date cannot be null');
            }
            if  (
                meeting.ActivityDate >= fromDate &&
                meeting.ActivityDate <= endDate &&
                meeting.IPS_Status1__c == 'Completed'
                ){
                    meetingsWithinInterval.add(meeting);
            }
        }
        return meetingsWithinInterval;
    }
}