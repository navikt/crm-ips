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
    static void formatBooleantrue(){
        Boolean tempBool = true;
        String formatBool = IPS_ParticipantPortalUtility.formatParticipatedBoolean(tempBool);
        System.Assert.areEqual('Deltatt',formatBool);
    }
    
    @isTest
    static void formatBooleanfalse(){
        Boolean tempBool = false;
        String formatBool = IPS_ParticipantPortalUtility.formatParticipatedBoolean(tempBool);
        System.Assert.areEqual('Ikke deltatt',formatBool);
    }
    
    @isTest
    static void formatTypeOfMeeting(){
        String tempType = 'Meeting with Participant';
        String formatType = IPS_ParticipantPortalUtility.formatTypeOfMeeting(tempType);
        System.Assert.areEqual('Møte med deltaker',formatType);
    }
    
    @isTest
    static void formatSubCategory(){
        String tempSub = 'Job development';
        String formatSub = IPS_ParticipantPortalUtility.formatSubcategory(tempSub);
        System.Assert.areEqual('Jobbutvikling',formatSub);
    }
    
    @isTest
    static void formatTypeOf(){
        String tempType = 'Apprentice';
        String formatType = IPS_ParticipantPortalUtility.formatTypeOf(tempType);
        System.Assert.areEqual('Lærling',formatType);
    }

    @isTest
    static void textReplace(){
        String s1 = 'First Line<br>Second Line<br>Third Line';
        String s2 = IPS_ParticipantPortalUtility.replaceBr(s1);
        System.assert(!s2.contains('<br>'));
    }
    
    @isTest
    static void jobStatus(){
        
        String[] tempStatus = new List<String>();
        tempStatus.add('Planned');
        tempStatus.add('Ongoing');
        tempStatus.add('Completed');
        tempStatus.add(' ');
        String formatStatus;
        for(Integer i=0;i<tempStatus.size();i++){
            formatStatus =IPS_ParticipantPortalUtility.formatJobStatus(tempStatus[i]);
        }
        System.Assert.areEqual('Ingen status valgt',formatStatus);
    }

    @isTest
    static void formatEndCause(){
        
        String[] tempEndCause = new List<String>();
        tempEndCause.add('Work');
        tempEndCause.add('Other');
        tempEndCause.add('Education');
        tempEndCause.add(' ');
        String formatEndCause;
        for(Integer i=0;i<tempEndCause.size();i++){
            formatEndCause =IPS_ParticipantPortalUtility.formatEndCauses(tempEndCause[i]);
        }
        System.Assert.areEqual('Ingen årsak valgt',formatEndCause);
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
        
        String tempType = '';
        String formatType = IPS_ParticipantPortalUtility.formatTypeOfMeeting(tempType);
        System.Assert.areEqual('Ingen møtetype',formatType);
        
        String tempSub = '';
        String formatSub = IPS_ParticipantPortalUtility.formatSubcategory(tempSub);
        System.Assert.areEqual('Ingen underkategori',formatSub);
        
        String tempTypeOf = '';
        String formatTypeOf = IPS_ParticipantPortalUtility.formatTypeOf(tempTypeOf);
        System.Assert.areEqual('Ingen type valgt',formatTypeOf);
        
        String s1 = '';
        String s2 = IPS_ParticipantPortalUtility.replaceBr(s1);
        System.Assert.areEqual('',s2);
    }

}