({
    fetchCountry : function(component, event) {
        var action = component.get('c.fetchCountryList');
        
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var customerTypeConfig = response.getReturnValue();
                
                component.set("v.picklistCountryOptions", customerTypeConfig[0]); //country select list
                component.set("v.customerTypeConfig", customerTypeConfig[1]); //Customer_Type_Configuration_AGN__c data for country                
                //console.log(JSON.stringify(customerTypeConfig));
            } else {
                console.log(response.getError().length + ' ERRORS');
                for(var i = 0; i < response.getError().length; i++) {
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerType : function(component, event) {
        var newlst = [];
        var customerTypeConfig = component.get("v.customerTypeConfig");
        var selected = component.find("inputSelectCountry").get("v.value");
        component.set("v.selectedCountry", selected);
        
        //alert(selected);
        if(selected != undefined && selected != null && selected != ''){
            //alert(selected);
            
            if ($A.util.isArray(customerTypeConfig)){
                //alert(selected);
                customerTypeConfig.forEach(function(currRow){                   
                    //console.log(JSON.stringify(currRow));
                    if(selected.toUpperCase() ==='GB' || selected.toUpperCase() ==='IE'){
                        if(currRow.Customer_Country_AGN__r.Name.toUpperCase() === selected.toUpperCase()){
                            //if (newlst.indexOf(currRow.Category_AGN__c) < 0){ // duplicate remove
                            //    newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c});                     
                            
                            if(newlst.map(function(e){
                                return e.key; e.val;
                            }).indexOf(currRow.Category_AGN__c,currRow.Category_Label_AGN__c)<0){
                                
                                newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c});                            
                            } 
                        }
                    }
                    else{
                        if(currRow.Country_Code_AGN__c.toUpperCase() === selected.toUpperCase()){
                            //if (newlst.indexOf(currRow.Category_AGN__c) < 0){ // duplicate remove
                            //    newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c});                     
                            
                            if(newlst.map(function(e){
                                return e.key; e.val;
                            }).indexOf(currRow.Category_AGN__c,currRow.Category_Label_AGN__c)<0){
                                
                                newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c});                            
                            } 
                        }
                    }
                });
               
                newlst.sort();               
            }
        }
        component.set("v.picklistCustomerTypeOptions", newlst);
        //console.log(JSON.stringify(newlst));
        
        this.fireEvent(component, event);
    },
    
    fetchCustomerSubType : function(component, event) {
        var newlst = [];
        var customerTypeConfig = component.get("v.customerTypeConfig");
        var selected = component.find("inputSelectCustomerType").get("v.value");
        component.set("v.selectedCustomerType", selected);
         var selectedCountry = component.get("v.selectedCountry");
        //console.log('selectedCountry : '+selectedCountry);
        if(selected != undefined && selected != null && selected != ''){
            //alert(selected);
            
            if ($A.util.isArray(customerTypeConfig)){
                //console.log('customerTypeConfig : '+JSON.stringify(customerTypeConfig));

                customerTypeConfig.forEach(function(currRow){
                    if(currRow.Category_AGN__c.toUpperCase() === selected.toUpperCase()){
                        if (newlst.map(function(e) { return e.key; }).indexOf(currRow.Sub_Category__c) <0){ // duplicate remove
                            if(selectedCountry === 'GB' || selectedCountry === 'IE'){
                                 if(currRow.Customer_Country_AGN__r.Name == selectedCountry){
                                newlst.push({key:currRow.Sub_Category__c, val:currRow.Sub_Category_Label_AGN__c});
                              }
                                
                            }else{
                                newlst.push({key:currRow.Sub_Category__c, val:currRow.Sub_Category_Label_AGN__c});
                            }
                           
                           // newlst.push({key:currRow.Sub_Category__c, val:currRow.Sub_Category_Label_AGN__c});
                        }
                    }
                });
                newlst.sort();                
            }
        }
        component.set("v.picklistSubTypeOptions", newlst);
        console.log('newlst : '+JSON.stringify(newlst));
        this.fireEvent(component, event);
    },
    
    fireEvent : function(component, event) {
        //console.log(JSON.stringify(component.get('v.picklistCountryOptions'), null, 2));
        console.log('Selected country --'+component.get("v.selectedCountry"));
        var formHeaderChange = component.getEvent("formHeaderChange");
        formHeaderChange.setParams({"formDataCCSu_Type":
                                    {
                                        "countryCode" : component.get("v.selectedCountry"),
                                        "customerType" : component.get("v.selectedCustomerType"),
                                        "customerSubType" : component.get("v.selectedSubType"),
                                        "countryOptions" : component.get("v.picklistCountryOptions"),
                                        "customerTypeConfig" : component.get("v.customerTypeConfig")
                                    }
                                   });
        formHeaderChange.fire();
    }
})