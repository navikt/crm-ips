public with sharing class IPS_ParticipantPortalUtility{

    public static string formatDate(Date recordDate){
        if(recordDate==null){
            return null;
        }else{
            Date tempDate = recordDate;
            String stringTempDate = tempDate.format();
            return stringTempDate;
        }
        
    }

    public static string formatDateTime(DateTime recordDate){
        
        if(recordDate == null){
            return null;
        }else{
            DateTime tempDate = recordDate;
            String stringTempDate = tempDate.format();
            return stringTempDate;
        }
        
    }

    public static String formatMainGoal(String goal){
        if(goal =='Work'){return 'Jobb';}
        if(goal =='Education/Apprentice'){return 'Utdanning';}
        if(goal =='AMS'){return 'Arbeid';}
        if(goal =='Vocational education and training'){return 'Fag og yrkesopplæring';}
        else{return 'Ingen hovedmål valgt';}
    }

}