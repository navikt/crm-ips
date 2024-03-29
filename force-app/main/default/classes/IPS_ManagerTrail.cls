public class IPS_ManagerTrail {

    @AuraEnabled
    public String trailStatus;

    @AuraEnabled
    public Integer numberOfTrail;

    @AuraEnabled
    public Integer rowId;
    
    @AuraEnabled
    public String employeeName;

    @AuraEnabled
    public String employeeId;
    
    @AuraEnabled
    public String month;
    
    @AuraEnabled
    public Integer year;
    
    @AuraEnabled
    public String cause;

    @AuraEnabled
    public String subCause;

    @AuraEnabled
    public String service;

    @AuraEnabled
    public Integer totalEnded;
}