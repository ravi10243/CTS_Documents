({
    fetchCountrySettings : function(component, event) {
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '2'            
            });       
        }
        else{            
            action.setParams({       
                'country': country,    //component.get("v.countryCode"), //v.countryCode v.SAPCountryCode (to fetch meta data configuration)           
                'stepNo': '2',
                'customerType': component.get("v.customerType"),
                'customerSubType': component.get("v.customerSubType"),
                'custTypeConfig': component.get("v.customerTypeConfig")
            });
        } 
        action.setStorable();
        action.setCallback(this, function(response) {
            
            if(response.getState() === 'SUCCESS') {
                var settingsSoldTo = [];
                var settingsBillTo = [];
                var settingsShipTo = [];
                var settingsMap = response.getReturnValue();
                console.log("settings map>>>>>>>>>>>>>>>>>",settingsMap);
                for(var key in settingsMap){
                    if(key.toUpperCase() === 'BILLING ADDRESS'){
                        settingsBillTo.push({value:settingsMap[key], key:key});
                    }else if(key.toUpperCase() === 'SHIPPING ADDRESS'){
                        settingsShipTo.push({value:settingsMap[key], key:key});
                    }else if(key.toUpperCase() === 'REGISTERED ADDRESS'){
                        settingsSoldTo.push({value:settingsMap[key], key:key});
                    }
                }
                component.set('v.sectionHeaderMapSoldTo', settingsSoldTo);
                component.set('v.sectionHeaderMapBillTo', settingsBillTo);
                component.set('v.sectionHeaderMapShipTo', settingsShipTo);
                // console.log('sectionHeaderMapShipTo---->'+JSON.stringify(sectionHeaderMapShipTo));
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchAddressDetails : function(component, event) {
        var soldToAddr;
        var billToAddr = [];
        var shipToAddr = [];
        
        var action = component.get("c.getCustomerAddressDetails");
		 action.setParams({
                'custRegId': component.get("v.custRegID")
            });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var addressList = response.getReturnValue();                  
                
                //console.log('addressList = ' +JSON.stringify(response.getReturnValue()));
                
                //split to SoldTo, ShipTo and BillTo Address
                if(!addressList) return;
                if($A.util.isArray(addressList)){
                    for(var i in addressList){
                       
                        if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                            soldToAddr = addressList[i];
                            
                            component.set("v.objMixType",addressList[i]); 
                           // if(!$A.util.isEmpty(addressList[i].Doctors_Email_AGN__c)){
                           if(!addressList[i].Are_You_The_Prescribing_Doctor_AGN__c){
                                component.find("ctrlChkBox").set("v.value",true); 
                                component.set("v.isPrescribingDr" , true);
                                component.set("v.showPrescribingDr" , false);
                            }
                            //alert('uploadAccowner>>>>'+component.get("v.uploadAccountOwnerDocument")+ '>>>>'+ addressList[i].Doctors_Email_AGN__c);
                            component.set('v.shipToSameAsSoldTo', addressList[i].Ship_To_AGN__c); //will set true/false
                            
                            component.set('v.billToSameAsSoldTo', addressList[i].Bill_To_AGN__c); //will set true/false
                        }
                        if(addressList[i].Ship_To_AGN__c){ //Multiple ShipTo Address will be present                            
                            shipToAddr.push(addressList[i]);
                        }
                        if(addressList[i].Bill_To_AGN__c){ //Multiple BillTo Address will be present
                            billToAddr.push(addressList[i]);
                        }
                    }
                    
                    component.set('v.objSoldTo', soldToAddr); 
                    component.set('v.objBillTo', billToAddr);
                    component.set('v.objShipTo', shipToAddr);
                    
                    if(component.get('v.shipToSameAsSoldTo')){
                        component.set('v.objSoldTo.Ship_To_AGN__c', true);       
                    } 
                    if(component.get('v.billToSameAsSoldTo')){
                        component.set('v.objSoldTo.Bill_To_AGN__c', true);                       
                    }
                    //console.log("isSoldToVerified>>>>>>>>>>>>>>>>>>>>>>>>"+component.get('v.objSoldTo.Is_Verified_Address__c'));
                    component.set("v.isSoldToVerified" , component.get('v.objSoldTo.Is_Verified_Address__c'));
                    var doValidateList = [];
                    shipToAddr.forEach(function(cmp){
                        doValidateList.push(false);              
                    });
                    //console.log("doValidateList>>>>>>>>>>>>>>>>>>>>>>>>>"+doValidateList);
                    component.set("v.doValidateList" , doValidateList);
                    
                    //component.set('v.sectionHeaderMapBillTo', settingsBillTo);
                    //console.log('billToAddr'+billToAddr);
                    if(billToAddr || billToAddr.length == 0){
                        //console.log('billToAddr'+billToAddr);
                        component.set('v.objBillToSectionHdr', component.get('v.sectionHeaderMapBillTo')[0].value[0].Section_Header_Label_AGN__c);                         
                    }
                    if(shipToAddr || shipToAddr.length == 0){
                        component.set('v.objShipToSectionHdr', component.get('v.sectionHeaderMapShipTo')[0].value[0].Section_Header_Label_AGN__c);
                    }
                    
                }
            }
        });
        
        $A.enqueueAction(action);        
        
    },
    
    getGCSPSettingsDetails: function(component, event) {
        var action = component.get("c.getGCSPSettingsDetails");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                 
                component.set('v.gcspSettings',response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    deleteAddress : function(component, event, index, v_objAddress, objAddress) {
        
        var customerAddress = objAddress[index];
        console.log('Address to be removed ' + JSON.stringify(customerAddress));
        var action = component.get('c.deleteAddress');   
        action.setParams({       
            'customerAddress': customerAddress
        });       
        
        action.setCallback(this, function(response) {
            
            if(response.getState() === 'SUCCESS') {
                
                objAddress.splice(index, 1); //removing array of index position
                console.log('Removed data of index ' + index);
                component.set(v_objAddress, objAddress);
                //this.fetchAddressDetails(component, event);               
                component.set("v.showSpinner", false); 
            } else {
                component.set("v.showSpinner", false); 
                this.logActionErrors(component, response);
            }
        });
        
        
        $A.enqueueAction(action);
    },
    
    deleteExistingShip_Bill_To : function(component, event){
        component.set("v.showSpinner", true);  
        var objAddress;
        var v_objAddress;
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value; //ctarget.getAttribute("data-selected-Index");
        console.log(index);
        
        var addressType = ctarget.getAttribute("data-address-type");
        console.log('addressType => '+ addressType);
        
        if(addressType === 'SHIPTO'){
            objAddress = component.get("v.objShipTo");
            v_objAddress = 'v.objShipTo';
            //component.set("v.showHideAddButtonShipTo", 1);
        }
        else if(addressType === 'BILLTO'){
            objAddress = component.get("v.objBillTo");
            v_objAddress = 'v.objBillTo';
           // component.set("v.showHideAddButton", 1);
        }
        
        //calling apex method to delete the address from object
        this.deleteAddress(component, event, index, v_objAddress, objAddress);
        
    },
    sectionValidateAndUpdate : function(component, event) {
        component.set("v.showSpinner", true); 
        console.log('Required is calling :' );  
        //console.log("Field values >>>>>>>>>>  : "+cmp.get("v.fieldValue"));  
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        var ctarget = event.currentTarget;
        var cmpId = ctarget.dataset.value;
        var dataset_name = ctarget.getAttribute("data-set-name");
        
        console.log(cmpId);
        const cmpfield = component.find(cmpId);
        
        
        if (!cmpfield) return;
        if ($A.util.isArray(cmpfield)){
            cmpfield.forEach( function (cmp){
                
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    console.log('is empty');
                    cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                    requiredMissing = true;
                }
                else{
                    cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
            if(requiredMissing){
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                // alert($A.get("$Label.c.AGN_OAM_Body_PleaseFill"));
                component.set("v.showSpinner", false); 
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
            }
            else{
                this.sectionValidateFormatFields(component, event, cmpId, dataset_name);
            }
        }       
    },
    sectionValidateFormatFields: function(component, event, cmpId, dataset_name) {
        jQuery.noConflict();
        var wellFormatted = true;
        var whichFields = '';
        
        const cmpfield = component.find(cmpId);
        
        if (!cmpfield) return;
        if ($A.util.isArray(cmpfield)){ 
            cmpfield.forEach(function (cmp){
                //if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && !$A.util.isEmpty(cmp.get("v.fieldValue")) ){
                if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
                    if(!cmp.get("v.isFormatValid")){
                        //console.log('not formatted');
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        wellFormatted = false;
                        whichFields += cmp.get("v.customLabelName") + ", ";
                    }
                    else{
                        //console.log('formatted');
                        cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                }                
            });
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                component.set("v.showSpinner", false);
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{                
                this.sectionUpdateAddressDetails(component, event, dataset_name);           
            }  
        }
    },
    sectionUpdateAddressDetails : function(component, event, dataset_name) {  
        console.log("Inside sectionUpdateAddressDetails");
        var self = this; 
        var data = [];
        
        if(component.get(dataset_name).length){ //list
            data = component.get(dataset_name);
        }else{
            data.push(component.get(dataset_name));
        }
        
        this.callServerAction(component, "c.updateAddressDetails", {
            'records' : data
        })          
        .then(             
            $A.getCallback(function(resp) {
                console.log('sectionUpdateAddressDetails--'+resp);
                if($A.util.isEmpty(resp)){
                    console.log('sectionUpdateAddressDetails Error');
                    component.set("v.showSpinner", false);
                    self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                } else {
                    component.set("v.showSpinner", false);
                    console.log('Successfully sectionUpdateAddressDetails updated');
                }                                     
            }))
        .catch($A.getCallback(function(errorsresp) {
            self.logActionErrors(component, errorsresp);
        }));    
    },
    
    validateAndUpsert : function(component, event) {
        component.set("v.showSpinner", true);
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        
        const cmpfieldSoldTo = component.find("fieldSoldTo");
        const cmpfieldBillTo = component.find("fieldBillTo");
        const cmpfieldShipTo = component.find("fieldShipTo");
        
        const cmpfieldnewShipTo = component.find("newShipTo");
        const cmpfieldnewBillTo = component.find("newBillTo");
        
        const cmpSBS = [];
        
        if(cmpfieldSoldTo){
            cmpSBS.push(cmpfieldSoldTo);
        }
        
        if(cmpfieldBillTo){
            cmpSBS.push(cmpfieldBillTo);
        }
        
        if(cmpfieldShipTo){
            cmpSBS.push(cmpfieldShipTo);
        }
        
        //adding new shipto, billto
        if(cmpfieldnewShipTo){
            cmpSBS.push(cmpfieldnewShipTo);
        }
        
        if(cmpfieldnewBillTo){
            cmpSBS.push(cmpfieldnewBillTo);
        }
        
        //console.log('cmpSBS'+JSON.stringify(cmpSBS));
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            cmpSBS.forEach( function (cmps){
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        console.log("required field missing>>>>>>>>>>>>>>>>"+cmp.get("v.fieldName"));
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                    }
                    else{
                        cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
            });           
            
            /********* Prescribibg Dr isRequired Starts***********/
            var lcmp = component.find("PrescribingDrField");
            if(!$A.util.isEmpty(lcmp) && component.get("v.isPrescribingDr")){
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                var isPrescribingDrRequired = false;
                var nonMandatoryFields = "";
                var mandatoryFields = "";
                licenseCmp.forEach( function (cmp){
                    if ($A.util.isEmpty(cmp.FieldValue_AGN__c) && cmp.Required_AGN__c){
                        console.log("Prescribibg Dr require field missing>>"+cmp.Field_Name_AGN__c);
                        requiredMissing = true;  
                        cmp.FieldValue_Missing_AGN__c = true;
                        isPrescribingDrRequired = true;
                    }  
                    if(!cmp.Required_AGN__c){
                        nonMandatoryFields = nonMandatoryFields + "-" + cmp.Field_Name_AGN__c;
                    }else{
                        mandatoryFields = mandatoryFields + "-" + cmp.Field_Name_AGN__c;
                    }
                });
                //To display required red color in buying group fields
                if(isPrescribingDrRequired){
                    if($A.util.isArray(lcmp)){
                        lcmp.forEach( function (cmp){
                            cmp.set("v.nonMandatoryFields" , nonMandatoryFields);
                            cmp.set("v.mandatoryFields" , mandatoryFields);
                            var actualVal = cmp.get("v.isRequiredAdded");
                            if(actualVal == true){
                                cmp.set("v.isRequiredAdded" , false);
                            }else{
                                cmp.set("v.isRequiredAdded" , true);
                            }
                        });
                    }else{
                        lcmp.set("v.nonMandatoryFields" , nonMandatoryFields);
                        lcmp.set("v.mandatoryFields" , mandatoryFields);
                        var actualVal = lcmp.get("v.isRequiredAdded");
                        if(actualVal == true){
                            lcmp.set("v.isRequiredAdded" , false);
                        }else{
                            lcmp.set("v.isRequiredAdded" , true);
                        }
                    }
                    
                }
            }
            console.log("Prescribibg Doctor isRequired validation completed");
            /********* Prescribibg Dr isRequired End*************/
            
            if(requiredMissing){
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                // alert($A.get("$Label.c.AGN_OAM_Body_PleaseFill"));
                component.set("v.showSpinner", false);
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
            }
            else{
                this.validateFormatFields(component, event);
            }
        }       
    },
    
    validateFormatFields: function(component, event) {
        jQuery.noConflict();
        var wellFormatted = true;
        var whichFields = '';
        
        const cmpfieldSoldTo = component.find("fieldSoldTo");
        const cmpfieldBillTo = component.find("fieldBillTo");
        const cmpfieldShipTo = component.find("fieldShipTo");
        
        const cmpfieldnewShipTo = component.find("newShipTo");
        const cmpfieldnewBillTo = component.find("newBillTo");
        
        
        const cmpSBS = [];
        
        if(cmpfieldSoldTo){
            cmpSBS.push(cmpfieldSoldTo);
        }
        
        if(cmpfieldBillTo){
            cmpSBS.push(cmpfieldBillTo);
        }
        
        if(cmpfieldShipTo){
            cmpSBS.push(cmpfieldShipTo);
        }
        
        //adding new shipto, billto
        if(cmpfieldnewShipTo){
            cmpSBS.push(cmpfieldnewShipTo);
        }
        
        if(cmpfieldnewBillTo){
            cmpSBS.push(cmpfieldnewBillTo);
        }
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){ 
            cmpSBS.forEach( function (cmps){
                cmps.forEach(function (cmp){
                    if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && !$A.util.isEmpty(cmp.get("v.fieldValue")) ){
                        if(!cmp.get("v.isFormatValid")){
                            //console.log('not formatted');
                            console.log("Not Formatted Fields>>>>>>"+cmp.get("v.fieldName"));
                            cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                            wellFormatted = false;
                            whichFields += cmp.get("v.customLabelName") + ", ";
                        }
                        else{
                            //console.log('formatted');
                            cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                        }
                    }                
                });
            });            
            /********* Prescribibg Dr Format for ANZ Starts***********/
            var lcmp = component.find("PrescribingDrField");
            if(!$A.util.isEmpty(lcmp) && component.get("v.isPrescribingDr")){                    
                var isValid = true;
                var notFormattedFields = "";
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                licenseCmp.forEach( function (cmp){                        
                    if(!cmp.Is_Format_Valid_AGN__c){                            
                        cmp.FieldValue_Missing_AGN__c = true; //to show red color bottom border                            
                        wellFormatted = false;                          
                        whichFields += $A.get("$Label.c."+cmp.Field_Custom_Label_AGN__c) + ", ";
                        isValid = false;
                        notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                    }
                    else{
                        cmp.FieldValue_Missing_AGN__c = false; //to hide red color bottom border
                    }						
                });
                if(!isValid){
                    if($A.util.isArray(lcmp)){
                        lcmp.forEach( function (cmp){
                            var actualVal = cmp.get("v.isFormatValid");
                            alert(actualVal);
                            if(actualVal == true){
                                cmp.set("v.isFormatValid" , false);
                            }else{
                                cmp.set("v.isFormatValid" , true);
                            }
                            cmp.set("v.notFormattedFields" , notFormattedFields);
                        });
                    }else{
                        var actualVal = lcmp.get("v.isFormatValid");
                        if(actualVal == true){
                            lcmp.set("v.isFormatValid" , false);
                        }else{
                            lcmp.set("v.isFormatValid" , true);
                        }
                    }
                    
                }
            }
            console.log("Prescribing Doctor format validation completed");
            /********* Prescribing Dr Format Validation for ANZ Ends*************/
            
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                component.set("v.showSpinner", false);
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{
                //calling registration process
                console.log("upsertAddressDetails Function");
                
                /* Added By Ravi for shipto & BillTo Limit Validation  Start*/
                
                var objSoldTo = component.get('v.objSoldTo');
                var billToAddrList = component.get('v.objBillTo');
                var shipToAddrList = component.get('v.objShipTo');
                var newBillToAddrList = component.get('v.obj_addNewBillTo');
                var newShipToAddrList = component.get('v.obj_addNewShipTo');
                
                var shipTosameAsSlodTo = component.get("v.shipToSameAsSoldTo"); 
                var billToSameAsSoldTo = component.get("v.billToSameAsSoldTo");
                
                var isValidShipToBillTo = '';                
                var isEmptyBillTo = false;
                var isEmptyShipToTo = false; 
                
                if(shipToAddrList.length == 0 && !shipTosameAsSlodTo && newShipToAddrList.length == 0){
                    isEmptyShipToTo = true;
                    isValidShipToBillTo = $A.get("$Label.c.AGN_OAM_OneShipTo");
                }
                if(billToAddrList.length == 0  && newBillToAddrList.length == 0 && !billToSameAsSoldTo){
                    isEmptyBillTo = true;
                    isValidShipToBillTo = $A.get("$Label.c.AGN_OAM_OneBillTo");
                }                
                billToAddrList.forEach(function (bill){
                    if(bill.Id == objSoldTo.Id && !billToSameAsSoldTo && billToAddrList.length == 1 && newBillToAddrList.length == 0){
                        isValid = false;
                        isEmptyBillTo = true;
                        isValidShipToBillTo = $A.get("$Label.c.AGN_OAM_OneBillTo");
                        console.log('B2>>'+billToSameAsSoldTo+'>>>>>'+billToAddrList.length+'>>>>'+newBillToAddrList.length);
                    }                
                });
                
                shipToAddrList.forEach(function (ship){
                    if(ship.Id == objSoldTo.Id && !shipTosameAsSlodTo && shipToAddrList.length == 1 && newShipToAddrList.length == 0 ){
                        isValid = false;
                        isEmptyShipToTo = true;
                        isValidShipToBillTo = $A.get("$Label.c.AGN_OAM_OneShipTo");
                        console.log('S2>>'+shipTosameAsSlodTo+'>>>>>'+shipToAddrList.length+'>>>>'+newShipToAddrList.length);
                    }                
                });                     
                
                if( !isEmptyBillTo && !isEmptyShipToTo ){
                    this.upsertAddressDetails(component, event);
                    
                }else if(isEmptyBillTo && isEmptyShipToTo){
                    component.set("v.showSpinner", false);
                    this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_OneShipToBillTo"), 'dismissible');
                }else if(isEmptyBillTo){
                    component.set("v.showSpinner", false);
                    this.showTosteMessage(component, '', 'error', isValidShipToBillTo, 'dismissible');
                }else if(isEmptyShipToTo){
                    component.set("v.showSpinner", false);
                    this.showTosteMessage(component, '', 'error', isValidShipToBillTo, 'dismissible');
                } 
                
                /* Added By Ravi for shipto & BillTo Limit Validation End */
                
            }  
        }
    },
    upsertAddressDetails : function(component, event) { 
        try{
            console.log("Inside upsertRegistration");
            
            component.set("v.isSaved", true); // single time work on save button
            
            var soldToId = component.get('v.objSoldTo').Id;         
            
            /********* Prescribing Dr data Start ***********/           
            var objSoldTo = component.get('v.objSoldTo');
            var lcmp = component.find("PrescribingDrField");
            var hasValue = true;
            if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                licenseCmp.forEach( function (lcmp){
                    if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                        objSoldTo[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                        hasValue = false;
                    }  
                })
            } 
            
            component.set('v.objSoldTo', objSoldTo);
            component.set("v.objSoldTo.Are_You_The_Prescribing_Doctor_AGN__c" , hasValue);
            /*if(hasValue){
                component.set('v.objSoldTo.Are_You_The_Prescribing_Doctor_AGN__c', true); 
            }else{
                component.set('v.objSoldTo.Are_You_The_Prescribing_Doctor_AGN__c', false);
            }*/
            
            /********* Prescribing Dr data End ***********/        
            
            
            var self = this; 
            //component.get('v.objSoldTo').Ship_To_AGN__c = true;
            
            var listAddress = [];
            var objBillTo = component.get('v.objBillTo');           
            objBillTo.forEach(function (bill){
                if(bill.Id != soldToId){
                    bill.Bill_To_AGN__c = true;
                    bill.Sold_To_AGN__c = false;
                    bill.Ship_To_AGN__c = false;
                }
                console.log("billto address verified?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+bill.Is_Verified_Address__c);
            });
            
            component.set('v.objBillTo', objBillTo);
            
            //console.log('objBillTo'+JSON.stringify( component.get('v.objBillTo')));
            
            //existing shipto
            var objShipTo = component.get('v.objShipTo');
            objShipTo.forEach(function (ship){
                if(ship.Id != soldToId){
                    ship.Bill_To_AGN__c = false;
                    ship.Sold_To_AGN__c = false;
                    ship.Ship_To_AGN__c = true;
                }
            });
            component.set('v.objShipTo', objShipTo);
            
            //new shipto if any
            
            var obj_NewShipTo = component.get('v.obj_addNewShipTo');
            var index_NST = obj_NewShipTo.findIndex(x => x.sameassoldto == true);
            if(index_NST >= 0){
                obj_NewShipTo.splice(index_NST, 1); //removing array of index position
            }
            component.set('v.obj_addNewShipTo', obj_NewShipTo);
            
            obj_NewShipTo = component.get('v.obj_addNewShipTo');
            obj_NewShipTo.forEach(function (nship){
                nship.Bill_To_AGN__c = false;
                nship.Sold_To_AGN__c = false;
                nship.Ship_To_AGN__c = true;
            });
            component.set('v.obj_addNewShipTo', obj_NewShipTo);
            //console.log('obj_addNewShipTo='+JSON.stringify(component.get('v.obj_addNewShipTo')));
            
            //new billto if any
            
            var obj_NewBillTo = component.get('v.obj_addNewBillTo');
            var index_NBT = obj_NewBillTo.findIndex(x => x.sameassoldto == true);
            console.log('index_NBT = ' + index_NBT);
            if(index_NBT >= 0){
                obj_NewBillTo.splice(index_NBT, 1); //removing array of index position
            }
            component.set('v.obj_addNewBillTo', obj_NewBillTo);
            
            obj_NewBillTo = component.get('v.obj_addNewBillTo');
            obj_NewBillTo.forEach(function (nbill){
                nbill.Bill_To_AGN__c = true;
                nbill.Sold_To_AGN__c = false;
                nbill.Ship_To_AGN__c = false;
            });
            component.set('v.obj_addNewBillTo', obj_NewBillTo);
            //console.log('obj_addNewBillTo='+JSON.stringify(component.get('v.obj_addNewBillTo')));
        }
        catch(err){
            //alert(' error message = '+ err.stack);
            console.log(' error message = '+ err.message);
            component.set("v.showSpinner", false);
        }      
        
        /* Based on SameAsSoldTo Checkbox Related Functionality  --- End */
        console.log("isSoldToVerified>>>>>>>>>>>>>>>>>>>>"+component.get("v.isSoldToVerified"));
        component.set('v.objSoldTo.Is_Verified_Address__c' , component.get("v.isSoldToVerified"));
        console.log("sold to after address validation" , component.get('v.objSoldTo.Is_Verified_Address__c'));
        
         component.set("v.objSoldTo.Ship_To_AGN__c", component.get("v.shipToSameAsSoldTo"));
         component.set("v.objSoldTo.Bill_To_AGN__c", component.get("v.billToSameAsSoldTo"));
        
        //*********upsert CustomerRegistration *************
        console.log("calling controller method>>>>>>>>>>>>>>>>");
        this.callServerAction(component, "c.upsertAddressDetails", {
            'soldToAddr' : component.get('v.objSoldTo'),
            'billToAddrList' : component.get('v.objBillTo'),
            'shipToAddrList' : component.get('v.objShipTo'),
            'newBillToAddrList' : component.get('v.obj_addNewBillTo'),
            'newShipToAddrList' : component.get('v.obj_addNewShipTo')
        })          
        .then(             
            $A.getCallback(function(resp) {
                console.log('updateCustomerRegistration--'+resp);
                if($A.util.isEmpty(resp)){
                    component.set("v.isSaved", false); // single time work on save button
                    console.log('CustomerRegistration Error');
                    component.get("v.objSoldTo").Ship_To_AGN__c = false;
                    component.get("v.objSoldTo").Bill_To_AGN__c = false;
                    self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                } else {
                    component.set("v.obj_addNewShipTo", []);
                    component.set("v.obj_addNewBillTo", []);
                    self.fetchAddressDetails(component, event);                    
                    var notifyRegStepChange = component.getEvent("notifyRegStepChange");
                    notifyRegStepChange.setParams({"Operation": 'UPDATE',
                                                   "StepNo": '3'}
                                                 );
                    notifyRegStepChange.fire();
                    
                    console.log('Successfully CustomerRegistration updated');
                    
                    component.set("v.showSpinner", false);
                    
                    component.set("v.showHideAddButtonShipTo", 0);
                    component.set("v.showHideAddButton",0);
                }                                     
            }))
        .catch($A.getCallback(function(errorsresp) {
            component.set("v.showSpinner", false);
            self.logActionErrors(component, errorsresp);                                                    
            //*********upsert CustomerRegistration *************
        }));    
    },   
    logActionErrors : function(component, response) {
        console.log("Error Response>>>>>>"+JSON.stringify(response, null, 2));
        
        var state = response.getState();
        var message = '';
        
        if (state === "INCOMPLETE") {
            message = "No Response From Server or Server could not be reached. Check your internet connection";
        }
        else 
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j];
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                }
                else {
                    message = "Unknown Error";
                }
            }
            else {
                message = "Unknown Status Error: " + state;
            }
        
        console.log('ERROR = ' + JSON.stringify(message, null, 2));
        this.showTosteMessage(component,'', 'error', message, 'sticky');
    },
    
    showTosteMessage : function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        
        if (toastEvent){
            
            toastEvent.setParams({
                title: title,
                type: type,
                message: message,
                mode: mode
            });
            
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(title + ': ' + message);
        }
    },
    
    callServerAction : function(component, actionName, params) {
        var helper = this;
        
        var p = new Promise(function(resolve, reject) {
            
            var action = component.get(actionName);
            
            if (params) {
                action.setParams(params);
            }
            action.setCallback(helper, function(response) {
                if (component.isValid() && response.getState() === 'SUCCESS'){
                    resolve(response.getReturnValue());
                } else {                   
                    //console.log('Error calling action "' + actionName + '" with state: ' + response.getState());                   
                    reject(response); 
                }
            });
            $A.enqueueAction(action);
        });       
        return p;
    },
    //fireEvent : function(component, actionName, params){
    fireEvent : function(component, event) {
        
        var formSubmitAddress = component.getEvent("formSubmitAddress");
        formSubmitAddress.setParams({"formDataCCSu_Type":
                                     {
                                         "custRegID" : component.get("v.custRegID")
                                     }
                                    });
        formSubmitAddress.fire();
    },
    fetchDependantFields : function(component , country){
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        
        var action = component.get('c.getDependantLayout');
        action.setParams({       
            'country': country
        });
        action.setCallback(this, function(response) {
            //console.log("Dependent settings call status>>>>>>"+response.getState());
            if(response.getState() === 'SUCCESS') {
                var settings = [];
                var prescribingDoctorsSettings = [];
                var settingsMap = response.getReturnValue();
                
                for(var key in settingsMap){
                    if(key === 'Doctors_Email_AGN__c'){
                        var flist = settingsMap[key];
                        //console.log(flist);
                        for(var item in flist){
                            var rec = flist[item];
                            rec.FieldValue_AGN__c = "";
                            prescribingDoctorsSettings.push(rec);
                        } 
                    }
                }
                prescribingDoctorsSettings.sort((a, b) => (a.Sort_Order_AGN__c > b.Sort_Order_AGN__c) ? 1 : -1); // Added by Ravi for soting the Records order by Sort_Order_AGN__c
                
                var customerType = component.get("v.customerType");
                var customerSubType = component.get("v.customerSubType");
                
                if(customerType.toUpperCase() === 'HOSPITAL' || customerType.toUpperCase() === 'PHARMACIES' || customerType.toUpperCase() === 'WHOLESALERS' || customerSubType.toUpperCase() ==='NURSE PRACTITIONER'){                    
                    component.set("v.PrescribingDoctorsDependantFields" , []);
                    component.set("v.showPrescribingDrSlider" , false);                  
                }else{
                    component.set("v.PrescribingDoctorsDependantFields" , prescribingDoctorsSettings);
                    component.set("v.showPrescribingDrSlider" , true);
                }               
                
                //component.set("v.showPrescribingDr" , false);
                //component.set("v.isPrescribingDr" , true);
                component.set("v.disablePrescribingDr" , false); 
                component.set("v.clearPrescribingDrValues" , false);
                component.set("v.clearPrescribingDrRequiredFields" , false);
            } else {
                this.logActionErrors(component, response);
            }
            //console.log(component.get("v.BuyingGroupDependantFields"));
        });
        $A.enqueueAction(action);
    } ,
    
    getLoqateAddress : function(component, selectedCountry) {
        console.log("inside loqate method>>>>>>>>>>>>>>",selectedCountry);
        console.log(component.get('v.objAddr'));
        //this.showSpinner(component);
        if(!$A.util.isEmpty(component.get('v.objAddr.Address_Line_1_AGN__c'))
           && !$A.util.isEmpty(component.get('v.objAddr.Zip_AGN__c'))
           && !$A.util.isEmpty(selectedCountry)){
            /*var selectedSuite = component.get('v.objAddr.Suite_AGN__c');  
            
             * commented on 24/05/2019
             * if($A.util.isEmpty(selectedSuite)){
                component.set("v.addressType" , "Street");
            }else{
                component.set("v.addressType" , "Address");
            }*/
            this.callServerAction(component, 'c.getValidAddress', {
                'customerAddress' : component.get('v.objAddr'),
                'country' : selectedCountry 
            })
            .then($A.getCallback(function(resp) {
                //this.hideSpinner(component);
                console.log("Address Respose>>>>>>>>>>>>>",resp);
                if(resp.length > 0){
                    component.set("v.activeAddressFound" , true);
                    if(resp.length === 1){
                        //component.set('v.objSoldTo.Is_Verified_Address__c' , true);
                    }else if(resp.length > 1){
                        
                    }
                    component.set("v.addressOps" , resp);
                    component.set("v.isOpen" , true);
                }else{
                    alert("No valid address found");
                }
            })) 
            .catch($A.getCallback(function(errorsresp) {
                //this.hideSpinner(component);
                self.logActionErrors(component, errorsresp);         
            }));
        }else{
            //this.hideSpinner(component);
            alert("Please add values for required address fields");
        }
        //this.hideSpinner(component);
    },
    
    showSpinner: function(component) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.showSpinner", true); 
    },
    
    hideSpinner : function(component){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.showSpinner", false);
    },
    
    doValidateLoqate : function(component , country){
        var action = component.get('c.isLoqateEnabled');
        action.setParams({       
            'country': country
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set("v.isLoqateEnabled" , response.getReturnValue());
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    }
})