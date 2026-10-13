public with sharing class IPS_SplitSelectedValues {
    public class Request {
        @InvocableVariable(label='Selected Values')
        public String selectedValues;
    }

    public class Result {
        @InvocableVariable(label='Values Collection')
        public List<String> values;
    }

    @InvocableMethod(
        label='Split Selected Values'
        description='Converts semicolon-separated selections into a text collection.'
    )
    public static List<Result> splitValues(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request request : requests) {
            Result result = new Result();
            result.values = new List<String>();

            if (request != null && String.isNotBlank(request.selectedValues)) {
                for (String value : request.selectedValues.split(';')) {
                    if (String.isNotBlank(value)) {
                        result.values.add(value);
                    }
                }
            }

            results.add(result);
        }

        return results;
    }
}