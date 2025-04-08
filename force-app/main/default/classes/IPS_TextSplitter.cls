/**
 * @description       : It takes a long text string, splits into smaller chunks
 * @author            : Balendra
 * @last modified on  : 07-04-2025
 * @last modified by  : Balendra
 */
public inherited sharing class IPS_TextSplitter {
    @InvocableMethod(label='Split text' description='Splits long text')
    public static List<OutputVariables> splitText(List<InputVariables> inputVariables) {
        List<String> textToSplit = inputVariables.get(0).textToSplit;
        //Limited to 90,000 characters to support safe Base64 encoding within the 131072-character field limit.
        final Integer MAX_LENGTH = 90000;
        List<String> splittedText = new List<String>();

        for (String ts : textToSplit) {
            Integer start = 0;
            while (start < ts.length()) {
                Integer endOfGivenText = Math.min(start + MAX_LENGTH, ts.length());
                splittedText.add(ts.substring(start, endOfGivenText));
                start = endOfGivenText;
            }
        }
        OutputVariables output = new OutputVariables();
        output.textToSend = splittedText;

        return new List<OutputVariables>{ output };
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
