({
    fetchCountry : function(component, event) {
        var action = component.get('c.fetchCountryList');
        
        //action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var customerTypeConfig = response.getReturnValue();
                component.set("v.picklistCountryOptions", customerTypeConfig[0]); //country select list
                component.set("v.customerTypeConfig", customerTypeConfig[1]); //Customer_Type_Configuration_AGN__c data for country 
                component.set("v.picklistProvinceOptions", customerTypeConfig[2]);   // Provience Data              
                
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
        var selected = component.find("inputselectedProvince").get("v.value");
        component.set("v.selectedProvince", selected);
        
        if(selected != undefined && selected != null && selected != ''){
            if ($A.util.isArray(customerTypeConfig)){
                var language = component.get("v.language");
                console.log("language>>>>>>>>>>>>>>>>>>>>>>"+language);
                customerTypeConfig.forEach(function(currRow){   
                    if(!$A.util.isEmpty(currRow.Province_AGN__c) && currRow.Province_AGN__c.includes(selected.toUpperCase())){                        
                        if(newlst.map(function(e){return e.key; e.val;}).indexOf(currRow.Category_AGN__c,currRow.Category_Label_AGN__c)<0){ 
                            if(!$A.util.isEmpty(language) && language === 'fr_CA' ){
                                newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c}); 
                            } else{
                                newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_AGN__c}); 
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
        var country;
        var customerTypeConfig = component.get("v.customerTypeConfig");
        var selected = component.find("inputSelectCustomerType").get("v.value");
        var selectedProvince = component.find("inputselectedProvince").get("v.value");
        component.set("v.selectedCustomerType", selected);
        // alert(selected);
        if(selected != undefined && selected != null && selected != ''){
            //alert(selected);
            
            if ($A.util.isArray(customerTypeConfig)){
                var language = component.get("v.language");
                customerTypeConfig.forEach(function(currRow){
                    if(!$A.util.isEmpty(currRow.Province_AGN__c) && currRow.Category_AGN__c.toUpperCase() === selected.toUpperCase() && currRow.Province_AGN__c.includes(selectedProvince.toUpperCase())){
                        if (newlst.map(function(e) { return e.key; e.val;}).indexOf(currRow.Sub_Category__c) <0){ // duplicate remove 
                             if(!$A.util.isEmpty(language) && language === 'fr_CA' ){
                                newlst.push({key:currRow.Sub_Category__c, val:currRow.Sub_Category_Label_AGN__c});  
                            } else{
                                newlst.push({key:currRow.Sub_Category__c, val:currRow.Sub_Category__c});  
                            }  
                            country = currRow.Country_Code_AGN__c;
                        }
                    }
                });
                newlst.sort();                
            }
        }
        
        component.set("v.picklistSubTypeOptions", newlst);
        //console.log(JSON.stringify(newlst));
        /* For country value passing to step 1 - start */
        console.log('country code>>>>>>>>>>>'+country);
        component.set("v.selectedCountry", country);
        
        /*For country value passing to step 1 - end */
        
        
        this.fireEvent(component, event);
    },
    
    fireEvent : function(component, event) {
        //console.log(JSON.stringify(component.get('v.picklistCountryOptions'), null, 2));
        
        var formHeaderChange = component.getEvent("formHeaderChangeCA");
        formHeaderChange.setParams({"formDataCCSu_Type":
                                    {
                                        "countryCode" : component.get("v.selectedCountry"),
                                        "customerType" : component.get("v.selectedCustomerType"),
                                        "customerSubType" : component.get("v.selectedSubType"),
                                        "countryOptions" : component.get("v.picklistCountryOptions"),
                                        "customerTypeConfig" : component.get("v.customerTypeConfig"),
                                        "customerProvince" :  component.get("v.selectedProvince")
                                    }
                                   });
        formHeaderChange.fire();
    },
    
    setSelectedLanguage : function (component, event) {
        var language = this.getUrlParameter('language');
        if(!$A.util.isEmpty(language)){
            component.set("v.language" , language);
        }
    },
    
    getUrlParameter : function getUrlParameter(sParam) {
                var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('&'),
                    sParameterName,
                    i;

                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('=');

                    if (sParameterName[0] === sParam) {
                        return sParameterName[1] === undefined ? true : sParameterName[1];
                    }
                }
   }
})