@isTest
public class IPS_ParticipantPortalUtilityTest {
    
     @isTest
    static void formatDate(){
        
        Date tempDate = Date.newInstance(2024,12,19);
        String formatDate =IPS_ParticipantPortalUtility.formatDate(tempDate);
        System.Assert.areEqual('19.12.2024',formatDate);
    }
    
    @isTest
    static void formatDateTime(){
        DateTime tempDate = DateTime.newInstance(2024, 12, 19, 12, 49, 00);
        String formatDate =IPS_ParticipantPortalUtility.formatDateTime(tempDate);
        System.Assert.areEqual('19.12.2024, 12:49',formatDate);
        
    }
    
    @isTest
    static void formatMainGoalWork(){
        String tempGoal = 'Work';
        String formatGoal =IPS_ParticipantPortalUtility.formatMainGoal(tempGoal);
        System.Assert.areEqual('Jobb',formatGoal);
    }
    
    @isTest
    static void formatMainGoalEducation(){
        String tempGoal = 'Education/Apprentice';
        String formatGoal =IPS_ParticipantPortalUtility.formatMainGoal(tempGoal);
        System.Assert.areEqual('Utdanning',formatGoal);
    }
    
    @isTest
    static void formatMainGoalArbeid(){
        String tempGoal = 'AMS';
        String formatGoal =IPS_ParticipantPortalUtility.formatMainGoal(tempGoal);
        System.Assert.areEqual('Arbeid',formatGoal);
    }
    
    @isTest
    static void formatMainGoalTraining(){
        String tempGoal = 'Vocational education and training';
        String formatGoal =IPS_ParticipantPortalUtility.formatMainGoal(tempGoal);
        System.Assert.areEqual('Fag og yrkesopplæring',formatGoal);
    }
    
    @isTest
    static void testNullValues(){
        Date tempDate = null;
        String formatDate =IPS_ParticipantPortalUtility.formatDate(tempDate);
        System.Assert.areEqual(null,formatDate);
        
        DateTime tempDateTime =null;
        String formatDateTime =IPS_ParticipantPortalUtility.formatDateTime(tempDateTime);
        System.Assert.areEqual(null,formatDateTime);
        
        String tempGoal = '';
        String formatGoal =IPS_ParticipantPortalUtility.formatMainGoal(tempGoal);
        System.Assert.areEqual('Ingen hovedmål valgt',formatGoal);
    }

}