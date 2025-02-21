public class IPS_ParticipantPortalReport{
    @AuraEnabled
    public Id reportId;

    @AuraEnabled
    public Id reportTrailId;

    @AuraEnabled
    public String reportDueDate;

    @AuraEnabled
    public String reportParticipantName;

    @AuraEnabled
    public String reportOwnerName;
    
    @AuraEnabled
    public String reportType;

    @AuraEnabled
    public String reportTrailType;
    
    @AuraEnabled
    public DateTime createdDate;
    
    @AuraEnabled
    public String reportFromDate;

    @AuraEnabled
    public Date reportNotFormatFromDate;
    
    @AuraEnabled
    public String reportToDate;

    @AuraEnabled
    public Date reportNotFormatToDate;

    @AuraEnabled
    public String reportName;

    @AuraEnabled
    public String reportIntervallSummarizePeriode;

    @AuraEnabled
    public String reportIntervallSummarizeNextPeriode;

    @AuraEnabled
    public String reportTrailGoal;

    @AuraEnabled
    public String reportTrailGoalDescription;

    @AuraEnabled
    public Date reportTrailEndDate;

    @AuraEnabled
    public String reportTrailEndCause;

    @AuraEnabled
    public String reportTrailEndSubCause;

    @AuraEnabled
    public String reportTrailSupervisor;

    @AuraEnabled
    public String reportTrailDepartmentTeam;

    @AuraEnabled
    public String reportTrailDepartmentTeamLabel;

    @AuraEnabled
    public String reportTrailReferredDate;

    @AuraEnabled
    public String reportTrailStartDate;
    
    @AuraEnabled
    public String reportTrailWorkWish;
    
    @AuraEnabled
    public String reportParticipantComment;
    @AuraEnabled public String reportParticipantOnBehalfComment;

}