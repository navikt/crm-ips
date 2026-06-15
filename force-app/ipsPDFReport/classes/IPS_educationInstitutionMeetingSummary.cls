/**
 * Wrapper class that stores aggregated education institution meeting data.
 * Used to transfer summary information from IPS_reportPDFService to
 * IPS_viewReportPDF for PDF report generation.
 * @author Balendra Sounthararajan
 * @since 09.06.26
 */
public class IPS_educationInstitutionMeetingSummary {

    public Integer totalMeetings { get; set; }
    public Integer completedMeetings { get; set; }
    public Integer cancelledMeetings { get; set; }
    public Integer participantsRelatedToMeeting { get; set; }
    public Integer participantsRelatedToMeetingCancelled {get; set;}
    public List<String> institutionNames { get; set; }

    public IPS_educationInstitutionMeetingSummary() {
        totalMeetings = 0;
        completedMeetings = 0;
        cancelledMeetings = 0;
        participantsRelatedToMeeting = 0;
        participantsRelatedToMeetingCancelled = 0;
        institutionNames = new List<String>();
    }
}