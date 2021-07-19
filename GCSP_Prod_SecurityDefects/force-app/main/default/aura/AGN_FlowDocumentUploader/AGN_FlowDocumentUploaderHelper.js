({
	getDocumnetList: function(component, event, helper) {
        console.log("[FileUpload].[=====helper1=====]");
                                           
        var action = component.get("c.getAllAttachments");
        action.setParams({
            "parentRecId": component.get("v.custRegId"),
            "documentList": component.get("v.nameOfDocuments")
        });
        
        console.log("[Flow Util Method].[Called Apex method]");
        action.setCallback(this, function(response) {     
            console.log("[Flow Util Method].[inside callBack]");       
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.AttachmentList", response.getReturnValue().attachmentWrapperList);
                component.set("v.MissingAttachment", response.getReturnValue().missingAttachment);
                component.set("v.WebSiteList", response.getReturnValue().webSiteList);
                console.log("[Flow Util Method].[inside callBack]"+ component.get("v.MissingAttachment")); 
                component.set("v.showSpinner", false);
            }
            else component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action); 
		
	},
    
    MAX_DOC_FILE_SIZE: 2500000, /* 1 000 000 * 3/4 to account for base64 */

    saveFile : function(component,event, fileInput,attachmentRecId) {
    
        component.set("v.showSpinner", true);
        console.log("[FileUpload].[save]");
        var file = fileInput.files[0];

  
        if (file.size > this.MAX_DOC_FILE_SIZE) {
            alert('File size cannot exceed ' + (this.MAX_DOC_FILE_SIZE/1000000) + ' Mb.\n' +
              'Selected file size: ' + (file.size/1000000)+'Mb');
            return;
        }

        var fr = new FileReader();

        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            console.log("[FileUpload].[Calling Upload]");
            self.upload(component,event, file, fileContents,attachmentRecId);
            console.log("[FileUpload].[Called Upload]");
        };


        fr.readAsDataURL(file);
    },

    upload : function(component,event, file, fileContents,attachmentRecId) {
        console.log("inside upload function. parent="+component.get("v.custRegId"));
        var actionFile;
        console.log("[FileUpload].["+ file.name+ "]"+"["+ attachmentRecId+ "]");
        actionFile = component.get("c.saveFile");
        actionFile.setParams({
            
            "attachmentId": attachmentRecId,
            "parentId": component.get("v.custRegId"),
            "fileName": file.name,
            "base64Data": encodeURIComponent(fileContents),
            "contentType": file.type,
            "description": file.description
        });
        actionFile.setCallback(this, function(response) {
			
            var status = response.getState();
            if(status === "SUCCESS"){
                alert("file loaded successfully");
                if(component.get("v.isSingleAttachment")){
                    component.set("v.singleAttachmentName", file.name); 
                    component.set("v.MissingAttachment", false);
                }
                else{
                	component.set("v.showSpinner", false);    
                	this.getDocumnetList(component,event);
                }
            }
            else {
                alert("failed to upload file");
                component.set("v.showSpinner", false);
            }
        });
        console.log("rrr-5");
        $A.enqueueAction(actionFile);
        console.log("rrr-6");
    },

     // added by abdul
    
        
     MAX_DOC_FILE_SIZE_NEW: 5000000, //Max file size 5 MB 
    CHUNK_SIZE_NEW: 750000,      //Chunk Max size 750Kb 
    
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
               
                //window.clearInterval(component.get("v.setIntervalId"));
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
        
        //component.set("v.showSpinner", true); 
        var self = this;
        console.log("inside upload function. parent="+component.get("v.custRegId"));
        var actionFile;
      
        console.log('attachmentRecId@@ '+attachmentRecId);
        console.log('parentId@@ '+component.get("v.custRegId"));
        console.log('fileNAme@@ '+file.name);
        console.log('contentType@@ '+file.type);
        console.log('attachId@@1 '+attachId);
        var getchunk = fileContents.substring(startPosition, endPosition);
        actionFile = component.get("c.saveChunk");
        actionFile.setParams({
            
            "fileId": attachId,
            "attachmentId": attachmentRecId,            
            "parentId": component.get("v.custRegId"),
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
               component.set("v.showSpinner", false);  
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE_NEW);
               if (startPosition < endPosition) {
                    self.uploadInChunk(component,file, fileContents,startPosition, endPosition,attachmentRecId, attachId);
               }else{
                   
                   alert("file loaded successfully");
                    if(component.get("v.isSingleAttachment")){
                        
                       //alert("file loaded successfully");
                        component.set("v.singleAttachmentName", file.name); 
                        component.set("v.MissingAttachment", false);
                    }
                    else{
                       // alert("file loaded successfully");
                        component.set("v.showSpinner", false);    
                        this.getDocumnetList(component,event);
                    }
                   
               }
              
            }
            else {
                

                alert("failed to upload file ");
                component.set("v.showSpinner", false);
                console.log('clear interval due to navigation else');
                window.clearInterval(component.get("v.setIntervalId"));
            }
           
            
            
            
        });
        console.log("rrr-5");
        $A.enqueueAction(actionFile);
        console.log("rrr-6");
    },
    
    
    
    // end by abdul
    
    
    callDummyMethod : function(component){
        component.set("v.showSpinner", false);
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

})