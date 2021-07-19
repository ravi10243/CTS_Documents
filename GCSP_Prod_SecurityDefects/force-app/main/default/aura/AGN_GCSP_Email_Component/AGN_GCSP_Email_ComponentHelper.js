({
    sendHelper: function(component, getEmail, getSubject, getbody,fromEmail)
    {
        var action = component.get("c.sendMailMethod");   
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'mailCCAddress':component.get("v.ccEmail"), 
            'mailBCCAddress':component.get("v.bccEmail"), 
            'atachID':component.get("v.attachId"),
            'caseID':component.get("v.recordId"),
            'fromEmail':component.get("v.fromEmail")
        });
        
        action.setCallback(this, function(response)
       		{
            	var state = response.getState();
                var returnValue = response.getReturnValue();
            	if (returnValue === "Success")
                {
                   
                	component.set("v.Spinner",false);
              		component.set("v.mailStatus", true);
                    $A.get('e.force:refreshView').fire(); 
                    component.set("v.email","");
              		component.set("v.ccEmail", "");
              		component.set("v.bccEmail", "");
                    component.set("v.attachmentName",null);
        			component.set("v.attachId",null);
        			component.set("v.closeattachment",false);
  					                    
            	}
                
        	});
        $A.enqueueAction(action);
       
        
    },
    
    
    populateFromAddress: function(component, event)
    {
        var action = component.get("c.getFromAddress");  
        action.setCallback(this, function(response) {
            
            var res=JSON.stringify(response.getReturnValue());           
            var parseRes= JSON.parse(res);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                 component.set("v.fromAddressOptions",parseRes); 
                 component.set("v.selectedfromAddress",parseRes[0]); 
                 component.set("v.fromEmail",parseRes[0]);
               	
            }   
          });
        $A.enqueueAction(action); 
        $A.get('e.force:refreshView').fire(); 
    },
    
    emailBodyHelper: function(component, event)
    {
        var action = component.get("c.getCaseDetails");  
        action.setParams({
            'caseId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            
            var res=JSON.stringify(response.getReturnValue());           
            var parseRes= JSON.parse(res);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                             
                 component.set("v.subject",'[' + parseRes.CaseNumber + '] ' + parseRes.Subject);
                 component.set("v.body","");
                
            }     
            else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors)
                {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else
                {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
        $A.get('e.force:refreshView').fire(); 
    },
    
})