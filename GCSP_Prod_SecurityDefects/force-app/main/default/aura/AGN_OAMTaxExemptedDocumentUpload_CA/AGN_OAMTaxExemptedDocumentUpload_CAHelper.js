({
    getShipToDocumnetListTax: function(component, event, helper) {

        //console.log("[FileUpload].[=====helper1=====]");
        var action = component.get("c.getTaxExemptedAttachment");
        action.setParams({
            "parentRecId": component.get("v.customerRegId"),
            "taxexempted" : component.get("v.taxExemptedVal")
        });
        
        //console.log("[Flow Util Method].[Called Apex method]");
        action.setCallback(this, function(response) {    
            //console.log("[Flow Util Method].[inside callBack]===> 3-->"+response.getState());
          
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.AttachmentList", response.getReturnValue().attachmentWrapperList);
                
               // component.set("v.AttachmentListObj", response.getReturnValue().attachmentWrapperList);
                
                component.set("v.MissingAttachment", response.getReturnValue().missingAttachment);
                component.set("v.showSpinner", false); 
                var attList = component.get("v.AttachmentList");
                
                console.log('@@@attList>>>>'+JSON.stringify(component.get("v.AttachmentList")));
                //console.log('@@@Obj>>>>'+JSON.stringify(component.get("v.AttachmentListObj")));
                
                if ($A.util.isArray(attList)){
                    var requiredTotalDocsCount=0; 
                    var requiredInsertDocCount=0; 
                    attList.forEach( function (att){  
                        if(att.isRequired) { 
                            requiredTotalDocsCount++;                                                        
                        }                        
                        if(att.isRequired && att.file.Name !== undefined ){
                            requiredInsertDocCount++;                           
                        }  
                    });                   
                    //console.log('requiredTotalDocsCount@@@@@@--->'+requiredTotalDocsCount);
                    //console.log('requiredInsertDocCount@@@@@@-->'+requiredInsertDocCount);
                    attList.forEach( function (att){
                        if(requiredTotalDocsCount == requiredInsertDocCount){                            
                            var missdoc = component.getEvent("isManadteTaxExemptingDocmant"); 
                            missdoc.setParams({"isMandateDoc":true});                           
                            missdoc.fire();
                        }else{
                            var missdoc = component.getEvent("isManadteTaxExemptingDocmant");
                            missdoc.setParams({"isMandateDoc":false});
                            missdoc.fire();
                        }
                 
                    });  
                }
            }
            else component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action); 
        
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
                helper.getShipToDocumnetListTax(component);
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
   
    MAX_DOC_FILE_SIZE_NEW: 5000000, //Max file size 5 MB 
    CHUNK_SIZE_NEW: 750000,  //Chunk Max size 750Kb
    saveUploadedFile : function(component,event, fileInput,attachmentRecId) {
        
        console.log(' saveFile@@@@ ');
        component.set("v.showSpinner", true);      
        console.log('@@attachmentRecId@@ '+attachmentRecId);
        var file = fileInput.files[0];
        
        console.log('file@@@@ '+file);
        
        if (file.size > this.MAX_DOC_FILE_SIZE_NEW) {
            alert('File size cannot exceed ' + (this.MAX_DOC_FILE_SIZE_NEW/1000000) + ' Mb.\n' +
                  'Selected file size: ' + (file.size/1000000)+'Mb');            
            component.set("v.showSpinner", false);
            return;
        }
        var self = this;
        
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component,event, file, fileContents,attachmentRecId);
        });
        
        objFileReader.readAsDataURL(file);
        
        
    },
    uploadProcess: function(component,event, file, fileContents,attachmentRecId) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE_NEW);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition,attachmentRecId, '');
    },
    
    uploadInChunk : function(component,file, fileContents,startPosition, endPosition,attachmentRecId, attachId) {
        var self = this;
        console.log("inside upload function. parent="+component.get("v.customerRegId"));
        var actionFile;
        
        console.log('attachmentRecId@@ '+attachmentRecId);
        console.log('parentId@@ '+component.get("v.customerRegId"));
        console.log('fileNAme@@ '+file.name);
        console.log('contentType@@ '+file.type);
        console.log('attachId@@1 '+attachId);
        var getchunk = fileContents.substring(startPosition, endPosition);
        actionFile = component.get("c.saveChunk");
        actionFile.setParams({
            
            "fileId": attachId,
            "attachmentId": attachmentRecId,            
            "parentId": component.get("v.customerRegId"),
            "fileName": file.name,            
            "base64Data": encodeURIComponent(getchunk),
            "contentType": file.type,
            "description": file.description
        });
        //self.callDummyMethod(component); base64Data: encodeURIComponent(getchunk),
        var self = this;
        actionFile.setCallback(this, function(response) {
            
            console.log("inside callback");
            attachId = response.getReturnValue();
            var status = response.getState();
            console.log('attachId@@2 : '+attachId);
            console.log('status@@ '+status);
            if(status === "SUCCESS"){
                //alert("file loaded successfully");
                
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE_NEW);
                if (startPosition < endPosition) {
                    self.uploadInChunk(component,file, fileContents,startPosition, endPosition,attachmentRecId, attachId);
                }
                component.set("v.showSpinner", false);
                if(startPosition=endPosition){
                    
                    if(component.get("v.isSingleAttachment")){
                        component.set("v.singleAttachmentName", file.name);                     
                        component.set("v.MissingAttachment", false);
                    }
                    else{
                        component.set("v.showSpinner", false);                        
                        this.getShipToDocumnetListTax(component,event);
                    }
                    
                }
                
                console.log('clear interval due to navigation if');
                window.clearInterval(component.get("v.setIntervalId"));
            }
            else {
                //alert("failed to upload file");
                component.set("v.showSpinner", false);
                console.log('clear interval due to navigation else');
                window.clearInterval(component.get("v.setIntervalId"));
            }
        });
        console.log("rrr-5");
        $A.enqueueAction(actionFile);
        console.log("rrr-6");
    },
    // this is new function upload file upto 5.7 mb end
    callDummyMethod : function(component){
        //component.set("v.showSpinner", false);
        console.log("[Dummy Method].[inside Method]");
        var action = component.get("c.saveTestFile");
        console.log("[Dummy Method].[Called Apex method]");
        action.setCallback(this, function(response) {     
            console.log("[Dummy Method].[inside callBack]");       
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                console.log("Dummy Case Number : "+response.getReturnValue());                
                component.set("v.showSpinner", false);
            }
            else console.log("Dummy Case Number : Null"); 
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    callDummyMethod1 : function(component){
        //component.set("v.showSpinner", false);
        console.log("[Dummy Method].[inside Method]");
    },
    
})