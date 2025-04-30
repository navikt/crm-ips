/*
*********************************************************
Apex Class Name    : IPS_ParticipantPortalReportController
Created Date       : Januar 2025
@description       : Henter data fra alle objekter knyttet til ett jobbspor for å utarbeide en veilederrapport. 
                    Veilderrapport deles i 2 underveis- og sluttrapport. 
                    Hver av de inneholder kriterer for uttak av data.
@author            : AKO
Modification Log:
Ver   Date         Author                               Modification

*********************************************************
*/

public with sharing class IPS_ParticipantPortalReportController{
  public enum idType {TRAIL, REPORT}
 
    /*
    *********************************************************
    @Method Name    : getParticipantReport
    @author         : AKO
    @description    : Henter rapport fra ips_report__c objektet med kriterer Status = 'Shared report'. 
                        Dette indikerer at jobbspesialist har delt en veilederrapport for gjennomlesning i innlogginsløsningen.
    @param          : JobbsporId, 
    @param          : Kategori om rapport skal brukses i main side (TRAIL) eller i rapportdetaljer (REPORT)
    @return         : Liste over rapporter som er delt
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalReport> getParticipantReport(String recordId,String typeOfId){
    Id currentRecordId = recordId;
    String useType = typeOfId;
      
      List<IPS_ParticipantPortalReport> wrapperList = new List<IPS_ParticipantPortalReport>();
      if(idType.TRAIL.name() == useType){ 
          wrapperList = getReportWrapperList(currentRecordId);
      }
      if (idType.REPORT.name() == useType) {
          wrapperList = getReportDetailList(currentRecordId);  
      }
      return wrapperList; 
    }

   /*
    *********************************************************
    @Method Name    : getParticipantEducations
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra ips_Education__c  og AMS_Vocational_education_and_training__c  objektet 
                        Alle utdanninger som er pågående og fullført blir hentet for sluttrapport.
                        Utdanninger som er planlagt, påbegynt og fullført blir hentet for intervallrapport.
    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport), 
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over utdanninger knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEducation> getParticipantEducations(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;
        String reportType = typeOfReport; 

        List<ips_ParticipantPortalEducation> wrapperList = new List<ips_ParticipantPortalEducation>();
            wrapperList = getEducations(currentRecordId,reportDateFrom,reportDateTo);
            return wrapperList;
    }


    
   /*
    *********************************************************
    @Method Name    : getParticipantJobs
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra ips_Job__c objektet. Henter alle pågående og fullførte jobber for sluttrapport.
                        Henter alle pågående jobber og fullførte jobber som er innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over jobber knyttet til ett jobbspor
    ********************************************************
    */
 
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalJob> getParticipantJobs(String recordId,Date recordDateFrom, Date recordDateTo)
    {
        Id currentRecordId = recordId;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<ips_ParticipantPortalJob> wrapperList = new List<ips_ParticipantPortalJob>();

            wrapperList = getJobs(currentRecordId,reportDateFrom,reportDateTo);
            return wrapperList;
    }

    


   /*
    *********************************************************
    @Method Name    : getParticipantsReportCompletedGoals
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Task objektet. Henter kun type task som = Delmål.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId,
    @param          : Type rapport(intervall,sluttrapport),  
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over jobber knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalTask> getParticipantsReportCompletedGoals(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport; 
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<IPS_ParticipantPortalTask> wrapperList = new List<IPS_ParticipantPortalTask>();
        if(reportType == 'End report'){
            wrapperList = getReportCompletedGoals(currentRecordId); 

        }
        if(reportType == 'Intervall'){
            wrapperList = getReportCompletedGoals(currentRecordId,reportType,reportDateFrom,reportDateTo); 
        }

    
           

        return wrapperList;
    }

     /*
    *********************************************************
    @Method Name    : getParticipantsReportCompletedMeetings
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Event objektet. Henter deltakermøter som er fullført.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over jobber knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantsReportCompletedMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();

            wrapperListMeeting = getReportCompletedMeetings(currentRecordId,reportType,reportDateFrom, reportDateTo); 

        return wrapperListMeeting;
    }

 /*
    *********************************************************
    @Method Name    : getParticipantReportCancelledMeetings
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Event objektet. Henter deltakermøter som er kanselert.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantReportCancelledMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;
        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();
        
        wrapperListMeeting = getReportCanceledMeetings(currentRecordId,reportType,reportDateFrom, reportDateTo);
        return wrapperListMeeting;

    }

/*
    *********************************************************
    @Method Name    : getParticipantsReportAbsentMeetings
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Event objektet. Henter deltakermøter som ikke har deltatt på møtet.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantsReportAbsentMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();

            wrapperListMeeting = getReportAbsentMeetings(currentRecordId, reportType, reportDateFrom, reportDateTo);

        return wrapperListMeeting;
    }

/*
    *********************************************************
    @Method Name    : getParticipantsReportEmployeeCompletedMeetings
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Event objektet. Henter deltakermøter som er fullført.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalEvent> getParticipantsReportEmployeeCompletedMeetings(String recordId,String typeOfReport,Date recordDateFrom, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;
        Date reportDateFrom = recordDateFrom;

        List<IPS_ParticipantPortalEvent> wrapperListMeeting = new List<IPS_ParticipantPortalEvent>();
        
            wrapperListMeeting = getReportCompletedEmployeeMeetings(currentRecordId,reportType, reportDateFrom, reportDateTo); 

        return wrapperListMeeting;
}

 /*
    *********************************************************
    @Method Name    : getParticipantsReportOpenMeetings
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Event objektet. Henter deltakermøter som er åpne.
                        Henter møter som er planlagte max 3 mnd fremover.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
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

/*
    *********************************************************
    @Method Name    : getParticipantsReportOpenGoals
    @author         : AKO
    @description    : AuraEnabled som er synlig for uthenting av data fra LWC komponent.
                        Henter data fra Task objektet. Henter delmål som er åpne.
                        Henter Delmål som er planlagte max 3 mnd fremover.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ParticipantPortalTask> getParticipantsReportOpenGoals(String recordId,String typeOfReport, Date recordDateTo){
        Id currentRecordId = recordId;
        String reportType = typeOfReport;
        Date reportDateTo = recordDateTo;

        List<IPS_ParticipantPortalTask> wrapperListGoals = new List<IPS_ParticipantPortalTask>();

        if(reportType =='Intervall'){
        
            wrapperListGoals = getReportOpenGoals(currentRecordId, reportDateTo); 
        }

        return wrapperListGoals;
    }


/*
    *********************************************************
    @Method Name    : getReportOpenGoals
    @author         : AKO
    @description    : 
                        Henter data fra Task objektet. Henter delmål som er åpne.
                        Henter Delmål som er planlagte max 3 mnd fremover.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalTask> getReportOpenGoals(id recordId, Date reportDateTo){
        List<IPS_ParticipantPortalTask> wrapperTempList = new List<IPS_ParticipantPortalTask>();
        Date tempDate = reportDateTo.addMonths(3);

        List<Task> tempGoalList = new List<Task>();
        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Open\' ';
        String goalId = ' AND WhatId = :recordId';
        String goalFilter = ' AND ActivityDate > :reportDateTo  AND ActivityDate < :tempDate';
        String goalSort = ' ORDER BY ActivityDate ASC';
        String query = goalSelect + goalWhere + goalId + goalFilter + goalSort;
        tempGoalList = Database.query(query);

            for(Task t:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = t.Subject;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(t.ActivityDate);
                tempList.OpprettelsesDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(t.CreatedDate));
                tempList.ReferatKommentar = t.Description;
                tempList.OppgaveId = t.id;
                wrapperTempList.add(tempList);
            }

        return wrapperTempList;
    }


     /*
    *********************************************************
    @Method Name    : getReportOpenMeetings
    @author         : AKO
    @description    : 
                        Henter data fra Event objektet. Henter møter som er åpne.
                        Henter møter som er planlagte max 3 mnd fremover.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalEvent> getReportOpenMeetings(id recordId, Date reportDateTo){
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
                AND WhatId = :recordId
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

  /*
    *********************************************************
    @Method Name    : getReportCompletedEmployeeMeetings
    @author         : AKO
    @description    : Henter data fra Event objektet. Henter møter med arbeidsgiver og deltaker som er fullført.

    @param          : JobbsporId,
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over Møter knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalEvent> getReportCompletedEmployeeMeetings(id recordId,String reportType, Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        list<Event> employeeActivity = new List<Event>();

        String partSelect = 'SELECT id,Subject,ActivityDate,RelatedToAccount__r.name,Konto_kontakt__r.Name,IPS_participant_related_to_meeting__c,ips_Subcategory_Type_IPS__c,IPS_Subcategory_Type_UO__c FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Employer\',\'First Meeting with Employer\') AND IPS_Status1__c IN (\'Completed\')';
        String partId = ' AND WhatId = :recordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';

        if(reportType == 'End report'){
            query = partSelect + partWhere + partId;
        }
        if(reportType == 'Intervall'){
            query = partSelect + partWhere + partId + partFilter + partSort;
            for(Event epart : Database.query(query)) {
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
        }
        return wrapperTempList;
    }


   
     /*
    *********************************************************
    @Method Name    : getReportCompletedMeetings
    @author         : AKO
    @description    : Henter data fra Event objektet. Henter deltakermøter som er fullført.
                        Henter deltakermøter og oppstartsmøter som er fullførte innenfor intervall for intervallrapport.

    @param          : JobbsporId,
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over Møter knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalEvent> getReportCompletedMeetings(id recordId,String reportType, Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        

        String partSelect = 'SELECT id,Subject,ActivityDate FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Completed\')';
        String partId = ' AND WhatId = :recordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';
        if(reportType == 'End report'){
            query = partSelect + partWhere + partId;
            Integer numbersOfMeeting = 1;
            
            for(Event epart : Database.query(query)) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.EventId = epart.Id;
                tempList.AntallCompletedMeeting = numbersOfMeeting++;
                wrapperTempList.add(tempList);
            }
            
        }
        if(reportType == 'Intervall'){

            query = partSelect + partWhere + partId + partFilter + partSort;
            for(Event epart : Database.query(query)) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.EventId = epart.Id;
                tempList.Emne = epart.Subject;
                tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(epart.ActivityDate);
                wrapperTempList.add(tempList);
            }
        }
        return wrapperTempList;
    }


 /*
    *********************************************************
    @Method Name    : getReportCanceledMeetings
    @author         : AKO
    @description    : 
                        Henter data fra Event objektet. Henter deltakermøter som er kanselert.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalEvent> getReportCanceledMeetings(id recordId,String reportType, Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();

        String partSelect = 'SELECT id FROM Event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Cancelled\')';
        String partId = ' AND WhatId = :recordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';
        if(reportType == 'End report'){
            query = partSelect + partWhere + partId;
        }
        if(reportType == 'Intervall'){
            query = partSelect + partWhere + partId + partFilter + partSort;
        }

       Integer numbersOfMeeting = 1;
        for(Event epart : Database.query(query)) {
            tempList.AntallCancelledMeeting = numbersOfMeeting++;
        }
        wrapperTempList.add(tempList);
        return wrapperTempList;
    }

     /*
    *********************************************************
    @Method Name    : getReportAbsentMeetings
    @author         : AKO
    @description    : 
                        Henter data fra Event objektet. Henter deltakermøter hvor deltaker ikke har deltatt.
                        Henter for sluttrapport.
                        Henter innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport)
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over møter knyttet til ett jobbspor
    ********************************************************
    */

    /**
     * Returns a list of unique absent participants meetings 
     * within the given intervall 
     *
     * @return  List of event
     */
    private static List<IPS_ParticipantPortalEvent> getReportAbsentMeetings(id recordId,String reportType,Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalEvent> wrapperTempList = new List<IPS_ParticipantPortalEvent>();
        
        String partSelect = 'SELECT id,Subject,ActivityDate FROM event';
        String partWhere = ' WHERE IPS_Type__c IN (\'Meeting with Participant\',\'Start up meeting\') AND IPS_Status1__c IN (\'Participant Absent\')';
        String partId = ' AND WhatId = :recordId';
        String partFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String partSort = ' ORDER BY ActivityDate DESC';
        String query = '';

        if(reportType == 'End report'){
            query = partSelect + partWhere + partId;
            Integer numbersOfMeeting = 1;
            for(Event epart : Database.query(query)) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.AntallCancelledMeeting = numbersOfMeeting++;
                wrapperTempList.add(tempList);
            }
            

        }
        if(reportType == 'Intervall'){
            query = partSelect + partWhere + partId + partFilter + partSort;
            for(Event epart : Database.query(query)) {
                IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
                tempList.EventId = epart.Id;
                tempList.Emne = epart.Subject;
                tempList.Motedato = IPS_ParticipantPortalUtility.formatDate(epart.ActivityDate);
                wrapperTempList.add(tempList);
            }
        }

    return wrapperTempList;
    }

     /**
     * Returns a list of unique goals that are completed either
     * within the given intervall or the whole period of the worktrail.
     *
     * @return  List of task
     */
    private static List<IPS_ParticipantPortalTask> getReportCompletedGoals(id recordId,String reportType,Date reportDateFrom,Date reportDateTo) {
        List<IPS_ParticipantPortalTask> wrapperTempList = new List<IPS_ParticipantPortalTask>();
        List<Task> tempGoalList = new List<Task>();
        List<Task> tempIntervalDueDateGoals = new List<Task>();
        List<Task> tempIntervalCompletedGoals = new List<Task>();
        List<Task> tempIntervalGoals = new List<Task>();

        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,IPS_subjectAndDate__c ,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Completed\' ';
        String goalId = ' AND WhatId = :recordId';
        String goalDueDateFilter = ' AND ActivityDate >= :reportDateFrom AND ActivityDate <= :reportDateTo';
        String goalCompletedDateFilter = ' AND DAY_ONLY(CompletedDateTime) >= :reportDateFrom AND DAY_ONLY(CompletedDateTime) <= :reportDateTo';
        String goalSort = ' ORDER BY ActivityDate DESC';
        String endQuery = '';
        String dueDateQuery = '';
        String completedDateQuery = '';

        if (reportType == 'End report') {
            endQuery = goalSelect + goalWhere + goalId + goalSort;
            tempGoalList = Database.query(endQuery);
            System.debug('Henter delmål: '+endQuery);

            for(Task ta:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = ta.Subject;
                tempList.EmneOgDato = ta.IPS_subjectAndDate__c ;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(ta.ActivityDate);
                tempList.OpprettelsesDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(ta.CreatedDate));
                tempList.UtfoertDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(ta.CompletedDateTime));
                tempList.ReferatKommentar = ta.Description;
                tempList.OppgaveId = ta.id;
                wrapperTempList.add(tempList);
            }
            
        }
        if( reportType == 'Intervall') {
            dueDateQuery = goalSelect + goalWhere + goalId + goalDueDateFilter + goalSort;
            tempIntervalDueDateGoals = Database.query(dueDateQuery);
            System.debug('Henter åpne delmål: '+tempGoalList);

            completedDateQuery = goalSelect + goalWhere + goalId + goalCompletedDateFilter + goalSort;
            tempIntervalCompletedGoals = Database.query(completedDateQuery);

            tempIntervalGoals.addAll(tempIntervalDueDateGoals);
            tempGoalList = tempIntervalGoals;

            for(Task t:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = t.Subject;
                tempList.EmneOgDato = t.IPS_subjectAndDate__c ;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(t.ActivityDate);
                tempList.OpprettelsesDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(t.CreatedDate));
                tempList.UtfoertDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(t.CompletedDateTime));
                tempList.ReferatKommentar = t.Description;
                tempList.OppgaveId = t.id;
                wrapperTempList.add(tempList);
            }


            // Adding unique completed goals to the list of goals queried by due date
            for (Task task : tempIntervalCompletedGoals) {
                if (!tempGoalList.contains(task)) {
                    IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                    tempList.Emne = task.Subject;
                    tempList.EmneOgDato = task.IPS_subjectAndDate__c ;
                    tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(task.ActivityDate);
                    tempList.OpprettelsesDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(task.CreatedDate));
                    tempList.UtfoertDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(task.CompletedDateTime));
                    tempList.ReferatKommentar = task.Description;
                    tempList.OppgaveId = task.id;
                    wrapperTempList.add(tempList);
                }
            }
    }
    return wrapperTempList;
}

     /**
     * Returns a list of unique goals that are completed either
     * within the given intervall or the whole period of the worktrail.
     *
     * @return  List of task
     */
    private static List<IPS_ParticipantPortalTask> getReportCompletedGoals(id recordId) {
        List<IPS_ParticipantPortalTask> wrapperTempList = new List<IPS_ParticipantPortalTask>();
        List<Task> tempGoalList = new List<Task>();


        String goalSelect = 'SELECT id,ActivityDate,CreatedDate,CompletedDateTime,IPS_subjectAndDate__c ,Subject,Type_of_Task_IPSUO__c,Description,Status FROM Task ';
        String goalWhere = ' WHERE Type_of_Task_IPSUO__c = \'Delmål (av hovedmål)\' AND Status = \'Completed\' ';
        String goalId = ' AND WhatId = :recordId';
        String goalSort = ' ORDER BY ActivityDate DESC';
        String endQuery = '';


            endQuery = goalSelect + goalWhere + goalId + goalSort;
            tempGoalList = Database.query(endQuery);
            System.debug('Henter delmål: '+endQuery);

            for(Task ta:tempGoalList){
                IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
                tempList.Emne = ta.Subject;
                tempList.EmneOgDato = ta.IPS_subjectAndDate__c ;
                tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(ta.ActivityDate);
                tempList.OpprettelsesDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(ta.CreatedDate));
                tempList.UtfoertDato = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(ta.CompletedDateTime));
                tempList.ReferatKommentar = ta.Description;
                tempList.OppgaveId = ta.id;
                wrapperTempList.add(tempList);
            }
            return wrapperTempList;
            
        }


  
  /*
    *********************************************************
    @Method Name    : getReportWrapperList
    @author         : AKO
    @description    : Henter rapport fra ips_report__c objektet med kriterer Status = 'Shared report'. for å vise dette på hovedsiden i innloggingsløsningen.
                        Viser at jobbspesialist har delt en veilederrapport for gjennomlesning i innlogginsløsningen.
    @param          : JobbsporId, 
    @param          : Type rapport(intervall,sluttrapport), 
    @return        : Liste over rapporter som er delt
    ********************************************************
    */
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
    *********************************************************
    @Method Name    : getReportDetailList
    @author         : AKO
    @description    : Henter rapport fra ips_report__c objektet med kriterer Status = 'Shared report'. 
    @param          : RapportId
    @return         : Rapportdetaljer
    ********************************************************
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
            IPS_endReportSumm1__c,
            IPS_endReportSumm2__c,
            IPS_endReportSumm3__c,
            IPS_workTrailName__c,
            IPS_endReportSumm4__c,
            IPS_endReportSumm5__c,
            IPS_endReportSumm6__c,
            IPS_endReportSumm7__c,
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
            IPS_workTrailName__r.ips_Priority_career_wishes__c,
            IPS_workTrailName__r.ips_Desired_profession_industry_career__c
            FROM ips_report__c 
            WHERE id =:currentRecordId
            AND IPS_status__c = 'Shared report'];
  
  
            if(!tempReportList.isEmpty()){
              for(ips_report__c r:tempReportList){
                  IPS_ParticipantPortalReport tempList = new IPS_ParticipantPortalReport();
                  tempList.reportId = r.Id;
                  tempList.reportTrailId = r.IPS_workTrailName__c;
                  tempList.reportDueDate =IPS_ParticipantPortalUtility.formatDate(r.IPS_dueDateBack__c);
                  tempList.reportName = r.IPS_subject__c;
                  tempList.reportType = r.IPS_report_Type__c;
                  tempList.reportParticipantComment =r.IPS_participantsComment__c;
                  tempList.reportParticipantOnBehalfComment = IPS_ParticipantPortalUtility.replaceBr(r.IPS_participantsOnBehalf__c);
                  tempList.reportOwnerName = r.IPS_workTrailOwner__c;
                  tempList.reportParticipantName = r.IPS_participantName__c;
                  tempList.reportTrailGoalDescription = r.IPS_workTrailName__r.ips_Main_goal__c;
                  tempList.reportTrailEndDate = r.IPS_workTrailName__r.ips_End_Date__c;
                  tempList.reportTrailEndCause = r.IPS_workTrailName__r.End_Cause__c;
                  tempList.reportTrailEndSubCause = r.IPS_workTrailName__r.ips_Other_end_cases__c;
                  tempList.reportTrailReferredDate = IPS_ParticipantPortalUtility.formatDate(r.IPS_workTrailName__r.ips_Referred_date__c);
                  
                  tempList.reportTrailStartDate = IPS_ParticipantPortalUtility.formatDate(Date.ValueOf(r.IPS_workTrailName__r.Oppstartsdato__c));
                  tempList.reportTrailSupervisor = r.IPS_workTrailName__r.ips_NAV_supervisor__c;
  
                  
                  if(r.IPS_worktrail_Type__c =='Supported Employment'){
                      tempList.reportTrailGoal = IPS_ParticipantPortalUtility.formatMainGoal(r.IPS_workTrailName__r.ips_UO_Service__c);
                      tempList.reportTrailDepartmentTeam = r.IPS_workTrailName__r.ips_Applying_Department__c;
                      tempList.reportTrailDepartmentTeamLabel ='Innsøkende avdeling';
                      tempList.reportTrailType = 'AMS';
                      tempList.reportTrailWorkWish= r.IPS_workTrailName__r.ips_Desired_profession_industry_career__c;
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
                    tempList.reportSummarizeComment1 = r.IPS_endReportSumm1__c;
                    tempList.reportSummarizeComment2 = r.IPS_endReportSumm2__c;
                    tempList.reportSummarizeComment3 = r.IPS_endReportSumm3__c;
                    tempList.reportSummarizeComment4 = r.IPS_endReportSumm4__c;
                    tempList.reportSummarizeComment5 = r.IPS_endReportSumm5__c;
                    tempList.reportSummarizeComment6 = r.IPS_endReportSumm6__c;
                    tempList.reportSummarizeComment7 = r.IPS_endReportSumm7__c;
                  }
                  
                  wrapperTempList.add(tempList);
              }
          }
          return wrapperTempList;
    }

 /*
    *********************************************************
    @Method Name    : getEducations
    @author         : AKO
    @description    : Henter data fra ips_Education__c  og AMS_Vocational_education_and_training__c  objektet 
                        Alle utdanninger som er pågående og fullført blir hentet for sluttrapport.
                        Utdanninger som er planlagt, påbegynt og fullført blir hentet for intervallrapport.
    @param          : JobbsporId, 
    @param          : Startdato
    @param          : Sluttdato
    @return         : Liste over utdanninger knyttet til ett jobbspor
    ********************************************************
    */
    private static List<IPS_ParticipantPortalEducation> getEducations(ID currentRecordId,Date reportDateFrom, Date reportDateTo){
        
        List<IPS_ParticipantPortalEducation> wrapperTempList = new List<IPS_ParticipantPortalEducation>();
        
        List<ips_Education__c> tempEducation = new List<ips_Education__c>();
        List<AMS_Vocational_education_and_training__c> tempAMSEducation = new List<AMS_Vocational_education_and_training__c>();

        tempEducation = [
            SELECT
                id,
                Name,
                ips_Name_of_the_Education_Institution__c,
                ips_Form_of_Education__c,
                ips_Start_Date__c,
                ips_End_Date__c,
                ips_What_did_not_work_with_thiseducation__c,
                ips_What_did_work_with_this_education__c,
                ips_Education_Support_Plan__c,
                ips_Status__c
            FROM ips_Education__c
            WHERE ips_Work_Trail__c = :currentRecordId 
            AND ips_Status__c IN ('Ongoing', 'Completed', 'Planned')
            ORDER BY ips_Start_Date__c DESC
        ];

        tempAMSEducation = [
            SELECT 
            id,
            name,
            AMS_Name_of_the_Education_institution__c,
            AMS_Form_of_Study__c,
            AMS_Start_Date__c,
            AMS_End_Date__c,
            AMS_What_did_not_work_with_the_education__c,
            AMS_What_did_work_with_the_education__c,
            AMS_Education_Support_Plan__c,
            AMS_Status__c,
            AMS_Description__c
            FROM AMS_Vocational_education_and_training__c 
            WHERE AMS_Work_Trail__c =:currentRecordId
            AND AMS_Status__c IN ('Ongoing', 'Completed', 'Planned')
            ORDER BY AMS_Start_Date__c DESC

        ];
        if(!tempAMSEducation.isEmpty()){
            for(AMS_Vocational_education_and_training__c ams : tempAMSEducation){
                IPS_ParticipantPortalEducation tempAMSList = new IPS_ParticipantPortalEducation();

                //end report
                if(reportDateFrom==null && reportDateTo==null){
                    if(ams.AMS_Status__c =='Completed' || ams.AMS_Status__c == 'Ongoing'){
                        tempAMSList.UtdanningId = ams.id;
                        tempAMSList.Utdanningslop = ams.AMS_Description__c;
                        tempAMSList.UtdanningNavn = ams.Name;
                        tempAMSList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(ams.AMS_Form_of_Study__c);
                        tempAMSList.Plan = ams.AMS_Education_Support_Plan__c;
                        tempAMSList.UtdanningStart = ams.AMS_Start_Date__c;
                        tempAMSList.UtdanningSlutt = ams.AMS_End_Date__c;
                        tempAMSList.Fungerer = ams.AMS_What_did_work_with_the_education__c;
                        tempAMSList.FungererIkke = ams.AMS_What_did_not_work_with_the_education__c;
                        tempAMSList.Status = ams.AMS_Status__c;
                       
                        wrapperTempList.add(tempAMSList);
                    }
                }
                //intervall report
                if(reportDateFrom!=null && reportDateTo!=null){
                    if(ams.AMS_Status__c == 'Ongoing'){
                        tempAMSList.UtdanningId = ams.id;
                        tempAMSList.Utdanningslop = ams.AMS_Description__c;
                        tempAMSList.UtdanningNavn = ams.Name;
                        tempAMSList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(ams.AMS_Form_of_Study__c);
                        tempAMSList.Plan = ams.AMS_Education_Support_Plan__c;
                        tempAMSList.UtdanningStart = ams.AMS_Start_Date__c;
                        tempAMSList.UtdanningSlutt = ams.AMS_End_Date__c;
                        tempAMSList.Fungerer = ams.AMS_What_did_work_with_the_education__c;
                        tempAMSList.FungererIkke = ams.AMS_What_did_not_work_with_the_education__c;
                        tempAMSList.Status = ams.AMS_Status__c;
                       
                        wrapperTempList.add(tempAMSList);
                    }else{
                        if(ams.AMS_End_Date__c !=null && (ams.AMS_End_Date__c >= reportDateFrom || ams.AMS_End_Date__c>= reportDateTo)){
                            tempAMSList.UtdanningId = ams.id;
                            tempAMSList.Utdanningslop = ams.AMS_Description__c;
                            tempAMSList.UtdanningNavn = ams.Name;
                            tempAMSList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(ams.AMS_Form_of_Study__c);
                            tempAMSList.Plan = ams.AMS_Education_Support_Plan__c;
                            tempAMSList.UtdanningStart = ams.AMS_Start_Date__c;
                            tempAMSList.UtdanningSlutt = ams.AMS_End_Date__c;
                            tempAMSList.Fungerer = ams.AMS_What_did_work_with_the_education__c;
                            tempAMSList.FungererIkke = ams.AMS_What_did_not_work_with_the_education__c;
                            tempAMSList.Status = ams.AMS_Status__c;
                       
                            wrapperTempList.add(tempAMSList);
                        }
                        if(ams.AMS_End_Date__c== null && ams.AMS_Start_Date__c >= reportDateFrom && ams.AMS_Start_Date__c <= reportDateTo){
                            tempAMSList.UtdanningId = ams.id;
                            tempAMSList.Utdanningslop = ams.AMS_Description__c;
                            tempAMSList.UtdanningNavn = ams.Name;
                            tempAMSList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(ams.AMS_Form_of_Study__c);
                            tempAMSList.Plan = ams.AMS_Education_Support_Plan__c;
                            tempAMSList.UtdanningStart = ams.AMS_Start_Date__c;
                            tempAMSList.UtdanningSlutt = ams.AMS_End_Date__c;
                            tempAMSList.Fungerer = ams.AMS_What_did_work_with_the_education__c;
                            tempAMSList.FungererIkke = ams.AMS_What_did_not_work_with_the_education__c;
                            tempAMSList.Status = ams.AMS_Status__c;
                        
                            wrapperTempList.add(tempAMSList);
                        }
                    }
                }
        }

        if(!tempEducation.isEmpty()){
            for(ips_Education__c i : tempEducation) {
                IPS_ParticipantPortalEducation tempList = new IPS_ParticipantPortalEducation();
                
                // end report
                if (reportDateFrom==null && reportDateTo==null){
                    if(i.ips_Status__c == 'Ongoing' || i.ips_Status__c == 'Completed'){
                        tempList.UtdanningId = i.id;
                        tempList.UtdanningNavn = i.Name;
                        tempList.UtdanningSted = i.ips_Name_of_the_Education_Institution__c;
                        tempList.Utdanningsform =IPS_ParticipantPortalUtility.formatTypeOf(i.ips_Form_of_Education__c);
                        tempList.Plan = i.ips_Education_Support_Plan__c;
                        tempList.UtdanningStart = i.ips_Start_Date__c;
                        tempList.UtdanningSlutt = i.ips_End_Date__c;
                        tempList.Fungerer = i.ips_What_did_work_with_this_education__c;
                        tempList.FungererIkke = i.ips_What_did_not_work_with_thiseducation__c;
                        tempList.Status = i.ips_Status__c;
                        wrapperTempList.add(tempList);
                    }
                }
                //intervall report
                if (reportDateFrom!=null && reportDateTo!=null){
                    if(i.ips_Status__c == 'Ongoing'){
                        tempList.UtdanningId = i.id;
                        tempList.UtdanningNavn = i.Name;
                        tempList.UtdanningSted = i.ips_Name_of_the_Education_Institution__c;
                        tempList.Utdanningsform =IPS_ParticipantPortalUtility.formatTypeOf(i.ips_Form_of_Education__c);
                        tempList.Plan = i.ips_Education_Support_Plan__c;
                        tempList.UtdanningStart = i.ips_Start_Date__c;
                        tempList.UtdanningSlutt = i.ips_End_Date__c;
                        tempList.Fungerer = i.ips_What_did_work_with_this_education__c;
                        tempList.FungererIkke = i.ips_What_did_not_work_with_thiseducation__c;
                        tempList.Status = i.ips_Status__c;
                        wrapperTempList.add(tempList);
                    }
                    
                    /*else{
                        if(i.ips_End_Date__c !=null && (i.ips_End_Date__c >= reportDateFrom || i.ips_End_Date__c>= reportDateTo)){
                            tempList.UtdanningId = i.id;
                            tempList.UtdanningNavn = i.Name;
                            tempList.UtdanningSted = i.ips_Name_of_the_Education_Institution__c;
                            tempList.Utdanningsform =IPS_ParticipantPortalUtility.formatTypeOf(i.ips_Form_of_Education__c);
                            tempList.Plan = i.ips_Education_Support_Plan__c;
                            tempList.UtdanningStart = i.ips_Start_Date__c;
                            tempList.UtdanningSlutt = i.ips_End_Date__c;
                            tempList.Fungerer = i.ips_What_did_work_with_this_education__c;
                            tempList.FungererIkke = i.ips_What_did_not_work_with_thiseducation__c;
                            tempList.Status = i.ips_Status__c;
                            wrapperTempList.add(tempList);
                        }
                        if(i.ips_End_Date__c== null && i.ips_Start_Date__c >= reportDateFrom && i.ips_Start_Date__c <= reportDateTo){
                            tempList.UtdanningId = i.id;
                            tempList.UtdanningNavn = i.Name;
                            tempList.UtdanningSted = i.ips_Name_of_the_Education_Institution__c;
                            tempList.Utdanningsform =IPS_ParticipantPortalUtility.formatTypeOf(i.ips_Form_of_Education__c);
                            tempList.Plan = i.ips_Education_Support_Plan__c;
                            tempList.UtdanningStart = i.ips_Start_Date__c;
                            tempList.UtdanningSlutt = i.ips_End_Date__c;
                            tempList.Fungerer = i.ips_What_did_work_with_this_education__c;
                            tempList.FungererIkke = i.ips_What_did_not_work_with_thiseducation__c;
                            tempList.Status = i.ips_Status__c;
                            wrapperTempList.add(tempList);
    
                        }
    
                    }*/
    
                }
            }
        }
       
        }
        return wrapperTempList;
    }

    /*
    *********************************************************
    @Method Name    : getJobs
    @author         : AKO
    @description    : Henter data fra ips_Job__c objektet. Henter alle pågående og fullførte jobber for sluttrapport.
                        Henter alle pågående jobber og fullførte jobber som er innenfor intervall for intervallrapport.

    @param          : JobbsporId, 
    @param          : Startdato
    @param          : Sluttdato
    @Return         : Liste over jobber knyttet til ett jobbspor
    ********************************************************
    */
    private static list< IPS_ParticipantPortalJob> getJobs(ID recordId,Date reportDateFrom, Date reportDateTo) {
        List<IPS_ParticipantPortalJob> wrapperTempList = new List<IPS_ParticipantPortalJob>();
        List<ips_Job__c> activeJobs = new List<ips_Job__c>();
        activeJobs = [
            SELECT
                id,
                Name,
                ips_Employer__r.Name,
                ips_Form_of_Employment__c,
                ips_Start_Date__c,
                IPS_UO_Stillingsbeskrivelse__c,
                ips_Job_Support__c,
                ips_End_Date__c,
                ips_Status__c,
                ips_What_did_not_work_at_the_workplace__c,
                ips_What_did_work_at_the_workplace__c,
                IPS_jobSubject__c
            FROM ips_Job__c
            WHERE ips_Work_Trail__c = :recordId AND ips_Status__c = 'Ongoing'
            ORDER BY ips_Start_Date__c DESC
        ];

        for(ips_Job__c j:activeJobs){

            IPS_ParticipantPortalJob tempListActive = new IPS_ParticipantPortalJob();
            tempListActive.JobbId =  j.id;
            tempListActive.Emne = j.Name;
            tempListActive.Arbeidsform = IPS_ParticipantPortalUtility.formatTypeOf(j.ips_Form_of_Employment__c);
            tempListActive.Plan = j.ips_Job_Support__c;
            tempListActive.StartDato = j.ips_Start_Date__c;
            tempListActive.SluttDato = j.ips_End_Date__c;
            tempListActive.Arbeidsgiver = j.ips_Employer__r.Name;
            tempListActive.Stillingsbeskrivelse = j.IPS_UO_Stillingsbeskrivelse__c;
            tempListActive.Fungerer = j.ips_What_did_work_at_the_workplace__c;
            tempListActive.FungererIkke = j.ips_What_did_not_work_at_the_workplace__c;
            tempListActive.Status = IPS_ParticipantPortalUtility.formatJobStatus(j.ips_Status__c);
            wrapperTempList.add(tempListActive);
        }

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
                ips_Status__c,
                ips_Job__c.ips_What_did_not_work_at_the_workplace__c,
                ips_What_did_work_at_the_workplace__c,
                IPS_jobSubject__c
            FROM ips_Job__c
            WHERE
                ips_Work_Trail__c = :recordId
                AND ips_Status__c = 'Completed'
                AND (ips_End_Date__c >= :reportDateFrom
                AND ips_End_Date__c <= :reportDateTo)
            ORDER BY ips_End_Date__c DESC
        ];

        for(ips_Job__c j:closedJobs){

        IPS_ParticipantPortalJob tempListCompleted = new IPS_ParticipantPortalJob();
        tempListCompleted.JobbId =  j.id;
        tempListCompleted.Emne = j.Name;
        tempListCompleted.Arbeidsform = j.ips_Form_of_Employment__c;
        tempListCompleted.Plan = j.ips_Job_Support__c;
        tempListCompleted.StartDato = j.ips_Start_Date__c;
        tempListCompleted.SluttDato = j.ips_End_Date__c;
        tempListCompleted.Arbeidsgiver = j.ips_Employer__r.Name;
        tempListCompleted.Stillingsbeskrivelse = j.IPS_UO_Stillingsbeskrivelse__c;
        tempListCompleted.Fungerer = j.ips_What_did_work_at_the_workplace__c;
        tempListCompleted.FungererIkke = j.ips_What_did_not_work_at_the_workplace__c;
        tempListCompleted.Status = IPS_ParticipantPortalUtility.formatJobStatus(j.ips_Status__c);
        wrapperTempList.add(tempListCompleted);

        }
       
        return wrapperTempList;
    }
  
  

  }