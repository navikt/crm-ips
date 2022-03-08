({
    invoke: function (component, event, helper) {
        // Get the record ID attribute
        var record = component.get('v.recordId');

        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get('e.force:navigateToSObject');

        // Pass the record ID to the event
        redirect.setParams({
            recordId: record
        });

        // Open the record
        redirect.fire();
    }
});
