public with sharing class IPS_ParticipantPortalReportController{
    /* */
  public enum idType {TRAIL, REPORT}
 
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

   /* Get all completed goals and show it in report in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalTask> getParticipantsReportCompletedGoals(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport; //if true the report is end report, if false the report is intervall report
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;
    

        List<IPS_ParticipantPortalTask> wrapperList = new List<IPS_ParticipantPortalTask>();
        wrapperList = getReportCompletedGoals(currentRecordId,reportType,reportDateFrom,reportDateTo);
        return wrapperList;
        
    }
  
  

     /**
     * Returns a list of unique goals that are completed either
     * within the given intervall or the whole period of the worktrail.
     *
     * @return  List of task
     */
    private static List<IPS_ParticipantPortalTask> getReportCompletedGoals(id currentRecordId,String reportType,Date reportDateFrom,Date reportDateTo) {
        List<IPS_ParticipantPortalTask> wrapperTempList = new List<IPS_ParticipantPortalTask>();
        List<Task> tempGoalList = new List<Task>();
        List<Task> tempIntervalDueDateGoals = new List<Task>();
        List<Task> tempIntervalCompletedGoals = new List<Task>();
        List<Task> tempIntervalGoals = new List<Task>();

        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Completed\' ';
        String goalId = ' AND WhatId = :currentRecordId';
        String goalDueDateFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String goalCompletedDateFilter = ' AND DAY_ONLY(CompletedDateTime) >= :reportDateFrom AND DAY_ONLY(CompletedDateTime) <= :reportDateTo';
        String goalSort = ' ORDER BY ActivityDate DESC';
        String endQuery = '';
        String dueDateQuery = '';
        String completedDateQuery = '';

        if (reportType == 'End report') {
            endQuery = goalSelect + goalWhere + goalId + goalSort;
            tempGoalList = Database.query(endQuery);

            for(Task t:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = t.subject;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(t.ActivityDate);
                tempList.ReferatKommentar = t.Description;
                tempList.OppgaveId = t.id;
                wrapperTempList.add(tempList);
            }
        }

        /* Getting goals that are completed within the intervall and
         has a due date within the intervall with status completed */
        if (reportType =='Intervall') {
            dueDateQuery = goalSelect + goalWhere + goalId + goalDueDateFilter + goalSort;
            tempIntervalDueDateGoals = Database.query(dueDateQuery);

            completedDateQuery = goalSelect + goalWhere + goalId + goalCompletedDateFilter + goalSort;
            tempIntervalCompletedGoals = Database.query(completedDateQuery);

            tempIntervalGoals.addAll(tempIntervalDueDateGoals);
            tempGoalList = tempIntervalGoals;

            for(Task t:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = t.subject;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(t.ActivityDate);
                tempList.ReferatKommentar = t.Description;
                tempList.OppgaveId = t.id;
                wrapperTempList.add(tempList);
            }


            // Adding unique completed goals to the list of goals queried by due date
            for (Task task : tempIntervalCompletedGoals) {
                if (!tempGoalList.contains(task)) {
                    IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                    tempList.Emne = task.subject;
                    tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(task.ActivityDate);
                    tempList.ReferatKommentar = task.Description;
                    tempList.OppgaveId = task.id;
                    wrapperTempList.add(tempList);
                }
            }
        }        
        return wrapperTempList;
    }
  
  /* */
  private static List<IPS_ParticipantPortalReport> getReportWrapperList(id currentRecordId){
      List<IPS_ParticipantPortalReport> wrapperTempList = new List<IPS_ParticipantPortalReport>();
      List<ips_report__c> tempReportList = new List<ips_report__c>();
      tempReportList =[SELECT id,IPS_subject__c,IPS_dueDateBack__c
                      FROM ips_report__c
                      WHERE IPS_workTrailName__c =:currentRecordId
                      AND IPS_status__c = 'Shared report'];

                      for(ips_report__c r:tempReportList){
                          IPS_ParticipantPortalReport tempList = new IPS_ParticipantPortalReport();
                         tempList.reportId = r.Id;
                         tempList.reportName = r.IPS_subject__c;
                         tempList.reportDueDate  =IPS_ParticipantPortalUtility.formatDate(r.IPS_dueDateBack__c);
                         wrapperTempList.add(tempList);
                      }
                      
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
            IPS_participantsComment__c,
            IPS_participantsOnBehalf__c,
            IPS_workTrailOwner__c,
            IPS_worktrail_Type__c,
            IPS_subject__c,
            IPS_intervallDateFrom__c,
            IPS_intervallDateTo__c,
            IPS_summarizeIntervallNextPeriode__c,
            IPS_summarizeIntervallPeriode__c,
            IPS_workTrailName__c,
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
                  tempList.reportTrailId = r.IPS_workTrailName__c;
                  tempList.reportDueDate =IPS_ParticipantPortalUtility.formatDate(r.IPS_dueDateBack__c);
                  tempList.reportName = r.IPS_subject__c;
                  tempList.reportType = r.IPS_report_Type__c;
                  tempList.reportParticipantComment =r.IPS_participantsComment__c;
                  tempList.reportParticipantOnBehalfComment = r.IPS_participantsOnBehalf__c;
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
                      tempList.reportTrailType = 'AMS';
                  }
  
                  if(r.IPS_worktrail_Type__c =='IPS'){
                      tempList.reportTrailGoal = IPS_ParticipantPortalUtility.formatMainGoal(r.IPS_workTrailName__r.ips_Main_Goal_list__c);
                      tempList.reportTrailDepartmentTeam = r.IPS_workTrailName__r.ips_Behandlingsteam__c;
                      tempList.reportTrailDepartmentTeamLabel ='Behandlingsteam';
                      tempList.reportTrailWorkWish= r.IPS_workTrailName__r.ips_Priority_career_wishes__c;
                      tempList.reportTrailType = 'IPS';
  
                  }
                  if(r.IPS_report_Type__c =='Intervall'){
                      tempList.reportFromDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_intervallDateFrom__c);
                      tempList.reportNotFormatFromDate = r.IPS_intervallDateFrom__c;
                      tempList.reportToDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_intervallDateTo__c);
                      tempList.reportNotFormatToDate = r.IPS_intervallDateTo__c;
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