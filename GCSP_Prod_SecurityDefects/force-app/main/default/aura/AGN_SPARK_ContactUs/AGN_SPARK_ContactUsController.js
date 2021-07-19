({
    doInit :function(component, event, helper) {
        helper.getPageImages(component);
    },
	getClick : function(component, event, helper) { 
        if(!confirm($A.get("$Label.c.AGN_SPARK_Leave_Allergan_Site"))){
            event.preventDefault();
       		event.stopPropagation();
            return;
        }
       // $A.get("$Label.c.AGN_SPARK_ContactUs_Adverse_events_reportwebsite")
    },
})