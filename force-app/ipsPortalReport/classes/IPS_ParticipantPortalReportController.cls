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
        String reportType = typeOfReport; 
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;
    

        List<IPS_ParticipantPortalTask> wrapperList = new List<IPS_ParticipantPortalTask>();
        wrapperList = getReportCompletedGoals(currentRecordId,reportType,reportDateFrom,reportDateTo);
        return wrapperList;
        
    }

    /* Get all completed participant meetings and show it in report in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantsReportCompletedMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();

        if(reportType =='Intervall'){
           
            wrapperListMeeting = getReportCompletedMeetings(currentRecordId,reportDateFrom, reportDateTo); 
        }
        if(reportType =='End report'){
            wrapperListMeeting = getReportCompletedMeetings(currentRecordId);
        }

        return wrapperListMeeting;
    }

        /* Get all absent participant meetings and show it in report in experience cloud*/
        @AuraEnabled(cacheable=true)
        public static List<IPS_ParticipantPortalEvent> getParticipantsReportAbsentMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
            Id currentRecordId = recordId;
            String reportType = typeOfReport;
            Date reportDateTo = recordDateTo;
            Date reportDateFrom = recordDateFrom;
    
            List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();
    
            if(reportType =='Intervall'){
    
                wrapperListMeeting = getReportAbsentMeetings(currentRecordId,reportDateFrom, reportDateTo);
    
            }
            if(reportType =='End report'){
    
                wrapperListMeeting = getReportAbsentMeetings(currentRecordId);
            }
    
            return wrapperListMeeting;
        }

        /* Get all completed employee meetings and show it in report in experience cloud*/
        @AuraEnabled(cacheable=true)
        public static List<IPS_ParticipantPortalEvent> getParticipantsReportEmployeeCompletedMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
            Id currentRecordId = recordId;
            String reportType = typeOfReport;
            Date reportDateTo = recordDateTo;
            Date reportDateFrom = recordDateFrom;

            List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();

            if(reportType =='Intervall'){
            
                wrapperListMeeting = getReportCompletedEmployeeMeetings(currentRecordId,reportDateFrom, reportDateTo); 
            }
            if(reportType =='End report'){
               
            }

            return wrapperListMeeting;
    }

    /* Get all open meetings and show it in report in experience cloud*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantsReportOpenMeetings(String recordId,String typeOfReport, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;

        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();

        if(reportType =='Intervall'){
        
            wrapperListMeeting = getReportOpenMeetings(currentRecordId, reportDateTo); 
        }

        return wrapperListMeeting;
    }

    /**
     * Returns a list of unique open meetings 
     * after intervall periode. 
     *
     * @return  List of event
     */
    private static List<IPS_ParticipantPortalEvent> getReportOpenMeetings(id currentRecordId, Date reportDateTo){
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        Date tempDate = reportDateTo.addMonths(3);
        List<Event> emplActivity = new List<Event>();
        emplActivity = [
            SELECT
                id,
                Subject,
                ActivityDate,
                IPS_Type__c
            FROM event
            WHERE
                IPS_Type__c IN (
                    'Meeting with Employer',
                    'Meeting with Participant',
                    'Start up meeting',
                    'First Meeting with Employer'
                )
                AND ActivityDate > :reportDateTo AND ActivityDate < :tempDate
                AND WhatId = :currentRecordId
                AND IPS_Status1__c ='Open'
            ORDER BY ActivityDate ASC
        ];

        for(event e:emplActivity){
            
            IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
            tempList.EventId = e.Id;
            tempList.Emne = e.Subject;
            tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(e.ActivityDate);
            tempList.Motetype = IPS_ParticipantPortalUtility.formatTypeOfMeeting(e.IPS_Type__c);
            wrapperTempList.add(tempList);
        }

        return wrapperTempList;
    }

    /**
     * Returns a list of unique completed employee meetings 
     * within the given intervall. 
     *
     * @return  List of event
     */
    private static List<IPS_ParticipantPortalEvent> getReportCompletedEmployeeMeetings(id currentRecordId,Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        list<Event> employeeActivity = new List<Event>();
        employeeActivity=[
            SELECT id,Subject,ActivityDate,RelatedToAccount__r.name,Konto_kontakt__r.Name,IPS_participant_related_to_meeting__c,toLabel(ips_Subcategory_Type_IPS__c),toLabel(IPS_Subcategory_Type_UO__c) 
            FROM event
            WHERE IPS_Type__c IN ('Meeting with Employer','First Meeting with Employer')
            AND IPS_Status1__c = 'Completed'
            AND WhatId = :currentRecordId
            AND ActivityDate >= :reportDateFrom
            AND ActivityDate <= :reportDateTo
            ORDER BY ActivityDate DESC];


        for(Event epart : employeeActivity) {
            IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
            tempList.EventId = epart.Id;
            tempList.Emne = epart.Subject;
            tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(epart.ActivityDate);
            tempList.Arbeidsgiver = epart.RelatedToAccount__r.name;
            tempList.ArbeidsgiverKontakt = epart.Konto_kontakt__r.Name;
            tempList.DeltakerDeltatt = IPS_ParticipantPortalUtility.formatParticipatedBoolean(epart.IPS_participant_related_to_meeting__c);
            if(epart.ips_Subcategory_Type_IPS__c != null){
                tempList.Underkategori = IPS_ParticipantPortalUtility.formatSubcategory(epart.ips_Subcategory_Type_IPS__c);
            }
            if(epart.IPS_Subcategory_Type_UO__c != null){
                tempList.Underkategori = IPS_ParticipantPortalUtility.formatSubcategory(epart.IPS_Subcategory_Type_UO__c);
            }
            wrapperTempList.add(tempList);
        }
        return wrapperTempList;
    }


   
    /**
     * Returns a list of unique completed participants meetings 
     * within the given intervall. If date is null - it will return all completed meetings.
     *
     * @return  List of event
     */
    private static List<IPS_ParticipantPortalEvent> getReportCompletedMeetings(id currentRecordId,Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        List<Event> participantActivity = new List<Event>();

        String partSelect = 'SELECT id,Subject,ActivityDate FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Completed\')';
        String partId = ' AND WhatId = :currentRecordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';

       query = partSelect + partWhere + partId + partFilter + partSort;
           
            participantActivity = Database.query(query);
            for(Event epart : participantActivity) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.EventId = epart.Id;
                tempList.Emne = epart.Subject;
                tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(epart.ActivityDate);
                wrapperTempList.add(tempList);
            }
            return wrapperTempList;
    }

    private static List<IPS_ParticipantPortalEvent> getReportCompletedMeetings(id currentRecordId) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
        tempList.AntallCompletedMeeting =(Integer) [SELECT count(id)Antall FROM Event WHERE IPS_Type__c in('Meeting with Participant','Start up meeting') AND IPS_Status1__c ='Completed' AND WhatId =:currentRecordId][0].get('Antall');
        wrapperTempList.add(tempList);

        return wrapperTempList;
    }

    /**
     * Returns a list of unique absent participants meetings 
     * within the given intervall 
     *
     * @return  List of event
     */
    private static List<IPS_ParticipantPortalEvent> getReportAbsentMeetings(id currentRecordId,Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        list<Event> participantActivity = new List<Event>();


        String partSelect = 'SELECT id,Subject,ActivityDate FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Participant Absent\')';
        String partId = ' AND WhatId = :currentRecordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';

            query = partSelect + partWhere + partId + partFilter + partSort;
            participantActivity = Database.query(query);
            for(Event epart : participantActivity) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.EventId = epart.Id;
                tempList.Emne = epart.Subject;
                tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(epart.ActivityDate);
                wrapperTempList.add(tempList);
            }
            return wrapperTempList;
    }

    private static List<IPS_ParticipantPortalEvent> getReportAbsentMeetings(id currentRecordId) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
        tempList.AntallAbsentMeeting =(Integer) [SELECT count(id)Antall FROM Event WHERE IPS_Type__c in('Meeting with Participant','Start up meeting') AND IPS_Status1__c ='Participant Absent' AND WhatId =:currentRecordId][0].get('Antall');
        wrapperTempList.add(tempList);

        return wrapperTempList;
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