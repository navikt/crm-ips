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

    public static String formatParticipatedBoolean(Boolean bool){
        if(bool){
            return 'Deltatt';
        }else{
            return'Ikke deltatt';
        }
    }

    public static String formatTypeOfMeeting(String typeOfMeeting){
        if(typeOfMeeting == 'Meeting with Participant'){return 'Møte med deltaker';}
        if(typeOfMeeting == 'Start up meeting'){return 'Oppstartsmøte';}
        if(typeOfMeeting == 'First Meeting with Employer'){ return 'Første møte med arbeidsgiver';}
      else{return 'Ingen møtetype';}
    }

    public static String formatSubcategory(String subcategory){
        if(subcategory == 'Job development'){return 'Jobbutvikling';}
        if(subcategory == 'Relationship building'){return 'Relasjonsbygging';}
        if(subcategory == 'Job support'){return 'Jobbstøtte';}
        if(subcategory == 'Follow-up'){return 'Oppfølging';}
        else {return 'Ingen underkategori';}
    }

    public static String formatMainGoal(String goal){
        if(goal =='Work'){return 'Jobb';}
        if(goal =='Education/Apprentice'){return 'Utdanning';}
        if(goal =='AMS'){return 'Arbeid';}
        if(goal =='Vocational education and training'){return 'Fag og yrkesopplæring';}
        else{return 'Ingen hovedmål valgt';}
    }

    public static String formatTypeOf(string typeOf){
        //job types
        if(typeOf =='Apprentice'){return 'Lærling';}
        if(typeOf =='Freelance / self-employed'){return 'Freelance/selvstendig næringsdrivende';}
        if(typeOf =='Permanent employment'){return 'Fast ansettelse';}
        if(typeOf =='Temporary employment'){return 'Tidsbegrenset ansettelse';}
        if(typeOf =='work training'){return 'Arbeidstrening';}
        if(typeOf =='Zero hours contrac'){return 'Tilkalling ekstrajobb';}
        //education types
        if(typeOf =='Certificate of Apprenticeship'){return 'Lærling';}
        if(typeOf =='Full-time Study'){return 'Heltidsstudie';}
        if(typeOf =='Part-time Study'){return 'Deltidsstudie';}
        if(typeOf =='Evening Course'){return 'Kurs på kveldstid';}
        if(typeOf =='Day Cource'){return 'Kurs på dagtid';}
        if(typeOf =='Module-structured subject and vocational training'){return 'Modulstrukturert fag- og yrkesopplæring';}
        //ams education types
        if(typeOf =='Vocational certificate at work'){return 'Fagbrev på jobb';}
        if(typeOf =='0+4 scheme'){return '0+4 ordning';}
        if(typeOf =='practice letter candidate'){return 'Praksisbrevkandidat';}
        if(typeOf =='practice candidate'){return 'Praksiskandidat';}
        if(typeOf =='Teaching candidate'){return 'Lærerkandidat';}
        if(typeOf =='Upper Secondary Education for Adults (VOV)'){return 'Videregående opplæring for voksne (VOV)';}
        else{return 'Ingen type valgt';}
    }

}