({
    doInit:function(component,event,helper){
        document.body.style.overflow="hidden";
       	helper.getPicklistValues(component, event);
    },
 
	closeModal:function(component,event,helper){ 
       	helper.clsModal(component, event,helper);
    },
    
    updateProfile:function(component,event,helper){ 
        helper.updProfile(component, event);
    },
    
    handleChange: function (component, event) {
        var changeValue = event.getParam("value");
        component.set("v.currentPracticing", changeValue);
    },
})