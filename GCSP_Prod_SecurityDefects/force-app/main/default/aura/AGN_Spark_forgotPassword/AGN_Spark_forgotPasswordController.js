({
    handleForgotPassword: function (component, event, helpler) {
        helpler.handleForgotPassword(component, event);
    },
    onKeyUp: function(component, event, helpler){
       
        if (event.getParam('keyCode')===13) {
            helpler.handleForgotPassword(component, event);
        }
    },
    
    setExpId: function (component, event, helper) {
        console.log("test3");
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },

    initialize: function(component, event, helper) {
        
   /*  var x = document.getElementsByClassName("loginlink_btn"); 
        if(x!=null){
     x.classList.remove("slds-button slds-button--neutral sfdc_button uiButton--default uiButton");
        }*/
      //  $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
    }
})