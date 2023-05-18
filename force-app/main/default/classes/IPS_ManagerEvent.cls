public with sharing class IPS_ManagerEvent {
   @AuraEnabled
   public Id employeeId;
   
    @AuraEnabled
    public String employeeName;

    @AuraEnabled
    public String participantIdent;

    @AuraEnabled
    public String  participantName;

    @AuraEnabled
    public String  participantAddress;

    @AuraEnabled
    public String subject; 

    @AuraEnabled
    public String location; 

    @AuraEnabled
    public String startTime;

    @AuraEnabled
    public String meetingCategory;
   
    @AuraEnabled
    public Id eventId;

    @AuraEnabled
    public Id accountId;

    @AuraEnabled
    public String accountName;

    @AuraEnabled
    public Boolean isParticipantAttending;
    
    public Id workTrailId;

}