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
}