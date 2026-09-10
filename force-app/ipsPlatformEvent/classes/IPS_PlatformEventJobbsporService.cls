public without sharing class IPS_PlatformEventJobbsporService {
    public static void getWorkTrailToPlatformEvent(List<Work_Trail__c> trailList){
        
        Set<Id> workTrailIdSet = new Set<Id>();
        for (Work_Trail__c trail : trailList) {
            workTrailIdSet.add(trail.Id);
        }
        
        List<IPSJobbsporEvent__e> eventJobbsporList = new List<IPSJobbsporEvent__e>();
        
        List<Work_Trail__c> workTrailList = [
                SELECT 
            		id,
            		OwnerId,
            		ips_Applying_Department__c,
            		ips_Behandlingsteam__c,
            		CreatedDate,
            		ips_End_Date__c,
            		toLabel(End_Cause__c),
            		toLabel(ips_Other_end_cases__c),
            		ips_First_meeting_with_the_Employer_held__c,
            		recordtype.developername,
            		toLabel(ips_Status__c),
            		Passive_activate__c,
            		Passive_deactivate__c,
            		ips_Referred_date__c,
            		IPS_Personnummer__c,
            		toLabel(ips_Main_Goal_list__c),
            		toLabel(ips_UO_Service__c),
            		Oppstartsdato__c 
            FROM Work_trail__c
            WHERE Id IN :workTrailIdSet
        ];
        
        for(Work_Trail__c t:workTrailList){
            IPSJobbsporEvent__e eventJobbspor = new IPSJobbsporEvent__e();
            eventJobbspor.JobbsporId__c =hashString(t.Id);
            eventJobbspor.UserId__c = hashString(t.OwnerId);
            eventJobbspor.JobbsporCreated__c = Date.valueOf(t.CreatedDate);
            eventJobbspor.JobbsporEndDate__c = t.ips_End_Date__c;
            eventJobbspor.JobbsporEndReason__c = formatEndCause(t.End_Cause__c);
            eventJobbspor.JobbsporEndReasonDetail__c = formatEndCauseDetail(t.ips_Other_end_cases__c);
            eventJobbspor.JobbsporFirstEmployeeMeeting__c = Date.valueOf(t.ips_First_meeting_with_the_Employer_held__c);
            eventJobbspor.JobbsporStatus__c = formatStatus(t.ips_Status__c);
            eventJobbspor.ParticipantPassiveDateActivated__c = t.Passive_activate__c;
            eventJobbspor.ParticipantPassiveDateDeactivated__c = t.Passive_deactivate__c;
            eventJobbspor.ParticipantReferredDate__c = t.ips_Referred_date__c;
            eventJobbspor.ParticipantSCN__c = t.IPS_Personnummer__c;
            eventJobbspor.ParticipantStartDate__c = Date.valueOf(t.Oppstartsdato__c);
            if(t.recordtype.developername =='ips_Supported_Employment'){
                eventJobbspor.JobbsporApplyingDepartment__c =t.ips_Applying_Department__c;
                eventJobbspor.JobbsporService__c = 'AMS';
                eventJobbspor.ParticipantsMainGoal__c = formatMainGoal(t.ips_UO_Service__c);
            }
            if(t.recordtype.developername == 'IPS'){
                eventJobbspor.JobbsporApplyingDepartment__c =t.ips_Behandlingsteam__c;
                eventJobbspor.JobbsporService__c = 'IPS';
                eventJobbspor.ParticipantsMainGoal__c =formatMainGoal(t.ips_Main_Goal_list__c);
            }
            
            eventJobbsporList.add(eventJobbspor);
            
        }
       List<Database.SaveResult> results = EventBus.publish(eventJobbsporList);
       
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    String errormessage = 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage();
                    System.debug(errormessage);
                }
            }       
    	}
	}
    
    public static Integer getMinutesIncludingLastDay20Hours() {
        
        Date inputDate = Date.today() ;
        // Get the first day of the next month
        Date firstDayOfNextMonth = inputDate.toStartOfMonth().addMonths(1);
        // Subtract one day to get the last day of the current month
        Date lastDateOfMonth = firstDayOfNextMonth.addDays(-1);
        
       //Integer totalDaysInBetween = lastDateOfMonth.day()-inputDate.day();
       Integer totalDaysInBetween = firstDayOfNextMonth.day()-inputDate.day();
 	   Integer totalMinutesIn = totalDaysInBetween * 1440;        

        Integer additionalMinutes = 12 * 60;

        // Return the total minutes including the additional 20 hours
        return totalMinutesIn - additionalMinutes;
    }
    
    
    
    Private static String hashString(String inputString){
            Blob inputBlob = Blob.valueOf(inputString);
            Blob hashedBlob = Crypto.generateDigest('SHA-256', inputBlob);
            String hashedString = EncodingUtil.convertToHex(hashedBlob);
        return hashedString;
    }
    
    Private static String formatStatus(String inputString){
        String outputString;
     	switch on inputString {
                            when 'Referred' {outputString = 'Henvist'; }
                            when 'Initial contact' {outputString = 'Innledende kontakt'; }
                            when 'Mapping' {outputString = 'Kartlegging'; }
                            when 'Job development' {outputString = 'Jobbutvikling'; }
                            when 'In Education' {outputString = 'I utdannelse'; }
                            when 'Working' {outputString = 'Jobber'; }
                            when 'Downsizing' {outputString = 'Nedtrapping'; }
                            when 'Career mapping and career planning' {outputString = 'Yrkeskartlegging og karriereplanlegging'; }
                            when 'Find a suitable job / Collaborate with AG' {outputString = 'Finne en passende jobb / samarbeid med arb.g'; }
                            when 'Education and training in and / or outside the workplace' {outputString = 'Opplæring og trening på og/eller utenom arbeidsplassen'; }
                            when 'Information and decision support' {outputString = 'Informasjon og beslutningsstøtte'; }
                            when 'Discovery' {outputString = 'Utforske muligheter'; }
                            when 'Job development CE' {outputString = 'Tilpasset jobbutvikling'; }
                            when 'Adapted training and training in the workplace' {outputString = 'Tilpasset opplæring og trening på arbeidsplassen'; }
                            when 'Long-term available follow-up and career development' {outputString = 'Langvarig tilgjengelig oppfølging og karriereutvikling'; }
                            when 'Ended' {outputString = 'Sluttet'; }
                            when else {outputString = 'Ukjent status'; }
                        }
        return outputString;
    }
        
    Private static String formatMainGoal(String inputString){
        String outputString;
        	switch on inputString {
                            when 'Work' {outputString = 'Arbeid'; }
                            when 'Education/Apprentice' {outputString = 'Utdanning'; }
                            when 'AMS' {outputString = 'Arbeid'; }
                            when 'Vocational education and training' {outputString = 'Arbeid via fag- og yrkesopplæring'; }
                            when else {outputString = 'Ukjent hovedmål'; }
                        }
        
        return outputString;
    }
    
    Private static String formatEndCause(String inputString){
       String outputString;
        switch on inputString {
                            when 'Education' {outputString = 'Utdanning'; }
                            when 'Other end causes' {outputString = 'Andre sluttårsaker'; }
                            when 'Work' {outputString = 'Arbeid'; }
                            when else {outputString = 'Ukjent avslutningsårsak'; }
                        }
        
       return outputString;
    }
    
    Private static String formatEndCauseDetail(String inputString){
        String outputString;
        switch on inputString {
                            when 'Education - self-financed' {outputString = 'Utdanning - egenfinansiert'; }
                            when 'Education - covered by NAV' {outputString = 'Utdanning - dekket av NAV'; }
                            when 'Chaining for other work-oriented measures under the auspices of NAV' {outputString = 'Kjeding til andre arbeidsrettede tiltak i regi av NAV'; }
                            when 'Other active measures in consultation with NAV (eg medical treatment, or municipal measures)' {outputString = 'Andre aktive tiltak i samråd med NAV (eks medisinsk behandling eller kommunale tiltak)'; }
                            when 'Illness' {outputString = 'Sykdom'; }
                            when 'Applied for / granted old age pension / AFP' {outputString = 'Søkt/innvilget alderspensjon/AFP'; }
                            when 'Applied / granted disability benefits' {outputString = 'Søkt/innvilget uføretrygd'; }
                            when 'Other (military, pregnancy, relocation, etc.)' {outputString = 'Annet (militær, svangerskap, flytting mm)'; }
                            when 'Work without wage subsidy' {outputString = 'Arbeid uten lønnstilskudd'; }
                            when 'Work with wage subsidies from NAV' {outputString = 'Arbeid med lønnstilskudd fra NAV'; }
                            when 'Work in combination with other benefits from NAV / granted disability benefits' {outputString = 'Arbeid i kombinasjon med andre ytelser fra NAV'; }
                            when 'Work in combination with a graduated disability pension (military, pregnancy, relocation, etc.)' {outputString = 'Arbeid i kombinasjon med gradert uførepensjon'; }
                            when 'Not applicable' {outputString = 'Ikke aktuell'; }
                            when else {outputString = 'Ukjent avslutningsdetaljårsak'; }
                        }
        
        return outputString;
    }
}