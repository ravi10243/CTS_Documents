({
	handleCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        component.set("v.showDependantFields" , isChecked);
        console.log("on check>>>>>>>>>>>>>>"+ component.get("v.showDependantFields"));
        if(!isChecked){
            component.set("v.clearValues" ,  true);
        }else{
            component.set("v.clearValues" ,  true);
            console.log("DependantFields>>>>>>>>>>>>>>>>>>>>",component.get("v.DependantFields"));
            component.set("v.DependantFields" , component.get("v.DependantFields"));
            
        }
        
    },
    doInit : function(component, event, helper){
        console.log("inside doinit>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        var cmps = [];
        var newcm = [];
        cmps = component.get("v.DependantFields");
        if(!$A.util.isEmpty(cmps)){
            cmps.forEach(function(cmp){
                console.log("Fieldvalue 0>>>>>>>>>>>>>>>>>>>>>>>"+cmp.FieldValue_AGN__c);
                cmp.FieldValue_AGN__c = "";
                newcm.push(cmp);
            })
        }
        
        newcm.forEach(function(cmp){
                console.log("Fieldvalue 1>>>>>>>>>>>>>>>>>>>>>>>"+cmp.FieldValue_AGN__c);
            })
        component.set("v.DependantFields",newcm);
    },
    /*onRender : function(component, event, helper){
        console.log("onRender event>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }*/
})