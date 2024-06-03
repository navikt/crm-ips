@isTest
private class IPS_PassivePeriodTest {
    @isTest
    static void creatingPassivePeriod() {
        Datetime startDate = Datetime.newInstance(2024, 5, 17, 8, 13, 53);
        Datetime endDate = Datetime.newInstance(2024, 5, 31, 8, 13, 53);

        Test.startTest();

        IPS_PassivePeriod passivePeriod = new IPS_PassivePeriod(startDate, endDate);

        Test.stopTest();
        Assert.areEqual(startDate, passivePeriod.startDate, 'Start date should be set correctly');
        Assert.areEqual(endDate, passivePeriod.endDate, 'End date should be set correctly');
    }
}
