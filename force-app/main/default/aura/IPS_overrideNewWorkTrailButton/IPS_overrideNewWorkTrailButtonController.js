({
   
   init: function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
       if(toastEvent){
           toastEvent.setParams({
        	"title": "Til informasjon!",
            "type" : "info",
        	"message": "Det er ikke mulig å opprette jobbspor via mobil."
    		});
    		toastEvent.fire();
       }else{
           //fallback for salesforce mobile app
           var toastMessage = $A.get("e.force:showToast");
           toastMessage.setParams({
       		"title": "Til informasjon!",
        	"mode" : "sticky",
            "type" : "info",
        	"message": "Det er ikke mulig å opprette jobbspor via mobil."
    		});
    		toastMessage.fire();
       }
}
})