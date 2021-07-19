({
    doInit : function(component, event, helper) {
        
        var ispicklist = component.get("v.isPicklist");
        var objname = component.get("v.sobjectName");
        var fieldname = component.get("v.fieldName");
        var displaytype= component.get("v.displayType");
        var reg = component.get("v.fieldRegex");
        var labelname = component.get("v.customLabel");
        //console.log('labelname : '+labelname);
        var labelReference = $A.getReference("$Label.c." + labelname);
        //console.log('labelReference'+labelReference);
        component.set("v.customLabelName", labelReference);
        
        if(fieldname === 'Country_AGN__c')
        {
            component.set("v.containsValue",true);
            component.set("v.disabled",true);
            
            var action1 = component.get("c.getloggedInUserCountry");
            action1.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS') 
                {
                    var countryval = response.getReturnValue();
                    console.log('Fetchcountry'+countryval);
                    component.set("v.fieldValue",countryval);
                }          
            });
            $A.enqueueAction(action1);
        } 
        
        
        if(ispicklist)
        {
            var opts = [{  label: "", value: "", selected: "true" }];
            var action = component.get("C.getPicklistValuesLogged");
            action.setParams({
                'SObjectAPIName': objname,
                'FieldAPIName': fieldname
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
        }
        else
        {
            //helper.parseFieldValue(component, event);
        }
    },
    validateFieldValue : function(component, event) {
        var fieldRequired  = component.get('v.required');
        console.log('In ValidateFieldValue');
        var fieldValue = event.getParam('value') !== undefined ? event.getParam('value') : event.getSource().get('v.value');
        if(typeof fieldValue === 'undefined'|| fieldValue === null || fieldValue === '' )
        {
            fieldValue = '';
        }
        else
        {
            console.log('FocusOut');
            jQuery(".input-effect input").focusout(function() {
                if ($(this).val() != "") {
                    $(this).addClass("has-content");
                } else {
                    $(this).removeClass("has-content");
                    $(this).prop("type", "text");
                }
            })
        }
        var fieldValueMissing = fieldValue === null || fieldValue === '' || fieldValue === undefined;
        component.set('v.fieldValueMissing', (fieldRequired && fieldValueMissing));
        //this.validate(component, event);
    },
    handleBlur : function(component,event,helper) {
        jQuery.noConflict();
        //var a = $;
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