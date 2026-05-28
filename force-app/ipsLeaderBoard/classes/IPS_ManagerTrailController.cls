/**
 * @description  : Controller class for managing aggregated Work Trail data for managers in IPS.
 * @author       : Ann Kristin Olsen, Balendra Sounthararajan
 * @author       : Håkon Kavli
 * @since        : 0.533.0
 **/
public without sharing class IPS_ManagerTrailController {
    private static final List<String> ACTIVE_STATUSES = new List<String>{
        'Initial contact',
        'Mapping',
        'Job development',
        'In Education',
        'Working',
        'Downsizing',
        'Career mapping and career planning',
        'Find a suitable job / Collaborate with AG',
        'Education and training in and / or outside the workplace'
    };

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall jobbspor pr status, active statuses only */
    public static List<IPS_ManagerTrail> getAggregatedTrailStatus() {
        List<IPS_ManagerTrail> trailStatuses = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList = [
            SELECT COUNT(Id) Antall, toLabel(ips_Status__c) Status, RecordType.Name Tjeneste
            FROM Work_Trail__c
            WHERE OwnerId IN :IPS_Utility.getMyEmployeesUserId() AND ips_Status__c IN :ACTIVE_STATUSES
            GROUP BY ips_Status__c, RecordType.Name
            ORDER BY RecordType.Name
        ];

        if (aggList.size() > 0) {
            for (AggregateResult agg : aggList) {
                IPS_ManagerTrail trailStatus = new IPS_ManagerTrail();
                trailStatus.numberOfTrail = (Integer) agg.get('Antall');
                trailStatus.trailStatus = statusMap.get((String) agg.get('Status')) ?? 'Ukjent status';
                trailStatus.service = (String) agg.get('Tjeneste');
                trailStatuses.add(trailStatus);
            }
            return trailStatuses;
        } else {
            return null;
        }
    }

    /* Aggregerte data - referred/ended pr service*/
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerTrail> getReferredTrails() {
        List<IPS_ManagerTrail> trailReferreds = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList = [
            SELECT COUNT(Id) Antall, toLabel(ips_status__c) Status, RecordType.Name Tjeneste, End_Cause__c Cause
            FROM Work_Trail__c
            WHERE OwnerId IN :IPS_Utility.getMyEmployeesUserId() AND ips_status__c IN ('Ended', 'Referred')
            GROUP BY ips_status__c, RecordType.Name, End_Cause__c
            ORDER BY RecordType.Name
        ];

        if (aggList.size() > 0) {
            for (AggregateResult agg : aggList) {
                IPS_ManagerTrail trailReferred = new IPS_ManagerTrail();
                trailReferred.numberOfTrail = (Integer) agg.get('Antall');
                trailReferred.trailStatus = (String) agg.get('Status');
                trailReferred.service = (String) agg.get('Tjeneste');
                trailReferred.cause = (String) agg.get('Cause');
                trailReferreds.add(trailReferred);
            }
            return trailReferreds;
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall sluttet pr år og måned */
    public static List<IPS_ManagerTrail> getAggregatedEndedTrail() {
        List<IPS_ManagerTrail> trailEnds = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList = [
            SELECT
                COUNT(Id) Antall,
                CALENDAR_YEAR(ips_End_Date__c) Year,
                CALENDAR_MONTH(ips_End_Date__c) Month,
                toLabel(End_Cause__c) Cause,
                toLabel(ips_Other_end_cases__c) toAnother
            FROM Work_Trail__c
            WHERE OwnerId IN :IPS_Utility.getMyEmployeesUserId() AND ips_Status__c = 'Ended'
            GROUP BY
                CALENDAR_YEAR(ips_End_Date__c),
                CALENDAR_MONTH(ips_End_Date__c),
                End_Cause__c,
                ips_Other_end_cases__c
            ORDER BY CALENDAR_YEAR(ips_End_Date__c)
        ];

        if (aggList.size() > 0) {
            for (AggregateResult agg : aggList) {
                IPS_ManagerTrail trailEnded = new IPS_ManagerTrail();
                trailEnded.numberOfTrail = (Integer) agg.get('Antall');
                trailEnded.year = (Integer) agg.get('Year');
                trailEnded.month = monthNumberMap.get((Integer) agg.get('Month'));
                trailEnded.cause = mainEndCauseMap.get((String) agg.get('Cause')) ?? 'Ukjent årsak';
                trailEnded.subCause = subEndCauseMap.get((String) agg.get('toAnother')) ?? 'Ukjent underkategori';
                trailEnds.add(trailEnded);
            }
        }
        return trailEnds;
    }

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall jobbspor pr jobbspesialist */
    public static List<IPS_ManagerTrail> getAggregatedTrailJobbspesialist() {
        List<IPS_ManagerTrail> trailOwners = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList = [
            SELECT COUNT(Id) Antall, Owner.Name OwnerName
            FROM Work_Trail__c
            WHERE OwnerId IN :IPS_Utility.getMyEmployeesUserId() AND ips_Status__c IN :ACTIVE_STATUSES
            GROUP BY Owner.Name
        ];

        if (aggList.size() > 0) {
            for (AggregateResult agg : aggList) {
                IPS_ManagerTrail trailOwner = new IPS_ManagerTrail();
                trailOwner.numberOfTrail = (Integer) agg.get('Antall');
                trailOwner.employeeName = (String) agg.get('OwnerName');
                trailOwners.add(trailOwner);
            }
            return trailOwners;
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    /* Aggregerte data - antall i opplæringsløp UO */
    public static List<IPS_ManagerTrail> getUOTraining() {
        List<IPS_ManagerTrail> trainingUO = new List<IPS_ManagerTrail>();
        List<AggregateResult> aggList = new List<AggregateResult>();

        aggList = [
            SELECT COUNT(Id) Antall
            FROM Work_Trail__c
            WHERE
                OwnerId IN :IPS_Utility.getMyEmployeesUserId()
                AND ips_UO_Service__c = 'UO Training'
                AND ips_Status__c IN :ACTIVE_STATUSES
        ];

        if (aggList.size() > 0) {
            for (AggregateResult agg : aggList) {
                IPS_ManagerTrail trailUO = new IPS_ManagerTrail();
                trailUO.numberOfTrail = (Integer) agg.get('Antall');
                trainingUO.add(trailUO);
            }
            return trainingUO;
        } else {
            return null;
        }
    }

    public static String getSubCause(String another) {
        if (!String.isBlank(another)) {
            return another;
        } else {
            return null;
        }
    }

    public static Map<Integer, String> monthNumberMap = new Map<Integer, String>{
        1 => 'Januar',
        2 => 'Februar',
        3 => 'Mars',
        4 => 'April',
        5 => 'Mai',
        6 => 'Juni',
        7 => 'Juli',
        8 => 'August',
        9 => 'September',
        10 => 'Oktober',
        11 => 'November',
        12 => 'Desember'
    };

    public static Map<String, String> statusMap = new Map<String, String>{
        'Referred' => 'Henvist',
        'Career mapping and career planning' => 'Yrkeskartlegging og karriereplanlegging',
        'Education and training in and/ or outside the workplace' => 'Opplæring og trening på og/eller utenom arbeidsplassen',
        'Ended' => 'Sluttet',
        'Find a suitable job/ Collaborate with AG' => 'Finne en passende jobb/samarbeid med arbeidsgiver',
        'In Education' => 'I utdannelse',
        'Initial contact' => 'Innledende kontakt',
        'Mapping' => 'Kartlegging',
        'Passive' => 'Nedtrapping',
        'Working' => 'Jobber',
        'Job development' => 'Jobbutvikling',
        'Downsizing' => 'Nedtrapping'
    };

    public static Map<String, String> mainEndCauseMap = new Map<String, String>{
        'Work' => 'Arbeid',
        'Other end causes' => 'Andre sluttårsaker',
        'Education' => 'Utdanning'
    };
    public static Map<String, String> subEndCauseMap = new Map<String, String>{
        'Applied / granted disability benefits' => 'Søkt/innvilget uføretrygd',
        'Applied for / granted old age pension / AFP' => 'Søkt/innvilget alderspensjon/AFP',
        'Chaining for other work-oriented measures under the auspices of NAV' => 'Kjeding til andre arbeidsrettede tiltak i regi av NAV',
        'Education - covered by NAV' => 'Utdanning - dekket av NAV',
        'Illness' => 'Sykdom',
        'Not applicable' => 'Ikke aktuell',
        'Other (military, pregnancy, relocation, etc.)' => 'Annet (militær, svangerskap, flytting mm)',
        'Other active measures in consultation with NAV (eg medical treatment, or municipal measures)' => 'Andre aktive tiltak i samråd med NAV (eks medisinsk behandling eller kommunale tiltak)',
        'Work in combination with a graduated disability pension' => 'Arbeid i kombinasjon med gradert uførepensjon',
        'Work in combination with other benefits from NAV' => 'Arbeid i kombinasjon med andre ytelser fra NAV',
        'Work with wage subsidies from NAV' => 'Arbeid med lønnstilskudd fra NAV',
        'Work without wage subsidy' => 'Arbeid uten lønnstilskudd',
        '' => 'Ukjent underkategori'
    };
}
