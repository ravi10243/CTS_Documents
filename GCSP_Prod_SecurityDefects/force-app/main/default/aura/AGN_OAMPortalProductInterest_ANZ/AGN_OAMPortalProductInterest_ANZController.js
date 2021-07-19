({
    doInit : function(component) {
        //console.log("inside product interest>>>>>>>>>>>>>>>>>>>>",component.get("v.productInterestOptions"));
        var customerGroup = component.get("v.customerGroup");
        var customerType = component.get("v.customerType");
        var customerSubType = component.get("v.customerSubType");
        var customerTypeConfig = component.get("v.customerTypeConfig");
        var customCountryCode = component.get("v.customCountryCode");
        
        if(customCountryCode == 'AU'){
            customCountryCode = 'AN';
        }else{
            customCountryCode = component.get("v.customCountryCode");
        }
       
        var dynamicLabel = $A.getReference("$Label.c." + component.get("v.customLabel"));
        component.set("v.customLabelName" , dynamicLabel); 
       
        component.set("v.showSpinner",true);
        
        var action = component.get("c.getPicklistOptions");
        action.setParams({ 
            ObjectName : 'Allergan_Customer_Registration_AGN__c',
            fieldName : 'Product_Interest_AGN__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log("From server:::::::::::::: "+ JSON.stringify(response.getReturnValue()));
                var prodOptions = [];
                var optionMap = new Map();
                var options = response.getReturnValue();
                
                if(!$A.util.isEmpty(options)){
                    options.forEach(function(cmp){
                        optionMap.set(cmp.value ,cmp.label);                            
                    });
                }
                //alert(customerGroup+">>>>>"+customerType+">>>>>"+customerSubType+">>>>>"+customCountryCode);
                if(!$A.util.isEmpty(customerTypeConfig) && !$A.util.isEmpty(optionMap)){
                    customerTypeConfig.forEach(function(cmp){
                 //console.log('cmp.Customer_Group_AGN__c : '+cmp.Customer_Group_AGN__c+ '>>>>customerGroup : '+customerGroup+'>>> cmp.Product_Interest_AGN__c : '+cmp.Product_Interest_AGN__c);
                        if(!$A.util.isEmpty(customerType) 
                           && !$A.util.isEmpty(customerSubType) 
                           && !$A.util.isEmpty(cmp.Product_Interest_AGN__c) 
                         //  && cmp.Customer_Group_AGN__c === customerGroup
                           && (cmp.Category_AGN__c === customerType || cmp.Category_Label_AGN__c === customerType)
                           && (cmp.Sub_Category__c === customerSubType || cmp.Sub_Category_Label_AGN__c === customerSubType)
                           && cmp.Customer_Country_AGN__r.Name === customCountryCode){ 
                            var ops = cmp.Product_Interest_AGN__c.split(';');
                            //console.log('Current Product Interest Options>>>>>>>>>>>>>>>',ops);
                            if(!$A.util.isEmpty(ops)){
                                ops.forEach(function(op){
                                    if(optionMap.has(op)){ 
                                        prodOptions.push({label : optionMap.get(op) , value : op});
                                    }
                                });
                            }
                        }
                    });
                }
                //console.log('prodOptions>>>>>>>>>>>>>>>>>>>>>>>>>>>>',optionMap);
                
                component.set("v.options" , prodOptions);
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);                 
        
        
    },
    
    onChkSelect : function(component , event) {
        console.log(event.getSource().get("v.name"));
        //console.log(component.find("yo").get("v.name"));
        
        var ops = component.find("options");
        //console.log(ops);
        var selected = [];
        for(var op in ops){
            
           // console.log("selected value>>>>>>>>>>>",op);
            //selected.push(op.g)        
        }
        
    }
})