/************************************************************************************************************
@FileName:          agn_duplicateListing.js 
@Version:           1.0
@Author:            Ayush Basak (ayush.basak@cognizant.com)
@Purpose:           Identify and list possible duplicate business account, based on the information captured 
                    on the Allergan Customer Address record. It also allows users to map and unmap identified 
                    business accounts with the Allergan Customer Address Record
-------------------------------------------------------------------------------------------------------------
@ Change history: 28.12.2020 / Ayush Basak / Created the file.
*************************************************************************************************************/
import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ACA_ID from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Id';
import ACA_BA_ID from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Account_AGN__c';
//import ACA_BA_ID from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Temp__c';
import ACA_BA_LOSER_ID from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Initial_Account_AGN__c';
import ACA_IS_SOLD_TO from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Sold_To_AGN__c';
import ACA_VALIDATION_FLAG from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Use_Existing_Account_AGN__c';
import ACA_UPDATE_FLAG from '@salesforce/schema/Allergan_Customer_Address_AGN__c.Is_Update_Bussiness_Account_AGN__c';

import ACR_ID from '@salesforce/schema/Allergan_Customer_Registration_AGN__c.Id';
import ACR_BA_ID from '@salesforce/schema/Allergan_Customer_Registration_AGN__c.Account_AGN__c';
import ACR_BA_LOSER_ID from '@salesforce/schema/Allergan_Customer_Registration_AGN__c.Mapped_Account_AGN__c';
import ACR_VALIDATION_FLAG from '@salesforce/schema/Allergan_Customer_Registration_AGN__c.Use_Existing_Account_AGN__c';

import ACC_ID from '@salesforce/schema/Allergan_Customer_Contact_AGN__c.Id';
import ACC_BA_ID from '@salesforce/schema/Allergan_Customer_Contact_AGN__c.Contact_AGN__c';
import ACC_MAPPED_ID from '@salesforce/schema/Allergan_Customer_Contact_AGN__c.Mapped_Account_AGN__c';
//import ACC_MAPPED_ID from '@salesforce/schema/Allergan_Customer_Contact_AGN__c.Temp__c';
import ACC_VALIDATION_FLAG from '@salesforce/schema/Allergan_Customer_Contact_AGN__c.Use_Existing_Account_AGN__c';


// Apex method to fetch duplicate business accounts
import getDuplicates from '@salesforce/apex/AGN_Duplicate_Checker.getDuplicates'; 

// Labels 
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';
import NO_RECORDS from '@salesforce/label/c.AGN_Dupe_Checker_NoRecords';
import ID_PLACEHOLDER from '@salesforce/label/c.AGN_Dupe_Checker_Id_Placeholder';
import LOAD_ERRORS from '@salesforce/label/c.AGN_Dupe_Checker_Error';
import ERROR_TITLE from '@salesforce/label/c.AGN_Dupe_Checker_ErrorTitle';
import SUCCESS_TITLE from '@salesforce/label/c.AGN_Dupe_Checker_SuccessTitle';
import UPMAPPING_SUCCESS_MSG from '@salesforce/label/c.AGN_Dupe_Checker_ActionError';
import MAPPING_SUCCESS_MSG from '@salesforce/label/c.AGN_Dupe_Checker_ActionSuccess';
import COMPONENT_TITLE from '@salesforce/label/c.AGN_Dupe_Checker_Title';
import CHECKBOX_LABEL from '@salesforce/label/c.AGN_Dupe_Checker_CheckboxMessage';
import VALIDATION_SUCCESS from '@salesforce/label/c.AGN_Dupe_Checker_CheckboxConfirmation';
const PER_PAGE_COUNT = 5;

export default class DuplicateListingAGN extends LightningElement {
    // Public variable to be set by parent component/page
    @api recordId;
    // Public variable to be set with object type
    @api objectApiName;

    fieldList = [];
    fieldObject = {};
    // Wired record to get Business Account currently stamped on the record
    @wire(getRecord, { recordId: '$recordId', 
                       fields: '$fieldList'
                     })
    recordDetail;
    // Reactive variable to accept the result set and display
    duplicateRecords;
    // Boolean to check if any records where returned
    recordsReturned;

    // Accept error messages from apex calls and display
    wireError;

    rendered = false; 

    validationBox;

    duplicateRecordsDisplay;
    totalPages;
    currentPage;
    perPageCount = PER_PAGE_COUNT;   
    
    // Constant string labels to be displayed on the component
    label = {
        noRecords: NO_RECORDS,
        loadErrors: LOAD_ERRORS,
        componentTitle: COMPONENT_TITLE,
        checkboxLabel: CHECKBOX_LABEL

    }
    
    // Action to be performed on load
    // Making apex call to get the list of duplicate business accounts
    connectedCallback() {
        if(this.objectApiName === 'Allergan_Customer_Address_AGN__c') {
            this.fieldObject.Id = ACA_ID;
            this.fieldObject.mappingField = ACA_BA_ID;
            this.fieldObject.losingField = ACA_BA_LOSER_ID;
            this.fieldObject.flag = ACA_VALIDATION_FLAG;
            this.fieldObject.soldTo = ACA_IS_SOLD_TO;
			this.fieldObject.updateRequired = ACA_UPDATE_FLAG;
            this.fieldList = [ACA_ID, ACA_BA_ID, ACA_BA_LOSER_ID, ACA_IS_SOLD_TO, ACA_VALIDATION_FLAG,ACA_UPDATE_FLAG];
        }
        else if(this.objectApiName === 'Allergan_Customer_Registration_AGN__c'){
            this.fieldObject.Id = ACR_ID;
            this.fieldObject.mappingField = ACR_BA_LOSER_ID;
            this.fieldObject.losingField = ACR_BA_ID;
            this.fieldObject.flag = ACR_VALIDATION_FLAG;
            this.fieldList = [ACR_ID, ACR_BA_ID, ACR_BA_LOSER_ID, ACR_VALIDATION_FLAG];
        }
        else if(this.objectApiName === 'Allergan_Customer_Contact_AGN__c'){
            this.fieldObject.Id = ACC_ID;
            this.fieldObject.mappingField = ACC_MAPPED_ID;
            this.fieldObject.losingField = ACC_BA_ID;
            this.fieldObject.flag = ACC_VALIDATION_FLAG;
            this.fieldList = [ACC_ID, ACC_MAPPED_ID, ACC_BA_ID, ACC_VALIDATION_FLAG];
        }
        this.getDuplicates();
    }

    getDuplicates() {
        this.rendered = false;
        getDuplicates({ crAddressId: this.recordId })
        .then(result => {
            this.duplicateRecords = result;
            this.recordsReturned = this.duplicateRecords.length > 0;
            this.setupDynamicDisplay();
            this.checkMappedRecord();
            this.validationBox = this.recordDetail.data.fields[this.fieldObject.flag.fieldApiName].value;
			this.wireError = null;
        })
        .catch(error => {
            console.log(error); 
			this.recordsReturned = false;
            this.wireError =  (error.body != null)? error.body.message : '. Please click on refresh button.';
        })
        .finally(() => {
            this.rendered = true;
        });
    }

    // Button suport action, uses UpdateRecord method from uiRecordApi module to update the record.
    assignAccount(event) {
        this.rendered = false;
        // Getting the account id from event
        let selectedAccountId = event.target.dataset.key;
        let busAccountLooserId = this.recordDetail.data.fields[this.fieldObject.losingField.fieldApiName].value;
        let busAccountId = this.recordDetail.data.fields[this.fieldObject.mappingField.fieldApiName].value;
        let isSoldTo;
        if(this.objectApiName === 'Allergan_Customer_Address_AGN__c') {
            isSoldTo = this.recordDetail.data.fields[this.fieldObject.soldTo.fieldApiName].value;
        }
        else if(this.objectApiName === 'Allergan_Customer_Registration_AGN__c' 
                || this.objectApiName === 'Allergan_Customer_Contact_AGN__c') {
            isSoldTo = false;
        }
        // Setting up the record
        const fields = {};
        fields[this.fieldObject.Id.fieldApiName] = this.recordId;
        fields[this.fieldObject.mappingField.fieldApiName] = selectedAccountId;
        // Check if looser id is already stamped or not, 
        if(busAccountLooserId == null && isSoldTo) {
            if(busAccountId == null) {
                fields[this.fieldObject.losingField.fieldApiName] = ID_PLACEHOLDER;
            }
            else {
                fields[this.fieldObject.losingField.fieldApiName] = busAccountId;
            }
			fields[this.fieldObject.updateRequired.fieldApiName] = false;
        }

        const recordInput = { fields };
        // Calling data service method
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: SUCCESS_TITLE,
                        message: MAPPING_SUCCESS_MSG,
                        variant: SUCCESS_VARIANT
                    })
                );
                return refreshApex(this.recordDetail);
            })
            .then(() => {
                this.checkMappedRecord();
                this.rendered = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ERROR_TITLE,
                        message: error.body.message,
                        variant: ERROR_VARIANT
                    })
                );
                this.rendered = true;
            });
    }

    // Button suport action, uses UpdateRecord method from uiRecordApi module to update the record.
    unassignAccount(event) {

        // Setting up the record
        let busAccountLooserId = this.recordDetail.data.fields[this.fieldObject.losingField.fieldApiName].value;
        let isSoldTo;
        this.rendered = false;
        if(this.objectApiName === 'Allergan_Customer_Address_AGN__c') {
            isSoldTo = this.recordDetail.data.fields[this.fieldObject.soldTo.fieldApiName].value;
        }
        else if(this.objectApiName === 'Allergan_Customer_Registration_AGN__c'
                || this.objectApiName === 'Allergan_Customer_Contact_AGN__c') {
            isSoldTo = false;
        }
        const fields = {};
        fields[this.fieldObject.Id.fieldApiName] = this.recordId;
        if(busAccountLooserId != null && isSoldTo) {
            if(busAccountLooserId == ID_PLACEHOLDER) {
                fields[this.fieldObject.mappingField.fieldApiName] = null;
            }
            else {
                fields[this.fieldObject.mappingField.fieldApiName] = busAccountLooserId; // Setting back already created account
            }
            fields[this.fieldObject.losingField.fieldApiName] = null; 
			fields[this.fieldObject.updateRequired.fieldApiName] = true;
        }
        else {
            fields[this.fieldObject.mappingField.fieldApiName] = null; // Setting Business Account field as blank
        }
        const recordInput = { fields };

        // Calling data service method
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: SUCCESS_TITLE,
                        message: UPMAPPING_SUCCESS_MSG,
                        variant: SUCCESS_VARIANT
                    })
                );
                return refreshApex(this.recordDetail);
            })
            .then(() => {
                this.checkMappedRecord();
                this.rendered = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ERROR_TITLE,
                        message: error.body.message,
                        variant: ERROR_VARIANT
                    })
                );
                this.rendered = true;
            });
    }

    // This method is called when data is loaded in the renderedCallback
    // This copies all the field map for each record and translates in to object list for display
    // This allows backend class to update field list without having to make changes in the component 
    // to add/remove fields
    setupDynamicDisplay() {
        let tempRecords = [];
        this.duplicateRecords.forEach(rec => {
            let tempRecord = rec; 
            let tempMap = [];
            for (const dataRow of Object.entries(rec.data)) {
                tempMap.push({key:dataRow[0], value:dataRow[1]});
            }
            tempRecord.dataSet = tempMap;
            tempRecord.data = null;
            tempRecords.push(tempRecord);
        });
        this.duplicateRecords = tempRecords;
        console.log(this.duplicateRecords);
    }

    // This method is called on renderedCallback, or everytime assign or unassigned actions are triggerd
    // This method checks for the currently mapped Business account Id on the record 
    // and controls the visibility of assign and unassign buttons
    checkMappedRecord() {
        console.log('In checkMapping');
        console.log(this.recordDetail);
        let tempRecords = [];
        let selectedRecord;
        let busAccountLooserId = this.recordDetail.data.fields[this.fieldObject.losingField.fieldApiName].value;
        let busAccountId = this.recordDetail.data.fields[this.fieldObject.mappingField.fieldApiName].value;
        let isSoldTo;
        if(this.objectApiName === 'Allergan_Customer_Address_AGN__c') {
            isSoldTo = this.recordDetail.data.fields[this.fieldObject.soldTo.fieldApiName].value;
        }
        else if(this.objectApiName === 'Allergan_Customer_Registration_AGN__c' 
                || this.objectApiName === 'Allergan_Customer_Contact_AGN__c') {
            isSoldTo = false;
        }
         
        this.duplicateRecords.forEach(rec => {
            let tempRecord = rec; 
            tempRecord.isMapped = (rec.accountId == busAccountId); 

            if((rec.accountId != busAccountLooserId || (!isSoldTo)) && rec.accountId != busAccountId) {
                tempRecords.push(tempRecord);
            }
            else if(((busAccountLooserId != null && busAccountLooserId != busAccountId) || (!isSoldTo)) 
                        && rec.accountId == busAccountId) {
                selectedRecord = tempRecord;
            }

        });
        if(selectedRecord != null) {
            tempRecords.unshift(selectedRecord);
        }
        this.duplicateRecords = tempRecords;
        this.currentPage = 1;
        this.totalPages = Math.ceil(this.duplicateRecords.length/this.perPageCount);
        console.log(this.duplicateRecords);
        this.paginate();
    }


    checkboxHandler(evt) {
        const fields = {};
        fields[this.fieldObject.Id.fieldApiName] = this.recordId;
        if (evt.target.checked)
        {
            fields[this.fieldObject.flag.fieldApiName] = true;
        }
        else
        {
            fields[this.fieldObject.flag.fieldApiName] = false;
        }
        
        const recordInput = { fields };

        // Calling data service method
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: SUCCESS_TITLE,
                        message: VALIDATION_SUCCESS,
                        variant: SUCCESS_VARIANT
                    })
                );
                this.checkMappedRecord();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ERROR_TITLE,
                        message: error.body.message,
                        variant: ERROR_VARIANT
                    })
                );
            });
    }

    paginate() {
        let start = (this.currentPage - 1) * this.perPageCount;
        let end = this.currentPage * this.perPageCount;
        this.duplicateRecordsDisplay = this.duplicateRecords.slice(start, end);
    }

    handleNavigation(evt) {
        if(evt.target.name == 'First') {
            this.currentPage = 1;
        }
        else if(evt.target.name == 'Previous' && this.currentPage != 1) {
            this.currentPage = this.currentPage - 1;
        }
        else if(evt.target.name == 'Next' && this.currentPage != this.totalPages) {
            this.currentPage = this.currentPage + 1;
        }
        else if(evt.target.name == 'Last') {
            this.currentPage = this.totalPages;
        }
        else if(evt.target.name == 'Refresh') {
            this.getDuplicates();
        }
        this.paginate();
    }
}