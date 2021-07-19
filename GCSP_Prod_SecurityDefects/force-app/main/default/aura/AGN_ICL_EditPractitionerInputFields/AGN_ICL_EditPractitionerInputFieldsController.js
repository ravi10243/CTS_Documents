({
	doInit : function(component, event, helper) {
		var ispicklist = component.get("v.isPicklist");
        var objname = component.get("v.sobjectName");
        var fieldname = component.get("v.fieldName");
        //console.log('REGEX :'+component.get("v.fieldRegex"));
        var labelname = component.get("v.customLabel");
        var labelReference = $A.getReference("$Label.c." + labelname);
        component.set("v.customLabelName", labelReference);
         var pract = JSON.stringify(component.get("v.practitioner")); 
        console.log('Edit practitioner list '+pract);
        var jsonpract = JSON.parse(pract);
        if(objname === 'Practitioner_Listing_AGN__c')
        {
            console.log('Pract list '+pract);
            component.set('v.fieldValue',jsonpract[fieldname]);        
        }
        //var val = pract.fieldname;
        //console.log('Val :'+val);
        //component.set("v.fieldValue",val);
        if(ispicklist === true)
        {
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
                            console.log('a[key].label : '+a[key].label +'a[key].value :'+a[key].value);
                            if(a[key].value === jsonpract[fieldname])
                            {
                                opts.push({label : a[key].label,value :a[key].value,selected:true});
                            }
                            else
                            {
                                opts.push({label : a[key].label,value :a[key].value,selected : false});
                            }
                        }
                        component.set("v.PickListValues", opts);
                        var compEvent = component.getEvent("CloseSpinner");
                        compEvent.setParams({ "CloseSpinner": true });
                        //compEvent.setParams({ "message": 'Cool' });
                        compEvent.fire();
                    } 
                    //console.log('Salutation list--'+response.getReturnValue());  
                });
                $A.enqueueAction(action);
            //}
            
        }
        if(component.get("v.fieldValue") != null || component.get("v.fieldValue") != undefined)
        {
            component.set("v.containsValue",true);
        }
    },
     handleBlur : function(component, event,helper) {
        jQuery.noConflict();
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