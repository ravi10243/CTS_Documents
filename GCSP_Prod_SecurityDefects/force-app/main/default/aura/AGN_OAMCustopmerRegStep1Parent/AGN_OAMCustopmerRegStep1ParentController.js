({
    doInit : function(component, event, helper) {
       var action  = component.get("c.getUserDetail"); 
         action.setCallback(this, function(response) {
             console.log('abdul state : '+response.getState());
            if(response.getState() === 'SUCCESS') {
               var user = response.getReturnValue();
                console.log('Country Code : '+user.Country_Code__c);
               component.set("v.countryCode", user.Country_Code__c);
            } else {
                console.log('error to featch country code');
            }
        });
        $A.enqueueAction(action);
                
    },
    onSelectListChange : function(component, event, helper) {
        //var language = $A.get("$Locale.language");
        //console.log(language);
        var eventParam = event.getParam("formDataCCSu_Type");
        
        //console.log('@@@@@@@eventparam'+JSON.stringify(eventParam));
        var countryCode = eventParam.countryCode; //e.g. IT or FR
        var customerType = eventParam.customerType;
        var customerSubType = eventParam.customerSubType;
        var countryOptions = eventParam.countryOptions;
        var customerTypeConfig = eventParam.customerTypeConfig;
        
        var formStep1 = component.find("formStep1");
        //console.log(formStep1);
        formStep1.displayFormStep1(countryCode, customerType, customerSubType, countryOptions, customerTypeConfig); //calling aura method of child component
        
        //console.log("Event received at parent");
    },
        
       /* For Canada Province  */
    
    onSelectListChangeCA : function(component, event, helper) {
        //var language = $A.get("$Locale.language");
        //console.log(language);
        var eventParam = event.getParam("formDataCCSu_Type");
        //console.log('@@@@@@@eventparam'+JSON.stringify(eventParam));
        var countryCode = eventParam.countryCode; //e.g. IT or FR
        var customerType = eventParam.customerType;
        var customerSubType = eventParam.customerSubType;
        var countryOptions = eventParam.countryOptions;
        var customerTypeConfig = eventParam.customerTypeConfig;       
        var customerProvince = eventParam.customerProvince; 
        
        var formStep1CA = component.find("formStep1CA");        
          formStep1CA.displayFormStep1(countryCode, customerType, customerSubType, countryOptions, customerTypeConfig, customerProvince); 
        
        //console.log("Event received at parent");
    },    
  
    onStep1Completed : function(component, event, helper) {
        //var language = $A.get("$Locale.language");
        //console.log(language);
        var eventParam = event.getParam("isCompleted");
        component.set("v.isCompleted", eventParam);
        //console.log(eventParam);
    }
    
})