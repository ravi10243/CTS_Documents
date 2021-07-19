/**
 * @description       : 
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 07-08-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-21-2021   Ravi Sirigiri   Initial Version
 **/
 import {
	LightningElement,
	track,
	api
} from 'lwc';
import getPickListValues from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getPickListValues';
import getLayout from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getLayout';
import AGN_OAM_Body_PaymentMethod from '@salesforce/label/c.AGN_OAM_Body_PaymentMethod';
import AGN_OAM_Payment_Term from '@salesforce/label/c.AGN_OAM_Payment_Term';
//import AGN_CP_FORMAT_INVALID from '@salesforce/label/c.AGN_CP_FORMAT_INVALID';
import AGN_OAM_PaymentDetails_Header from '@salesforce/label/c.AGN_OAM_PaymentDetails_Header';
import AGN_OAM_Invalid_Input from '@salesforce/label/c.AGN_OAM_Invalid_Input';
import AGN_OAM_Loading from '@salesforce/label/c.AGN_OAM_Loading';
import LOCALE from '@salesforce/i18n/locale';

import {
	loadStyle
} from 'lightning/platformResourceLoader';
import {
	getCustomLable
} from 'c/aGN_GCSP_CustomLabelsComponent';
import ASSETS from '@salesforce/resourceUrl/AGN_GCSP_Assets';
import ASSETS1 from '@salesforce/resourceUrl/AGN_CustomerPortal_LWC';

export default class Agn_gcsp_paymentForm extends LightningElement {
	@api paymentmethod = [];
	@api countrycode;
	@api sectionPaymentMap = [];
	@api record;
	@api recordData;
	@api instancetype;
	@api isExistingSAPRecord;
	@api selectedPaymentMethodId;
	@api selectedPaymentTermId;
	@api paymentmap = [];
	@api isupdateform = false;
	@api index;
	@api objecttype;
	@track PaymentTerm;
	@track PaymentTerm1;
	@track PaymentMethod1;
	@track sectionPaymentCreditList = [];
	@track sectionPaymentCreditListHistory = [];
	@track disablePaymentTerm = false;
	@track disablePaymentMethod = false;
	@api showBankDetails;
	@api bankTermsChecked;
	@api applicableforregistration;
	@track paymentFieldsRequired = true;
	@track showLoader = false;
	@track hidemaindiv = false;
    @track variant = 'error';
	
	@api customerTypeConfig;
	@api customerType;
	@api customerSubType;
	@api source;
	@api stepNo;
	@api sapid;

	@api layoutMetadataMaster;

	label = {
		AGN_OAM_Body_PaymentMethod,
		AGN_OAM_Payment_Term,
		AGN_OAM_PaymentDetails_Header,
		AGN_OAM_Loading
	};

	isOnlineRegistration = false;
	isCanadaEnglishOam = false;
	isDisable = true;
	renderedCallback() {
		loadStyle(this, ASSETS + "/assets/agn_gcsp_registration.css");
		loadStyle(this, ASSETS1 + "/css/style.css");
		loadStyle(this, ASSETS1 + "/css/footer.css");
	}

	connectedCallback() {

		/*//console.log('#paymentmethod>>>' + JSON.stringify(this.paymentmethod));
		//console.log('#paymentmap>>>' + JSON.stringify(this.paymentmap));
		//console.log('#customerType>>>' + this.customerType);
		//console.log('#instancetype>>>' + JSON.stringify(this.instancetype));
		//console.log('#record>>>' + JSON.stringify(this.record));
		//console.log('#index>>>' + JSON.stringify(this.index));*/

		if (this.source == 'oam') {
			this.isOnlineRegistration = true;		
			this.isCanadaEnglishOam = (this.countrycode == 'CA' && (LOCALE.includes('en') || LOCALE.includes('EN'))) ? true : false;
		}
		if (this.applicableforregistration === false) {
			this.disablePaymentMethod = true;
			this.disablePaymentTerm = true;
		}
		this.isDisable = ((this.countrycode == 'AN' || this.countrycode == 'AU' || this.countrycode == 'NZ' || this.countrycode == 'BR') && this.source == 'cs') ? false : true;
		if (this.isupdateform && this.isDisable)
		{
			this.disablePaymentMethod = true;
			this.disablePaymentTerm = true;
		}
		let currentrecordChild = this.record;
		/*****************For Record Edit***********************/
		
		if (currentrecordChild){
			if(currentrecordChild.Form_Of_Payment_AGN__c) {
                //console.log("currentrecordChild.Form_Of_Payment_AGN__c:::::: ", currentrecordChild.Form_Of_Payment_AGN__c);
                //console.log("paymethods:::::: ", this.paymentmethod);
                var paymethods = this.paymentmethod;
                let currentpaymentmethod = paymethods.find(
                    (pm) => pm.Id === currentrecordChild.Form_Of_Payment_AGN__c
                );
                //console.log("existing paymentmethod>>>>>>>>>>>>", currentpaymentmethod);
                const filteredItems = paymethods.filter(
                    (item) => item !== currentpaymentmethod
                );
                //console.log("filteredItems>>>>>>>>>>>>", filteredItems);
                this.PaymentMethod1 = currentpaymentmethod;
                this.paymentmethod = filteredItems;
                if (currentrecordChild.Payment_Term_AGN__c) {
                    this.selectedPaymentMethodId = currentrecordChild.Form_Of_Payment_AGN__c;
                    this.selectedPaymentTermId = currentrecordChild.Payment_Term_AGN__c;
                    this.loadPaymentTerms(
                        currentrecordChild.Payment_Term_AGN__c,
                        currentrecordChild.Form_Of_Payment_AGN__c
                    );
                }else if(this.instancetype === "update"){
                        this.getPaymentFields();
                }
            }else if(this.instancetype === "update"){
                    this.getPaymentFields();
            }
	    }
	}

	loadPaymentTerms(paymentTermId, paymentMethodId) {
		//console.log("*********Inside load payments**********", this.paymentmap);
		let paymentTermMap = new Map();
		if (this.paymentmap) {
			this.paymentmap.forEach(function (term) {
				if (paymentTermMap.has(term.Form_Of_Payment__c)) {
					paymentTermMap.get(term.Form_Of_Payment__c).push(term);
				} else {
					let termlist = [];
					termlist.push(term);
					paymentTermMap.set(term.Form_Of_Payment__c, termlist);
				}
			});
			//console.log("paymentTermMap in child>>>>>>>>>>>", paymentTermMap);
			if (paymentTermMap) {
				if (paymentTermMap.has(paymentMethodId)) {
					var paymentTermval = paymentTermMap.get(paymentMethodId);
					//console.log("paymentTermval>>>>>>>>>>>>>>>>", paymentTermval);
					if (this.countrycode === "IT") {
						let self = this;
						let paymentterm = paymentTermval.find(
							(pt) => pt.Id === paymentTermId
						);
						self.PaymentTerm1 = paymentterm;
						self.getPaymentFields();
					} else {
						let paymentterm = paymentTermval.find(
							(pt) => pt.Id === paymentTermId
						);
						this.PaymentTerm1 = paymentterm;
						this.getPaymentFields();
						this.PaymentTerm = paymentTermval;
					}
				}
			}
		}
	}

	@api
	checkPaymentMethod() {
		return this.selectedPaymentMethodId;
	}
	@api
	checkPaymentTerm() {
		return this.selectedPaymentTermId;
	}

	@api getSAPId() {
		return this.sapid;
	 }

	 @api getIsUpdateFrom(){
		 return this.isupdateform;
	 }

	paymentFormChangeHandler(event) {
		 this.PaymentTerm = [];
		 this.PaymentTerm1 = '';
		 this.sectionPaymentCreditList =[];
		if (event.target.value) {	
			this.showLoader = true;
			this.hidemaindiv = false;
			let paymentTermObj = {
				'sobjectType': 'Payment_Term_AGN__c'
			};
			this.PaymentTerm1 = paymentTermObj;
			this.disablePaymentTerm = false;
			let pmethod = event.target.value;
			/*//console.log(
				"SELECTED PAYMENT METHOD ID>>>>>>>>>>>>>>>>",
				pmethod,
				this.PaymentMethod1,
				this.paymentmethod
			);*/
			this.selectedPaymentMethodId = pmethod;
			let paymethods = this.paymentmethod;
			if (this.PaymentMethod1) {
				//To avoid issue for new records
				paymethods.push(this.PaymentMethod1);
			}

			let currentpaymentmethod = paymethods.find((pm) => pm.Id === pmethod);
			/*//console.log(
				"SELECTED PAYMENT METHOD>>>>>>>>>>>>>>>>",
				currentpaymentmethod
			);*/
			this.PaymentMethod1 = currentpaymentmethod;
			const filteredItems = paymethods.filter(
				(item) => item !== currentpaymentmethod
			);
			//console.log("filteredItems>>>>>>>>>>>>", filteredItems);
			this.paymentmethod = filteredItems.sort();
			var pmethodvalue = "'" + pmethod + "'";
			var sourcevalue = "'" + this.source + ";'";
			//console.log("pmethodvalue-->" + pmethodvalue);
			var columnName = "Payment_Term_Label_AGN__c, Name, Bank_Details_Required_AGN__c";
			var columnId = "SAP_Payment_Term_Code_AGN__c";
			var objectName = "Payment_Term_AGN__c";
			var whereCondition =
				" where Form_Of_Payment__c = " +
				pmethodvalue +
				" AND Active_AGN__c = true AND Source_AGN__c includes (" + sourcevalue + ")";
			//console.log("whereCondition>>>>>>>>>>>>>>>>>>>", whereCondition);
			getPickListValues({
					objectName: objectName,
					columnName: columnName,
					columnId: columnId,
					whereCondition: whereCondition
				})
				.then((result) => {
					//console.log("Payment Term>>>>>>>>>>>>>>>>>>>", result);
					if (result) {
						var paymentTermval = result;
						//console.log('paymentTermval1>>>>>>>>>>>>>>', paymentTermval);
						if (this.countrycode === "IT") {
							let self = this;
							for (var i in paymentTermval) {
								if (paymentTermval[i].SAP_Payment_Term_Code_AGN__c) {
									self.PaymentTerm1 = paymentTermval[i];
									self.selectedPaymentTermId = paymentTermval[i].Id;
								}
							}
							//console.log("self.PaymentTerm1>>>>>>>>>>>>>>>>>>>", self.PaymentTerm1);
							self.getPaymentFields();
							this.showLoader = false;
							this.hidemaindiv = false;
						} else {
							//console.log("paymentTermval:::::", paymentTermval);
							//console.log("this.PaymentTerm:::::", this.PaymentTerm);
							this.PaymentTerm = paymentTermval;
							this.showLoader = false;
							this.hidemaindiv = false;
						}
					}
				})
				.catch((error) => {
					console.log("error>>>>>>>>>>>>>>>>>>>", error);
					this.error = error;
					this.showLoader = false;
					this.hidemaindiv = false;
				});
		} else {
			/*this.disablePaymentTerm = true;
			      this.selectedPaymentMethodId = '';
			      this.PaymentTerm1 = [];
			      var eventData = { paymentfields: [] , 
			          paymentmethod:[] ,
			          paymentterm:[]};
			      this.invokePaymentEvent(eventData);*/
			let key;
			if (this.instancetype && this.instancetype === "update") {
				key = this.record.SAP_ID_AGN__c;
			} else if (this.record.Id) {
				key = this.record.Id;
			} else if (this.index) {
				key = this.index;
			}	
			var eventData = {
				key: key,
				showBankDetails: false,
				objecttype: this.objecttype,
				instancetype :this.instancetype
			};
			this.invokePaymentEvent(eventData);
			}
	}

	getPaymentFields() {
		let showBankDetails = this.showBankFields();
		if (showBankDetails) {
			this.invokeGetLayout(
				this.countrycode,
				this.stepNo,
				this.customerType,
				this.customerSubType,
				this.customerTypeConfig,
				this.source
			);
		}
		let key;
		if (this.instancetype && this.instancetype === "update") {
			key = this.record.SAP_ID_AGN__c;
		} else if (this.record.Id) {
			key = this.record.Id;
		} else if (this.index) {
			key = this.index;
		}	
		var eventData = {
			key: key,
			showBankDetails: showBankDetails,
			objecttype: this.objecttype,
			instancetype :this.instancetype
		};
		this.invokePaymentEvent(eventData);
	}

	invokePaymentEvent(eventData) {
		//console.log("calling payment event>>>>>>>>>>>>>", eventData);
		const paymentSelectionEvent = new CustomEvent("paymentselection", {
			detail: eventData
		});

		// Dispatches the event.
		this.dispatchEvent(paymentSelectionEvent);
	}

	paymentTermChangeHandler(event) {
		this.sectionPaymentCreditList =[];
		let pmethod = this.selectedPaymentMethodId;
		let pterm = event.target.value;
		//console.log("pmethod:::", pmethod, " >>> pterm:::", pterm);
		this.selectedPaymentTermId = pterm;
		let paymeterms = this.PaymentTerm;
		if(pterm)
		{

			if (this.PaymentTerm1) {
				paymeterms.push(this.PaymentTerm1);
			}
			let currentpaymentTerm = paymeterms.find((pt) => pt.Id === pterm);
			//console.log("currentpaymentTerm::::: ", currentpaymentTerm);
			this.PaymentTerm1 = currentpaymentTerm;
			const filteredItems = paymeterms.filter(
				(item) => item !== currentpaymentTerm
			);
			//console.log("filteredItems>>>>>>>>>>>>>", filteredItems);
			this.PaymentTerm = filteredItems.sort();
			//console.log("this.PaymentTerm11>>>>>>>>>>>>>", this.PaymentTerm);
			if (pmethod && pterm) {
				this.getPaymentFields();
			}
		}
	
	}

	invokeGetLayout(
		countryCode,
		stepNo,
		customerType,
		customerSubType,
		customerTypeConfigData,
		source
	) {		

		getLayout({
			country: countryCode,
			stepNo: stepNo,
			customerType: customerType,
			customerSubType: customerSubType,
			custTypeConfig: customerTypeConfigData,
			source: source
		})
		.then((result) => {
			this.hidemaindiv = false;
			this.showLoader = false;
			this.setPaymentLayoutFields(result);
		})
		.catch((error) => {
			console.log("error>>>>>>>>>>>>>>>>>>>", error);
			this.error = error;
			this.hidemaindiv = false;
			this.showLoader = false;
		});
	}
	setPaymentLayoutFields(data) {
		var settingsMap = data;
		var settings = [];
		for (var key in settingsMap) {
			settings = settingsMap[key];			
		}

		if(settings && this.isupdateform){	
			const data = JSON.parse(JSON.stringify(settings)); 
			//console.log('11::: '+JSON.stringify(data));
			data.forEach( (layout) => {
				layout.Required_AGN__c = false;
			});
			settings = data;			
		}
		
		this.sectionPaymentCreditList = settings;
		this.layoutMetadataMaster = settings;
		this.sectionPaymentCreditListHistory = settings;
		//console.log("settingsMap>>>>>>>>>>>>>>>>>>", settings);
	}

	showBankFields() {
		let showBankDetails = true;
		
		if ( (this.PaymentMethod1 && this.PaymentMethod1.Bank_Details_Required_AGN__c) ||
			(this.PaymentTerm1 && this.PaymentTerm1.Bank_Details_Required_AGN__c)
		) {
			showBankDetails = true;
		} 
        else if(this.instancetype === "update") {
			showBankDetails = true;
		}
		else {
			showBankDetails = false;
		}
		this.showBankDetails = showBankDetails;
		//console.log("showBankDetails>>>>>>>>>>>>>>", showBankDetails);
		return showBankDetails;
	}

	@api 
	isAllFormatValid(){
		let isFormatValid = false;
		var formatIssuefieldList =[];
		let valChanged = false;
		let labelMap = getCustomLable();
		let instancetype = this.instancetype;
		this.template.querySelectorAll("c-a-g-n_-g-c-s-p_-common-input-field-component").forEach(element=>{
			isFormatValid = element.isFormatValid();
			let ischanged = element.isChanged;		
			if (!isFormatValid) {			
				formatIssuefieldList.push(labelMap.get(element.customlabel));
				element.setCustomErrorMessage("");								
			}else {
				element.setCustomErrorMessage("");
			}
			if(ischanged){
				valChanged =true;
			}			
		});
		//console.log("formatIssuefieldList>>>>>>>>>>>"+formatIssuefieldList);
		//console.log("instancetype>>>>>>>>>>>"+instancetype);
		//console.log("valChanged>>>>>>>>>>>"+valChanged);
		if(instancetype)
		{
			if(instancetype ==='new' )
			{
				return formatIssuefieldList.join();
			}
			else if((instancetype === 'old' || instancetype ==='update'))
			{
				if(valChanged){
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
		else{
			return formatIssuefieldList.join();
		}
	}

	@api 
	checkAllfieldValid(){	
		var isValid = true;	
		let isPaymentMethodValid = this.checkPaymentMethod();
        //console.log('isPaymentMethodValid >>>>>>>>>>>>>>>>', isPaymentMethodValid);
        let isPaymentTermValid = this.checkPaymentTerm();
        //console.log('isPaymentTermValid >>>>>>>>>>>>>>>>', isPaymentTermValid);
	    var isAnyChange = false;
		var instancetype = this.instancetype?this.instancetype:'new';
 		this.template.querySelectorAll("c-a-g-n_-g-c-s-p_-common-input-field-component").forEach(element=>{
		
			if(instancetype==='new')
			{
				isAnyChange = true;
			}
			else if((instancetype === 'old' || instancetype ==='update') && element.isChanged)
			{
				isAnyChange = true;
			}			
			if (!element.checkValidity()) {	
			    isValid	= false;
			}			
		});
		if((!isPaymentMethodValid || !isPaymentTermValid) && isAnyChange)
		{
			isValid	= false;
			return isValid;
		}
		else if(isAnyChange)
		{
			return isValid;
		}
		return true;
	}

	@api
	validateInputs() {
		let labelMap = getCustomLable();
		let formatIssuefieldList = [];
		//console.log("validate inputs>>>>>>>>>>");
		var allValid = true;
		var isFormatValid = true;
		var hasFormatIssues = false;
		let billtomap = new Map();
		let billtolist = [];
		let soldtomap = new Map();
		let soldtolist = [];
		let newBilltoMap = new Map();
		var hasPaymentFields = false;
		let objecttype = this.objecttype;
		let selectedPaymentMethodId = this.selectedPaymentMethodId;
		let selectedPaymentTermId = this.selectedPaymentTermId;
		let hasSoldToChanged = false;
		let hasBillToChanged = false;
		//let isFormatValidPaymentTerm = false;
		//let isFormatValidPaymentMethod = false;
		//console.log("instancetype>>>>>>>>>>>>>>>", this.instancetype);

		if (!selectedPaymentMethodId && this.instancetype == "new") {
			let errorMessage = AGN_OAM_Invalid_Input + ' :' + AGN_OAM_Body_PaymentMethod;
			this.showToast("error", errorMessage, "error");
			hasFormatIssues = true;
		}
		if (!selectedPaymentTermId && this.instancetype == "new") {
			let errorMessage = AGN_OAM_Invalid_Input + ' :' + AGN_OAM_Payment_Term;
			this.showToast("error", errorMessage, "error");
			hasFormatIssues = true;
		}

		this.template.querySelectorAll("c-a-g-n_-g-c-s-p_-common-input-field-component").forEach(element=>{
			hasPaymentFields = true;
			isFormatValid = element.isFormatValid();
			if (!isFormatValid) {
				//console.log('Format Error>>>>Setting Message>>>>');
				let errorMessage = AGN_OAM_Invalid_Input + ' :' + labelMap.get(element.customlabel);
				element.setCustomErrorMessage(errorMessage); //AGN_CP_FORMAT_INVALID
				formatIssuefieldList.push(labelMap.get(element.customlabel));
				hasFormatIssues = true;
			} else {
				element.setCustomErrorMessage("");
			}
			//console.log("Payment Field Name>>>>>>>>>>>>>>>", element.fieldname);
			//console.log("Payment Field isChanged >>>>>>>>>>>>>>>>",element.isChanged);
			//console.log("isFormatValid >>>>>>>>>>>>>>>>", isFormatValid);
			//console.log("checkValidity >>>>>>>>>>>>>>>>", element.checkValidity());
			if (element.checkValidity() && isFormatValid) {
				//allValid = true;
				let elementVal = element.getUserEnteredInput();
				let isChanged = true; // Always true for Registration components
				// This logic is applicable only for update journey
				if (this.instancetype && this.instancetype === "update" &&	!element.isChanged) {
					isChanged = false;
				}

        //console.log("isChanged >>>>>>>>>>>>>>>>", isChanged);
        //console.log("element.getUserEnteredInput >>>>>>>>>>>>>>>>", element.getUserEnteredInput());				
				if (element.sobjectname === "Allergan_Customer_Address_AGN__c" && isChanged) {
					if(objecttype === "soldto"){
						hasSoldToChanged = true;
						if (element.record) {
							let recordId;
							if (this.instancetype && this.instancetype === "update") {
								recordId = element.record.SAP_ID_AGN__c;
							} else {
								recordId = element.record.Id;
							}							
							if(soldtomap.has(recordId)){

							}else{
								let soldtoAddress = {
								sobjectType: "Allergan_Customer_Address_AGN__c"
								};

								if (this.instancetype && this.instancetype === "update") {
									soldtoAddress.SAP_ID_AGN__c = element.record.SAP_ID_AGN__c;
								} else {
									soldtoAddress.Id = element.record.Id;
								}		
								soldtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
								soldtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;
								soldtomap.set(recordId, soldtoAddress);
							}
							
						}
					}
					else if(objecttype === "billto"){
						hasBillToChanged = true;
						
						if (element.record) {
							let recordId;
							if (this.instancetype && this.instancetype === "update") {
								recordId = element.record.SAP_ID_AGN__c;
							} else {
								recordId = element.record.Id;
							}							
							if(!billtomap.has(recordId)){
								let billtoAddress = {
									sobjectType: "Allergan_Customer_Address_AGN__c"
								};

								if (this.instancetype && this.instancetype === "update") {
									billtoAddress.SAP_ID_AGN__c = element.record.SAP_ID_AGN__c;
								} else {
									billtoAddress.Id = recordId;
								}	
								billtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
								billtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;							
								billtomap.set(recordId, billtoAddress);
							}
						}else{
							/*************Create Record*****************/	
							if (newBilltoMap.has(this.index)) {
								//newBilltoMap.get(this.index)[element.fieldname] = elementVal;
							}else{
								let billtoAddress = {
									sobjectType: "Allergan_Customer_Address_AGN__c"
								};
								billtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
								billtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;
								newBilltoMap.set(this.index, billtoAddress);
							} 								
							
						}
					}
				}
		
				if (elementVal && isChanged) {
					if (element.sobjectname === "Allergan_Customer_Address_AGN__c") {
						if (objecttype === "soldto") {
							hasSoldToChanged = true;
							if (element.record) {
								let recordId;
								if (this.instancetype && this.instancetype === "update") {
									recordId = element.record.SAP_ID_AGN__c;
								} else {
									recordId = element.record.Id;
								}
								if (soldtomap.has(recordId)) {
									soldtomap.get(recordId)[element.fieldname] = elementVal;
								} else {
									let soldtoAddress = {
										sobjectType: "Allergan_Customer_Address_AGN__c"
									};
									soldtoAddress[element.fieldname] = elementVal;
									if (this.instancetype && this.instancetype === "update") {
										soldtoAddress.SAP_ID_AGN__c = element.record.SAP_ID_AGN__c;
									} else {
										soldtoAddress.Id = element.record.Id;
									}
									soldtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
									soldtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;
									soldtomap.set(recordId, soldtoAddress);
								}
								
							}
						} else if (objecttype === "billto") {
							hasBillToChanged = true;
							if (element.record) {
								/*************Edit Record*****************/
								let recordId;
								if (this.instancetype && this.instancetype === "update") {
									recordId = element.record.SAP_ID_AGN__c;
								} else {
									recordId = element.record.Id;
								}
								//console.log("recordId>>>>>>>>>>>>>>>>>", recordId);
								//console.log("billtomap>>>>>>>>>>>>>>>>>", billtomap);
								if (billtomap.has(recordId)) {
									billtomap.get(recordId)[element.fieldname] = elementVal;									
								} else {
									let billtoAddress = {
										sobjectType: "Allergan_Customer_Address_AGN__c"
									};
									billtoAddress[element.fieldname] = elementVal;
									if (this.instancetype && this.instancetype === "update") {
										billtoAddress.SAP_ID_AGN__c = element.record.SAP_ID_AGN__c;
									} else {
										billtoAddress.Id = recordId;
									}
									billtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
									billtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;
									billtomap.set(recordId, billtoAddress);
									
								}
								//console.log('billtomapfinal1111::: ',billtomap);
							} else {
								/*************Create Record*****************/
								if (newBilltoMap.has(this.index)) {
									newBilltoMap.get(this.index)[element.fieldname] = elementVal;
								} else {
									let billtoAddress = {
										sobjectType: "Allergan_Customer_Address_AGN__c"
									};
									billtoAddress[element.fieldname] = elementVal;
									billtoAddress.Form_Of_Payment_AGN__c = selectedPaymentMethodId;
									billtoAddress.Payment_Term_AGN__c = selectedPaymentTermId;
									newBilltoMap.set(this.index, billtoAddress);
								}

								//console.log('newBilltoMap111::: ',newBilltoMap);
							}
						}
					}
				}


				/* else {
				   //console.log("Payment Field Value IS INVALID>>>>>>>>>>>>>>>");
				   allValid = false;
				 }*/

			} else {
				//console.log("Payment Field Value IS INVALID>>>>>>>>>>>>>>>");
				allValid = false;
			}
			//console.log("Is Format Valid>>>>>>>>", isFormatValid);
		});
		//console.log("selectedPaymentMethodId::::", selectedPaymentMethodId);
		//console.log("selectedPaymentTermId::::", selectedPaymentTermId);
		if (!selectedPaymentMethodId || !selectedPaymentTermId) {
			//console.log("Payment mthod or term is blank>>>>>>>>>>>");
			allValid = false;
		}
		if (hasFormatIssues || !allValid) {
			//this.showToast('error', AGN_OAM_Invalid_Input, 'error');
			this.hidemaindiv = false;
			this.showLoader = false;
			return 'error' + formatIssuefieldList.join();
		} else {
			if (allValid && !hasFormatIssues) {
				let isPaymentChanged = false;
				if (this.record) {
					if (this.record.Form_Of_Payment_AGN__c !== selectedPaymentMethodId) {
						isPaymentChanged = true;
					}
					if (this.record.Payment_Term_AGN__c !== selectedPaymentTermId) {
						isPaymentChanged = true;
					}
				}
				let continueOperation = true;
				//console.log("hasBillToChanged>>>>>>>>>>>>>>>>>>>>>>", hasBillToChanged);
				//console.log("hasSoldToChanged>>>>>>>>>>>>>>>>>>>>>>", hasSoldToChanged);
				//console.log("isPaymentChanged>>>>>>>>>>>>>>>>>>>>>>", isPaymentChanged);
				if (this.instancetype && this.instancetype === "update") {

					if (hasBillToChanged || hasSoldToChanged || isPaymentChanged) {
						continueOperation = true;
					} else {
						continueOperation = false;
					}

				}
				//console.log("continueOperation>>>>>>>>>>>>>>>>>>>>>>", continueOperation);
				if (continueOperation) {
					if (objecttype === "soldto") {
						if (hasPaymentFields) {
							for (let value of soldtomap.values()) {
								soldtolist.push(value);
							}
							//console.log("Soldto Validation is successful****", soldtolist);
						} else {
							let soldtoAddress = {
								sobjectType: "Allergan_Customer_Address_AGN__c"
							};
							if (this.record) {
								if (this.instancetype && this.instancetype === "update") {
									soldtoAddress.SAP_ID_AGN__c = this.record.SAP_ID_AGN__c;
								} else {
									soldtoAddress.Id = this.record.Id;
								}
							}
							soldtoAddress.Form_Of_Payment_AGN__c = this.selectedPaymentMethodId;
							soldtoAddress.Payment_Term_AGN__c = this.selectedPaymentTermId;
               			//console.log('sectionPaymentCreditListHistory>>>>'+JSON.stringify(this.sectionPaymentCreditListHistory));
							if (this.sectionPaymentCreditListHistory) {
								this.sectionPaymentCreditListHistory.forEach(function (
									fieldvalue
								) {
									soldtoAddress[fieldvalue.Field_Name_AGN__c] = "";
								});
							}
							soldtolist.push(soldtoAddress);
							//console.log("Soldto Validation is successful****", soldtolist);
						}
						return soldtolist;
					} else if (objecttype === "billto") {
						if (hasPaymentFields) {
							if (this.record) {
								//console.log("For Edit>>>>>>>>>>>>>>", billtomap);
								// For Edit
								for (let value of billtomap.values()) {
									billtolist.push(value);
								}
							} else {
								// For New Record
								//console.log("For New>>>>>>>>>>>>>>", newBilltoMap);
								for (let value of newBilltoMap.values()) {
									billtolist.push(value);
								}
							}
						} else {
							let billtoAddress = {
								sobjectType: "Allergan_Customer_Address_AGN__c"
							};

							if (this.record) {
								if (this.instancetype && this.instancetype === "update") {
									billtoAddress.SAP_ID_AGN__c = this.record.SAP_ID_AGN__c;
								} else {
									billtoAddress.Id = this.record.Id;
								}
							}
							billtoAddress.Form_Of_Payment_AGN__c = this.selectedPaymentMethodId;
							billtoAddress.Payment_Term_AGN__c = this.selectedPaymentTermId;
							if (this.sectionPaymentCreditListHistory) {
								this.sectionPaymentCreditListHistory.forEach(function (
									fieldvalue
								) {
									billtoAddress[fieldvalue.Field_Name_AGN__c] = "";
								});
							} 

							billtolist.push(billtoAddress);
						}

						//console.log("Billto Validation is successful****", billtolist);
						return billtolist;
					}
				} else if (this.instancetype && this.instancetype === "update") { //continueOperation
					let resp = "NoChanges";
					return resp;
				} else {
					let resp =
						"FIELDS_NOT_FOUND," +
						this.selectedPaymentMethodId +
						"," +
						this.selectedPaymentTermId;
					return resp;
				}
			}

		}
		return false;
	}


	handleControllingFieldEvent(event) {
		const eventParemeters = event.detail;

		const controllingFieldSobjectName = eventParemeters.controllingFieldSobjectName;
		//console.log(			"controllingFieldSobjectName -> " + controllingFieldSobjectName		);
		const controllingFieldName = eventParemeters.controllingFieldName;
		//console.log("controllingFieldName -> " + controllingFieldName);
		const controllingFieldSelectedValue = eventParemeters.controllingFieldSelectedValue;
		//console.log(			"controllingFieldSelectedValue -> " + controllingFieldSelectedValue		);

		let dependentFieldList = [];
		//console.log("layoutMetadataMaster -> " + JSON.stringify(this.layoutMetadataMaster));
		//finding dependent field list based upon event received with parameters
		//console.log("layoutMetadataMaster Keys -> " +  Object.keys(this.layoutMetadataMaster));
		var itr = 1;
		Object.keys(this.layoutMetadataMaster).forEach((key) => {
			//console.log(				"layoutMetadataMaster[key]>>" +				JSON.stringify(this.layoutMetadataMaster[key])			);
			let dependentField = this.layoutMetadataMaster[key].find((layout) => {
				//console.log("layout>>" + JSON.stringify(layout));
				if (
					layout.Controlling_Field_AGN__c == controllingFieldName &&
					layout.Controlling_Field_SObject_Name_AGN__c ==
					controllingFieldSobjectName
				) {
					//console.log("itr>>" + itr);
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
			//console.log("dependentFieldList>>>" + JSON.stringify(dependentFieldList));
			dependentFieldList.forEach((field) => {
				this.template
					.querySelectorAll("c-a-g-n_-g-c-s-p_-common-input-field-component")
					.forEach((element) => {
						if (
							element.fieldname === field.Field_Name_AGN__c &&
							element.sobjectname === field.SObject_Name_AGN__c
						) {
							//console.log("Checking the dependent List>>");
							element.removeInputValue();
							if (
								field.Dependent_Field_Show_Criteria_AGN__c.includes(
									controllingFieldSelectedValue
								)
							) {
								element.showCmp();
								//console.log("met conditions>>");
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

	showToast(title, message, variant) {
		if (this.source === "cs") {
			this.error = message;
      this.variant = variant;
			this.template.querySelector("c-agn_gcsp_custom-toast").showCustomNotice();
		} else {
			const event = new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			});
			this.dispatchEvent(event);
		}
	}
}