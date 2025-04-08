@isTest
public with sharing class IPS_TextSplitterTest {
    public static String generateLongTest(Integer length) {
        String longText = '';
        for (Integer i = 0; i < length; i++) {
            longText += 'A';
        }
        return longText;
    }

    @isTest
    public static void splitTextTest() {
        // Test with a short input string
        IPS_TextSplitter.InputVariables input = new IPS_TextSplitter.InputVariables();
        input.textToSplit = new List<String>{ generateLongTest(50000) };
        List<IPS_TextSplitter.InputVariables> inputList = new List<IPS_TextSplitter.InputVariables>{ input };

        List<IPS_TextSplitter.OutputVariables> result = IPS_TextSplitter.splitText(inputList);

        Assert.areEqual(1, result[0].textToSend.size());
    }

    @isTest
    public static void splitTextWithLargeInputTest() {
        // Test with a large input string
        IPS_TextSplitter.InputVariables input = new IPS_TextSplitter.InputVariables();
        input.textToSplit = new List<String>{ generateLongTest(95000) };
        List<IPS_TextSplitter.InputVariables> inputList = new List<IPS_TextSplitter.InputVariables>{ input };

        List<IPS_TextSplitter.OutputVariables> result = IPS_TextSplitter.splitText(inputList);
        Assert.areEqual(2, result[0].textToSend.size());
    }
}
