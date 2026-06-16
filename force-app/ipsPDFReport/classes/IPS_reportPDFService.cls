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
}