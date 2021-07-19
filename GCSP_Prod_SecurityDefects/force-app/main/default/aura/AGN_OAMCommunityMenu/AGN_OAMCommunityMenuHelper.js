({
	getADOktaSSOUrl : function(component, event) {
        var action = component.get('c.getAD_OktaSSOUrl');
        
        action.setStorable();
        action.setCallback(this, function(response) {
            //console.log(response.getState());
            if(response.getState() === 'SUCCESS') {
                var adssourl = response.getReturnValue();
                //console.log("AD URL " + adssourl);
                component.set("v.adOktaSSOUrl",adssourl);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityURL : function(component, event) {
        
        var action = component.get('c.getCummunityURL');
        
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var commuUrl = response.getReturnValue();
                console.log(commuUrl);
                component.set("v.communityBaseURL",commuUrl[0]);
                component.set("v.communitySuffix",commuUrl[1]);
            }
        });
        $A.enqueueAction(action);
    }
})