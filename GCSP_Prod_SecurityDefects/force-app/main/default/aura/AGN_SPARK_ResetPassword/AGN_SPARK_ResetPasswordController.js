({
	doInit : function(component, event, helper) {
        var idParam = helper.getJsonFromUrl().usrId;
        var strParam = helper.getJsonFromUrl().str;
        component.set("v.usrId",idParam)
    }
	
})