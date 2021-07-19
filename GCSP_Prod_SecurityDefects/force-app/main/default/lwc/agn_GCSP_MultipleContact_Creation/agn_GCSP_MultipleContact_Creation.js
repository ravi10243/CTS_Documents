/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 07-09-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-02-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement, wire,track,api } from 'lwc';
import NAME1_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.SAP_Name_1_AGN__c';
import ADDRESS_LINE_1_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Address_Line_1_AGN__c';
import COUNTRY_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Country_AGN__c';
import SOLD_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Sold_To_AGN__c';
import SHIP_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Ship_To_AGN__c';
import BILL_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Bill_To_AGN__c';

import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getLayout';
import fetchCountryList from '@salesforce/apex/AGN_GCSP_PortalCustomerRegUtils.fetchCountryList';
import getexistingData from '@salesforce/apex/AGN_GCSP_MultipleContactsController.doInit';
import saveAcrContactsAffiliation from '@salesforce/apex/AGN_GCSP_MultipleContactsController.saveAcrContactsAffiliation';
import getGCSPSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings';
import AGN_OAM_Body_Confirm_Youhave from '@salesforce/label/c.AGN_OAM_Body_Confirm_Youhave';
import AGN_OAM_Body_Confirm_SuccessfullyCompleted from '@salesforce/label/c.AGN_OAM_Body_Confirm_SuccessfullyCompleted';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';
import AGN_OAM_Basic_Information_Heading from '@salesforce/label/c.AGN_OAM_Basic_Information_Heading';
import AGN_OAM_Address_Details_Heading from '@salesforce/label/c.AGN_OAM_Address_Details_Heading';
import AGN_OAM_Document_Upload_Heading from '@salesforce/label/c.AGN_OAM_Document_Upload_Heading';
import AGN_OAM_Confirmation_Heading from '@salesforce/label/c.AGN_OAM_Confirmation_Heading';
import AGN_OAM_Contact_Affiliation from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_Header_CustomerRegistration from '@salesforce/label/c.AGN_OAM_Header_CustomerRegistration';
import AGN_GCSP_Edit_Button from '@salesforce/label/c.AGN_GCSP_Edit_Button';
import AGN_GCSP_Close_Button from '@salesforce/label/c.AGN_GCSP_Close_Button';
import AGN_OAM_CaseNumber from '@salesforce/label/c.AGN_OAM_CaseNumber';
import AGN_GCSP_CaseDetails from '@salesforce/label/c.AGN_GCSP_CaseDetails';
import AGN_GCSP_CasePriority from '@salesforce/label/c.AGN_GCSP_CasePriority';
import AGN_OAM_CaseRequestToQA from '@salesforce/label/c.AGN_OAM_CaseRequestToQA';
import AGN_Confirm_ContactAffiliationMsg from '@salesforce/label/c.AGN_Confirm_ContactAffiliationMsg';

import AGN_GCSP_ExistingContacts from '@salesforce/label/c.AGN_GCSP_ExistingContacts';
import AGN_GCSP_NewContacts from '@salesforce/label/c.AGN_GCSP_NewContacts';
import AGN_GCSP_NewContactDescription from '@salesforce/label/c.AGN_GCSP_NewContactDescription';
import AGN_GCSP_AddNewContact from '@salesforce/label/c.AGN_GCSP_AddNewContact';
import AGN_GCSP_SubmitContact from '@salesforce/label/c.AGN_GCSP_SubmitContact';
import AGN_GCSP_ContactAddAffiliation  from '@salesforce/label/c.AGN_GCSP_ContactAddAffiliation';
import AGN_GCSP_Affiliations from '@salesforce/label/c.AGN_GCSP_Affiliations';
import AGN_GCSP_NewAffiliations  from '@salesforce/label/c.AGN_GCSP_NewAffiliations';

import AGN_GCSP_STEP1 from '@salesforce/label/c.AGN_GCSP_STEP1';
import AGN_GCSP_STEP2 from '@salesforce/label/c.AGN_GCSP_STEP2';
import AGN_GCSP_STEP3  from '@salesforce/label/c.AGN_GCSP_STEP3';
import AGN_GCSP_STEP4 from '@salesforce/label/c.AGN_GCSP_STEP4';
import AGN_GCSP_STEP5  from '@salesforce/label/c.AGN_GCSP_STEP5';

import AGN_OAM_Required_Fields_Missing_Error  from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';
import AGN_OAM_Body_PleaseCheckFormatFor  from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Loading  from '@salesforce/label/c.AGN_OAM_Loading';
import AGN_OAM_RequiredDocument_ErrorMsg  from '@salesforce/label/c.AGN_OAM_RequiredDocument_ErrorMsg';


import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import CASE from '@salesforce/schema/Case';
import CASE_PRIORITY from '@salesforce/schema/Case.Priority';



import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';


import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

const addressColumns = [
    { label: 'Name', fieldName: NAME1_FIELD.fieldApiName, type:'text' },
    { label: 'Address Line 1', fieldName: ADDRESS_LINE_1_FIELD.fieldApiName, type:'text' },
    { label: 'Country', fieldName: COUNTRY_FIELD.fieldApiName, type:'text' },
    { label: 'Sold To', fieldName: SOLD_TO_FIELD.fieldApiName, type: 'boolean' },
    { label: 'Ship To', fieldName: SHIP_TO_FIELD.fieldApiName, type: 'boolean' },
    { label: 'Bill To', fieldName: BILL_TO_FIELD.fieldApiName, type: 'boolean' }
];

const MAX_FILE_SIZE = 100000000; //10mb 
const CHUNK_SIZE_NEW =  750000;
export default class Agn_GCSP_MultipleContact_Creation extends LightningElement {
     data;
     error;
     flag = false;

    addrcols = addressColumns;

    @api caseId = '';
    @api sapId = '';
    
    @api existingSoldTo;
    @api existingShipTo;
    @api existingBillTo;
    @track errorCtLblet = new Set();

    @api source;
    @track showToastMsg =false;

    isRegistrationCompleted = false;

    addressList;
    existingAddressList = [];
    newAddressList = [];
    registration;
    caseCr;
    acrContactList;
    sapContactsMap = new Map();
    contactSapMap = new Map();
    existingAffiliationList;

    hidemaindiv =false;
    showLoader = false;

    isNew;

    contactsoption;
    contactOptionValue;
    isExistingContacts;

    isShowDataTable;

    wrapperDataMap = new Map();

    layoutMetadataMaster;
    step5fields;
    customerTypeConfig;

    newcontactsMap = [];
    existingContactsMap = [];
    contactMapCounter = 0;

    showNewContactsLayout;

    country;
    error;
    variant='error';
    caseNumber;
    CaseIdVal;

    afflAddr;
    sobjNamesList = [];

    isEscalateQA =false;
    showEscalateQA=false;
    casePriority='';
    priorityValue='';
    casePriorityOptions;
    registrationId;

    filesUploaded = [];

    showuploadCA;

    label={
        AGN_OAM_Body_Confirm_Youhave,
        AGN_OAM_Body_Confirm_SuccessfullyCompleted,
        AGN_OAM_Basic_Information_Heading,
        AGN_OAM_Address_Details_Heading,
        AGN_OAM_Document_Upload_Heading,
        AGN_OAM_Confirmation_Heading,
        AGN_OAM_Contact_Affiliation,
        AGN_OAM_Header_CustomerRegistration,
        AGN_GCSP_Edit_Button,
        AGN_GCSP_Close_Button,
        AGN_GCSP_ExistingContacts,
        AGN_GCSP_NewContacts,
        AGN_GCSP_NewContactDescription,
        AGN_GCSP_AddNewContact,
        AGN_GCSP_SubmitContact,
        AGN_GCSP_ContactAddAffiliation,
        AGN_GCSP_Affiliations,
        AGN_GCSP_NewAffiliations,
        AGN_GCSP_STEP1,
        AGN_GCSP_STEP2,
        AGN_GCSP_STEP3,
        AGN_GCSP_STEP4,
        AGN_GCSP_STEP5,
        AGN_OAM_CaseNumber,
        AGN_GCSP_CaseDetails,
        AGN_OAM_CaseRequestToQA,
        AGN_GCSP_CasePriority,
        AGN_OAM_Loading
    }

    get actionTypeOptions() {
        return [{
                label: 'New',
                value: 'new'
            },
            {
                label: 'Update',
                value: 'update'
            }
        ];
    }

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');
     }
   
    connectedCallback(){
        this.hidemaindiv = true;
        this.showLoader = true;
        this.getExistingContactsData();
        this.isNew = (this.sapId) ? false : true;
    }

    getExistingContactsData(){

        getexistingData({
            caseId: this.caseId,
            sapId: this.sapId
        })
        .then( result => {

            if (result) {
                //console.log('result at get existing contact info ::::', result);
                //this.addressList = result.addressList;
                var contactAddressMap = [];
                //this.sapContactsMap = result.customerDetailConMap;
                contactAddressMap = result.conCustomerDetailMap;
                //console.log('ConsoleAddressMap>>>>'+JSON.stringify(contactAddressMap));
                for (var key in contactAddressMap) {
                    this.contactSapMap.set(key, contactAddressMap[key]);
                    }

                    //console.log('Data :::',this.contactSapMap);
                if (result.addressList) {
                    this.addExistingAddressToNewList(result.addressList);
                }
                this.registration = result.newRegistration;    
                this.registrationId = this.registration.Id;

                this.caseCr = result.newCase;
                this.acrContactList = result.acrContactList;
                if (this.acrContactList) {
                     this.contactsoption = this.getcontactOptions(this.acrContactList);
                }
                let countryCode = '';
                countryCode = this.registration.SAP_Country_Code_AGN__c;
                if (!countryCode) {
                   countryCode = this.registration.Country_Code_AGN__c
                }
                this.country = countryCode;
                this.showuploadCA = (countryCode && countryCode.toUpperCase() == 'CA' && this.registrationId) ?  true : false; 
                this.getGCSPCustomSettings(countryCode);
                this.fetchCountryList(countryCode);
                
            }else{
                this.hidemaindiv = false;
                this.showLoader = false;
            }
            
        })
        .catch(error => {
            console.log('error at get existing data::: ', error);
            this.hidemaindiv = false;
            this.showLoader = false;
        });
    }

    addExistingAddressToNewList(addlist){
        let addressList = [];
        var addressMap = new Map();
        let existingSoldToRec = this.existingSoldTo;
        let existingShipToRec = this.existingShipTo;
        let existingBillToRec = this.existingBillTo;
        
        var existingAddMap = new Map();
        if (addlist) {
            addlist.forEach(function (address) {                
                if (address.SAP_ID_AGN__c) {
                    existingAddMap.set(address.SAP_ID_AGN__c, address);
                }
                else{
                    addressList.push(address);
                }
            });
        }
        //console.log('Parent existingAddMap:::'+JSON.stringify(existingAddMap));
        //console.log('Parent addressList:::'+JSON.stringify(addressList));

       if (existingSoldToRec) {
           existingSoldToRec.forEach(function (soldTo) {
               addressMap.set(soldTo.SAP_ID_AGN__c, soldTo);
               if (existingAddMap.has(soldTo.SAP_ID_AGN__c)){
                   addressList.push(existingAddMap.get(soldTo.SAP_ID_AGN__c));
               }else{
                   addressList.push(soldTo);
               }
               
           });
       }
       if (existingShipToRec) {
           existingShipToRec.forEach(function (shiptTo) {
               addressMap.set(shiptTo.SAP_ID_AGN__c, shiptTo);
               if (existingAddMap.has(shiptTo.SAP_ID_AGN__c)) {
                   addressList.push(existingAddMap.get(shiptTo.SAP_ID_AGN__c));
               } else {
                   addressList.push(shiptTo);
               }
           });
       }
       if (existingBillToRec) {
           existingBillToRec.forEach(function (billTo) {
               addressMap.set(billTo.SAP_ID_AGN__c, billTo);
               if (existingAddMap.has(billTo.SAP_ID_AGN__c)) {
                   addressList.push(existingAddMap.get(billTo.SAP_ID_AGN__c));
               } else {
                   addressList.push(billTo);
               }
           });
       }       
      
       this.addressList = addressList;

       //console.log('Parent this.addressList:::'+JSON.stringify(this.addressList));
    }

    getGCSPCustomSettings(countryCode) {
         getGCSPSettings({
                 country: countryCode
             })
             .then(result => {
                 if (result) {
                     //console.log('Custom Settings Data*******', result);
                     this.showEscalateQA = result.QA_Validation_Applicable_AGN__c;
                     
                 } else {
                     this.hidemaindiv = false;
                     this.showLoader = false;
                 }
             })
             .catch(error => {
                 console.log('error>>>>>>>>>>>>>>>>>>>', error);
                 this.error = error;
                 this.hidemaindiv = false;
                 this.showLoader = false;
             });
     }


    handleChangeQA(event){
        this.isEscalateQA = event.target.checked;
    }

    handleChangePriyarity(event){
        this.priorityValue = event.target.value;
    }

    handleAddressRowSelection = e => {
        var selectedAddressRows = e.detail.selectedRows;

        if (selectedAddressRows.length > 0) {
            this.afflAddr = selectedAddressRows;

        }
    } 
    @wire(getObjectInfo, { objectApiName: CASE })
    caseMetadata;   
  
     @wire(getPicklistValues, {
        recordTypeId : '$caseMetadata.data.defaultRecordTypeId',
        fieldApiName : CASE_PRIORITY
    })
        wiredPickListValue({ data, error }){
            if(data){
                //console.log(` Picklist values are `, data.values); 
                //this.casePriorityOptions.push({attributes: null, label: " ", validFor: Array(0), value: ""});
                //this.casePriorityOptions =data.values;
                this.casePriorityOptions = [ { label: '', value: '', selected: true }, ...data.values];
                //console.log(` this.casePriorityOption `, this.casePriorityOption); 
                this.error = undefined;
            }
            if(error){
                //console.log(` Error while fetching Picklist values  ${error}`);
                this.error = error;
                this.casePriorityOptions = undefined;
            }
        }
    getcontactOptions(acrContacts){
        let options = [];
        acrContacts.forEach(function(contact){
            if(typeof contact.Email_AGN__c == 'undefined')
                options.push({
                    label: contact.First_Name_AGN__c + ' ' + contact.Last_Name_AGN__c,
                    value: contact
                });
            else
                options.push({
                    label: contact.First_Name_AGN__c + ' ' + contact.Last_Name_AGN__c + '('+ contact.Email_AGN__c +')',
                    value: contact
                });
        });
        return options;
    }

    show_hide_contact(event) {

        var acrConValue = event.target.value;
        var acrContact = '';
        if(typeof acrConValue.Email_AGN__c == 'undefined'){
            acrContact = acrConValue.First_Name_AGN__c + ' ' + acrConValue.Last_Name_AGN__c;
        }else{
            acrContact = acrConValue.First_Name_AGN__c + ' ' + acrConValue.Last_Name_AGN__c+'('+acrConValue.Email_AGN__c+')';

        }          
         //console.log('edit button::::: '+JSON.stringify(acrConValue));
         //console.log('acrContact::::: ', acrContact);

        this.template.querySelectorAll(`[data-id="${acrContact}"]`).forEach(element => {

            //element.classList.toggle('Contact_add1');
            element.className = 'slds-show';            

        });
         this.template.querySelectorAll(`[data-value="${acrContact}"]`).forEach(element => {

             //element.classList.toggle('Contact_add');  
             element.className = 'slds-hide';

         });
    }

    hideFullview_contact(event) {

        var acrConValue = event.target.value;
       var acrContact = '';
        if(typeof acrConValue.Email_AGN__c == 'undefined'){
            acrContact = acrConValue.First_Name_AGN__c + ' ' + acrConValue.Last_Name_AGN__c;
        }else{
            acrContact = acrConValue.First_Name_AGN__c + ' ' + acrConValue.Last_Name_AGN__c+'('+acrConValue.Email_AGN__c+')';

        }
         //console.log('edit button::::: '+JSON.stringify(acrConValue));
         //console.log('acrContact::::: ', acrContact);

        this.template.querySelectorAll(`[data-id="${acrContact}"]`).forEach(element => {

            //element.classList.toggle('Contact_add1');
            element.className = 'slds-hide';   

        });
         this.template.querySelectorAll(`[data-value="${acrContact}"]`).forEach(element => {

             //element.classList.toggle('Contact_add');  
             
             element.className = 'slds-show';     

         });
    }
   

    fetchCountryList(countryCode) {

        fetchCountryList({
                countryCode: countryCode,
                source: this.source
            })
            .then(result => {
                var customerTypeConfig = result[1];
                this.customerTypeConfig = customerTypeConfig;
                // //console.log('Data*******', JSON.stringify(this.customerTypeConfig)); 
                this.invokeGetLayout(this.registration, countryCode, customerTypeConfig);
            })
            .catch(error => {
                console.log('error IT Layout>>>>>>>>>>>>>>>>>>>', error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
            });

    }

    invokeGetLayout(registration, countryCode, customerTypeConfig) {
        console.log('invokeGetLayout>>>>>>>>>>>>>>>', countryCode,registration,customerTypeConfig);
        console.log('this.source:::',this.source);
            getLayout({
                    country: countryCode,
                    stepNo: '5',
                    customerType: registration.Customer_Category_AGN__c,
                    customerSubType: registration.Customer_Sub_Category_AGN__c,
                    custTypeConfig: customerTypeConfig,
                    source: this.source
                })
                .then(result => {
                    console.log('Layout Response :: ', result);
                    this.setLayoutFields(result);
                    this.layoutMetadataMaster = result;
                })
                .catch(error => {
                    console.log('Error In Layout calllout :: ', error);
                    this.setErrorMessage(error, '');
                    this.showLoader = false;
                    this.hidemaindiv = false;
                });

    }
    sobjectName;
    setLayoutFields(data) {
        var settingsMap = data;
        var step5fields = [];
        let sobjNames = new Set();
        for (var key in settingsMap) {
            step5fields = settingsMap[key];            
        }
        for(var objName of step5fields){           
            sobjNames.add(objName.SObject_Name_AGN__c);
            this.sobjectName = objName.SObject_Name_AGN__c;
        }
        //sobjNamesList
        console.log('step3fields2222>>>>>>>>>>>>>>>>>>'+JSON.stringify(step5fields));  
        this.step5fields = step5fields;
        //console.log('sobjNames::::: ', sobjNames);
        for(var objName of sobjNames){
            this.sobjNamesList.push(objName);
        }
        // = Array.from(sobjNames);
       //console.log('sobjNames::::: ', this.sobjNamesList);
       //console.log('this.showLoader:::',this.showLoader);
       this.showLoader = false;
       this.hidemaindiv = false;
    }

    @wire(getObjectInfo, { objectApiName: '$sobjectName' })
    sObjectsData({ data, error }){
            if(data){
                //console.log('Objects data:::::', data);                
                this.hidemaindiv = false;
                this.showLoader = false;
            }
            if(error){
                //console.log('Error Objectdata:::  ',error);
                this.hidemaindiv = false;
                this.showLoader = false;
            }
        }   


    setErrorMessage(error, custommsg) {
        //console.log('error == ', error);
        if (custommsg) {
            this.showToast('error', ' Contact your administrator ::: ' + custommsg, 'error');
        } else if (error && error.body && error.body.message) {
            this.showToast('error', ' Contact your administrator ::: ' + error.body.message, 'error');
        } else {
            this.showToast('error', ' Unknown Error, Contact your administrator ', 'error');
        }
    }

    showToast(title , message , variant) {
        if(this.source ==='cs')
        {   this.error = message; 
            this.variant = variant; 
            //this.showToastMsg = true;              
            this.template.querySelector('c-agn_gcsp_custom-toast').showCustomNotice();
        }
        else{
            const event = new ShowToastEvent({
                title: title,
                message : message,
                variant : variant
            });
            this.dispatchEvent(event);
        }
    }  

     deleteContact(event) {
         var indx = event.detail.index;
         var instancetype = event.detail.instancetype;
         if (instancetype === "new") {
             if (indx === 0 || indx > 0) {
                 //console.log('index>>>>>>>>>>>>', indx);
                 var contactsMap = this.newcontactsMap;
                 //console.log('contactsMap before delete>>>>>>>>>>>>>>>', JSON.stringify(contactsMap));
                 contactsMap.splice(indx, 1);
                 //console.log('contactsMap after delete>>>>>>>>>>>>>>>'+JSON.stringify(contactsMap));
                 this.newcontactsMap = contactsMap;  
                 this.showNewContactsLayout = true;
                this.contactMapCounter--;                
             }            
         }
     }

     addNewContact(){
         this.showNewContactsLayout = false;
         if(this.contactMapCounter < 0) {
             this.contactMapCounter = 0;
         }         
         //console.log('this.contactMapCounter:::', this.contactMapCounter);
         var mapKey = 'Contact' + this.contactMapCounter;
         this.newcontactsMap.push({
             key: mapKey,
             value: this.step5fields
         });       
         this.showNewContactsLayout = true;
         this.contactMapCounter++;
         //console.log('this.newcontactsMap::::', this.newcontactsMap);

         //var selectedContactId;
         
         //this.template.querySelector('c-agn_gcsp_mange_accounts').handleShowHide(selectedContactId, this.addressList, this.contactSapMap, this.sapId);
     }

     handleClick(){
          let allDocsValid = true;
          /*****************Document Validation****************** */
          this.template.querySelectorAll('c-agn_gcsp_update-flow-documents').forEach(element => {
               //console.log('element.required1>>>>>>>>>>>>>>>>>>',element.requiredPending);
               if(element.requiredPending){
                  allDocsValid = false;                  
                  element.validateDocs();
               }
          }); 

          this.template.querySelectorAll('c-agn_gcsp_ship-to-documents-upload_ca').forEach(element => {
               //console.log('element.required1>>>>>>>>>>>>>>>>>>',element.requiredPending);
               if(element.requiredPending){
                  allDocsValid = false;                  
                  element.validateDocs();
               }
          }); 

          if(!allDocsValid){
                //this.showToast('Error' ,AGN_CP_DOCS_MANDATORY , 'Error'); 
                this.showToast('error' , AGN_OAM_RequiredDocument_ErrorMsg , 'error'); 
                this.hidemaindiv = false;
                this.showLoader = false;
                return;
          }  
         if(confirm(AGN_Confirm_ContactAffiliationMsg)){
             this.handleSave();
         }
      
     }

    handleSave() {
        
        this.hidemaindiv = true;
        this.showLoader = true;
       
        var oldContactMap = new Map();
        let oldContactList = this.acrContactList;

        if (oldContactList) {
            oldContactList.forEach(function (acrCon) {                
                oldContactMap.set(acrCon.Contact_AGN__c, acrCon);
            });
        }

        let labelMap = getCustomLable();
        var customerObj = [];
        var addContmapObj = [];
        
        let hasError = true;
        let hasFieldsNotFoundIssue = true;
        let allvalid = true;
       // let selectedAddRows;
        let formateFields = new Set();
        let isChildDataValid = true;
        let isChildDataFormat = true;

        this.template.querySelectorAll(".commoninputcmpCase").forEach(element=>{
            if(!element.reportValidity())
            {                
                element.setCustomValidity('');
            }
        });

        this.template.querySelectorAll('c-agn_gcsp_mange_accounts').forEach(element => {
            let isValid = element.checkreportValidity();
            if(!isValid){
                isChildDataValid = false;
                this.errorCtLblet.add(element.getConLabel());
            }
              
            let formateFieldLabels = element.checkFormate();
            if(formateFieldLabels){
                this.errorCtLblet.add(element.getConLabel());
                formateFieldLabels.split(',').forEach(e=>{
                    formateFields.add(e);
                });
                isChildDataFormat = false;
            }           
        });

        if(!isChildDataValid){
             
             for (let errorCont of this.errorCtLblet){

                this.template.querySelectorAll(`[data-id="${errorCont}"]`).forEach(element => {
                    //element.classList.toggle('Contact_add1');
                    element.className = 'slds-show';
        
                });
                 this.template.querySelectorAll(`[data-value="${errorCont}"]`).forEach(element => {        
                     //element.classList.toggle('Contact_add');
                     element.className = 'slds-hide';
        
                 });
            }     
            
            this.hidemaindiv = false;
            this.showLoader = false;
            this.showToast('error' , AGN_OAM_Required_Fields_Missing_Error , 'error');
            return;
        }
        /*if(!this.priorityValue){
            this.hidemaindiv = false;
            this.showLoader = false;
            this.showToast('error' , AGN_OAM_Required_Fields_Missing_Error , 'error');
            
            return;
        }*/
        if(!isChildDataFormat){          
             for (let errorCont of this.errorCtLblet){

                this.template.querySelectorAll(`[data-id="${errorCont}"]`).forEach(element => {

                    //element.classList.toggle('Contact_add1');
                    element.className = 'slds-show'
        
                });
                 this.template.querySelectorAll(`[data-value="${errorCont}"]`).forEach(element => {
        
                     //element.classList.toggle('Contact_add');
                     element.className = 'slds-hide'
        
                 });
            } 
            
            this.hidemaindiv = false;
            this.showLoader = false;
            this.showToast('error' , AGN_OAM_Body_PleaseCheckFormatFor +' '+ Array.from(formateFields).join(), 'error');
            return;
        }
       
       
        this.template.querySelectorAll('c-agn_gcsp_mange_accounts').forEach(element => {
            let contactsData = element.validateInputs();
            let selectedAddRows = element.selectedAddRows();            
            let newcontactAffliation = new Map();
            //console.log("selectedAddRows::::::"+JSON.stringify(selectedAddRows));
            //console.log("contactsData::::::",contactsData);
            if (contactsData) {
                hasFieldsNotFoundIssue = (contactsData.includes("FIELDS_NOT_FOUND")) ? true : false;
                hasError = (contactsData.includes("error")) ? true : false;
                this.errorCtLblet.add(element.getConLabel());              
            }

           // //console.log("selectedAddRows::::::"+JSON.stringify(selectedAddRows));
           //             

            if (contactsData && !hasFieldsNotFoundIssue && !hasError) {
                let acrContactList = [];
                contactsData.forEach(function (cont) {
                    if (cont.Contact_AGN__c) {
                         for (var attkey in cont) {
                             if (cont.hasOwnProperty(attkey)) {
                                 oldContactMap.get(cont.Contact_AGN__c)[attkey] = cont[attkey];
                             }
                         }
                         acrContactList.push(oldContactMap.get(cont.Contact_AGN__c));
                    }else{
                       acrContactList.push(cont);
                    }
                });
                console.log('@@@acrContactListData>>>>', acrContactList);
                for (let value of acrContactList) {
                    if (selectedAddRows) {
                        for (let add of selectedAddRows) {
                            let acrContact = {
                                'sobjectType': 'Allergan_Customer_Contact_AGN__c'
                            };
                            for (let key in value) {
                                if (value.hasOwnProperty(key) && key !== 'sobjectType') {
                                    acrContact[key] = value[key];
                                }
                            }
                            acrContact.Parent_AGN__c = this.registration.Id;
                            
                            if (add.Id) {
                                newcontactAffliation = {
                                    'key': add.Id,
                                    'acrConList': acrContact
                                }; 
                                 addContmapObj.push(newcontactAffliation);
                            } else if (add.SAP_ID_AGN__c) {                                                               
                                newcontactAffliation = {
                                    'key': add.SAP_ID_AGN__c,
                                    'acrConList': acrContact
                                };
                                addContmapObj.push(newcontactAffliation);

                            }

                        }
                    }
                    else{
                        customerObj.push(value);
                    }
                }
            }
            else{
                allvalid = false;
            }
        });
        //customerMap.set
        if(!allvalid){          
            for (let errorCont of this.errorCtLblet){

                this.template.querySelectorAll(`[data-id="${errorCont}"]`).forEach(element => {
                    element.className = 'slds-show';
        
                });
                 this.template.querySelectorAll(`[data-value="${errorCont}"]`).forEach(element => {
                     element.className = 'slds-hide';        
                 });
            }
            this.hidemaindiv = false;
            this.showLoader = false;
            this.showToast('error' , AGN_OAM_Required_Fields_Missing_Error , 'error');
        }
       /* else if(hasFieldsNotFoundIssue && allvalid){
            this.hidemaindiv = false;
                this.showLoader = false;
                 this.showToast('error' , AGN_OAM_Required_Fields_Missing_Error , 'error');
        }   */     
        else if(addContmapObj || customerObj){ 
            console.log("addContmapObj:::1:::" + JSON.stringify(addContmapObj));
            console.log("customerObj::::1::::" + JSON.stringify(customerObj));            
            this.handleSavecustomerDetails(JSON.stringify(addContmapObj), customerObj);
        }
        else{
            this.hidemaindiv = false;
            this.showLoader = false;
        }

    }

    
    handleSavecustomerDetails(newconAffMap, customerObj) {
       //console.log('newconAffMap>>2>>>' + newconAffMap);
       //console.log('customerObj>>>2>>' + JSON.stringify(customerObj));           
        saveAcrContactsAffiliation({
                caseId: this.caseId,
                contactAddMap: newconAffMap,
                customerConList:customerObj,
                addList: this.addressList,
                isEscalateQa: this.isEscalateQA,
                priority: this.priorityValue
            })
            .then(result => {
                    if (result) {                         
                        //console.log('result:::::', result);
                        let caseData = result;
                        this.caseNumber = caseData.CaseNumber;
                        this.CaseIdVal = '/'+caseData.Id;                        
                        this.isRegistrationCompleted = true;
                        this.hidemaindiv = false;
                        this.showLoader = false;
                    }
                    
                })
                .catch(error => {
                    console.log('error at Save existing data::: '+JSON.stringify(error));
                    this.hidemaindiv = false;
                    this.showLoader = false;
                    this.showToast('error' , JSON.stringify(error) , 'error'); 
                });
                
    }
   

}