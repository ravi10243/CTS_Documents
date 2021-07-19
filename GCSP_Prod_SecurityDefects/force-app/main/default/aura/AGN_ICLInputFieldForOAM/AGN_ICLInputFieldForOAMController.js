({
    doInit : function(component, event, helper) {
        var ispicklist = component.get('v.isPicklist');
        var objname = component.get("v.sobjectName");
        var fieldname = component.get("v.fieldName");
        var TypeOfAcc = component.get("v.TypeofAccount");
       
         var labelname = component.get("v.customLabel");
            var labelReference = $A.getReference("$Label.c." + labelname);
            component.set("v.customLabelName", labelReference);
       
        if(objname==='Account' && TypeOfAcc === 'Clinic Admin')
        {
            var ac = JSON.stringify(component.get("v.Clinic_Admin_details")); 
            var json = JSON.parse(ac);
            component.set('v.fieldValue',json[fieldname]);  
            component.set('v.containsValue',true);
        }
        
      
         if(objname==='Locator_Listing_AGN__c' )
        {
            var addr = JSON.stringify(component.get("v.Address_details"));
            var Clinic = JSON.stringify(component.get("v.Clinic_details"));
            var json = JSON.parse(addr);
            var jsonclinic = JSON.parse(Clinic);
            if(fieldname === 'Name')
            {
                component.set('v.fieldValue',jsonclinic['Name']);
            }
            if(fieldname === 'Street_AGN__c')
            {
                component.set('v.fieldValue',json['Name']);
            }
            else if(fieldname === 'City_AGN__c')
            {
             	component.set('v.fieldValue',json['City_vod__c']);   
            }
            else if(fieldname === 'State_Providence_Region_AGN__c')
            {
                if(json['State_vod__c'] != null)
                {
                    component.set('v.fieldValue',json['State_vod__c']);
                }
                else
                {
                 	component.set('v.fieldValue',json['Province_AGN__c']);   
                }
            }
            else if(fieldname === 'Zip_Code_AGN__c')
            {
                component.set('v.fieldValue',json['Zip_vod__c']);
            }
            else if(fieldname === 'Country_AGN__c')
            {
                component.set('v.fieldValue',json['Country_vod__c']);
            }
            
            if(component.get('v.fieldValue') != null || component.get('v.fieldValue') != undefined)
            {
             	component.set('v.containsValue',true);   
            }
        }
        
                 
        if(ispicklist)
        {
             var opts = [{  label: "", value: "", selected: "true" }];
                var action = component.get("C.getPicklistValues");
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
                    alert(1);
                    $(this).addClass("has-content");
                } else {
                    alert(2);
                    $(this).removeClass("has-content");
                    $(this).prop("type", "text");
                }
            })
        }
        var fieldValueMissing = fieldValue === null || fieldValue === '' || fieldValue === undefined;
        component.set('v.fieldValueMissing', (fieldRequired && fieldValueMissing));
        this.validate(component, event);
    },
    validate : function(component, event) {
        var field = component.find('inputField');
        var fieldValue = component.get('v.fieldValue');
        var regex = component.get('v.fieldRegex');///^[0-9+ ()-]+$/ ;
        //console.log('regex ' + regex);
        if(regex && !$A.util.isEmpty(field)){   
            if(fieldValue.match(regex)){
                component.set('v.isFormatValid', true);
            }else{
                component.set('v.isFormatValid', false);
            }
        }
    },
    
    handleBlur : function(component, event,helper) {
        jQuery.noConflict();
        //var a = $;
        console.log('dfvdjhh');
        if(component.get('v.fieldValue')==null ||component.get('v.fieldValue')=='')
        {
            console.log('no value');
            component.set('v.containsValue',false);
            console.log('false');
        }
        else
        {
            console.log('has value');
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