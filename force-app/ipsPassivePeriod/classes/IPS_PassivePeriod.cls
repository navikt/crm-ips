/**
 * Represents a passive period with a start date and end date.
 * @author Balendra Sounthararajan
 * @since 31.05.24
 */
public class IPS_PassivePeriod {
    @AuraEnabled
    public Datetime startDate { get; set; }

    @AuraEnabled
    public Datetime endDate { get; set; }

    public IPS_PassivePeriod(Datetime startDate, Datetime endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
}
