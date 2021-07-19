({
	doInit : function(component, event, helper) {
		var action = component.get("c.getMDApplications");
        console.log('fetch applications---');
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.applications",response.getReturnValue());
                console.log('applicationsapplicationsapplications -' + JSON.stringify(response.getReturnValue()));
            }
        });
        
        $A.enqueueAction(action);
	}
})