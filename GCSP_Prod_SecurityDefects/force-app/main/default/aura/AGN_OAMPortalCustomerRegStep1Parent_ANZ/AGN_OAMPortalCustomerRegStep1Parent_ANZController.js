({
    doInit : function(component, event, helper) {        
      /*  var browserType = navigator.sayswho= (function(){
            var ua= navigator.userAgent, tem,               
                M= ua.match(/(opera|Chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if(/trident/i.test(M[1])){
                tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
                //alert("IE"+'IE '+(tem[1] || ''));
                return 'IE '+(tem[1] || '');
            }
            if(M[1]=== 'Chrome'){                
                tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
                if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
                
            }
            M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
            if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
            return M.join(' ');
        })();      
        if (browserType.startsWith("Chrome")) {
            component.set("v.isChrome", true);
            //alert("Chrome>>>"+browserType);
        } */
        
       var action  = component.get("c.getUserDetail"); 
         action.setCallback(this, function(response) {
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
        var customerType = eventParam.customerType;
        var customerSubType = eventParam.customerSubType;
        var countryOptions = eventParam.countryOptions;
        var customerTypeConfig = eventParam.customerTypeConfig;
         var countryCode = eventParam.countryCode; //e.g. IT or FR
        var formStep1 = component.find("formStep1");
        //console.log(formStep1);
        formStep1.displayFormStep1(countryCode, customerType, customerSubType, countryOptions, customerTypeConfig); //calling aura method of child component
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