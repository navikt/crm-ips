public without sharing class IPS_ParticipantPortalUtility{

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
        if(typeOfMeeting == 'Meeting with Employer'){return 'Møte med arbeidsgiver';}
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
        if(typeOf =='Zero hours contract'){return 'Tilkalling ekstrajobb';}
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

    public static String replaceBr( String textToReplace) {
        if(String.isEmpty(textToReplace)){
            return '';
        }else{
            String tempText = textToReplace.replace('<br>','\n');
            return tempText;
        }
        
    }

    public static String formatJobStatus(String jobStatus){
        if(jobStatus == 'Planned'){return 'Planlagt';}
        if(jobStatus == 'Ongoing'){return 'Pågående';}
        if(jobStatus == 'Aborted'){ return 'Avbrutt';}
        if(jobStatus == 'Completed'){return 'Avsluttet';}
        if(jobStatus == 'Ended'){return 'Avsluttet';}
        else {return 'Ingen status valgt';}
    }

    public static String formatEndCauses(String endCause){
        if(endCause == 'Work'){return 'Arbeid';}
        if(endCause == 'Education'){return 'Utdanning';}
        if(endCause == 'Other end causes'){return 'Andre sluttårsaker';}
        if(endCause == 'Education - self-financed'){return 'Utdanning - egenfinansiert';} 
        if(endCause == 'Education - covered by NAV'){return 'Utdanning - dekket av NAV';}
        if(endCause == 'Chaining for other work-oriented measures under the auspices of NAV'){return 'Kjeding til andre arbeidsrettede tiltak i regi av NAV';}
        if(endCause == 'Other (military, pregnancy, relocation, etc.)'){return 'Annet (militær, svangerskap, flytting mm)';}
        if(endCause == 'Other active measures in consultation with NAV (eg medical treatment, or municipal measures)'){return 'Andre aktive tiltak i samråd med NAV (eks medisinsk behandling eller kommunale tiltak)';}
        if(endCause == 'Illness'){return 'Sykdom';} 
        if(endCause == 'Applied for / granted old age pension / AFP'){return 'Søkt/innvilget alderspensjon/AFP';}
        if(endCause == 'Applied / granted disability benefits'){return 'Søkt/innvilget uføretrygd';}   
        if(endCause == 'Work without wage subsidy'){return 'Arbeid uten lønnstilskudd';}
        if(endCause == 'Work with wage subsidies from NAV'){return 'Arbeid med lønnstilskudd fra NAV';}
        if(endCause == 'Work in combination with other benefits from NAV'){return 'Arbeid i kombinasjon med andre ytelser fra NAV';}
        if(endCause == 'Work in combination with a graduated disability pension'){return 'Arbeid i kombinasjon med gradert uførepensjon';}
        if(endCause == 'Not applicable'){return 'Ikke aktuell';}
        else {return 'Ingen årsak valgt';}
    }

}