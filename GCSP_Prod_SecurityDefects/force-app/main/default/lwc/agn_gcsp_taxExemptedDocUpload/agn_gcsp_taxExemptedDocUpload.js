/* eslint-disable vars-on-top */
/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement , track , api } from 'lwc';
import getDependentAttachments from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getDependentAttachments';
//import AGN_CP_UPLOAD_DOCS from '@salesforce/label/c.AGN_CP_UPLOAD_DOCS';
import { loadStyle } from 'lightning/platformResourceLoader';
//import ASSETS from '@salesforce/resourceUrl/AGN_CP_Assets';

export default class Agn_gcsp_taxExemptedDocUpload extends LightningElement {
    @api registrationId;
    @api source;
    @api creteriaValue;
    @api fieldname;
    @api sobjectname;
    @track AttachmentList = [];
    @track DepAttachmentList = [];
    @track WebSiteList = [];
    @track MissingAttachment = [];
    @track fileName = '';
    @track showDepUpload = false;
    @track depDoc = true;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    @track isTrue = false;
    @api requiredPending = false;
    /*label = {
        AGN_CP_UPLOAD_DOCS
    };*/
    renderedCallback() {
       // loadStyle(this, ASSETS + '/assets/agn_cp_registration.css');
    }
    connectedCallback(){
        //console.log('get all attachments Dep'+ this.registrationId);        
        this.fetchDependentAttachments(this.registrationId);
    }

    fetchDependentAttachments(registrationId){
        //console.log('creteriaValue: ',this.creteriaValue);
        //console.log('source: ',this.source);
        //console.log('fieldname: ',this.fieldname);
        //console.log('sobjectname: ',this.sobjectname);
        //console.log('registrationId: ',registrationId);
        getDependentAttachments({parentRecId: registrationId,
        stepNo:'3',
        source: this.source,
        fieldName:this.fieldname, 
        objectname:this.sobjectname,
        creteriaValue:this.creteriaValue})
        .then(result => {
            //console.log('resultDep>>>>>>>>>>>>>>>>>>>',result);
            this.DepAttachmentList = result.attachmentWrapperList;          
            this.showDepUpload = true;

            if(this.DepAttachmentList.length > 0){
                this.showDepUpload = true;
            }else{
                this.showDepUpload = false;
            }
             //console.log('showDepUpload>>>>>>>>>>>>>>>>>>>',this.showDepUpload);
            var attList = this.DepAttachmentList;
            if(attList){
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
                var requiredPending = true;
                if(requiredTotalDocsCount === requiredInsertDocCount){
                    requiredPending = false;
                }
                this.requiredPending = requiredPending;
            }
        })
        .catch(error => {
            console.log('errorDep>>>>>>>>>>>>>>>>>>>',error);
            this.error = error;
        });
    }


    onupload(event){
        /*var AttachmentList = event.detail.AttachmentList;
        //console.log('Upload/Delete Action Competed>>>>>>>>>>>',AttachmentList);
        this.AttachmentList = AttachmentList;*/
        //console.log('Upload/Delete Action Completed Dep>>>>>>>>>>>');
        this.requiredPending = event.detail.requiredPending;
        //console.log('requiredPendingDep>>>>>>>>>>>'+this.requiredPending);
    }

    @api
    validateDocs(){
        if(this.requiredPending){
            this.template.querySelectorAll('c-agn_gcsp_file-upload').forEach(element => {
                element.validateDocuments();
           }); 
        }

    }

}