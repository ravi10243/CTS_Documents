/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 04-30-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-30-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import AGN_OAM_Download_Button from '@salesforce/label/c.AGN_OAM_Download_Button';
import saveChunk from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.saveChunk';
import deleteFile from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.deleteFile';
//import getAllAttachments from '@salesforce/apex/AGN_CP_DocumentUploaderStep3Utils.getAllAttachments';
import getAllAttachments from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getAllAttachments';
import getDependentAttachments from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getDependentAttachments';
import getAllAttachmentsForUpdate from '@salesforce/apex/AGN_GCSP_MultipleContactsController.getUpdateAttachments';
import getShipToAttachments from '@salesforce/apex/AGN_OAMDocumentUploaderShipto_CA.getShipToAttachments';

export default class Agn_gcsp_fileUpload extends LightningElement {

    @api parentid;
    @api attachment;
    @api description;
    @api source;
	@api creteriaValue;
    @api fieldname;
    @api sobjectname;
    @api isdepdoc = false;
    @api isUpdateDoc = false;
    @api isShiptoDoc=false;
    @api countrycode;
    @track isDownload;
    @track showDelete;
    @track attachmentid;
    @track attachmentname;
    @track downloadlink;
    @track showLoadingSpinner = false;
    
    MAX_DOC_FILE_SIZE_NEW =  5000000; //Max file size 5 MB 
    CHUNK_SIZE_NEW =  750000;
    label = {
        AGN_OAM_Download_Button
    };
    connectedCallback(){
        //console.log('inside fileupload connectedcallback>>'+JSON.stringify(this.attachment));
        this.showLoadingSpinner = false;
        this.setAttachmentDetails();
    }

    setAttachmentDetails(){
        this.isDownload = this.attachment.isDownload? true:false;
        //console.log('this.attachment.documentId>>>>>>>>>>>>>>>>>>>>>>>>>',this.attachment.documentId);
        //console.log('this.attachment.file>>>>>>>>>>>>>>>>>>>>>>>>>',this.attachment.file.Id);
        /*if(!this.attachment.file.Id){
            this.isDownload = false;
        }*/
        
        /*
        //THIS LOGIC IS TO DISPLAY DOWNLOAD BUTTON FOR ALL DOCS.
        //COMMENTING THIS LOGIC BECAUSE AS PER GCSP LOGIC, ONLY REQUIRED DOCS SHOULD HAVE THE DOWNLOAD BUTTON
        //THIS INVOLVES CODE CHANGES IN APEX AS WELL
        else{
            this.isDownload = true;
        }*/
        this.attachmentid = this.attachment.file.Id;
        this.description = this.attachment.file.Description;
        this.attachmentname = this.attachment.file.Name;
        this.showDelete = this.attachment.file.Name==null ? false : true;
        this.downloadlink = this.attachment.downloadLink;
        /*if(this.attachment.downloadLink){
            var link = this.attachment.downloadLink;
            var splitstr = link.split('file=');
            if(splitstr.length > 0){
                this.downloadlink = splitstr[0] + 'file='+ this.attachmentid;
            }
        }*/
        
        
    }

    uploadAttachmentLargeFile(event) {
        if(event.target.files.length > 0) {
            this.showLoadingSpinner = true;
            //console.log('event.target.files>>>>>>>>>>>>>>>>',event.target.files);
            var fileInput = event.target.files;
            //this.fileName = event.target.files[0].name;
            //console.log('filelist>>>>>>>>>>>>>>>',fileInput[0]);
            fileInput[0].description = this.description;
            var existingAtachmentId= this.attachmentid;
            //console.log("fileInput>>>>>>>>>>>>>>> "+fileInput);
            //console.log("existingAtachmentId>>>>>>>>>>>>> "+existingAtachmentId);
            //console.log("[FileUpload].[=====file=====]"+fileInput[0].name);
            if (typeof fileInput[0].name !== "undefined" && fileInput[0].name!=='' ){   
                //console.log('call saveUploadedFile');            
                this.saveUploadedFile( fileInput, existingAtachmentId); 
            }else{
                this.showLoadingSpinner = false;
            }
        }
    }

    saveUploadedFile( fileInput, attachmentRecId){
        //console.log(' saveFile@@@@ ');        
        //component.set("v.showSpinner", true);      
        //console.log('@@attachmentRecId@@ '+attachmentRecId);
        var file = fileInput[0];
        
        //console.log('file@@@@ '+file);
        
        if (file.size > this.MAX_DOC_FILE_SIZE_NEW) {
            alert('File size cannot exceed ' + (this.MAX_DOC_FILE_SIZE_NEW/1000000) + ' Mb.\n' +
                  'Selected file size: ' + (file.size/1000000)+'Mb');
            
            this.showLoadingSpinner = false;
            return;
        }
        var objFileReader = new FileReader();
        // set onload function of FileReader object
        objFileReader.onload = (() => {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            this.uploadProcess( file, fileContents,attachmentRecId);
        });
 
        objFileReader.readAsDataURL(file);
    }

    uploadProcess(file, fileContents,attachmentRecId) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE_NEW);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(file, fileContents, startPosition, endPosition,attachmentRecId, '');
    }

    uploadInChunk(file, fileContents,startPosition, endPosition,attachmentRecId, attachId) {
        //console.log('attachmentRecId>>>> '+attachmentRecId);
        //console.log('parentId>>>> '+this.parentid);
        //console.log('fileNAme>>>> '+file.name);
        //console.log('contentType>>>> '+file.type);
        //console.log('attachId>>>> '+attachId);
        var getchunk = fileContents.substring(startPosition, endPosition);
       // //console.log('fileContents>>>>>',fileContents);
       // //console.log('base64Data>>>>>',encodeURIComponent(getchunk));
        saveChunk({fileId : attachId,
            attachmentId: attachmentRecId,            
            parentId: this.parentid,
            fileName: file.name,            
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            description: file.description})
          .then(result => {
              //console.log('result attachment id>>>>>>>>>>>>>>>>>>>',result);
              if(result){
                  attachId = result;
                  startPosition = endPosition;
                  endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE_NEW);
                  if (startPosition < endPosition) {
                      //console.log('calling uploadchunk again>>>>>>>>');
                      this.uploadInChunk(file, fileContents,startPosition, endPosition,attachmentRecId, attachId);
                  }
                  if(startPosition === endPosition){
                      //console.log('calling refreshAttachments>>>>>>>>',file);  
                      this.attachmentid = attachId;
                      this.attachmentname = file.name;
                      this.description = file.description;
                      if(this.attachment.downloadLink){
                        var link = this.attachment.downloadLink;
                        var splitstr = link.split('file=');
                        if(splitstr.length > 0){
                            //this.downloadlink = splitstr[0] + 'file='+ this.attachmentid;
                            this.isDownload = true;
                        }
                      }
                      this.showDelete = true;
                      if(this.isUpdateDoc){
                        this.refreshAttachmentsForUpload();
                      }else if(this.isShiptoDoc){
                        this.refreshShiptoDocUpload();
                      }
                      else if(!this.isdepdoc){
                        this.refreshAttachments();
                      } 
                      else{
                        this.refreshAttachmentsDep();
                      }                       
                  }
              }else{
                this.showLoadingSpinner = false;
              }
          })
          .catch(error => {
              console.log('error>>>>>>>>>>>>>>>>>>>',error);
              this.showLoadingSpinner = false;
              this.error = error;
          });
        //console.log("rrr-6");
    }

    refreshAttachments(){
        //console.log('parentRecId>>>>>>>>>>>>>>',this.parentid);
        //console.log('source>>>>>>>>>>>>>>', this.source);
        getAllAttachments({
            parentRecId: this.parentid,
            source: this.source
        })
        .then(result => {
            //console.log('result>>>>>>>>>>>>>>>>>>>',result);
            var AttachmentList = result.attachmentWrapperList;
            var attList = AttachmentList;            
                
                if (attList){
                    var requiredTotalDocsCount=0; 
                    var requiredInsertDocCount=0; 
                    //var requiredToDownLoad = 0;
                    attList.forEach( function (att){  
                        if(att.isRequired) { 
                            requiredTotalDocsCount++;                                                        
                        }                        
                        if(att.isRequired && att.file.Name !== undefined ){
                            requiredInsertDocCount++;                           
                        }
                        //For download button
                        /*if(att.isDownload){
                            requiredToDownLoad++;
                        }*/
                        
                    });                   
                    //console.log('requiredTotalDocsCount@@@@@@--->'+requiredTotalDocsCount);
                    //console.log('requiredInsertDocCount@@@@@@-->'+requiredInsertDocCount);
                    var requiredPending = true;
                    if(requiredTotalDocsCount === requiredInsertDocCount){
                        requiredPending = false;
                    }
                    this.showLoadingSpinner = false;                    
                    var attData = { requiredPending: requiredPending};
                    const attachmentUploadEvent = new CustomEvent('attachmentupload' , { detail: attData });
                    // Dispatches the event.
                    this.dispatchEvent(attachmentUploadEvent); 
                } 
        })
        .catch(error => {
            console.log('error>>>>>>>>>>>>>>>>>>>',error);
            this.showLoadingSpinner = false;
        });
       
    }
    refreshAttachmentsDep(){
        //console.log('refreshAttachments>>>>>>>>>>>>>>');
        //console.log('refreshAttachments>>>>>>>>>>>>>>');
        getDependentAttachments({parentRecId:  this.parentid,
            stepNo:'3',
			source: this.source,
			fieldName:this.fieldname, 
			objectname:this.sobjectname,
			creteriaValue:this.creteriaValue})
        .then(result => {
            //console.log('result>>>>>>>>>>>>>>>>>>>',result);
            var AttachmentList = result.attachmentWrapperList;
            var attList = AttachmentList;
                
                if (attList){
                    var requiredTotalDocsCount=0; 
                    var requiredInsertDocCount=0; 
                    //var requiredToDownLoad = 0;
                    attList.forEach( function (att){  
                        if(att.isRequired) { 
                            requiredTotalDocsCount++;                                                        
                        }                        
                        if(att.isRequired && att.file.Name !== undefined ){
                            requiredInsertDocCount++;                           
                        }
                        //For download button
                        /*if(att.isDownload){
                            requiredToDownLoad++;
                        }*/
                        
                    });                   
                    //console.log('requiredTotalDocsCount@@@@@@--->'+requiredTotalDocsCount);
                    //console.log('requiredInsertDocCount@@@@@@-->'+requiredInsertDocCount);
                    var requiredPending = true;
                    if(requiredTotalDocsCount === requiredInsertDocCount){
                        requiredPending = false;
                    }
                    this.showLoadingSpinner = false;                   
                    var attData = { requiredPending: requiredPending};
                    const attachmentUploadEvent = new CustomEvent('attachmentupload' , { detail: attData });
                    // Dispatches the event.
                    this.dispatchEvent(attachmentUploadEvent); 
                } 
        })
        .catch(error => {
            console.log('error>>>>>>>>>>>>>>>>>>>',error);
            this.showLoadingSpinner = false;
        });
       
    }

    refreshAttachmentsForUpload(){
        //console.log('parentRecId>>>>>>>>>>>>>>',this.parentid);
        //console.log('source>>>>>>>>>>>>>>', this.source);
        getAllAttachmentsForUpdate({
            parentRecId: this.parentid,
            stepNo:'update',
            source: this.source
        })
        .then(result => {
            //console.log('result>>>>>>>>>>>>>>>>>>>',result);
            var AttachmentList = result.attachmentWrapperList;
            var attList = AttachmentList;            
                
                if (attList){
                    var requiredTotalDocsCount=0; 
                    var requiredInsertDocCount=0; 
                    //var requiredToDownLoad = 0;
                    attList.forEach( function (att){  
                        if(att.isRequired) { 
                            requiredTotalDocsCount++;                                                        
                        }                        
                        if(att.isRequired && att.file.Name !== undefined ){
                            requiredInsertDocCount++;                           
                        }
                        //For download button
                        /*if(att.isDownload){
                            requiredToDownLoad++;
                        }*/
                        
                    });                   
                    //console.log('requiredTotalDocsCount@@@@@@--->'+requiredTotalDocsCount);
                    //console.log('requiredInsertDocCount@@@@@@-->'+requiredInsertDocCount);
                    var requiredPending = true;
                    if(requiredTotalDocsCount === requiredInsertDocCount){
                        requiredPending = false;
                    }
                    this.showLoadingSpinner = false;                    
                    var attData = { requiredPending: requiredPending};
                    const attachmentUploadEvent = new CustomEvent('attachmentuploadupdate' , { detail: attData });
                    // Dispatches the event.
                    this.dispatchEvent(attachmentUploadEvent); 
                } 
        })
        .catch(error => {
            console.log('error>>>>>>>>>>>>>>>>>>>',error);
            this.showLoadingSpinner = false;
        });
       
    }

    deleteAttachment(){
        //console.log('delete attachment>>>>>>>>>>>>'+this.attachmentid);
        this.showLoadingSpinner = true;
        deleteFile({fileId : this.attachmentid})
          .then(result => {
              //console.log('result>>>>>>>>>>>>>>>>>>>',result);
              this.showDelete = false;
              //this.isDownload = false;
              this.attachmentid = '';
              if(this.isUpdateDoc){
                this.refreshAttachmentsForUpload();
              }
              else if(!this.isdepdoc){
                this.refreshAttachments();
              } 
              else{
                this.refreshAttachmentsDep();
              }             
             
          })
          .catch(error => {
              console.log('error>>>>>>>>>>>>>>>>>>>',error);
              this.showLoadingSpinner = false;
              this.error = error;
          });
    }

    @api
    validateDocuments(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            //console.log('doc elements>>>>>>>>>>>',element.required);
            if(element.required){              
               element.reportValidity();
            }
       }); 
    }

}