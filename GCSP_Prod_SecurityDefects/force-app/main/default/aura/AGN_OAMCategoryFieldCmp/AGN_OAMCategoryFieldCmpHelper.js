({
    getCustomerGroupData : function(customerType , customerSubType , component ) {
        var fieldName  = component.get('v.fieldName');
        var obj = component.get('v.obj_addNewShipTo');
        var index = component.get('v.index');
        var action = component.get("c.getCustomerGroup");
        action.setParams({ 
            customerType : customerType,
            customerSubType : customerSubType 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state>>>>>>>>>>>>>>>>>>>>>>>>>>",state);
            if (state === "SUCCESS") {
                var customerGroup = response.getReturnValue();
                console.log("customerGroup>>>>>>>>>>>>>>>>>>>>>>>>>>",customerGroup.trim());
               
                if(customerGroup){
                    obj[index][fieldName] = customerGroup.trim();                       
                    component.set('v.obj_addNewShipTo' , obj);
                    component.set("v.selectedSubTyp" , customerSubType);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchCustomerSubType : function(component, event , selected) {
        var newlst = [];
        var customerTypeConfig = component.get("v.customerTypeConfig");
        //var selected = event.getSource().get("v.value");
        console.log('@Category List --------->'+selected);
        if(selected != undefined && selected != null && selected != ''){           
            if ($A.util.isArray(customerTypeConfig)){
                customerTypeConfig.forEach(function(currRow){
                    if(currRow.Category_Label_AGN__c.toUpperCase() === selected.toUpperCase()){
                        if (newlst.map(function(e) { return e.key; }).indexOf(currRow.Sub_Category_Label_AGN__c) <0){ // duplicate remove
                            newlst.push({key:currRow.Sub_Category_Label_AGN__c, val:currRow.Sub_Category_Label_AGN__c});
                        }
                    }
                });
                newlst.sort();                
            }
        }
        component.set("v.picklistSubTypeOptions", newlst);
    }
})