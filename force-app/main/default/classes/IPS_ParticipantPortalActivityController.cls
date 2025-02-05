public with sharing class IPS_ParticipantPortalActivityController {

 /* 
 * Open goals that is connected with participants worktrail
 * Portal Activity
 * */
 @AuraEnabled(cacheable = true)    
 public static List<IPS_ParticipantPortalTask> getParticipantsOpenGoals(String recordId){
    Id trailRecordId = recordId;

    List<IPS_ParticipantPortalTask> wrapperList = new List<IPS_ParticipantPortalTask>();
    wrapperList = getOpenGoals(trailRecordId);
    return wrapperList;
 }

 private static List<IPS_ParticipantPortalTask> getOpenGoals(Id trailRecordId){
    List<IPS_ParticipantPortalTask> tempWrapperList = new List<IPS_ParticipantPortalTask>();

    List<Task> tempTaskList = new List<Task>();
    tempTaskList =[
         SELECT 
             id,
             ActivityDate,
             Subject,
             Description
         FROM Task 
         WHERE WhatId = :trailRecordId 
         AND Type_of_Task_IPSUO__c ='Delmål (av hovedmål)'  
         AND Status ='Open'
         ORDER BY ActivityDate ASC
     ];

     for(Task t:tempTaskList){
        IPS_ParticipantPortalTask tempList = new IPS_ParticipantPortalTask();
        tempList.Emne = t.subject;
        tempList.ForfallsDato = IPS_ParticipantPortalUtility.formatDate(t.ActivityDate);
        tempList.ReferatKommentar = t.Description;
        tempList.OppgaveId = t.id;
        tempWrapperList.add(tempList);
     }
     return tempWrapperList;
 }

  /* 
 * Open meetings that is connected with participants worktrail
 * Portal Activity
 * */
 @AuraEnabled(cacheable = true) 
 public static List<IPS_ParticipantPortalEvent> getParticipantOpenMeetings(String recordId,String contactId){
    Id trailRecordId = recordId;
    Id participantId = contactId;

    List<IPS_ParticipantPortalEvent> wrapperList = new List<IPS_ParticipantPortalEvent>();
    wrapperList = getOpenMeetings(trailRecordId,participantId);
    return wrapperList;
 }

 private static List<IPS_ParticipantPortalEvent> getOpenMeetings(Id trailRecordId,Id participantId){
    List<IPS_ParticipantPortalEvent> tempWrapperList = new List<IPS_ParticipantPortalEvent>();

     Date todaysDate = System.today();
     List<Event> tempEventList = new List<Event>();
     tempEventList =[
         SELECT 
             id,
             IPS_subjectAndDate__c,
             Location,
             StartDateTime,
             EndDateTime, 
             Description,
             IPS_employerName__c 
         FROM event 
         WHERE 
             ActivityDate >=: todaysDate
             AND WhoId= :participantId 
             AND WhatId = :trailRecordId 
             AND (IPS_Type__c ='Meeting with Participant' OR IPS_Type__c='Meeting with Employer')
             AND IPS_Status1__c ='Open'
         ORDER BY ActivityDate DESC
     ];

     for(Event t:tempEventList){
        IPS_ParticipantPortalEvent tempList = new IPS_ParticipantPortalEvent();
        tempList.Emne = t.IPS_subjectAndDate__c;
        tempList.FraTidDato = t.StartDateTime;
        tempList.TilTidDato = t.EndDateTime;
        tempList.ReferatKommentar = t.Description;
        tempList.EventId = t.id;
        tempList.Lokasjon =t.Location;
        tempList.Arbeidsgiver = t.IPS_employerName__c;
        tempWrapperList.add(tempList);
     }
     return tempWrapperList;

 }

  /* 
 * Open jobs that is connected with participants worktrail
 * Portal Activity
 * */
@AuraEnabled(cacheable=true)
public static List<IPS_ParticipantPortalJob> getParticipantOpenJobs(String recordId){
    Id trailRecordId = recordId;

    List<IPS_ParticipantPortalJob> wrapperList = new List<IPS_ParticipantPortalJob>();
    wrapperList = getOpenJobs(trailRecordId);
    return wrapperList;
  
}
private static List<IPS_ParticipantPortalJob> getOpenJobs(Id trailRecordId){
    List<IPS_ParticipantPortalJob> tempWrapperList = new List<IPS_ParticipantPortalJob>();

    List<ips_Job__c> tempJobList = new List<ips_Job__c>();

    tempJobList =[
         SELECT 
            Id, 
            IPS_jobSubject__c, 
            ips_Start_Date__c,
            ips_End_Date__c, 
            ips_Form_of_Employment__c, 
            ips_Job_Support__c, 
            ips_Number_of_hours__c
            FROM ips_Job__c 
            WHERE ips_Work_Trail__c =:trailRecordId
            AND ips_Form_of_Employment__c !='work training'
            AND ips_Status__c ='Ongoing'
         ];

         for(ips_Job__c j:tempJobList){
            IPS_ParticipantPortalJob tempList = new IPS_ParticipantPortalJob();
            tempList.Emne = j.IPS_jobSubject__c;
            tempList.JobbId = j.id;
            tempList.StartDato = j.ips_Start_Date__c;
            tempList.SluttDato = j.ips_End_Date__c;
            tempList.AntallTimerUke = j.ips_Number_of_hours__c;
            tempList.Plan =j.ips_Job_Support__c;
            tempList.Arbeidsform = IPS_ParticipantPortalUtility.formatTypeOf(j.ips_Form_of_Employment__c);
            tempWrapperList.add(tempList);
         }
         return tempWrapperList;
}

  /* 
 * Open job trainings that is connected with participants worktrail
 * Portal Activity
 * */
@AuraEnabled(cacheable=true)
public static List<IPS_ParticipantPortalJob> getParticipantOpenJobTrainings(String recordId){
    Id trailRecordId = recordId;

    List<IPS_ParticipantPortalJob> wrapperList = new List<IPS_ParticipantPortalJob>();
    wrapperList = getOpenJobTrainings(trailRecordId);
    return wrapperList;
  
}
private static List<IPS_ParticipantPortalJob> getOpenJobTrainings(Id trailRecordId){
    List<IPS_ParticipantPortalJob> tempWrapperList = new List<IPS_ParticipantPortalJob>();

    List<ips_Job__c> tempJobTrainingList = new List<ips_Job__c>();

    tempJobTrainingList =[
         SELECT 
            Id, 
            IPS_jobSubject__c, 
            ips_Start_Date__c,
            ips_End_Date__c, 
            ips_Form_of_Employment__c, 
            ips_Job_Support__c, 
            ips_Number_of_hours__c
            FROM ips_Job__c 
            WHERE ips_Work_Trail__c =:trailRecordId
            AND ips_Form_of_Employment__c ='work training'
            AND ips_Status__c ='Ongoing'
         ];

         for(ips_Job__c j:tempJobTrainingList){
            IPS_ParticipantPortalJob tempList = new IPS_ParticipantPortalJob();
            tempList.Emne = j.IPS_jobSubject__c;
            tempList.JobbId = j.id;
            tempList.StartDato = j.ips_Start_Date__c;
            tempList.SluttDato = j.ips_End_Date__c;
            tempList.AntallTimerUke = j.ips_Number_of_hours__c;
            tempList.Plan =j.ips_Job_Support__c;
            tempWrapperList.add(tempList);
         }
         return tempWrapperList;
}

/* 
 * Open education that is connected with participants worktrail
 * Portal Activity
 * */
@AuraEnabled(cacheable=true)
public static List<IPS_ParticipantPortalEducation> getParticipantOpenEducations(String recordId){
    Id trailRecordId = recordId;

    List<IPS_ParticipantPortalEducation> wrapperList = new List<IPS_ParticipantPortalEducation>();
    wrapperList = getOpenEducations(trailRecordId);
    return wrapperList;
  
}
private static List<IPS_ParticipantPortalEducation> getOpenEducations(Id trailRecordId){
    List<IPS_ParticipantPortalEducation> tempWrapperList = new List<IPS_ParticipantPortalEducation>();

    List<ips_Education__c> tempEducationList = new List<ips_Education__c>();
    tempEducationList =[
        SELECT 
            id,
            Name,
            ips_Name_of_the_Education_Institution__c,
            ips_Start_Date__c,
            ips_End_Date__c,
            ips_Education_Support_Plan__c,
            ips_Form_of_Education__c
        FROM ips_Education__c
        WHERE ips_Work_Trail__c =:trailRecordId
        AND ips_Status__c = 'Ongoing'
        ];

         for(ips_Education__c e:tempEducationList){
            IPS_ParticipantPortalEducation tempList = new IPS_ParticipantPortalEducation();
            tempList.UtdanningNavn = e.Name;
            tempList.UtdanningId = e.id;
            tempList.UtdanningSted = e.ips_Name_of_the_Education_Institution__c;
            tempList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(e.ips_Form_of_Education__c);
            tempList.UtdanningStart = e.ips_Start_Date__c;
            tempList.UtdanningSlutt = e.ips_End_Date__c;
            tempList.Plan = e.ips_Education_Support_Plan__c;
            tempWrapperList.add(tempList);
         }
         return tempWrapperList;
}

/* 
 * Open AMS education/training that is connected with participants worktrail
 * Portal Activity
 * */
@AuraEnabled(cacheable=true)
public static List<IPS_ParticipantPortalEducation> getParticipantOpenEducationTrainingAMS(String recordId){
    Id trailRecordId = recordId;

    List<IPS_ParticipantPortalEducation> wrapperList = new List<IPS_ParticipantPortalEducation>();
    wrapperList = getOpenEducationsTraining(trailRecordId);
    return wrapperList;
  
}
private static List<IPS_ParticipantPortalEducation> getOpenEducationsTraining(Id trailRecordId){
    List<IPS_ParticipantPortalEducation> tempWrapperList = new List<IPS_ParticipantPortalEducation>();

    List<AMS_Vocational_education_and_training__c> tempEducationList = new List<AMS_Vocational_education_and_training__c>();
    tempEducationList =[
        SELECT 
            id,
            Name,
            AMS_Name_of_the_Education_institution__c, 
            AMS_Start_Date__c, 
            AMS_End_Date__c, 
            AMS_Education_Support_Plan__c, 
            AMS_Form_of_Study__c
        FROM AMS_Vocational_education_and_training__c 
        WHERE AMS_Work_Trail__c =:trailRecordId
        AND AMS_Status__c  = 'Ongoing'
        ];

         for(AMS_Vocational_education_and_training__c e:tempEducationList){
            IPS_ParticipantPortalEducation tempList = new IPS_ParticipantPortalEducation();
            tempList.UtdanningNavn = e.Name;
            tempList.UtdanningId = e.id;
            tempList.UtdanningSted = e.AMS_Name_of_the_Education_institution__c;
            tempList.Utdanningsform = IPS_ParticipantPortalUtility.formatTypeOf(e.AMS_Form_of_Study__c);
            tempList.UtdanningStart = e.AMS_Start_Date__c;
            tempList.UtdanningSlutt = e.AMS_End_Date__c;
            tempList.Plan = e.AMS_Education_Support_Plan__c;
            tempWrapperList.add(tempList);
         }
         return tempWrapperList;
}

}