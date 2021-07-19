/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 06-11-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-05-2021   Ravi Sirigiri   Initial Version
 **/
 import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import AGN_OAM_Body_Country from '@salesforce/label/c.AGN_OAM_Body_Country';
import AGN_OAM_Body_CustomerType from '@salesforce/label/c.AGN_OAM_Body_CustomerType';
import AGN_OAM_Body_SubType from '@salesforce/label/c.AGN_OAM_Body_SubType';
import AGN_OAM_Apex_DuplicateEmail from '@salesforce/label/c.AGN_OAM_Apex_DuplicateEmail';
import AGN_OAM_Body_Confirm_Youhave from '@salesforce/label/c.AGN_OAM_Body_Confirm_Youhave';
import AGN_OAM_Body_Confirm_SuccessfullyCompleted from '@salesforce/label/c.AGN_OAM_Body_Confirm_SuccessfullyCompleted';
import AGN_OAM_Body_Confirm_FirstStep from '@salesforce/label/c.AGN_OAM_Body_Confirm_FirstStep';
import AGN_OAM_Communication_Contact from '@salesforce/label/c.AGN_OAM_Communication_Contact';
import AGN_OAM_Address from '@salesforce/label/c.AGN_OAM_Address';
import AGN_OAM_Basic_Information from '@salesforce/label/c.AGN_OAM_Basic_Information';
import AGN_GCSP_AllFieldMandatory from '@salesforce/label/c.AGN_GCSP_AllFieldMandatory';
import AGN_OAM_Confirm_not_robot from '@salesforce/label/c.AGN_OAM_Confirm_not_robot';
import AGN_OAM_Accept from '@salesforce/label/c.AGN_OAM_Accept';
import AGN_OAM_Cancel from '@salesforce/label/c.AGN_OAM_Cancel';

import AGN_OAM_Please_Confirm from '@salesforce/label/c.AGN_OAM_Please_Confirm';
import AGN_OAM_Privacy_Policy from '@salesforce/label/c.AGN_OAM_Privacy_Policy';
import AGN_OAM_Body_TermsConditions from '@salesforce/label/c.AGN_OAM_Body_TermsConditions';
import AGN_OAM_Header_CustomerRegistration from '@salesforce/label/c.AGN_OAM_Header_CustomerRegistration';
import AGN_OAM_Product_Interest from '@salesforce/label/c.AGN_OAM_Product_Interest';
import AGN_OAM_Body_Submit from '@salesforce/label/c.AGN_OAM_Body_Submit';
import AGN_OAM_Next from '@salesforce/label/c.AGN_OAM_Next';
import AGN_OAM_Loading from '@salesforce/label/c.AGN_OAM_Loading';
import AGN_OAM_CS from '@salesforce/label/c.AGN_OAM_CS';
import AGN_OAM_Country_IE from '@salesforce/label/c.AGN_OAM_Country_IE';
import AGN_OAM_Country_GB from '@salesforce/label/c.AGN_OAM_Country_GB';
import AGN_OAM_IT from '@salesforce/label/c.AGN_OAM_IT';

import AGN_OAM_Body_CommunicationContact from '@salesforce/label/c.AGN_OAM_Body_CommunicationContact';
import AGN_OAM_Unknown_Err from '@salesforce/label/c.AGN_OAM_Unknown_Err';
import AGN_OAM_Contact_Service from '@salesforce/label/c.AGN_OAM_Contact_Service';
import AGN_OAM_Inactive_State from '@salesforce/label/c.AGN_OAM_Inactive_State';
import AGN_OAM_Valid_Input from '@salesforce/label/c.AGN_OAM_Valid_Input';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';
import AGN_OAM_Captcha_Error from '@salesforce/label/c.AGN_OAM_Captcha_Error';

import AGN_OAM_Basic_Information_Heading from '@salesforce/label/c.AGN_OAM_Basic_Information_Heading';
import AGN_OAM_Address_Details_Heading from '@salesforce/label/c.AGN_OAM_Address_Details_Heading';
import AGN_OAM_Document_Upload_Heading from '@salesforce/label/c.AGN_OAM_Document_Upload_Heading';
import AGN_OAM_Confirmation_Heading from '@salesforce/label/c.AGN_OAM_Confirmation_Heading';
import AGN_OAM_Accept_TnC from '@salesforce/label/c.AGN_OAM_Accept_TnC';
import AGN_OAM_TnC_Header from '@salesforce/label/c.AGN_OAM_TnC_Header';
import AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions from '@salesforce/label/c.AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions';
import AGN_OAM_Body_PleaseCheckFormatFor from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Required_Fields_Missing_Error from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';

import AGN_OAM_Body_Province from '@salesforce/label/c.AGN_OAM_Body_Province';
import AGN_GCSP_STEP1 from '@salesforce/label/c.AGN_GCSP_STEP1';
import AGN_GCSP_STEP2 from '@salesforce/label/c.AGN_GCSP_STEP2';
import AGN_GCSP_STEP3  from '@salesforce/label/c.AGN_GCSP_STEP3';
import AGN_GCSP_STEP4 from '@salesforce/label/c.AGN_GCSP_STEP4';
import AGN_GCSP_STEP5  from '@salesforce/label/c.AGN_GCSP_STEP5';
import AGN_OAM_Contact_Affiliation  from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_information_for_communication  from '@salesforce/label/c.AGN_OAM_information_for_communication';
import AGN_OAM_Successfully_reset_and_check_inbox_NL from '@salesforce/label/c.AGN_OAM_Successfully_reset_and_check_inbox_NL';


/*import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport'; */

import fetchCountryList from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.fetchCountryList';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getLayout';
import fetchFooterConsents from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.fetchFooterConsents';
import getCommonSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getCommonSettings';
import createAccount from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createAccount';
import createContact from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createContact';
import createCommunityUser from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createCommunityUser';
import createNewCustomerRegistration from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createNewCustomerRegistration';
import createOktaUserSendLink from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createOktaUserSendLink';
import isDuplicateUser from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.isDuplicateUser';
import getCustomerRegDetailsCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS';
import getCustomerAddressDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails';
import getCaseDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCaseDetails';
import getcustomerContactDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getcustomerContactDetails';
import createNewCustomerRegistrationCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.createNewCustomerRegistrationCS';
import getAddressInformation from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getAddressInformation';
import getUserDetail from '@salesforce/apex/AGN_GCSP_PortalAccountDetailController.getUserDetail';
import getGCSPSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings';
import getAllFieldsMetadata from '@salesforce/apex/AGN_GCSP_MetadataController.getAllFieldsMetadata';  
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';
import LANG from '@salesforce/i18n/lang';


export default class AGN_GCSP_CustomerRegistrationStep1 extends LightningElement {
    @api box_img_step1_active = ASSETS + '/assets/Images/Registration/box_img_step1_active.png';
    @api country = '';
    @api language = '';
    @track langCode;
    @track selectedCountry;
    @track selectedCustomerCategory;
    @track selectedCustomerSubCategory;
    @track picklistCountryOptions;
    @track picklistCustomerTypeOptions;
    @track picklistSubTypeOptions;
    @track customerTypeConfig;
    @track showStep1;
    @track productIntSection = false;
    @track stepNo;
    @track basicInformationFields;
	@track brazilPostalCodeFields;
    @track practiceAddressFields;
    @track productInterestFields;
    @track allFieldsDescribeMap = new Map();
    @track contactFields;
    @track showLoader;
    @track isCompleted;
    @track hidemaindiv;

    @track customerType;
    @track customerSubType;
    @track custTypeConfig;
    @track customerGroup;

    @track account;
    @track contact;
    @track countryCode = '';
    @track sapCountryCode = '';
    @track disableSubmitBtn = true;
    @track layoutMetadataMaster;
    @track isOnlineRegistration = false;

    @track soldToAddress;
    @track registrationRec;
    @track acrContact;
    @track caseRecord;
    @track showDisSelection =false;
    @track error;
    @track selectedProductInterest=[];

    @track captchaurl = '';
    @track iscaptchavalid = false;
    @track baseurl = '';
    @track isCS = false;
	
	isPostalCodeBR = false;	
    isBRAddressDisable = false;	
    isBrZipCodeValue = false;
    isEmailReqdOnLoad = false;

    @track termsURL;
    @track record;
    @api source = null;
    @api sourceOAM = null;
    @api sourceCS = null;

    @api RegistrationStepNo;
    @api caseId;
    @api accountId;

    @track commonSettings;
    @track ShowTermsAndConditions;
    @track isTNCAccepted =false;
    @track textTNC;
    @track variant ='error';
    @track isNL = false;
    @track isBR = false;
    custypeshow;
    cusSubtypeshow;
    
    @track picklistProvienceOptions;
    selectedProvience;
    isProvience;
    provienceShow;

    header_cus_css;
    header_css;
    header_css_read;
    @track hasRendered=false;
    countryName;
    stateName;

    basicInfoLabel; 
    

    label = {
        AGN_OAM_Body_Province,
        AGN_OAM_Basic_Information_Heading,
        AGN_OAM_Address_Details_Heading,
        AGN_OAM_Document_Upload_Heading,
        AGN_OAM_Confirmation_Heading,
        AGN_OAM_Body_Country,
        AGN_OAM_Body_CustomerType,
        AGN_OAM_Body_SubType,
        AGN_OAM_Apex_DuplicateEmail,
        AGN_OAM_Body_Confirm_Youhave,
        AGN_OAM_Body_Confirm_SuccessfullyCompleted,
        AGN_OAM_Body_Confirm_FirstStep,
        AGN_OAM_Basic_Information,
        AGN_OAM_Address,
        AGN_OAM_Communication_Contact,
        AGN_GCSP_AllFieldMandatory,
        AGN_OAM_Confirm_not_robot,
        AGN_OAM_Header_CustomerRegistration,
        AGN_OAM_Product_Interest,
        AGN_OAM_Please_Confirm,
        AGN_OAM_Privacy_Policy,
        AGN_OAM_Body_TermsConditions,
        AGN_OAM_Body_Submit,
        AGN_OAM_Next,
        AGN_OAM_Loading,
        AGN_OAM_CS,
        AGN_OAM_Country_IE,
        AGN_OAM_Country_GB,
        AGN_OAM_IT,
        AGN_OAM_Body_CommunicationContact,
        AGN_OAM_Unknown_Err,
        AGN_OAM_Contact_Service,
        AGN_OAM_Inactive_State,
        AGN_OAM_Valid_Input,
        AGN_OAM_Invalid_Input,
        AGN_OAM_Captcha_Error,
        AGN_OAM_Cancel,
        AGN_OAM_Accept,
        AGN_OAM_Accept_TnC,
        AGN_OAM_TnC_Header,
        AGN_OAM_I_Accept_the_GDPR_Terms_and_Conditions,
        AGN_OAM_Body_PleaseCheckFormatFor,
        AGN_GCSP_STEP1,
        AGN_GCSP_STEP2,
        AGN_GCSP_STEP3,
        AGN_GCSP_STEP4,
        AGN_GCSP_STEP5,
        AGN_OAM_Contact_Affiliation,
        AGN_OAM_Required_Fields_Missing_Error,
        AGN_OAM_Successfully_reset_and_check_inbox_NL

    };

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');  
        this.header_cus_css = this.country=='CA' ? 'slds-form-element cus_input_canada':'slds-form-element cus_input';
        this.header_css = this.country=='CA' ? 'slds-select slds-input_canada':'slds-select slds-input';
        this.header_css_read = this.country=='CA' ? 'slds-form-element cus_input_read_canada':'slds-form-element cus_input_read';  
        //console.log('renderedCallback|hasRendered:: ', this.hasRendered)
        if(!this.hasRendered) {this.renderDependentField();}   
        //this.renderDependentField(); 
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
        this.productIntSection = false;
        //alert('step1::' + this.sourceCS);
        if (this.sourceOAM && this.sourceOAM === 'oam') {
            this.source = this.sourceOAM;
            this.isOnlineRegistration = true;
        }
        if (this.sourceCS && this.sourceCS === 'cs') { //AGN_OAM_CS
            this.source = this.sourceCS;
            this.iscaptchavalid = true;
            this.isCS = true;
        }
        //console.log('source :::::: ', this.source);
        var parameters = {};
        this.showStep1 = false;
        this.isCompleted = false;
        this.hidemaindiv = false;
        parameters = this.getQueryParams(); //get url parameters
        this.showLoader = true;

        if (parameters.language) {
            this.langCode = parameters.language;
            let langreg = parameters.language.split('_'); //it, en_AU, en_GB
            if (langreg.length === 2) {
               // this.language = langreg[0];
                this.country = langreg[1].toUpperCase();
            } else {                
                this.country = parameters.language.toUpperCase();
            }
            this.language = parameters.language;
            //console.log('language-->' + this.language);
            //console.log('country-->' + this.country);

            this.showStep1 = false;
            this.isCompleted = false;
            this.hidemaindiv = false;
        }
        if (parameters.country) {
            this.country = parameters.country.toUpperCase();
            //console.log('ccall>>>',this.country, typeof this.country);
            if(this.country == "NL"){ // Step 1 Specific Message rendering for NL
                this.isNL=true;
                //console.log('isNL>>>>', this.isNL);
            } else if(this.country == "BR") { // Hide TnC from BR Step 1
                this.isBR=true;
            }
        }
        if (this.source === 'oam') {
            this.getCurrentUserDetails(this.country, this.language);
            this.getCommonSettingsData(this.country);
        }
        if (this.sourceCS === 'cs') { //AGN_OAM_CS
            if (parameters) {
                var caseService = parameters.caseService;
                var caseStaticCategory = parameters.caseStaticCategory;
                var selectedCountryCode = parameters.countryCode; //countryCode
                var recordType = parameters.recordType;
                var entitlementId = parameters.entitlementId;
                var caseCategory = parameters.caseCategory;
                var caseReason = parameters.caseReason;
                var accId = parameters.accountId;
                //console.log('caseService:: ' + caseService + ':: ' + caseStaticCategory + '::  ' + recordType + ':::  ' + entitlementId + '::  ' + caseCategory + ':::  ' + caseReason);
                //console.log('selectedCountryCode::::::', selectedCountryCode);
                //console.log('accId::::::', accId);
                this.country = selectedCountryCode;
                this.accountId = accId;
            }           
            if (this.caseId) {
                this.getCustomerRegistrationDetailsCS();
            }
        } 
        
        this.countryCode = this.country;  
        
        /* */
        
    /*if(window.addEventListener){            
        window.addEventListener("message", (event) =>{​​​​
            this.listenMessage(event)
        }​​​​, false);
    }​​​​ else{​​​​
        window.attachEvent("onmessage", (event) =>{​​​​
            this.listenMessage(event)
        }​​​​, false);
    }​​​​*/
        
       window.addEventListener("message", (event) => {
            //console.log("action>>"+event.data.action);
            //console.log("alohaResponseCAPTCHA>>"+event.data.alohaResponseCAPTCHA);
            //console.log("origin>>"+event.origin);  
            if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK'){              
                this.iscaptchavalid  = false;          
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK'){
                
               // //console.log("Captcha Success1");
                this.iscaptchavalid  = true;
                //console.log("Captcha Success2>>" +  this.iscaptchavalid);
            }
        
        }, false);
      

    }

    getCommonSettingsData(countryCodeVal){
        getCommonSettings().then(result =>{
            if(result)
            {
                this.commonSettings = result;
               // //console.log('commonSettings>>>'+JSON.stringify(this.commonSettings));
                //this.captchaurl = this.commonSettings.Community_Base_URL_AGN__c+this.commonSettings.Community_Suffix_AGN__c+this.commonSettings.GoogleCapcha_AGN__c;
                //this.baseurl = this.commonSettings.Community_Base_URL_AGN__c;
                //console.log('this.captchaurl>>>'+this.captchaurl);
                //console.log('this.baseurl>>>'+this.baseurl);
                getGCSPSettings({country : countryCodeVal})
                .then(result => {
                        if(result){
                            //console.log('Custom Settings Data Response :: ',result);
                           let baseUrl =  result.Community_Base_URL_AGN__c;
                           let suffix =  result.Community_Suffix_AGN__c
                           let url = (suffix && suffix == '/') ? baseUrl : baseUrl+suffix;
                           this.captchaurl = url+this.commonSettings.GoogleCapcha_AGN__c;
                           this.baseurl = baseUrl;

                           //console.log('this.captchaurl>>>'+this.captchaurl);
                         //console.log('this.baseurl>>>'+this.baseurl);
                        }else{
                            this.showLoader = false;
                            this.hidemaindiv = false;
                            this.showToast('error' , AGN_OAM_Unknown_Err);
                        }
                 })
                 .catch(error => {
                            console.log('Error in GCSP Settings Callout :: ',error);
                            //this.showToast(error , '');
                            this.showLoader = false;
                            this.hidemaindiv = false;
                 });

                 
            }
        }).catch(error=>{
            console.log('error>>>'+JSON.stringify(error));
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }

    getCurrentUserDetails(countryCodeVal, languageVal){
        getUserDetail()
        .then(result=>{            
            if(result){                
                let user = result;
                //console.log('result:::::',user);                              
                this.country =  countryCodeVal ? countryCodeVal : user.Country_Code__c;
                this.language =  languageVal ? languageVal : user.LocaleSidKey;
                this.countryCode = this.countryCode ? this.countryCode : this.country;
                this.langCode =  this.langCode ?  this.langCode : this.language; 
                this.getCommonSettingsData(this.countryCode);
                //console.log('this.countryCode>>>'+this.country);
                //console.log('this.language>>>'+this.language);   
            }else{
                //console.log('No user found Error:::::');   
            }
        })
        .catch(error =>{
            console.log('Error in get User Level :: ', error);
            this.showToast(error, '');
                this.showLoader = false;
                this.hidemaindiv = false;
        })
    }

    getCustomerRegistrationDetailsCS() {
        getCustomerRegDetailsCS({
                caseRecId: this.caseId
            })
            .then(result => {
                //console.log('Registration Response :: ', result);
                if (result) {
                    let registration = {
                        'sobjectType': 'Allergan_Customer_Registration_AGN__c'
                    };
                    this.registrationRec = result;
                    var countryCode = result.SAP_Country_Code_AGN__c;
                    if (!countryCode) {
                        countryCode = result.Country_Code_AGN__c;
                    }
                    this.country = countryCode;                    
                   
                    this.customerType = result.Customer_Category_AGN__c;
                    this.customerSubType = result.Customer_Sub_Category_AGN__c;
                    this.selectedCustomerCategory = this.customerType;
                    this.selectedCustomerSubCategory = this.customerSubType;
                    var lang = result.Language_AGN__c;
                    this.provienceShow = result.Province_AGN__c;
                    this.selectedProvience = result.Province_AGN__c;
                    this.stepNo = 1;
                    this.customerTypeConfig && this.customerTypeConfig.forEach(confg=>{ 
                        if((this.customerType===confg.Category_AGN__c) && (confg.Sub_Category__c === this.customerSubType) ) {                  
                             
                             if(this.source==='cs')
                             {
                                this.cusSubtypeshow = confg.Cust_Group_Desc_AGN__c;
                                this.custypeshow = confg.Category_AGN__c;
                             }
                             else{
                                this.language = this.language ? this.language : LANG;
                                 if(this.language && countryCode.toUpperCase() == 'CA' && this.language == 'en_CA'){
                                    this.custypeshow = confg.Category_AGN__c;
                                    this.cusSubtypeshow =  confg.Sub_Category__c;
                                 }
                                 else{
                                    this.custypeshow = confg.Category_Label_AGN__c;
                                    this.cusSubtypeshow =  confg.Sub_Category_Label_AGN__c;
                                 }                              
                             }
                             
                         }                        
                    });
 

                    this.getAddressDetails(result, countryCode);
                    this.getCaseRecordDetails();
                    this.getCustomerContactDetails(result.Id);                    
                    this.showDisSelection = true;
                    //console.log('Error customerTypeConfig :: ',  this.customerTypeConfig);
                    this.getLayoutForInternational(countryCode, this.customerType,
                    this.customerSubType, this.customerTypeConfig);

                    this.showStep1 = true;

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    //this.showToast('', AGN_OAM_Unknown_Err);
                }
            })
            .catch(error => {
                console.log('Error in Registration :: ', error);
                //this.showToast(error, '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }
    getCaseRecordDetails() {
        getCaseDetails({
                caseId: this.caseId
            })
            .then(result => {
                //console.log('Case Response :: ', result);
                if (result) {
                    let caseInfo = {
                        'sobjectType': 'Case'
                    };
                    this.caseRecord = result;

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('', AGN_OAM_Unknown_Err);
                }
            })
            .catch(error => {
                console.log('Error in Case :: ', error);
                this.showToast(error, '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }
    getCustomerContactDetails(regId) {
        getcustomerContactDetails({
                custRegId: regId
            })
            .then(result => {
                //console.log('allergan customer contact Response :: ', result);
                if (result) {
                    let acrContactRec = {
                        'sobjectType': 'Allergan_Customer_Contact_AGN__c'
                    };
                    this.acrContact = result;
                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('', AGN_OAM_Unknown_Err);
                }
            })
            .catch(error => {
                console.log('Error in Case :: ', error);
                this.showToast(error, '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }

    getAddressDetails(registration, countryCode) {

        getCustomerAddressDetails({
                custRegId: registration.Id
            })
            .then(data => {
                if (data) {
                    //console.log("Address Response Callout :: ", data);
                    var soldToAddr;
                    var addressList = data;
                    for (var i in addressList) {
                        if (addressList[i].Sold_To_AGN__c) {
                            //only 1 SoldTo Address will be present
                            soldToAddr = addressList[i];
                        }
						if(addressList[i].Zip_AGN__c && countryCode.toUpperCase() == 'BR'){	
                            this.isBRAddressDisable = false; 	
                            this.isBrZipCodeValue = true;                                                       	
                        }
                    }
                    this.soldToAddress = soldToAddr;

                    this.mergeRegAddRecords();

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('', AGN_OAM_Unknown_Err);
                }
            })
            .catch(error => {
                console.log('Error in Address Callout :: ', error);
                this.showToast(error, '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }

    openModal() {    
       
        this.ShowTermsAndConditions = true;
    }
    acceptTNC(event) { 
        let cmp = this.template.querySelector('.tncchkbox');
        cmp.checked = true;       
        this.ShowTermsAndConditions = false; 
        this.disableSubmitBtn = false;
    }
    closeModal() {    
        let cmp = this.template.querySelector('.tncchkbox');
        cmp.checked = false;
        this.ShowTermsAndConditions = false;
        this.disableSubmitBtn = true;
    }
    mergeRegAddRecords() {
        let objmix = Object.assign({}, this.registrationRec, this.soldToAddress); //Merging registration and address data
        this.record = objmix;
        this.showLoader = false;
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
    getQueryParams() {
        var params = {};
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }
    /*************Country Dropdown Functionality - Below*******************/

    @wire(fetchCountryList, {
        countryCode: '$countryCode',
        source: '$source'
    }) countryConfig({
        error,
        data
    }) {
        if (data) {
           // //console.log('Header Data*******', data[1]);
            this.picklistCountryOptions = data[0];
            //console.log('picklistCountryOptions*******', data[0]);
            var customerTypeConfig = data[1];
            this.customerTypeConfig = customerTypeConfig;
           
            //console.log('Header customerTypeConfig*******', this.customerTypeConfig);
            //console.log('this.countryCode.toUpperCase()::: ',this.countryCode.toUpperCase());
            this.basicInfoLabel = this.country == 'CA' ? AGN_OAM_information_for_communication : AGN_OAM_Basic_Information; 

            if(this.countryCode.toUpperCase() !== 'CA'){
                this.populateCustomerCategoryDropDown(this.countryCode, customerTypeConfig);
            }else{
                 //console.log('picklistProvienceOptions*******', data[2]);
                 this.isProvience = true;
                 
                 this.populateCustomerCategoryDropDownCA(this.countryCode, data[2]);
            }
            this.showLoader = false;
        } else if (error) {
            //console.log('error on header component>>>>>>>', error);
            this.showLoader = false;
        }
    }

    countryChangeHandler(event) {
        const field = event.target.name;
        //console.log('field>>>>>>>>>>>>>>>>>', field);
        //console.log(event);
        //console.log('event.target.value>>>>>>>>>>>', event.target.value);
        var newlst = [];
        if (field === 'countrySelect') {
            var selected = event.target.value;
            //var lang = this.language;
            //console.log('selected value>>>>', selected);
            this.selectedCountry = selected;
            //console.log('selected country>>>>', this.selectedCountry);
            //console.log('selected language>>>>', this.language);
            this.customerTypeConfig.forEach(function (currRow) {


                if (selected.toUpperCase() === AGN_OAM_Country_GB || selected.toUpperCase() === AGN_OAM_Country_IE) {
                    if (currRow.Customer_Country_AGN__r.Name.toUpperCase() === selected.toUpperCase()) {
                        if (newlst.map(function (e) {
                                return e.key;
                                e.val;
                            }).indexOf(currRow.Category_AGN__c, currRow.Category_Label_AGN__c) < 0) {
                            newlst.push({
                                key: currRow.Category_AGN__c,
                                val: currRow.Category_Label_AGN__c
                            });
                        }
                    }
                } else {
                    if (currRow.Country_Code_AGN__c.toUpperCase() === selected.toUpperCase()) {
                        if (newlst.map(function (e) {
                                return e.key;
                                e.val;
                            }).indexOf(currRow.Category_AGN__c, currRow.Category_Label_AGN__c) < 0) {
                            newlst.push({
                                key: currRow.Category_AGN__c,
                                val: currRow.Category_Label_AGN__c
                            });
                        }
                    }
                }


            });

            newlst.sort();
            this.picklistCustomerTypeOptions = newlst;

        }
    }

    provienceChangeHandler(event){
        this.picklistCustomerTypeOptions = [];
        this.showLoader = true;
        var selected = event.target.value;
        this.selectedProvience = selected;
        var country = this.selectedCountry;
        //this.showStep1 = false;
        var lang = this.language;
        var sourceVal = this.source;
        //console.log('this.country::'+this.country);
        //console.log('this.selectedProvience::'+this.selectedProvience);
        
         var countrysfobj = this.getCountrySFCode(this.country);

        let address = {
            'sobjectType': 'Allergan_Customer_Address_AGN__c'
        };
		 let registration = {
            'sobjectType': 'Allergan_Customer_Registration_AGN__c'
        };
		
		address.State_AGN__c = this.country.toUpperCase() + '-' + this.selectedProvience;
		address.Country_AGN__c = countrysfobj.countryName;
		let objmix = Object.assign({}, registration, address); //Merging registration and address data
		this.record = objmix;
        //console.log('this.record:::: ',this.record);

        if (selected) {
            var newlst = [];
			this.customerTypeConfig.forEach(function (currRow) {
			
                var categoryLableValue = '';
                if (sourceVal === 'cs') { //AGN_OAM_CS
                    categoryLableValue = currRow.Category_AGN__c;
                } else {
                    lang = lang ? lang : LANG;
                    categoryLableValue = (lang && lang.toUpperCase() == 'EN_CA') ? currRow.Category_AGN__c : currRow.Category_Label_AGN__c;
                }
                
				if(currRow.Province_AGN__c && currRow.Province_AGN__c.includes(selected.toUpperCase())){                        
					if(newlst.map(function(e){return e.key; e.val;}).indexOf(currRow.Category_AGN__c,currRow.Category_Label_AGN__c)<0){ 
						
                        if(lang && lang === 'fr_CA' ){
							newlst.push({key:currRow.Category_AGN__c, val:categoryLableValue}); 
						} else{
							newlst.push({key:currRow.Category_AGN__c, val:categoryLableValue}); 
						}                            
					} 
				}
            });
			newlst.sort();
			this.picklistCustomerTypeOptions = newlst;
            this.showLoader = false;
            //console.log('this.picklistCustomerTypeOptions::CA::::', newlst);
			
        } else {
            this.showLoader = false;
            this.picklistCustomerTypeOptions = [];
        }


    }

    populateCustomerCategoryDropDownCA(country, provienceList){
        var newlst = [];
        var lang = this.language;
        this.selectedCountry = country;
        var sourceVal = this.source;        
        if(provienceList){
            provienceList.forEach(function (currRow) {
                var provienceLabelValue = '';
                if (sourceVal === 'cs') { //AGN_OAM_CS
                    provienceLabelValue = currRow.MasterLabel;
                } else {     
                    lang  = lang ? lang : LANG;         
                    provienceLabelValue = (lang && lang.toUpperCase() == 'EN_CA') ? currRow.MasterLabel : currRow.Region_Label_AGN__c;
                }

                if (newlst.map(function (e) {
                            return e.key;
                            e.val;
                        }).indexOf(currRow.MasterLabel, currRow.RegionCode__c) < 0) {
                        newlst.push({
                            key: currRow.RegionCode__c,
                            val: provienceLabelValue
                        });
                    }

            });
            newlst.sort();
            this.picklistProvienceOptions = newlst;
            //console.log('this.picklistProvienceOptions111::::',this.picklistProvienceOptions);
            
        }
    }
    

    populateCustomerCategoryDropDown(country, customerTypeConfig) {
        var newlst = [];
        var selected = country;
        var lang = this.language;
        this.selectedCountry = country;
        var sourceVal = this.source;

        customerTypeConfig.forEach(function (currRow) {
            var categoryLableValue = '';
           if (sourceVal === 'cs') { //AGN_OAM_CS
                categoryLableValue = currRow.Category_AGN__c;
            } else {                
                categoryLableValue = currRow.Category_Label_AGN__c;
            }

           // categoryLableValue = currRow.Category_Label_AGN__c;

            /*
            Canada related code - for Provice Picklist
            if(currRow.Province_AGN__c && currRow.Province_AGN__c.includes(selected.toUpperCase())){                        
                if(newlst.map(function(e){return e.key; e.val;}).indexOf(currRow.Category_AGN__c,currRow.Category_Label_AGN__c)<0){ 
                    if(lang && lang === 'fr_CA' ){
                        newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_Label_AGN__c}); 
                    } else{
                        newlst.push({key:currRow.Category_AGN__c, val:currRow.Category_AGN__c}); 
                    }                            
                } 
            }*/
			 selected = selected.toUpperCase() == 'AU' ? 'AN' : selected;
            if (selected.toUpperCase() === AGN_OAM_Country_GB || selected.toUpperCase() === AGN_OAM_Country_IE || selected.toUpperCase() === 'AN' || selected.toUpperCase() === 'NZ' ) {
                if (currRow.Customer_Country_AGN__r.Name.toUpperCase() === selected.toUpperCase()) {

                    if (newlst.map(function (e) {
                            return e.key;
                            e.val;
                        }).indexOf(currRow.Category_AGN__c, currRow.Category_Label_AGN__c) < 0) {
                        newlst.push({
                            key: currRow.Category_AGN__c,
                            val: categoryLableValue
                        });
                    }
                }
            } else {
                if (currRow.Country_Code_AGN__c.toUpperCase() === selected.toUpperCase()) {
                    if (newlst.map(function (e) {
                            return e.key;
                            e.val;
                        }).indexOf(currRow.Category_AGN__c, currRow.Category_Label_AGN__c) < 0) {
                        newlst.push({
                            key: currRow.Category_AGN__c,
                            val: categoryLableValue
                        });
                    }
                }
            }

        });

        newlst.sort();
        this.picklistCustomerTypeOptions = newlst;
    }

    customerCategoryChangeHandler(event) {
        this.showLoader = true;     
        //console.log('selected value>>>>', event.target.value);       
        this.showStep1 = false;
        this.picklistSubTypeOptions = [];
        var selected = event.target.value;
        var lang = this.language;
        var country = this.selectedCountry;
        var provience = this.selectedProvience;
        this.selectedCustomerCategory = selected;
        var sourceVal = this.source;
        //console.log('selected value>>>>', this.selectedCustomerCategory);
        //console.log('provience value>>>>', provience);
        //console.log('country value>>>>', country);
        if (selected) {
            var newlst = [];

            this.customerTypeConfig.forEach(function (currRow) {
                var subCategoryLableValue = '';
                if (sourceVal === 'cs') { //AGN_OAM_CS
                    subCategoryLableValue = currRow.Cust_Group_Desc_AGN__c;
                } else {
                    lang = lang ? lang : LANG;
                    subCategoryLableValue = (lang && lang.toUpperCase() == 'EN_CA') ? currRow.Sub_Category__c : currRow.Sub_Category_Label_AGN__c;
                }
                // subCategoryLableValue = currRow.Sub_Category_Label_AGN__c;
                if(country.toUpperCase() == 'CA'){
                    if(currRow.Province_AGN__c && currRow.Category_AGN__c.toUpperCase() === selected.toUpperCase() && currRow.Province_AGN__c.includes(provience.toUpperCase())){
                        if (newlst.map(function(e) { return e.key; e.val;}).indexOf(currRow.Sub_Category__c) <0){ // duplicate remove 
                           newlst.push({key:currRow.Sub_Category__c, val:subCategoryLableValue}); 
                        }
                    }
                }else if (currRow.Category_AGN__c.toUpperCase() === selected.toUpperCase()) {
                    if (newlst.map(function (e) {
                            return e.key;
                        }).indexOf(currRow.Sub_Category__c) < 0) { // duplicate remove
                        if (country === AGN_OAM_Country_GB || country === AGN_OAM_Country_IE) {
                            if (currRow.Customer_Country_AGN__r.Name === country) {
                                newlst.push({
                                    key: currRow.Sub_Category__c,
                                    val: subCategoryLableValue
                                });
                            }
                        } else {
                            newlst.push({
                                key: currRow.Sub_Category__c,
                                val: subCategoryLableValue
                            });
                        }
                    }
                }
            });
            newlst.sort();
            //console.log('sub category list>>>>>>>>>>>>>>>', newlst);
            this.picklistSubTypeOptions = newlst;
            this.showLoader = false;
        } else {
            this.showLoader = false;
            this.showStep1 = false;
            this.picklistSubTypeOptions = [];
        }
        
    }

    customerSubCategoryChangeHandler(event) {
        this.productIntSection = false;
        this.showLoader = true;
        const field = event.target.name;
        //console.log('event.target.value>>>>>>>>>>>', event.target.value);
        var selected = event.target.value;
        this.selectedCustomerSubCategory = selected;
        var country = this.selectedCountry;
        country = country.toUpperCase() == 'AN' ? 'AU' : country;
        //console.log('country>>>>>>>>>>>', country);
        this.getLayoutForInternational(country, this.selectedCustomerCategory,
            this.selectedCustomerSubCategory, this.customerTypeConfig);
        if (selected) {
            this.showStep1 = true;
        } else {
            this.showStep1 = false;
        }
    }

    getLayoutForInternational(countryCode, customerType, customerSubType, customerTypeConfig) {
        //console.log('countryCode:::: ', countryCode);
        //console.log('customerType:::: ', customerType);
        //console.log('customerSubType:::: ', customerSubType);
        //console.log('customerTypeConfig:::: ', customerTypeConfig);
        //console.log('this.source ', this.source);
        if (countryCode === "IT11") {
            getLayout({
                    country: countryCode,
                    stepNo: '1',
                    source: this.source
                })
                .then(result => {                  
                    //console.log('setLayoutFields>>>>>>>>>>>>>>>>>>',result);
                    this.layoutMetadataMaster = result;
                    this.setLayoutFields(result);
                  
                })
                .catch(error => {
                    //console.log('error IT Layout>>>>>>>>>>>>>>>>>>>', error);
                    this.error = error;
                });
        } else {

            getLayout({
                    country: countryCode,
                    stepNo: '1',
                    customerType: customerType,
                    customerSubType: customerSubType,
                    custTypeConfig: customerTypeConfig,
                    source: this.source
                })
                .then(result => {
                    this.layoutMetadataMaster = result;
                    //console.log('setLayoutFields>>>>>>>>>>>>>>>>>>',result);
                    //this.setLayoutFields(result); 
                    this.getAllFieldsMetadata(result);

                })
                .catch(error => {
                    console.log('error layout>>>>>>>>>>>>>>>>>>>' + JSON.stringify(error));
                    this.error = error;   
                    this.showToast('error',JSON.stringify(error) ,'error');   
                });
        }

    }

    setLayoutFields(data) {
        this.productIntSection = false;
        var settings = [];
        var settingsMap = data;
        var allBasicInformationFields = [];
        var basicInformationFields = [];
        var productInterestFields = [];
		var allpracticeAddressFields = [];    	
        var brazilPostalCodeFields = [];
        var practiceAddressFields = [];
        var productofinterest ;
        var contactFields = [];
        var allcontactFields=[]; //Added for PT
        var allFieldList = []; //Added for PT
        //console.log('settingsMap>>>>>>>>>>>>>>>>>>', settingsMap);
        for (var key in settingsMap) {
            if (key == 'Basic information') { 
                allBasicInformationFields  = settingsMap[key];
            } else if (key === 'Address') {
                allpracticeAddressFields = settingsMap[key];
            } else if (key === 'Communication Contact') {
                allcontactFields = settingsMap[key];
            }  
        }

        //Added for PT 
        //allFieldsDescribeMap conatins the key in format 'fieldName=SobjectName' with Sobject Field describe result as value
        //this.getAllFieldsMetadata(allFieldList); 

       // this.basicInformationFields = basicInformationFields;
        this.practiceAddressFields = practiceAddressFields;
        this.contactFields = contactFields; 
        
        allBasicInformationFields.forEach(info1 =>{
            //Added for PT
            //cloning the variable to add new fieldDescribe attribute to the metadata record for sending it to common input child component
            var newFieldValue = Object.assign({}, info1, {fieldDescribe:this.allFieldsDescribeMap.get(info1.Field_Name_AGN__c+'='+info1.SObject_Name_AGN__c)})

            if(newFieldValue.Field_Name_AGN__c=="Product_Interest_AGN__c"){              
                productofinterest = newFieldValue;
                productInterestFields.push(newFieldValue);
                this.productIntSection = true;
            }
            else {
                basicInformationFields.push(newFieldValue);
            } 
            //console.log('allBasicInformationFields-fieldvalue:::::', JSON.stringify(newFieldValue));          
        });
		
		let countryCode = this.selectedCountry;	
        allpracticeAddressFields.forEach(info1 =>{            
            //added new fieldDescribe attribute to the metadata record for sending it to common input child component         
            var newFieldValue = Object.assign({}, info1, {fieldDescribe:this.allFieldsDescribeMap.get(info1.Field_Name_AGN__c+'='+info1.SObject_Name_AGN__c)})

            if(newFieldValue.Field_Name_AGN__c=="Zip_AGN__c" && countryCode.toUpperCase() =='BR'){	              	
                productofinterest = newFieldValue;	
                brazilPostalCodeFields.push(newFieldValue);	
                //console.log('brazilPostalCodeFields>>>', brazilPostalCodeFields);	
                this.isPostalCodeBR = true;	
                this.isBRAddressDisable = this.isBrZipCodeValue ? false : true;	
            }	
            else{	
                practiceAddressFields.push(newFieldValue);	
            }

        });
        allcontactFields.forEach(cfield =>{
            //added new fieldDescribe attribute to the metadata record for sending it to common input child component 
            var newFieldValue = Object.assign({}, cfield, {fieldDescribe:this.allFieldsDescribeMap.get(cfield.Field_Name_AGN__c+'='+cfield.SObject_Name_AGN__c)})

            if(newFieldValue.Field_Name_AGN__c=="Email_AGN__c" && newFieldValue.SObject_Name_AGN__c=="Allergan_Customer_Registration_AGN__c"){
                this.isEmailReqdOnLoad=newFieldValue.Required_AGN__c;
                //console.log("newfeature>>>>>",this.isEmailReqdOnLoad, newFieldValue.Required_AGN__c);
            }
            contactFields.push(newFieldValue);	//Added for PT
        });
        this.basicInformationFields = basicInformationFields;
        this.productInterestFields =  productInterestFields;
		this.practiceAddressFields = practiceAddressFields;	
        this.brazilPostalCodeFields = brazilPostalCodeFields;	
        this.contactFields = contactFields;

        this.showLoader = false;
        if(this.source ==='oam'){
            let cmp = this.template.querySelector('.tncchkbox');
            cmp.checked = false;  
            fetchFooterConsents({
                langCode: this.langCode
            }).then(result => {
                //console.log('result33>>>>'+ JSON.stringify(result));
                result.forEach(element =>{
                    //console.log('varTxt>>>>'+element);
                    if(element.Name=='Terms of Use')
                      {
                        this.textTNC  = element.Footer_RichText_c__c;
                        //console.log('textTNC>>>>'+ this.textTNC);
                      }
    
                });                            
            })
            .catch(error => {
                console.log('tnc error');
            });
        }       

    }

    //Added for PT 
    getAllFieldsMetadata(result){

        var allFieldList = [];
        for (var key in this.layoutMetadataMaster) {
            var fieldDetails = this.layoutMetadataMaster[key].map(field => { 
                return {sobjectName: field.SObject_Name_AGN__c,
                        fieldName : field.Field_Name_AGN__c,
                        controllingFieldValue : field.Controlling_Field_AGN__c};
            });
            allFieldList = [...allFieldList, ...fieldDetails];
        }
        //console.log('inside PT | fieldListToBeCached ::' , JSON.stringify(allFieldList));
        getAllFieldsMetadata({
            fieldListJson: JSON.stringify(allFieldList)
        })
        .then(data => {
            //console.log('Response-data:::::', JSON.stringify(data));
            data.forEach(field => {
                this.allFieldsDescribeMap.set(field.name+'='+field.sobjectName,field);
            })
            //promise chaining has been done to make it synchronus. being called from  from here instead of  getLayoutForInternational method
            this.setLayoutFields(result);  
        })
        .catch(error =>{
            console.log('Error fetching All Metadata :::::', error);
        })
    }

    handleEnableDirectAccess(event){
        const eventParemeters = event.detail;
        const templateIndex = eventParemeters.index;
        const templateobjecttype = eventParemeters.objecttype;
        const templateinstancetype = eventParemeters.instancetype;
        const templatevalue = eventParemeters.checkedVal;
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
            if (element.fieldname === 'Email_AGN__c' &&
                element.sobjectname === 'Allergan_Customer_Registration_AGN__c' &&
                !this.isEmailReqdOnLoad) {
                //console.log('Checking the dependent List>>');
                //element.removeInputValue();
                element.setRequired(templatevalue);
            }
        });

    }
    handleClick() {   
   
    let formatIssuefieldList = [];
    let labelMap = getCustomLable();

    //console.log('this.iscaptchavalid1>>>'+ this.iscaptchavalid);
    if(this.source ==="oam"){
      //this.iscaptchavalid = false;
      this.template.querySelector('iframe').contentWindow.postMessage({ action: "alohaCallingCAPTCHA" , alohaResponseCAPTCHA : "OK"  }, this.baseurl);                  
      if(this.country != 'BR'){
         let cmp = this.template.querySelector('.tncchkbox');
         if(!cmp.checked){           
                this.showToast('error', AGN_OAM_Accept_TnC ,'error')
                return;
         } 
      }
      
    }
    else{
        this.iscaptchavalid = true;
    }
    //console.log('this.iscaptchavalid2>>>'+ this.iscaptchavalid);
         this.showLoader = true;
        //this.hidemaindiv = true;
        var allValid = true;
        var isFormatValid = true;
        let address = {
            'sobjectType': 'Allergan_Customer_Address_AGN__c'
        };
        let soldToAddr = this.soldToAddress;
        if(soldToAddr && soldToAddr.Id) address.Id = soldToAddr.Id;
       /* for (let key in soldToAddr) {
            if (soldToAddr.hasOwnProperty(key) && key !== 'sobjectType') {
                address[key] = soldToAddr[key];
            }
        } */
        let registration = {
            'sobjectType': 'Allergan_Customer_Registration_AGN__c'
        };
        if (this.registrationRec && this.registrationRec.Id) registration.Id = this.registrationRec.Id;
        
        /*let regRecord = this.registrationRec;
        for (let key in regRecord) {
            if (regRecord.hasOwnProperty(key) && key !== 'sobjectType') {
                registration[key] = regRecord[key];
            }
        } */
        let crContact = {
            'sobjectType': 'Allergan_Customer_Contact_AGN__c'
        };
        let crContactObj = this.acrContact;
        for (let key in crContactObj) {
            if (crContactObj.hasOwnProperty(key) && key !== 'sobjectType') {
                crContact[key] = crContactObj[key];
            }
        }
        let caseCr = {
            'sobjectType': 'Case'
        };
        let crCaseObj = this.caseRecord;
        for (let key in crCaseObj) {
            if (crCaseObj.hasOwnProperty(key) && key !== 'sobjectType') {
                caseCr[key] = crCaseObj[key];
            }
        }
        caseCr.Id = this.caseId;
        var country = this.countryCode;
        var countryCodeVal = '';
        if (this.country && this.country === 'IE') {
            //this.countryCode = 'GB';
			countryCodeVal = 'GB';
            this.sapCountryCode = 'IE';
        } else if(this.country && (this.country === 'AN' || this.country === 'NZ' || this.country === 'AU')){
            //this.countryCode = 'AN';
			countryCodeVal = 'AN';
            this.sapCountryCode = this.country === 'NZ' ? 'NZ': 'AU';
        } else {
            //this.countryCode = this.country;
			countryCodeVal = this.country;
            this.sapCountryCode = this.country;
        }
        registration.Customer_Category_AGN__c = this.selectedCustomerCategory;
        registration.Customer_Sub_Category_AGN__c = this.selectedCustomerSubCategory;
        registration.Country_Code_AGN__c = countryCodeVal;
        registration.SAP_Country_Code_AGN__c = this.sapCountryCode;
        
        var countrysfobj = this.getCountrySFCode(this.sapCountryCode);
        //console.log('sapCountryCode>>>>>>>>>>>>>>>>>>>>>>>>', this.sapCountryCode);
        //console.log('countrysfobj>>>>>>>>>>>>>>>>>>>>>>>>', countrysfobj);
        if(this.source == 'oam'){
            registration.Allergan_Direct_Access_Requested_AGN__c = true;            
        }
        let countryName = address.Country_AGN__c;
        if (countryName) {
            address.Country_AGN__c = countryName;
        } else {
            address.Country_AGN__c = countrysfobj.countryName;
        }
        if (countrysfobj) {
            registration.Country_AGN__c = countrysfobj.countrySFDCId;
            address.Country_Lookup_AGN__c = countrysfobj.countrySFDCId;

        }

        if(this.selectedProvience){
            registration.Province_AGN__c = this.selectedProvience;
            let state =  this.country.toUpperCase() + '-' + this.selectedProvience;
            address.State_AGN__c = state;
        }

        /* 	CoolSculpting  Start*/
        if (this.accountId) {
            address.Account_AGN__c = this.accountId;
        }
        /* 	CoolSculpting  End*/

        var hasFormatIssues = false;
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
            //console.log('field>>>>>>>>>>>>' + element.fieldname + '>>>>>>>value>>>>>>>>>>>>>>>>>>>>', element.getUserEnteredInput() + '>>>element.checkValidity()>>>>' + element.checkValidity());
             // //console.log('required>>>>>>>>>>>>>>', element.required);
            //  //console.log('sobject>>>>>>>>>>>>>>>>>>>>', element.sobjectname);
            //  //console.log('fieldname>>>>>>>>>>>>>>>>>>>>', element.fieldname);
            if (element.isActiveField() || (!element.isActiveField() && !element.fieldValue)) {
                isFormatValid = element.isFormatValid();               
                if (isFormatValid) {                   
                    if(element.checkValidity()){
                        let enteredVal = element.getUserEnteredInput();
                       // //console.log("enteredVal>>>>"+ enteredVal);                   
                        if (element.sobjectname === 'Allergan_Customer_Registration_AGN__c') {
                            registration[element.fieldname] = enteredVal;
                        } else if (element.sobjectname === 'Allergan_Customer_Address_AGN__c') {
                            address[element.fieldname] = enteredVal;
                        }
                        element.setCustomErrorMessage('');
                    }   
                    else {
                        allValid = false;
                    }                

                } else{
                    //console.log('Format Error>>>>Setting Message>>>>');
                    let errorMessage =  AGN_OAM_Body_PleaseCheckFormatFor+ ' '+ labelMap.get(element.customlabel);
                    element.setCustomErrorMessage(errorMessage); 
                    formatIssuefieldList.push(labelMap.get(element.customlabel));                       
                    hasFormatIssues = true;
                }
            }

        });
        //console.log('allValid>>>>>>>>', allValid);
        //console.log('Registration>>>>>>>>>>>>>>>', registration);
        //console.log('Address>>>>>>>>>>>>>>>>>>>>', address);        
        //console.log('caseCr>>>>>>>>>>>>>>>>>>>>', caseCr);
        //console.log('formatIssuefieldList>>>>>>>'+formatIssuefieldList);
        if (allValid && !hasFormatIssues) {          
            if(this.iscaptchavalid)
            {
           
            //console.log('calling isduplicate user>>>>>>>>>>>>>>>');
            var userLocale = this.language;
            if (this.source === 'cs') { //AGN_OAM_CS
                let contactRecord = {
                    'sobjectType': 'Contact'
                };
                this.invokeCreateCustomerRegistrationForCS(address, registration, this.customerTypeConfig, contactRecord, caseCr, crContact, userLocale, country);
            }
            else{
                isDuplicateUser({
                    email: registration.Email_AGN__c,
                    country: country
                })
                .then(result => {
                    //console.log('isDuplicateUser>>>>>>>>>', result);
                    if (result) {                      
                        this.showLoader = false;
                        this.showToast('error', AGN_OAM_Apex_DuplicateEmail,'error');
                        this.hidemaindiv = false;
                    } else {
                        this.invokeCreateAccount(address, registration, country);
                    }

                })
                .catch(error => {
                    console.log(error);
                    this.error = error;
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.error = error;    
                    this.showToast('error', JSON.stringify(error),'error');
                });
            }

            

            }
             else{
             this.showLoader = false;
             this.hidemaindiv = false;
             this.error = AGN_OAM_Captcha_Error;    
             this.showToast('error', AGN_OAM_Captcha_Error, 'error'); 
             }
        } 
        else if(!allValid){
            this.showLoader = false;
            this.hidemaindiv = false;
            this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
        }
        else if(hasFormatIssues){
            //console.log('formatIssuefieldList1>>>>>>>'+formatIssuefieldList);
            this.showLoader = false;
            this.hidemaindiv = false;
           // this.error = AGN_OAM_Invalid_Input;  
            if(formatIssuefieldList.length>0) {
                this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
            }
            else{
                this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
            }

        }
        else{
            this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
        }      

    }
    invokeCreateAccount(address, registration, country) {
        /* //console.log('country>>>>>>>>>>>>>>>', country);
         //console.log('address>>>>>>>>>>>>>>>', address);
         //console.log('registration>>>>>>>>>>>>>>>', registration); */
        //console.log('Account creation');
        createAccount({
                customerAddress: address,
                customer: registration,
                country: country
            })
            .then(result => {
                if (result) {
                    this.account = result;
                    //console.log('New Account Created>>>>>>>>>', result);
                    this.invokeCreateContact(address, registration, result, country);
                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('error', AGN_OAM_Unknown_Err,'error');
                }


            })
            .catch(error => {
                console.log(error);
                
                this.showLoader = false;
                this.hidemaindiv = false; 
                this.showToast('error', JSON.stringify(error),'error'); 
            });
    }

    invokeCreateContact(address, registration, account, country) {
        //console.log('inside invokeCreateContact>>>>>>>', address, registration, account, country);
        createContact({
                customer: registration,
                acc: account,
                country: country
            })
            .then(result => {
                if (result) {
                    this.contact = result;
                    //console.log('New Contact Created>>>>>>>>>', result);
                    this.invokecreateCommunityUser(address, result, country, registration);
                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('error', AGN_OAM_Unknown_Err,'error');
                }

            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error', JSON.stringify(error),'error');
            });
    }

    invokecreateCommunityUser(address, customerContact, country, registration) {
        var userLocale = this.language;
        //console.log('user locale ::::', userLocale);
        createCommunityUser({
                customerContactId: customerContact.Id,
                countryCode: country,
                userLocale: userLocale
            })
            .then(result => {
                if (result) {
                    this.contact = result;
                    //console.log('New Community User Created>>>>>>>>>', result);
                    this.invokeCreateCustomerRegistration(address, registration, this.customerTypeConfig, customerContact, userLocale, country);

                    //this.invokeCreateOktaUserSendLink(registration, customerContact, userLocale, country);

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('error', AGN_OAM_Unknown_Err,'error');
                }

            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error', JSON.stringify(error),'error');
            });
    }

    invokeCreateCustomerRegistration(address, registration, configList, customerContact, userLocale, country) {

        //console.log('**********New Customer Registration************');
        /* //console.log('customerAddress>>>>>>>>>>>>>>>>', address);
         //console.log('configList>>>>>>>>>>>>>>>>', configList);
         //console.log('customerContact>>>>>>>>>>>>>>>>', customerContact);
         //console.log('userLocale>>>>>>>>>>>>>>>>', userLocale); */
        //console.log('Coountry::::: ' + country);
        if(this.source == 'oam'){
            address.Is_Update_Bussiness_Account_AGN__c = true;
        }
        
        createNewCustomerRegistration({
                customer: registration,
                customerAddress: address,
                configList: configList,
                customerContact: customerContact,
                userLocale: userLocale
            })
            .then(result => {
                if (result) {
                    //console.log('New Customer Registration Created>>>>>>>>>', result);
                    this.invokeCreateOktaUserSendLink(registration, customerContact, userLocale, country);

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('error', JSON.stringify(error),'error');
                }

            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error', JSON.stringify(error),'error');
            });
    }
    invokeCreateCustomerRegistrationForCS(address, registration, configList, customerContact, casenewCr, acrContact,  userLocale, country) {

        //console.log('**********New Customer Registration CS************');
        /* //console.log('customerAddress>>>>>>>>>>>>>>>>', address);
         //console.log('configList>>>>>>>>>>>>>>>>', configList);
         //console.log('customerContact>>>>>>>>>>>>>>>>', customerContact);*/
        //console.log('userLocale>>>>>>>>>>>>>>>>', userLocale);
        if(this.caseId)
        {
            registration.Case_AGN__c = this.caseId;
        }
        //console.log('registration222>>>>>>>>>>>>>>>>', registration);
        createNewCustomerRegistrationCS({
                customer: registration,
                customerAddress: address,
                configList: configList,
                customerContact: customerContact,
                caseCr: casenewCr,
                acrContact: acrContact,
                userLocale: country
            })
            .then(result => {
                if (result) {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    //console.log('New Customer Registration Created>>>>>>>>>', result);
                    this.RegistrationStepNo = '2';
                    this.caseId = result;                    
                    this.nextOrPreviousActionEvent(result, '2');

                } else {
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.showToast('error', AGN_OAM_Unknown_Err,'error');
                }

            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error', JSON.stringify(error),'error');
            });
    }
    nextOrPreviousActionEvent(caseId, stepNo) {
         const selectEvent = new CustomEvent('stepinfoevent',  {
            detail: {
                caseId: caseId,
                stepNo: stepNo
            }           
         });
         this.dispatchEvent(selectEvent);
     }
    invokeCreateOktaUserSendLink(registration, customerContact, userLocale, country) {

        //console.log('**********New Okta User Creation************');
        /*//console.log('registration>>>>>>>>>>>>>>>>', registration);
        //console.log('customerContact>>>>>>>>>>>>>>>>', customerContact);
        //console.log('userLocale>>>>>>>>>>>>>>>>', userLocale);
        //console.log('country>>>>>>>>>>>>>>>>', country); */
        createOktaUserSendLink({
                customer: registration,
                customerContact: customerContact,
                userLocale: userLocale,
                country: country
            })
            .then(result => {
                //console.log('New Okta User Created>>>>>>>>>', result);
                switch (result) {
                    case 'SUCCESS':
                        this.isCompleted = true;
                        break;
                    case 'FAILURE':
                        this.showToast('error', AGN_OAM_Contact_Service,'error');
                        break;
                    case 'DEPROVISIONED':
                        this.showToast('error', AGN_OAM_Inactive_State,'error');
                        break;
                    default:
                        this.showToast('error', AGN_OAM_Unknown_Err,'error');
                        break;
                }
                this.showLoader = false;
                this.hidemaindiv = false;                
                this.hidemaindiv = false;

            })
            .catch(error => {
                console.log(error);
                this.error = error;
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error', JSON.stringify(error),'error');
            });
    }

    getCountrySFCode(country) {
        var countryobj;
        country = country.toUpperCase() == 'AU' ? 'AN' : country;
       // //console.log('picklistCountryOptions>>>'+JSON.stringify(this.picklistCountryOptions));
       // //console.log('country-getCountrySFCode>>>'+JSON.stringify(country));
        this.picklistCountryOptions.forEach(function (currRow) {
           // //console.log('currRow>>>'+JSON.stringify(currRow));
            if (currRow.Alpha_2_Code_vod__c.toUpperCase() === country.toUpperCase()) {
                countryobj = {
                    'countrySFDCId': currRow.Id,
                    'countryName': currRow.AGN_Country_Name__c 
                };
            }
        });
        return countryobj;
    }


    showToastSticky(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(event);
    }

    showToast(title , message , variant) {
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

    checkboxHandler(event) {
        //console.log('event.target.checked>>>>>>>>>>>>>', event.target.checked);
        let fieldname = event.target.name;
        let checked = event.target.checked;
        if (fieldname === 'termsncondns') {
            if (checked) {
                this.disableSubmitBtn = false;
            } else {
                this.disableSubmitBtn = true;
            }
        }
    }

    handleControllingFieldEvent(event) {

        this.showLoader = true;
        this.hidemaindiv = true;
        //console.log('this.showLoader>>>>'+this.showLoader);   
        const eventParemeters = event.detail;
        const controllingFieldSobjectName = eventParemeters.controllingFieldSobjectName;
       //console.log("eventParemeters -----3-> " + eventParemeters);
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
           // //console.log('layoutMetadataMaster[key]>>' + JSON.stringify(this.layoutMetadataMaster[key]));
            let dependentField = this.layoutMetadataMaster[key].find(layout => {
                //console.log('layout>>' + JSON.stringify(layout));
                if (layout.Controlling_Field_AGN__c == controllingFieldName && layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName ) {
                    //console.log('itr>>' + itr);
                    itr++;
                    dependentFieldList.push(layout);
                    //return layout;

                }
            });
        });

        if (dependentFieldList.length > 0) {
            dependentFieldList.forEach(field => {
                this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                    if (element.fieldname === field.Field_Name_AGN__c && element.sobjectname === field.SObject_Name_AGN__c) {
                        if (field.Dependent_Field_Show_Criteria_AGN__c && field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
                       // && typeof controllingFieldSelectedValue != "undefined" && typeof controllingFieldSelectedValue != null && typeof controllingFieldSelectedValue != '') {
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
	
	//Brazil Zip Code Validation code goes here
	handleZipCodeValueChange(event){	
        //this.showLoader = true;	
        //this.hidemaindiv = true;	
        let labelMap = getCustomLable();        	
        const eventParemeters = event.detail;	
        const sobjectName = eventParemeters.sobjectName;	
        const fieldName = eventParemeters.fieldName;	
        const zipValue = eventParemeters.value;	
        const instancetype = eventParemeters.instancetype;	
        const objecttype = eventParemeters.objecttype;	
        const index = eventParemeters.index;	
        const sapid = eventParemeters.sapid;	
        const isFormatvalid = eventParemeters.isFormatvalid;	
        //console.log('eventParemeters::::: ',zipValue, '::::'+ isFormatvalid);	
        /*let errorMessage;	
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {	
            if(element.sobjectname === sobjectName && element.fieldname === fieldName  && !isFormatvalid){	
                errorMessage =  AGN_OAM_Body_PleaseCheckFormatFor+ ' '+ labelMap.get(element.customlabel);	
                element.setCustomErrorMessage(errorMessage);	
            }	
        });	
        if(!isFormatvalid && errorMessage){	
            this.showToast('error', errorMessage,'error');	
            this.hidemaindiv = false;	
            this.showLoader = false;   	
            return;	
        }*/	
         if(zipValue && isFormatvalid){	
             this.showLoader = true;            	
             getAddressInformation({	
                    cepCode: zipValue	
                })	
                .then(result => {                  	
                    //console.log('Result Zipcode Related Address>>>>>>>>>>>>>>>>>>',result); 	
                    let addressInfo = result;	
                    if (this.practiceAddressFields.length > 0) {          	
            	
                        //customerAddress.State_AGN__c = customer.SAP_Country_Code_AGN__c+'-'+cepDetail.state;	
                        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {	
                                if (element.sobjectname === sobjectName) {	
                                	
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
                    }  	
                    	
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
        let controllingFieldSelectedValue = controlingfieldData.controllingFieldSelectedValue;
        const templateIndex = controlingfieldData.index;
        const templateobjecttype = controlingfieldData.objecttype;
        let dependentFieldList = [];
        var itr = 1;
        Object.keys(layoutMetadataMaster).forEach(key => {
            let dependentField = this.layoutMetadataMaster[key].find(layout => {
                if (layout.Controlling_Field_AGN__c == controllingFieldName && layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName){ 
					//&& typeof controllingFieldSelectedValue != "undefined" && typeof controllingFieldSelectedValue != null && typeof controllingFieldSelectedValue != '') {
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
                    if (element.fieldname === field.Field_Name_AGN__c && element.sobjectname === field.SObject_Name_AGN__c) {
                        //console.log('fieldname111111>>',field.Field_Name_AGN__c);
                        //console.log('Dependent_Field_Show_Criteria_AGN__c11111>>',field.Dependent_Field_Show_Criteria_AGN__c);
                        //console.log('controllingVal11111>>>>>',controllingFieldSelectedValue);
                        //console.log('l11111>>>>>',field.Dependent_Field_Show_Criteria_AGN__c.includes('false'));
                        
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