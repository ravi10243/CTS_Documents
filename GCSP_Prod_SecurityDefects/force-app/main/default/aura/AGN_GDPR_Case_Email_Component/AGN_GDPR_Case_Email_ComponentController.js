({
    doInit : function(component, event, helper)
    {       
        helper.emailBodyHelper(component, event);   
        
    },
        
    sendMail: function(component, event, helper) {
        
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var attachId = component.get("v.attachId");
        
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } 
        else 
        {
         //   component.set("v.Spinner",true);
            helper.sendHelper(component, getEmail, getSubject, getbody ,attachId);
        }
    },
    // Added by Kunal : Change required to enable DPO verified email content change box in case email tab 
    emailVerification: function(component, event, helper) {
         var checkCmp = component.find("DPOVerifiedMailContent");
		 component.set("v.DPOVerifiedMailContent",checkCmp.get("v.value"));
    },
    
    //Added by Namrata : Changes done for EmailType
    //Updated by Arijit
    populateEmailBodyForInformationType: function(component, event, helper){
     
        if(component.get("v.isRequestTypeInformation")===true)
        {
            
         var idstr = component.find('InputSelectInformation1'); 
        var val = idstr.get("v.value");
         if(val == $A.get('$Label.c.CCPA_Information_Complete_Picklist_AGN')){
            component.set("v.emailType","Information Task Completed");
            helper.populateEmailBodyForEmailType(component, event);
          
        }
        else if(val == $A.get('$Label.c.CCPA_Information_Failed_Picklist_AGN')){
           component.set("v.emailType","Information Task Failed");
           helper.populateEmailBodyForEmailType(component, event);
            
        }
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Information");
           helper.populateEmailBodyForEmailType(component, event);
           
       }
       else if(val == $A.get('$Label.c.CCPA_Information_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Information Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);
      
        }
      }
        if(component.get("v.displayEmailTypeForInformation")===true)
        {
            var idstr = component.find('InputSelectInformation2'); 
        var val = idstr.get("v.value");
          if(val == $A.get('$Label.c.CCPA_Information_Complete_Picklist_AGN')){
            component.set("v.emailType","Information Task Completed");
            helper.populateEmailBodyForEmailType(component, event);
          
        }
        else if(val == $A.get('$Label.c.CCPA_Information_Failed_Picklist_AGN')){
           component.set("v.emailType","Information Task Failed");
           helper.populateEmailBodyForEmailType(component, event);
            
        }
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Information");
           helper.populateEmailBodyForEmailType(component, event);
           
       }
       else if(val == $A.get('$Label.c.CCPA_Information_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Information Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);
          
        } 
        }
   },
    populateEmailBodyForAccessType: function(component, event, helper){
        console.log("Entertype");
        if(component.get("v.isRequestTypeAccess")===true)
        {
       var idstr = component.find('InputSelectAccess1');
       var val = idstr.get("v.value");
            console.log("Value"+val);
          if(val == $A.get('$Label.c.CCPA_Access_Failed_Picklist_AGN')){
            component.set("v.emailType","Access Request Type Failed");
              console.log('Emailtype'+component.get("v.emailType"));
            helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Access");
           helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.CCPA_Access_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Access Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);    
       }
       else if(val == $A.get('$Label.c.CCPA_Access_Info_Required_Picklist_AGN')){
           component.set("v.emailType","Access Info Required");
           helper.populateEmailBodyForEmailType(component, event);
                           
           }
        }
      if(component.get("v.displayEmailTypeForAccess")===true)
      {
          console.log('test');
        var idstr = component.find('InputSelectAccess2');
       var val = idstr.get("v.value");
          if(val == $A.get('$Label.c.CCPA_Access_Failed_Picklist_AGN')){
            component.set("v.emailType","Access Request Type Failed");
            helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Access");
           helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.CCPA_Access_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Access Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);    
       }
       else if(val == $A.get('$Label.c.CCPA_Access_Info_Required_Picklist_AGN')){
           component.set("v.emailType","Access Info Required");
           helper.populateEmailBodyForEmailType(component, event);
                           
           }
        }
          
     },
    populateEmailBodyForDeletionType: function(component, event, helper){
        if(component.get("v.isRequestTypeDeletion")===true)
        {
          
        var idstr = component.find('InputSelectDeletion1'); 
        var val = idstr.get("v.value");
        if(val == $A.get('$Label.c.Deletion_Complete_Picklist_AGN')){
			component.set("v.emailType","Deletion Completed");
            helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.Deletion_Partial_Complete_Picklist_AGN')){
           component.set("v.emailType","Deletion Partially Completed");
           helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.Deletion_Failed_Picklist_AGN')){
           component.set("v.emailType","Deletion Failed");
           helper.populateEmailBodyForEmailType(component, event);
        } 
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Deletion");
           helper.populateEmailBodyForEmailType(component, event);
        } 
        else if(val == $A.get('$Label.c.CCPA_Deletion_Info_Required_Picklist_AGN')){
           component.set("v.emailType","Deletion Info Required");
           helper.populateEmailBodyForEmailType(component, event);
       }
       else if(val == $A.get('$Label.c.CCPA_Deletion_Confirmation_mail_Picklist_AGN')){
           component.set("v.emailType","Deletion Confirmation Mail");
           helper.populateEmailBodyForEmailType(component, event);
       }
       else if(val == $A.get('$Label.c.CCPA_Deletion_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Deletion Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);      
       }
        }
        if(component.get("v.displayEmailTypeForDeletion")===true)
        {
             var idstr = component.find('InputSelectDeletion2'); 
        var val = idstr.get("v.value");
            console.log("value"+val);
        if(val == $A.get('$Label.c.Deletion_Complete_Picklist_AGN')){
			component.set("v.emailType","Deletion Completed");
            helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.Deletion_Partial_Complete_Picklist_AGN')){
           component.set("v.emailType","Deletion Partially Completed");
           helper.populateEmailBodyForEmailType(component, event);
        }
        else if(val == $A.get('$Label.c.Deletion_Failed_Picklist_AGN')){
           component.set("v.emailType","Deletion Failed");
           helper.populateEmailBodyForEmailType(component, event);
        } 
        else if(val == $A.get('$Label.c.CCPA_Others_Picklist_AGN')){
           component.set("v.emailType","Others Selected For Deletion");
           helper.populateEmailBodyForEmailType(component, event);
        } 
        else if(val == $A.get('$Label.c.CCPA_Deletion_Info_Required_Picklist_AGN')){
           component.set("v.emailType","Deletion Info Required");
           helper.populateEmailBodyForEmailType(component, event);
       }
       else if(val == $A.get('$Label.c.CCPA_Deletion_Confirmation_mail_Picklist_AGN')){
           component.set("v.emailType","Deletion Confirmation Mail");
           helper.populateEmailBodyForEmailType(component, event);
       }
       else if(val == $A.get('$Label.c.CCPA_Deletion_Info_Required_Generic_Picklist_AGN')){
           component.set("v.emailType","Deletion Generic Info Required");
           helper.populateEmailBodyForEmailType(component, event);      
          }
        }
    },
    //Updated by Arijit
    
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        //component.set("v.email", null);
        //component.set("v.subject", null);
        component.set("v.body", null);
        component.set("v.attachmentName",null);
        $A.get('e.force:refreshView').fire();
    },
    removeAttach :function(component, event, helper) {
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
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})