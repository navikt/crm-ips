@isTest
public class IPS_UtilityFlowTranslateControllerTest {
    
    @isTest
    static void testTranslateString() {
        // Test data setup
        List<IPS_UtilityFlowTranslateController.Input> inputs = new List<IPS_UtilityFlowTranslateController.Input>();

        // Add test cases for MAINGOAL
        inputs.add(createInput('Work', 'MAINGOAL'));
        inputs.add(createInput('Education/Apprentice', 'MAINGOAL'));
        inputs.add(createInput('Unknown', 'MAINGOAL'));

        // Add test cases for STATUS
        inputs.add(createInput('Referred', 'STATUS'));
        inputs.add(createInput('Initial contact', 'STATUS'));
        inputs.add(createInput('Unknown', 'STATUS'));

        // Add test cases for ENDCAUSE
        inputs.add(createInput('Education', 'ENDCAUSE'));
        inputs.add(createInput('Other end causes', 'ENDCAUSE'));
        inputs.add(createInput('Unknown', 'ENDCAUSE'));

        // Add test cases for ENDDETAILCAUSE
        inputs.add(createInput('Education - self-financed', 'ENDDETAILCAUSE'));
        inputs.add(createInput('Illness', 'ENDDETAILCAUSE'));
        inputs.add(createInput('Unknown', 'ENDDETAILCAUSE'));
        inputs.add(createInput('','MAINGOAL'));

        // Call the method under test
        List<IPS_UtilityFlowTranslateController.Output> outputs = IPS_UtilityFlowTranslateController.translateString(inputs);

        // Assertions
        System.assertEquals(inputs.size(), outputs.size(), 'The number of outputs should match the number of inputs.');

        // Validate translations for MAINGOAL
        System.assertEquals('Arbeid', outputs[0].outputString, 'Translation for "Work" in MAINGOAL is incorrect.');
        System.assertEquals('Utdanning', outputs[1].outputString, 'Translation for "Education/Apprentice" in MAINGOAL is incorrect.');
        System.assertEquals('Ukjent hovedmål', outputs[2].outputString, 'Translation for unknown value in MAINGOAL is incorrect.');

        // Validate translations for STATUS
        System.assertEquals('Henvist', outputs[3].outputString, 'Translation for "Referred" in STATUS is incorrect.');
        System.assertEquals('Innledende kontakt', outputs[4].outputString, 'Translation for "Initial contact" in STATUS is incorrect.');
        System.assertEquals('Ukjent status', outputs[5].outputString, 'Translation for unknown value in STATUS is incorrect.');

        // Validate translations for ENDCAUSE
        System.assertEquals('Utdanning', outputs[6].outputString, 'Translation for "Education" in ENDCAUSE is incorrect.');
        System.assertEquals('Andre sluttårsaker', outputs[7].outputString, 'Translation for "Other end causes" in ENDCAUSE is incorrect.');
        System.assertEquals('Ukjent avslutningsårsak', outputs[8].outputString, 'Translation for unknown value in ENDCAUSE is incorrect.');

        // Validate translations for ENDDETAILCAUSE
        System.assertEquals('Utdanning - egenfinansiert', outputs[9].outputString, 'Translation for "Education - self-financed" in ENDDETAILCAUSE is incorrect.');
        System.assertEquals('Sykdom', outputs[10].outputString, 'Translation for "Illness" in ENDDETAILCAUSE is incorrect.');
        System.assertEquals('Ukjent avslutningsdetaljårsak', outputs[11].outputString, 'Translation for unknown value in ENDDETAILCAUSE is incorrect.');
    }

    // Helper method to create input objects
    private static IPS_UtilityFlowTranslateController.Input createInput(String inputString, String fieldCategory) {
        IPS_UtilityFlowTranslateController.Input input = new IPS_UtilityFlowTranslateController.Input();
        input.inputString = inputString;
        input.fieldCategory = fieldCategory;
        return input;
    }

}