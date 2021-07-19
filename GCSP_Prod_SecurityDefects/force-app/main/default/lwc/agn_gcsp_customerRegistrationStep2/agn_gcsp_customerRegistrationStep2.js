/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on: 06-10-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-20-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement , track , wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchCountryList from  '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.fetchCountryList';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getLayout';
import getCustomerRegDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetails';
import getCustomerRegDetailsCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS';
import getCustomerAddressDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails';
import upsertRegistrationDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.upsertRegistrationDetails';
import deleteAddress from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.deleteAddress';
import getGCSPSettings from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings';
import getAddressInformation from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getAddressInformation';
import { loadStyle } from 'lightning/platformResourceLoader';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

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
import AGN_OAM_Next from '@salesforce/label/c.AGN_OAM_Next';
import AGN_OAM_Previous from '@salesforce/label/c.AGN_OAM_Previous';
import AGN_OAM_Body_Agree from '@salesforce/label/c.AGN_OAM_Body_Agree';	
import AGN_OAM_Body_TermsConditions from '@salesforce/label/c.AGN_OAM_Body_TermsConditions';	
import AGN_OAM_Body_Ok from '@salesforce/label/c.AGN_OAM_Body_Ok';	
import AGN_OAM_Body_Cancel from '@salesforce/label/c.AGN_OAM_Body_Cancel';	
import AGN_OAM_Body_ClickOkToAgree from '@salesforce/label/c.AGN_OAM_Body_ClickOkToAgree';	
import AGN_OAM_TermsConditions_Link from '@salesforce/label/c.AGN_OAM_TermsConditions_Link';

import AGN_OAM_Basic_Information_Heading from '@salesforce/label/c.AGN_OAM_Basic_Information_Heading';
import AGN_OAM_Address_Details_Heading from '@salesforce/label/c.AGN_OAM_Address_Details_Heading';
import AGN_OAM_Document_Upload_Heading from '@salesforce/label/c.AGN_OAM_Document_Upload_Heading';
import AGN_OAM_Confirmation_Heading from '@salesforce/label/c.AGN_OAM_Confirmation_Heading';
import AGN_OAM_Contact_Affiliation from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_Header_CustomerRegistration from '@salesforce/label/c.AGN_OAM_Header_CustomerRegistration';
import AGN_OAM_AdditionalShippingHelpTxt from '@salesforce/label/c.AGN_OAM_AdditionalShippingHelpTxt';
import AGN_OAM_NewShippingAddresses from '@salesforce/label/c.AGN_OAM_NewShippingAddresses';

import AGN_Article_23_declaration from '@salesforce/label/c.AGN_Article_23_declaration';
import AGN_Article_23_Text from '@salesforce/label/c.AGN_Article_23_Text';
import AGN_Article_23_Text_2 from '@salesforce/label/c.AGN_Article_23_Text_2';
import AGN_Article23_Relevant_Yes from '@salesforce/label/c.AGN_Article23_Relevant_Yes';
import AGN_Article23_Relevant_NO from '@salesforce/label/c.AGN_Article23_Relevant_NO';
import AGN_IE_falsifiedURL from '@salesforce/label/c.AGN_IE_falsifiedURL';
import AGN_DE_falsifiedURL from '@salesforce/label/c.AGN_DE_falsifiedURL';
import AGN_ArticleDeclaration_Heading from '@salesforce/label/c.AGN_ArticleDeclaration_Heading';
import AGN_ArticleDeclaration1 from '@salesforce/label/c.AGN_ArticleDeclaration1';
import AGN_ArticleDeclaration2 from '@salesforce/label/c.AGN_ArticleDeclaration2';
import AGN_ArticleDeclaration3 from '@salesforce/label/c.AGN_ArticleDeclaration3';
import AGN_ArticleDeclaration4 from '@salesforce/label/c.AGN_ArticleDeclaration4';
import AGN_ArticleDeclaration5 from '@salesforce/label/c.AGN_ArticleDeclaration5';
import AGN_ArticleDeclaration6 from '@salesforce/label/c.AGN_ArticleDeclaration6';
import AGN_ArticleDeclarationLabel from '@salesforce/label/c.AGN_ArticleDeclarationLabel';
import AGN_ArticleSupportedSubCategoryFR from '@salesforce/label/c.AGN_ArticleSupportedSubCategoryFR';
import AGN_ArticleSupportedSubCategoryRequiredFR from '@salesforce/label/c.AGN_ArticleSupportedSubCategoryRequiredFR';
import AGN_OAM_Required_Fields_Missing_Error from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';

import AGN_OAM_Body_Province from '@salesforce/label/c.AGN_OAM_Body_Province';

import AGN_GCSP_STEP1 from '@salesforce/label/c.AGN_GCSP_STEP1';
import AGN_GCSP_STEP2 from '@salesforce/label/c.AGN_GCSP_STEP2';
import AGN_GCSP_STEP3  from '@salesforce/label/c.AGN_GCSP_STEP3';
import AGN_GCSP_STEP4 from '@salesforce/label/c.AGN_GCSP_STEP4';
import AGN_GCSP_STEP5  from '@salesforce/label/c.AGN_GCSP_STEP5';
import AGN_OAM_AdditionalShipTo_Mandatory  from '@salesforce/label/c.AGN_OAM_AdditionalShipTo_Mandatory';
import AGN_OAM_Body_PleaseCheckFormatFor  from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Accept_TnC  from '@salesforce/label/c.AGN_OAM_Accept_TnC';


import LANG from '@salesforce/i18n/lang';
import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';

export default class Agn_gcsp_customerRegistrationStep2 extends NavigationMixin(LightningElement) {
    @track countryCode;
    @track country;
    @track language;
    @track registration;
    @track picklistCountryOptions;
    @track customerTypeConfig;
    @track custRegId;
    soldToAddr;
    billToAddr = []; 
    shipToAddr = [];
    @track soldToAddressFields = [];
    @track billToAddressFields = [];
    @track shipToAddressFields = [];
    @track customerType;
    @track customerSubType;
    @track shippingMap = [];
    @track shippingMapCounter = 0;
    @track showNewShipto = false;
    @api stepNo;
    @track showLoader;
    @track hidemaindiv;
    @track showModal;
    @track shipToSameAsSoldTo;
    @track article23ConsentValue;
    @track shiptoLimit = 0;
    @track disableSoldToFields = true;
    @track isnext = false;
    @track showNewShiptoButton = false;
	@api source;
    @api sourceOAM;
    @api sourceCS;
    @api caseId;
    @api RegistrationStepNo;
    @api isOnlineRegistration;
    @track isCS = false;
    @track enableShipTo = false;
    @track variant ='error';
    error;
    @track oneShipToRequired = false;
	@track ShowTermsAndConditions;		
    @track isTNCAccepted =false;
	@track isCountryBR = false;

    @track IsAddShipByDefault = false;
    
    @track showArticle23Declaration = false;
    custypeshow;
    cusSubtypeshow;
    isArticleFR;
    formatedURL;
    customerGroup;
    @track layoutMetadataMaster;
    isExistingShipToAddr = false;
    isProvience;
    provienceShow;
    header_css1;
    header_css2;
    header_css3;

    @track hasRendered=false;
    label = {
        
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
        AGN_OAM_Next,
        AGN_OAM_Previous,
        AGN_OAM_Basic_Information_Heading,
        AGN_OAM_Address_Details_Heading,
        AGN_OAM_Document_Upload_Heading,
        AGN_OAM_Confirmation_Heading,
        AGN_OAM_Contact_Affiliation,
        AGN_OAM_Header_CustomerRegistration,
        AGN_OAM_AdditionalShippingHelpTxt,
        AGN_GCSP_STEP1,
        AGN_GCSP_STEP2,
        AGN_GCSP_STEP3,
        AGN_GCSP_STEP4,
        AGN_GCSP_STEP5,
        AGN_OAM_NewShippingAddresses,
        AGN_OAM_AdditionalShipTo_Mandatory,
        AGN_Article23_Relevant_NO,
		AGN_Article23_Relevant_Yes,
        AGN_Article_23_declaration,
        AGN_Article_23_Text,
        AGN_Article_23_Text_2,
        AGN_IE_falsifiedURL,
		AGN_DE_falsifiedURL,
		AGN_ArticleDeclaration_Heading,
		AGN_ArticleDeclaration1,
		AGN_ArticleDeclaration2,
		AGN_ArticleDeclaration3,
		AGN_ArticleDeclaration4,
		AGN_ArticleDeclaration5,
		AGN_ArticleDeclaration6,	
		AGN_ArticleDeclarationLabel,
		AGN_ArticleSupportedSubCategoryFR,
		AGN_ArticleSupportedSubCategoryRequiredFR,
		AGN_OAM_Body_Agree,	
        AGN_OAM_Body_TermsConditions,	
        AGN_OAM_Body_Ok,	
        AGN_OAM_Body_Cancel,	
        AGN_OAM_Body_ClickOkToAgree,	
        AGN_OAM_TermsConditions_Link

    };

    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');
        this.header_css1 = this.country == 'CA' ? 'slds-form-element scope1_ca' : 'slds-form-element scope1';
        this.header_css2 = this.country == 'CA' ? 'slds-form-element scope2_ca' : 'slds-form-element scope2';
        this.header_css3 = this.country == 'CA' ? 'slds-form-element scope3_ca' : 'slds-form-element scope3'; 
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

    

    nextOrPreviousActionEvent(caseId, stepNo) {
        const selectEvent = new CustomEvent('stepinfoevent',  { detail : {
            caseId: caseId,
            stepNo: stepNo
           }
        });
        this.dispatchEvent(selectEvent);
    }
    get options() {	
        return [
            { label: AGN_Article23_Relevant_Yes, value: AGN_Article23_Relevant_Yes},
            { label: AGN_Article23_Relevant_NO, value: AGN_Article23_Relevant_NO},
        ];
    }
    connectedCallback(){
        this.showLoader = true;
        this.hidemaindiv = true;

         this.source = (this.sourceOAM) ? this.sourceOAM : (this.sourceCS) ? this.sourceCS :'';
         this.isOnlineRegistration = (this.sourceOAM) ? true : false;
    
		if( this.source == AGN_OAM_CS){            
			this.getCustomerRegistrationDetailsCS();
            this.isCS = true;
		}
		else{
			this.getCustomerRegistrationDetails();
        } 
		
        this.shippingMap = [];
        this.language = this.language ? this.language : LANG;
        this.showModal = false;
        //this.showHideDependentField();
    }

    getCustomerRegistrationDetails(){
        getCustomerRegDetails()
        .then(result => {
            //console.log('Registration Response :: ',result);
            if(result){
                let registration = { 'sobjectType': 'Allergan_Customer_Registration_AGN__c' };
                this.registration = result;
                this.language = result.Language_AGN__c;
                var countryCode = result.SAP_Country_Code_AGN__c;
                if(!countryCode){
                    countryCode = result.Country_Code_AGN__c;
                }
                this.country = countryCode;
                //console.log("country>>>>>>>>>", this.country);                  
                if(this.country.toUpperCase() == 'CA'){
                    this.isProvience = true;
                    this.provienceShow = result.Province_AGN__c;
                }
		        if(this.country == 'BR' && this.source=='oam'){
			        this.isCountryBR=true;
		        }
                this.customerGroup = result.Customer_Group_AGN__c;
                 //console.log('Customer Group>>>>>>>>>>>>',result.Customer_Group_AGN__c);
                if(this.country === 'DE' || this.country === 'IE' && this.source === 'oam')
                {
                    this.showArticle23Declaration = true;
                }
                else if(this.country === 'FR' && (this.customerGroup == 'SP' || this.customerGroup == 'RH' || this.customerGroup == 'R'
                || this.customerGroup == 'BK') && this.source === 'oam')
                {
                this.isArticleFR = true;
                }
                
                if(countryCode.toUpperCase() == 'IE'){
                    this.formatedURL = AGN_IE_falsifiedURL;
                }else if( countryCode.toUpperCase() == 'DE'){
                    this.formatedURL = AGN_DE_falsifiedURL;
                }  
                this.customerType = result.Customer_Category_AGN__c;
                this.customerSubType = result.Customer_Sub_Category_AGN__c;

                this.custypeshow = this.customerType;
                this.cusSubtypeshow = this.customerSubType;
                //console.log('Step No>>>>>>>>>>>>',result.Online_Registration_Step_AGN__c);
                // eslint-disable-next-line radix
                let currentStepNo = parseInt(result.Online_Registration_Step_AGN__c);
                if(currentStepNo && currentStepNo >4){
                  this.navigateToLink('customer-registration-step4');
                }else{
                    this.stepNo = 2;
                    this.getAddressDetails(result , countryCode);
                }
                
            }else{
                this.showLoader = false;
                this.hidemaindiv = false;
                this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in Registration :: ',error);
            this.setErrorMessage(error , '');
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }
	getCustomerRegistrationDetailsCS(){
        getCustomerRegDetailsCS({ caseRecId: this.caseId})
        .then(result => {
            //console.log('Registration Response :: ',result);
            if(result){
                let registration = { 'sobjectType': 'Allergan_Customer_Registration_AGN__c' };
                this.registration = result;
                var countryCode = result.SAP_Country_Code_AGN__c;
                if(!countryCode){
                    countryCode = result.Country_Code_AGN__c;
                }
                this.country = countryCode;
                this.customerType = result.Customer_Category_AGN__c;
                this.customerSubType = result.Customer_Sub_Category_AGN__c;
                this.custypeshow = this.customerType;
                this.cusSubtypeshow = this.customerSubType;

                if(this.country.toUpperCase() == 'CA'){
                    this.isProvience = true;
                    this.provienceShow = result.Province_AGN__c;
                }
                //console.log('Step No>>>>>>>>>>>>',result.Online_Registration_Step_AGN__c);
                // eslint-disable-next-line radix
                let currentStepNo = parseInt(result.Online_Registration_Step_AGN__c);
                if(currentStepNo && currentStepNo >4){
                  this.navigateToLink('customer-registration-step4');
                }else{
                    this.stepNo = 2;
                    this.getAddressDetails(result , countryCode);
                }
                
            }else{
                this.showLoader = false;
                this.hidemaindiv = false;
                this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in Registration :: ',error);
            this.setErrorMessage(error , '');
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }

    

    getAddressDetails(registration , countryCode ){
             
        getCustomerAddressDetails({custRegId : registration.Id})
            .then(data => {
                if (data) {
                    //console.log("Address Response Callout :: ", data);
                    var soldToAddr;
                    var billToAddr = [];
                    var shipToAddr = [];
                    var addressList = data;
                    for (var i in addressList) {
                      if (addressList[i].Sold_To_AGN__c) {
                        //only 1 SoldTo Address will be present
                        soldToAddr = addressList[i];
                        let yes = AGN_Article23_Relevant_Yes;
                        let no = AGN_Article23_Relevant_NO;
                        this.article23ConsentValue = soldToAddr.KB23_Article_AGN__c?yes:no;	
                        this.shipToSameAsSoldTo = addressList[i].Ship_To_AGN__c; //will set true/false
                        this.billToSameAsSoldTo = addressList[i].Bill_To_AGN__c; //will set true/false
                      }
                      if (addressList[i].Ship_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                        //Multiple ShipTo Address will be present
                        shipToAddr.push(addressList[i]);
                        this.isExistingShipToAddr = true;
                      }
                      if (addressList[i].Bill_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                        //Multiple BillTo Address will be present
                        billToAddr.push(addressList[i]);
                      }
                    }
                    //console.log('soldToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',soldToAddr);
                    //console.log('billToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',billToAddr);
                    //console.log('shipToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',shipToAddr);
                    this.soldToAddr = soldToAddr;
                    this.billToAddr = billToAddr;
                    this.shipToAddr = shipToAddr;
                    this.getGCSPCustomSettings(registration , countryCode);
                    
                  }else{
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    this.setErrorMessage('' , 'Unknown Error');
                }
            })
            .catch(error => {
                console.log('Error in Address Callout :: ',error);
                this.setErrorMessage(error , '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }

    getGCSPCustomSettings(registration , countryCode){
        getGCSPSettings({country : countryCode})
        .then(result => {
            if(result){
                //console.log('Custom Settings Data Response :: ',result);
                let shiptoLimit = (this.source == 'oam') ? parseInt(result.Number_Of_ShipTo_Allowed_AGN__c) : parseInt(result.Number_Of_ShipTo_Allowed_CS_AGN__c);
                let shiptolen = this.getShiptoLength();
                if(shiptoLimit){
                    if(shiptolen <= shiptoLimit){
                        this.showNewShiptoButton = true;
                     }else{
                         this.showNewShiptoButton = false;
                     }
                     this.shiptoLimit = shiptoLimit;
                }
                
                this.getConfigurations(registration, countryCode);
            }else{
                this.showLoader = false;
                this.hidemaindiv = false;
                this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in GCSP Settings Callout :: ',error);
            this.setErrorMessage(error , '');
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }
       
    getConfigurations(registration , countryCode){
        fetchCountryList({
                          countryCode : countryCode,
                          source : this.source})
        .then(result => {
            if(result){
                //console.log('Configuration Data Response :: ',result);
                this.picklistCountryOptions = result[0];
                this.customerTypeConfig = result[1];
                this.invokeGetLayout(registration, countryCode , result[1]);
                this.showLoader = false;
                this.hidemaindiv = false;
                this.customerTypeConfig.forEach(confg=>{                        

                       if (this.source === 'cs') { //AGN_OAM_CS   
                            if((this.customerType.toUpperCase()===confg.Category_AGN__c.toUpperCase()) && (confg.Sub_Category__c.toUpperCase() === this.customerSubType.toUpperCase()) ) {                  
                                this.custypeshow = confg.Category_AGN__c;
                                this.cusSubtypeshow = confg.Cust_Group_Desc_AGN__c;
                            }
                       } 
                       else {                       
                            if((this.customerType.toUpperCase()===confg.Category_AGN__c.toUpperCase()) && (confg.Sub_Category__c.toUpperCase() === this.customerSubType.toUpperCase()) ) {                  
                               let lang = this.language ? this.language.toUpperCase() : '';
                                if(lang && lang.includes('EN')){
                                    this.custypeshow = confg.Category_AGN__c;
                                    this.cusSubtypeshow =  confg.Sub_Category__c;
                                }else{
                                    this.custypeshow = confg.Category_Label_AGN__c;
                                    this.cusSubtypeshow =  confg.Sub_Category_Label_AGN__c;
                                }
                                
                            }
                       }
                      
                       
                });

            }else{
                this.showLoader = false;
                this.hidemaindiv = false;
                this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in Configuration Callout :: ',error);
            this.setErrorMessage(error , '');
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }


    invokeGetLayout(registration , countryCode , customerTypeConfig) {
        //console.log('invokeGetLayout>>>>>>>>>>>>>>>', countryCode,registration,customerTypeConfig,this.stepNo);
        if(countryCode === 'FFF'){
            getLayout({
                country: countryCode,
                stepNo: this.stepNo,
                source: this.source
            })
            .then(result => {
                this.setLayoutFields(result);
                this.layoutMetadataMaster = result;
                
            })
            .catch(error => {
                console.log('Error In Layout calllout :: ',error);
                this.setErrorMessage(error , '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
        }else{
            getLayout({country: countryCode , 
                      stepNo: this.stepNo , 
                      customerType: registration.Customer_Category_AGN__c , 
                      customerSubType:registration.Customer_Sub_Category_AGN__c ,
                      custTypeConfig: customerTypeConfig,
                      source: this.source
                      })
            .then(result => {
                //console.log('Layout Response :: ',result);
                this.setLayoutFields(result);
                this.layoutMetadataMaster = result;
            })
            .catch(error => {
                console.log('Error In Layout calllout :: ',error);
                this.setErrorMessage(error , '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
        }
        
    }

    setLayoutFields(data){
        var settings = [];
        settings = data;
        var settingsMap = settings;
        var soldToAddressFields = [];
        var billToAddressFields = [];
        var shipToAddressFields = [];
        //console.log('settingsMap>>>>>>>>>>>>>>>>>>',settingsMap);
        for(var key in settingsMap){
            //console.log('key>>>>>>>',key);
            //console.log('value>>>>>>>',settingsMap[key]);
             if (key === 'Registered Address') { //AGN_OAM_Body_RegisteredAddress
                 soldToAddressFields = settingsMap[key];
             } else if (key === 'Shipping Address') { //AGN_OAM_Shipping_Address
                 shipToAddressFields = settingsMap[key];
             } else if (key === 'Billing Address') { //AGN_OAM_Biling_Address
                 billToAddressFields = settingsMap[key];
             }
        }
        this.soldToAddressFields = soldToAddressFields;
        this.shipToAddressFields = shipToAddressFields;
        this.billToAddressFields = billToAddressFields;
        if(this.country =='ES' || this.country =='BR'){
            this.setButtonConfiguration();
        }
        else {
            this.enableShipTo = true;
        }
       
       
        //console.log('soldToAddressFields>>>>>>>>>>>>>>>>>>',soldToAddressFields);
        //console.log('shipToAddressFields>>>>>>>>>>>>>>>>>>',shipToAddressFields);
        //console.log('billToAddressFields>>>>>>>>>>>>>>>>>>',billToAddressFields);
    }
    setButtonConfiguration(){

        let custConfig = this.customerTypeConfig;   
        let configCategoryValue;
        let configSubCategoryValue
        if(custConfig)
        {
            custConfig.forEach(confg=>{  

                if (this.source === 'cs') { //AGN_OAM_CS
                    configCategoryValue = confg.Category_AGN__c;
                    configSubCategoryValue = confg.Sub_Category__c;
                } else {
                    configCategoryValue = confg.Category_Label_AGN__c;
                    configSubCategoryValue = confg.Sub_Category_Label_AGN__c;
                }

                //this.custypeshow = configCategoryValue;
                //this.cusSubtypeshow =configSubCategoryValue;

                //console.log('this.customertype>>>',this.customerType);  
                //console.log('this.customersubtype>>>',this.customerSubType);  
                //console.log('confg.Product_Interest_AGN__c >>>',confg.Additional_Shipping_Address_Required_AGN__c );  
                //console.log('confg.Category_AGN__c>>>',confg.Category_AGN__c);  
                //console.log('confg.Category_Label_AGN__c>>>',confg.Category_Label_AGN__c);  
                //console.log('confg.Sub_Category__c>>>',confg.Sub_Category__c); 
                //console.log('confg.Customer_Country_AGN__r.Name>>>',confg.Customer_Country_AGN__r.Name); 
                //console.log('confg.Sub_Category_Label_AGN__c>>>',confg.Sub_Category_Label_AGN__c); 
                //console.log('this.countrycode>>>',this.country);
        
           
                if(this.customerType && this.customerSubType && (confg.Category_AGN__c.toUpperCase() === this.customerType.toUpperCase() || confg.Category_Label_AGN__c.toUpperCase() === this.customerType.toUpperCase())
                && (confg.Sub_Category__c.toUpperCase() === this.customerSubType.toUpperCase() || confg.Sub_Category_Label_AGN__c.toUpperCase() === this.customerSubType.toUpperCase())
                && confg.Customer_Country_AGN__r.Name === this.country)
                {
                   this.enableShipTo = confg.Additional_Shipping_Address_Required_AGN__c;
                   if(this.country =='ES'){ 
                       this.oneShipToRequired = confg.Additional_Shipping_Address_Required_AGN__c;
                       //console.log('this.oneShipToRequired>>>'+ this.oneShipToRequired);
                   } 
                   if(confg.Additional_Shipping_Address_Required_AGN__c){
                        this.shipToSameAsSoldTo = confg.Additional_Shipping_Address_Required_AGN__c;
                   }                   
                   this.IsAddShipByDefault  = this.shipToSameAsSoldTo;
                }
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

    handlePrevious() { 
        
        
        if (this.source == 'cs') {
            /*  this.RegistrationStepNo = '2';
              //this.caseId = result;
              const regStepNoEvent = new FlowAttributeChangeEvent('RegistrationStepNo', this.RegistrationStepNo);
              const caseIdEvent = new FlowAttributeChangeEvent('caseId', this.caseId);
  
              this.dispatchEvent(regStepNoEvent);
              this.dispatchEvent(caseIdEvent);
  
              const nextNavigationEvent = new FlowNavigationNextEvent();
              this.dispatchEvent(nextNavigationEvent);*/
              this.nextOrPreviousActionEvent(this.caseId, '1');
          }
          if(this.source=='oam'){
              this.navigateToLink('customer-registration-step1');
          }
        /*this.RegistrationStepNo = '1';
        //this.caseId = result;
        const regStepNoEvent = new FlowAttributeChangeEvent('RegistrationStepNo', this.RegistrationStepNo);
        const caseIdEvent = new FlowAttributeChangeEvent('caseId', this.caseId);

        this.dispatchEvent(regStepNoEvent);
        this.dispatchEvent(caseIdEvent);

        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);*/

    }

    handleNext(){
		//Brazil Policy Link Checkbox
		if(this.country === 'BR' && this.source=='oam'){
			let cmp = this.template.querySelector('.tncchkbox');		
			if(cmp.checked!==true)	
				this.showToast('error',AGN_OAM_Accept_TnC,'error');	
			else{	
				let self = this;	
				self.isnext = true;	
				self.handleClick('next');	
			}
		}
		else{
            let self = this;
            self.isnext = true;
            self.handleClick('next');
        }        
    }

    handleSave(){
		//Brazil Policy Link Checkbox
		if(this.country === 'BR' && this.source=='oam'){
			let cmp = this.template.querySelector('.tncchkbox');	
			if(cmp.checked!==true)	
				this.showToast('error',AGN_OAM_Accept_TnC,'error');	
			else{	
				this.handleClick('save');	
			}
		}
        else{
            this.handleClick('save');
        }
    }

    handleClick(actionType){
        let labelMap = getCustomLable();
        let formatIssuefieldList = [];
        //console.log('inside handleclick>>>>>>>>>>>>>>>>>>>');
        //this.hidemaindiv = true;
        this.showLoader = true;
        var allValid = true;
        var isFormatValid = true;
        //this.billToAddr = billToAddr;
        //this.shipToAddr = shipToAddr;
        var soldToAddRec = this.soldToAddr;
        //console.log('inside handleclick1>>>>>>>>>>>>>>>>>>>');
        var soldToAddr = {
            'sobjectType': 'Allergan_Customer_Address_AGN__c'
        };
        //console.log('inside handleclick2>>>>>>>>>>>>>>>>>>>');
        var newBillToAddrList = [];
        var newShipToAddrList = [];
        var billToAddrList = [];
        var shipToAddrList = [];
        var hasFormatIssues = false;
        var newShiptoMap = new Map();
        let shiptomap = new Map();
        //let requiredMissing = false;
        var soldToId = soldToAddRec.Id; 
        let yes = AGN_Article23_Relevant_Yes;
		let no = AGN_Article23_Relevant_NO;
        if(this.article23ConsentValue.toUpperCase() == yes.toUpperCase())
        {
            soldToAddr.KB23_Article_AGN__c = true;
        }
        else if(this.article23ConsentValue.toUpperCase() == no.toUpperCase())
        {
            soldToAddr.KB23_Article_AGN__c = false;
        }
        //console.log('inside handleclick3>>>>>>>>>>>>>>>>>>>');       
          billToAddrList = this.billToAddr;
        //  //console.log('inside handleclick4>>>>>>>>>>>>>>>>>>>');
         // shipToAddrList = this.shipToAddr;
         if (this.shipToAddr) {
             this.shipToAddr.forEach(function (ship) {
                 if (ship.Id !== soldToId) {
                     shiptomap.set(ship.Id, ship);
                 }
             });
         }

         //console.log('inside handleclick5>>>>>>>>>>>>>>>>>>>', this.shipToAddr);
         /* if(billToAddrList.length >0){
            billToAddrList.forEach(function (bill){
                if(bill.Id !== soldToId){
                    bill.Bill_To_AGN__c = true;
                    bill.Sold_To_AGN__c = false;
                    bill.Ship_To_AGN__c = false;
                }
            });
        }
        
          //console.log('shipToAddrList>>>>>>>>>>>>>>>>>>>'+JSON.stringify(shipToAddrList));
          //console.log('billToAddrList>>>>>>>>>>>>>>>>>>>'+JSON.stringify(billToAddrList));
          //console.log('soldToId>>>>>>>>>>>>>>>>>>>'+ soldToId);
         //shipToAddr 
         /* if(shipToAddrList.length > 0){
            shipToAddrList.forEach( ship => {
                let shipObj = {
                    'sobjectType': 'Allergan_Customer_Address_AGN__c'
                };
                shipObj = ship;
                //console.log('ship>>>>>>>>>>>>>>>>>>>'+ shipObj.Id);
                //console.log('Bill_To_AGN__c>>>>>>>>>>>>>>>>>>>'+ shipObj.Bill_To_AGN__c);
                //console.log('Sold_To_AGN__c>>>>>>>>>>>>>>>>>>>'+ shipObj.Sold_To_AGN__c);
                //console.log('Ship_To_AGN__c>>>>>>>>>>>>>>>>>>>'+ shipObj.Ship_To_AGN__c);
                //console.log('soldToId>>>>>>>>>>>>>>>>>>>'+ soldToId);
               
                if(soldToId && shipObj.Id && shipObj.Id !== soldToId){
                    //console.log('ship33333>>>>>>>>>>>>>>>>>>>');
                    shipObj['Bill_To_AGN__c'] = 'false';
                    //shipObj.Sold_To_AGN__c = false;
                    //shipObj.Ship_To_AGN__c = true;
                    //console.log('ship2>>>>>>>>>>>>>>>>>>>'+ JSON.stringify(shipObj));
                }
                shiptomap.set(shipObj.Id , shipObj);
            });          
          }*/
          //console.log('inside handleclick7>>>>>>>>>>>>>>>>>>>');
        //console.log('newShiptoList>>>>>>>>>>>>>>>>>',newShipToAddrList);
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
              /*  if(!isFormatValid){                   
                }else{                    
                }   */       
                if (element.isActiveField() || (!element.isActiveField() && !element.fieldValue)) {
                    let enteredVal = element.getUserEnteredInput();
                    let isFormatValid1 = element.isFormatValid();
                    //console.log('value>>>>>>>>>>>>>>>>>>>>',enteredVal);               
                    //console.log('isFormatValid>>>>>>>>>>>>>>>>>>>>',isFormatValid1);
                    //console.log(`element.checkValidity()>>>>>>>>>>>>>>>>>>>>${element.checkValidity1()}`);
                    
                    if(isFormatValid1){                       
                        if(element.checkValidity1()){
                             if(element.sobjectname === 'Allergan_Customer_Address_AGN__c'){
                                 if(element.objecttype === 'soldto'){
                                     soldToAddr[element.fieldname] = enteredVal;
                                 }else if(element.objecttype === 'shipto' && element.instancetype === 'new'){
                                     
                                     //console.log('has index>>>>>>>>>>>>>>>',newShiptoMap.has(element.index));
                                     if(newShiptoMap.has(element.index)){
                                         newShiptoMap.get(element.index)[element.fieldname] = enteredVal;
                                     }else{
                                         let newShiptoAddress = { 'sobjectType': 'Allergan_Customer_Address_AGN__c' };
                                         newShiptoAddress[element.fieldname] = enteredVal;
                                         newShiptoMap.set(element.index , newShiptoAddress);
                                     }
                                     
                                 }else if(element.objecttype === 'shipto' && element.instancetype === 'old'){
                                     var recordId = element.record.Id;
                                     //console.log('recordId>>>>>>>>>>>>>>>>>',recordId);
                                     //console.log('Value11>>>>>>>>>>>>>>>>>',enteredVal);
                                     //console.log('shiptomap11>>>>>>>>>>>>>>>>>',shiptomap);
                                     if(shiptomap.has(recordId)){
                                         shiptomap.get(recordId)[element.fieldname] = enteredVal;
                                     }
                                 }
                             }
                             element.setCustomErrorMessage('');
                        }
                        else{
                            allValid = false;
                        }                                  
                     }else{
                        let errorMessage = AGN_OAM_Body_PleaseCheckFormatFor+' : '+ labelMap.get(element.customlabel);
                        element.setCustomErrorMessage(errorMessage);
                        formatIssuefieldList.push(labelMap.get(element.customlabel));
                        hasFormatIssues = true;
                     }                      
                     //console.log('allValid>>>>>>>>>>>>>>>>>>>>',allValid);

                }
            
          });
        
      if (allValid && !hasFormatIssues) {
          //UPSERT DATA CODE HERE
          //console.log('Success - Calling Upsert Method');
          //console.log('shiptomap>>>>' + JSON.stringify(shiptomap));
          soldToAddr.Id = soldToId;
          soldToAddr.Ship_To_AGN__c = this.shipToSameAsSoldTo;
          for (let value of newShiptoMap.values()) {
            newShipToAddrList.push(value)
          }
        for (let value of shiptomap.values()) {
            shipToAddrList.push(value);
        }

          if(newShipToAddrList){
                newShipToAddrList.forEach(function (nship){
                    nship.Bill_To_AGN__c = false;
                    nship.Sold_To_AGN__c = false;
                    nship.Ship_To_AGN__c = true;                    
                });
          }
          if(newBillToAddrList){
            newBillToAddrList.forEach(function (nbill){
                nbill.Bill_To_AGN__c = true;
                nbill.Sold_To_AGN__c = false;
                nbill.Ship_To_AGN__c = false;
            });
          }
          let existingShiptoLen = 0;
          let esShipToLen = 0;
          if(soldToAddr.Ship_To_AGN__c){
            existingShiptoLen ++;

          }
          if(shipToAddrList){
            existingShiptoLen += shipToAddrList.length;
            esShipToLen += shipToAddrList.length
          }
          if(newShipToAddrList){
            esShipToLen += newShipToAddrList.length
            existingShiptoLen += newShipToAddrList.length;
          }

          //console.log('existingShiptoLen::::::::::: ', existingShiptoLen);
          //console.log('this.oneShipToRequired::::::::::: ', this.oneShipToRequired);
          //console.log('soldToAddr.Ship_To_AGN__c ::::::::::: ', soldToAddr.Ship_To_AGN__c );
          //console.log('esShipToLen ::::::::::: ', esShipToLen);
          if((existingShiptoLen > 0 && !this.oneShipToRequired)||( (soldToAddr.Ship_To_AGN__c && esShipToLen >=1 ) && this.oneShipToRequired)){
              //console.log('newShipToAddrList::::::::::: ', newShipToAddrList);
              //console.log('this.registration::::::::::: ', this.registration);
              //console.log('billToAddrList::::::::::: ', billToAddrList);
              //console.log('newBillToAddrList::::::::::: ', newBillToAddrList);
              //console.log('shipToAddrList::::::::::: ', shipToAddrList);
              //console.log('customer::::::::::: ', this.registration);
              //console.log('soldToAddr::::::::::: ', soldToAddr);
              upsertRegistrationDetails({soldToAddr: soldToAddr , 
                billToAddrList:billToAddrList , 
                shipToAddrList: shipToAddrList,
                newBillToAddrList: newBillToAddrList,
                newShipToAddrList:newShipToAddrList,
                customer: this.registration,
                actionType : actionType,
                currentStep : '2'})
                .then(result => {
                if(result){
                    //console.log('Success :: Address Upserted',result);
                    this.hidemaindiv = false;
                    this.showLoader = false;
                    
                    if(this.isnext){
                        if (this.source === "cs"){
                            this.RegistrationStepNo = '3';
                            this.caseId = result;
                            //const regStepNoEvent = new FlowAttributeChangeEvent('RegistrationStepNo', this.RegistrationStepNo);
                            //const caseIdEvent = new FlowAttributeChangeEvent('caseId', this.caseId);

                            //this.dispatchEvent(regStepNoEvent);
                            //this.dispatchEvent(caseIdEvent);

                            //const nextNavigationEvent = new FlowNavigationNextEvent();
                            //this.dispatchEvent(nextNavigationEvent);
                            this.nextOrPreviousActionEvent(result, '3');
                        }
                        else{
                            this.navigateToLink('customer-registration-step3');
                        }
                       
                        this.isnext = false;
                    }else{
                        this.reloadAddresses();  
                        this.showToast('success' , AGN_OAM_Successfully_Updated , 'success'); //AGN_CP_ADDRESS_UPDATE_SUCCESS     
                        //window.location.reload(true);                    
                        //this.navigateToLink('customer-registration-step2');    

                    }
                    
                }
                })
                .catch(error => {
                  console.log('Error in Address Upsert :: ',error);
                    this.setErrorMessage(error , '');
                    this.showLoader = false;
                    this.hidemaindiv = false;
                });
            
          }else{
            this.hidemaindiv = false;
            this.showLoader = false;
            if(this.oneShipToRequired){                
                this.showToast('error', AGN_OAM_AdditionalShipTo_Mandatory, 'error');
            }else{
                this.showToast('error', AGN_OAM_ShipTo_Mandatory, 'error');
            }
             //AGN_CP_SHIPTO_MANDATORY_ERROR_MSG
          }        
      }
      //console.log('allValid>>>>>>>>>>>>>>>>>>>>',allValid);
      if(!allValid){
        this.showLoader = false;
        this.hidemaindiv = false;
        this.error = AGN_OAM_Invalid_Input;  
        this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error'); 
        return;       
      }
      if(hasFormatIssues)
      {
        this.showLoader = false;
        this.hidemaindiv = false;
        if(formatIssuefieldList.length>0) {
            this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
        }  
        return;      
      }     
    }

    reloadAddresses(){
        this.showLoader = true;
        this.hidemaindiv = true;
        this.shippingMap = [];
        this.shipToAddr = [];  
        this.shippingMapCounter = 0;
        //this.isExistingShipToAddr= false;
        getCustomerAddressDetails({custRegId : this.registration.Id})
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
                        let yes = AGN_Article23_Relevant_Yes;
                        let no = AGN_Article23_Relevant_NO;
                        this.article23ConsentValue = soldToAddr.KB23_Article_AGN__c?yes:no;	
                        this.shipToSameAsSoldTo = addressList[i].Ship_To_AGN__c; //will set true/false
                        this.billToSameAsSoldTo = addressList[i].Bill_To_AGN__c; //will set true/false
                      }
                      if (addressList[i].Ship_To_AGN__c && !addressList[i].Sold_To_AGN__c) {                        //Multiple ShipTo Address will be present                       
                        
                        shipToAddr.push(addressList[i]);
                      }
                      if (addressList[i].Bill_To_AGN__c && !addressList[i].Sold_To_AGN__c) {
                        //Multiple BillTo Address will be present
                        billToAddr.push(addressList[i]);
                      }
                    }
                    // //console.log('soldToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',soldToAddr);
                    // //console.log('billToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',billToAddr);
                    // //console.log('shipToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',shipToAddr);
                    this.soldToAddr = soldToAddr;
                    this.billToAddr = billToAddr;
                    this.shipToAddr = shipToAddr;
                    this.isExistingShipToAddr = true;
                    this.showLoader = false;
                    this.hidemaindiv = false;
                    //console.log('Calling_renderDependentField_from_relodAddress');                
                    //this.renderDependentField();
                    //this.hasRendered=false;
                  }
            })
            .catch(error => {
                console.log('Error on Address Reload :: ',error);
                this.setErrorMessage(error , '');
                this.showLoader = false;
                this.hidemaindiv = false;
            });
    }

    getShiptoLength(){
        let shiptolen = 0;
        if(this.shipToSameAsSoldTo){
                shiptolen++;
        }
        if(this.shipToAddr.length > 0){
                shiptolen += this.shipToAddr.length;
        }
        if(this.shippingMap.length > 0){
                shiptolen += this.shippingMap.length;
        }
        return shiptolen;
    }

    addNewShipTo(){
        //console.log('inside addNewShipTo>>>>>>>>>>>');
        let shiptoLimit = 0;
        if(this.shiptoLimit){
            shiptoLimit = this.shiptoLimit;
        }
        if(shiptoLimit>0){
            let shiptolen = this.getShiptoLength();
            if(shiptolen <= shiptoLimit){
                let mapKey = AGN_OAM_Shipping_Address + this.shippingMapCounter;
                this.shippingMap.push({key: mapKey, value: this.shipToAddressFields});
                //this.shippingMap.set(mapKey , this.shipToAddressFields);
                this.shippingMapCounter++;
                //console.log('this.shippingMap>>>>>>>>>>>',this.shippingMap);
                //console.log('this.shippingMapCounter>>>>>>>>>>>',this.shippingMapCounter);
                if(this.shippingMapCounter > 0){
                    this.showNewShipto = true;
                }else{
                    this.showNewShipto = false;
                }
            }else{
                //this.showNewShiptoButton = false;
                this.showToast('error' , AGN_OAM_Address_Limit, 'error');
            }
        }else{
            var mapKey = 'Shipping Address' + this.shippingMapCounter;
                this.shippingMap.push({key: mapKey, value: this.shipToAddressFields});
                //this.shippingMap.set(mapKey , this.shipToAddressFields);
                this.shippingMapCounter++;
                //console.log('this.shippingMap>>>>>>>>>>>',this.shippingMap);
                //console.log('this.shippingMapCounter>>>>>>>>>>>',this.shippingMapCounter);
                if(this.shippingMapCounter > 0){
                    this.showNewShipto = true;
                }else{
                    this.showNewShipto = false;
                }
        }

        
        
    }

    deleteShipTo(event){
        this.hidemaindiv = true;
        this.showLoader = true;
        var indx = event.detail.index;
        var instancetype = event.detail.instancetype;
        //console.log('inside delete event handler>>>>>>>>>>>>>>>',indx);
        if(instancetype === "new"){
            if(indx === 0 || indx > 0){
                //console.log('index>>>>>>>>>>>>',indx);
                var shippingMap = this.shippingMap;
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>',shippingMap);
                shippingMap.splice(indx , 1);
                //console.log('shippingMap before delete>>>>>>>>>>>>>>>',shippingMap);
                this.shippingMap = shippingMap;
                this.shippingMapCounter++;
                if(this.shippingMapCounter > 0){
                    this.showNewShipto = true;
                }else{
                    this.showNewShipto = false;
                }
            }
            this.setNewButtonVisibility();
        }if(instancetype === "old"){
           var recordId = event.detail.recordId;
           //console.log('call permanent delete method>>>>>>>',recordId);
          // var shipToAddr = this.shipToAddr;
           //console.log('shippingMap before delete>>>>>>>>>>>>>>>',shippingMap);
           
           this.setNewButtonVisibility();
           let customerAddress = { 'sobjectType': 'Allergan_Customer_Address_AGN__c' , 'Id' : recordId };
           deleteAddress({customerAddress : customerAddress})
           .then(result => {
            this.shipToAddr.splice(indx , 1);
            this.showToast('success' , AGN_OAM_Address_deleted, 'success');
            this.reloadAddresses();  
            this.hidemaindiv = false;
            this.showLoader = false;
                 
           })
           .catch(error => {
               console.log('Error in Address Delete :: ',error);
                this.setErrorMessage(error , '');
                this.hidemaindiv = false;
                this.showLoader = false;
           });
        }
        this.hidemaindiv = false;
        this.showLoader = false;

    }

    setErrorMessage(error , custommsg){
        //console.log('error == ',error);
        if(custommsg){
            this.showToast('error' , AGN_OAM_Contact_Admin+custommsg, 'error');
        }else if(error && error.body && error.body.message){
            this.showToast('error' , AGN_OAM_Contact_Admin+error.body.message, 'error');
        }else{
            this.showToast('error' , AGN_OAM_Unknown_Error, 'error');
        }
        
    }

    setNewButtonVisibility(){
        //set new button visibility
        let shiptoLimit = 0;
        if(this.shiptoLimit){
            shiptoLimit = this.shiptoLimit;
        }
        if(shiptoLimit>0){
            let shiptolen = this.getShiptoLength();
            //console.log('shiptolen>>>>>>>>>>>>',shiptolen);
            //console.log('shiptoLimit>>>>>>>>>>>>',shiptoLimit);
            if(shiptolen <= shiptoLimit){
                this.showNewShiptoButton = true;
            }
        }
    }

    showToast(title , message , variant) {

        if(this.source==='cs')
        {   this.error = message;   
            this.variant = variant;
            //console.log('variant>>>>>>',this.variant);             
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

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.showModal = false;
    }

    deleteAddress(){
   
    }

    checkboxHandler(event){
        //console.log('event.target.checked>>>>>>>>>>>>>',event.target.checked);
        let fieldname = event.target.name;
        let checked = event.target.checked;
        if(fieldname === 'sameassoldto'){
            this.shipToSameAsSoldTo = checked;
           // this.soldToAddr.Ship_To_AGN__c = checked;
        }
        
    }
    radiogroupHandler(event){
        //console.log('event.target.value>>>>>>>>>>>>>',event.target.value);
        let fieldname = event.target.name;
        let value = event.target.value;
        if(fieldname === 'article23Consent'){
            this.article23ConsentValue = value;     
        } 
        if(fieldname === 'article23ConsentFrance'){
            this.article23ConsentValue = value;     
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
         //console.log("controllingFieldSelectedValue ->  " + eventParemeters.objecttype + ' | '+controllingFieldSelectedValue , controllingFieldName);
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
                // //console.log('layout>>' + JSON.stringify(layout));
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
            // //console.log('dependentFieldList>>>' + JSON.stringify(dependentFieldList));
             dependentFieldList.forEach(field => {
                 this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
                     if (element.fieldname === field.Field_Name_AGN__c &&
                         element.sobjectname === field.SObject_Name_AGN__c && element.index == templateIndex  && element.objecttype == templateobjecttype ) {
                         //console.log('Checking the dependent List>>');
                         //element.removeInputValue();
                         //console.log('field.Dependent_Field_Show_Criteria_AGN__c>>'+field.Dependent_Field_Show_Criteria_AGN__c);
                         if (field.Dependent_Field_Show_Criteria_AGN__c && field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
                             element.showCmp();
                             element.setControllingValue(controllingFieldSelectedValue);
                             //console.log('met conditions>>');
                             this.showtest = true;
                             return;
                         } else {
                            //console.log('removing controllingfield>>');
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

    @api
    refreshRegForm(custType,custSubType)
    {
        this.showLoader = true;
        this.hidemaindiv = true;
        //console.log('inside refreshRegForm of reg 1>>>>>'); 
        if( this.source == AGN_OAM_CS){            
			this.getCustomerRegistrationDetailsCS();
		}
		else{
			this.getCustomerRegistrationDetails();
		}   
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