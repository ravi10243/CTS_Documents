({
	doInit : function(component, event, helper) {
     	component.set("v.MissingAttachment", false);
        if(component.get("v.isSingleAttachment"))
            component.set("v.MissingAttachment",component.get("v.singleAttachmentIsRequired") );
        else{    
            console.log("[FileUpload].[=====controller=====]");
            helper.getDocumnetList(component); 
        }
    },
    
    uploadAttachment :function (component, event, helper){
        component.set("v.showSpinner", true )
        var auraId = event.target.id;
        var fileInput = document.getElementById(auraId);
        fileInput.files[0].description=fileInput.dataset.description;
        var existingAtachmentId=fileInput.dataset.attachmentid;
        console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
        if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){           
            helper.saveFile(component,event, fileInput, existingAtachmentId);
            console.log("[Dummy Method].[Calling]");
            helper.callDummyMethod(component); // This is only required for file upload
         }
    },
    
       uploadAttachmentLargeFile :function (component, event, helper){
        component.set("v.showSpinner", true )
        var auraId = event.target.id;
        var fileInput = document.getElementById(auraId);
        fileInput.files[0].description=fileInput.dataset.description;
        var existingAtachmentId=fileInput.dataset.attachmentid;
        console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
        if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){           
            helper.saveUploadedFile(component,event, fileInput, existingAtachmentId);
            console.log("[Dummy Method].[Calling]");
            helper.callDummyMethod(component); // This is only required for file upload
         }
    } 
            
                
})