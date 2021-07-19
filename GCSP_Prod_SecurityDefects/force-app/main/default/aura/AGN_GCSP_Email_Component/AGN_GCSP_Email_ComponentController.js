({
    doInit : function(component, event, helper)
    {
        helper.populateFromAddress(component, event);
        helper.emailBodyHelper(component, event);
    },
    
    setFromAddressInEmail : function(component, event, helper)
    {
        var getfromEmail = component.get("v.selectedfromAddress"); 
        component.set("v.fromEmail",getfromEmail);
    },
    
    sendMail: function(component, event, helper) {
        var getEmail = component.get("v.email");                
        var getSubject = component.get("v.subject"); 
        var getbody = component.get("v.body");
        var getCCEmail = component.get("v.ccEmail");
        var getBCCEmail = component.get("v.bccEmail");
        var getfromEmail = component.get("v.fromEmail")
        
        var invalidEmailId = false;
        
        if ($A.util.isEmpty(getEmail)) 
        {
            alert($A.get('$Label.c.AGN_OAM_GCSP_TOEmailAlert'));
        }
        else 
        {
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;                                  
            var toList = getEmail.split(';');
            for(var i=0;i<toList.length;i++)
            {
                if(!toList[i].match(regExpEmailformat) && !($A.util.isEmpty(toList[i])) && toList[i].trim().length >0)
                {
                    invalidEmailId = true;
                }            
            }
            
            if(!($A.util.isEmpty(getCCEmail)))
            {
                var cc = getCCEmail.split(';');
                for(var i=0;i<cc.length;i++)
                {
                    if(!cc[i].match(regExpEmailformat) && !($A.util.isEmpty(cc[i])) && cc[i].trim().length > 0)
                    {
                        console.log('cc[i]'+cc[i]);
                        invalidEmailId = true;
                    }
                }
            }
            if(!($A.util.isEmpty(getBCCEmail)))
            {
                var bcc =  getBCCEmail.split(';');
                for(var i=0;i<bcc.length;i++)
                {
                    if(!bcc[i].match(regExpEmailformat) && !($A.util.isEmpty(bcc[i])) && bcc[i].trim().length > 0)
                    {
                        invalidEmailId = true;     
                    }
                }
            }
            if(invalidEmailId == false)
            {
                component.set("v.Spinner",true);
                helper.sendHelper(component, getEmail, getSubject, getbody,getfromEmail);
            }
            else if(invalidEmailId == true)
            {
             alert($A.get('$Label.c.AGN_OAM_GCSP_InavlidEmailAlert'));   
            }
        }
    },
    
     removeAttach :function(component, event, helper)
    {
        component.set("v.attachmentName",null);
        component.set("v.attachId",null);
        component.set("v.closeattachment",false);
    },
    
    handleUploadFinished: function (component, event ,helper)
    {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        component.set("v.attachId",documentId);
        component.set("v.attachmentName",fileName);
        component.set("v.closeattachment",true);
              
    },
    
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        helper.emailBodyHelper(component, event);       
    },
})