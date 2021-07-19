/**
 * @description       : Gcsp Customer Registration step4
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-21-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement , track, api} from 'lwc';
import LANG from '@salesforce/i18n/lang';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import AGN_Static_PDF from '@salesforce/resourceUrl/AGN_Static_PDF';
import getCustomerRegDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetails';
import getCustomerRegDetailsCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS';
import getCustomerAddressDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails';
import fetchCountryList from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.fetchCountryList';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getLayout';
import deleteAddress from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.deleteAddress';
import upsertAllAddressDetailsNew from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.upsertAllAddressDetails';
import getPaymentMethods from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getPaymentMethods';
import getPaymentTerms from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getPaymentTerms';
import getGCSPSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings';
import getAddressInformation from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getAddressInformation';	

import AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions from '@salesforce/label/c.AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions';
import AGN_OAM_Body_Declaration from '@salesforce/label/c.AGN_OAM_Body_Declaration';
import AGN_OAM_Confirm_Bank_details from '@salesforce/label/c.AGN_OAM_Confirm_Bank_details';
import AGN_OAM_Body_Confirm_Youhave from '@salesforce/label/c.AGN_OAM_Body_Confirm_Youhave';
import AGN_OAM_Body_Confirm_SuccessfullyCompleted from '@salesforce/label/c.AGN_OAM_Body_Confirm_SuccessfullyCompleted';
import AGN_OAM_Body_Confirm_CheckInbox from '@salesforce/label/c.AGN_OAM_Body_Confirm_CheckInbox';
import AGN_OAM_Body_Finish from '@salesforce/label/c.AGN_OAM_Body_Finish';
import AGN_OAM_Previous from '@salesforce/label/c.AGN_OAM_Previous';
import AGN_OAM_Body_Agree from '@salesforce/label/c.AGN_OAM_Body_Agree';	
import AGN_OAM_Body_TermsConditions2 from '@salesforce/label/c.AGN_OAM_Body_TermsConditions2';	
import AGN_OAM_Body_Ok from '@salesforce/label/c.AGN_OAM_Body_Ok';	
import AGN_OAM_Body_Cancel from '@salesforce/label/c.AGN_OAM_Body_Cancel';	
import AGN_OAM_Body_ClickOkToAgree from '@salesforce/label/c.AGN_OAM_Body_ClickOkToAgree';

import AGN_OAM_Fields_Mandatory from '@salesforce/label/c.AGN_OAM_Fields_Mandatory';
import AGN_OAM_Body_RegisteredAddress from '@salesforce/label/c.AGN_OAM_Body_RegisteredAddress';
import AGN_OAM_Shipping_Address from '@salesforce/label/c.AGN_OAM_Shipping_Address';
import AGN_OAM_Biling_Address from '@salesforce/label/c.AGN_OAM_Biling_Address';
import AGN_OAM_Same_Name_Address from '@salesforce/label/c.AGN_OAM_Same_Name_Address';
import AGN_OAM_New_Biling_Address from '@salesforce/label/c.AGN_OAM_New_Biling_Address';
import AGN_OAM_NumberOfBillTo_LimitExceed from '@salesforce/label/c.AGN_OAM_NumberOfBillTo_LimitExceed';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';
import AGN_OAM_BillTo_Mandatory from '@salesforce/label/c.AGN_OAM_BillTo_Mandatory';
import AGN_OAM_Bank_Declaration from '@salesforce/label/c.AGN_OAM_Bank_Declaration';
import AGN_OAM_BiillTo_Same_Name_Add from '@salesforce/label/c.AGN_OAM_BiillTo_Same_Name_Add';

import AGN_OAM_Basic_Information_Heading from '@salesforce/label/c.AGN_OAM_Basic_Information_Heading';
import AGN_OAM_Address_Details_Heading from '@salesforce/label/c.AGN_OAM_Address_Details_Heading';
import AGN_OAM_Document_Upload_Heading from '@salesforce/label/c.AGN_OAM_Document_Upload_Heading';
import AGN_OAM_Confirmation_Heading from '@salesforce/label/c.AGN_OAM_Confirmation_Heading';
import AGN_OAM_Payment_Term from '@salesforce/label/c.AGN_OAM_Payment_Term';
import AGN_OAM_Body_PaymentMethod from '@salesforce/label/c.AGN_OAM_Body_PaymentMethod';
import AGN_OAM_AdditionalBillingHelpTxt from '@salesforce/label/c.AGN_OAM_AdditionalBillingHelpTxt';
import AGN_OAM_Successfully_Updated from '@salesforce/label/c.AGN_OAM_Successfully_Updated';
import AGN_OAM_Save from '@salesforce/label/c.AGN_OAM_Save';
import AGN_OAM_Next from '@salesforce/label/c.AGN_OAM_Next';
import AGN_OAM_Body_step4a  from '@salesforce/label/c.AGN_OAM_Body_step4a';	
import AGN_OAM_Body_step4b  from '@salesforce/label/c.AGN_OAM_Body_step4b';
import AGN_OAM_Body_step4d from '@salesforce/label/c.AGN_OAM_Body_step4d';		
import AGN_OAM_Body_step4c from '@salesforce/label/c.AGN_OAM_Body_step4c';
import AGN_OAM_Confirmation_finalstep_BR from '@salesforce/label/c.AGN_OAM_Confirmation_finalstep_BR';

import AGN_GCSP_STEP1 from '@salesforce/label/c.AGN_GCSP_STEP1';
import AGN_GCSP_STEP2 from '@salesforce/label/c.AGN_GCSP_STEP2';
import AGN_GCSP_STEP3  from '@salesforce/label/c.AGN_GCSP_STEP3';
import AGN_GCSP_STEP4 from '@salesforce/label/c.AGN_GCSP_STEP4';
import AGN_GCSP_STEP5  from '@salesforce/label/c.AGN_GCSP_STEP5';
import AGN_OAM_Contact_Affiliation  from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_Header_CustomerRegistration  from '@salesforce/label/c.AGN_OAM_Header_CustomerRegistration';
import AGN_OAM_BillingDetails_Confirmation  from '@salesforce/label/c.AGN_OAM_BillingDetails_Confirmation';
import AGN_GCSP_Declaration_header  from '@salesforce/label/c.AGN_GCSP_Declaration_header';
import AGN_OAM_Accept  from '@salesforce/label/c.AGN_OAM_Accept';
import AGN_OAM_New_BillTO  from '@salesforce/label/c.AGN_OAM_New_BillTO';
import AGN_OAM_Declaration  from '@salesforce/label/c.AGN_OAM_Declaration';
import AGN_OAM_Existing_Address  from '@salesforce/label/c.AGN_OAM_Existing_Address';
import AGN_OAM_Body_PleaseCheckFormatFor  from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Loading  from '@salesforce/label/c.AGN_OAM_Loading';
import AGN_OAM_Declaration2_ANZ  from '@salesforce/label/c.AGN_OAM_Declaration2_ANZ';
import AGN_OAM_Declaration_ANZ  from '@salesforce/label/c.AGN_OAM_Declaration_ANZ';
import AGN_OAM_Accept_TnC  from '@salesforce/label/c.AGN_OAM_Accept_TnC';
import AGN_OAM_Required_Fields_Missing_Error  from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';
import AGN_OAM_Mandatory_Declaration  from '@salesforce/label/c.AGN_OAM_Mandatory_Declaration';
import AGN_OAM_Accept_Declaration  from '@salesforce/label/c.AGN_OAM_Accept_Declaration';
import AGN_OAM_Declaration_Canada from '@salesforce/label/c.AGN_OAM_Declaration_Canada';
import AGN_OAM_Declaration2_Canada from '@salesforce/label/c.AGN_OAM_Declaration2_Canada';

import {
    loadStyle
} from 'lightning/platformResourceLoader';
import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

export default class AGN_GCSP_CustomerRegistrationStep4 extends NavigationMixin(LightningElement) {
	 @track LGPDpdfLink = AGN_Static_PDF;
     @track countryCode;
     @track country;
     @track language;
     @track registration;
     @track picklistCountryOptions;
     @track customerTypeConfig;
     @track hidemaindiv = false;
     @track showLoader = false;
     @track paymentSectionFields;
     @track record;
     @track soldToAddr;
     @track billToAddr = [];
     @track shipToAddr = [];
     @track soldToAddressFields = [];
     @track billToAddressFields = [];
     @track shipToAddressFields = [];
     @track billingMap = [];
     @track billingMapCounter = 0;
     @track showNewBillto = false;
     @track PaymentMethod = [];
     @track sectionPaymentMap = [];
     @track selectedPaymentMethod;
     @track selectedPaymentTerm;
     @track paymentTermMap = [];
     @track showPaymentSection = true;//false;
     @track billToSameAsSoldTo = false;
     @track disableFinishBtn = true;
     @track showBankDeclaration = false;
     @track showBankDeclarationMap = new Map();
     @track isBankDeclarationChecked = false;
     @track isTermsChecked = false;
     @track billtoLimit;
     @track disableSoldToFields = true;
     @track isRegistrationCompleted = false;
     @track successMsg;
     @api caseId;
     @api source;
     @api sourceCS;
     @api sourceOAM;
     @track isCS = false;
     @track isFinish = false;
     @track variant = 'error'
	 error;
     @track billtoExists = false;
	 @track ShowTermsAndConditions;		
     @track isTNCAccepted =false;
     
     @api RegistrationStepNo;
     @api isOnlineRegistration;

     @track layoutMetadataMaster;
     isPaymentInfo;
     @track showExistingBillTo = false;
     displayNLdeclaration = false;
     isANZ =false;
	 showBrazilDeclaration = false;		
     showBillToSection = false;
     showCanadaDeclaration;
     isBRoam = false;
     @track hasRendered=false;

     label = {
         AGN_OAM_Declaration_Canada,
         AGN_OAM_Declaration2_Canada,
         AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions,
         AGN_OAM_Declaration2_ANZ,
         AGN_OAM_Declaration_ANZ,
         AGN_OAM_Body_Declaration,
         AGN_OAM_Confirm_Bank_details,
         AGN_OAM_Body_Confirm_Youhave,
         AGN_OAM_Body_Confirm_SuccessfullyCompleted,
         AGN_OAM_Body_Confirm_CheckInbox,
         AGN_OAM_Previous, 
         AGN_OAM_Body_Finish,
         AGN_OAM_Fields_Mandatory,
         AGN_OAM_Body_RegisteredAddress,
         AGN_OAM_Shipping_Address,
         AGN_OAM_Biling_Address,
         AGN_OAM_Same_Name_Address,
         AGN_OAM_New_Biling_Address,
         AGN_OAM_NumberOfBillTo_LimitExceed,
         AGN_OAM_Invalid_Input,
         AGN_OAM_BillTo_Mandatory,
         AGN_OAM_Bank_Declaration,
         AGN_OAM_BiillTo_Same_Name_Add,
         AGN_OAM_Basic_Information_Heading,
         AGN_OAM_Address_Details_Heading,
         AGN_OAM_Document_Upload_Heading,
         AGN_OAM_Confirmation_Heading,
         AGN_OAM_Payment_Term,
         AGN_OAM_AdditionalBillingHelpTxt,
         AGN_OAM_Successfully_Updated,
         AGN_OAM_Save,
         AGN_GCSP_STEP1,
         AGN_GCSP_STEP2,
         AGN_GCSP_STEP3,
         AGN_GCSP_STEP4,
         AGN_GCSP_STEP5,
         AGN_OAM_Next,
         AGN_OAM_Contact_Affiliation,
         AGN_OAM_Header_CustomerRegistration,
         AGN_OAM_BillingDetails_Confirmation,
         AGN_GCSP_Declaration_header,
         AGN_OAM_Accept,
         AGN_OAM_New_BillTO,
         AGN_OAM_Declaration,
         AGN_OAM_Existing_Address,
         AGN_OAM_Loading,
         AGN_OAM_Accept_Declaration,
         AGN_OAM_Mandatory_Declaration,
		 AGN_OAM_Existing_Address,		
         AGN_OAM_Loading,		
         AGN_OAM_Body_step4b,		
         AGN_OAM_Body_step4c,		
         AGN_OAM_Body_step4a,	
         AGN_OAM_Body_step4d,	
         AGN_OAM_Confirmation_finalstep_BR,
         AGN_OAM_Body_Agree,	
         AGN_OAM_Body_TermsConditions2,	
         AGN_OAM_Body_Ok,	
         AGN_OAM_Body_Cancel,	
         AGN_OAM_Body_ClickOkToAgree
     };

     renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');  
        //console.log('this.hasRendered::::', this.hasRendered);   
        if(!this.hasRendered) {this.renderDependentField(); }
          
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

     //connectedCallback

     connectedCallback() {
         this.hidemaindiv = true;
         this.showLoader = true;
         this.source = (this.sourceOAM) ? this.sourceOAM : (this.sourceCS) ? this.sourceCS : '';
		 this.isOnlineRegistration = (this.sourceOAM) ? true : false;
		 
        //console.log('Customer Reg Calling>>>1');
         if (this.source == 'cs') {
             this.getCustomerRegistrationDetailsCS();
             this.disableFinishBtn = false;
             this.isCS = true;             
         } else {
             //console.log('Customer Reg Calling>>>2');
             this.getCustomerRegistrationDetails();
         }

         this.language = LANG;
     }

     getCustomerRegistrationDetails() {
         //console.log('Customer Reg Calling>>>3');
         getCustomerRegDetails()
             .then(result => {
                 //console.log('registration>>>>>>>>>>>>>>>>>>>', result.Id);
                 if (result) {
                     this.showupload = true;
                     this.registration = result;
                     var countryCode = result.SAP_Country_Code_AGN__c;
                     if (!countryCode) {
                         countryCode = result.Country_Code_AGN__c;
                     }
                     this.country = countryCode;
                     if(this.country === "AU" || this.country === "AN" || this.country === "NZ"){    // Declaration for NL OAM
                        this.isANZ = true;
                    }
                    if(this.country === "NL"){    // Declaration for NL OAM
                        this.displayNLdeclaration = true;
                    }
					if(this.country === 'BR' && this.source === 'oam')		
                    {		
                        this.showBrazilDeclaration = true;
                        this.isBRoam = true;		
                    }else if(this.country === 'CA' && this.source === 'oam'){
                         this.showCanadaDeclaration = true;
                    }
                     this.customerType = result.Customer_Category_AGN__c;
                     this.customerSubType = result.Customer_Sub_Category_AGN__c;
                     //console.log('Step No>>>>>>>>>>>>', result.Online_Registration_Step_AGN__c);
                     let stepNo = parseInt(result.Online_Registration_Step_AGN__c);

                     if (stepNo > 4) {
                         this.hidemaindiv = false;
                         this.showLoader = false;
                         this.isRegistrationCompleted = true;

                     } else {
                         this.stepNo = 4;
                     }
                     this.getPaymentOptions(result, countryCode);
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

     getCustomerRegistrationDetailsCS() {
         getCustomerRegDetailsCS({
                 caseRecId: this.caseId
             })
             .then(result => {
                 //console.log('registration>>>>>>>>>>>>>>>>>>>', result.Id);
                 if (result) {
                     this.showupload = true;
                     this.registration = result;
                     var countryCode = result.SAP_Country_Code_AGN__c;
                     if (!countryCode) {
                         countryCode = result.Country_Code_AGN__c;
                     }
                     this.country = countryCode;
                     this.customerType = result.Customer_Category_AGN__c;
                     this.customerSubType = result.Customer_Sub_Category_AGN__c;
                     //console.log('Step No>>>>>>>>>>>>', result.Online_Registration_Step_AGN__c);
                     let stepNo = parseInt(result.Online_Registration_Step_AGN__c);

                     if (stepNo > 4) {
                         this.hidemaindiv = false;
                         this.showLoader = false;
                         this.isRegistrationCompleted = true;

                     } else {
                         this.stepNo = 4;
                     }
                     this.getPaymentOptions(result, countryCode);
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

     getPaymentOptions(registration, countryCode) {
        // //console.log('countryCode>>>>>>>>>>>>>>>', countryCode);
         getPaymentMethods({
                 country: countryCode,
                 source: this.source
             })
             .then(result => {
               //  //console.log('Form of Payment>>>>>>>>>>>>>>>>>>>', result);
                 if (result) {
                     this.PaymentMethod = result;
                     this.getAddressDetails(registration, countryCode);
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

     getAddressDetails(registration, countryCode) {

         getCustomerAddressDetails({
                 custRegId: registration.Id
             })
             .then(data => {
                 if (data) {
                     //console.log("Address Data*******", data);
                     var soldToAddr;
                     var billToAddr = [];
                     var shipToAddr = [];
                     var addressList = data;
                     for (var i in addressList) {
                         if (addressList[i].Sold_To_AGN__c) {
                             //only 1 SoldTo Address will be present
                             soldToAddr = addressList[i];
                             this.shipToSameAsSoldTo = addressList[i].Ship_To_AGN__c; //will set true/false
                             this.billToSameAsSoldTo = addressList[i].Bill_To_AGN__c; //will set true/false
                         }
                         if (addressList[i].Ship_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                             //Multiple ShipTo Address will be present
                             shipToAddr.push(addressList[i]);
                         }
                         if (addressList[i].Bill_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                             //Multiple BillTo Address will be present
                             billToAddr.push(addressList[i]);
                         }
                     }
                    /* //console.log('soldToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', soldToAddr);
                     //console.log('billToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', billToAddr);
                     //console.log('shipToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', shipToAddr);*/
                     let paymentMethodSet = new Set()
                     if (soldToAddr.Form_Of_Payment_AGN__c) {
                         paymentMethodSet.add(soldToAddr.Form_Of_Payment_AGN__c);
                     }
                     billToAddr.forEach(function (bill) {
                         if (bill.Form_Of_Payment_AGN__c) {
                             paymentMethodSet.add(bill.Form_Of_Payment_AGN__c);
                         }
                     });
                     //console.log('paymentMethodSet>>>>>>>>>>>>>>>>>', paymentMethodSet);
                     this.soldToAddr = soldToAddr;
                     this.billToAddr = billToAddr;
                     //console.log('this.billToAddr size>>>>>>>>>>>>>>>>>', this.billToAddr.length);
                     this.billtoExists = true;
                        //this.showExistingBillTo = true;
                    
                     this.shipToAddr = shipToAddr;
                     if (paymentMethodSet) {
                         if(this.source === 'oam' && this.country === 'BR')		
                            {		
                                this.isPaymentInfo = false;		
                            }		
                            else		
                            {		
                                this.getPaymentTerms(paymentMethodSet);		
                            }
                     } else {
                         this.getConfigurations(registration, countryCode);
                         if(this.source === 'oam' && this.country === 'BR')		
                         {		
                             this.isPaymentInfo = false;		
                         }		
                         else		
                         {		
                             this.isPaymentInfo = true;		
                         }
                     }                     
                     this.getGCSPCustomSettings(registration, countryCode);
                 } else {
                     this.hidemaindiv = false;
                     this.showLoader = false;
                 }
             })
             .catch(error => {
                 console.log('error on address fetching>>>>>>>>>>>>>>>>>>>', error);
                 this.hidemaindiv = false;
                 this.showLoader = false;
             });
     }


     getPaymentTerms(paymentMethodSet) {
         let paymethods = [];
         paymentMethodSet.forEach(function (pay) {
             paymethods.push(pay);
         });
         getPaymentTerms({
                 paymentMethodSet: paymethods,
                 source: this.source
             })
             .then(result => {
                 if (result) {
                     //console.log('********Payment Term List*************', result);
                     this.paymentTermMap = result;
                     this.isPaymentInfo = true;                     
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

     getGCSPCustomSettings(registration, countryCode) {
         getGCSPSettings({
                 country: countryCode
             })
             .then(result => {
                 if (result) {
                     //console.log('Custom Settings Data*******', result);
                     
                     this.billtoLimit = (this.source === 'oam') ? parseInt(result.Number_Of_BillTo_Allowed_AGN__c) :  parseInt(result.Number_Of_BillTo_Allowed_CS_AGN__c);
                     //console.log('this.billToAddr length>>>>'+this.billToAddr.length);
                     //console.log(' this.billtoLimit>>>>'+ this.billtoLimit);
                     if(this.billtoLimit && this.billtoLimit > 0){
						this.showBillToSection = true;		
                     }		
                     if(this.billtoLimit>this.billToAddr.length){
                        this.showNewBillto = true;		
                     }
                     this.getConfigurations(registration, countryCode);
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

     getConfigurations(registration, countryCode) {
         fetchCountryList({
                 countryCode: countryCode
             })
             .then(result => {
                 if (result) {
                    //console.log('step4 Configuration Data*******', result);
                     this.picklistCountryOptions = result[0];
                     this.customerTypeConfig = result[1];
                     this.invokeGetLayout(registration, countryCode, result[1], 2);
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



     invokeGetLayout(registration, countryCode, customerTypeConfig, stepNo) {
         //console.log('invokeGetLayout>>>>>>>>>>>>>>>', countryCode, registration, customerTypeConfig, stepNo);
         if (countryCode === 'ITTT') {
             getLayout({
                     country: countryCode,
                     stepNo: stepNo,
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
         } else {
             getLayout({
                     country: countryCode, 
                     stepNo: stepNo,
                     customerType: registration.Customer_Category_AGN__c,
                     customerSubType: registration.Customer_Sub_Category_AGN__c,
                     custTypeConfig: customerTypeConfig,
                     source: this.source
                 })
                 .then(result => {
                     //console.log('result>>>>>>>>>>>>>>>>>>>', result);
                     this.hidemaindiv = false;
                     this.showLoader = false;
                     
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

     setPaymentLayoutFields(data) {
         var settingsMap = data;
         //var paymentSectionFields = [];
        
         var settings = [];
         for (var key in settingsMap) {
             //paymentSectionFields = settingsMap[key];
             settings.push({
                 value: settingsMap[key],
                 key: key
             });
         }
        
         this.sectionPaymentMap = settings;
         this.showPaymentSection = true;
         //console.log('settingsMap>>>>>>>>>>>>>>>>>>', settings);
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
         //console.log('soldToAddressFields>>>>>>>>>>>>>>>>>>', soldToAddressFields);
           /*  //console.log('shipToAddressFields>>>>>>>>>>>>>>>>>>', shipToAddressFields);
         //console.log('billToAddressFields>>>>>>>>>>>>>>>>>>', billToAddressFields);*/
     }

     addNewBillTo() {
         //console.log('inside addNewBillTo>>>>>>>>>>>');
         var mapKey = 'Shipping Address' + this.billingMapCounter;
         let billtoLimit = 0;
         if (this.billtoLimit) {
             billtoLimit = this.billtoLimit;
         }
         if (billtoLimit > 0) {
             let billtolen = 0;
             if (this.billToSameAsSoldTo) {
                 billtolen++;
             }
             if (this.billToAddr.length > 0) {
                 billtolen += this.billToAddr.length;
             }
             if (this.billingMap.length > 0) {
                 billtolen += this.billingMap.length;
             }

             if (billtolen < billtoLimit) {
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
             } else {
                 this.showToast('error', AGN_OAM_NumberOfBillTo_LimitExceed, 'error');
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
         var keyVal = '';
         //console.log('inside delete event handler>>>>>>>>>>>>>>>',indx);
         //console.log('::keyVal:::',this.showBankDeclarationMap);
         if (instancetype === 'new') {
             keyVal = indx;
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
             keyVal = recordId;
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
	 
	 openModal() {    		
       		
        this.ShowTermsAndConditions = true;		
	 }		
     acceptTNC(event) { 		
        let cmp = this.template.querySelector('.tncchkbox');		
        cmp.checked = true;       		
        this.ShowTermsAndConditions = false;		
     }		
     closeAccModal() {    		
        let cmp = this.template.querySelector('.tncchkbox');		
        cmp.checked = false;		
        this.ShowTermsAndConditions = false;	
     }

     navigateToLink(pagename) {
         // Navigate to a URL
         this[NavigationMixin.Navigate]({
                 type: 'comm__namedPage',
                 attributes: {
                     pageName: pagename
                 }
             },
             false //Replaces the current page in your browser history with the URL
         );
     }

     nextOrPreviousActionEvent(caseId, stepNo) {
        const selectEvent = new CustomEvent('stepinfoevent',  { detail : {
            caseId: caseId,
            stepNo: stepNo
           }
        });
        this.dispatchEvent(selectEvent);
    }
     handlePrevious() {
        if (this.source == 'cs') {
            this.nextOrPreviousActionEvent(this.caseId, '3');
        }
        if(this.source=='oam'){
            this.navigateToLink('customer-registration-step3');
        }
     }

    handleSave(){
		//Brazil Policy Link Checkbox
		if(this.country === 'BR' && this.source=='oam'){
			let cmp = this.template.querySelector('.tncchkbox');		
			if(cmp.checked!==true)	
				this.showToast('error',AGN_OAM_Accept_TnC,'error');	
			else{	
				this.isFinish = false;	
				this.handleClick('save');	
			}
		}else if(this.country === 'NL' && this.source=='oam'){
            const nlDecBox = this.template.querySelector(".nlChkBox");
            if(nlDecBox.checked !== true){
                this.showToast('error',AGN_OAM_Accept_Declaration,'error');
            } else{
                this.isFinish = false;
                this.handleClick('save');
            }
        }
		else{
            this.isFinish = false;
            this.handleClick('save');
        }
    }
    handleFinish(){
		//Brazil Policy Link Checkbox
		if(this.country === 'BR' && this.source=='oam'){
			let cmp = this.template.querySelector('.tncchkbox');		
			if(cmp.checked!==true)	
				this.showToast('error',AGN_OAM_Accept_TnC,'error');	
			else{	
				this.isFinish = true;	
				this.handleClick('finish');	
			}
		}else if(this.country === 'NL' && this.source=='oam'){
            const nlDecBox = this.template.querySelector(".nlChkBox");
            if(nlDecBox.checked !== true){
                this.showToast('error',AGN_OAM_Accept_Declaration,'error');
            } else{
                this.isFinish = true;
                this.handleClick('finish');
            }
        }
		else{
            this.isFinish = true;
            this.handleClick('finish');
        }
    }

     handleClick(actionType) {
         //this.hidemaindiv = true;
         let labelMap = getCustomLable();
         let formatIssuefieldList = [];
         //console.log('formatIssuefieldList length1>>>>'+formatIssuefieldList.length);
         this.disableFinishBtn = true;
         this.showLoader = true;
         let addressFieldsValid = true;
         let paymentFieldsValid = true;
         var isFormatValid = true;
         //this.billToAddr = billToAddr;
         //this.shipToAddr = shipToAddr;
         //var soldToAddr = this.soldToAddr;
         var soldToAddRec = this.soldToAddr
         var soldToAddr = {
             'sobjectType': 'Allergan_Customer_Address_AGN__c'
         };
         var newBillToAddrList = [];
         var newShipToAddrList = [];
         var billToAddrList = [];
         var shipToAddrList = [];
         var allPaymentValid = true;
         var hasFormatIssues = false;
         let paymntfieldIssue = false;
         var newBilltoMap = new Map();
         let billtomap = new Map();
         //vat or tax required
         let vatTaxMap = new Map();
         let hasTaxVatRequired = false;
         let VATORTAXRequired = '';
         let labelNameVAT = '';
         let labelNameTAX = '';

         var soldToId = soldToAddRec.Id;
         for (let key in soldToAddRec) {
             if (soldToAddRec.hasOwnProperty(key) && key !== 'sobjectType') {
                 soldToAddr[key] = soldToAddRec[key];
             }
         }
         //soldToAddr.Id = soldToId;
         soldToAddr.Bill_To_AGN__c = this.billToSameAsSoldTo;
         billToAddrList = this.billToAddr;
         shipToAddrList = this.shipToAddr;
         if (billToAddrList) {
             billToAddrList.forEach(function (bill) {
                 if (bill.Id !== soldToId) {
                     bill.Bill_To_AGN__c = true;
                     bill.Sold_To_AGN__c = false;
                     bill.Ship_To_AGN__c = false;
                 }
                 billtomap.set(bill.Id, bill);
             });
         }
         //shipToAddr 
         if (shipToAddrList) {
             shipToAddrList.forEach(function (ship) {
                 if (ship.Id !== soldToId) {
                     ship.Bill_To_AGN__c = false;
                     ship.Sold_To_AGN__c = false;
                     ship.Ship_To_AGN__c = true;
                 }
             });
         }
         
         this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
             //console.log('instancetype>>>>>>>>>>>>>>>>>', element.instancetype);
             //console.log('objecttype>>>>>>>>>>>>>>>>>', element.objecttype);
            // //console.log('index>>>>>>>>>>>>>>>', element.index);

             //console.log('value>>>>>>>>>>>>>>>>>>>>',element.getUserEnteredInput());
             //console.log('sobject>>>>>>>>>>>>>>>>>>>>',element.sobjectname);
             //console.log('fieldname>>>>>>>>>>>>>>>>>>>>', element.fieldname);
             isFormatValid = element.isFormatValid();            
             //console.log('(element.checkValidity()>>>>>>>>>>>>>>>>>>>>',element.checkValidity());
            if(element.fieldname == 'Tax_Number_AGN__c'){               
                labelNameTAX = labelMap.get(element.customlabel);                                                      
            }
            if(element.fieldname == 'VAT_Number_AGN__c'){               
                labelNameVAT = labelMap.get(element.customlabel);                                                                 
            }
            
            if(element.isActiveField()){
                if(isFormatValid)
                {  
                    element.setCustomErrorMessage('');
                    if (element.checkValidity()) {
                        //addressFieldsValid = true;                    
                    // if (element.getUserEnteredInput()) {
                            if (element.sobjectname === 'Allergan_Customer_Address_AGN__c') {
                                if (element.objecttype === 'soldto') {
                                    soldToAddr[element.fieldname] = element.getUserEnteredInput();
                                } else if (element.objecttype === 'billto' && element.instancetype === 'new') {

                                // //console.log('has index>>>>>>>>>>>>>>>', newBilltoMap.has(element.index));
                                    if (newBilltoMap.has(element.index)) {
                                        newBilltoMap.get(element.index)[element.fieldname] = element.getUserEnteredInput();
                                    } else {
                                        let newBilltoAddress = {
                                            'sobjectType': 'Allergan_Customer_Address_AGN__c'
                                        };
                                        newBilltoAddress[element.fieldname] = element.getUserEnteredInput();
                                        newBilltoMap.set(element.index, newBilltoAddress);
                                    }

                                } else if (element.objecttype === 'billto' && element.instancetype === 'old') {
                                    var recordId = element.record.Id;
                                    //console.log('recordId>>>>>>>>>>>>>>>>>',recordId);
                                // //console.log('billtomap>>>>>>>>>>>>>>>>>', billtomap);

                                    if (billtomap.has(recordId)) {
                                        billtomap.get(recordId)[element.fieldname] = element.getUserEnteredInput();
                                    }
                                }
                            }
                    // }                    
                    } else {
                            addressFieldsValid = false;                           
                    }
                }
                else{

                    formatIssuefieldList.push(labelMap.get(element.customlabel));
                    element.setCustomErrorMessage(AGN_OAM_Invalid_Input); //AGN_CP_FORMAT_INVALID
                    hasFormatIssues = true;
                }
            }
             //console.log('Is Format Valid>>>>>>>>', isFormatValid);
             //console.log('Registration>>>>>>>>>>>>>>>',registration);
             //console.log('Address>>>>>>>>>>>>>>>>>>>>',address);

         });
         if(!addressFieldsValid){
            this.showLoader = false;
            this.hidemaindiv = false; 
            
            this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
            return;
         }
         if(hasFormatIssues){
            this.showLoader = false;
            this.hidemaindiv = false; 
            if(formatIssuefieldList.length>0){
                this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
            }  
            formatIssuefieldList =[];         
            return;
         }
         if(this.country === 'IT' || this.country == 'ES'){
            if(newBilltoMap){
                let billtolist =  newBilltoMap.values();
                for(let billtoRecd of billtolist){
                    let TAXValue = billtoRecd.Tax_Number_AGN__c;
                    let VATValue = billtoRecd.VAT_Number_AGN__c;
                    //console.log('New TAXValue::::',TAXValue, '::VATValue:::',VATValue);
                    if(!TAXValue && !VATValue){
                        hasTaxVatRequired = true;
                    } 
                }                 
                
            }
            if(billtomap){
                 let billtolist =  billtomap.values();
                 for(let billtoRecd of billtolist){
                    let TAXValue = billtoRecd.Tax_Number_AGN__c;
                    let VATValue = billtoRecd.VAT_Number_AGN__c;
                    //console.log('old TAXValue::::',TAXValue, '::VATValue:::',VATValue);
                    if(!TAXValue && !VATValue){
                        hasTaxVatRequired = true;
                    } 
                 }
                
            }
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
            
         
         let paymentformatValid = new Set();
         let paymentinputValid=true;
         let isAnyPaymentMethodInValid  = false;
         let isAnyPaymentTermInValid = false;
        this.template.querySelectorAll('c-agn_gcsp_payment-form').forEach(element=>{  
            
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
            //console.log('isPaymentMethodValid >>>>>>>>>>>>>>>>', isPaymentMethodValid);
            let isPaymentTermValid = element.checkPaymentTerm();
            //console.log('isPaymentTermValid >>>>>>>>>>>>>>>>', isPaymentTermValid);
            if(!isPaymentTermValid)
            {                     
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
                isAnyPaymentTermInValid = true
            }
            if(!isPaymentMethodValid)
            {
            
                paymntfieldIssue = true;
                paymentFieldsValid = false;
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
                isAnyPaymentMethodInValid = true;
            }        

         });
         //console.log('paymentformatValid >>>>>>>>>>>>>>>>', paymentformatValid);
         //console.log('paymentinputValid >>>>>>>>>>>>>>>>', paymentinputValid);

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

         
         this.template.querySelectorAll('c-agn_gcsp_payment-form').forEach(element=>{
           
            let isPaymentMethodValid = element.checkPaymentMethod();
            //console.log('isPaymentMethodValid >>>>>>>>>>>>>>>>', isPaymentMethodValid);
            let isPaymentTermValid = element.checkPaymentTerm();
            //console.log('isPaymentTermValid >>>>>>>>>>>>>>>>', isPaymentTermValid);
            if(!isPaymentTermValid)
            {
                this.showToast('error',AGN_OAM_Required_Fields_Missing_Error+' '+ AGN_OAM_Payment_Term ,'error');
                paymntfieldIssue = true;
                paymentFieldsValid = false; 
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
            }
            if(!isPaymentMethodValid)
            {
                this.showToast('error',AGN_OAM_Required_Fields_Missing_Error+' '+  AGN_OAM_Body_PaymentMethod ,'error');
                paymntfieldIssue = true;
                paymentFieldsValid = false;
                this.hidemaindiv = false;
                this.showLoader = false;
                this.disableFinishBtn = false;
            }
            let paymentDetails = element.validateInputs();
            //console.log('paymentDetails>>>>'+ JSON.stringify(paymentDetails));
            if(paymentDetails.includes('error')){
                //console.log('paymentDetails2>>>>'+ paymentDetails.replace('error',''));
                if(paymentDetails.replace('error',''))
                {
                    formatIssuefieldList.push(paymentDetails.replace('error',''));
                }  
                //console.log('formatIssuefieldList length>>>>'+formatIssuefieldList.length);
                this.hidemaindiv = false;
                this.showLoader = false;
                hasFormatIssues = true;                
                //this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+paymentDetails.replace('error',''), 'error'); 
                this.disableFinishBtn = false;
                paymntfieldIssue = true;
                //return;
            }
             let index = element.index;
             let objecttype = element.objecttype;
             //console.log('Iterating payment form>>>>>>>>>>>>>>>>', paymentDetails);
             //console.log('payment index>>>>>>>>>>>>>>>', index);
            
             if (paymentDetails && !paymntfieldIssue) {
                 paymentFieldsValid = true;
                 let hasIssue = paymentDetails.includes("FIELDS_NOT_FOUND");
                 if(!hasIssue)
                 {
                    paymentDetails.forEach(function (payment) {
                        if (objecttype === 'soldto') {
                            if (payment.Id) {
                                for (var key in payment) {
                                    if (payment.hasOwnProperty(key)) {
                                        //console.log('soldto key>>>>>>>>>', key);
                                        //console.log('soldto payment[key]>>>>>>>>>', payment[key]);
                                        soldToAddr[key] = payment[key];
                                    }
                                }
                            }
                        } else if (objecttype === 'billto') {
                            if (payment.Id) {
                                /* Existing Records ==== Record Update */
                                if (billtomap.has(payment.Id)) {
                                    for (var skey in payment) {
                                        if (payment.hasOwnProperty(skey)) {
                                            //console.log('key>>>>>>>>>', skey);
                                            //console.log('payment[key]>>>>>>>>>', payment[skey]);
                                            //console.log('payment[keyqq]>>>>>>>>>', billtomap.get(payment.Id)[skey] );
                                            billtomap.get(payment.Id)[skey] = payment[skey];
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
                        }
   
                    });

                 }
                 else{
                    this.showToast('error',AGN_OAM_Required_Fields_Missing_Error,'error');
                    this.disableFinishBtn = false;
                    paymentFieldsValid =false;
                 }
                
             } else {
               
                 paymentFieldsValid = false;
             }
         });
         
         let isBankDeclarationChecked = true;

         if(!this.isCS)
         {           
            if ((this.showBankDeclaration || this.showCanadaDeclaration) && !this.isBankDeclarationChecked) {
                isBankDeclarationChecked = false;
            }
         }else{
            this.isBankDeclarationChecked = true;
         }
         

         if (isBankDeclarationChecked && addressFieldsValid && paymentFieldsValid && !hasFormatIssues) {
             //UPSERT DATA CODE HERE
             //console.log('Success - Add Upsert Code***');
             billToAddrList = [];
             for (let value of billtomap.values()) {
                 billToAddrList.push(value);
             }
             //console.log('billtolist to upsert>>>>>>>>>>', billToAddrList);
             for (let value of newBilltoMap.values()) {
                 newBillToAddrList.push(value)
             }
             if (newShipToAddrList) {
                 newShipToAddrList.forEach(function (nship) {
                     nship.Bill_To_AGN__c = false;
                     nship.Sold_To_AGN__c = false;
                     nship.Ship_To_AGN__c = true;
                 });
             }
             if (newBillToAddrList) {
                 newBillToAddrList.forEach(function (nbill) {
                     nbill.Bill_To_AGN__c = true;
                     nbill.Sold_To_AGN__c = false;
                     nbill.Ship_To_AGN__c = false;
                 });
             }
             if (this.selectedPaymentMethod) {
                 soldToAddr.Form_Of_Payment_AGN__c = this.selectedPaymentMethod;
             }
             if (this.selectedPaymentTerm) {
                 soldToAddr.Payment_Term_AGN__c = this.selectedPaymentTerm;
             }
             let existingBilltoLen = 0;
             if (soldToAddr.Bill_To_AGN__c) {
                 existingBilltoLen++;
             }
             if (billToAddrList) {
                 existingBilltoLen += billToAddrList.length;
             }
             if (newBillToAddrList) {
                 existingBilltoLen += newBillToAddrList.length;
             }
             if (existingBilltoLen > 0 || !this.showBillToSection || !this.billtoLimit || this.billtoLimit > 0) { //&&  this.country === 'BR'
                 //console.log('soldToAddrsuccess:::', soldToAddr);
                 //console.log('billToAddrList:::', billToAddrList);
                 //console.log('newBillToAddrList:::', newBillToAddrList);
                 //console.log('registration:::', this.registration);
                 upsertAllAddressDetailsNew({
                         soldToAddr: soldToAddr,
                         billToAddrList: billToAddrList,
                         shipToAddrList: shipToAddrList,
                         newBillToAddrList: newBillToAddrList,
                         newShipToAddrList: newShipToAddrList,
                         customer: this.registration,
                         currentStep: '4',
                         actionType: actionType,
                         source : this.source
                     })
                     .then(result => {
                         if (result) {

                             //console.log('Address Upserted>>>>>>>>>', result);
                             //console.log('case.id>>>>>>>>>', result.Id);
                             //this.showNewBillto = false;
                             this.reloadAddress();
                             this.hidemaindiv = false;
                             this.showLoader = false;  
                             if(this.isFinish){
                                if (this.source == 'cs') {
                                    this.nextOrPreviousActionEvent(result, '0');
                                 }
                                 else{
                                    this.isRegistrationCompleted = true;
                                   // this.successMsg = 'you have Successfully completed your registration';//result;
                                 }
                                 this.isFinish = false;
                             }else{
                                this.showToast('success' , AGN_OAM_Successfully_Updated , 'success');
                             }
                             //AGN_CP_CaseCreationSuccessmsg
                             //this.showToast('Success' , 'Address updated Successfully'); //AGN_CP_ADDRESS_UPDATE_SUCCESS
                         
                            }
                            this.disableFinishBtn = false;
                     })
                     .catch(error => {
                         console.log(error);
                         this.error = error;
                         this.hidemaindiv = false;
                         this.showLoader = false;
                         this.disableFinishBtn = false;
                         this.showToast('error' , error , 'error');
                     });
             } else {
                 this.hidemaindiv = false;
                 this.showLoader = false;
                 this.disableFinishBtn = false;
                 this.showToast('error', AGN_OAM_BillTo_Mandatory, 'error'); //AGN_CP_BILLTO_MANDATORY_ERROR_MSG
             }

         } else {
             if (!isBankDeclarationChecked && addressFieldsValid && paymentFieldsValid && !hasFormatIssues) {
                 this.showToast('error', AGN_OAM_Bank_Declaration, 'error'); 
                this.disableFinishBtn = false;//AGN_CP_BANK_DECLARATION_REQUIRED
             } else {
                this.disableFinishBtn = false;
                if(hasFormatIssues){
                    //console.log('formatIssuefieldList1>>>>>>>'+formatIssuefieldList);
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.error = AGN_OAM_Invalid_Input;  
                    if(formatIssuefieldList.length>0) {
                        this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
                    }
                    else{
                        this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
                    }
                    formatIssuefieldLis =[];
        
                }
                else{
                    this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error'); //AGN_CP_Invalid_Input_Error
                }
                 
             }

             this.hidemaindiv = false;
             this.showLoader = false;
             this.disableFinishBtn = false;
         }
     }

     reloadAddress() {
         this.billingMap = [];
         this.billToAddr = [];
         this.billtoExists = false;
         getCustomerAddressDetails({
                 custRegId: this.registration.Id
             })
             .then(data => {
                 if (data) {
                     //console.log("Address Data*******", data);
                     var soldToAddr;
                     var billToAddr = [];
                     var shipToAddr = [];
                     var addressList = data;
                     for (var i in addressList) {
                         if (addressList[i].Sold_To_AGN__c) {
                             //only 1 SoldTo Address will be present
                             soldToAddr = addressList[i];
                             this.shipToSameAsSoldTo = addressList[i].Ship_To_AGN__c; //will set true/false
                             this.billToSameAsSoldTo = addressList[i].Bill_To_AGN__c; //will set true/false
                         }
                         if (addressList[i].Ship_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                             //Multiple ShipTo Address will be present
                             shipToAddr.push(addressList[i]);
                         }
                         if (addressList[i].Bill_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                             //Multiple BillTo Address will be present
                             billToAddr.push(addressList[i]);
                         }
                     }
                     //console.log('soldToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', soldToAddr);
                     //console.log('billToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', billToAddr);
                     //console.log('shipToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>', shipToAddr);
                     let paymentMethodSet = new Set()
                     if (soldToAddr.Form_Of_Payment_AGN__c) {
                         paymentMethodSet.add(soldToAddr.Form_Of_Payment_AGN__c);
                     }
                     billToAddr.forEach(function (bill) {
                         if (bill.Form_Of_Payment_AGN__c) {
                             paymentMethodSet.add(bill.Form_Of_Payment_AGN__c);
                         }
                     });
                     //console.log('paymentMethodSet>>>>>>>>>>>>>>>>>', paymentMethodSet);
                     this.soldToAddr = soldToAddr;
                     this.billToAddr = billToAddr;
                     this.shipToAddr = shipToAddr;                     
                     if (paymentMethodSet) {
                         this.reloadPaymentTerms(paymentMethodSet);
                     }
                     this.billtoExists = true;                  

                 } else {
                     this.hidemaindiv = false;
                     this.showLoader = false;
                 }
             })
             .catch(error => {
                 console.log('error on address fetching>>>>>>>>>>>>>>>>>>>', error);
                 this.hidemaindiv = false;
                 this.showLoader = false;
             });
     }

     reloadPaymentTerms(paymentMethodSet) {
         let paymethods = [];
         paymentMethodSet.forEach(function (pay) {
             paymethods.push(pay);
         });
         getPaymentTerms({
                 paymentMethodSet: paymethods,
                 source: this.source
             })
             .then(result => {
                 if (result) {
                     //console.log('********Payment Term Reload*************', result);
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

     showToast(title, message, variant) {

        if(this.source==='cs')
        {   this.error = message; 
            this.variant = variant;               
            this.template.querySelector('c-agn_gcsp_custom-toast').showCustomNotice();
        }
        else{
            const event = new ShowToastEvent({               
                message : message,
                variant : variant
            });
            this.dispatchEvent(event);
        }           
     }

     paymentHandler(event) {
        this.showBankDeclaration =false;
         /*//console.log('Payment Event Handler>>>>>>>>>>>',event.detail.paymentfields)
         var paymentFields = event.detail.paymentfields;
         var paymentmethod = event.detail.paymentmethod;
         var paymentterm = event.detail.paymentterm;
         if(paymentFields){
             this.paymentSectionFields = paymentFields;
         }
         if(paymentmethod){
             this.selectedPaymentMethod = paymentmethod;
         }
         if(paymentterm){
             this.selectedPaymentTerm = paymentterm;
         }*/
         //console.log('Payment Event Handler>>>>>>>>>>> ', event.detail.showBankDetails);
               
         let eventValue = event.detail.showBankDetails;
         let key = event.detail.key;
         this.showBankDeclarationMap.set(key, eventValue);
         let showBankDeclaration = false;
         //console.log('this.showBankDeclarationMap>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', this.showBankDeclarationMap);
         if(this.country === 'AU' || this.country ==='AN' || this.country ==='NZ')
         {
             showBankDeclaration = true;
         }
         else 
         {
            for (let value of this.showBankDeclarationMap.values()) {
                //console.log('Iterating Map>>>>>>>>', value);
                if (value) {
                    showBankDeclaration = true;
                }
               }
         }
         if(!this.isCS){
            this.disableFinishBtn = showBankDeclaration;
         }
         else{
            this.disableFinishBtn = true;
         }  
        if(this.country !== 'CA'){
            this.showBankDeclaration = showBankDeclaration;
        }       
        
             
        
         //console.log('this.showBankDeclaration>>>>>>>>>>>>>>>>>>>>>', this.showBankDeclaration);
     }

     checkboxHandler(event) {
         //console.log('event.target.checked>>>>>>>>>>>>>', event.target.checked);
         let fieldname = event.target.name;
         let checked = event.target.checked;
         if (fieldname === 'sameassoldto') {
             this.billToSameAsSoldTo = checked;
             //this.soldToAddr.Bill_To_AGN__c = checked;
         } /*else if (fieldname === 'termsncondns') {
             this.isTermsChecked = checked;

             if (checked) {
                 if (this.showBankDeclaration) {
                     if (this.isBankDeclarationChecked) {
                         this.disableFinishBtn = false;
                     } else {
                         this.disableFinishBtn = true;
                     }
                 } else {
                     this.disableFinishBtn = false;
                 }
             } else {
                 this.disableFinishBtn = true;
             }

         }*/ else if (fieldname === 'banktermsncondns') {
             this.isBankDeclarationChecked = checked;
             if (checked) {//&& this.isTermsChecked
                 this.disableFinishBtn = false;
             } else {
                 this.disableFinishBtn = true;
             }
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
        const templateIndex = eventParemeters.index;
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
                     if (element.fieldname === field.Field_Name_AGN__c &&
                        element.sobjectname === field.SObject_Name_AGN__c && element.index == templateIndex  && element.objecttype == templateobjecttype ) {
                         //console.log('Checking the dependent List>>');
                         //element.removeInputValue();
                         if (field.Dependent_Field_Show_Criteria_AGN__c && field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
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
       this.hidemaindiv = false;
       this.showLoader = false;
        //console.log('this.showLoader>>>>'+this.showLoader);  
     }
	 
	 //Brazil Zipcode validation code goes here
	 handleZipCodeValueChange(event){	
        //this.showLoader = true;	
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
        //console.log('eventParemeters::::: ',zipValue);	
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
                                if (element.sobjectname === sobjectName && element.index == index  && element.objecttype == objecttype) {	
                                	
                                        if(element.fieldname === 'Street_Name_AGN__c'){	
                                            element.fieldValue = addressInfo.street;	
                                        }	
                                        if(element.fieldname === 'Address_Line_3_AGN__c'){	
                                            element.fieldValue = addressInfo.bairro;	
                                        }	
                                        if(element.fieldname === 'City_AGN__c'){	
                                            element.fieldValue = addressInfo.city;	
                                        }	
                                        if(element.fieldname === 'State_AGN__c'){	
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

    showDependentField(layoutMetadataMaster, controlingfieldData) {
       // const eventParemeters = controlingfieldData;
        //console.log('controlingfieldDataonload:::::::::', controlingfieldData);
        const controllingFieldSobjectName = controlingfieldData.controllingFieldSobjectName;
        const controllingFieldName = controlingfieldData.controllingFieldName;
        const controllingFieldSelectedValue = controlingfieldData.controllingFieldSelectedValue;
        const templateIndex = controlingfieldData.index;
        const templateobjecttype = controlingfieldData.objecttype;
        let dependentFieldList = [];
        var itr = 1;
        Object.keys(layoutMetadataMaster).forEach(key => {
            let dependentField = this.layoutMetadataMaster[key].find(layout => {
                if (layout.Controlling_Field_AGN__c == controllingFieldName && layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName) { 
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
                    if (element.fieldname === field.Field_Name_AGN__c && element.sobjectname === field.SObject_Name_AGN__c
                        && element.index == templateIndex  && element.objecttype == templateobjecttype) {
                       
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