({
    doInit : function(component, event, helper) {       
        component.set("v.MissingAttachment", false);
        if(component.get("v.isSingleAttachment")){           
            component.set("v.MissingAttachment",component.get("v.singleAttachmentIsRequired") );
        }else{    
            console.log("[FileUpload].[=====controller=====]");
            helper.getDocumnetList(component); 
        }
    },
    
    deleteAttachment : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var attachmentId = event.currentTarget.getAttribute("data-value");
        console.log(':::File Id:::',attachmentId);
        
        var action = component.get("c.deleteFile");
        action.setParams({ fileId : attachmentId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("File has been deleted");
                //reload document list
                helper.getDocumnetList(component);
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    // this is old function is uploading upto 2.5 mb file
    uploadAttachment :function (component, event, helper){
        //component.set("v.showSpinner", true );
        var auraId = event.target.id;
        var fileInput = document.getElementById(auraId);
        fileInput.files[0].description=fileInput.dataset.description;
        var existingAtachmentId=fileInput.dataset.attachmentid;
        console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
        if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){               
            helper.saveFile(component,event, fileInput, existingAtachmentId);        
            
            console.log("[Dummy Method].[Calling]");            
            //helper.callDummyMethod(component); // This is only required for file upload
            //execute callDummyMethod() again after 1 sec each
            var interval = window.setInterval(
                $A.getCallback(function() { 
                    helper.callDummyMethod1(component);
                }), 2000
            );
            component.set("v.setIntervalId", interval) ;
        }
    } ,
    // this function is uploading upto 5.7 mb file
    uploadAttachmentLargeFile :function (component, event, helper){
        //component.set("v.showSpinner", true );
        var auraId = event.target.id;
        var fileInput = document.getElementById(auraId);
        console.log("@@fileInput@@ "+fileInput);
        fileInput.files[0].description=fileInput.dataset.description;
        var existingAtachmentId=fileInput.dataset.attachmentid;
        
        console.log("@@@fileInput@@@ "+fileInput);
        console.log("@@@existingAtachmentId@@@ "+existingAtachmentId);
        console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
        if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){               
            helper.saveUploadedFile(component,event, fileInput, existingAtachmentId);        
            
            var interval = window.setInterval(
                $A.getCallback(function() { 
                    helper.callDummyMethod1(component);
                }), 2000
            );
            component.set("v.setIntervalId", interval) ;
        }
    } 
    
})