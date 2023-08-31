@isTest public class IPS_invocableCrashControllerTest {
    static testmethod void testCrash() {

        try {   

            IPS_invocableCrashController.execute(new String[] {'Hello there!'});

            System.assert(false, 'Method did not cause a crash');

        } catch (IPS_invocableCrashController.InvocableCrashException ex) {

            //All good!

        }

    }

}