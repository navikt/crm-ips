public with sharing class IPS_viewReportPDFController {
    public Id currentRecordId { get; set; }
    public ips_report__c currentRecord { get; set; }
    public boolean isIPS { get; set; }
    public boolean isUO { get; set; }
    public boolean isEndReport { get; set; }
    public boolean isIntervallReport { get; set; }
    public String pdfTitle { get; set; }
    public Date intervallToDate { get; set; }
    public Date intervallFromDate { get; set; }
    public boolean participantComment { get; set; }

    public Work_Trail__c currentTrail { get; set; }
    public String startDatoText { get; set; }
    public String sluttDatoText { get; set; }
    public String startDatoTrail { get; set; }
    public String sluttDatoTrail { get; set; }
    public String sluttAarsak { get; set; }
    public String underAarsak { get; set; }
    public String workTrailId { get; set; }
    public String ownerName { get; set; }

    public list<Task> closedGoal { get; set; }
    public list<Task> openGoal { get; set; }

    public list<Event> completedEmplMeeting { get; set; }
    public list<Event> notAttendedEmplMeeting { get; set; }
    public Integer completedEmplMeetingNumber { get; set; }
    public Integer notAttendedEmplMeetingNumber { get; set; }

    public list<Event> completedPartMeeting { get; set; }
    public list<Event> notAttendedPartMeeting { get; set; }
    public Integer completedPartMeetingNumber { get; set; }
    public Integer notAttendedPartMeetingNumber { get; set; }
    public Set<String> accountNames { get; set; }

    public list<Event> openIntervallMeeting { get; set; }
    public list<Event> openIntervallPartMeeting { get; set; }

    public list<ips_Job__c> activeParticipantsJobs { get; set; }
    public list<ips_Education__c> activeParticipantsEducations { get; set; }
    public list<ips_Education__c> plannedParticipantsEducations { get; set; }
    public list<AMS_Vocational_education_and_training__c> activeAmsEducations { get; set; }
    public list<AMS_Vocational_education_and_training__c> plannedAmsEductions { get; set; }
    public list<IPS_PassivePeriod> getAllPassivePeriods { get; set; }
    public List<IPS_PassivePeriod> getPassivePeriodsWithinDateRange { get; set; }

    public IPS_viewReportPDFController(ApexPages.StandardController sc) {
        this.currentRecordId = sc.getRecord().Id;
        this.isEndReport = false;
        this.isIntervallReport = false;
        this.isIPS = false;
        this.isUO = false;
        this.participantComment = false;

        this.currentRecord = getReport(this.currentRecordId);
        this.currentTrail = getWorkTrail(this.currentRecordId);

        this.closedGoal = getCompletedGoals();
        this.openGoal = getopenGoals();
        getEmployerActivity();
        getParticipantActivity();
        this.openIntervallMeeting = getOpenIntervallActivity(intervallToDate);
        this.activeParticipantsJobs = getActiveJobs(intervallFromDate, intervallToDate);
        this.activeParticipantsEducations = getActiveEducations(intervallFromDate, intervallToDate);
        this.plannedParticipantsEducations = getPlannedEducations(intervallFromDate);
        this.activeAmsEducations = getAMSEducation(intervallFromDate, intervallToDate);
        this.plannedAmsEductions = getPlannedAMSEducations(intervallFromDate);
        this.getAllPassivePeriods = getAllPassivePeriods();
        this.getPassivePeriodsWithinDateRange = getPassivePeriodsWithinDateRange(intervallFromDate, intervallToDate);

        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + this.pdfTitle + '.pdf');
    }
    /*********************** current report *******************************/
    private ips_report__c getReport(string currRecordId) {
        ips_report__c reportingParticipant = [
            SELECT
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
                IPS_endReportSumm7__c,
                IPS_participantsComment__c,
                IPS_participantsOnBehalf__c,
                IPS_workTrailOwner__c
            FROM ips_report__c
            WHERE id = :currRecordId
        ];
        if (reportingParticipant.IPS_report_Type__c == 'Intervall') {
            this.isIntervallReport = true;
            this.startDatoText = formatDate(reportingParticipant.IPS_intervallDateFrom__c, null);
            this.intervallFromDate = reportingParticipant.IPS_intervallDateFrom__c;
            this.sluttDatoText = formatDate(reportingParticipant.IPS_intervallDateTo__c, null);
            this.intervallToDate = reportingParticipant.IPS_intervallDateTo__c;
        }

        if (reportingParticipant.IPS_report_Type__c == 'End report') {
            this.isEndReport = true;
            if (
                reportingParticipant.IPS_participantsComment__c != null ||
                reportingParticipant.IPS_participantsComment__c != ''
            ) {
                this.participantComment = true;
            }
        }
        this.pdfTitle = reportingParticipant.IPS_subject__c;
        this.ownerName = reportingParticipant.IPS_workTrailOwner__c;
        return reportingParticipant;
    }

    /************************** jobbspor **********************************/
    private Work_Trail__c getWorkTrail(String currRecordId) {
        Work_Trail__c reportingTrail = [
            SELECT
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
                End_Cause__c,
                toLabel(ips_Other_end_cases__c),
                toLabel(ips_Work__c),
                toLabel(ips_Main_Goal_list__c),
                ips_Priority_career_wishes__c,
                ips_Desired_profession_industry_career__c,
                ips_UO_Service__c,
                ips_Main_goal__c
            FROM Work_Trail__c
            WHERE id IN (SELECT IPS_workTrailName__c FROM ips_report__c WHERE id = :currRecordId)
        ];
        if (reportingTrail.recordType.DeveloperName == 'IPS') {
            this.isIPS = true;
        }

        if (reportingTrail.recordType.DeveloperName == 'ips_Supported_Employment') {
            this.isUO = true;
        }

        this.sluttAarsak = reportingTrail.End_Cause__c;
        this.underAarsak = reportingTrail.ips_Other_end_cases__c;
        this.workTrailId = reportingTrail.id;
        if (reportingTrail.Oppstartsdato__c != null) {
            this.startDatoTrail = formatDate(null, reportingTrail.Oppstartsdato__c);
        }
        if (reportingTrail.ips_End_Date__c != null) {
            this.sluttDatoTrail = formatDate(reportingTrail.ips_End_Date__c, null);
        }

        return reportingTrail;
    }

    /****************** Goals ********************************************/

    /**
     * Returns a list of unique goals that are completed either
     * within the given intervall or the whole period of the worktrail.
     *
     * @return  List of task
     */
    private List<Task> getCompletedGoals() {
        List<Task> userGoal = new List<Task>();
        List<Task> tempIntervalGoals = new List<Task>();
        List<Task> tempIntervalDueDateGoals = new List<Task>();
        List<Task> tempIntervalCompletedGoals = new List<Task>();
        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Completed\' ';
        String goalId = ' AND WhatId = :workTrailId';
        String goalDueDateFilter = ' AND ActivityDate >= :intervallFromDate AND ActivityDate <= :intervallToDate';
        String goalCompletedDateFilter = ' AND DAY_ONLY(CompletedDateTime) >= :intervallFromDate AND DAY_ONLY(CompletedDateTime) <= :intervallToDate';
        String goalSort = ' ORDER BY ActivityDate DESC';
        String endQuery = '';
        String dueDateQuery = '';
        String completedDateQuery = '';

        if (isEndReport) {
            endQuery = goalSelect + goalWhere + goalId + goalSort;
            userGoal = Database.query(endQuery);
        }

        /* Getting goals that are completed within the intervall and
         has a due date within the intervall with status completed */
        if (isIntervallReport) {
            dueDateQuery = goalSelect + goalWhere + goalId + goalDueDateFilter + goalSort;
            completedDateQuery = goalSelect + goalWhere + goalId + goalCompletedDateFilter + goalSort;
            tempIntervalDueDateGoals = Database.query(dueDateQuery);
            tempIntervalCompletedGoals = Database.query(completedDateQuery);
            tempIntervalGoals.addAll(tempIntervalDueDateGoals);
            userGoal = tempIntervalGoals;
        }
        // Adding unique completed goals to the list of goals queried by due date
        for (Task task : tempIntervalCompletedGoals) {
            if (!userGoal.contains(task)) {
                userGoal.add(task);
            }
        }
        for (Task task : tempIntervalCompletedGoals) {
            if (!userGoal.contains(task)) {
                userGoal.add(task);
            }
        }
        return userGoal;
    }

    private list<Task> getopenGoals() {
        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Open\' ';
        String goalId = ' AND WhatId = :workTrailId';
        String goalFilter = ' AND ActivityDate > :intervallToDate';
        String goalSort = ' ORDER BY ActivityDate ASC';
        String query = goalSelect + goalWhere + goalId + goalFilter + goalSort;

        list<Task> userGoal = new List<Task>();
        userGoal = Database.query(query);
        return userGoal;
    }

    /********************** Meetings *********************************/
    private void getEmployerActivity() {
        String emplSelect = 'SELECT id,Subject,ActivityDate,RelatedToAccount__r.name,IPS_employerName__c,Konto_kontakt__r.Name,IPS_Type__c,ips_Subcategory_Type_IPS__c,IPS_Subcategory_Type_UO__c,IPS_Status1__c,IPS_participant_related_to_meeting__c FROM event';
        String emplWhere = ' WHERE IPS_Type__c IN (\'Meeting with Employer\',\'First Meeting with Employer\')';
        String emplId = ' AND WhatId = :workTrailId';
        String emplFilter = ' AND ActivityDate >= :intervallFromDate AND ActivityDate <= :intervallToDate';
        String emplSort = ' ORDER BY ActivityDate DESC';
        String query = emplSelect + emplWhere + emplId + emplFilter + emplSort;

        List<Event> tempCompletedEmplMeeting = new List<Event>();
        Integer tempCompletedNumber = 0;
        List<Event> tempNotAttended = new List<Event>();
        Integer tempNotAttendedNumber = 0;
        Set<String> tempAccountName = new Set<String>();

        list<Event> userEvent = new List<Event>();
        userEvent = Database.query(query);

        for (Event e : userEvent) {
            if (e.IPS_Status1__c == 'Completed') {
                if (isEndReport && e.IPS_participant_related_to_meeting__c == true) {
                    tempCompletedNumber++;
                }
                if (isIntervallReport) {
                    tempCompletedEmplMeeting.add(e);
                }
            }
            if (
                (e.ips_Subcategory_Type_IPS__c == 'Job development' ||
                e.ips_Subcategory_Type_IPS__c == 'Job support' ||
                e.IPS_Subcategory_Type_UO__c == 'Relationship building') && e.IPS_Status1__c != 'Cancelled'
            ) {
                tempAccountName.add(e.RelatedToAccount__r.name);
            }

            if (e.IPS_Status1__c == 'Participant Absent') {
                if (isEndReport && e.IPS_participant_related_to_meeting__c == true) {
                    tempNotAttendedNumber++;
                }
                if (isIntervallReport) {
                    tempNotAttended.add(e);
                }
            }
        }
        this.accountNames = tempAccountName;
        this.completedEmplMeeting = tempCompletedEmplMeeting;
        this.completedEmplMeetingNumber = tempCompletedNumber;
        this.notAttendedEmplMeeting = tempNotAttended;
        this.notAttendedEmplMeetingNumber = tempNotAttendedNumber;
    }

    private list<Event> getOpenIntervallActivity(Date sluttDato) {
        List<Event> emplActivity = new List<Event>();
        emplActivity = [
            SELECT
                id,
                Subject,
                CreatedDate,
                IPS_subjectAndDate__c,
                ActivityDate,
                Description,
                IPS_employerName__c,
                Konto_kontakt__r.Name,
                IPS_Type__c,
                IPS_Status1__c
            FROM event
            WHERE
                IPS_Type__c IN (
                    'Meeting with Employer',
                    'Meeting with Participant',
                    'Start up meeting',
                    'First Meeting with Employer'
                )
                AND ActivityDate > :sluttDato
                AND WhatId = :workTrailId
                AND IPS_Status1__c IN ('Open')
            ORDER BY ActivityDate ASC
        ];

        return emplActivity;
    }

    private void getParticipantActivity() {
        String partSelect = 'SELECT id,Subject,CreatedDate,IPS_subjectAndDate__c, ActivityDate,Description,IPS_Type__c,IPS_Status1__c FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Completed\',\'Participant Absent\')';
        String partId = ' AND WhatId = :workTrailId';
        String partFilter = ' AND ActivityDate >= :intervallFromDate AND ActivityDate <= :intervallToDate';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';

        List<Event> tempCompleted = new List<Event>();
        Integer tempCompletedNumber = 0;
        List<Event> tempNotAttended = new List<Event>();
        Integer tempNotAttendedNumber = 0;
        list<Event> partActivity = new List<Event>();

        if (isEndReport) {
            query = partSelect + partWhere + partId + partSort;
        }
        if (isIntervallReport) {
            query = partSelect + partWhere + partId + partFilter + partSort;
        }

        partActivity = Database.query(query);

        for (Event epart : partActivity) {
            if (epart.IPS_Status1__c == 'Completed') {
                if (isEndReport) {
                    tempCompletedNumber++;
                }
                if (isIntervallReport) {
                    tempCompleted.add(epart);
                }
            }
            if (epart.IPS_Status1__c == 'Participant Absent') {
                if (isEndReport) {
                    tempNotAttendedNumber++;
                }
                if (isIntervallReport) {
                    tempNotAttended.add(epart);
                }
            }
        }
        this.completedPartMeeting = tempCompleted;
        this.completedPartMeetingNumber = tempCompletedNumber;
        this.notAttendedPartMeeting = tempNotAttended;
        this.notAttendedPartMeetingNumber = tempNotAttendedNumber;
    }

    /****************** jobb **************************/
    private list<ips_Job__c> getActiveJobs(Date startDate, Date endDate) {
        List<ips_Job__c> jobList = new List<ips_Job__c>();

        List<ips_Job__c> activeJobs = new List<ips_Job__c>();
        activeJobs = [
            SELECT
                id,
                Name,
                ips_Work_Trail__c,
                ips_Employer__r.Name,
                ips_Form_of_Employment__c,
                ips_Start_Date__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_Job_Support__c,
                ips_End_Date__c,
                toLabel(ips_Status__c),
                ips_Job__c.ips_What_did_not_work_at_the_workplace__c,
                ips_What_did_work_at_the_workplace__c,
                IPS_jobSubject__c
            FROM ips_Job__c
            WHERE ips_Work_Trail__c = :workTrailId AND ips_Status__c = 'Ongoing'
            ORDER BY ips_Start_Date__c DESC
        ];

        List<ips_Job__c> closedJobs = new List<ips_Job__c>();
        closedJobs = [
            SELECT
                id,
                Name,
                ips_Work_Trail__c,
                ips_Employer__r.Name,
                ips_Form_of_Employment__c,
                ips_Start_Date__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_Job_Support__c,
                ips_End_Date__c,
                toLabel(ips_Status__c),
                ips_Job__c.ips_What_did_not_work_at_the_workplace__c,
                ips_What_did_work_at_the_workplace__c,
                IPS_jobSubject__c
            FROM ips_Job__c
            WHERE
                ips_Work_Trail__c = :workTrailId
                AND ips_Status__c = 'Completed'
                AND (ips_End_Date__c >= :startDate
                OR ips_End_Date__c >= :endDate)
            ORDER BY ips_End_Date__c DESC
        ];

        if (!activeJobs.isEmpty()) {
            jobList.addAll(activeJobs);
        }
        if (!closedJobs.isEmpty()) {
            jobList.addAll(closedJobs);
        }
        return jobList;
    }

    /****************** Utdanning IPS *************************/

    private list<ips_Education__c> getPlannedEducations(Date endDate) {
        List<ips_Education__c> eduList = new List<ips_Education__c>();

        List<ips_Education__c> plannedEdu = new List<ips_Education__c>();
        plannedEdu = [
            SELECT
                id,
                Name,
                ips_Work_Trail__c,
                ips_Name_of_the_Education_Institution__c,
                ips_Form_of_Education__c,
                ips_Start_Date__c,
                ips_End_Date__c,
                ips_What_did_not_work_with_thiseducation__c,
                ips_What_did_work_with_this_education__c,
                ips_Education_Support_Plan__c,
                toLabel(ips_Status__c)
            FROM ips_Education__c
            WHERE ips_Work_Trail__c = :workTrailId AND ips_Status__c = 'Planned' AND ips_Start_Date__c > :endDate
        ];

        if (!plannedEdu.isEmpty()) {
            eduList.addAll(plannedEdu);
        }
        return eduList;
    }

    private list<ips_Education__c> getActiveEducations(Date startDate, Date endDate) {
        List<ips_Education__c> eduList = new List<ips_Education__c>();
        List<ips_Education__c> allEdu = new List<ips_Education__c>();

        allEdu = [
            SELECT
                id,
                Name,
                ips_Work_Trail__c,
                ips_Name_of_the_Education_Institution__c,
                ips_Form_of_Education__c,
                ips_Start_Date__c,
                ips_End_Date__c,
                ips_What_did_not_work_with_thiseducation__c,
                ips_What_did_work_with_this_education__c,
                ips_Education_Support_Plan__c,
                toLabel(ips_Status__c)
            FROM ips_Education__c
            WHERE ips_Work_Trail__c = :workTrailId AND ips_Status__c IN ('Ongoing', 'Completed', 'Canceled')
            ORDER BY ips_Start_Date__c DESC
        ];

        if (this.isEndReport == true) {
            eduList.addAll(allEdu);
        }
        if (this.isIntervallReport == true) {
            for (ips_Education__c i : allEdu) {
                if (i.ips_Status__c == 'Ongoing') {
                    eduList.add(i);
                } else {
                    if (i.ips_End_Date__c != null && (i.ips_End_Date__c >= startDate || i.ips_End_Date__c >= endDate)) {
                        eduList.add(i);
                    }
                    if (
                        i.ips_End_Date__c == null &&
                        i.ips_Start_Date__c >= startDate &&
                        i.ips_Start_Date__c <= endDate
                    ) {
                        eduList.add(i);
                    }
                }
            }
        }
        return eduList;
    }

    /****************** Utdanning AMS *************************/

    private List<AMS_Vocational_education_and_training__c> getAMSEducation(Date startDate, Date endDate) {
        List<AMS_Vocational_education_and_training__c> amsEduList = new List<AMS_Vocational_education_and_training__c>();
        List<AMS_Vocational_education_and_training__c> allAmsEdu = new List<AMS_Vocational_education_and_training__c>();
        List<AMS_Vocational_education_and_training__c> closedAmsEdu = new List<AMS_Vocational_education_and_training__c>();

        allAmsEdu = [
            SELECT
                Id,
                Name,
                CreatedDate,
                AMS_Work_Trail__c,
                AMS_Description__c,
                AMS_Education_Support_Plan__c,
                AMS_Education_title__c,
                AMS_Educational_program__c,
                AMS_End_Date__c,
                AMS_Form_of_Study__c,
                AMS_Name_of_the_Education_institution__c,
                AMS_Start_Date__c,
                toLabel(AMS_Status__c)
            FROM AMS_Vocational_education_and_training__c
            WHERE AMS_Work_Trail__c = :workTrailId AND AMS_Status__c IN ('Ongoing', 'Completed', 'Canceled')
            ORDER BY AMS_Start_Date__c DESC
        ];

        if (this.isEndReport == true) {
            amsEduList.addAll(allAmsEdu);
        }
        if (isIntervallReport == true) {
            for (AMS_Vocational_education_and_training__c a : allAmsEdu) {
                if (a.AMS_Status__c == 'Ongoing' || a.AMS_Status__c == 'Pågående') {
                    amsEduList.add(a);
                } else {
                    if (
                        a.AMS_End_Date__c != null &&
                        ((a.AMS_End_Date__c >= startDate || a.AMS_End_Date__c >= endDate) &&
                        (a.AMS_Status__c == 'Completed' ||
                        a.AMS_Status__c == 'Fullført'))
                    ) {
                        amsEduList.add(a);
                    }
                    if (
                        a.AMS_End_Date__c == null &&
                        ((a.AMS_Status__c == 'Completed' ||
                        a.AMS_Status__c == 'Fullført') &&
                        a.AMS_Start_Date__c >= startDate &&
                        a.AMS_Start_Date__c <= endDate)
                    ) {
                        amsEduList.add(a);
                    }
                }
            }
        }
        return amsEduList;
    }

    private list<AMS_Vocational_education_and_training__c> getPlannedAMSEducations(Date endDate) {
        List<AMS_Vocational_education_and_training__c> eduList = new List<AMS_Vocational_education_and_training__c>();

        List<AMS_Vocational_education_and_training__c> plannedEdu = new List<AMS_Vocational_education_and_training__c>();
        plannedEdu = [
            SELECT
                Id,
                Name,
                CreatedDate,
                AMS_Work_Trail__c,
                AMS_Description__c,
                AMS_Education_Support_Plan__c,
                AMS_Education_title__c,
                AMS_Educational_program__c,
                AMS_End_Date__c,
                AMS_Form_of_Study__c,
                AMS_Name_of_the_Education_institution__c,
                AMS_Start_Date__c,
                toLabel(AMS_Status__c)
            FROM AMS_Vocational_education_and_training__c
            WHERE AMS_Work_Trail__c = :workTrailId AND AMS_Status__c = 'Planned' AND AMS_Start_Date__c > :endDate
            ORDER BY AMS_Start_Date__c DESC
        ];

        if (!plannedEdu.isEmpty()) {
            eduList.addAll(plannedEdu);
        }
        return eduList;
    }

    /**
     * Returns all the passive periods related to a worktrail
     * @return  List of passive periods
     */
    private list<IPS_PassivePeriod> getAllPassivePeriods() {
        list<Task> allpassiveActivities = [
            SELECT id, subject, ActivityDate, CreatedDate, whatId
            FROM task
            WHERE
                WhatId = :workTrailId
                AND Type_of_Task_IPSUO__c = 'Historikk'
                AND (subject = 'Passiv tilstand aktivert'
                OR subject = 'Passiv tilstand deaktivert')
            ORDER BY CreatedDate
        ];
        list<IPS_PassivePeriod> passivePeriods = new List<IPS_PassivePeriod>();
        Task aktivertTask = null;

        for (Task task : allpassiveActivities) {
            if (task.Subject == 'Passiv tilstand aktivert') {
                aktivertTask = task;
            } else if (task.Subject == 'Passiv tilstand deaktivert' && aktivertTask != null) {
                passivePeriods.add(new IPS_PassivePeriod(aktivertTask.CreatedDate, task.CreatedDate));
                aktivertTask = null;
            }
        }
        system.debug('Passive periods');
        system.debug(passivePeriods);

        return passivePeriods;
    }

    /**
     * Returns passive periods within a given date range.
     * @param startDate starting date of the date range
     * @param endDate ending date of the date range
     * @return  List of filtered passive periods
     */
    private List<IPS_PassivePeriod> getPassivePeriodsWithinDateRange(Datetime startDate, Datetime endDate) {
        List<IPS_PassivePeriod> passivePeriods = getAllPassivePeriods();
        List<IPS_PassivePeriod> filteredPassivePeriods = new List<IPS_PassivePeriod>();

        for (IPS_PassivePeriod period : passivePeriods) {
            if (
                (period.startDate >= startDate && period.startDate <= (endDate + 1)) &&
                (period.endDate >= startDate &&
                period.endDate <= (endDate + 1))
            ) {
                filteredPassivePeriods.add(period);
            }
        }

        return filteredPassivePeriods;
    }

    /*********************** **************************/
    public static String formatDate(Date d, DateTime dt) {
        String returnedDate;
        if (d == null) {
            returnedDate = dt.day() + '.' + dt.month() + '.' + dt.year();
        }
        if (dt == null) {
            returnedDate = d.day() + '.' + d.month() + '.' + d.year();
        }

        return returnedDate;
    }
}
