public with sharing class IPS_StringHasherController {
        @InvocableMethod(label='IPS string hasher' description='Input a string and the string will be hashed with SHA-256')
        public static List<FlowOutput> hashString(List<eventRequest> request){
        List<FlowOutput> flowOutput = new List<FlowOutput>();
        FlowOutput output = new FlowOutput();
        
        //parse input and variables
        String currentString = request.get(0).inputString;
           
        // Convert the input string to a Blob
        Blob inputBlob = Blob.valueOf(currentString);

        // Hash the Blob using SHA-256
        Blob hashedBlob = Crypto.generateDigest('SHA-256', inputBlob);

        // Convert the hashed Blob to a hexadecimal string
        String hashedString = EncodingUtil.convertToHex(hashedBlob);

        output.hashString = hashedString;
        FlowOutput.add(output);
        // Return the hashed string
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