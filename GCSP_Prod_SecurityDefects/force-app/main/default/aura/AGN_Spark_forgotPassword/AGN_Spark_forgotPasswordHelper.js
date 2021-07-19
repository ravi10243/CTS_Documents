({
    qsToEventMap: {
        'expid'  : 'e.c:setExpId'
    },
    

    
    handleForgotPassword: function (component, event) {

        var userName = component.find("username").get("v.value");
        if($A.util.isEmpty(userName)){
                component.set("v.showError",true);
                component.set("v.errorMessage", 'Please enter the username');
            return;
        }
        component.set("v.showError",false);
        var checkEmailUrl = component.get("v.checkEmailUrl");

        var action = component.get("c.forgotPassword");
        action.setParams({
             username		: userName, 
             checkEmailUrl	: checkEmailUrl
        });
        action.setCallback(this, function(a) {
            
            var rtnValue = JSON.parse(a.getReturnValue());
            if (!$A.util.isEmpty(rtnValue)) {
                if(rtnValue.message == 'The password reset has been sent to your email.'){
                    rtnValue.message = 'The password reset communication has been sent to your email';
                }
                
                component.set("v.isSuccess", rtnValue.isSuccess);
                //alert(rtnValue.isSuccess + '  & '+rtnValue.message);
                if(rtnValue.isSuccess == false){
               		component.set("v.showError",true);
                }
                component.set("v.errorMessage", rtnValue.message);
            }
       });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {

        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})