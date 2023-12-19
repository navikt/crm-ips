public with sharing class IPS_CVController {

    @AuraEnabled(cacheable=true)
    public static CV getCV(String fodselsnummer) {
        if (String.isBlank(fodselsnummer)) {
            String errorRef = logError('Feil fra getCV()-funksjonen!');

            throw new CVException('Kunne ikke hente CV.' + errorRef);
        }
        HttpResponse response = CV_Service.getCV(fodselsnummer);

        if (response.getStatusCode() == 200) {
            CV enCV = (true == String.isNotBlank(response.getBody()))
                ? (CV) JSON.deserialize(response.getBody().replaceAll('\n', '\\\\r\\\\n'), CV.class)
                : null;

            return enCV != null ? enCV : null;
        } else if (response.getStatusCode() == 404) {
            throw new CVException('Ingen CV');
        }

        String errorRef = logError(response, 'Feil fra getCV()-funksjonen!');
        throw new CVException('Kunne ikke hente CV.' + errorRef);
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