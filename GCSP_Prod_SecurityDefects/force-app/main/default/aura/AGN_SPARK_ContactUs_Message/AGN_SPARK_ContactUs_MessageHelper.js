({
	sendEmailMessage : function(component, event, helper) { 
        var sparkMessage = component.get("v.SparkMessage");
        var action = component.get("c.sendMailmessage");
        action.setParams({
            "name"    : sparkMessage.name,
            "fromEmail"   : sparkMessage.email,
            "message" : sparkMessage.message
        });
        action.setCallback(this, function (response) {
            var isEmailSendResult = response.getReturnValue();
            console.log('isEmailSendResult ' + isEmailSendResult);
            if (isEmailSendResult) {   
                component.set("v.isEmailSend", isEmailSendResult);
                component.set("v.EmailSendMessage", $A.get("$Label.c.AGN_SPARK_Email_Success_Message"));
            }  
            else if(!isEmailSendResult) {
                component.set("v.isEmailSend", isEmailSendResult);
                component.set("v.EmailSendMessage", $A.get("$Label.c.AGN_SPARK_Email_Fail_Message"));
            } 
        });
        $A.enqueueAction(action);        
    },
    
})