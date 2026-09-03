/**
 * @description  : Controller class for managing aggregated Job data for managers, used on the "Jobbsporet Lederbrett".
 * @author       : Balendra Sounthararajan
 **/
public without sharing class IPS_ManagerJobController {
    private static Boolean hasAccess = IPS_Utility.checkIfUserHasLeaderboardAccess(UserInfo.getUserId());
    private static final List<String> CONTRACT_WORK = new List<String>{
        'Freelance / self-employed',
        'Permanent employment',
        'Temporary employment',
        'Zero hours contrac'
    };

    /* Aggregated data - number of ongoing paid jobs per employment type, for employees reporting to the manager */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerJob> totalJobsByCategory() {
        try {
            List<IPS_ManagerJob> jobCategoryList = new List<IPS_ManagerJob>();
            List<AggregateResult> aggList = new List<AggregateResult>();

            // Check if the current user has access to the leaderboard. If not, return empty list.
            if (!hasAccess) {
                return jobCategoryList;
            }

            aggList = [
                SELECT Count(Id) Antall, toLabel(ips_Form_of_Employment__c) Ansettelsesform
                FROM ips_Job__c
                WHERE
                    ips_status__c = 'Ongoing'
                    AND ips_Form_of_Employment__c IN :CONTRACT_WORK
                    AND ips_Work_Trail__r.OwnerId IN :IPS_Utility.getMyEmployeesUserId()
                WITH SYSTEM_MODE
                GROUP BY ips_form_of_employment__c
            ];

            if (aggList.size() > 0) {
                for (AggregateResult agg : aggList) {
                    IPS_ManagerJob jobCategory = new IPS_ManagerJob();
                    jobCategory.totalNumber = (Integer) agg.get('Antall');
                    jobCategory.typeOfEmployment = (String) agg.get('Ansettelsesform');

                    jobCategoryList.add(jobCategory);
                }
            }
            return jobCategoryList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Aggregated data - number of ongoing work trainings, for employees reporting to the manager */
    @AuraEnabled(cacheable=true)
    public static List<IPS_ManagerJob> totalJobTraining() {
        try {
            List<IPS_ManagerJob> jobTrainingList = new List<IPS_ManagerJob>();
            List<AggregateResult> aggList = new List<AggregateResult>();

            // Check if the current user has access to the leaderboard. If not, return empty list.
            if (!hasAccess) {
                return jobTrainingList;
            }

            aggList = [
                SELECT Count(Id) Antall
                FROM ips_Job__c
                WHERE
                    ips_status__c = 'Ongoing'
                    AND ips_Form_of_Employment__c = 'work training'
                    AND ips_Work_Trail__r.OwnerId IN :IPS_Utility.getMyEmployeesUserId()
                WITH SYSTEM_MODE
            ];

            if (aggList.size() > 0) {
                for (AggregateResult agg : aggList) {
                    IPS_ManagerJob jobTraining = new IPS_ManagerJob();
                    jobTraining.totalNumber = (Integer) agg.get('Antall');

                    jobTrainingList.add(jobTraining);
                }
            }
            return jobTrainingList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
