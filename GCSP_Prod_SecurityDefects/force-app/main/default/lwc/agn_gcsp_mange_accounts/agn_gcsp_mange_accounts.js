/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   02-17-2021   Ravi Sirigiri   Initial Version
**/
import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import LANG from '@salesforce/i18n/lang';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

import NAME1_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.SAP_Name_1_AGN__c';
import ADDRESS_LINE_1_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Address_Line_1_AGN__c';
import COUNTRY_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Country_AGN__c';
import SOLD_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Sold_To_AGN__c';
import SHIP_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Ship_To_AGN__c';
import BILL_TO_FIELD from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Bill_To_AGN__c';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';

import AGN_GCSP_ContactAddAffiliation from '@salesforce/label/c.AGN_GCSP_ContactAddAffiliation';
import AGN_GCSP_Affiliations from '@salesforce/label/c.AGN_GCSP_Affiliations';
import AGN_GCSP_NewAffiliations from '@salesforce/label/c.AGN_GCSP_NewAffiliations';
import AGN_OAM_Contact_Affiliation from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_Body_PleaseCheckFormatFor from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Required_Fields_Missing_Error from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';
import AGN_OAM_Name_LT from '@salesforce/label/c.AGN_OAM_Name_LT';
import AGN_OAM_Address_Line_1_LT from '@salesforce/label/c.AGN_OAM_Address_Line_1_LT';
import AGN_OAM_Country_LT from '@salesforce/label/c.AGN_OAM_Country_LT';
import AGN_OAM_Sold_To_LT from '@salesforce/label/c.AGN_OAM_Sold_To_LT';
import AGN_OAM_Ship_To_LT from '@salesforce/label/c.AGN_OAM_Ship_To_LT';
import AGN_OAM_Bill_To_LT from '@salesforce/label/c.AGN_OAM_Bill_To_LT';


import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';

const addressColumns = [{
        label: AGN_OAM_Name_LT,
        fieldName: NAME1_FIELD.fieldApiName,
        type: 'text'
    },
    {
        label: AGN_OAM_Address_Line_1_LT,
        fieldName: ADDRESS_LINE_1_FIELD.fieldApiName,
        type: 'text'
    },
    {
        label: AGN_OAM_Country_LT,
        fieldName: COUNTRY_FIELD.fieldApiName,
        type: 'text'
    },
    {
        label: AGN_OAM_Sold_To_LT,
        fieldName: SOLD_TO_FIELD.fieldApiName,
        type: 'boolean'
    },
    {
        label: AGN_OAM_Ship_To_LT,
        fieldName: SHIP_TO_FIELD.fieldApiName,
        type: 'boolean'
    },
    {
        label: AGN_OAM_Bill_To_LT,
        fieldName: BILL_TO_FIELD.fieldApiName,
        type: 'boolean'
    }
];
export default class Agn_gcsp_mange_accounts extends NavigationMixin(LightningElement) {

    @api indx;
    @api addressList;
    @api existingAddressList;
    @api newAddressList;
    childexistingAddressList = [];
    childnewAddressList = [];
    @api sapId;
    @api contactSapMap;
    @api instancetype;
    @api layoutMetadataMaster;
    @api layoutData;
    @api record;
    @api country;
    @api acrContactList;
    

    @api sourceOAM;
    @api sourceCS;
    @api soldToSAPId;
    @api conLabel;
    @track hasChildnewAddress = false;

    addrcols = addressColumns;  
    addressSelected;

    afflAddr;

    label = {
        AGN_OAM_Invalid_Input,
        AGN_GCSP_ContactAddAffiliation,
        AGN_GCSP_Affiliations,
        AGN_GCSP_NewAffiliations,
        AGN_OAM_Contact_Affiliation

    };

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');     
    } 
    connectedCallback() {
        //console.log('addressList>>>>', this.addressList);
        //console.log('this.afflAddr:::::',this.afflAddr);
        this.layoutMetadataMaster = this.layoutData;
        if (this.sapId && this.addressList) {
            this.getSapDataAddress();
        } else if (this.addressList) { //!this.sapId &&
            var existingAddressList = [];
            var newAddressList = [];
            this.addressList.forEach(function (address) {
                if (address.Sold_To_AGN__c) {
                    existingAddressList.push(address);
                } else {
                    newAddressList.push(address);
                }
            });
            //console.log('New existingAddressList:::::::'+JSON.stringify(existingAddressList));
            //console.log('New newAddressList:::::::'+JSON.stringify(newAddressList));
            this.childexistingAddressList = existingAddressList;
            this.childnewAddressList = newAddressList;
            this.hasChildnewAddress = this.childnewAddressList.length>0?true:false;
            //console.log('hasChildnewAddress:::::::'+this.hasChildnewAddress);
        }
    }

    getSapDataAddress(){
        //console.log('this.record:::::::'+JSON.stringify(this.record));
        if (this.record) {
            let selectedContactId = this.record.Contact_AGN__c;
             var existingAddressList = [];
             var newAddressList = [];
             let SAPIDList = [];
            var contactAddressMap = new Map();
            contactAddressMap = this.contactSapMap;
            let sapIdMap = new Map();
            contactAddressMap.forEach((value, key) => {
                //console.log('selectedContactId>>>'+selectedContactId);
                //console.log('key>>>'+key);
                //console.log('value>>>'+value);
                if (key === selectedContactId) {
                   // SAPIDList = value.slice();
                    //SAPIDList.push(value);
                    SAPIDList = value;
                    sapIdMap.set(selectedContactId, value);
                }
            })
        //console.log('sapIdMap::::: '+JSON.stringify(sapIdMap));
        //console.log('SAPIDList:::::::'+JSON.stringify(SAPIDList));
        //console.log('addressList:::::::'+JSON.stringify(this.addressList));
            for (var j in this.addressList){ 
                let sapId =  this.addressList[j].SAP_ID_AGN__c;
                let sapIdVal= SAPIDList.find((existingAffliation) => existingAffliation === sapId);
                if(sapIdVal){
                   existingAddressList.push(this.addressList[j]); 
                }else{
                   newAddressList.push(this.addressList[j]);
                }
               /* if(sapIdMap.has(sapId)){
                    existingAddressList.push(this.addressList[j]);
                }else{
                     newAddressList.push(this.addressList[j]);
                } */
               
               /* let checkflag = false;
                for (var i in SAPIDList) {                                      
                    if (SAPIDList[i] == this.addressList[j].SAP_ID_AGN__c) {
                        existingAddressList.push(this.addressList[j]);
                        checkflag = true;
                    }                    
                }
                if(!checkflag){
                    newAddressList.push(this.addressList[j]);
                }  */           
            }
            
            //console.log('Update existingAddressList:::::::'+JSON.stringify(existingAddressList));
            //console.log('Update newAddressList:::::::'+JSON.stringify(newAddressList));
            this.childexistingAddressList = existingAddressList;
            this.childnewAddressList = newAddressList;
            this.hasChildnewAddress = this.childnewAddressList.length>0?true:false;
            //console.log('hasChildnewAddress:::::::'+this.hasChildnewAddress);
        }
    }

    handleAddressRowSelection = e => {
        var selectedAddressRows = e.detail.selectedRows;

        if (selectedAddressRows.length > 0) {
           
            this.afflAddr = selectedAddressRows;

             //console.log('this.afflAddr:::::',this.afflAddr);

        }
    }

    @api validateInputs() {
        var allValid = true;
        var isFormatValid = true;
        var hasFormatIssues = false;

        let newContactMap = new Map();
        let contactMap = new Map();
        
        let contactAddMap = new Map();
        let acrConList = [];
        
        let labelMap = getCustomLable();

        let invalidDataFields = '';
        let isValChanged = false;   
        let rowchange = this.selectedAddRows();  
        let inputValueErr = false;
        let isInvalid = false;
        let formatIssuefieldList = [];

        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {           
         
            let elementVal;
            let isChanged = false;         
            //console.log('element.fieldname>>>', element.fieldname+'>>checkValidity>>'+element.checkValidity());
            isChanged = element.isChanged;
            if (element.checkValidity()) { 

                elementVal = element.getUserEnteredInput();
                isFormatValid = element.isFormatValid();
               
                //ValChanged  = element.isChanged;
                
                if (!isFormatValid) {                            
                    element.setCustomErrorMessage(AGN_OAM_Body_PleaseCheckFormatFor); //AGN_CP_FORMAT_INVALID
                    formatIssuefieldList.push(labelMap.get(element.customlabel));
                    hasFormatIssues = true;
                } else {
                    element.setCustomErrorMessage('');
                    //console.log('inside element.record1>>>>');
                    if( isChanged || rowchange){
                        if (elementVal || element.isBoolean) {//&& isChanged
                            if (element.sobjectname === 'Allergan_Customer_Contact_AGN__c') {
                                if (element.record) {
                                    /*************Edit Record*****************/
                                    let recordId = (element.record.Id) ? element.record.Id : element.record.Contact_AGN__c;
                                    
                                    if (contactMap.has(recordId)) {  
                                        contactMap.get(recordId)[element.fieldname] = elementVal;                               
                                    }
                                    else {                                
                                        let acrContact = {
                                            'sobjectType': 'Allergan_Customer_Contact_AGN__c'
                                        };
                                        acrContact[element.fieldname] = elementVal;
                                            let conId = element.record.Contact_AGN__c;
                                            let recId = element.record.Id;
                                            if (recId) {                                        
                                                acrContact.Id = recordId;
                                            }else{
                                                acrContact.Contact_AGN__c = conId;
                                            }                                    
                                            contactMap.set(recordId, acrContact);                                  
                                            contactMap.get(recordId)[element.fieldname] = elementVal;
                                                                        
                                    }
                                
                                }
                                else{
                                    /*************New Record*****************/                            
                                    if (newContactMap.has(this.indx)) {                                 
                                        newContactMap.get(this.indx)[element.fieldname] = elementVal;                               
                                    } else {
                                        let acrContact = {
                                            'sobjectType': 'Allergan_Customer_Contact_AGN__c'
                                        };
                                        newContactMap[element.fieldname] = elementVal;                                 
                                        newContactMap.set(this.indx, acrContact);
                                        newContactMap.get(this.indx)[element.fieldname] = elementVal;
                                    }
                                    
                                }
                            }
                        } 
                        else{
                            //console.log('error field>>>'+element.fieldname);
                           // inputValueErr =true;
                        }                        
                    }         
                }                              
            }           
            else{
                isInvalid = true;
                allValid = false;
            }
            if (this.instancetype && this.instancetype === 'update') {
                if(isChanged || rowchange)
                {
                   isValChanged = true;
                }                  
            } 
       
        });
        //console.log('allValid>>>', allValid);
        //console.log('hasFormatIssues>>>', hasFormatIssues);
        //console.log('isValChanged>>>', isValChanged);
        if(isValChanged && isInvalid )
        {
            allValid = false;
            inputValueErr = true;
        }
        if(!isValChanged && this.instancetype=='update')
        {
            hasFormatIssues = false;
            allValid = true;
        }
        if (allValid && !hasFormatIssues && !inputValueErr){
            
            if (this.record && isValChanged) {
                //console.log('For Edit>>>>>>>>>>>>>>', contactMap);
                // For Edit
                for (let value of contactMap.values()) {
                    acrConList.push(value);
                }
            } else {
                // For New Record
                 //console.log('For New>>>>>>>>>>>>>>', newContactMap);
                for (let value of newContactMap.values()) {
                    acrConList.push(value);
                }
            }        
            return acrConList;
        } 
        else if (hasFormatIssues || inputValueErr) {
            //console.log('Child error');
            let resp = 'error'+formatIssuefieldList.join();
            return resp;
        }else{
             //console.log('Child FIELDS_NOT_FOUND');
            let resp = 'FIELDS_NOT_FOUND,';
            return resp;
        }
     

    }

    @api checkFormate(){
        let labelMap = getCustomLable();
        let formatIssuefieldList=[];
        var isValchanged = false;
        var instancetype = this.instancetype?this.instancetype:'new';
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
              
                if (!element.isFormatValid()) {                          
                   
                    formatIssuefieldList.push(labelMap.get(element.customlabel));
                }
                if(element.isChanged)
                {
                    isValchanged = true;
                }
         });
         if((instancetype==='old'||instancetype==='update'))
         {
             if(isValchanged || this.selectedAddRows())
             {
                return formatIssuefieldList.join();
             }
             else{
                 return null;
             }
           
         }
         else{
            return formatIssuefieldList.join();
         }
         
    }

    @api checkreportValidity(){
        
        let isValid=true;
        var instancetype = this.instancetype?this.instancetype:'new';
        var isAnyChange = false;
         this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
            //console.log('fieldName>>>'+element.fieldname +' checkValidity>>>'+ element.checkValidity());
            if(!element.checkValidity()){
                isValid = false;
             }
             if(instancetype==='new')
             {
                isAnyChange = true;
             }
             else if((instancetype==='old' || instancetype ==='update') && element.isChanged)
             {
                isAnyChange = true;
             }
             //console.log('fieldName>>>'+element.fieldname +' checkValidity>>>'+ element.checkValidity()+' isValid>>>' +isValid);

         });
         

         if(isAnyChange)
         {
            return isValid;
         }
         return true;
         
    }

    @api selectedAddRows() {        
        return this.afflAddr;
        //this.template.querySelector('lightning-datatable').getSelectedRows();
    }
    @api getConLabel(){
       return this.conLabel;
    }

    handleControllingFieldEvent(event) {
         const eventParemeters = event.detail;

         const controllingFieldSobjectName = eventParemeters.controllingFieldSobjectName;
         //console.log("controllingFieldSobjectName -> " + controllingFieldSobjectName);
         const controllingFieldName = eventParemeters.controllingFieldName;
         //console.log("controllingFieldName -> " + controllingFieldName);
         const controllingFieldSelectedValue = eventParemeters.controllingFieldSelectedValue;
         //console.log("controllingFieldSelectedValue -> " + controllingFieldSelectedValue);

         let dependentFieldList = [];
         //console.log("layoutMetadataMaster -> " + JSON.stringify(this.layoutMetadataMaster));
         //finding dependent field list based upon event received with parameters
         //console.log("layoutMetadataMaster Keys -> " +  Object.keys(this.layoutMetadataMaster));
         var itr = 1;
         Object.keys(this.layoutMetadataMaster).forEach(key => {
             //console.log('layoutMetadataMaster[key]>>' + JSON.stringify(this.layoutMetadataMaster[key]));
             let dependentField = this.layoutMetadataMaster[key].find(layout => {
                 //console.log('layout>>' + JSON.stringify(layout));
                 if (layout.Controlling_Field_AGN__c == controllingFieldName &&
                     layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName) {
                     //console.log('itr>>' + itr);
                     itr++;
                     dependentFieldList.push(layout);
                     //return layout;

                 }
             });
             /*if (dependentField) {
                 dependentFieldList.push(dependentField);
             }*/
         });

         if (dependentFieldList.length > 0) {
             //console.log('dependentFieldList>>>' + JSON.stringify(dependentFieldList));
             dependentFieldList.forEach(field => {
                 this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                     if (element.fieldname === field.Field_Name_AGN__c &&
                         element.sobjectname === field.SObject_Name_AGN__c) {
                         //console.log('Checking the dependent List>>');
                         element.removeInputValue();
                         if (field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
                             element.showCmp();
                             element.setControllingValue(controllingFieldSelectedValue);
                             //console.log('met conditions>>');
                             this.showtest = true;
                             return;
                         } else {
                             element.hideCmp();
                             this.showtest = false;
                             return;
                         }
                     }
                 });
             });
         }
     }

     handleEnableDirectAccess(event){
        const eventParemeters = event.detail;
        const templateIndex = eventParemeters.index;
        const templateobjecttype = eventParemeters.objecttype;
        const templateinstancetype = eventParemeters.instancetype;
        const templatevalue = eventParemeters.checkedVal;
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
            if ((element.fieldname === 'Email_AGN__c' && 
                element.sobjectname === 'Allergan_Customer_Registration_AGN__c') || (element.fieldname === 'Email_AGN__c' && element.sobjectname==='Allergan_Customer_Contact_AGN__c')) {
               if(templateIndex ==element.index  && templateobjecttype == element.objecttype  && templateinstancetype ==element.instancetype ){

                    //console.log('Checking the dependent List>>');
                    //element.removeInputValue();
                    element.setRequired(templatevalue);
                }
               
            }
        });

    }

}