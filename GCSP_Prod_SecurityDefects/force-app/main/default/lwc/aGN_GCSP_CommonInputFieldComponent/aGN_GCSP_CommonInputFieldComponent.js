/**
 * @description       : Display all input fields based on sobject name and field name from UI.
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 06-11-2021
 * @last modified by  : Ravi Sirigiri
 * @class             : AGN_GCSP_CommonInputFieldComponent
 * @extends           : LightningElement
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-04-2021   Ravi Sirigiri   Initial Version
 **/
import getPicklistOptions from '@salesforce/apex/AGN_GCSP_CustomerRegStep1Controller.getPicklistOptions';
import getSpecialityDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getSpecialityDetails';
import getSubSpecialityDetails from '@salesforce/apex/AGN_GCSP_CustomerRegStep2Controller.getSubSpecialityDetails';
import getFieldMetadata from '@salesforce/apex/AGN_GCSP_MetadataController.getFieldMetadata';
//import getLabelString from '@salesforce/apex/AGN_GCSP_MetadataController.getLabelString';
import { getCustomLable} from 'c/aGN_GCSP_CustomLabelsComponent';
import { api, LightningElement,track } from 'lwc';


export default class AGN_GCSP_CommonInputFieldComponent extends LightningElement {


    @api fielddescribe;
  //@api cachedFields
    @api customertype;
    @api customersubtype;
    @api custtypeconfig;
    @api customergroup;
    @api countrycode;
    @api source;
    @api isLast;
    @api isFirst;

    @api country;
    @api sobjectname;
    @api fieldname;
    @api fieldValue;
    @api required;
    @api labelVal;
    @api regex;
    @api disabled = false;
    @api customlabel;
    @api picklistOptionValues;
    @api helptext;
    @api sapid;
    @api recordValue;

    @track metadataval;
    @track displayType;
    @track privateRecord;
           recordOnLoad;
    @track picklistOptions;
    @track labelMap = new Map();
    @track showhide;
    isShowHide;
    @track isActive;
    @track isReference;

    @track isPhone = false;
    @track isString = false;
    @track isUrl = false;
    @track isTextArea = false;
    @track isPercent = false;
    @track isPicklist = false;
    @track isNumber = false;
    @track isDate = false;
    @track isDateTime = false;
    @track isCurrency = false;
    @api isBoolean = false;
    @track isMultiSelect =false;
    @track isMultiSelectNR =false;
    @track chkBoxVal = [];
    @track optionList =[];
    @track isProductOfinterest = false;
    @api instancetype;
    @api objecttype;
    @api index;
    @api isChanged = false;
    @api applicableforregistration;
    @api step = '';
    @api rendered = false;
    @api objectfieldtype; //field type of dummy object
    @api iscontrollingfield = false;
    @api controllingFieldValue = '';
    @api dependentfieldsproperty;
    @api documentrequired = false;
    @api
    get record() {
        return this.privateRecord;
    }
    set record(value) {
        if (value) {
           // //console.log('firing controlling field event:::'+ this.fieldname, ':::fieldValue=', this.fieldValue,':::newFiedlValue='+ +':::fieldVal='+ fieldVal);
            this.privateRecord = value;
            var rec = value;
            var fldname = this.fieldname;
            var sobname = this.sobjectname;
            var fieldVal = rec[fldname];

            //console.log('d', fieldVal + ' fieldname::' + fldname + 'displaytype>>'+this.displayType);

            if (fieldVal || fieldVal===false|| fieldVal===0 ){
                if(this.fieldname == 'Product_Interest_AGN__c'){
                    //console.log('Product_Interest_AGN__c22>>>>>>>>>>>>>>>', fieldVal);
                    this.chkBoxVal = fieldVal;
                    //console.log('chkBoxValc22>>>>>>>>>>>>>>>', this.chkBoxVal);
                }
                /*if(this.fieldname == 'Specialty_Allergan_1_AGN__c'){

                    for(var vl in this.picklistOptions){
                      //console.log('picklistOptionsValset>>>>>>>>>>>>>>>', this.picklistOptions[vl]);
                      if(this.picklistOptions[vl].Id===fieldVal)
                      {
                        this.picklistOptions[vl].selected = true;
                      }
                    }
                    this.fieldValue = fieldVal;   
                }*/
                else{                    
                    this.fieldValue = fieldVal; 
                }

            }
        }
    }

    @track position = '';

    @api setControllingValue(value) {
       // this.fieldValue ='';
        //console.log('from field - > ' +value);
        this.controllingFieldValue = value;
        //console.log('this.controllingFieldValue>>'+ this.controllingFieldValue)
        this.getFieldMetadata();
    }

    get inputClass() {
        var inpclass = '';
        var instancetype = this.instancetype;
        if (instancetype && instancetype === 'new') {
            inpclass = 'commoninputcmp newinstance';
        } else {
            inpclass = 'commoninputcmp';
        }
       // //console.log('inpclass>>>>>>>>>>>>>>>>>>', inpclass);
        return inpclass;
    }
    
    @api
    setRequired(templatevalue){
        this.required = templatevalue;
    }

    connectedCallback() {

        //console.log('isFirst>>>>>'+ this.isFirst);
        //console.log('index>>>>>'+ this.index);
        
        if(this.isFirst){
            this.position = 'First'
        }
        else if(this.isLast){
            this.position = 'Last'
        } 
        if(this.position =='First'){
            var positionEvent = new CustomEvent('startstopevent', {
                detail: {
                    postion: this.position
                }
            });                   
            this.dispatchEvent(positionEvent);
        }     
        if(this.position =='Last'){
            var positionEvent = new CustomEvent('startstopevent', {
                detail: {
                    postion: this.position
                }
            });                   
            this.dispatchEvent(positionEvent);
        }   

        //console.log(this.country);
        //console.log('custtypeconfig>>>>>'+ this.custtypeconfig);
        //console.log('this.fieldname;>>>>>'+ this.fieldname);
        //console.log('this.sobjectname>>>>>'+ this.sobjectname);
   

        this.labelMap = getCustomLable();
        //var labvalue = this.labelMap.get(this.customlabel);
        var labvalue = this.labelMap.has(this.customlabel) ? this.labelMap.get(this.customlabel) : this.customlabel;
        this.labelVal = labvalue;
        var helpTexValue = this.labelMap.has(this.helptext) ? this.labelMap.get(this.helptext) : this.helptext;
        this.helptext = helpTexValue;

        if (this.applicableforregistration === false) {
            this.disabled = true;
        }

        if (this.rendered === undefined || this.rendered == true) {
            //console.log('entering 1>>>');
            this.rendered = true;
            this.showhide = 'slds-show';
            this.isShowHide=true;
            //console.log('showhide>>>' + this.showhide);
        } else if (this.rendered == false) {
            //console.log('entering 2>>>');
            this.rendered = false;
            this.showhide = 'slds-hide';
            this.isShowHide=false;
            //console.log('showhide>>>' + this.showhide);
        }
        //console.log('CommonInput|ConnectedCallback|fielddescribe:::' , this.fielddescribe);
        this.fielddescribe? this.setFieldMetadata(this.fielddescribe): this.getFieldMetadata();
        //this.getAllFieldsMetadata(); 
        //this.getFieldMetadata();    

        this.index= (this.sapid) ? this.sapid : (this.index || this.index == 0)? this.index  : this.privateRecord? this.privateRecord.Id : '';
		//console.log(`CommonInput| connectedCallback | index :: ${this.record} - ${this.index}`);
        //console.log(`CommonInput| connectedCallback | privaterecord :: ${JSON.stringify(this.privateRecord)}`);
    }

    renderedCallback() {
       
    }

    @api showCmp() {
        this.rendered = true;
        this.showhide = 'slds-show';         
        this.isShowHide=true;       
    }

    @api hideCmp() {
        this.rendered = false;        
        this.showhide = 'slds-hide';
        this.isShowHide = false;
    }
    @api isActiveField(){
        if(this.showhide == "slds-show")
        {
            return true;
        }
        return false;
    }

    @api isCmpHidden() {       
        return this.rendered;
    }

    @api removeInputValue() {
        var inputCmp = this.template.querySelector(".commoninputcmp");
        //inputCmp.setCustomValidity('');
        if(inputCmp){inputCmp.value = '' ;}
        this.fieldValue='';
    }

    @api handleBlur(event) {
        var inputCmp = this.template.querySelector(".commoninputcmp");
        if (this.isFormatValid()) {
            inputCmp.setCustomValidity('');
        }

        let newval = event.target.value;
        let fieldType =  event.target.type;
        if(this.country && this.country.toUpperCase() === 'CA' && fieldType){
            //console.log('fieldType::::',fieldType);//
           newval= newval? this.convertFrenchCharacterToUpperCase(newval).toUpperCase() : newval;
           // newval= newval? this.convertFrenchCharacterToUpperCase(newval) : newval;
            this.fieldValue= newval;
        }
        
    }   

    convertFrenchCharacterToUpperCase(inputString){
        if(inputString){
            inputString = inputString.replaceAll('à','A');
            inputString = inputString.replaceAll('â','A');
            inputString = inputString.replaceAll('À','A');
            inputString = inputString.replaceAll('Â','A');
            inputString = inputString.replaceAll('ç','C');
            inputString = inputString.replaceAll('Ç','C');
            inputString = inputString.replaceAll('é','E');
            inputString = inputString.replaceAll('è','E');
            inputString = inputString.replaceAll('ê','E');
            inputString = inputString.replaceAll('ë','E');
            inputString = inputString.replaceAll('É','E');
            inputString = inputString.replaceAll('È','E');
            inputString = inputString.replaceAll('Ê','E');
            inputString = inputString.replaceAll('Ë','E');
            inputString = inputString.replaceAll('î','I');
            inputString = inputString.replaceAll('ï','I');
            inputString = inputString.replaceAll('Î','I');
            inputString = inputString.replaceAll('Ï','I');
            inputString = inputString.replaceAll('ô','O');
            inputString = inputString.replaceAll('Ô','O');
            inputString = inputString.replaceAll('ù','U');
            inputString = inputString.replaceAll('û','U');
            inputString = inputString.replaceAll('ü','U');
            inputString = inputString.replaceAll('Ù','U');
            inputString = inputString.replaceAll('Û','U');
            inputString = inputString.replaceAll('Ü','U');
            //console.log('newVal::::::',inputString);
        }
        return inputString;
    }
    handleKeyUp(event){

        //console.log('==inputCmp.value==before==', this.fieldValue);
        var inputCmp = this.template.querySelector(".commoninputcmp");
        if(this.country && this.country.toUpperCase() === 'BR' && this.source && this.source === 'oam'){
            //newval= newval? this.convertFrenchCharacterToUpperCase(newval).toUpperCase() : newval;
            // newval= newval? this.convertFrenchCharacterToUpperCase(newval) : newval;
            //this.fieldValue= '';
            inputCmp.value='';
        }
    //console.log('==this.fieldValue==after==', this.fieldValue);

    }
    handleChange(event) {
        
        let newval = event.target.value; 
        let fieldType =  event.target.type;
       /* //if(fieldType =='text'){
            if(this.country && this.country.toUpperCase() === 'CA'){
                newval= newval? convertFrenchCharacterToUpperCase(newval).toUpperCase() : newval;
                this.fieldValue= newval;
            }
        //}    */ 
         

        if(fieldType=='checkbox')
        {
            newval = event.target.checked;   
            if(this.fieldname=='Allergan_Direct_Access_Requested_AGN__c' ||  this.fieldname=='Enable_Portal_User_AGN__c' )
            {
                //console.log('inside checkboxevent>>>>');             
                var chkBoxEvent = new CustomEvent('checkboxevent', {
                    detail: {

                        instancetype : this.instancetype,
                        objecttype : this.objecttype,
                        index: this.index,
                        checkedVal : newval
                    }
                });
                this.dispatchEvent(chkBoxEvent);                
            }
        }        
        if (!newval && !this.fieldValue) {
            this.isChanged = false;
        } else {
            if (newval === this.fieldValue) {
                this.isChanged = false;
            } else {
                this.isChanged = true;
            }
        }

        if(this.fieldname == 'Product_Interest_AGN__c'){         
            if (!newval && !this.chkBoxVal) {
                this.isChanged = false;
            } else {
                if (newval === this.chkBoxVal) {
                    this.isChanged = false;
                } else {
                    this.isChanged = true;
                }
            }          
         }
        
        if(this.country.toUpperCase() === 'BR' && this.fieldname == 'Zip_AGN__c' && this.sobjectname == 'Allergan_Customer_Address_AGN__c'){
            let indx = (this.sapid) ? this.sapid : this.index;
            //console.log('this.sapid::::: ',this.sapid);
            var selectedEvent = new CustomEvent('zipcodevalue', {
                detail: {
                    sobjectName: this.sobjectname,
                    fieldName: this.fieldname,
                    value: newval,
                    instancetype : this.instancetype,
                    objecttype : this.objecttype,
                    index: this.index,
                    sapid: this.sapid,
                    isFormatvalid: this.isFormatValid()
                }
            });
            // Dispatches the event.
            //console.log('custom event controllingfieldevent fired');
            this.dispatchEvent(selectedEvent);
        }
        
        if (this.iscontrollingfield) { 
            this.displayDependentField(newval);
            /*var controllingFieldSobjectName = this.sobjectname;
            var controllingFieldName = this.fieldname;
            var controllingFieldSelectedValue = newval;
            let indx = (this.sapid) ? this.sapid : this.index;
            //console.log('this.sapid::::: ',this.sapid);
            var selectedEvent = new CustomEvent('controllingfieldevent', {
                detail: {
                    controllingFieldSobjectName: controllingFieldSobjectName,
                    controllingFieldName: controllingFieldName,
                    controllingFieldSelectedValue: controllingFieldSelectedValue,
                    instancetype : this.instancetype,
                    objecttype : this.objecttype,
                    index: this.index,
                    sapid: this.sapid
                }
            });
            // Dispatches the event.
            //console.log('custom event controllingfieldevent fired');
            this.dispatchEvent(selectedEvent); */
        }
        //console.log('this.documentrequired:::::: ',this.documentrequired);
       // //console.log('newval:::::: ',newval);
       if(this.documentrequired){
            var FieldSobjectName = this.sobjectname;
            var FieldNameAPIName = this.fieldname;
            var FieldSelectedValue = newval;

            var upEvent = new CustomEvent('uploaddocevent', {
                detail: {
                    DocFieldSobjectName: FieldSobjectName,
                    DocFieldName: FieldNameAPIName,
                    DocFieldSelectedValue: FieldSelectedValue
                }
            });
            // Dispatches the event.
            //console.log('custom event controllingfieldevent fired');
            this.dispatchEvent(upEvent);
        }
    }

     @api 
    displayDependentFieldonload(){

        var recordeFieldValue = this.recordValue ? this.recordValue[this.fieldname] : 'undefined';
        //this.recordOnLoad? this.recordOnLoad[this.fieldname]:'';
        //
        //console.log('firing controlling field event:::',this.fieldname, '::ObjName', this.sobjectname, ':::fieldValue=', this.fieldValue,':::recordeFieldValue='+ recordeFieldValue);
        
        var controllingFieldSelectedValue =  this.fieldValue ? this.fieldValue : recordeFieldValue; //to include boolean and picklist blank value
        let indx = (this.sapid) ? this.sapid : (this.index)? this.index  : this.privateRecord? this.privateRecord.Id : ''; //during new registration saved record will have record id istead of SAP id
        //console.log(' this.index::::: ', indx);
        //if(controllingFieldSelectedValue){
            const detail = {
                    controllingFieldSobjectName: this.sobjectname,
                    controllingFieldName: this.fieldname,
                    controllingFieldSelectedValue: controllingFieldSelectedValue,
                    instancetype : this.instancetype,
                    objecttype : this.objecttype,
                    index: indx,
                    sapid: this.sapid                
            };
            // Dispatches the event.
            //console.log('detail onload::',detail);
           return detail;
        //}
       
    }
    @api 
    displayDependentField(newFieldvalue){

        var recordeFieldValue = this.recordValue ? this.recordValue[this.fieldname] : '';
        //this.recordOnLoad? this.recordOnLoad[this.fieldname]:'';
        //
        //console.log('firing controlling field event:::'+ this.objecttype, ':::fieldValue=', this.fieldValue,':::newFiedlValue='+ newFieldvalue+':::recordeFieldValue='+ recordeFieldValue);
        var controllingFieldSobjectName = this.sobjectname;
        var controllingFieldName = this.fieldname;
        //(newFieldvalue || fieldVal===false|| fieldVal===0 ) 
        var controllingFieldSelectedValue = (!(typeof newFieldvalue === "undefined" || newFieldvalue=== null || newFieldvalue=== ''))?  newFieldvalue : this.fieldValue ? this.fieldValue : recordeFieldValue; //to include boolean and picklist blank value
        let indx = (this.sapid) ? this.sapid : (this.index)? this.index  : this.privateRecord? this.privateRecord.Id : ''; //during new registration saved record will have record id istead of SAP id
        //console.log(' this.index::::: ', indx);
       // if(controllingFieldSelectedValue){
             var selectedEvent = new CustomEvent('controllingfieldevent', {
             detail: {
                    controllingFieldSobjectName: controllingFieldSobjectName,
                    controllingFieldName: controllingFieldName,
                    controllingFieldSelectedValue: controllingFieldSelectedValue,
                    instancetype : this.instancetype,
                    objecttype : this.objecttype,
                    index: indx,
                    sapid: this.sapid
                }
            });
            // Dispatches the event.
            //console.log('custom event controllingfieldevent fired');
            this.dispatchEvent(selectedEvent);
       // }
       
    }

    @api getUserEnteredInput() {
      
        //console.log('this.template.querySelector(".commoninputcmp")>>>>>>>>>>>>', this.template.querySelector(".commoninputcmp"));
        var inputCmp = this.template.querySelector(".commoninputcmp");
        //console.log('inside getUserEnteredInput>>>>>>>>>>>>>>>>>>>'+inputCmp.label);
        //console.log('input val>>>>>>>>>>>>', inputCmp.value +'fieldname'+ this.fieldname);
        
        var value = inputCmp.value;
        if(this.fieldname == 'Product_Interest_AGN__c'){
            return inputCmp.value; 
        }
        if(this.isBoolean){
            //console.log('input checked>>>>>>>>>>>>', inputCmp.checked +'fieldname'+ this.fieldname);
            return inputCmp.checked;            
        }
        return value;
    }

    @api isFormatValid() {
        var formatValid = true;
        var value = this.getUserEnteredInput();
        var regex = this.regex;
        if (value && regex) {
            if (value.match(regex)) {
                formatValid = true;
            } else {
                formatValid = false;
            }
        }
        return formatValid;
    }
  

    @api getSAPId() {        
        return this.sapid;
    }

    @api setCustomErrorMessage(errorMsg) {
        var inputCmp = this.template.querySelector(".commoninputcmp");
        inputCmp.setCustomValidity(errorMsg);
    }

    @api checkValidity1() {
        var inputCmp = this.template.querySelector(".commoninputcmp");
        //return inputCmp.reportValidity();
        //console.log(`commoninput | checkvalidity :: isactive : ${this.isActiveField()}  fieldValue : ${inputCmp.value}`);
        return (!this.isActiveField() && !inputCmp.value) ? true : inputCmp.reportValidity();        
    }
    @api checkValidity() {
        var inputCmp = this.template.querySelector(".commoninputcmp");
        //return inputCmp.reportValidity();
        return (!this.isActiveField() && !inputCmp.value) ? true : inputCmp.reportValidity();
    }

   /* @wire(getFieldMetadata, {
        sobjectName: '$sobjectname',
        fieldName: '$fieldname',
        controllingFieldValue: '$controllingFieldValue'
    })
    wiredmetadata({
        error,
        data
    }) {
        if (data) {
            //console.log('fieldname>>>>'+this.fieldname+' displayType >>>>' + data.displayType + ' countrycode>>> '+this.country);

            if (this.displayType === undefined) {
                this.displayType = data.displayType;
            }

            if (this.required === undefined) {
                var isUpdateableRequired = data.isUpdateable && data.required;
                var isUpdateableNameField = data.isUpdateable && data.isNameField;
                this.required = isUpdateableRequired || isUpdateableNameField;
            }           
            switch (data.displayType) {
                case 'STRING':
                    this.isString = true;
                    break;
                case 'PHONE':
                    this.isPhone = true;
                    break;
                case 'URL':
                    this.isUrl = true;
                    break;
                case 'TEXTAREA':
                    this.isTextArea = true;
                    break;
                case 'PERCENT':
                    this.isPercent = true;
                    break;
                case 'EMAIL':
                    this.isString = true;
                    break;
                case 'PICKLIST':
                    this.isPicklist = true;
                    break;
                case 'DOUBLE':
                    this.isNumber = true;
                    break;
                case 'INTEGER':
                    this.isNumber = true;
                    break;
                case 'DATE':
                    this.isDate = true;
                    break;
                case 'DATETIME':
                    this.isDateTime = true;
                    break;
                case 'CURRENCY':
                    this.isCurrency = true;
                    break;
                case 'BOOLEAN':
                    this.isBoolean = true;
                    break;
                case 'MULTIPICKLIST':                              
                    this.isMultiSelect = true;
                    break;
                case 'REFERENCE':                              
                    this.isPicklist = true;
                    this.isReference = true;
                    break;
                default:
                    this.isString = true;
                    break;
            }
            if (data.displayType === 'PICKLIST' && data.picklistOptions) {
                var picklistOptionsVal = [];
                var country = this.country;
                var sobjectName = this.sobjectname;
                var fieldName = this.fieldname;
                var optionsEmptymap = new Map();
                
                picklistOptionsVal.push(optionsEmptymap);
                if (this.picklistOptionValues) {
                    var avilableOptions = this.picklistOptionValues.split(';');
                    var optionsmap = new Map();
                    for (var i in avilableOptions) {
                        optionsmap.set(avilableOptions[i], avilableOptions[i]);
                    }
                    
                    for (var i in data.picklistOptions) {
                        if (optionsmap.get(data.picklistOptions[i].value)) {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }
                    }
                } else {
                    for (var i in data.picklistOptions) {
                        if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                            if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                                if (data.picklistOptions[i].value.startsWith(country + '-')) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            } else {
                                if (country && data.picklistOptions[i].value.startsWith(country)) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            }
                        } else {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }

                    }
                }

               

                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                this.picklistOptions = picklistOptionsVal;
                //console.log('picklistOptionValues::::', this.picklistOptions);
            }
            if (data.displayType === 'MULTIPICKLIST' && data.picklistOptions) 
            {
                if(this.fieldname == 'Product_Interest_AGN__c'){
                   
                    this.getPicklistOptions();
                }
                else{
                this.isMultiSelectNR = true;
                var picklistOptionsVal = [];
                var country = this.country;
                var sobjectName = this.sobjectname;
                var fieldName = this.fieldname;
                if (this.picklistOptionValues) {
                    var avilableOptions = this.picklistOptionValues.split(';');
                    var optionsmap = new Map();
                    for (var i in avilableOptions) {
                        optionsmap.set(avilableOptions[i], avilableOptions[i]);
                    }

                    for (var i in data.picklistOptions) {
                        if (optionsmap.get(data.picklistOptions[i].value)) {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }
                    }
                } else {
                    for (var i in data.picklistOptions) {
                        if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                            if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                                if (data.picklistOptions[i].value.startsWith(country + '-')) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            } else {
                                if (country && data.picklistOptions[i].value.startsWith(country)) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            }
                        } else {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }

                    }
                }

                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                this.picklistOptions = picklistOptionsVal;

                //console.log('picklistOptionValues::::', this.picklistOptions);
                }
            }
            var countryCode = this.country;
            if(data.displayType === 'REFERENCE' && countryCode.toUpperCase() ==='DE')
            {
                getSpecialityDetails({
                    countryCode : countryCode
                }).then(result =>{
                        //console.log('Reference result>>>',result);
                        //console.log('Reference result2>>>',this.fieldValue);
                        var picklistOptionsVal = [];
                        var optionsmap = new Map();
                        for (var opt in result){
                          
                            if(this.fieldValue &&  result[opt].Id === this.fieldValue ){
                                picklistOptionsVal.push({
                                    isDefaultValue :true,
                                    label :result[opt].Translated_Value_AGN__c,
                                    value :result[opt].Translated_Value_AGN__c,
                                    Id : result[opt].Id                                                                 
                                });
                                this.fieldValue = result[opt].Translated_Value_AGN__c;
                            }
                            else{
                                picklistOptionsVal.push({
                                    isDefaultValue :false,
                                    label :result[opt].Translated_Value_AGN__c,
                                    value :result[opt].Translated_Value_AGN__c,
                                    Id : result[opt].Id    
                                });
                            }
                            //console.log('Reference result222>>>',result[opt]);
                        
                        }
                        //console.log('picklistOptionsVal##>',picklistOptionsVal);
                        this.picklistOptions = picklistOptionsVal;
                }).catch(error=>{
                    //console.log('error>>>>>>>>>>>>>>', error);
                });

            }
           


        } else if (error) {
            //console.log('error>>>>>>>>>>>>>>', error);
            this.metadataval = undefined;
        }
        else {
            //console.log('wire else -> ' + this.controllingFieldValue);
        }

    }
 */
    getFieldMetadata(){
        getFieldMetadata({
            sobjectName: this.sobjectname,
            fieldName: this.fieldname,
            controllingFieldValue: this.controllingFieldValue
        })
        .then(data => {
             //console.log('fieldname>>>>'+this.fieldname+' displayType >>>>' + data.displayType + ' countrycode>>> '+this.country);
             //console.log('data>>>>'+data);
            if (this.displayType === undefined) {
                this.displayType = data.displayType;
            }

            if (this.required === undefined) {
                var isUpdateableRequired = data.isUpdateable && data.required;
                var isUpdateableNameField = data.isUpdateable && data.isNameField;
                this.required = isUpdateableRequired || isUpdateableNameField;
            }           
            switch (data.displayType) {
                case 'STRING':
                    this.isString = true;
                    break;
                case 'PHONE':
                    this.isPhone = true;
                    break;
                case 'URL':
                    this.isUrl = true;
                    break;
                case 'TEXTAREA':
                    this.isTextArea = true;
                    break;
                case 'PERCENT':
                    this.isPercent = true;
                    break;
                case 'EMAIL':
                    this.isString = true;
                    break;
                case 'PICKLIST':
                    this.isPicklist = true;
                    break;
                case 'DOUBLE':
                    this.isNumber = true;
                    break;
                case 'INTEGER':
                    this.isNumber = true;
                    break;
                case 'DATE':
                    this.isDate = true;
                    break;
                case 'DATETIME':
                    this.isDateTime = true;
                    break;
                case 'CURRENCY':
                    this.isCurrency = true;
                    break;
                case 'BOOLEAN':
                    this.isBoolean = true;
                    break;
                case 'MULTIPICKLIST':                              
                    this.isMultiSelect = true;
                    break;
                case 'REFERENCE':                              
                    this.isPicklist = true;
                    this.isReference = true;
                    break;
                default:
                    this.isString = true;
                    break;
            }
            if (data.displayType === 'PICKLIST' && data.picklistOptions) {
                var picklistOptionsVal = [];
                var country = this.country;
                var sobjectName = this.sobjectname;
                var fieldName = this.fieldname;
                var optionsEmptymap = new Map();
                
                picklistOptionsVal.push(optionsEmptymap);
                if (this.picklistOptionValues) {
                    var avilableOptions = this.picklistOptionValues.split(';');
                    var optionsmap = new Map();
                    for (var i in avilableOptions) {
                        optionsmap.set(avilableOptions[i], avilableOptions[i]);
                    }
                    
                    for (var i in data.picklistOptions) {
                        if (optionsmap.get(data.picklistOptions[i].value)) {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }
                    }
                } else {
                    for (var i in data.picklistOptions) {
                        if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                            if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                                if (data.picklistOptions[i].value.startsWith(country + '-')) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            } else {
                                if (country && data.picklistOptions[i].value.startsWith(country)) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            }
                        } else {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }

                    }
                }
                //console.log('picklistOptionsVal::::',picklistOptionsVal);
                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                this.picklistOptions = picklistOptionsVal;
                //console.log('picklistOptionValues::::', this.picklistOptions);
            }
            if (data.displayType === 'MULTIPICKLIST' && data.picklistOptions) 
            {
                if(this.fieldname == 'Product_Interest_AGN__c'){
                   
                    this.getPicklistOptions();
                }
                else{
                this.isMultiSelectNR = true;
                var picklistOptionsVal = [];
                var country = this.country;
                var sobjectName = this.sobjectname;
                var fieldName = this.fieldname;
                if (this.picklistOptionValues) {
                    var avilableOptions = this.picklistOptionValues.split(';');
                    var optionsmap = new Map();
                    for (var i in avilableOptions) {
                        optionsmap.set(avilableOptions[i], avilableOptions[i]);
                    }

                    for (var i in data.picklistOptions) {
                        if (optionsmap.get(data.picklistOptions[i].value)) {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }
                    }
                } else {
                    for (var i in data.picklistOptions) {
                        if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                            if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                                if (data.picklistOptions[i].value.startsWith(country + '-')) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            } else {
                                if (country && data.picklistOptions[i].value.startsWith(country)) {
                                    picklistOptionsVal.push(data.picklistOptions[i]);
                                }
                            }
                        } else {
                            picklistOptionsVal.push(data.picklistOptions[i]);
                        }

                    }
                }

                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                this.picklistOptions = picklistOptionsVal;

                //console.log('picklistOptionValues::::', this.picklistOptions);
                }
            }
            var countryCode = this.country;
            if(data.displayType === 'REFERENCE')
            {
                if(this.fieldname =='Specialty_Allergan_1_AGN__c'){
                  getSpecialityDetails({
                      countryCode : countryCode
                  }).then(result =>{
                       //console.log('Reference result>>>',result);
                       //console.log('Reference result2>>>',this.fieldValue);
                            var picklistOptionsVal = [];
                            var optionsmap = new Map();
                            for (var opt in result){

                            /*picklistOptionsVal.push({
                                    isDefaultValue :false,
                                    label :result[opt].Translated_Value_AGN__c,
                                    value :result[opt].Translated_Value_AGN__c,
                                    Id : result[opt].Id    
                                });*/
                                if(this.fieldValue &&  result[opt].Id === this.fieldValue ){
                                    if(this.source === 'oam'){
                                        let transLatedValue = (result[opt].Translated_Value_AGN__c)?result[opt].Translated_Value_AGN__c : result[opt].English_Value_AGN__c;
                                        picklistOptionsVal.push({
                                            isDefaultValue :true,
                                            label :transLatedValue,
                                            value :transLatedValue,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        this.fieldValue = transLatedValue;
                                    }else{
                                        picklistOptionsVal.push({
                                            isDefaultValue :true,
                                            label :result[opt].English_Value_AGN__c,
                                            value :result[opt].English_Value_AGN__c,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        this.fieldValue = result[opt].English_Value_AGN__c;
                                    }
                                }
                                else{
                                    if(this.source === 'oam'){
                                        let transLatedValue = (result[opt].Translated_Value_AGN__c)?result[opt].Translated_Value_AGN__c : result[opt].English_Value_AGN__c;
                                        picklistOptionsVal.push({
                                            isDefaultValue :false,
                                            label :transLatedValue,
                                            value :transLatedValue,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                    }else{
                                        picklistOptionsVal.push({
                                            isDefaultValue :false,
                                            label :result[opt].English_Value_AGN__c,
                                            value :result[opt].English_Value_AGN__c,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        
                                    }
                                }
                                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                                //console.log('Reference result222>>>',result[opt]);
                                
                            /*  optionsmap.set(opt,{
                                    isDefaultValue :false,
                                    label :result[opt].Translated_Value_AGN__c,
                                    value :result[opt].Id
                                });*/
                            }
                            //console.log('picklistOptionsVal##>',picklistOptionsVal);
                            this.picklistOptions = picklistOptionsVal;
                    }).catch(error=>{
                        console.log('error>>>>>>>>>>>>>>', error);
                    });
                }else if(this.fieldname == 'Sub_Specialty_Allergan_AGN__c'){
                    getSubSpecialityDetails({
                        countryCode : countryCode
                    }).then(result => {
                        //console.log('result::::',result);
                        var picklistOptionsVal = [];
                            var optionsmap = new Map();
                            for (var opt in result){
                            
                                if(this.fieldValue &&  result[opt].Id === this.fieldValue ){
                                    if(this.source === 'oam'){                                      
                                        picklistOptionsVal.push({
                                            isDefaultValue :true,
                                            label :result[opt].Name,
                                            value :result[opt].Id ,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        this.fieldValue = result[opt].Id;
                                    }else{
										let transLatedValue = (result[opt].English_Value_AGN__c)? result[opt].English_Value_AGN__c : result[opt].Name;
                                        picklistOptionsVal.push({
                                            isDefaultValue :true,
                                            label :transLatedValue,
                                            value :result[opt].Id,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        this.fieldValue = result[opt].Id;
                                    }
                                
                                    
                                }
                                else{
                                    if(this.source === 'oam'){                                       
                                        picklistOptionsVal.push({
                                            isDefaultValue :false,
                                            label :result[opt].Name,
                                            value :result[opt].Id,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                    }else{
									let transLatedValue = (result[opt].English_Value_AGN__c)? result[opt].English_Value_AGN__c : result[opt].Name;
                                        picklistOptionsVal.push({
                                            isDefaultValue :false,
                                            label :transLatedValue,
                                            value :result[opt].Id,
                                            Id : result[opt].Id                                                                                                     
                                        });
                                        
                                    }
                                }
                            
                                picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                            }   
                            //console.log('picklistOptionsVal##>',picklistOptionsVal);
                            this.picklistOptions = picklistOptionsVal;

                    }).catch(error => {
                        console.log('error :::: ', error);
                    });
                }               

            }
        })
        .catch(error =>{
            console.log('Error Metadata :::::', error);
        })
    }

    /*getAllFieldsMetadata(){
        //console.log('cachedFields_Input_APEX :::::', JSON.stringify(this.cachedFields));
        getAllFieldsMetadata({
            fieldListJSON: JSON.stringify(this.cachedFields)
        })
        .then(data => {
            //console.log('Response-data:::::', JSON.stringify(data));
            
            this.setFieldMetadata (data.find(field => { 
                return field.name === this.fieldname && field.sobjectName === this.sobjectname}))
        })
        .catch(error =>{
            //console.log('Error fetching All Metadata :::::', error);
        })
    }*/
    
    setFieldMetadata(data){
        //console.log('fieldname>>>>'+this.fieldname+' displayType >>>>' + data.displayType + ' countrycode>>> '+this.country);
        //console.log('data>>>>'+data);
       if (this.displayType === undefined) {
           this.displayType = data.displayType;
       }

       if (this.required === undefined) {
           var isUpdateableRequired = data.isUpdateable && data.required;
           var isUpdateableNameField = data.isUpdateable && data.isNameField;
           this.required = isUpdateableRequired || isUpdateableNameField;
       }           
       switch (data.displayType) {
           case 'STRING':
               this.isString = true;
               break;
           case 'PHONE':
               this.isPhone = true;
               break;
           case 'URL':
               this.isUrl = true;
               break;
           case 'TEXTAREA':
               this.isTextArea = true;
               break;
           case 'PERCENT':
               this.isPercent = true;
               break;
           case 'EMAIL':
               this.isString = true;
               break;
           case 'PICKLIST':
               this.isPicklist = true;
               break;
           case 'DOUBLE':
               this.isNumber = true;
               break;
           case 'INTEGER':
               this.isNumber = true;
               break;
           case 'DATE':
               this.isDate = true;
               break;
           case 'DATETIME':
               this.isDateTime = true;
               break;
           case 'CURRENCY':
               this.isCurrency = true;
               break;
           case 'BOOLEAN':
               this.isBoolean = true;
               break;
           case 'MULTIPICKLIST':                              
               this.isMultiSelect = true;
               break;
           case 'REFERENCE':                              
               this.isPicklist = true;
               this.isReference = true;
               break;
           default:
               this.isString = true;
               break;
       }
       if (data.displayType === 'PICKLIST' && data.picklistOptions) {
           var picklistOptionsVal = [];
           var country = this.country;
           var sobjectName = this.sobjectname;
           var fieldName = this.fieldname;
           var optionsEmptymap = new Map();
           
           picklistOptionsVal.push(optionsEmptymap);
           if (this.picklistOptionValues) {
               var avilableOptions = this.picklistOptionValues.split(';');
               var optionsmap = new Map();
               for (var i in avilableOptions) {
                   optionsmap.set(avilableOptions[i], avilableOptions[i]);
               }
               
               for (var i in data.picklistOptions) {
                   if (optionsmap.get(data.picklistOptions[i].value)) {
                       picklistOptionsVal.push(data.picklistOptions[i]);
                   }
               }
           } else {
               for (var i in data.picklistOptions) {
                   if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                       if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                           if (data.picklistOptions[i].value.startsWith(country + '-')) {
                               picklistOptionsVal.push(data.picklistOptions[i]);
                           }
                       } else {
                           if (country && data.picklistOptions[i].value.startsWith(country)) {
                               picklistOptionsVal.push(data.picklistOptions[i]);
                           }
                       }
                   } else {
                       picklistOptionsVal.push(data.picklistOptions[i]);
                   }

               }
           }
           //console.log('picklistOptionsVal::::',picklistOptionsVal);
           picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
           this.picklistOptions = picklistOptionsVal;
           //console.log('picklistOptionValues::::', this.picklistOptions);
       }
       if (data.displayType === 'MULTIPICKLIST' && data.picklistOptions) 
       {
           if(this.fieldname == 'Product_Interest_AGN__c'){
              
               this.getPicklistOptions();
           }
           else{
           this.isMultiSelectNR = true;
           var picklistOptionsVal = [];
           var country = this.country;
           var sobjectName = this.sobjectname;
           var fieldName = this.fieldname;
           if (this.picklistOptionValues) {
               var avilableOptions = this.picklistOptionValues.split(';');
               var optionsmap = new Map();
               for (var i in avilableOptions) {
                   optionsmap.set(avilableOptions[i], avilableOptions[i]);
               }

               for (var i in data.picklistOptions) {
                   if (optionsmap.get(data.picklistOptions[i].value)) {
                       picklistOptionsVal.push(data.picklistOptions[i]);
                   }
               }
           } else {
               for (var i in data.picklistOptions) {
                   if (sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C') {
                       if (country && (country.toUpperCase() === 'CA' || country.toUpperCase() === 'AU' || country.toUpperCase() === 'AN' || country.toUpperCase() === 'NZ')) {
                           if (data.picklistOptions[i].value.startsWith(country + '-')) {
                               picklistOptionsVal.push(data.picklistOptions[i]);
                           }
                       } else {
                           if (country && data.picklistOptions[i].value.startsWith(country)) {
                               picklistOptionsVal.push(data.picklistOptions[i]);
                           }
                       }
                   } else {
                       picklistOptionsVal.push(data.picklistOptions[i]);
                   }

               }
           }

           picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
           this.picklistOptions = picklistOptionsVal;

           //console.log('picklistOptionValues::::', this.picklistOptions);
           }
       }
       var countryCode = this.country;
       if(data.displayType === 'REFERENCE')
       {
           if(this.fieldname =='Specialty_Allergan_1_AGN__c'){
               getSpecialityDetails({
               countryCode : countryCode
               }).then(result =>{
                       //console.log('Reference result>>>',result);
                       //console.log('Reference result2>>>',this.fieldValue);
                       var picklistOptionsVal = [];
                       var optionsmap = new Map();
                       for (var opt in result){

                       /*picklistOptionsVal.push({
                               isDefaultValue :false,
                               label :result[opt].Translated_Value_AGN__c,
                               value :result[opt].Translated_Value_AGN__c,
                               Id : result[opt].Id    
                           });*/
                           if(this.fieldValue &&  result[opt].Id === this.fieldValue ){
                               if(this.source === 'oam'){
                                   let transLatedValue = (result[opt].Translated_Value_AGN__c)?result[opt].Translated_Value_AGN__c : result[opt].English_Value_AGN__c;
                                   picklistOptionsVal.push({
                                       isDefaultValue :true,
                                       label :transLatedValue,
                                       value :transLatedValue,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   this.fieldValue = transLatedValue;
                               }else{
                                   picklistOptionsVal.push({
                                       isDefaultValue :true,
                                       label :result[opt].English_Value_AGN__c,
                                       value :result[opt].English_Value_AGN__c,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   this.fieldValue = result[opt].English_Value_AGN__c;
                               }
                           }
                           else{
                               if(this.source === 'oam'){
                                   let transLatedValue = (result[opt].Translated_Value_AGN__c)?result[opt].Translated_Value_AGN__c : result[opt].English_Value_AGN__c;
                                   picklistOptionsVal.push({
                                       isDefaultValue :false,
                                       label :transLatedValue,
                                       value :transLatedValue,
                                       Id : result[opt].Id                                                                                                     
                                   });
                               }else{
                                   picklistOptionsVal.push({
                                       isDefaultValue :false,
                                       label :result[opt].English_Value_AGN__c,
                                       value :result[opt].English_Value_AGN__c,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   
                               }
                           }
                           picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                           //console.log('Reference result222>>>',result[opt]);
                           
                       /*  optionsmap.set(opt,{
                               isDefaultValue :false,
                               label :result[opt].Translated_Value_AGN__c,
                               value :result[opt].Id
                           });*/
                       }
                       //console.log('picklistOptionsVal##>',picklistOptionsVal);
                       this.picklistOptions = picklistOptionsVal;
               }).catch(error=>{
                   console.log('error>>>>>>>>>>>>>>', error);
               });
           }else if(this.fieldname == 'Sub_Specialty_Allergan_AGN__c'){
               getSubSpecialityDetails({
                   countryCode : countryCode
               }).then(result => {
                   //console.log('result::::',result);
                   var picklistOptionsVal = [];
                       var optionsmap = new Map();
                       for (var opt in result){
                       
                           if(this.fieldValue &&  result[opt].Id === this.fieldValue ){
                               if(this.source === 'oam'){                                      
                                   picklistOptionsVal.push({
                                       isDefaultValue :true,
                                       label :result[opt].Name,
                                       value :result[opt].Id ,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   this.fieldValue = result[opt].Id;
                               }else{
                                   let transLatedValue = (result[opt].English_Value_AGN__c)? result[opt].English_Value_AGN__c : result[opt].Name;
                                   picklistOptionsVal.push({
                                       isDefaultValue :true,
                                       label :transLatedValue,
                                       value :result[opt].Id,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   this.fieldValue = result[opt].Id;
                               }
                           
                               
                           }
                           else{
                               if(this.source === 'oam'){                                       
                                   picklistOptionsVal.push({
                                       isDefaultValue :false,
                                       label :result[opt].Name,
                                       value :result[opt].Id,
                                       Id : result[opt].Id                                                                                                     
                                   });
                               }else{
                               let transLatedValue = (result[opt].English_Value_AGN__c)? result[opt].English_Value_AGN__c : result[opt].Name;
                                   picklistOptionsVal.push({
                                       isDefaultValue :false,
                                       label :transLatedValue,
                                       value :result[opt].Id,
                                       Id : result[opt].Id                                                                                                     
                                   });
                                   
                               }
                           }
                       
                           picklistOptionsVal.sort((a, b) => (a.value > b.value) ? 1 : -1);
                       }   
                       //console.log('picklistOptionsVal##>',picklistOptionsVal);
                       this.picklistOptions = picklistOptionsVal;

               }).catch(error => {
                   console.log('error :::: ', error);
               });
           }               

       }
    }
    getPicklistOptions(){
        getPicklistOptions(
            {
                ObjectName : this.sobjectname,
                fieldName : this.fieldname
            }
        ).then(result => {
            //console.log('Product Interest resultdfd>>>>>>>>>>>>>>>>>>>>>>>',result); 
            let options = result;
            var prodOptions = [];
            let configCategoryValue='';
            let configSubCategoryValue='';
            let configCategoryLabelValue='';
            let configSubCategoryLabelValue='';
            var optionMap = new Map();
            //console.log('optionMap1>>>',optionMap);  
            var custConfig = this.custtypeconfig;
            options.forEach(val=>{                
                optionMap.set(val.value,val.label);
            }); 
            //console.log('optionMap>>>',optionMap);  
            if(optionMap.size >0){
                this.isProductOfinterest =true;
            }       
            if(custConfig && optionMap )
            {
                //console.log('this.optionMap>>>',optionMap); 
                custConfig.forEach(confg=>{
                 configCategoryValue = confg.Category_AGN__c;
                 configSubCategoryValue = confg.Sub_Category__c;
                 configCategoryLabelValue=confg.Category_Label_AGN__c;
                 configSubCategoryLabelValue=confg.Sub_Category_Label_AGN__c;
                    if(this.customertype && this.customersubtype && confg.Product_Interest_AGN__c 
                    && (configCategoryValue.toUpperCase() == this.customertype.toUpperCase() || configCategoryLabelValue.toUpperCase() == this.customertype.toUpperCase())
                    && (configSubCategoryValue.toUpperCase() == this.customersubtype.toUpperCase() || configSubCategoryLabelValue.toUpperCase() == this.customersubtype.toUpperCase())
                    && confg.Customer_Country_AGN__r.Name == this.countrycode)
                    {
                        var ops = confg.Product_Interest_AGN__c.split(';');
						//console.log('ops:::::::: ',ops);
                        if(ops){                           
                            ops.forEach(op=>{                                 
                                if(optionMap.has(op)){                                    
                                    prodOptions.push({label : optionMap.get(op) , value : op});
                                }
                            });
                        }
                    }
                });
            }
            //console.log('prodOptions>>>>>',prodOptions);
            this.optionList = prodOptions;            
        }).catch(error =>
            {
                console.log('error layout>>>>>>>>>>>>>>>>>>>' + JSON.stringify(error));
                // this.error = error;                
                //this.template.querySelector('c-agn_gcsp_custom-toast').showCustomNotice();

            });

    }


}