/**
 * @description  :Oppretter ips_Team_Member__c-oppføringer for aktive brukere
 *                 med IPS/UO-profiler, koblet til riktig team via UserRole.Name
 *                 og riktig rolle via Profile.Name.
 *
 *                 Brukere med en rolle som starter med "Fagansvarlig" (f.eks.
 *                 "Fagansvarlig Nittedal IPS/AMS") blir i tillegg lagt til som
 *                 team member med rollen "Fagansvarlig" på alle team som ligger
 *                 under Fagansvarlig-rollen i rollehierarkiet. F.eks. skal en
 *                 bruker med rollen "Fagansvarlig Nittedal IPS/AMS" legges til
 *                 i både "AMS Nittedal"- og "IPS Nittedal"-teamet, siden rollene
 *                 "AMS Nittedal Jobbspesialist"/"Metodeveileder" og
 *                 "IPS Nittedal Jobbspesialist"/"Metodeveileder" ligger under
 *                 Fagansvarlig-rollen i hierarkiet.
 *
 *                 Forutsetninger:
 *                   - UserRole.Name samsvarer med ips_Team__c.Name (f.eks. "IPS Ålesund"),
 *                     eventuelt med suffiksene " Jobbspesialist"/" Metodeveileder" fjernet
 *                   - Teams er allerede opprettet i org
 * @author       : Håkon Kavli
 * @since        : 0.566.0
 * @version      : 0.566.0
 **/
public with sharing class IPS_CreateTeamMembers implements Database.Batchable<SObject> {
    public static Integer usersProcessed = 0;
    public static Integer teamMembersCreated = 0;
    public static final Integer BATCH_SIZE = 150;

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Name, CRM_NAV_Ident__c, UserRoleId, UserRole.Name, Profile.Name, CreatedDate
                FROM User
                WHERE
                    IsActive = TRUE
                    AND Profile.Name IN :TARGET_PROFILES
                    AND UserRoleId != NULL
                    AND CRM_NAV_Ident__c != NULL
                WITH SYSTEM_MODE
                ORDER BY UserRoleId
            ]
        );
    }

    public void execute(Database.BatchableContext context, List<User> scope) {
        usersProcessed += scope.size();
        try {
            upsert IPS_CreateTeamMembersHelper.createTeamMembers(
                (List<User>) scope,
                ips_Team_Member__c.ips_Unique_User_Key__c,
                false
            );
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.error(
                'Error processing IPS_CreateTeamMembers batch: ' + e.getMessage(),
                CRM_ApplicationDomain.Domain.IPS
            );
            logger.publishSynch();
        }
    }

    public void finish(Database.BatchableContext context) {
        // Log completion of batch job
        LoggerUtility logger = new LoggerUtility();
        logger.info(
            'IPS_CreateTeamMembers job completed. Users processed: ' +
                usersProcessed +
                ', Team members created: ' +
                teamMembersCreated,
            CRM_ApplicationDomain.Domain.IPS
        );
        logger.publishSynch();
    }
}
