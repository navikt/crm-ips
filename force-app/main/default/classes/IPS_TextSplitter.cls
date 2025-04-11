/**
 * @description       : It takes a long text string, splits into smaller chunks
 * @author            : Balendra
 * @last modified on  : 10-04-2025
 * @last modified by  : Balendra
 */
public inherited sharing class IPS_TextSplitter {
    @InvocableMethod(label='Split text' description='Splits long text')
    public static List<OutputVariables> splitText(List<InputVariables> inputVariables) {
        final Integer MAX_LENGTH = 90000;
        List<OutputVariables> outputList = new List<OutputVariables>();

        for (InputVariables input : inputVariables) {
            List<String> splittedText = new List<String>();

            if (input != null && input.textToSplit != null) {
                for (String ts : input.textToSplit) {
                    if (ts != null) {
                        Integer start = 0;
                        while (start < ts.length()) {
                            Integer endd = Math.min(start + MAX_LENGTH, ts.length());
                            splittedText.add(ts.substring(start, endd));
                            start = endd;
                        }
                    }
                }
            }

            OutputVariables output = new OutputVariables();
            output.textToSend = splittedText;
            outputList.add(output);
        }

        return outputList;
    }

    /**
     * Wrapper class used for Flow input.
     * Allows Flow to pass in a collection of text strings to be split.
     */
    public class InputVariables {
        @InvocableVariable
        public List<String> textToSplit;
    }

    /**
     * Wrapper class used for Flow output.
     * Contains a list of strings representing the split text chunks.
     */
    public class OutputVariables {
        @InvocableVariable
        public List<String> textToSend;
    }
}
