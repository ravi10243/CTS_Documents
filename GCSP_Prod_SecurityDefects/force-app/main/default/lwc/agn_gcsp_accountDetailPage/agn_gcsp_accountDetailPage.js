/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on: 06-10-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   02-04-2021   Ravi Sirigiri   Initial Version
 * 1.1   05-29-2021   Avik Shaw       PMO 2871 for Brazil
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
import saveCustomerUpdate from '@salesforce/apex/AGN_GCSP_PortalAccountUpdateController.saveCustomerUpdate';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getLayoutUpdateReg';
import deleteAddress from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.deleteAddress';
import getGCSPSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings';
import getSapData from '@salesforce/apex/AGN_GCSP_PortalAccountUpdateController.doInit';
import getPaymentMethods from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getPaymentMethods';
import getPaymentTerms from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getPaymentTerms';
import getAddressInformation from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getAddressInformation';
import getCustomerRegDetailsCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS';

import AGN_OAM_Fields_Mandatory from '@salesforce/label/c.AGN_OAM_Fields_Mandatory';
import AGN_OAM_CustomerType from '@salesforce/label/c.AGN_OAM_CustomerType';
import AGN_OAM_CustomerSubType from '@salesforce/label/c.AGN_OAM_CustomerSubType';
import AGN_OAM_Body_RegisteredAddress from '@salesforce/label/c.AGN_OAM_Body_RegisteredAddress';
import AGN_OAM_Shipping_Address from '@salesforce/label/c.AGN_OAM_Shipping_Address';
import AGN_OAM_Same_Name_Address from '@salesforce/label/c.AGN_OAM_Same_Name_Address';
import AGN_OAM_Loading from '@salesforce/label/c.AGN_OAM_Loading';
import AGN_OAM_Save from '@salesforce/label/c.AGN_OAM_Save';
import AGN_OAM_Biling_Address from '@salesforce/label/c.AGN_OAM_Biling_Address';
import AGN_OAM_Body_Sold_To from '@salesforce/label/c.AGN_OAM_Body_Sold_To';
import AGN_OAM_Body_Ship_To from '@salesforce/label/c.AGN_OAM_Body_Ship_To';
import AGN_OAM_Successfully_Updated from '@salesforce/label/c.AGN_OAM_Successfully_Updated';
import AGN_OAM_ShipTo_Mandatory from '@salesforce/label/c.AGN_OAM_ShipTo_Mandatory';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';
import AGN_OAM_Address_Limit from '@salesforce/label/c.AGN_OAM_Address_Limit';
import AGN_OAM_Address_deleted from '@salesforce/label/c.AGN_OAM_Address_deleted';
import AGN_OAM_Contact_Admin from '@salesforce/label/c.AGN_OAM_Contact_Admin';
import AGN_OAM_Unknown_Error from '@salesforce/label/c.AGN_OAM_Unknown_Error';
import AGN_OAM_New from '@salesforce/label/c.AGN_OAM_New';
import AGN_OAM_Old from '@salesforce/label/c.AGN_OAM_Old';
import AGN_OAM_IT from '@salesforce/label/c.AGN_OAM_IT';
import AGN_OAM_CS from '@salesforce/label/c.AGN_OAM_CS';
import AGN_OAM_Invalid_Format from '@salesforce/label/c.AGN_OAM_Invalid_Format';
import AGN_OAM_New_Shipping from '@salesforce/label/c.AGN_OAM_New_Shipping';
import AGN_OAM_New_ShipTo from '@salesforce/label/c.AGN_OAM_New_ShipTo';
import AGN_OAM_NewBillTo from '@salesforce/label/c.AGN_OAM_NewBillTo';
import AGN_OAM_Next from '@salesforce/label/c.AGN_OAM_Next';
import AGN_OAM_Previous from '@salesforce/label/c.AGN_OAM_Previous';
import AGN_OAM_Body_Submit from '@salesforce/label/c.AGN_OAM_Body_Submit';
import AGN_OAM_Warning_NoChanges from '@salesforce/label/c.AGN_OAM_Warning_NoChanges';
import AGN_OAM_Account_Update_case_number from '@salesforce/label/c.AGN_OAM_Account_Update_case_number';
import AGN_GCSP_Edit_Button from '@salesforce/label/c.AGN_GCSP_Edit_Button';
import AGN_GCSP_Close_Button from '@salesforce/label/c.AGN_GCSP_Close_Button';
import AGN_GCSP_Deactivate_Button from '@salesforce/label/c.AGN_GCSP_Deactivate_Button';
import AGN_GCSP_Deactivate_Billing_Address from '@salesforce/label/c.AGN_GCSP_Deactivate_Billing_Address';
import AGN_GCSP_Deactivate_Shipping_Address from '@salesforce/label/c.AGN_GCSP_Deactivate_Shipping_Address';
import AGN_GCSP_NewBiiling_Address from '@salesforce/label/c.AGN_GCSP_NewBiiling_Address';
import AGN_OAM_Thank_you from '@salesforce/label/c.AGN_OAM_Thank_you';
import AGN_OAM_Manage_My_Account from '@salesforce/label/c.AGN_OAM_Manage_My_Account';
import AGN_GCSP_Customer_Details from '@salesforce/label/c.AGN_GCSP_Customer_Details';
import AGN_OAM_Body_PleaseCheckFormatFor from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Required_Fields_Missing_Error from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';
import AGN_OAM_Body_PaymentMethod from '@salesforce/label/c.AGN_OAM_Body_PaymentMethod';
import AGN_OAM_Payment_Term from '@salesforce/label/c.AGN_OAM_Payment_Term';
import AGN_OAM_Declaration from '@salesforce/label/c.AGN_OAM_Declaration';
import AGN_OAM_Mandatory_Declaration from '@salesforce/label/c.AGN_OAM_Mandatory_Declaration';
import AGN_OAM_Accept_Declaration from '@salesforce/label/c.AGN_OAM_Accept_Declaration';
import AGN_OAM_RequiredDocument_ErrorMsg from '@salesforce/label/c.AGN_OAM_RequiredDocument_ErrorMsg';
import AGN_OAM_Body_Province from '@salesforce/label/c.AGN_OAM_Body_Province';

import AGN_GCSP_UploadDocumentsForUpdate from '@salesforce/label/c.AGN_GCSP_UploadDocumentsForUpdate';
 
import LANG from '@salesforce/i18n/lang';

import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';

import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

export default class Agn_gcsp_accountDetailPage extends NavigationMixin(LightningElement) {

    @api crRecord;
    @track countryCode;
    //@track country;
    @track language;

    @track customerTypeConfig;    
    @track soldToAddressFields = [];
    @track billToAddressFields = [];
    @track shipToAddressFields = [];
   // @track customerType;
   // @track customerSubType;
    @track shippingMap = [];
    @track billingMap = [];
    @track shippingMapCounter = 0;
    @track billingMapCounter = 0;
    @track showNewShipto = false;
    @track showNewBillto = false;
		showBillTo = true;
    @track showLoader;
    @track hidemaindiv;
    @track showModal;
    @track shiptoLimit = 0;
    @track billtoLimit = 0;
    @track showNewShiptoButton = true;  
    @track showNewBilltoButton = true;
    @track layoutMetadataMaster;
    @track showBankDeclaration = false;
    @track showBankDeclarationMap = new Map();

    PaymentMethod;
    @track sectionPaymentMap = [];
    @track selectedPaymentMethod;
    @track selectedPaymentTerm;
    @track paymentTermMap;
    @track disableFinishBtn = true;

    cssWrapperClass;
    isShowCanadaShiptoLicenseDocuments = false;

    @track controllerdata;

    variant = 'error';
	error;

    @api source;
    @api sourceOAM;
    @api sourceCS;
    @api soldToSAPId;
    @track isCS = false;

    @track isUpdateSuccess = false;
    @track caseNumber;
    @track updateSuccessMsg = "";
    @track errorSAPIdSet = new Set();
    @track errorSAPresultMap = new Map();
  
    //added-for-PT    
    @track existingSoldTo =[];
    @track existingShipTo =[];
    @track existingBillTo =[];
    newRegistration;
    primaryContact;
    customerType;
    customerSubType;
    provienceShow;
    country;
    ctype;
    cSubtype;
    registrationId;
    
    isSoldToflatView;
    isShipToflatView;
    isBillToflatView;

    billToSameAsSoldTo;
    shipToSameAsSoldTo;

    isBrazilOam;
    isShowDeactivateButton;
    displayNLdeclaration = false;
    showSAPIdDeactivateMap = new Map();
    isCanadaOam = false;

    header_css1;
    header_css2;
    header_css3;
    @track hasRendered=false;
    label = {
        AGN_GCSP_UploadDocumentsForUpdate,
        AGN_OAM_Body_Province,
        AGN_OAM_Fields_Mandatory,
        AGN_OAM_CustomerType,
        AGN_OAM_CustomerSubType,
        AGN_OAM_Body_RegisteredAddress,
        AGN_OAM_Shipping_Address,
        AGN_OAM_Same_Name_Address,
        AGN_OAM_Save,
        AGN_OAM_Loading,
        AGN_OAM_Biling_Address,
        AGN_OAM_Body_Sold_To,
        AGN_OAM_Body_Ship_To,
        AGN_OAM_New,
        AGN_OAM_Old,
        AGN_OAM_Successfully_Updated,
        AGN_OAM_ShipTo_Mandatory,
        AGN_OAM_Invalid_Input,
        AGN_OAM_Address_Limit,
        AGN_OAM_Address_deleted,
        AGN_OAM_Contact_Admin,
        AGN_OAM_Unknown_Error,
        AGN_OAM_IT,
        AGN_OAM_CS,
        AGN_OAM_Invalid_Format,
        AGN_OAM_New_Shipping,
        AGN_OAM_New_ShipTo,
        AGN_OAM_NewBillTo,
        AGN_OAM_Next,
        AGN_OAM_Previous,
        AGN_OAM_Body_Submit,
        AGN_OAM_Warning_NoChanges,
        AGN_GCSP_Edit_Button,
        AGN_GCSP_Close_Button,
        AGN_GCSP_Deactivate_Button,
        AGN_GCSP_Deactivate_Billing_Address,
        AGN_GCSP_Deactivate_Shipping_Address,
        AGN_GCSP_NewBiiling_Address,
        AGN_OAM_Account_Update_case_number,
        AGN_OAM_Thank_you,
        AGN_OAM_Manage_My_Account,
        AGN_GCSP_Customer_Details,
        AGN_OAM_Declaration,
        AGN_OAM_Mandatory_Declaration,
        AGN_OAM_Accept_Declaration

    };

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');
        loadStyle(this, ASSETS1 + '/css/footer.css');
        this.header_css1 = this.country == 'CA' ? 'slds-form-element scope1_ca' : 'slds-form-element scope1';
        this.header_css2 = this.country == 'CA' ? 'slds-form-element scope2_ca' : 'slds-form-element scope2';
        this.header_css3 = this.country == 'CA' ? 'slds-form-element scope3_ca' : 'slds-form-element scope3';
         if (this.sourceCS =='cs') {
            this.cssWrapperClass = 'cs_outer_wrapper';
         } 
         else if (this.sourceOAM == 'oam') {
            this.cssWrapperClass = 'outer_wrapper';
         }
         this.disableFinishBtn = false;
         //console.log('this.hasRendered::::', this.hasRendered);
        if(!this.hasRendered) {this.renderDependentField()}
    }

     renderDependentField(){    
         
        let controllingFieldCount = 0; 
        let inputFieldCount= 0;
        var controllingFieldCmpList = this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component');   
        controllingFieldCmpList.forEach(element => {       
            if (element.iscontrollingfield) {
                let data = element.displayDependentFieldonload();//element.displayDependentField();
                if(element.displayDependentFieldonload()){
                    this.showDependentField(this.layoutMetadataMaster, element.displayDependentFieldonload());
    }
                controllingFieldCount++
            }
            inputFieldCount++
        });
        //this.hasRendered = controllingFieldCount>0 ? true : (inputFieldCount>0)
        if(controllingFieldCount>0) {
            this.hasRendered = true;
            //console.log('renderDependentField|controllingFieldCount:: ', controllingFieldCount)
        }
        else if( inputFieldCount >0){
            this.hasRendered = true;
            //console.log('renderDependentField|inputFieldCount:: ', inputFieldCount)
        }        
    }


    connectedCallback() {
        this.showLoader = true;
        this.hidemaindiv = true;

        this.source = (this.sourceOAM) ? this.sourceOAM : (this.sourceCS) ? this.sourceCS : '';
        this.isOnlineRegistration = (this.sourceOAM) ? true : false;
        if (this.sourceCS && this.sourceCS == 'cs') {
            this.isShowDeactivateButton = true;
            this.isCS = true;
            this.cssWrapperClass = 'cs_outer_wrapper';
                     
        }       
        //console.log('this.soldToSAPId>>>>>>'+this.soldToSAPId);
        //console.log('this.source>>>>>>'+this.source);
        this.getSapDetails(this.soldToSAPId, this.source);
    }

    handleSpinnerLoader(event){
        
        //console.log('eventParemeters.soldToSAPId>>>>>>>'+this.soldToSAPId);

        const eventParemeters = event.detail;
        //console.log('eventParemeters.postion>>>>>>>'+eventParemeters.postion);

        var sapId = this.existingSoldTo[0].id;
        //var sapId = '0000868248';//this.soldToSAPId;
        //console.log('sapId::::: ', sapId);

        if(eventParemeters.postion=='First'){
            const toastModel1 = this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
                element.className = 'slds-show';
             });
            const toastModel2 = this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
                element.className = 'slds-hide';
             });
            this.showLoader = true;           

        }else{
            this.showLoader = false;       
        }

    }

    getSapDetails(soldToSAPId, source) {
        //console.log('this.soldToSAPIds>>>>>>'+soldToSAPId);
        //console.log('this.sources>>>>'+source);
				//console.log('cr_record>>>>>>'+JSON.stringify(this.crRecord));
        getSapData({
            sapId: soldToSAPId,
            source: source
        })
        .then(result => {
            if (result) {
                //console.log('get SAP results:::: ', result);
                 this.existingSoldTo = result.existingSoldToAddress;
                 this.existingShipTo = result.existingShipToAddress;
                 this.existingBillTo = result.existingBillToAddress;
                               
                 let paymentMethodSet = new Set();
                 this.soldToSAPId = this.soldToSAPId ? this.soldToSAPId : this.existingSoldTo.length==1? this.existingSoldTo[0].SAP_ID_AGN__c:'';    
				
				if( this.existingSoldTo.length > 1){
					this.existingSoldTo.forEach(function (soldTo) {
                     if (soldTo.Form_Of_Payment_AGN__c) {
                         paymentMethodSet.add(soldTo.Form_Of_Payment_AGN__c);
                     } 
                     if (soldTo.Primary_AGN__c) {
						//console.log('soldTo.Primary_AGN__c::', soldTo.Primary_AGN__c, ':::soldTo.SAP_ID_AGN__c:::', soldTo.SAP_ID_AGN__c);
                        this.soldToSAPId =  this.soldToSAPId ? this.soldToSAPId : soldTo.SAP_ID_AGN__c;
                     }                    
                   });
				}else if(this.existingSoldTo.length == 1){

                    if (this.existingSoldTo[0].Form_Of_Payment_AGN__c) {
                         paymentMethodSet.add(this.existingSoldTo[0].Form_Of_Payment_AGN__c);
                     }
                }
                
				 if(this.existingBillTo.length > 1){
					 this.existingBillTo.forEach(function (billTo) {
						 if (billTo.Form_Of_Payment_AGN__c) {
							 paymentMethodSet.add(billTo.Form_Of_Payment_AGN__c);
						 }
					 });
			     }else if(this.existingBillTo.length==1){
                    if (this.existingBillTo[0].Form_Of_Payment_AGN__c) {
						paymentMethodSet.add(this.existingBillTo[0].Form_Of_Payment_AGN__c);
				    }
                 }
                 //console.log('this.paymentMethodSet:::: ', paymentMethodSet);
                 if (paymentMethodSet) {
                    this.getPaymentTerms(paymentMethodSet);
                 }
                
                 let configList = [];
                 let custConfig = result.config;
                 if(custConfig){
                    configList.push(custConfig);
                 }
                 this.customerTypeConfig = configList;
                 this.newRegistration = result.newRegistration;
                 this.primaryContact = result.primaryContact;

                 this.provienceShow = result.province;
                 this.customerType = this.isOnlineRegistration ? custConfig.Category_Label_AGN__c : custConfig.Category_AGN__c;
                 this.customerSubType = this.isOnlineRegistration ? custConfig.Sub_Category_Label_AGN__c : custConfig.Sub_Category__c;
                 if(this.isOnlineRegistration){
                     let languageValue = LANG.toUpperCase();
                    if(languageValue.includes('EN')){
                        this.customerType = custConfig.Category_AGN__c;
                        this.customerSubType =  custConfig.Sub_Category__c;
                    }else{
                        this.customerType = custConfig.Category_Label_AGN__c;
                        this.customerSubType =  custConfig.Sub_Category_Label_AGN__c;
                    }
                 }else{
                   this.customerType =   custConfig.Category_AGN__c;
                   this.customerSubType = custConfig.Cust_Group_Desc_AGN__c;
                 }
                 this.country = (this.newRegistration.SAP_Country_Code_AGN__c) ? this.newRegistration.SAP_Country_Code_AGN__c : this.newRegistration.Country_Code_AGN__c;
				 if (this.country === "BR" && this.sourceCS == 'cs') {
				   // updating CR record with updated details received from HCP	 
				   this.newRegistration.Customer_Group_AGN__c = this.crRecord.Customer_Group_AGN__c;
                   this.newRegistration.Salutation_AGN__c = this.crRecord.Salutation_AGN__c;
                   this.newRegistration.First_Name_AGN__c = this.crRecord.First_Name_AGN__c;
                   this.newRegistration.Middle_Name_AGN__c = this.crRecord.Middle_Name_AGN__c;
                   this.newRegistration.Last_Name_AGN__c = this.crRecord.Last_Name_AGN__c;
                   this.newRegistration.Gender_AGN__c = this.crRecord.Gender_AGN__c;
                   this.newRegistration.BirthDate_AGN__c = this.crRecord.BirthDate_AGN__c;
                   this.newRegistration.Consent_to_Contact_AGN__c = this.crRecord.Consent_to_Contact_AGN__c;
                   this.newRegistration.Consent_to_Phone_AGN__c = this.crRecord.Consent_to_Phone_AGN__c;
                   this.newRegistration.Consent_to_Mail_AGN__c = this.crRecord.Consent_to_Mail_AGN__c;
                   this.newRegistration.Consent_to_Email_AGN__c = this.crRecord.Consent_to_Email_AGN__c;
                   this.newRegistration.Distribution_ID_AGN__c = this.crRecord.Distribution_ID_AGN__c;
                   this.newRegistration.Business_Unit_AGN__c = this.crRecord.Business_Unit_AGN__c;
                   this.newRegistration.Account_Status_AGN__c = this.crRecord.Account_Status_AGN__c;
                   this.newRegistration.Sub_Specialty_Allergan_AGN__c = this.crRecord.Sub_Specialty_Allergan_AGN__c;
                   this.newRegistration.Email_AGN__c = this.crRecord.Email_AGN__c;
                   this.newRegistration.Phone_AGN__c = this.crRecord.Phone_AGN__c;
                   this.newRegistration.Mobile_AGN__c = this.crRecord.Mobile_AGN__c;
                   this.newRegistration.Fax_AGN__c = this.crRecord.Fax_AGN__c;
                   this.newRegistration.Graduation_Year_AGN__c = this.crRecord.Graduation_Year_AGN__c;
                   this.newRegistration.Physician_Registration_Reference_AGN__c = this.crRecord.Physician_Registration_Reference_AGN__c;		
				}
                 if(this.country === "NL"){    // Declaration for NL OAM
                    this.displayNLdeclaration = true;
                 }
                 this.ctype = custConfig.Category_AGN__c;
                 this.cSubtype = custConfig.Sub_Category__c;
                 this.getPaymentOptions(this.country);
                 this.invokeGetLayout(this.newRegistration, this.country, this.customerTypeConfig, 2);
				 this.getGCSPCustomSettings(this.country);
				 if (this.country === "BR") {
				     //this.showBillTo = false;
				     this.isBrazilOam = this.source == 'oam' ? true : false;
				 }else if(this.country === "CA"){
                     this.isCanadaOam = this.source == 'oam' ? true : false;
            }
            }
        })
        .catch(error => {
                console.log('error at get data::: ',error);
                
            });

    }

    invokeGetLayout(registration, countryCode, customerTypeConfig, stepNo) {        
        //console.log('invokeGetLayout>>>>>>>>>>>>>>>', countryCode, registration, customerTypeConfig, stepNo);        
         if (countryCode === 'IT') {
             getLayout({
                     country: countryCode,
                     stepNo: '2',
                     customerType: registration.Customer_Category_AGN__c,
                     customerSubType: registration.Customer_Sub_Category_AGN__c,
                     custTypeConfig: customerTypeConfig,
                     source: this.source
                 })
                 .then(result => {
                     this.hidemaindiv = false;
                     this.showLoader = false;
                     this.setShippingAddressLayoutFields(result);
                     this.layoutMetadataMaster = result;

                 })
                 .catch(error => {
                     console.log('error>>>>>>>>>>>>>>>>>>>', error);
                     this.error = error;
                     this.hidemaindiv = false;
                     this.showLoader = false;
                 });
         } 
         else {
                getLayout({
                    country: countryCode,
                    //stepNo: this.stepNo , 
                    stepNo: '2',
                    customerType: registration.Customer_Category_AGN__c,
                    customerSubType: registration.Customer_Sub_Category_AGN__c,
                    custTypeConfig: customerTypeConfig,
                    source: this.source
                })
                .then(result => {
                    //console.log('result>>>>>>>>>>>>>>>>>>>', result);
                    this.hidemaindiv = false;
                    this.showLoader = false;                    
                    this.setShippingAddressLayoutFields(result);
                    this.layoutMetadataMaster = result;
                })
                .catch(error => {
                    console.log('error>>>>>>>>>>>>>>>>>>>', error);
                    this.error = error;
                    this.hidemaindiv = false;
                    this.showLoader = false;
                });
            }
    }

    setShippingAddressLayoutFields(data) {
        var settings = [];
        settings = data;
        var settingsMap = settings;
        var soldToAddressFields = [];
        var billToAddressFields = [];
        var shipToAddressFields = [];
        //console.log('settingsMapstep2Address>>>>>>>>>>>>>>>>>>', settingsMap);
        for (var key in settingsMap) {
            // //console.log('key>>>>>>>', key);
            //console.log('value>>>>>>>', settingsMap[key]);
            if (key === 'Registered Address') {
                soldToAddressFields = settingsMap[key];
            } else if (key === 'Shipping Address') {
                shipToAddressFields = settingsMap[key];
            } else if (key === 'Billing Address') {
                billToAddressFields = settingsMap[key];
            }
        }
        this.soldToAddressFields = soldToAddressFields;
        this.shipToAddressFields = shipToAddressFields;
        this.billToAddressFields = billToAddressFields;
        this.isSoldToflatView = true;
        this.isShipToflatView = true;
        this.isBillToflatView = true;
        //this.disableFinishBtn = false;
        /* //console.log('soldToAddressFields>>>>>>>>>>>>>>>>>>', soldToAddressFields);
         //console.log('shipToAddressFields>>>>>>>>>>>>>>>>>>', shipToAddressFields);
         //console.log('billToAddressFields>>>>>>>>>>>>>>>>>>', billToAddressFields);*/
    }

    getGCSPCustomSettings(countryCode) {
        getGCSPSettings({
                country: countryCode
            })
            .then(result => {
                if (result) {
                    //console.log('Custom Settings Data*******', result);
                    //this.billtoLimit = parseInt(result.Number_Of_BillTo_Allowed_AGN__c);
                    //this.shiptoLimit = parseInt(result.Number_Of_ShipTo_Allowed_AGN__c); 
                    this.shiptoLimit = (this.source == 'oam') ? parseInt(result.Number_Of_ShipTo_Allowed_AGN__c) : parseInt(result.Number_Of_ShipTo_Allowed_CS_AGN__c);
                	this.billtoLimit = (this.source === 'oam') ? parseInt(result.Number_Of_BillTo_Allowed_AGN__c) :  parseInt(result.Number_Of_BillTo_Allowed_CS_AGN__c);
                     
					if(this.billtoLimit <= 0 || !this.billtoLimit){
                    	this.showBillTo = false;
                    }
                    
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

    getPaymentOptions(countryCode) {
         //console.log('countryCode>>>>>>>>>>>>>>>', countryCode);
        getPaymentMethods({
                country: countryCode,
                source: this.source
            })
            .then(result => {
                  //console.log('Form of Payment>>>>>>>>>>>>>>>>>>>', result);
                if (result) {
                    this.PaymentMethod = result;
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

    getPaymentTerms(paymentMethodSet) {
        //console.log('paymentMethodSet>>>>>'+JSON.stringify(paymentMethodSet));
        let paymethods = [];
        paymentMethodSet.forEach(function (pay) {
            paymethods.push(pay);
        });
        //console.log('paymethods>>>>>'+JSON.stringify(paymethods));
        //console.log('this.source>>>>>'+this.source);
        getPaymentTerms({
                paymentMethodSet: paymethods,
                source: this.source
            })
            .then(result => {
                if (result) {
                    //console.log('********Payment Term List*************', result);
                    this.paymentTermMap = result;
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

    paymentHandler(event) {       
        //console.log('Payment Event Handler>>>>>>>>>>>', event.detail.showBankDetails);
        let eventValue = event.detail.showBankDetails;
        let key = event.detail.key;
        this.showBankDeclarationMap.set(key, eventValue);
        let showBankDeclaration = false;
        //console.log('this.showBankDeclarationMap>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', this.showBankDeclarationMap);
        for (let value of this.showBankDeclarationMap.values()) {
            //console.log('Iterating Map>>>>>>>>', value);
            if (value) {
                showBankDeclaration = true;
            }
        }
        this.showBankDeclaration = showBankDeclaration;
        //console.log('this.showBankDeclaration>>>>>>>>>>>>>>>>>>>>>', this.showBankDeclaration);
    }


    addNewBillTo() {
        //console.log('inside addNewBillTo>>>>>>>>>>>', this.billingMapCounter);
         
        var mapKey = 'Shipping Address' + this.billingMapCounter;
        let billtoLimit = 0;
        if (this.billtoLimit) {
            billtoLimit = this.billtoLimit;
        }
        //console.log('billtoLimit>>>>>>>>>>>', billtoLimit);
        if (billtoLimit > 0) {
            let billtolen = 0;            
            if (this.existingBillTo.length > 0) {
                billtolen += this.existingBillTo.length;
            }
            if (this.billingMap.length > 0) {
                billtolen += this.billingMap.length;
            }
            //console.log('billtolen>>>>>>>>>>>', billtolen);
            
            if (billtolen < billtoLimit) {
                this.billingMap.push({
                    key: mapKey,
                    value: this.billToAddressFields
                });

                this.billingMapCounter++;
                if (this.billingMapCounter > 0) {
                    this.showNewBillto = true;
                } else {
                    this.showNewBillto = false;
                }
            } else {
                //this.showToast('Error', AGN_OAM_NumberOfBillTo_LimitExceed, 'Error');
                //console.log('Number of billto limit exceeded');
            }
        } else {
            this.billingMap.push({
                key: mapKey,
                value: this.billToAddressFields
            });
            //this.shippingMap.set(mapKey , this.shipToAddressFields);
            this.billingMapCounter++;
            //console.log('this.shippingMap>>>>>>>>>>>',this.shippingMap);
            //console.log('this.shippingMapCounter>>>>>>>>>>>',this.shippingMapCounter);
            if (this.billingMapCounter > 0) {
                this.showNewBillto = true;
            } else {
                this.showNewBillto = false;
            }
        }

    }

    deleteBillTo(event) {
        this.hidemaindiv = true;
        this.showLoader = true;
        var indx = event.detail.index;
        var instancetype = event.detail.instancetype;
        //console.log('inside delete event handler>>>>>>>>>>>>>>>',indx);
        if (instancetype === 'new') {
            if (indx === 0 || indx > 0) {
                //console.log('index>>>>>>>>>>>>',indx);
                var billingMap = this.billingMap;
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>',shippingMap);
                billingMap.splice(indx, 1);
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>',shippingMap);
                this.billingMap = billingMap;
                this.billingMapCounter++;
                if (this.billingMapCounter > 0) {
                    this.showNewBillto = true;
                } else {
                    this.showNewBillto = false;
                }
            }
            this.hidemaindiv = false;
            this.showLoader = false;
        }
        if (instancetype === 'old') {
            var recordId = event.detail.recordId;
            //console.log('call permanent delete method>>>>>>>', recordId);
            var billToAddr = this.billToAddr;
            let customerAddress = {
                'sobjectType': 'Allergan_Customer_Address_AGN__c',
                'Id': recordId
            };
            deleteAddress({
                    customerAddress: customerAddress
                })
                .then(result => {
                    billToAddr.splice(indx, 1);
                    this.hidemaindiv = false;
                    this.showLoader = false;
                })
                .catch(error => {
                    console.log('error == ', error);
                    this.hidemaindiv = false;
                    this.showLoader = false;
                });

        }

    }

    addNewShipTo() {
        //console.log('inside addNewShipTo>>>>>>>>>>>', this.shiptoLimit);
        let shiptoLimit = 0;
        if (this.shiptoLimit) {
            shiptoLimit = this.shiptoLimit;
        }
        if (shiptoLimit > 0) {
            let shiptolen = this.getShiptoLength();
            //console.log('shiptolen::::: ', shiptolen);
            if (shiptolen <= shiptoLimit) {
                let mapKey = AGN_OAM_Shipping_Address + this.shippingMapCounter;
                this.shippingMap.push({
                    key: mapKey,
                    value: this.shipToAddressFields
                });
                
                this.shippingMapCounter++;
                //console.log('this.shippingMap>>>>>>>>>>>',this.shippingMap);
                //console.log('this.shippingMapCounter>>>>>>>>>>>',this.shippingMapCounter);
                if (this.shippingMapCounter > 0) {
                    this.showNewShipto = true;
                } else {
                    this.showNewShipto = false;
                }
            } else {
                this.showNewShiptoButton = false;
                this.showToast('error', AGN_OAM_Address_Limit, 'error');
               //console.log('Ship to limit exceded');
            }
        } else {
            var mapKey = 'Shipping Address' + this.shippingMapCounter;
            this.shippingMap.push({
                key: mapKey,
                value: this.shipToAddressFields
            });
            //this.shippingMap.set(mapKey , this.shipToAddressFields);
            this.shippingMapCounter++;
            //console.log('this.shippingMap else>>>>>>>>>>>',this.shippingMap);
            //console.log('this.shippingMapCounter else>>>>>>>>>>>',this.shippingMapCounter);
            if (this.shippingMapCounter > 0) {
                this.showNewShipto = true;
            } else {
                this.showNewShipto = false;
            }
        }



    }
    deleteShipTo(event) {
        this.hidemaindiv = true;
        this.showLoader = true;
        var indx = event.detail.index;
        var instancetype = event.detail.instancetype;
        //console.log('inside delete event handler>>>>>>>>>>>>>>>', indx);
        if (instancetype === "new") {
            if (indx === 0 || indx > 0) {
                //console.log('index>>>>>>>>>>>>', indx);
                var shippingMap = this.shippingMap;
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>', shippingMap);
                shippingMap.splice(indx, 1);
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>', shippingMap);
                this.shippingMap = shippingMap;
                this.shippingMapCounter++;
                if (this.shippingMapCounter > 0) {
                    this.showNewShipto = true;
                } else {
                    this.showNewShipto = false;
                }
            }
            this.setNewButtonVisibility();
        }
       
        this.hidemaindiv = false;
        this.showLoader = false;

    }

    setErrorMessage(error, custommsg) {
        //console.log('error == ', error);
        if (custommsg) {
            this.showToast('error', AGN_OAM_Contact_Admin + custommsg, 'error');
        } else if (error && error.body && error.body.message) {
            this.showToast('error', AGN_OAM_Contact_Admin + error.body.message, 'error');
        } else {
            this.showToast('error', AGN_OAM_Unknown_Error, 'error');
        }

    }

    setNewButtonVisibility() {
        //set new button visibility
        let shiptoLimit = 0;
        if (this.shiptoLimit) {
            shiptoLimit = this.shiptoLimit;
        }
        if (shiptoLimit > 0) {
            let shiptolen = this.getShiptoLength();
            //console.log('shiptolen>>>>>>>>>>>>', shiptolen);
            //console.log('shiptoLimit>>>>>>>>>>>>', shiptoLimit);
            if (shiptolen <= shiptoLimit) {
                this.showNewShiptoButton = true;
            }
        }
    }
    
    getShiptoLength() {
        let shiptolen = 0;
        
        if (this.existingShipTo.length > 0) {
            shiptolen += this.existingShipTo.length;
        }
        if (this.shippingMap.length > 0) {
            shiptolen += this.shippingMap.length;
        }
        return shiptolen;
    }
    
   
    hideFullView(event){
        var sapRecordId = event.target.value;
        var sapId = sapRecordId.SAP_ID_AGN__c;
        //console.log('sapId>>>>>',sapId);
        //console.log('this.showSAPIdDeactivateMap>>>>>',JSON.stringify(this.showSAPIdDeactivateMap));
            if (this.showSAPIdDeactivateMap.has(sapId) && this.showSAPIdDeactivateMap.get(sapId)) {
               /* this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {

                    element.className = 'slds-show';

                }); */
                this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                    element.className = 'readonlyAddressclass'; 
                });  
          
            }else {
                this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                    element.className = 'editAddressclass'; 
                });  
            }
            //this.showSAPIdDeactivateMap.set(sapId, false);
            var buttonName = event.target.name;
            this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {

                element.className = 'slds-hide';

            });
            this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {

                element.className = 'slds-show';

            });        

    }

   
    
    show_hide_SoldTo_Address(event){
       var sapRecordId = event.target.value;
       var sapId = sapRecordId.SAP_ID_AGN__c;
        //console.log('sapId::::: ', sapId);

      /*  this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
             element.classList.removeClass('Registered_add');
            element.classList.toggle('slds-show'); //'Registered_add1'
          
        });
         this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {

             element.classList.toggle('slds-hide'); //'Registered_add'

         });

         */      
         //Added-for-PT
        this.existingSoldTo.forEach(element => {
            if(element.SAP_ID_AGN__c ===sapId){
                element.showDetail = true;
            }
        });

        const toastModel1 = this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
            element.className = 'slds-show';
         });
        const toastModel2 = this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
            element.className = 'slds-hide';
         });
       
    }
    show_hide_SoldTo_FullView(event) {
         var sapRecordId = event.target.value;
         var sapId = sapRecordId.SAP_ID_AGN__c;
         const toastModel1 = this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
            element.className = 'slds-hide';
         });
        const toastModel2 = this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
            element.className = 'slds-show';  
         });
       
            
    } 
    show_hide_ShipTo_Address(event) {
        var sapRecordId = event.target.value;
        var sapId = sapRecordId.SAP_ID_AGN__c;
        //console.log('sapId::::: ', sapId);
        //Added-for-PT
        this.existingShipTo.forEach(element=> {
            if(element.SAP_ID_AGN__c ===sapId){
                element.showDetail = true;
            }
        });

        this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {

              element.className = 'slds-show';  
            //element.classList.toggle('Registered_add1');

        });
         this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
              element.className = 'slds-hide';
             //element.classList.toggle('Registered_add');

         }); 
       
    }
    show_hide_ShipTo_Address_Delete(event) {

        //var sapRecordId = event.target.value;        
        //var sapId = sapRecordId.SAP_ID_AGN__c;
        var isChecked = event.target.checked; 
        var sapId = event.target.name; 
        //console.log('sapId Delete::::: ', sapId);  
        //console.log('isChecked::::: ', isChecked);
        if(isChecked){
            this.showSAPIdDeactivateMap.set(sapId, true);
           /* this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
                element.className = 'slds-show';  
            // element.classList.toggle('Registered_add1');

            }); */
            this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                element.className = 'readonlyAddressclass'; 
            });
        }else{
             this.showSAPIdDeactivateMap.set(sapId, false);
            this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                element.className = 'editAddressclass'; 
            });
        }   
        
        /* this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
              element.className = 'slds-hide';
            //element.classList.toggle('Registered_add');

         });
          this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
              element.className = 'slds-show';  
             //element.classList.toggle('Registered_add1');

          }); */
    }
    show_hide_BillTo_Address(event) {
        var sapRecordId = event.target.value;
        var sapId = sapRecordId.SAP_ID_AGN__c;
        //console.log('sapId::::: ', sapId);
        
		//Added-for-PT
        this.existingBillTo.forEach(element => {
            if(element.SAP_ID_AGN__c ===sapId){
                element.showDetail = true;
            }
        });

        this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
            element.className = 'slds-show'; 
            //element.classList.toggle('Registered_add1');

        });
         this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
            element.className = 'slds-hide'; 
            // element.classList.toggle('Registered_add');

         });
        

    }
    show_hide_BillTo_Address_Delete(event) {
        /*var sapRecordId = event.target.value;
        var sapId = sapRecordId.SAP_ID_AGN__c;
        //console.log('sapId Delete::::: ', sapId);
        this.showSAPIdDeactivateMap.set(sapId, true);
        this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
            element.className = 'slds-show'; 
            //element.classList.toggle('Registered_add1');

        });
         this.template.querySelectorAll(`[data-value="${sapId}"]`).forEach(element => {
            element.className = 'slds-hide';
            // element.classList.toggle('Registered_add');

         });

          this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
            element.className = 'slds-show'; 
             // element.classList.toggle('Registered_add1');

          }); */
		  
		 var isChecked = event.target.checked; 
        var sapId = event.target.name; 
        //console.log('sapId Delete::::: ', sapId);  
        //console.log('isChecked::::: ', isChecked);
        if(isChecked){
            this.showSAPIdDeactivateMap.set(sapId, true);
           /* this.template.querySelectorAll(`[data-id="${sapId}"]`).forEach(element => {
                element.className = 'slds-show';  
            // element.classList.toggle('Registered_add1');

            }); */
            this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                element.className = 'readonlyAddressclass'; 
            });
        }else{
             this.showSAPIdDeactivateMap.set(sapId, false);
            this.template.querySelectorAll(`[data-address-id="${sapId}"]`).forEach(element => {
                element.className = 'editAddressclass'; 
            });
        }   
        
        
    }

    handleClick() {
	 const nlDecBox = this.template.querySelector(".nlChkBox");
        if(this.country === 'NL' && this.source=='oam' && nlDecBox.checked !== true){
            
            this.showToast('error',AGN_OAM_Accept_Declaration,'error');
            
        } else {
        let labelMap = getCustomLable();
        this.hidemaindiv = true;
        this.showLoader = true;
        let addressFieldsValid = true;
        let paymentFieldsValid = true;
        var isFormatValid = true;
        let paymntfieldIssue = false;
        let formatIssuefieldList =[];

        var newBillToAddrList = [];
        var newShipToAddrList = [];
        var billToAddrList = [];
        var shipToAddrList = [];
        var soldToAddrlist = [];
        var hasFormatIssues = false;

        var newBilltoMap = new Map();
        var newShiptoMap = new Map();

        var oldBilltoMap = new Map();
        var oldShiptoMap = new Map();
        var oldSoldtoMap = new Map();
        var ChangedOldSoldtoIdMap  = new Map();
        var ChangedOldShiptoIdMap  = new Map();
        var ChangedOldBilltoIdMap  = new Map();

        soldToAddrlist = this.existingSoldTo;
        shipToAddrList = this.existingShipTo;
        billToAddrList = this.existingBillTo;

        if (soldToAddrlist) {
            soldToAddrlist.forEach(function (sold) {
                oldSoldtoMap.set(sold.SAP_ID_AGN__c, sold);
            });
        }
        if (shipToAddrList) {
            shipToAddrList.forEach(function (ship) {
                oldShiptoMap.set(ship.SAP_ID_AGN__c, ship);
            });
        }
        if (billToAddrList) {
            billToAddrList.forEach(function (bill) {
                oldBilltoMap.set(bill.SAP_ID_AGN__c, bill);
            });
        }

        var hasPaymentErr = false;
        let isObjRecordChange = new Map();
        
        let nonSApIdValidaddFieldsMap = new Map();
        let nonSApIdValidPaymentFieldsMap = new Map();
        let labelNameVAT = '';
        let labelNameTAX = '';
        let VATORTAXRequired = '';
        let hasTaxVatRequired = '';
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                let isChanged = true;         
                //console.log('field value isChanged>>>>>>>>>>>>>>>>>>>>', element.isChanged); 
                isChanged = element.isChanged;	 
                //console.log('element.checkValidity1():::::',element.checkValidity1());
                isFormatValid = element.isFormatValid();
                if(element.fieldname == 'Tax_Number_AGN__c'){               
                    labelNameTAX = labelMap.get(element.customlabel);                                                      
                }
                if(element.fieldname == 'VAT_Number_AGN__c'){               
                    labelNameVAT = labelMap.get(element.customlabel);                                                                 
                }
                if(isFormatValid){                    
                    element.setCustomErrorMessage('');
                    if (element.checkValidity1()) { 
                        let elementVal = element.getUserEnteredInput();                        
                        if (elementVal && isFormatValid) {
                            if (element.sobjectname === 'Allergan_Customer_Address_AGN__c') {
                                if (element.objecttype === 'soldto' && element.instancetype === 'old') {

                                    let recordSAPId = element.record.SAP_ID_AGN__c;
                                    //console.log('oldSoldtoMap>>>>>>>>>>>>>>>>>', oldSoldtoMap);

                                    if (oldSoldtoMap.has(recordSAPId) && isChanged) {
                                        isObjRecordChange.set(recordSAPId, true);
                                        if(ChangedOldSoldtoIdMap.has(recordSAPId))
                                        {
                                            ChangedOldSoldtoIdMap.get(recordSAPId)['IsChanged'] = isChanged;
                                        }
                                        else{
                                            ChangedOldSoldtoIdMap.set(recordSAPId ,{IsChanged : isChanged})
                                        }
                                        
                                        oldSoldtoMap.get(recordSAPId)[element.fieldname] = elementVal;
                                    }

                                } else if (element.objecttype === 'billto' && element.instancetype === 'new') {

                                    //console.log('has index>>>>>>>>>>>>>>>', newBilltoMap.has(element.index));
                                    if (newBilltoMap.has(element.index)) {
                                        newBilltoMap.get(element.index)[element.fieldname] = elementVal;
                                    } else {
                                        let newBilltoAddress = {
                                            'sobjectType': 'Allergan_Customer_Address_AGN__c'
                                        };
                                        newBilltoAddress[element.fieldname] = elementVal;
                                        newBilltoMap.set(element.index, newBilltoAddress);
                                    }

                                } else if (element.objecttype === 'billto' && element.instancetype === 'old') {
                                    let recordSAPId = element.record.SAP_ID_AGN__c;
                                    //console.log('oldBilltoMap>>>>>>>>>>>>>>>>>', oldBilltoMap);

                                    if (oldBilltoMap.has(recordSAPId) && isChanged) {
                                        isObjRecordChange.set(recordSAPId, true);
                                            if(ChangedOldBilltoIdMap.has(recordSAPId))
                                            {
                                                ChangedOldBilltoIdMap.get(recordSAPId)['IsChanged'] = isChanged;
                                            }
                                            else{
                                                ChangedOldBilltoIdMap.set(recordSAPId ,{IsChanged : isChanged})
                                            }
                                        oldBilltoMap.get(recordSAPId)[element.fieldname] = elementVal;
                                    }

                                } else if (element.objecttype === 'shipto' && element.instancetype === 'new') {

                                    //console.log('has index>>>>>>>>>>>>>>>', newShiptoMap.has(element.index));
                                    if (newShiptoMap.has(element.index)) {
                                        newShiptoMap.get(element.index)[element.fieldname] = elementVal;
                                    } else {
                                        let newShiptoAddress = {
                                            'sobjectType': 'Allergan_Customer_Address_AGN__c'
                                        };
                                        newShiptoAddress[element.fieldname] = elementVal;
                                        newShiptoMap.set(element.index, newShiptoAddress);
                                    }

                                } else if (element.objecttype === 'shipto' && element.instancetype === 'old') {

                                    let recordSAPId = element.record.SAP_ID_AGN__c;
                                    //console.log('oldShiptoMap>>>>>>>>>>>>>>>>>', oldShiptoMap);

                                    if (oldShiptoMap.has(recordSAPId)  && isChanged) {
                                        //console.log('Shipto :: recordSAPId::::', recordSAPId);
                                        isObjRecordChange.set(recordSAPId, true);
                                        //console.log('Shipto :: isObjRecordChange::::', isObjRecordChange);
                                        if(ChangedOldShiptoIdMap.has(recordSAPId))
                                        {
                                            ChangedOldShiptoIdMap.get(recordSAPId)['IsChanged'] = isChanged;
                                        }
                                        else{
                                            ChangedOldShiptoIdMap.set(recordSAPId ,{IsChanged : isChanged})
                                        }
                                        oldShiptoMap.get(recordSAPId)[element.fieldname] = elementVal;
                                    }

                                }
                            }
                        }

                    } else {
                        addressFieldsValid = false; 
                        //console.log('element.getSAPId()2>>>>>>>>>>>>>>>',element.getSAPId());
                        if(!element.getSAPId()){
                            nonSApIdValidaddFieldsMap.set('New', addressFieldsValid);
                        }
                        else if(isChanged){
                            isObjRecordChange.set(element.getSAPId(), true);
                        }				  
                        //console.log('element.getSAPId()2>>>>>>>>>>>>>>>',element.getSAPId());
                        this.errorSAPIdSet.add(element.getSAPId());    
                        //this.hidemaindiv = false;
                        //this.showLoader = false;       
                    }
                }
                else{                    
                    hasFormatIssues = true;   
                    formatIssuefieldList.push(labelMap.get(element.customlabel));
                    if(element.getSAPId())           
                        this.errorSAPIdSet.add(element.getSAPId());
                    if(!element.getSAPId()){
                        nonSApIdValidaddFieldsMap.set('New', addressFieldsValid);
                    }
                    else if(isChanged){
                        isObjRecordChange.set(element.getSAPId(), true);
                    }
                }
                //console.log('Is Format Valid>>>>>>>>', isFormatValid);               

        });
       
        if(hasFormatIssues || !addressFieldsValid)
        {   
            let hasExistingDataInValid = false;        
            if(this.errorSAPIdSet.size>0){

                for (let errorSAP of this.errorSAPIdSet){
                    if(isObjRecordChange.has(errorSAP)&& isObjRecordChange.get(errorSAP)){
                        //console.log('errorSAP::::',errorSAP);                        
                        hasExistingDataInValid = true;
                        const toastModel1 = this.template.querySelectorAll(`[data-id="${errorSAP}"]`).forEach(element => {
                            //console.log('element.className1>>>',element.className)
                            element.className = 'slds-show';
                        });
                        const toastModel2 = this.template.querySelectorAll(`[data-value="${errorSAP}"]`).forEach(element => {
                            element.className = 'slds-hide';
                        });
                    }
                }
                this.errorSAPIdSet.clear();
                if(hasExistingDataInValid){
                    if(!addressFieldsValid){
                        this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
                    }
                    else if(hasFormatIssues)
                    {
                        this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
                    }
                    this.showLoader = false;
                    this.hidemaindiv = false;      
                    return;
                }               
            }

            if(nonSApIdValidaddFieldsMap.has('New')){
                if(!addressFieldsValid)
                {
                    this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
                    this.hidemaindiv = false;
                    this.showLoader = false; 
                    return;
                }
                else if(hasFormatIssues){
                    this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
                    this.hidemaindiv = false;
                    this.showLoader = false; 
                    return;
                }
             
            }
                      
        }
            
        
        let csFlagCheck = false; 
        let paymentChanged = false;
        let paymentformatValid = new Set();
        let paymentinputValid=true;
        let isAnyPaymentMethodInValid  = false;
        let isAnyPaymentTermInValid = false;
        
        this.template.querySelectorAll('c-agn_gcsp_payment-form').forEach(element => {

            //console.log('invalifFormatfields1 >>>>>>>>>>>>>>>>', element.isAllFormatValid());
            if(element.isAllFormatValid())
            {
                let invalifFormatfields = element.isAllFormatValid();
                //console.log('invalifFormatfields >>>>>>>>>>>>>>>>', invalifFormatfields);
                invalifFormatfields.split(',').forEach(e=>{
                    paymentformatValid.add(e);
                    //console.log('e>>>>>>>>>>>>>>>>', e);
                });                
            }
            if(!element.checkAllfieldValid()){
                paymentinputValid = false;
            }  

            let isPaymentMethodValid = element.checkPaymentMethod();
            let isUpdateForm =  element.getIsUpdateFrom();
            //console.log('isPaymentMethodValid >>>>>>>>>>>>>>>>', isPaymentMethodValid);
            let isPaymentTermValid = element.checkPaymentTerm();
            //console.log('isPaymentTermValid >>>>>>>>>>>>>>>>', isPaymentTermValid);
            if(!isPaymentTermValid && !isUpdateForm)
            {                     
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
                isAnyPaymentTermInValid = true
            }
            if(!isPaymentMethodValid && !isUpdateForm)
            {
            
                paymntfieldIssue = true;
                paymentFieldsValid = false;
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
                isAnyPaymentMethodInValid = true;
            }        


        });

        
        if(isAnyPaymentMethodInValid){
            this.showLoader = false;
            this.hidemaindiv = false; 
            this.showToast('error',AGN_OAM_Required_Fields_Missing_Error+' ' +  AGN_OAM_Body_PaymentMethod ,'error');
            return;
         }
         if(isAnyPaymentTermInValid){
            this.showLoader = false;
            this.hidemaindiv = false; 
            this.showToast('error',AGN_OAM_Required_Fields_Missing_Error+' ' + AGN_OAM_Payment_Term ,'error'); 
            return;
         }

         if(!paymentinputValid){
            this.showLoader = false;
            this.hidemaindiv = false; 
            this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
            return;
         }
        if(paymentformatValid && paymentformatValid.size >0){
            this.showLoader = false;
            this.hidemaindiv = false; 
            this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+ Array.from(paymentformatValid).join(), 'error'); 
            paymentformatValid = new Set();
            return;
         }

        
        this.template.querySelectorAll('c-agn_gcsp_payment-form').forEach(element => {
            let paymentResponse = element.validateInputs();
            let hasErrors = true;
            let paymentDetails;  
            csFlagCheck = false;
            //console.log('paymentResponse>>'+paymentResponse);
           
            let isPaymentMethodValid = element.checkPaymentMethod();
            let isUpdateForm =  element.getIsUpdateFrom();           
            let isPaymentTermValid = element.checkPaymentTerm();

            if(paymentResponse){
                    if(paymentResponse.includes('FIELDS_NOT_FOUND')){                    
                        paymentDetails = false;
                        hasErrors = false;
                    }else if(paymentResponse==='error'){
                        hasPaymentErr = true;
                        paymentDetails = false; 
                        if(!element.getSAPId()){
                            nonSApIdValidPaymentFieldsMap.set('NewPayment', false);
                        }
                        //While Update the Existing Record then escape the Payment method and Payment Term validation
                        if(element.getSAPId() && isUpdateForm && isPaymentMethodValid && isPaymentTermValid){
                            this.errorSAPIdSet.add(element.getSAPId()); 
                        }else if(element.getSAPId() && !isUpdateForm){
                            this.errorSAPIdSet.add(element.getSAPId()); 
                        }
                           
                    }else if(paymentResponse==='NoChanges'){ //this.source=='cs' && 
                        csFlagCheck = true;
                        paymentDetails = false;
                    }
                    else{
                        paymentDetails = paymentResponse;
                        paymentChanged = true;
                    }
                }else{
                    paymentDetails = false;
                }

            if (paymentDetails) {
                let index = element.index;
                let objecttype = element.objecttype;
                //console.log('Iterating payment form>>>>>>>>>>>>>>>>', paymentDetails);
                //console.log('payment index>>>>>>>>>>>>>>>', index);
                        
                paymentFieldsValid = true;
                paymentDetails.forEach(function (payment) {
                                    
                    if (objecttype === 'soldto') {                    
                        if (payment.SAP_ID_AGN__c) {
                            
                            isObjRecordChange.set(payment.SAP_ID_AGN__c, true);
                            
                            if (oldSoldtoMap.has(payment.SAP_ID_AGN__c)) {
                                for (var attkey in payment) {
                                    if (payment.hasOwnProperty(attkey)) {
                                        //console.log('key>>>>>>>>>', attkey);
                                        //console.log('payment[attkey]>>>>>>>>>', payment[attkey]);
                                        oldSoldtoMap.get(payment.SAP_ID_AGN__c)[attkey] = payment[attkey];
                                    }
                                }

                            }
                        }
                    } else if (objecttype === 'billto') {
                        //console.log('ins33>>');
                        if (payment.SAP_ID_AGN__c) {
                            
                            isObjRecordChange.set(payment.SAP_ID_AGN__c, true);
                            
                            //console.log('ins44>>');
                            /* Existing Records ==== Record Update */
                            if (oldBilltoMap.has(payment.SAP_ID_AGN__c)) {
                                //console.log('ins55>>');
                                for (var attkey in payment) {
                                    if (payment.hasOwnProperty(attkey)) {
                                        //console.log('key>>>>>>>>>', attkey);
                                        //console.log('payment[attkey]>>>>>>>>>', payment[attkey]);
                                        oldBilltoMap.get(payment.SAP_ID_AGN__c)[attkey] = payment[attkey];
                                    }
                                }

                            }
                        } else {
                            /* New Records ==== Record Insert */
                            //console.log('New Billing Address>>>>>>>>>>>>', newBilltoMap);
                            //console.log('New Billto index>>>>>>>>>>>>>>>>>>', index);
                            if (newBilltoMap.has(index)) {
                                for (var attkey in payment) {
                                    if (payment.hasOwnProperty(attkey)) {
                                        //console.log('key>>>>>>>>>', attkey);
                                        //console.log('payment[attkey]>>>>>>>>>', payment[attkey]);
                                        newBilltoMap.get(index)[attkey] = payment[attkey];
                                    }
                                }

                            }
                        }
                        //console.log('ins66>>');
                    }

                });
            } 
            else {
                //console.log('ins77>>');
                paymentFieldsValid = false;
            }
        });

        if(csFlagCheck || paymentChanged){
            paymentFieldsValid = true;
        }
        
        //console.log('addressFieldsValid::::', addressFieldsValid);
        //console.log('paymentFieldsValid::::', paymentFieldsValid);
        //console.log('hasFormatIssues::::', hasFormatIssues);
        
        var isUpdate = false;
        
            //UPSERT DATA CODE HERE
            newBillToAddrList = [];
            newShipToAddrList = [];
            billToAddrList = [];
            shipToAddrList = [];
            soldToAddrlist = [];

            for (let value of newBilltoMap.values()) {              
                newBillToAddrList.push(value);
                isUpdate = true;
            }
            for (let value of newShiptoMap.values()) {
                newShipToAddrList.push(value);
                isUpdate = true;
            }
            for (let value of oldBilltoMap.values()) {
                if (this.showSAPIdDeactivateMap.has(value.SAP_ID_AGN__c) || (isObjRecordChange.has(value.SAP_ID_AGN__c)&& isObjRecordChange.get(value.SAP_ID_AGN__c))){//ChangedOldBilltoIdMap.has(value.SAP_ID_AGN__c) || paymentChanged
                    if(this.showSAPIdDeactivateMap.get(value.SAP_ID_AGN__c)){
                        value.Request_for_Deactivation_AGN__c = true; 
                    }
                    billToAddrList.push(value);
                    isUpdate = true;
                }
            }
            for (let value of oldShiptoMap.values()) {
                if (this.showSAPIdDeactivateMap.has(value.SAP_ID_AGN__c) || (isObjRecordChange.has(value.SAP_ID_AGN__c)&& isObjRecordChange.get(value.SAP_ID_AGN__c))){ // ChangedOldShiptoIdMap.has(value.SAP_ID_AGN__c)) {
                    if(this.showSAPIdDeactivateMap.get(value.SAP_ID_AGN__c)){
                        value.Request_for_Deactivation_AGN__c = true; 
                    }
                    shipToAddrList.push(value);
                    isUpdate = true;
                }
            }
                //console.log('old slodto Map ::::', oldSoldtoMap.values());
            for (let value of oldSoldtoMap.values()) {             
                    if (isObjRecordChange.has(value.SAP_ID_AGN__c)&& isObjRecordChange.get(value.SAP_ID_AGN__c)) { //ChangedOldSoldtoIdMap.has(value.SAP_ID_AGN__c) || paymentChanged
                        soldToAddrlist.push(value);
                        isUpdate = true;
                    } else if (this.source == 'cs') {
                        soldToAddrlist.push(value);
                        isUpdate = true;
                    }                     
            }

            //console.log('new Billto List ::::', newBillToAddrList);
            //console.log('new shipto List ::::', newShipToAddrList);
            //console.log('old Billto List ::::', billToAddrList);
            //console.log('old shipto List ::::', shipToAddrList);
            //console.log('old slodto List ::::', soldToAddrlist); 

        /* if (paymentFieldsValid && addressFieldsValid && !hasFormatIssues && !hasPaymentErr) {
            
        } */
        
        let hasnonSapIdMapError = false;
        let hasExistingDataValid = false;
        let hasExistingPaymentDataValid = false;
        //console.log('nonSApIdValidaddFieldsMap::::', nonSApIdValidaddFieldsMap); 

        //for(let errorVal of nonSApIdValidaddFieldsMap){
         //   //console.log('errorVal::::', errorVal); 
            if(nonSApIdValidaddFieldsMap.has('New')){
                hasnonSapIdMapError = true;
            }
       // }
        //for(let errorVal of nonSApIdValidPaymentFieldsMap){
        //    //console.log('errorVal22::::', errorVal); 
            if(nonSApIdValidPaymentFieldsMap.has('NewPayment')){
                hasExistingPaymentDataValid = true;
            }
      //      
       // }
        
        if(this.errorSAPIdSet){		 
            for (let errorSAP of this.errorSAPIdSet){	
                //console.log('errorSAP::::',errorSAP);	
                 //console.log('isObjRecordChange::::',isObjRecordChange);			
                if(isObjRecordChange.has(errorSAP)&& isObjRecordChange.get(errorSAP)){			
                    hasExistingDataValid = true;
                    const toastModel1 = this.template.querySelectorAll(`[data-id="${errorSAP}"]`).forEach(element => {
                        //console.log('element.className1>>>',element.className)
                        element.className = 'slds-show';
                    });
                    const toastModel2 = this.template.querySelectorAll(`[data-value="${errorSAP}"]`).forEach(element => {
                    //console.log('element.className2>>>',element.className)
                        element.className = 'slds-hide';
                    }); 
            }
            }
            this.errorSAPIdSet.clear();
        }
        //console.log('hasnonSapIdMapError>>>>>',hasnonSapIdMapError);
        //console.log('hasExistingPaymentDataValid>>>>>',hasExistingPaymentDataValid);
        if(hasnonSapIdMapError || hasExistingDataValid || hasExistingPaymentDataValid){
            this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
            this.hidemaindiv = false;
            this.showLoader = false; 
        }
        else if(isUpdate){            
            if(newBillToAddrList && (this.country === 'IT' || this.country == 'ES')){                
                for(let billtoRecd of newBillToAddrList){
                    let TAXValue = billtoRecd.Tax_Number_AGN__c;
                    let VATValue = billtoRecd.VAT_Number_AGN__c;
                    //console.log('New TAXValue::::',TAXValue, '::VATValue:::',VATValue);
                    if(!TAXValue && !VATValue){
                        hasTaxVatRequired = true;
                    } 
                    //console.log('hasTaxVatRequired:: ',hasTaxVatRequired);
                } 
                if(hasTaxVatRequired ){
                    this.showLoader = false;
                    this.hidemaindiv = false; 
                    //console.log('labelNameVAT::', labelNameVAT, '::: ',labelNameTAX);
                    VATORTAXRequired = (labelNameVAT && labelNameTAX) ? labelNameVAT+' / '+labelNameTAX: (labelNameVAT)? labelNameVAT : (labelNameTAX)?labelNameTAX:'';
                                            
                    let errorMessage = AGN_OAM_Required_Fields_Missing_Error +' '+ VATORTAXRequired;
                    this.showToast('error' , errorMessage , 'error');
                    return;
                }                
                
            }

            this.handleSavecustomerDetails(this.newRegistration, this.primaryContact, newBillToAddrList, newShipToAddrList, billToAddrList, shipToAddrList, soldToAddrlist, this.source); 
        }    
        else if(!paymentChanged){
                if(this.source == 'oam'){
                    this.showToast('warning', AGN_OAM_Warning_NoChanges, 'warning');
                    this.hidemaindiv = false;
                    this.showLoader = false;
                }
                        
        }  
      }
    }
          
         // this.hidemaindiv = false;
         // this.showLoader = false;

    /*  } else { */
         
      /*    this.hidemaindiv = false;
          this.showLoader = false;
      } */



  handleSavecustomerDetails(newRegistration, primarycontact, newBillToAddrList, newShipToAddrList, billToAddrList, shipToAddrList, soldToAddrlist, source) {
      //console.log('primarycontact:::::::', primarycontact);
    saveCustomerUpdate({
              customerReg: newRegistration,
              newShippingAddress: newShipToAddrList,
              newBillingAddress: newBillToAddrList,
              oldShippingAddress: shipToAddrList,
              oldBillingAddress: billToAddrList,
              oldSoldAddress: soldToAddrlist,
              primaryContact: primarycontact,
              source: source,
              soldToSAPId: this.soldToSAPId
          })
          .then(result => {
              //console.log('result:::::: ', result);              
              this.showLoader = false;
              if(this.source==='cs'){
                const saveEvent = new CustomEvent('saveclicked', { 
                            detail: {
                               existingSoldTo: this.existingSoldTo,
                               existingShipTo: this.existingShipTo,
                               existingBillTo: this.existingBillTo,
                               IsUpdate : true,
                               caseId : result.Id,
                               soldToSAPId : this.soldToSAPId
                            }
                        });

                        // Dispatches the event.
                this.dispatchEvent(saveEvent);
                this.caseNumber = result.CaseNumber;
                this.isUpdateSuccess = false;
                this.hidemaindiv = false;
                this.showLoader = false;
              }
              else if(this.country =='CA' && this.source == 'oam'){
                this.caseNumber = result.CaseNumber; 
                getCustomerRegDetailsCS({
                    caseRecId : result.Id
                  })
                  .then(result =>{
                    //console.log('registration:::: ', result);
                    this.isUpdateSuccess = true;
                    this.registrationId = result.Id;
                    this.isShowCanadaShiptoLicenseDocuments = true;
                    this.updateSuccessMsg = "";
                    this.hidemaindiv = true;
                    this.showLoader = false;
                  })
                  .catch(error =>{
                    console.log('error>>>>> ', error);
                  });                  
                  // this.showToast{""}
              }else{
                  this.isUpdateSuccess = true;
                  this.isShowCanadaShiptoLicenseDocuments = false;
                  this.caseNumber = result.CaseNumber;
                  this.updateSuccessMsg = "";
                  this.hidemaindiv = true;
                  this.showLoader = false;
              }
              
          })
          .catch(error => {
              console.log('error == ', error);
              this.hidemaindiv = false;
              this.showLoader = false;
          });
       
  }

  showToast(title , message , variant) {
    if(this.source==='cs')
    {   this.error = message;
        this.variant = variant;
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

handleControllingFieldEvent(event) {

    this.showLoader = true;
    this.hidemaindiv = true;
    //console.log('this.showLoader>>>>'+this.showLoader);   
    const eventParemeters = event.detail;
     const controllingFieldSobjectName = eventParemeters.controllingFieldSobjectName;
     //console.log("controllingFieldSobjectName -> " + controllingFieldSobjectName);
     const controllingFieldName = eventParemeters.controllingFieldName;
     //console.log("controllingFieldName -> " + controllingFieldName);
     const controllingFieldSelectedValue = eventParemeters.controllingFieldSelectedValue;
     //console.log("controllingFieldSelectedValue -> " + controllingFieldSelectedValue);
    //console.log("index -> " + eventParemeters.index);
    //console.log("sapid -> " + eventParemeters.sapid);
    const templateIndex = eventParemeters.index;
    const sapidVal = eventParemeters.sapid;
    const templateobjecttype = eventParemeters.objecttype;
    //console.log("templateobjecttype -> " + eventParemeters.objecttype);

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
                let hasIndex = false;
                 //console.log('element.sapid:::'+element.sapid);
                  //console.log( 'SAP:: ', element.sapid, ':: ', sapidVal);
                 if(element.sapid){
                    hasIndex =  ((sapidVal)&&(element.sapid == sapidVal)) ? true : false;                   
                 }else{
                    hasIndex =   (element.index == templateIndex) ? true : false;
                 }
                 if (element.fieldname === field.Field_Name_AGN__c &&
                    element.sobjectname === field.SObject_Name_AGN__c && hasIndex && element.objecttype == templateobjecttype ) {
                     //console.log('Checking the dependent List>>');
                     element.removeInputValue();
                     if (field.Dependent_Field_Show_Criteria_AGN__c && field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
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
   this.hidemaindiv = false;
   this.showLoader = false;
    //console.log('this.showLoader>>>>'+this.showLoader);  
 }

  // Brazil Zip code validation code goes here
  handleZipCodeValueChange(event){
     
        //this.hidemaindiv = true;
        const eventParemeters = event.detail;        
        const sobjectName = eventParemeters.sobjectName;
        const fieldName = eventParemeters.fieldName;
        const zipValue = eventParemeters.value;
        const instancetype = eventParemeters.instancetype;
        const objecttype = eventParemeters.objecttype;
        const index = eventParemeters.index;
        const sapid = eventParemeters.sapid;
        const isFormatvalid = eventParemeters.isFormatvalid;
        //console.log('eventParemeters::::: ',eventParemeters);
        let hasIndex = false;
        //console.log( 'ElementSAP:: ', element.sapid);
        //console.log( 'SAP:: ', sapid);        
        if(zipValue && isFormatvalid){   
             this.showLoader = true;         
             getAddressInformation({
                    cepCode: zipValue
                })
                .then(result => {                  
                    //console.log('Result Zipcode Related Address>>>>>>>>>>>>>>>>>>',result); 
                    let addressInfo = result;
            
                        //customerAddress.State_AGN__c = customer.SAP_Country_Code_AGN__c+'-'+cepDetail.state;
                        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                            if(element.sapid){
                                hasIndex =  ((sapid)&&(element.sapid == sapid)) ? true : false;                   
                            }else{
                                hasIndex =   (element.index == index) ? true : false;
                            }    
                            if (element.sobjectname === sobjectName && hasIndex  && element.objecttype == objecttype) {
                                
                                        if(element.fieldname === 'Street_Name_AGN__c' && element.fieldValue != addressInfo.street){
											element.isChanged = true;
                                            element.fieldValue = addressInfo.street;
                                        }
                                        if(element.fieldname === 'Address_Line_3_AGN__c' && element.fieldValue != addressInfo.bairro){
											element.isChanged = true;
                                            element.fieldValue = addressInfo.bairro;
                                        }
                                        if(element.fieldname === 'City_AGN__c'&& element.fieldValue != addressInfo.city){
											element.isChanged = true;
                                            element.fieldValue = addressInfo.city;
                                        }
                                        if(element.fieldname === 'State_AGN__c'&& element.fieldValue != this.country+'-'+addressInfo.state){
											element.isChanged = true;
                                            element.fieldValue = this.country+'-'+addressInfo.state;
                                        }                                       
                                    
                                }
                                
                                
                            });
                   
                    
                    this.hidemaindiv = false;
                    this.showLoader = false;                  
                  
                })
                .catch(error => {
                    console.log('error Zipcode Related Address>>>>>>>>>>>>>>>>>>>', error);
                    this.error = error;
                    this.hidemaindiv = false;
                    this.showLoader = false; 
                });
        }else{
            this.hidemaindiv = false;
            this.showLoader = false; 
        }
        
    }

    handleSubmitCanada(event){
        let allDocsValid = true;
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
            }else{
                this.isUpdateSuccess = true;
                this.isShowCanadaShiptoLicenseDocuments = false;
            }
       
    }

    showDependentField(layoutMetadataMaster, controlingfieldData) {
       // const eventParemeters = controlingfieldData;
        //console.log('controlingfieldDataonload:::::::::', controlingfieldData);
        const controllingFieldSobjectName = controlingfieldData.controllingFieldSobjectName;
        const controllingFieldName = controlingfieldData.controllingFieldName;
        const controllingFieldSelectedValue = controlingfieldData.controllingFieldSelectedValue;
        const templateIndex = controlingfieldData.index;
        const sapidVal = controlingfieldData.sapid;
        const templateobjecttype = controlingfieldData.objecttype;
        let dependentFieldList = [];
        var itr = 1;
        Object.keys(layoutMetadataMaster).forEach(key => {
            let dependentField = this.layoutMetadataMaster[key].find(layout => {
                if (layout.Controlling_Field_AGN__c == controllingFieldName && layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName ) {
					//&& typeof controllingFieldSelectedValue != "undefined" && typeof controllingFieldSelectedValue != null && typeof controllingFieldSelectedValue != ''
                    itr++;
                    dependentFieldList.push(layout);
                    //return layout;

                }
            });
        });
        //console.log('dependentFieldListonload:::::::::', dependentFieldList);
        if (dependentFieldList.length > 0) {
            dependentFieldList.forEach(field => {
                this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                    let hasIndex = false;
                    //console.log('element.sapid:::'+element.sapid);
                    //console.log( 'SAP:: ', element.sapid, ':: ', sapidVal);
                    if(element.sapid){
                        hasIndex =  ((sapidVal)&&(element.sapid == sapidVal)) ? true : false;                   
                    }else{
                        hasIndex =   (element.index == templateIndex) ? true : false;
                    }
                    if (element.fieldname === field.Field_Name_AGN__c && element.sobjectname === field.SObject_Name_AGN__c
                        && hasIndex  && element.objecttype == templateobjecttype) {
                       
                         if (field.Dependent_Field_Show_Criteria_AGN__c && (field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue) 
                           || (field.Dependent_Field_Show_Criteria_AGN__c.includes('false') && (controllingFieldSelectedValue == 'undefined' || typeof controllingFieldSelectedValue == 'undefined')))) {
                            element.showCmp();
                            element.setControllingValue(controllingFieldSelectedValue);
                            //console.log('met conditions>>');
                            this.showtest = true;
                            return;
                        } else {
                            element.removeInputValue();
                            element.hideCmp();
                            this.showtest = false;
                            return;
                        }
                    }
                });
            });
        }
    }
  
}