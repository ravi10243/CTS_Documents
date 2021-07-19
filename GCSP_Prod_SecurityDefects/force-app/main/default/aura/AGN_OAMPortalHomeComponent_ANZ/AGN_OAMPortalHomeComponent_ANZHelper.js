({
    getcustomerAccountDetails : function(component, event) {
        var action = component.get('c.getAccountHeaderDetails');        
        //action.setStorable();
        action.setCallback(this, function(response) {
            
            if(response.getState() === 'SUCCESS') {
                var customerAcc = response.getReturnValue();
                component.set("v.customerAcc",customerAcc);
                //ICL
                /*var clinictype = component.get("v.customerAcc").Customer_Category_AGN__c;
                if(clinictype.includes("Clinic") || clinictype.includes("clinic"))
                {
                    component.set("v.isClinic",true);
                }*/
                console.log('component.get("v.customerAcc").'+component.get("v.customerAcc").Id)
                component.set("v.isICLEnabledInAccount", component.get("v.customerAcc").IsICLEnabled_AGN__c);
                this.isICLEnableForOAM(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    getADOktaSSOUrl : function(component, event) {
        var action = component.get('c.getAD_OktaSSOUrl');
        
        //action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var adssourl = response.getReturnValue();
                //console.log('adssourl' + adssourl);
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
                //console.log('commuUrl>>>>>>>>>'+commuUrl);
                component.set("v.communityBaseURL",commuUrl[0]);
                component.set("v.communitySuffix",commuUrl[1]);
                var action = component.get('c.isRegistrationCompleted');
                action.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        component.set("v.registrationCompleted",response.getReturnValue());
                        //console.log('registrationCompleted>>>>>' + component.get("v.registrationCompleted"));
                        if(!component.get("v.registrationCompleted")){
                            window.location.replace(commuUrl[0] + commuUrl[1] + "/s/agncustomerregistration2");
                        }
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
        console.log('xdffsdfsf');
        var action = component.get('c.isICLEnabled');        
        action.setStorable();
        action.setCallback(this, function(response) {
            console.log('response.getState()'+response.getState());
            if(response.getState() === 'SUCCESS') {
                var iclinfo = response.getReturnValue();
                var jsoniclinfo = JSON.parse(JSON.stringify(iclinfo));
                component.set("v.isICLEnabled",jsoniclinfo["OAMEnabled"]);
                var iclclinictype = jsoniclinfo["customercategory"];
                iclclinictype = iclclinictype.toLowerCase();
                var clinictype = component.get("v.customerAcc").Customer_Category_AGN__c;
                clinictype = clinictype.toLowerCase();
                if(clinictype.includes(iclclinictype))
                {
                    component.set("v.isClinic",true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})