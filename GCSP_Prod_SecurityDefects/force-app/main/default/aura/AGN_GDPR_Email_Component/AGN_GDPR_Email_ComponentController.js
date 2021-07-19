({
    doInit : function(component, event, helper)
    {
        helper.emailBodyHelper(component, event);
    },
    
    sendMail: function(component, event, helper) {
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody);
        }
    },
    
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        helper.emailBodyHelper(component, event);       
    },
})