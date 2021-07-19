/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-13-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement , track , api } from 'lwc';
import getAllAttachments from '@salesforce/apex/AGN_OAMDocumentUploaderShipto_CA.getShipToAttachments';
//import AGN_CP_UPLOAD_DOCS from '@salesforce/label/c.AGN_CP_UPLOAD_DOCS';
import { loadStyle } from 'lightning/platformResourceLoader';
//import ASSETS from '@salesforce/resourceUrl/AGN_CP_Assets';

export default class Agn_gcsp_shipToDocumentsUpload_ca extends LightningElement {

    @api registrationId;
    @track AttachmentList = [];
    @track WebSiteList = [];
    @track MissingAttachment = [];
    @track fileName = '';
    @track showUploadHeader = false;
    @api countryCode;
    isshiptoDoc = true;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    @track isTrue = false;
    @api requiredPending = false;
    @api source;
    @track isdepdoc = false;
    /*label = {
        AGN_CP_UPLOAD_DOCS
    };*/
    renderedCallback() {
       // loadStyle(this, ASSETS + '/assets/agn_cp_registration.css');
    }
    connectedCallback(){
        //console.log('get all attachments'+ this.registrationId);
        this.fetchAttachmentConfigs(this.registrationId);
    }
    
    fetchAttachmentConfigs(registrationId){
        //console.log('registrationId CA>>',registrationId);
        //console.log('this.source>>',this.source);
        getAllAttachments({parentRecId: registrationId, source: this.source, countryCode: this.countryCode})
        .then(result => {
            //console.log('result>>>>>>>>>>>>>>>>>>>',result);
            this.AttachmentList = result.attachmentWrapperList;
            var AttachmentList = result.attachmentWrapperList;
            //console.log('AttachmentList>>>>>>>>>>>>>>>>>>>>>>>',AttachmentList.length);
            if(AttachmentList.length > 0){
                this.showUploadHeader = true;
            }else{
                this.showUploadHeader = false;
            }
            var attList = AttachmentList;
                if (attList){
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
            console.log('error>>>>>>>>>>>>>>>>>>>',error);
            this.error = error;
        });
    }

    onupload(event){
        /*var AttachmentList = event.detail.AttachmentList;
        //console.log('Upload/Delete Action Competed>>>>>>>>>>>',AttachmentList);
        this.AttachmentList = AttachmentList;*/
        //console.log('Upload/Delete Action Competed>>>>>>>>>>>');
        this.requiredPending = event.detail.requiredPending;
       // this.fetchAttachmentConfigs(this.registrationId);
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