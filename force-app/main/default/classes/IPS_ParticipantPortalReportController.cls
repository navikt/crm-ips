public class IPS_ParticipantPortalReportController{
 
    /* Get all reports and show it in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalReport> getParticipantReport(String recordId,String typeOfId){
      Id currentRecordId = recordId;
      
      List<IPS_ParticipantPortalReport> wrapperList = new List<IPS_ParticipantPortalReport>();
      if(idType.TRAIL.name() == typeOfId){ 
          wrapperList = getReportWrapperList(currentRecordId);
      }
      if (idType.REPORT.name() == typeOfId) {
          wrapperList = getReportDetailList(currentRecordId);  
      }
      return wrapperList; 
  }
  
  /* */
  public enum idType {TRAIL, REPORT}
  
  /* */
  private static List<IPS_ParticipantPortalReport> getReportWrapperList(id currentRecordId){
      List<IPS_ParticipantPortalReport> wrapperTempList = new List<IPS_ParticipantPortalReport>();
      List<ips_report__c> tempReportList = new List<ips_report__c>();
      tempReportList =[SELECT id 
                      FROM ips_report__c
                      WHERE IPS_workTrailName__c =:currentRecordId
                      AND IPS_status__c = 'Shared report'];
      return wrapperTempList;
  
  
  }
  
      /* 
      * Get the report that is shared with participant
      *
      * @return List of reports
      */
      private static List<IPS_ParticipantPortalReport> getReportDetailList(Id currentRecordId){
        List<IPS_ParticipantPortalReport> wrapperTempList = new List<IPS_ParticipantPortalReport>();
  
        List<ips_report__c> tempReportList = new List<ips_report__c>();
        tempReportList =[
            SELECT 
            Id,
            IPS_dueDateBack__c,
            IPS_report_Type__c,
            IPS_participantName__c,
            IPS_workTrailOwner__c,
            IPS_worktrail_Type__c,
            IPS_subject__c,
            IPS_intervallDateFrom__c,
            IPS_intervallDateTo__c,
            IPS_summarizeIntervallNextPeriode__c,
            IPS_summarizeIntervallPeriode__c,
            IPS_workTrailName__r.ips_Main_goal__c,
            IPS_workTrailName__r.ips_UO_Service__c,
            IPS_workTrailName__r.ips_Main_Goal_list__c,
            IPS_workTrailName__r.ips_End_Date__c,
            IPS_workTrailName__r.End_Cause__c,
            IPS_workTrailName__r.ips_Other_end_cases__c,
            IPS_workTrailName__r.ips_NAV_supervisor__c,
            IPS_workTrailName__r.ips_Behandlingsteam__c,
            IPS_workTrailName__r.ips_Applying_Department__c,
            IPS_workTrailName__r.Oppstartsdato__c,
            IPS_workTrailName__r.ips_Referred_date__c,
            IPS_workTrailName__r.ips_Priority_career_wishes__c
            FROM ips_report__c 
            WHERE id =:currentRecordId
            AND IPS_status__c = 'Shared report' LIMIT 1];
  
            system.debug(tempReportList);
  
            if(!tempReportList.isEmpty()){
              for(ips_report__c r:tempReportList){
                  IPS_ParticipantPortalReport tempList = new IPS_ParticipantPortalReport();
                  tempList.reportId = r.Id;
                  tempList.reportDueDate =r.IPS_dueDateBack__c;
                  tempList.reportName = r.IPS_subject__c;
                  tempList.reportOwnerName = r.IPS_workTrailOwner__c;
                  tempList.reportParticipantName = r.IPS_participantName__c;
                  tempList.reportTrailGoalDescription = r.IPS_workTrailName__r.ips_Main_goal__c;
                  tempList.reportTrailEndDate = r.IPS_workTrailName__r.ips_End_Date__c;
                  tempList.reportTrailEndCause = r.IPS_workTrailName__r.End_Cause__c;
                  tempList.reportTrailEndSubCause = r.IPS_workTrailName__r.ips_Other_end_cases__c;
                  tempList.reportTrailReferredDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_workTrailName__r.ips_Referred_date__c);
                  
                  tempList.reportTrailStartDate = IPS_ParticipantPortalUtility.formatDateTime(r.IPS_workTrailName__r.Oppstartsdato__c);
                  tempList.reportTrailSupervisor = r.IPS_workTrailName__r.ips_NAV_supervisor__c;
  
                  
                  if(r.IPS_worktrail_Type__c =='Supported Employment'){
                      tempList.reportTrailGoal = IPS_ParticipantPortalUtility.formatMainGoal(r.IPS_workTrailName__r.ips_UO_Service__c);
                      tempList.reportTrailDepartmentTeam = r.IPS_workTrailName__r.ips_Applying_Department__c;
                      tempList.reportTrailDepartmentTeamLabel ='Innsøkende avdeling';
                  }
  
                  if(r.IPS_worktrail_Type__c =='IPS'){
                      tempList.reportTrailGoal = IPS_ParticipantPortalUtility.formatMainGoal(r.IPS_workTrailName__r.ips_Main_Goal_list__c);
                      tempList.reportTrailDepartmentTeam = r.IPS_workTrailName__r.ips_Behandlingsteam__c;
                      tempList.reportTrailDepartmentTeamLabel ='Behandlingsteam';
                      tempList.reportTrailWorkWish= r.IPS_workTrailName__r.ips_Priority_career_wishes__c;
  
                  }
                  if(r.IPS_report_Type__c =='Intervall'){
                      tempList.reportFromDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_intervallDateFrom__c);
                       tempList.reportToDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_intervallDateTo__c);
                       tempList.reportIntervallSummarizePeriode = r.IPS_summarizeIntervallPeriode__c;
                       tempList.reportIntervallSummarizeNextPeriode = r.IPS_summarizeIntervallNextPeriode__c;
                  }
  
                  if(r.IPS_report_Type__c =='End report'){
  
                  }
                  
                  wrapperTempList.add(tempList);
              }
          }
          return wrapperTempList;
      }
  }