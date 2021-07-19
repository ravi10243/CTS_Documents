/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 06-10-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   02-03-2021   Ravi Sirigiri   Initial Version
**/
import { LightningElement,api , track} from 'lwc';
import LANG from '@salesforce/i18n/lang';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getLayout';
import fetchCountryList from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.fetchCountryList';
import getCustomerRegDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetails';
import getCustomerRegDetailsCS from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS';
import upsertCustomerDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.upsertCustomerDetails';
import getCustomerAddressDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails';

import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';

import getSpecialityDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getSpecialityDetails';
import {
    getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

import AGN_OAM_Loading from '@salesforce/label/c.AGN_OAM_Loading';
import AGN_OAM_Successfully_Updated from '@salesforce/label/c.AGN_OAM_Successfully_Updated';
import AGN_OAM_Previous from '@salesforce/label/c.AGN_OAM_Previous';
import AGN_OAM_Save from '@salesforce/label/c.AGN_OAM_Save';
import AGN_OAM_Next from '@salesforce/label/c.AGN_OAM_Next';

import AGN_GCSP_STEP1 from '@salesforce/label/c.AGN_GCSP_STEP1';
import AGN_GCSP_STEP2 from '@salesforce/label/c.AGN_GCSP_STEP2';
import AGN_GCSP_STEP3  from '@salesforce/label/c.AGN_GCSP_STEP3';
import AGN_GCSP_STEP4 from '@salesforce/label/c.AGN_GCSP_STEP4';
import AGN_GCSP_STEP5  from '@salesforce/label/c.AGN_GCSP_STEP5';
import AGN_OAM_Contact_Affiliation  from '@salesforce/label/c.AGN_OAM_Contact_Affiliation';
import AGN_OAM_Header_CustomerRegistration  from '@salesforce/label/c.AGN_OAM_Header_CustomerRegistration';
import AGN_OAM_Document_Upload_Heading  from '@salesforce/label/c.AGN_OAM_Document_Upload_Heading';
import AGN_OAM_Basic_Information_Heading  from '@salesforce/label/c.AGN_OAM_Basic_Information_Heading';
import AGN_OAM_Address_Details_Heading  from '@salesforce/label/c.AGN_OAM_Address_Details_Heading';
import AGN_OAM_Confirmation_Heading  from '@salesforce/label/c.AGN_OAM_Confirmation_Heading';
import AGN_OAM_TAX_OR_VAT_REQUIRED  from '@salesforce/label/c.AGN_OAM_TAX_OR_VAT_REQUIRED';
import AGN_OAM_DOCS_MANDATORY  from '@salesforce/label/c.AGN_OAM_DOCS_MANDATORY';
import AGN_OAM_Body_PleaseCheckFormatFor  from '@salesforce/label/c.AGN_OAM_Body_PleaseCheckFormatFor';
import AGN_OAM_Required_Fields_Missing_Error  from '@salesforce/label/c.AGN_OAM_Required_Fields_Missing_Error';
import AGN_OAM_RequiredDocument_ErrorMsg  from '@salesforce/label/c.AGN_OAM_RequiredDocument_ErrorMsg';
import AGN_OAM_Contact_Admin  from '@salesforce/label/c.AGN_OAM_Contact_Admin';
import AGN_OAM_Accept_TnC_ANZ  from '@salesforce/label/c.AGN_OAM_Accept_TnC_ANZ';
import AGN_OAM_Body_Declaration  from '@salesforce/label/c.AGN_OAM_Body_Declaration';
import AGN_OAM_NPDeclaration1  from '@salesforce/label/c.AGN_OAM_NPDeclaration1';
import AGN_OAM_NPDeclaration2  from '@salesforce/label/c.AGN_OAM_NPDeclaration2';
import AGN_OAM_NPDeclaration3  from '@salesforce/label/c.AGN_OAM_NPDeclaration3';
import AGN_OAM_NPDeclaration4  from '@salesforce/label/c.AGN_OAM_NPDeclaration4';
import AGN_OAM_MPDeclaration1  from '@salesforce/label/c.AGN_OAM_MPDeclaration1';
import AGN_OAM_MPDeclaration2  from '@salesforce/label/c.AGN_OAM_MPDeclaration2';
import AGN_OAM_MPDeclaration3  from '@salesforce/label/c.AGN_OAM_MPDeclaration3';
import AGN_OAM_NPMP_Accept_the_Terms_and_Conditions  from '@salesforce/label/c.AGN_OAM_NPMP_Accept_the_Terms_and_Conditions';

export default class Agn_gcsp_customerRegDocumentCmp extends NavigationMixin(LightningElement) {

    @api customertype;
    @api customersubtype;
    @api selectedcustregid;    
    @api sapcountrycode;
    @api countrycode;
    @api country;
    @api customertypeconfig;
    @api caseId;

    @api source = null;
    @api sourceOAM = null;
    @api sourceCS = null;
    @api RegistrationStepNo;

    @track fieldloaded = false;
    @track step3fields;    
    @track layoutMetadataMaster;
    @track registration;
    @track stepNo;
    @track showToastMsg=false;
    
  
    @track registrationid;
    @track showupload = false;
    @track isnext = false;

    @track hidemaindiv = false;
    @track showTaxAndVat = false;
    @track showTaxAndVatError = false;
    @track showTaxAndVatErrorMsg;   
    @track toastErrorMsg;
    @track proofodexemption =false;
    @track isCS = false;
    @track variant ='error';
    error;
    @track showLoader = false;
    @track hasRendered=false;
    showuploadCA;
    @track isNursePractitioner = false;
    @track isMPractioner = false;

    supportedDocument;

    label = {
        AGN_OAM_Loading,
        AGN_OAM_Successfully_Updated,
        AGN_OAM_Previous,
        AGN_OAM_Save,
        AGN_GCSP_STEP1,
        AGN_GCSP_STEP2,
        AGN_GCSP_STEP3,
        AGN_GCSP_STEP4,
        AGN_GCSP_STEP5,
        AGN_OAM_Next,
        AGN_OAM_Contact_Affiliation,
        AGN_OAM_Header_CustomerRegistration,
        AGN_OAM_Document_Upload_Heading,
        AGN_OAM_Basic_Information_Heading,
        AGN_OAM_Address_Details_Heading,
        AGN_OAM_Confirmation_Heading, 
        AGN_OAM_TAX_OR_VAT_REQUIRED,
        AGN_OAM_DOCS_MANDATORY,
        AGN_OAM_Contact_Admin,
        AGN_OAM_Accept_TnC_ANZ,
        AGN_OAM_Body_Declaration,
        AGN_OAM_NPDeclaration1,
        AGN_OAM_NPDeclaration2,
        AGN_OAM_NPDeclaration3,
        AGN_OAM_NPDeclaration4,
        AGN_OAM_MPDeclaration1,
        AGN_OAM_MPDeclaration2,
        AGN_OAM_MPDeclaration3,
        AGN_OAM_NPMP_Accept_the_Terms_and_Conditions

    };


    nextOrPreviousActionEvent(caseId, stepNo) {
        const selectEvent = new CustomEvent('stepinfoevent',  { detail : {
            caseId: caseId,
            stepNo: stepNo
           }
        });
        this.dispatchEvent(selectEvent);
    }
    renderedCallback() {
        loadStyle(this, ASSETS + '/assets/agn_gcsp_registration.css');
        loadStyle(this, ASSETS1 + '/css/style.css');   
        loadStyle(this, ASSETS1 + '/css/footer.css');
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

        this.language = LANG;
        this.hidemaindiv = true;
        this.showLoader = true;
        if (this.sourceOAM && this.sourceOAM === 'oam'){
            this.source = this.sourceOAM;
        }
        if (this.sourceCS && this.sourceCS === 'cs') {
            this.source = this.sourceCS;
            this.isCS = true;
        }
        //console.log('inside connected callback of reg 3>>>>>>>>>>>>>>>>>>>>>>>');       
        if( this.source == 'cs'){
			this.getCustomerRegistrationDetailsCS();
		}
		else{
			this.getCustomerRegistrationDetails();
		}   
        //this.fetchCountryList();        
        //this.custTypeConfig = this.customertypeconfig;
        //this.getLayoutForInternational(this.country, this.customertype, this.customersubtype);         
        //String countryCode, String customerType , String customerSubType 
    }

    fetchCountryList(){
       
        fetchCountryList({
                    countryCode: this.country,
                    source: this.source
                })
                .then(result => {
                        var customerTypeConfig = result[1];
                        this.customerTypeConfig = customerTypeConfig;
                       // //console.log('Data*******', JSON.stringify(this.customerTypeConfig)); 
                        this.getLayoutForInternational(this.country, this.customertype, this.customersubtype, this.customerTypeConfig);                   
                })
                .catch(error => {
                    console.log('error IT Layout>>>>>>>>>>>>>>>>>>>', error);
                    this.error = error;
                });
      
    }   

    getCustomerRegistrationDetails(){
        getCustomerRegDetails()
        .then(result => {
            //console.log('Registration Response :: ',result.Id);
            if(result){
                let registration = { 'sobjectType': 'Allergan_Customer_Registration_AGN__c' };
                this.registration = result;
                //console.log('registrationId1>>>>'+ result.Id);
                this.registrationid = result.Id;
                //console.log('registrationxxxx>>>>'+ this.registration);
                this.showupload=true;
                var countryCode = result.SAP_Country_Code_AGN__c;
                if(!countryCode){
                    countryCode = result.Country_Code_AGN__c;
                }
                
                this.country = countryCode;
                this.customerType = result.Customer_Category_AGN__c;
                this.customerSubType = result.Customer_Sub_Category_AGN__c;
                if( ['AU','NZ','AN'].includes(this.country) && this.customerType === "HEALTHCARE PRACTITIONERS"){
                    if(this.customerSubType === "NURSE PRACTITIONER")
                        this.isNursePractitioner = true;
                    else
                        this.isMPractioner = true;
                }
                //console.log('Step No>>>>>>>>>>>>',result.Online_Registration_Step_AGN__c);
                // eslint-disable-next-line radix
                let currentStepNo = parseInt(result.Online_Registration_Step_AGN__c);
                if(currentStepNo && currentStepNo >4){
                   this.navigateToLink('customer-registration-step4');
                }else{
                    this.stepNo = 3;
                    this.getAddressDetails(result , countryCode);
                }
                if(result.Tax_Exempted_AGN__c === '0')
                {
                    this.proofodexemption = true;
                    var supportedDoc = {sobjectname:'Allergan_Customer_Registration_AGN__c', fieldname:'Tax_Exempted_AGN__c', selectedVal:result.Tax_Exempted_AGN__c};
                    this.supportedDocument = supportedDoc;  
                }
                this.showLoader = false;
                this.hidemaindiv = false;
                
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
           // //console.log('Registration Response id :: ',result.Id);
            if(result){
                let registration = { 'sobjectType': 'Allergan_Customer_Registration_AGN__c' };
                this.registration = result;
                 this.registrationid = result.Id;
                 //console.log('registrationId>>>>' + this.registrationid);
                 //console.log('registrationdddd>>>>' + this.registration);
                 this.showupload = true;
                var countryCode = result.SAP_Country_Code_AGN__c;
                if(!countryCode){
                    countryCode = result.Country_Code_AGN__c;
                }                 
                this.country = countryCode;
                this.customerType = result.Customer_Category_AGN__c;
                this.customerSubType = result.Customer_Sub_Category_AGN__c;
                if (result.Tax_Classification_AGN__c === '0') {
                    this.proofodexemption = true; 
                     var supportedDoc = {sobjectname:'Allergan_Customer_Registration_AGN__c', fieldname:'Tax_Classification_AGN__c', selectedVal:result.Tax_Classification_AGN__c};
                    this.supportedDocument = supportedDoc;                                       
                }
                //console.log('Step No>>>>>>>>>>>>',result.Online_Registration_Step_AGN__c);
                // eslint-disable-next-line radix
                let currentStepNo = parseInt(result.Online_Registration_Step_AGN__c);
                if(currentStepNo && currentStepNo >4){
                  this.navigateToLink('customer-registration-step4');
                }else{
                    this.stepNo = 3;
                    this.getAddressDetails(result , countryCode);
                }
                this.showLoader = false;
                this.hidemaindiv = false;
                
            }else{
                this.showLoader = false;
                this.hidemaindiv = false;
                this.showToast('error' , AGN_OAM_Unknown_Error, 'error');
                //this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in Registration :: ',error);
            this.showToast('error' , JSON.stringify(error), 'error');
            //this.setErrorMessage(error , '');
            this.showLoader = false;
            this.hidemaindiv = false;
        });
    }


    getAddressDetails(registration , countryCode){

        getCustomerAddressDetails({custRegId : registration.Id})
            .then(data => {
                if (data) {
                    //console.log("Address Data*******", data);
                    var soldToAddr;
                    var addressList = data;
                    for (var i in addressList) {
                      if (addressList[i].Sold_To_AGN__c) {
                        //only 1 SoldTo Address will be present
                        soldToAddr = addressList[i];
                        break;
                      }
                    }
                    //console.log('soldToAddr record>>>>>>>>>>>>>>>>>>>>>>>>>>',soldToAddr);
                    this.soldToAddr = soldToAddr;
                    var objmix = Object.assign({}, registration, soldToAddr); //Merging registration and address data
                    this.record = objmix;
                    this.getConfigurations(registration , countryCode);
                    //console.log('objmix:::: ',objmix);
                  }else{
                    this.hidemaindiv = false;
                    this.showLoader = false;
                    this.showToast('error' , AGN_OAM_Unknown_Error, 'error');
                    //this.setErrorMessage('' , 'Unknown Error');
                  }
            })
            .catch(error => {
                console.log('Error in fetching address details :: ',error);
                //this.setErrorMessage(error , '');
                this.showToast('error' , JSON.stringify(error), 'error');
                this.hidemaindiv = false;
                this.showLoader = false;
            });
    }

    getConfigurations(registration , countryCode){
        //console.log('countryCode Data*******',countryCode);
        //console.log('this.source Data*******',this.source);   
        this.showuploadCA =  countryCode && countryCode.toUpperCase() == 'CA' ?  true : false;    
        fetchCountryList({
            countryCode : countryCode,
            source : this.source })
        .then(result => {
            if(result){
               // //console.log('Configuration Data*******',result);
                this.picklistCountryOptions = result[0];
                this.customerTypeConfig = result[1];
                this.invokeGetLayout(registration, countryCode , result[1]);
            }else{
                this.hidemaindiv = false;
                this.showLoader = false;
                this.showToast('error' , AGN_OAM_Unknown_Error, 'error');
                //this.setErrorMessage('' , 'Unknown Error');
            }
        })
        .catch(error => {
            console.log('Error in fetching configurations :: ',error);
            //this.setErrorMessage(error , '');
            this.showToast('error' ,  JSON.stringify(error), 'error');
            this.hidemaindiv = false;
            this.showLoader = false;
        });
    }

    invokeGetLayout(registration , countryCode , customerTypeConfig) {
        //console.log('countryCode>>>>>>>>>>>>>>>', countryCode);
       // //console.log('this.stepNo>>>>>>>>>>>>>>>', this.stepNo);
       // //console.log('registration.Customer_Category_AGN__c>>>>>>>>>>>>>>>', registration.Customer_Category_AGN__c);
       // //console.log('registration.Customer_Sub_Category_AGN__c >>>>>>>>>>>>>>>', registration.Customer_Sub_Category_AGN__c );
      //  //console.log('customerTypeConfig>>>>>>>>>>>>>>>', this.customerTypeConfig);
      //  //console.log(' this.source>>>>>>>>>>>>>>>', this.source);      
        if(countryCode === 'IT'){
            getLayout({country: countryCode ,
                 stepNo: this.stepNo,
                 customerType: registration.Customer_Category_AGN__c , 
                 customerSubType:registration.Customer_Sub_Category_AGN__c ,
                 custTypeConfig: this.customerTypeConfig,
                 source: this.source
                })
            .then(result => {
                this.hidemaindiv = false;
                this.showLoader = false;
                this.setLayoutFields(result);
            })
            .catch(error => {
                console.log('Error in fetching layout configurations :: ',error);
                this.showToast('error' ,  JSON.stringify(error), 'error');
                //this.setErrorMessage(error , '');
                this.hidemaindiv = false;
                this.showLoader = false;
            });
        }else{
            getLayout({country: countryCode , 
                      stepNo: this.stepNo , 
                      customerType: registration.Customer_Category_AGN__c , 
                      customerSubType:registration.Customer_Sub_Category_AGN__c ,
                      custTypeConfig: this.customerTypeConfig,
                      source: this.source})
            .then(result => {
               // //console.log('result>>>>>>>>>>>>>>>>>>>',result);
                this.hidemaindiv = false;
                this.showLoader = false;
                this.setLayoutFields(result);
            })
            .catch(error => {
                console.log('Error in fetching layout configurations :: ',error);
                this.showToast('error' ,  JSON.stringify(error), 'error');
                this.setErrorMessage(error , '');
                this.hidemaindiv = false;
                this.showLoader = false;
            });
        }
    }


    getLayoutForInternational(countryCode, customerType, customerSubType, customerTypeConfig) {
        //console.log('countryCode:::: ', countryCode);
        //console.log('customerType:::: ', customerType);
        //console.log('customerSubType:::: ', customerSubType);
        //console.log('customerTypeConfig:::: ', customerTypeConfig);
        getLayout({
            country: countryCode,
            stepNo: '3',
            customerType: customerType,
            customerSubType: customerSubType,
            custTypeConfig: customerTypeConfig,
            source: this.source
        })
        .then(result => {
            this.setLayoutFields(result);
            this.layoutMetadataMaster = result;
        })
        .catch(error => {
            console.log('error layout>>>>>>>>>>>>>>>>>>>' + JSON.stringify(error));
            this.error = error;
            this.showToast('error' ,  JSON.stringify(error), 'error');
        });

   }

   setLayoutFields(data) {
       var settings = [];
       var settingsMap = data;
       var step3fields =[];  
      // //console.log('settingsMap>>>>>>>>>>>>>>>>>>', settingsMap);
       for(var key in settingsMap){
        step3fields = settingsMap[key];     
       }  
      // //console.log('step3fields2222>>>>>>>>>>>>>>>>>>', JSON.stringify(step3fields));  
       this.step3fields = step3fields; 
       this.hidemaindiv = false;
       this.fieldloaded = this.step3fields.length>0? true:false;
       this.showLoader =false;
   }

   setErrorMessage(error , custommsg){
        //console.log('error == ',error);
        if(custommsg){
            this.showToast('error' , AGN_OAM_Contact_Admin +custommsg, 'error');
        }else if(error && error.body && error.body.message){
            this.showToast('error' , AGN_OAM_Contact_Admin +error.body.message, 'error');
        }else{
            this.showToast('error' , AGN_OAM_Contact_Admin , 'error');
        }
    }

    showToast(title , message , variant) {
        if(this.source==='cs')
        {   this.error = message; 
            this.variant = variant; 
            this.showToastMsg = true;              
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

    handlePrevious(){

        if (this.source == 'cs') {
          /*  this.RegistrationStepNo = '2';
            //this.caseId = result;
            const regStepNoEvent = new FlowAttributeChangeEvent('RegistrationStepNo', this.RegistrationStepNo);
            const caseIdEvent = new FlowAttributeChangeEvent('caseId', this.caseId);

            this.dispatchEvent(regStepNoEvent);
            this.dispatchEvent(caseIdEvent);

            const nextNavigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(nextNavigationEvent);*/
            this.nextOrPreviousActionEvent(this.caseId, '2');
        }
        if(this.source=='oam'){
            this.navigateToLink('customer-registration-step2');
        }

    }

    handleSave(){
        let cmp = this.template.querySelector('.tncchkbox');
   
        if(cmp && cmp.checked!==true){
            this.showToast('error',AGN_OAM_Accept_TnC_ANZ,'error');
        }else{
        	this.handleClick('save');
        }
    }

    handleNext(){
        let cmp = this.template.querySelector('.tncchkbox');	
        if(cmp && cmp.checked!==true){
            this.showToast('error',AGN_OAM_Accept_TnC_ANZ,'error');
        }else{
          let self = this;
          self.isnext = true;       
          self.handleClick('next');
    	}
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

    handleClick(actionType){
        let labelMap = getCustomLable();
        let speciality = '';
        let formatIssuefieldList = [];
        this.hidemaindiv = true;
        this.showLoader = true;
        let labelNameVAT = '';
        let labelNameTAX = '';
        let address = { 'sobjectType': 'Allergan_Customer_Address_AGN__c' };
        let registration = { 'sobjectType': 'Allergan_Customer_Registration_AGN__c' };
        let registratinRec = this.registration;
        if (this.registration) {
            registration.Id = registratinRec.Id;
            registration.Case_AGN__c = this.registration.Case_AGN__c;
        }
        if (this.soldToAddr) {
          address.Id = this.soldToAddr.Id;
        }
        /*registration.Id = registratinRec.Id;
        registration.Case_AGN__c = this.registration.Case_AGN__c;
        registration.Country_Code_AGN__c = this.registration.Country_Code_AGN__c; 
        address = this.soldToAddr.Id;*/
        var allValid = true;
        var isFormatValid = true;
        var hasFormatIssues = false;
        let hasTaxNumber = false;
        let hasVatNumber = false;
        let currentCountry = this.country;
        let parentRecordCRM ;	
        let parentRecordState;

        let VATORTAXRequired = '';
        this.template.querySelectorAll('c-a-g-n_-g-c-s-p_-common-input-field-component').forEach(element => {
           
           
            //console.log('sobject>>>>>>>>>>>>>>>>>>>>',element.sobjectname);
            //console.log('fieldname>>>>>>>>>>>>>>>>>>>>',element.fieldname);
            //console.log('customlabel>>>>>>>>>>>>>>>>>>>>',element.customlabel);
            if(element.isActiveField())
            {
                isFormatValid = element.isFormatValid();
                let enteredVal = element.getUserEnteredInput();
                //console.log('value>>>>>>>>>>>>>>>>>>>>',enteredVal);
                if(element.fieldname == 'Tax_Number_AGN__c'){               
                    labelNameTAX = labelMap.get(element.customlabel);        
                }
                if(element.fieldname == 'VAT_Number_AGN__c'){               
                    labelNameVAT = labelMap.get(element.customlabel);              
                }
                if(isFormatValid)
                { 
                    element.setCustomErrorMessage('');
                    if(element.checkValidity()){ 

                        if(element.getUserEnteredInput()){
                            if(element.sobjectname === 'Allergan_Customer_Registration_AGN__c'){
                                registration[element.fieldname] = enteredVal;
                                if(element.fieldname ==='Specialty_Allergan_1_AGN__c'){
                                    speciality = enteredVal;
                                }
                                if(labelMap.get(element.customlabel) == 'CRM/CRO'){	
                                    parentRecordCRM = enteredVal;
                                }	
                                if(labelMap.get(element.customlabel) == 'UF do CRM/CRO'){	
                                    parentRecordState = enteredVal;
                                }
                            }else if(element.sobjectname === 'Allergan_Customer_Address_AGN__c'){
                                address[element.fieldname] = enteredVal;
                            }
                            /*  Tax Number/Vat Number validation for IT */
                            if(element.fieldname == 'Tax_Number_AGN__c'){
                                hasTaxNumber = true;                      
                            }
                            if(element.fieldname == 'VAT_Number_AGN__c'){
                                hasVatNumber = true;                      
                            }
                            if(parentRecordCRM && parentRecordState && !parentRecordCRM.includes('_') && !parentRecordState.includes('_')){	
                                registration.Physician_Registration_Reference_AGN__c=parentRecordCRM+'_'+parentRecordState;	
                            }
                            //console.log('labelNameTAX>>>>>>>>>>>>>>>>>>>>',labelNameTAX);
                            //console.log('labelNameVAT>>>>>>>>>>>>>>>>>>>>',labelNameVAT);                    
                        }                
        
                    }else{
                        allValid = false;
                        //console.log('Required Field Missing>>>>>>>>',allValid);
                    }

                }
                else{
                    let errorMessage = AGN_OAM_Body_PleaseCheckFormatFor +' '+ labelMap.get(element.customlabel);
                    element.setCustomErrorMessage(errorMessage);
                    formatIssuefieldList.push(labelMap.get(element.customlabel));
                    hasFormatIssues = true;
                }
            }
            
          });
          //console.log('hasVatNumber>>>>>>>>>>>>>>>',hasVatNumber);
          //console.log('hasTaxNumber>>>>>>>>>>>>>>>>>>>>',hasTaxNumber);
          let VatOrTax = (labelNameVAT && labelNameTAX) ? labelNameVAT+' / '+labelNameTAX: (labelNameVAT)? labelNameVAT : (labelNameTAX)?labelNameTAX:'';
          //console.log('VatOrTax>>>>>>>>>>>>>>>>>>>>',VatOrTax);
          VATORTAXRequired = VatOrTax;

          //console.log('VATORTAXRequired>>>>>>>>>>>>>>>>>>>>',VATORTAXRequired);

          if(!hasTaxNumber){
            address.Tax_Number_AGN__c = '';
          }
          if(!hasVatNumber){
              address.VAT_Number_AGN__c = '';
          }
          
          let allDocsValid = true;
          /*****************Document Validation****************** */
          this.template.querySelectorAll('c-agn_gcsp_customer-reg-step2-uploader').forEach(element => {
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

          //console.log('allDocsValid1>>>>>>>>>>>>>>>>>>',allDocsValid);
          let allDepDoc = true;
          this.template.querySelectorAll('c-agn_gcsp_tax-exempted-doc-upload').forEach(element => {
            //console.log('element.required2>>>>>>>>>>>>>>>>>>',element.requiredPending);
            if(element.requiredPending){
                allDepDoc = false;                  
                element.validateDocs();
            }
         }); 
         //console.log('allDepDoc>>>>>>>>>>>>>>>>>>',allDepDoc);
         if(!allDepDoc)
         {
            allDocsValid = false;
         }
          //console.log('hasTaxNumber>>>>>>>>>>>>>>>>>>',hasTaxNumber);
          //console.log('hasVatNumber>>>>>>>>>>>>>>>>>>',hasVatNumber);
          //console.log('speciality>>>>>>>>>>>>>>>>>>',speciality);
          let hasTaxAndVatError = false;
          if((currentCountry === 'IT' || currentCountry == 'ES' ) && !hasTaxNumber && !hasVatNumber ){
              //allValid = false;
              hasTaxAndVatError = true;
          }else{
             hasTaxAndVatError = false;
          }
          //console.log('hasTaxAndVatError>>>>>>>>>>>>>>>>>>>>>>>>',hasTaxAndVatError);
          //console.log('allValid>>>>>>>>>>>>>>>>>>>>>>>>',allValid);
         // //console.log('hasFormatIssues>>>>>>>>>>>>>>>>>>>>>>>>',hasFormatIssues);
          //console.log('allDocsValid>>>>>>>>>>>>>>>>>>>>>>>>',allDocsValid);
          if (allDocsValid && allValid && !hasFormatIssues && !hasTaxAndVatError) {
              //console.log('call upsert method>>>>>>>>>>>>>>>>');
              //console.log('registration>>>>>>>>>>>>>>>>',registration);
              //console.log('address>>>>>>>>>>>>>>>>',address);
              upsertCustomerDetails({customer : registration,
               customerAddress : address,
               Specialty	: speciality,
               actionType : actionType,
               currentStep : '3',
               source: this.source})
                .then(result => {
                    if(result){
                        //console.log('success result>>>>>>>>>>>>>>>>>>>',result);
                        this.showLoader = false;
                        this.hidemaindiv = false;
                        if(this.isnext){
                            if (this.source == 'cs'){
                                this.RegistrationStepNo = '4';
                                this.caseId = result;                              
                                this.nextOrPreviousActionEvent(result, '4');
                            }
                            else{
                                this.navigateToLink('customer-registration-step4');
                            }
                            this.isnext = false;
                        }else{
                            this.showToast('success' , AGN_OAM_Successfully_Updated , 'success');
                        }
                        this.issuccess = true;
                    }else{
                        this.showLoader = false;
                        this.hidemaindiv = false;
                        this.showToast('error' , AGN_OAM_Unknown_Error, 'error');
                        //this.setErrorMessage('' , 'Unknown Error');
                    }
                })
                .catch(error => {
                    console.log('Error in Upsert Details :: ',error);
                    this.showToast('error' ,  JSON.stringify(error), 'error');
                   // this.setErrorMessage(error , '');
                    this.showLoader = false;
                    this.hidemaindiv = false;
                });
          }else{
            this.showLoader = false;
            this.hidemaindiv = false;
            if(!allValid){
                this.showLoader = false;
                this.hidemaindiv = false;
                this.error = AGN_OAM_Invalid_Input;  
                this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
               
            }
            else if(hasFormatIssues){
                this.showLoader = false;
                this.hidemaindiv = false;
                if(formatIssuefieldList.length>0) {
                    this.showToast('error', AGN_OAM_Body_PleaseCheckFormatFor +' '+formatIssuefieldList.join(), 'error'); 
                }
                else{
                    this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
                }
            }
            /*if(!allValid){
                //this.showToast('Error' , AGN_CP_Invalid_Input_Error , 'Error');
                this.showToast('error' , AGN_OAM_Invalid_Input , 'error');
            }*/
            else if(!allDocsValid){
                //this.showToast('Error' ,AGN_CP_DOCS_MANDATORY , 'Error'); 
                this.showToast('error' , AGN_OAM_RequiredDocument_ErrorMsg , 'error'); 
            }
            else if((currentCountry === 'IT' || currentCountry == 'ES' ) && hasTaxAndVatError){
                //this.showToast('Error' , AGN_CP_TAX_OR_VAT_REQUIRED , 'Error');
                let errorMessage = AGN_OAM_Required_Fields_Missing_Error +' '+ VATORTAXRequired;
                this.showToast('error' , errorMessage , 'error');
            }else{
                this.showToast('error', AGN_OAM_Required_Fields_Missing_Error, 'error');
            }
            
          }
    }

    handledocupload(event){
       
        const eventParemeters = event.detail;
        const DocFieldSobjectName = eventParemeters.DocFieldSobjectName;
        //console.log("FieldSobjectName -> " + DocFieldSobjectName);
        const DocFieldName = eventParemeters.DocFieldName;
       // //console.log("FieldName -> " + DocFieldName);
        const DocFieldSelectedValue = eventParemeters.DocFieldSelectedValue;
        //console.log("FieldSelectedValue -> " + DocFieldSelectedValue);
        var supportedDoc = {sobjectname:DocFieldSobjectName, fieldname:DocFieldName, selectedVal:DocFieldSelectedValue};
         this.supportedDocument = supportedDoc;   
        if(DocFieldSelectedValue ==="0" || DocFieldSelectedValue === 0)
        {
            this.proofodexemption = true;
        }
        else {
            this.proofodexemption = false;
        }
        //console.log('@@@this.proofodexemption::',this.supportedDocument);
    }

    handleControllingFieldEvent(event) {
        const eventParemeters = event.detail;

        const controllingFieldSobjectName = eventParemeters.controllingFieldSobjectName;
       // //console.log("controllingFieldSobjectName -> " + controllingFieldSobjectName);
        const controllingFieldName = eventParemeters.controllingFieldName;
       // //console.log("controllingFieldName -> " + controllingFieldName);
        const controllingFieldSelectedValue = eventParemeters.controllingFieldSelectedValue;
       // //console.log("controllingFieldSelectedValue -> " + controllingFieldSelectedValue);

        let dependentFieldList = [];
        //console.log("layoutMetadataMaster -> " + JSON.stringify(this.layoutMetadataMaster));
        //finding dependent field list based upon event received with parameters
        //console.log("layoutMetadataMaster Keys -> " +  Object.keys(this.layoutMetadataMaster));
        var itr = 1;
        Object.keys(this.layoutMetadataMaster).forEach(key => {
           // //console.log('layoutMetadataMaster[key]>>' + JSON.stringify(this.layoutMetadataMaster[key]));
            let dependentField = this.layoutMetadataMaster[key].find(layout => {
               // //console.log('layout>>' + JSON.stringify(layout));
                if (layout.Controlling_Field_AGN__c == controllingFieldName &&
                    layout.Controlling_Field_SObject_Name_AGN__c == controllingFieldSobjectName) {
                   // //console.log('itr>>' + itr);
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
                        element.sobjectname === field.SObject_Name_AGN__c) {
                        //console.log('Checking the dependent List>>');
                        element.removeInputValue();
                        if (field.Dependent_Field_Show_Criteria_AGN__c && field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue)) {
                            element.showCmp();
                            element.setControllingValue(controllingFieldSelectedValue);
                          //  //console.log('met conditions>>');
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

    handleSpinnerLoader(event){        
       // //console.log('eventParemeters.soldToSAPId>>>>>>>'+this.soldToSAPId);
        const eventParemeters = event.detail;
      //  //console.log('eventParemeters.postion>>>>>>>'+eventParemeters.postion);
        if(eventParemeters.postion=='First'){          
            this.showLoader = true; 
        }else{
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
                        //console.log('l11111>>>>>',field.Dependent_Field_Show_Criteria_AGN__c.includes(controllingFieldSelectedValue));
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