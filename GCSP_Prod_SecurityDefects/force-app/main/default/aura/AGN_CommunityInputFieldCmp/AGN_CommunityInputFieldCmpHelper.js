({
    cachedResults : {},
    fetchFieldMetadata : function(component, event) {
        var sobjectName = component.get('v.sobjectName');
        var fieldName = component.get('v.fieldName');
        var cacheKey = sobjectName + fieldName;
        
        //if(this.cachedResults.hasOwnProperty(cacheKey)) {
        if(false) {
            var fieldMetadata = this.cachedResults[cacheKey];
            component.set('v.fieldMetadata', fieldMetadata);
            this.setFieldMetadataAttributes(component, event, fieldMetadata);
        } else {
            var action = component.get('c.getFieldMetadata');
            action.setParams({
                'sobjectName': component.get('v.sobjectName'),
                'fieldName': component.get('v.fieldName')
            });
            //action.setStorable();
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var fieldMetadata = response.getReturnValue();
                    
                    //Tax Exempted
                    if(sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'TAX_EXEMPTED_AGN__C'){
                        if(component.get('v.customCountryCode') != 'IT'){
                            var picklistOptionArr = [];
                            //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                            for(var i in fieldMetadata.picklistOptions){
                                if(fieldMetadata.picklistOptions[i].value.toUpperCase() ==='9' || fieldMetadata.picklistOptions[i].value.toUpperCase() ==='0'){
                                    picklistOptionArr.push(fieldMetadata.picklistOptions[i]);                                    
                                }
                            }
                            fieldMetadata.picklistOptions = picklistOptionArr;
                        }
                    }
                    
                    //State_AGN__c hack
                    
                    if(sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'STATE_AGN__C'){
                        
                        var picklistOptionArr = [];
                        picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        console.log('State with countr---->'  + component.get('v.customCountryCode'));
                        
                        if(component.get('v.customCountryCode') === 'CA'){
                            for(var i in fieldMetadata.picklistOptions){
                                if(fieldMetadata.picklistOptions[i].value.startsWith(component.get('v.customCountryCode')+'-'))
                                    picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                            }
                            fieldMetadata.picklistOptions = picklistOptionArr;
                        }else if(component.get('v.customCountryCode') === 'AU' || component.get('v.customCountryCode') === 'NZ' || component.get('v.customCountryCode') ==='AN'){
                            for(var i in fieldMetadata.picklistOptions){
                                if(fieldMetadata.picklistOptions[i].value.startsWith(component.get('v.customCountryCode')+'-'))
                                    picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                            }
                            fieldMetadata.picklistOptions = picklistOptionArr;
                        }else{
                            for(var i in fieldMetadata.picklistOptions){                               
                                if(fieldMetadata.picklistOptions[i].value.startsWith(component.get('v.customCountryCode')))
                                    picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                //console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                            }
                            fieldMetadata.picklistOptions = picklistOptionArr;
                            // console.log('StateValues>>>'+JSON.stringify(picklistOptionArr));
                        }
                    }
                    //Removing Miss and MS Values for Country Germany
                    if(component.get('v.customCountryCode') === 'DE' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'SALUTATION_AGN__C'){
                        var picklistOptionArr = [];
                        //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        for(var i in fieldMetadata.picklistOptions){
                            if(fieldMetadata.picklistOptions[i].value !='Ms.' && fieldMetadata.picklistOptions[i].value !='Miss' && fieldMetadata.picklistOptions[i].value !='Pr.' && fieldMetadata.picklistOptions[i].value !='Dra.'){
                                
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                // console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                                
                            }
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    //Removing Sister and Nurse,Pr Values for Country Italy
                    if(component.get('v.customCountryCode') === 'IT' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'SALUTATION_AGN__C'){
                        var picklistOptionArr = [];
                        //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        for(var i in fieldMetadata.picklistOptions){
                            if(fieldMetadata.picklistOptions[i].value !='Sister' && fieldMetadata.picklistOptions[i].value !='Nurse' && fieldMetadata.picklistOptions[i].value !='Pr.' && fieldMetadata.picklistOptions[i].value !='Dra.'){
                                
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                // console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                                
                            }
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    //Removing Nurse Values for Country Canada
                    if(component.get('v.customCountryCode') === 'CA' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'SALUTATION_AGN__C'){
                        var picklistOptionArr = [];
                        //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        for(var i in fieldMetadata.picklistOptions){
                            if(fieldMetadata.picklistOptions[i].value !='Nurse'){
                                
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                // console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                            }
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    
                    //Removing Sister and Nurse,Miss,Ms. Values for Country FR
                    if(component.get('v.customCountryCode') === 'FR' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'SALUTATION_AGN__C'){
                        var picklistOptionArr = [];
                        //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        for(var i in fieldMetadata.picklistOptions){
                            if(fieldMetadata.picklistOptions[i].value !='Sister' && fieldMetadata.picklistOptions[i].value !='Nurse' && fieldMetadata.picklistOptions[i].value !='Miss'
                               && fieldMetadata.picklistOptions[i].value !='Ms.' && fieldMetadata.picklistOptions[i].value !='Dra.'){
                                
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                // console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                            }
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    //Removing Sister and Nurse,Miss,Pr Values for Country ES
                    if(component.get('v.customCountryCode') === 'ES' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_REGISTRATION_AGN__C' && fieldName.toUpperCase() === 'SALUTATION_AGN__C'){
                        var picklistOptionArr = [];
                        //picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank
                        
                        for(var i in fieldMetadata.picklistOptions){
                            if(fieldMetadata.picklistOptions[i].value !='Sister' && fieldMetadata.picklistOptions[i].value !='Nurse' && fieldMetadata.picklistOptions[i].value !='Miss' && fieldMetadata.picklistOptions[i].value !='Pr.'){
                                
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                // console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));
                            }
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    if(component.get('v.customCountryCode') === 'IT' && sobjectName.toUpperCase() === 'ALLERGAN_CUSTOMER_ADDRESS_AGN__C' && fieldName.toUpperCase() === 'COUNTRY_AGN__C'){
                        
                        var picklistOptionArr = [];
                        picklistOptionArr.push(fieldMetadata.picklistOptions[0]); //added default blank                        
                        for(var i in fieldMetadata.picklistOptions){                             
                            if(fieldMetadata.picklistOptions[i].value =='San Marino' || fieldMetadata.picklistOptions[i].value =='Vatican' || fieldMetadata.picklistOptions[i].value =='Italy'){                              
                                picklistOptionArr.push(fieldMetadata.picklistOptions[i]);
                                //console.log(JSON.stringify(fieldMetadata.picklistOptions[i]));   
                            }                           
                        }
                        fieldMetadata.picklistOptions = picklistOptionArr;
                    }
                    fieldMetadata.picklistOptions.sort((a, b) => (a.value > b.value) ? 1 : -1); //Added by Ravi for soting the PicklistValues
                    component.set('v.fieldMetadata', fieldMetadata);
                    //this.cachedResults[cacheKey] = fieldMetadata;
                    this.setFieldMetadataAttributes(component, event, fieldMetadata);
                } else {
                    console.log(response.getError().length + ' ERRORS');
                    for(var i = 0; i < response.getError().length; i++) {
                        console.log(response.getError()[i]);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    setFieldMetadataAttributes : function(component, event, fieldMetadata) {
        if(component.get('v.displayType') === undefined) {
            component.set('v.displayType', fieldMetadata.displayType);
        }
        if(component.get('v.disabled') === undefined) {
            component.set('v.disabled', fieldMetadata.isUpdateable == false);
        }
        if(component.get('v.required') === undefined) {
            var isUpdateableRequired = fieldMetadata.isUpdateable && fieldMetadata.required;
            var isUpdateableNameField = fieldMetadata.isUpdateable && fieldMetadata.isNameField;
            component.set('v.required', isUpdateableRequired || isUpdateableNameField);
        }
        this.parsePicklistOptions(component, event);
    },
    parseFieldValue : function(component, event) {
        var record = component.get('v.record');
        var fieldName = component.get('v.fieldName');
        if(record === null) return;
        
        if(record.hasOwnProperty(fieldName)) {
            component.set('v.fieldValue', record[fieldName]);
        }
    },
    parsePicklistOptions : function(component, event) {
        var fieldValue = component.get('v.fieldValue');
        var picklistOptions = component.get('v.picklistOptions');
        
        if(picklistOptions === undefined || picklistOptions === null || picklistOptions.length === 0) {
            var fieldMetadata = component.get('v.fieldMetadata');
            
            if(fieldMetadata == null) return;
            
            picklistOptions = fieldMetadata.picklistOptions;
        }
        component.set('v.picklistOptions', picklistOptions);
    },
    handleFieldValueChanged : function(component, event) {
        var changedField  = component.get('v.fieldName');
        var record        = component.get('v.record');
        var fieldValue    = component.get('v.fieldValue');
        var fieldMetadata = component.get('v.fieldMetadata');
        var displayType   = component.get('v.displayType');
        
        //alert(fieldMetadata.displayType);
        
        var newFieldValue = event.getParam('value') !== undefined ? event.getParam('value') : event.getSource().get('v.value');
        //added by sharon to fix dropdown issue - start
        component.set('v.fieldValue' , newFieldValue);
        //added by sharon to fix dropdown issue - end
        if(typeof newFieldValue === 'undefined') newFieldValue = '';
        var oldFieldValue = event.getParam('oldValue') !== undefined ? event.getParam('oldValue') : event.getSource().get('v.oldValue');
        
        var fieldChanged = newFieldValue !== oldFieldValue;
        // If the displayType is different from the field metadata and it should be a string, then cast to strings and compare to see if the field changed
        if(newFieldValue !== null && typeof newFieldValue !== 'string' && fieldMetadata != null && (fieldMetadata.displayType === 'TEXT' || fieldMetadata.displayType === 'TEXTAREA')) {
            var newFieldValueString = newFieldValue == null ? null : newFieldValue.toString();
            var oldFieldValueString = oldFieldValue == null ? null : oldFieldValue.toString();
            fieldChanged = newFieldValueString !== oldFieldValueString;
        }
        
        if(fieldChanged) {
            if(newFieldValue !== null && typeof newFieldValue !== 'string' && fieldMetadata != null && (fieldMetadata.displayType === 'TEXT' || fieldMetadata.displayType === 'TEXTAREA')) {
                newFieldValue = newFieldValue.toString();
            }
            record[changedField] = newFieldValue;
            //console.log(record);
            component.set('v.record', record);
            this.parsePicklistOptions(component, event);
        }
    },
    validateFieldValue : function(component, event) {
        var fieldRequired  = component.get('v.required');
        var fieldValue = component.get('v.fieldValue');
        //test
        component.set("v.fieldValue",fieldValue);
        //test
        var fieldValueMissing = fieldValue === null || fieldValue === '' || fieldValue === undefined;
        //component.set('v.fieldValueMissing', (fieldRequired && fieldValueMissing)); commented by sharon and added below codes 
        if(fieldRequired && fieldValueMissing){
            if(component.get('v.fieldValueMissing')){
                component.set('v.fieldValueMissing', false);
                component.set('v.fieldValueMissing', true);
            }else{
                component.set('v.fieldValueMissing', true);
            }
        }else{
            if(component.get('v.fieldValueMissing')){
                component.set('v.fieldValueMissing', false);
            }else{
                component.set('v.fieldValueMissing', true);
                component.set('v.fieldValueMissing', false);
            }
        }
        
        var fieldMetadata = component.get('v.fieldMetadata');
        this.validate(component, event);
    },
    validate : function(component, event) {
        var field = component.find('inputField');
        var fieldValue = component.get('v.fieldValue');
        var regex = component.get('v.fieldRegex');///^[0-9+ ()-]+$/ ;
        //console.log('regex ' + regex);
        if(regex && !$A.util.isEmpty(field)){   
            if(fieldValue.match(regex)){
                component.set('v.isFormatValid', true);
            }else{
                component.set('v.isFormatValid', false);
            }
        }
    },
    validatePhone : function(component, event) {
        var phoneField = component.find('inputField');
        var phoneFieldValue = component.get('v.fieldValue');
        var phoneRegex = component.get('v.fieldRegex');///^[0-9+ ()-]+$/ ;
        //console.log(phoneRegex);
        if(!$A.util.isEmpty(phoneField)){   
            if(phoneFieldValue.match(phoneRegex)){
                //phoneField.set("v.errors", [{message: null}]);
                //$A.util.removeClass(phoneField, 'slds-has-error');
                component.set('v.isFormatValid', true);
            }else{
                //$A.util.addClass(phoneField, 'slds-has-error');
                //phoneField.set("v.errors", [{message: "Please Enter a Valid Phone Number"}]);
                component.set('v.isFormatValid', false);
            }
        }
    },
    validateEmail : function(component, event) {
        var emailField = component.find('inputField');
        var emailFieldValue = component.get('v.fieldValue');
        var regExpEmailformat =  component.get('v.fieldRegex');///^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        //console.log(regExpEmailformat);
        if(!$A.util.isEmpty(emailFieldValue)){   
            if(emailFieldValue.match(regExpEmailformat)){
                //$A.util.removeClass(emailField, 'slds-has-error');
                //emailField.set("v.errors", [{message: null}]);
                component.set('v.isFormatValid', true);
            }else{
                //$A.util.addClass(emailField, 'slds-has-error');
                //emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                component.set('v.isFormatValid', false);
            }
        }
    }
})