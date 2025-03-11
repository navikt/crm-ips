public without sharing class IPS_ParticipantPortalUtility{

    private static Boolean checkParticipantPermission(String userId){
        String currentRecordId = userId;
        String userPermissionSet = 'IPS_Deltaker';
        List<PermissionSetAssignment> tempList = new List<PermissionSetAssignment>();
        tempList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.name =: userPermissionSet AND isActive = true AND AssigneeId =:currentRecordId];
        if(tempList.size() > 0){
            return true;
        }
        return false;
    }

    public static List<User> getPersonAccountId(String userId) {
        List<User> userList = new List<User>();
        String confidential = 'UGRADERT';
        //String query = 'SELECT AccountId FROM User WHERE Id = :userId AND Account.CRM_Person__r.INT_Confidential__C =:confidential LIMIT 1';
        if (userId != null) {
            //userList = Database.query(query);
            userList = [
                SELECT AccountId
                FROM User
                WHERE Id = :userId AND Account.CRM_Person__r.INT_Confidential__C = :confidential
                LIMIT 1
            ];
        }
        return userList;
    }

    @AuraEnabled(cacheable = true)
    public static List<work_trail__c> getUserWorkTrailId(String userId) {

            List<User> userList = IPS_Utility.getPersonAccountId(userId);
                if(userList.isEmpty()){
                    system.debug('No accountId found on user');
                    return new List<work_trail__c>();
                }
            String accountId = userList[0]?.AccountId;
            List<Work_Trail__c> mytrail = new List<Work_Trail__c>();
            mytrail = [
                SELECT id,ips_Participant__r.PersonContactId,RecordType.DeveloperName,ips_End_Date__c
                FROM Work_Trail__c 
                WHERE ips_Participant__c = :accountId AND (ips_End_Date__c = LAST_N_DAYS:365 OR ips_End_Date__c =NULL)
                ORDER BY CreatedDate DESC 
                LIMIT 1];
            
            return mytrail;
    }

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