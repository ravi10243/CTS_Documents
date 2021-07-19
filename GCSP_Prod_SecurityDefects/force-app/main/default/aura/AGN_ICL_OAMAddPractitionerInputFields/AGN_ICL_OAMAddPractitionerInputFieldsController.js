({
	doInit : function(component, event, helper) {
		var ispicklist = component.get("v.isPicklist");
        var objname = component.get("v.sobjectName");
        var fieldname = component.get("v.fieldName");
        var labelname = component.get("v.customLabel");
        //console.log('labelname : '+labelname);
            var labelReference = $A.getReference("$Label.c." + labelname);
        //console.log('labelReference'+labelReference);
            component.set("v.customLabelName", labelReference);
        
        if(ispicklist === true)
        {
            /*if(objname === 'Practitioner_Listing_AGN__c' && fieldname ==='Type_AGN__c')
            {
                var action2 = component.get("c.getPractitionerType");
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        component.set("v.PickListValues", response.getReturnValue());
                    } 
                });
                $A.enqueueAction(action2);
            }
            else
            {*/
                 var opts = [{  label: "", value: "", selected: "true" }];
                var action = component.get("C.fetchPicklistValues");
                action.setParams({
                    'objectName': objname,
                    'field_apiName': fieldname,
                    'nullRequired': true 
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS"){
                         var a = response.getReturnValue();
                         for(var key in a)
                        {
                             opts.push({label : a[key].label,value :a[key].value,selected : false});
                        }
                        component.set("v.PickListValues", opts);
                        //component.set("v.PickListValues", response.getReturnValue());
                    } 
                });
                $A.enqueueAction(action);     
            //}
        }

    },
     handleBlur : function(component, event,helper) {
        //jQuery.noConflict();
        if(component.get('v.fieldValue')==null ||component.get('v.fieldValue')=='')
        {
            component.set('v.containsValue',false);
            console.log('false');
        }
        else
        {
            component.set('v.containsValue',true);
            console.log('true');
        }
         helper.validate(component, event);
    },
    SetPickListValue :function(component, event) {
        var picklistcomp  = component.find("inputField");
        component.set("v.fieldValue",picklistcomp.get("v.value"));
    }
})