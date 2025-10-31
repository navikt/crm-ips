public with sharing class IPS_StringHasherController {
        @InvocableMethod(label='IPS string hasher' description='Input a string and the string will be hashed with SHA-256')
        public static List<FlowOutput> hashString(List<eventRequest> request){
        List<FlowOutput> flowOutput = new List<FlowOutput>();
        
        // Iterate over each eventRequest in the input list
        for (eventRequest req : request) {
            FlowOutput output = new FlowOutput();

            // Parse input and variables
            String currentString = req.inputString;

            // Convert the input string to a Blob
            Blob inputBlob = Blob.valueOf(currentString);

            // Hash the Blob using SHA-256
            Blob hashedBlob = Crypto.generateDigest('SHA-256', inputBlob);

            // Convert the hashed Blob to a hexadecimal string
            String hashedString = EncodingUtil.convertToHex(hashedBlob);

            // Set the hashed string in the output object
            output.hashString = hashedString;

            // Add the output object to the result list
            flowOutput.add(output);
        }

        // Return the list of hashed strings
        return FlowOutput;
    }

        //Input variables from flow
        public class eventRequest {
            @InvocableVariable(required=true)
            public String inputString;
            
		}
        //Output variables from flow
        public class FlowOutput{
            @InvocableVariable()
            public String hashString;
        }
}