public with sharing class IPS_viewReportPDFController {
    
    public Id currentRecordId {get; set;}
    public ips_report__c currentRecord {get; set;}
    public boolean isIPS {get; set;}
    public boolean isUO {get; set;}
    public boolean isEndReport {get; set;}
    public boolean isIntervallReport {get; set;}
    public String pdfTitle {get; set;}
    public Date intervallToDate {get; set;}
    public Date intervallFromDate {get; set;}

    public Work_Trail__c currentTrail {get; set;}
    public String startDatoText {get; set;}
    public String sluttDatoText {get; set;}
    public String startDatoTrail {get; set;}
    public String sluttDatoTrail {get; set;}
    public String sluttAarsak {get; set;}
    public String underAarsak {get; set;}
    public String workTrailId {get; set;}
    
    public list<Task> closedGoal {get; set;}
    public list<Task> openGoal {get; set;}
    
    public list<Event> completedEmplMeeting {get; set;}
    public list<Event> notAttendedEmplMeeting {get; set;}
    public Integer completedEmplMeetingNumber {get; set;}
    public Integer notAttendedEmplMeetingNumber {get; set;}
    
    public list<Event> completedPartMeeting {get; set;}
    public list<Event> notAttendedPartMeeting {get; set;}
    public Integer completedPartMeetingNumber {get; set;}
    public Integer notAttendedPartMeetingNumber {get; set;}
    public Set<String> accountNames {get; set;}
    
    public list<Event> openIntervallMeeting {get; set;}
    public list<Event> openIntervallPartMeeting {get; set;}
    
    public list<ips_Job__c> activeParticipantsJobs {get; set;}
    public list<ips_Education__c> activeParticipantsEducations {get; set;}
    
    
    public IPS_viewReportPDFController(ApexPages.StandardController sc){
        //this.currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        this.currentRecordId = sc.getRecord().Id;
        this.isEndReport = false;
        this.isIntervallReport = false;
        this.isIPS = false;
        this.isUO = false;
        
        this.currentRecord = getReport(this.currentRecordId);
        this.currentTrail = getWorkTrail(this.currentRecordId);

            this.closedGoal = getCompletedGoals();
            this.openGoal = getopenGoals();
            getEmployerActivity();
            getParticipantActivity();
            this.openIntervallMeeting = getOpenIntervallActivity(intervallToDate);
            this.activeParticipantsJobs = getActiveJobs();
            this.activeParticipantsEducations = getActiveEducations(); 
        
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+this.pdfTitle+'.pdf');
        
  }
	/*********************** current report *******************************/
    private ips_report__c getReport(string currRecordId){
        ips_report__c reportingParticipant =  [SELECT
                                                   IPS_subject__c,
                                                   IPS_endReport__c,
                                                   IPS_report_Type__c,
                                                   IPS_intervallReport__c,
                                                   IPS_intervallDateFrom__c,
                                                   IPS_intervallDateTo__c,
                                                   IPS_summarizeIntervallPeriode__c,
                                                   IPS_summarizeIntervallNextPeriode__c,
                                                   IPS_endReportSumm1__c,
                                                   IPS_endReportSumm2__c,
                                                   IPS_endReportSumm3__c,
                                                   IPS_endReportSumm4__c,
                                                   IPS_endReportSumm5__c,
                                               IPS_endReportSumm6__c,
                                               IPS_endReportSumm7__c
                                               FROM ips_report__c
                                               WHERE id = :currRecordId
                                              ];
        If(reportingParticipant.IPS_report_Type__c == 'Intervall'){
            this.isIntervallReport = true;
            this.startDatoText = formatDate(reportingParticipant.IPS_intervallDateFrom__c,null);
            this.intervallFromDate = reportingParticipant.IPS_intervallDateFrom__c;
        	this.sluttDatoText = formatDate(reportingParticipant.IPS_intervallDateTo__c,null);
            this.intervallToDate = reportingParticipant.IPS_intervallDateTo__c;
        }
        
        IF(reportingParticipant.IPS_report_Type__c == 'End report'){
            this.isEndReport = true;
        } 
        this.pdfTitle = reportingParticipant.IPS_subject__c;
        return reportingParticipant;
    }

    /************************** jobbspor **********************************/
    private Work_Trail__c getWorkTrail(String currRecordId){
        Work_Trail__c reportingTrail = [SELECT 
                                            Id, 
                                            recordType.DeveloperName,  
                                            IPS_ownerName__c, 
                                            ips_Participant__r.name, 
                                            ips_Behandlingsteam__c,
                                            ips_Applying_Department__c, 
                                            ips_NAV_supervisor__c,
                                        	Oppstartsdato__c,
                                        	ips_Referred_date__c,
                                            ips_Start_Date__c, 
                                            ips_End_Date__c, 
                                            toLabel(End_Cause__c), 
                                            toLabel(ips_Other_end_cases__c), 
                                            toLabel(ips_Work__c), 
                                            ips_Main_Goal_list__c,
                                        	ips_Priority_career_wishes__c,
                                        	ips_Desired_profession_industry_career__c,
                                            ips_UO_Service__c,  
                                            ips_Main_goal__c 
                                        FROM Work_Trail__c 
                                        WHERE id IN (SELECT IPS_workTrailName__c FROM  ips_report__c WHERE id =:currRecordId)
                                        ];
        IF(reportingTrail.recordType.DeveloperName =='IPS'){ 
            this.isIPS = true;
            
        }

        IF(reportingTrail.recordType.DeveloperName =='ips_Supported_Employment'){
            this.isUO = true;
        }

        IF(reportingTrail.End_Cause__c=='Work'){    
            this.underAarsak = reportingTrail.ips_Work__c;
        }

        IF(reportingTrail.End_Cause__c=='Other end causes'){
            this.underAarsak = reportingTrail.ips_Other_end_cases__c;
        }

        this.sluttAarsak = reportingTrail.End_Cause__c;
        this.workTrailId = reportingTrail.id;
        if(reportingTrail.Oppstartsdato__c!=null){
           this.startDatoTrail = formatDate(null,reportingTrail.Oppstartsdato__c); 
        }
        if(reportingTrail.ips_End_Date__c!=null){
          this.sluttDatoTrail = formatDate(reportingTrail.ips_End_Date__c,null);  
        }
        

        return reportingTrail;
    }
    
    /****************** Goals ********************************************/
    private list<Task> getCompletedGoals(){
        
        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Completed\' ';
        String goalId = ' AND WhatId = :workTrailId';
        String goalFilter = ' AND DAY_ONLY(CompletedDateTime) >= :intervallFromDate AND DAY_ONLY(CompletedDateTime) <= :intervallToDate';
        String goalSort = ' ORDER BY CompletedDateTime DESC';
        String query = '';
        
            if(isEndReport){
              query = goalSelect + goalWhere+goalId+goalSort;  
            }
            if(isIntervallReport){
              query = goalSelect + goalWhere + goalId + goalFilter + goalSort;
            }

            list<Task> userGoal = new list<Task>();
            userGoal = Database.query(query);
            return userGoal;
        }
    
    private list<Task> getopenGoals(){
        
        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Open\' ';
        String goalId = ' AND WhatId = :workTrailId';
        String goalFilter = ' AND ActivityDate > :intervallToDate';
        String goalSort = ' ORDER BY ActivityDate ASC';
        String query = goalSelect + goalWhere + goalId + goalFilter + goalSort;
        
        list<Task> userGoal = new list<Task>();
        userGoal = Database.query(query);
        return userGoal;
        }
    
    /********************** Meetings *********************************/
    private void getEmployerActivity(){
        
        String emplSelect = 'SELECT id,Subject,ActivityDate,RelatedToAccount__r.name,IPS_employerName__c,Konto_kontakt__r.Name,IPS_Type__c,toLabel(ips_Subcategory_Type_IPS__c),toLabel(IPS_Subcategory_Type_UO__c),IPS_Status1__c,IPS_participant_related_to_meeting__c FROM event';
        String emplWhere = ' WHERE IPS_Type__c IN (\'Meeting with Employer\',\'First Meeting with Employer\')';
        String emplId = ' AND WhatId = :workTrailId';
        String emplFilter = ' AND ActivityDate >= :intervallFromDate AND ActivityDate <= :intervallToDate';
        String emplSort = ' ORDER BY ActivityDate DESC';
        String query = emplSelect + emplWhere + emplId + emplFilter + emplSort;
        
        List<Event> tempCompletedEmplMeeting = new List<Event>();
        Integer tempCompletedNumber=0;
        List<Event> tempNotAttended = new List<Event>();
        Integer tempNotAttendedNumber=0;
        Set<String> tempAccountName = new Set<String>();
        
        list<Event> userEvent = new list<Event>();
        userEvent = Database.query(query);

        for(Event e:userEvent){
            if(e.IPS_Status1__c == 'Completed'){
                if(isEndReport && e.IPS_participant_related_to_meeting__c==true){
                    tempCompletedNumber++;
					tempAccountName.add(e.RelatedToAccount__r.name);
                }
                if(isIntervallReport){tempCompletedEmplMeeting.add(e);}     
            }
            
            if(e.IPS_Status1__c == 'Participant Absent'){
                if(isEndReport && e.IPS_participant_related_to_meeting__c==true){tempNotAttendedNumber++;}
                if(isIntervallReport){tempNotAttended.add(e);}
            }
        }
        this.accountNames = tempAccountName;
        this.completedEmplMeeting = tempCompletedEmplMeeting;
        this.completedEmplMeetingNumber = tempCompletedNumber;
        this.notAttendedEmplMeeting = tempNotAttended;
        this.notAttendedEmplMeetingNumber = tempNotAttendedNumber;
    }
    
    private list<Event> getOpenIntervallActivity(Date sluttDato){
        List<Event> emplActivity = new List<Event>();
        emplActivity =[
            SELECT 
                id,
                Subject,
                CreatedDate,
                IPS_subjectAndDate__c, 
                ActivityDate,
                Description,
                IPS_employerName__c,
            	Konto_kontakt__r.Name,
                toLabel(IPS_Type__c),
                IPS_Status1__c 
            FROM event 
            WHERE 
                IPS_participant_related_to_meeting__c = true
                AND IPS_Type__c IN ('Meeting with Employer','Meeting with Participant')
            	AND ActivityDate > :sluttDato 
                AND WhatId = :workTrailId 
                AND IPS_Status1__c IN ('Open')
            ORDER BY ActivityDate ASC
        ];
        
		return emplActivity;
    }
    
    private void getParticipantActivity(){
        
        String partSelect = 'SELECT id,Subject,CreatedDate,IPS_subjectAndDate__c, ActivityDate,Description,IPS_Type__c,IPS_Status1__c FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Completed\',\'Participant Absent\')';
        String partId = ' AND WhatId = :workTrailId';
        String partFilter = ' AND ActivityDate >= :intervallFromDate AND ActivityDate <= :intervallToDate';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';
        
        List<Event> tempCompleted = new List<Event>();
        Integer tempCompletedNumber=0;
        List<Event> tempNotAttended = new List<Event>();
        Integer tempNotAttendedNumber=0;
        list<Event> partActivity = new list<Event>();
        
        if(isEndReport){
              query = partSelect + partWhere + partId + partSort;  
        }
        if(isIntervallReport){
            query = partSelect + partWhere + partId + partFilter + partSort;
        }

        partActivity = Database.query(query);

        for(Event epart:partActivity){
            if(epart.IPS_Status1__c == 'Completed'){
                if(isEndReport){tempCompletedNumber++;}
                if(isIntervallReport){tempCompleted.add(epart);}   
            }
            if(epart.IPS_Status1__c == 'Participant Absent'){
                if(isEndReport){tempNotAttendedNumber++;}
                if(isIntervallReport){tempNotAttended.add(epart);}   
            }
        }
        this.completedPartMeeting = tempCompleted;
        this.completedPartMeetingNumber = tempCompletedNumber;
        this.notAttendedPartMeeting = tempNotAttended;
        this.notAttendedPartMeetingNumber = tempNotAttendedNumber;
    }
    
    /****************** jobb **************************/
    private list<ips_Job__c> getActiveJobs(){
        List<ips_Job__c> activeJobs = new List<ips_Job__c >();
        activeJobs =[
            SELECT 
            id,
            Name,
            ips_Work_Trail__c,
            ips_Employer__r.Name,
            toLabel(ips_Form_of_Employment__c),
            ips_Start_Date__c,
            IPS_UO_Stillingsbeskrivelse__c,
            ips_Job_Support__c,
            ips_End_Date__c,
            ips_Status__c,
            ips_Job__c.ips_What_did_not_work_at_the_workplace__c,
            ips_What_did_work_at_the_workplace__c,
            IPS_jobSubject__c
            FROM ips_Job__c
            WHERE ips_Work_Trail__c = :workTrailId 
        ];
        return activeJobs;
    }
    
    /****************** Utdanning *************************/
     
    private list<ips_Education__c> getActiveEducations(){
        List<ips_Education__c> activeEdu = new List<ips_Education__c >();
        activeEdu =[
            SELECT 
            id,
            Name,
            ips_Work_Trail__c,
            ips_Name_of_the_Education_Institution__c,
            toLabel(ips_Form_of_Education__c),
            ips_Start_Date__c,
            ips_End_Date__c,
            ips_What_did_not_work_with_thiseducation__c,
            ips_What_did_work_with_this_education__c,
            ips_Education_Support_Plan__c,
            ips_Status__c
            FROM ips_Education__c
            WHERE ips_Work_Trail__c = :workTrailId
            AND ips_Status__c ='Ongoing'   
        ];
        return activeEdu;
    }
    
    
    
    /*********************** **************************/    
    public static String formatDate(Date d,DateTime dt) {
 	String returnedDate;
        if(d==null){
            returnedDate = dt.day()+ '.' +dt.month()+ '.' + dt.year();
        }
        if(dt==null){
            returnedDate =   d.day()+ '.' +d.month()+ '.' + d.year();
        }
           
        return returnedDate;

	}
}