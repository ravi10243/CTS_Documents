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
        
        /*console.log('Picklist'+ispicklist);
        console.log('Sobject'+objname);
        console.log('fieldname'+fieldname);
        console.log('Type'+component.get("v.displayType"));
        console.log('Regex value'+reg);*/
        //ARIJIT
        
        if(fieldname === 'Country_AGN__c')
        {
            component.set("v.containsValue",true);
            component.set("v.disabled",true);
            
            var query = location.search.substr(1);
            query.split("&").forEach(function(part)
                                     {
                                         var item = part.split("=");
                                         if(item[0] === 'country')
                                         {
                                             var action1 = component.get("c.getcountry");
                                            // console.log('Country'+ decodeURIComponent(item[1]));
                                             action1.setParams({
                                                 'country' : decodeURIComponent(item[1])
                                             });
                                             
                                             action1.setCallback(this, function(response){
                                                 
                                                 if(response.getState() === 'SUCCESS') 
                                                 {
                                                     var countryval = response.getReturnValue();
                                                     //alert('countryval  '+ countryval);
                                                     component.set("v.fieldValue",countryval);
                                                     
                                                 }
                                                 
                                             });
                                             $A.enqueueAction(action1);
                                         
                                         }
                                     }) ;
        } 
        
        //ARIJIT
        
        if(ispicklist)
        {
            var opts = [{  label: "", value: "", selected: "true" }];
            var vars = {};
            var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
                vars[key] = value;
            });  
            var action = component.get("C.getPicklistValues");
            action.setParams({
                'SObjectAPIName': objname,
                'FieldAPIName': fieldname,
                'countryCode': vars["country"]
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
        //added as apart of two column layout
        /* var action = component.get("C.isTwoLayerLayout");
            action.setParams({
                'countryCode': component.get("v.customCountryCode")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var a = response.getReturnValue();
                    component.set("v.twoLayerLayout", a);
                    //component.set("v.PickListValues", response.getReturnValue());
                } 
            });
            $A.enqueueAction(action);*/
        //End
    },
    validateFieldValue : function(component, event) {
        var fieldRequired  = component.get('v.required');
        var fieldValue = event.getParam('value') !== undefined ? event.getParam('value') : event.getSource().get('v.value');
        if(typeof fieldValue === 'undefined'|| fieldValue === null || fieldValue === '' )
        {
            fieldValue = '';
        }
        else
        {
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
        }
        else
        {
            component.set('v.containsValue',true);
        }
        helper.validate(component, event);
    },
    SetPickListValue :function(component, event) {
        var picklistcomp  = component.find("inputField");
        component.set("v.fieldValue",picklistcomp.get("v.value"));
    }
})