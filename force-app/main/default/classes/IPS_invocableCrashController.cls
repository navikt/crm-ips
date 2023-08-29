public with sharing class IPS_invocableCrashController {
@InvocableMethod(Label='Crash on delete' Description='Crashes with an error message')

    public static void execute(List<String> errorMessages) {

		if (errorMessages.size() > 0) {

			throw new InvocableCrashException(errorMessages.get(0));

		}

	}

	public class InvocableCrashException extends Exception {}
}