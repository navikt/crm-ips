public with sharing class CE_viewDiscovery {
    public Id currentRecordId { get; set; }
    public CE_viewDiscovery(ApexPages.StandardController sc) {
        this.currentRecordId = ApexPages.currentPage().getParameters().get('id');

    }
}

