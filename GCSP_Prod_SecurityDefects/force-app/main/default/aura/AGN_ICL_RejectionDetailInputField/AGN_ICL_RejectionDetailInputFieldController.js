({
    doInit : function(component, event, helper) {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        console.log('vars22>>'+JSON.stringify(vars));
        var ispicklist = component.get('v.isPicklist');
        var objname = component.get("v.sobjectName");
        var fieldname = component.get("v.fieldName");
        var abd = JSON.stringify(component.get("v.Locator_Listing")); 
        var labelname = component.get("v.customLabel");
            var labelReference = $A.getReference("$Label.c." + labelname);
            component.set("v.customLabelName", labelReference);  
        
       if(objname=='Locator_Listing_AGN__c')
        {
            var ll = JSON.stringify(component.get("v.Locator_Listing"));
            var jsonloc = JSON.parse(ll);
            component.set('v.fieldValue',jsonloc[fieldname]);
            
        }
        
        if(ispicklist)
        {
            console.log('ispicklist'+ispicklist);
            var opts = [{  label: "", value: "", selected: "true" }];
                var action = component.get("c.getPicklistValuesFromLoc");
                action.setParams({
                    'SObjectAPIName': objname,
                    'FieldAPIName': fieldname,
                    'LocId':vars["lcid"]
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state'+state);
                    if (state === "SUCCESS"){
                        var a = response.getReturnValue();
                        console.log('len ' + a.length);
                        for(var key in a)
                        {
                            console.log('a[key].label : '+a[key].label +'a[key].value :'+a[key].value);
                            //console.log(JSON.stringify(key));
                            if(objname === 'Locator_Listing_AGN__c')
                            {
                                if(a[key].value === jsonloc[fieldname])
                                {
                                    opts.push({label : a[key].label,value :a[key].value,selected:true});
                                }
                                else
                                {
                                    opts.push({label : a[key].label,value :a[key].value,selected : false});
                                }
                            }
                            else if(objname === 'Account')
                            {
                                if(a[key].value === jsonacc[fieldname])
                                {
                                    opts.push({label : a[key].label,value :a[key].value,selected:true});
                                }
                                else
                                {
                                    opts.push({label : a[key].label,value :a[key].value,selected : false});
                                }                                
                            }
                            
                        }
                        component.set("v.PickListValues", opts);
                    } 
                });
                $A.enqueueAction(action);
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
        this.validate(component, event);
    },
    handleBlur : function(component,event,helper) {
        //jQuery.noConflict();
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