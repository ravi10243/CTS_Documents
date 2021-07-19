({
    getcustomerAccountDetails : function(component, event) {
        var action = component.get('c.getAccountDetails');        
        action.setStorable();
        action.setCallback(this, function(response) {
            
            if(response.getState() === 'SUCCESS') {
                var customerAcc = response.getReturnValue();
                component.set("v.customerAcc",customerAcc);
                //ICL
                var clinictype = component.get("v.customerAcc").Customer_Category_AGN__c;
                if(clinictype === null || clinictype === undefined){
                    clinictype = component.get("v.customerAcc").Primary_Parent_vod__r.Customer_Category_AGN__c;
                }
                if(clinictype.includes("Clinic") || clinictype.includes("clinic"))
                {
                    component.set("v.isClinic",true);
                }
                var jsoncust = JSON.parse(JSON.stringify(component.get("v.customerAcc")));
                var jsonprim = JSON.parse(JSON.stringify(jsoncust["Primary_Parent_vod__r"]));
                component.set("v.isICLEnabledInAccount", jsonprim["IsICLEnabled_AGN__c"]);
            }
        });
        $A.enqueueAction(action);
    },
    getADOktaSSOUrl : function(component, event) {
        var action = component.get('c.getAD_OktaSSOUrl');
        
        action.setStorable();
        action.setCallback(this, function(response) {
           if(response.getState() === 'SUCCESS') {
                var adssourl = response.getReturnValue();
                component.set("v.adOktaSSOUrl",adssourl);
            }
        });
        $A.enqueueAction(action);
    },   
        
    registrationCompleted : function(component, event) {
        var action1 = component.get('c.getCummunityURL');
        
        action1.setStorable();
        action1.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var commuUrl = response.getReturnValue();
                //console.log(commuUrl);
                component.set("v.communityBaseURL",commuUrl[0]);
                component.set("v.communitySuffix",commuUrl[1]);
                var action = component.get('c.isRegistrationCompleted');
                action.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        component.set("v.registrationCompleted",response.getReturnValue());
                        //console.log('registrationCompleted' + component.get("v.registrationCompleted"));
                        if(!component.get("v.registrationCompleted")){
                            window.location.replace(commuUrl[0] + commuUrl[1] + "/s/agncustomerregistration2");
                        }
                        var action2 = component.get('c.hasAllerganDirectAccess');
                        action2.setCallback(this, function(ar) {
                            if(ar.getState() === 'SUCCESS'){
                                component.set("v.hasAlleganDirectAccess",ar.getReturnValue());
                            }else{
                                console.log(ar.getState());
                            }
                        });
                         $A.enqueueAction(action2);
                    }
                    else{
                        console.log(response.getState());
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action1);
    },
    isICLEnableForOAM : function(component, event) {
        var action = component.get('c.isICLEnabled');        
        action.setStorable();
        action.setCallback(this, function(response) {
            
            if(response.getState() === 'SUCCESS') {
                component.set("v.isICLEnabled", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})