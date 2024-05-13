public without sharing class IPS_ManagerTrailController {


    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall jobbspor pr status, not ended and referred*/
    public static List<IPS_ManagerTrail> getAggregatedTrailStatus(){
        List<IPS_ManagerTrail> trailStatuses = new List<IPS_ManagerTrail>();
         List<AggregateResult> aggList = new List<AggregateResult>();
        
        aggList =[SELECT count(id)Antall, toLabel(ips_Status__c) Status,recordtype.name Tjeneste
                  FROM work_trail__c 
                  WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() AND ips_status__c NOT IN('Ended','Referred')
                  GROUP BY ips_status__c,recordtype.name
                  ORDER BY recordtype.name];
        
        if(aggList.size()>0){
            for(AggregateResult agg : aggList){
                IPS_ManagerTrail trailStatus = new IPS_ManagerTrail();
                trailStatus.numberOfTrail = (Integer)agg.get('Antall');
                trailStatus.trailStatus = (String)agg.get('Status');
                trailStatus.service = (String)agg.get('Tjeneste');
                trailStatuses.add(trailStatus);
        	}
            return trailStatuses;
        }else{
            return null;
        }  
    }

    /* Aggregerte data - referred/ended pr service*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerTrail> getReferredTrails(){
        List<IPS_ManagerTrail> trailReferreds = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList =[SELECT count(id)Antall,toLabel(ips_status__c)Status,recordtype.name Tjeneste,End_Cause__c Cause
                  FROM work_trail__c 
                  WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() AND ips_status__c IN('Ended','Referred')
                  GROUP BY ips_status__c,recordtype.name,End_Cause__c
                  ORDER BY recordtype.name];

        if(aggList.size()>0){
            for(AggregateResult agg : aggList){
                IPS_ManagerTrail trailReferred = new IPS_ManagerTrail();
                trailReferred.numberOfTrail = (Integer)agg.get('Antall');
                trailReferred.trailStatus =(String)agg.get('Status');
                trailReferred.service = (String)agg.get('Tjeneste');
                trailReferred.cause =(String)agg.get('Cause');
                trailReferreds.add(trailReferred);
        	}
            return trailReferreds;
        }else {
            return null;
        } 
    }
    
    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall sluttet pr år og måned */
    public static List<IPS_ManagerTrail> getAggregatedEndedTrail(){
        List<IPS_ManagerTrail> trailEnds = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();
        
        aggList = [SELECT 
                    count(id)Antall, 
                    CALENDAR_YEAR(ips_End_Date__c)Year, 
                    CALENDAR_MONTH(ips_End_Date__c)Month,
                    toLabel(End_Cause__c) Cause,
                    toLabel(ips_Work__c ) toWork,
                    toLabel(ips_Other_end_cases__c) toAnother
                   FROM work_trail__c 
                   WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() AND ips_Status__c='Ended' 
                   GROUP BY CALENDAR_YEAR(ips_End_Date__c),CALENDAR_MONTH(ips_End_Date__c),End_Cause__c,ips_Work__c,ips_Other_end_cases__c
                   ORDER BY CALENDAR_YEAR(ips_End_Date__c)
                  ];
        
        if(aggList.size()>0){
            for(AggregateResult agg:aggList){
                IPS_ManagerTrail trailEnded = new IPS_ManagerTrail();
                trailEnded.numberOfTrail = (Integer)agg.get('Antall');
                trailEnded.year = (Integer)agg.get('Year');
                trailEnded.month = convertMonthNumberToString((Integer)agg.get('Month'));
                trailEnded.cause = (String)agg.get('Cause');
                trailEnded.subCause = getSubCause((String)agg.get('toWork'),(String)agg.get('toAnother'));
                trailEnds.add(trailEnded);
            }
        }
        return trailEnds;
    }

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall jobbspor pr jobbspesialist */
    public static List<IPS_ManagerTrail> getAggregatedTrailJobbspesialist(){
        List<IPS_ManagerTrail> trailOwners = new List<IPS_ManagerTrail>();
         List<AggregateResult> aggList = new List<AggregateResult>();
        
        aggList =[SELECT count(id)Antall, owner.name OwnerName
                  FROM work_trail__c 
                  WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() AND ips_status__c NOT IN('Ended','Referred')
                  GROUP BY owner.name];

        
        if(aggList.size()>0){
            for(AggregateResult agg : aggList){
                IPS_ManagerTrail trailOwner = new IPS_ManagerTrail();
                trailOwner.numberOfTrail = (Integer)agg.get('Antall');
            	trailOwner.employeeName = (String)agg.get('OwnerName');
                trailOwners.add(trailOwner);
        	}
            return trailOwners;
        }else{
            return null;
        }
        
    }

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall i opplæringsløp UO */
    public static List<IPS_ManagerTrail> getUOTraining(){
        List<IPS_ManagerTrail> trainingUO = new List<IPS_ManagerTrail>();
         List<AggregateResult> aggList = new List<AggregateResult>();
        
        aggList =[SELECT count(id)Antall
                  FROM work_trail__c 
                  WHERE OwnerId in: IPS_Utility.getMyEmployeesUserId() AND ips_UO_Service__c='UO Training' AND ips_status__c NOT IN('Ended','Referred')];

        
        if(aggList.size()>0){
            for(AggregateResult agg : aggList){
                IPS_ManagerTrail trailUO = new IPS_ManagerTrail();
                trailUO.numberOfTrail = (Integer)agg.get('Antall');
                trainingUO.add(trailUO);
        	}
            return trainingUO;
        }else{
            return null;
        }
        
    }

    public static String getSubCause(String work,String another){

        if(!String.isBlank(work)){
            return work;
        }else if (!String.isBlank(another)) {
            return another;
        }else {
            return null;
        }
    }
    
    public static String convertMonthNumberToString(Integer month){
    	if(month == 1){
            return 'Januar';   
        }else if(month == 2){
            return 'Februar';   
        }else if(month == 3){
            return 'Mars';   
        }else if(month == 4){
            return 'April';   
        }else if(month == 5){
            return 'Mai';       
        }else if(month == 6){            
            return 'Juni';   
        }else if(month == 7){
            return 'Juli';   
        }else if(month == 8){
            return 'August';   
        }else if(month == 9){
            return 'September';   
        }else if(month == 10){
            return 'Oktober';  
        }else if(month == 11){
            return 'November';  
        }else{
            return 'Desember';
        }
    }

    public static String convertStatus(string status){
        if(status=='Referred'){
            return 'Henvist';
        }else if(status=='Career mapping and career planning'){
            return 'Yrkeskartlegging og karriereplanlegging';

        }else if(status=='Education and training in and/ or outside the workplace'){
            return 'Opplæring og trening på og/eller utenom arbeidsplassen';

        }else if(status=='Ended'){
            return 'Sluttet';

        }else if(status=='Find a suitable job/ Collaborate with AG'){
            return 'Finne en passende jobb/samarbeid med arbeidsgiver';
        }else if(status=='In Education'){
            return 'I utdannelse';
            
        }else if(status=='Initial contact'){
            return 'Jobbutvikling';
            
        }else if(status=='Mapping'){
            return 'Kartlegging';
            
        }else if(status=='Passive'){
            return 'Nedtrapping';
            
        }else if(status=='Working'){
            return 'Jobber';
            
        }else if(status=='Job development'){
            return 'Jobbutvikling';
        
        }else if(status=='Downsizing'){
            return 'Nedtrapping';
            
        }else{
            return 'Ingen status';
        }
    }
    

}