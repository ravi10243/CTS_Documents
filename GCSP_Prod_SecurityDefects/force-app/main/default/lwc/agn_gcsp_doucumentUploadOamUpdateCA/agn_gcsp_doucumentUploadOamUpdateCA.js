/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on: 05-22-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-18-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement, api } from 'lwc';
const MAX_FILE_SIZE = 100000000; //10mb  
export default class Agn_gcsp_doucumentUploadOamUpdateCA extends LightningElement {

    isDownload;
    downloadlink;
    isRequired;
    downloadLabel;
    showDelete;
   
    @api attachmentLabel;
    @api index = '';
    @api sapId;
    @api keyvalue;
    @api instancetype;

    showLoadingSpinner;
    showComponent;

    uploadedFiles = []; file; fileContents; fileReader; content; fileName 

    connectedCallback(){
        this.isRequired = false;
        //console.log('Shipto canada document:: ',this.attachmentLabel);
        //console.log('index:: '+this.index);
        //console.log('sapId:: '+JSON.stringify(this.sapId));
        //console.log('keyvalue:: '+JSON.stringify(this.keyvalue)); 
       /* if((this.sapId && this.keyvalue.includes(this.sapId)) || (this.index && this.keyvalue.includes(this.index))){
            this.shoeComponent = true;
        } */
         this.showComponent = false;
        if (this.keyvalue == this.index && this.instancetype == 'new' && this.attachmentLabel) {
            this.showComponent = true;
        } else if (this.keyvalue == this.sapId && this.instancetype == 'old' && this.attachmentLabel) {
             this.showComponent = true;
        } 
        //this.showComponent = this.sapId ? this.keyvalue.includes(this.sapId) : this.index ? this.keyvalue.includes(this.index) : false;
    }

    onFileUpload(event) { 
        this.showLoadingSpinner =true; 
        if (event.target.files.length > 0) {  
            this.uploadedFiles = event.target.files;      
            this.file = this.uploadedFiles[0];  
            if (this.file.size > MAX_FILE_SIZE) {  
                alert("File Size Can not exceed" + MAX_FILE_SIZE); 
                this.showLoadingSpinner =false; 
            }else{
                this.showDelete = true;
                this.fileName = event.target.files[0].name; 
                this.showLoadingSpinner =false; 
            }  
        }  
   }  

   @api getUploadFilesList(){
    var filesData = {file:this.file, fileName:this.fileName};
    
    if(this.isRequired && !this.file && !this.fileName){
        return 'RequiredDocument';
    }
    return filesData;
   }

    deleteAttachment(){
        this.showDelete = false;
        this.fileName = '';
        this.file = undefined;
    }


}