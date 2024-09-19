/**
 * @description Getting CV data using CV_Service class
 */
public with sharing class IPS_CVController {
    /**
     * @description Returns a CV for a participant
     * @param recordId fnr of participant
     * @return CV
     */
    @AuraEnabled(cacheable=true)
    public static CV getCV(String recordId) {
        try {
            String fodselsnummer = [SELECT IPS_Personnummer__c FROM Work_Trail__c WHERE id = :recordId]
            ?.IPS_Personnummer__c;

            if (String.isBlank(fodselsnummer)) {
                String errorRef = logError('Henting av CV feilet: fnr mangler eller er ugyldig.');
                throw new CVException('Henting av CV feilet: fnr mangler eller er ugyldig. Feilreferanse: ' + errorRef);
            }
            // Using the following class to access the API
            // https://github.com/navikt/crm-platform-integration/blob/main/force-app/cv/classes/CV_Service.cls
            HttpResponse response = CV_Service.getCV(fodselsnummer);
            if (response.getStatusCode() == 200) {
                CV enCV = (true == String.isNotBlank(response.getBody()))
                    ? (CV) JSON.deserialize(response.getBody().replaceAll('\n', '\\\\r\\\\n'), CV.class)
                    : null;
                return enCV != null ? enCV : null;
            } else {
                String errorRef = logError(response, ' Feil fra getCV()-funksjonen!');
                throw new CVException('Henting av CV feilet. Feilreferanse: ' + errorRef);
            }
        } catch (Exception e) {
            throw new CVException(e.getMessage());
        }
    }

    private static String logError(HttpResponse resp, String message) {
        String errorRef = '';
        LoggerUtility logger = new LoggerUtility();
        logger.httpError(message, resp, null, null);
        errorRef = logger.peek().UUID__c;
        logger.publish();
        return errorRef;
    }

    private static String logError(String message) {
        String errorRef = '';
        LoggerUtility logger = new LoggerUtility();
        logger.error(message, null, null);
        errorRef = logger.peek().UUID__c;
        logger.publish();
        return errorRef;
    }

    private class CVException extends Exception {
    }
}
