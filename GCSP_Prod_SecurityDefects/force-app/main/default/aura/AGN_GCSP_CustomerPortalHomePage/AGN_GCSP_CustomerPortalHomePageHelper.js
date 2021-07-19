({
   
    getADOktaSSOUrl : function(component, event) {
        var action = component.get('c.getAD_OktaSSOUrl');        
        action.setCallback(this, function(response) {
           if(response.getState() === 'SUCCESS') {
                var adssourl = response.getReturnValue();
                component.set("v.adOktaSSOUrl",adssourl);
               console.log('adssourl::::',component.get("v.adOktaSSOUrl"));
            }
        });
        $A.enqueueAction(action);
    },   
       
    getCommunityUrl : function(component, event, helper){
        console.log('community url calling');
        var action1 = component.get('c.getCummunityURL');
        action1.setCallback(this, function(response) {
            console.log('Get community Url Res state:::', response.getState());
            if(response.getState() === 'SUCCESS'){
                var commuUrl = response.getReturnValue();                           
                component.set("v.communityBaseURL",commuUrl[0]);
                component.set("v.communitySuffix",commuUrl[1]);
                this.registrationCompleted(component, event, helper);
            }
        });
        $A.enqueueAction(action1);
        
    },
    registrationCompleted : function(component, event, helper) {       
        var action = component.get('c.isRegistrationCompleted');
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var isRegistartionComplete = response.getReturnValue();
                component.set("v.registrationCompleted",isRegistartionComplete);
                console.log('registrationCompleted:::::' + isRegistartionComplete);
                if(!isRegistartionComplete){
                   this.inprogressRegRedirectPage(component, event); 
                }
                this.hasAllerganDirectAccess(component, event);
            }
            else{
                console.log('Registration Status::::: ',response);
            }
        });
        $A.enqueueAction(action);
       
    },
    
    hasAllerganDirectAccess : function(component, event){
        var action2 = component.get('c.hasAllerganDirectAccess');
        action2.setCallback(this, function(ar) {
             console.log('has Allergan Res State::::',ar.getState());
           
            if(ar.getState() === 'SUCCESS'){
                component.set("v.hasAlleganDirectAccess",ar.getReturnValue());
            }
             console.log('has Allergan::::',component.get("v.hasAlleganDirectAccess"));
        });
        $A.enqueueAction(action2);
    },
    
    inprogressRegRedirectPage : function(component, event){
    	/*var action3 = component.get("c.getredirectUrl");
    	 action3.setCallback(this, function(result) {
             console.log('has Allergan Res State::::',result.getState());
            if(result.getState() === 'SUCCESS'){
    			console.log("redirect URl::", result.getReturnValue());
    			var redirectUrl = result.getReturnValue();
                if(redirectUrl){
                	window.location.replace(redirectUrl);
                }else{
                    var commuUrl = component.get("v.communityBaseURL");
                	var commuSuffex = component.get("v.communitySuffix");
                 	window.location.replace(commuUrl + commuSuffex + "/s/customer-registration-step4");
                 }
               
            }
        });*/
        console.log('Calling Registration');
       
        var action = component.get("c.getRegistrationStepPage");
        action.setCallback(this, function(result) {
            console.log('Allergan Res State::::',result.getReturnValue());
            
            if(result.getState() === 'SUCCESS'){
                /*var pageName = "";
                var result = result.getReturnValue();               
                if(result.includes("/s/")){
                    pageName = result.replace('/s', '');
                }else{
                    pageName = '/customer-registration-step4';
                }*/
                var returnURL = result.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");                
                urlEvent.setParams({
                    "url": returnURL
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
    
})