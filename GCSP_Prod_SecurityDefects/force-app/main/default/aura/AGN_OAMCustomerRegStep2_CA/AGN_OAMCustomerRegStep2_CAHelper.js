({
    fetchCountrySettings : function(component, event) {
        
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '2'            
            });       
        }
        else{
            action.setParams({       
                'country': component.get("v.countryCode"), //FR, DE            
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
                
                console.log('addressList = ' +JSON.stringify(response.getReturnValue()));
                
                //split to SoldTo, ShipTo and BillTo Address
                
                if(!addressList) return;
                if($A.util.isArray(addressList)){
                    for(var i in addressList){
                        
                        if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                            soldToAddr = addressList[i];
                           
                            component.set("v.objMixType",addressList[i]);
                           
                            if(!$A.util.isEmpty(addressList[i].Buying_Group_Name_AGN__c) && !$A.util.isEmpty(addressList[i].Member_Account_Number_AGN__c) ){
                               component.find("ctrlChkBoxBG").set("v.value",true);
                               component.set("v.isBuyingGroup",true);
                            }                            
                            //if(!$A.util.isEmpty(addressList[i].US_State_AGN__c) && !$A.util.isEmpty(addressList[i].License_Number_US_AGN__c)){
                            if(addressList[i].US_License_HCP_AGN__c == true){  
                               component.set("v.showUSLicensedHCP",true);
                               component.set("v.isUSLicensedHCP",true);
                            }
                            if(!$A.util.isEmpty(addressList[i].Doctors_Email_AGN__c)){
                                component.set("v.uploadAccountOwnerDocument", true);                                
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
                    console.log("isSoldToVerified>>>>>>>>>>>>>>>>>>>>>>>>"+component.get('v.objSoldTo.Is_Verified_Address__c'));
                    component.set("v.isSoldToVerified" , component.get('v.objSoldTo.Is_Verified_Address__c'));
                    var doValidateList = [];
                    shipToAddr.forEach(function(cmp){
                         doValidateList.push(false);              
                    });
                    console.log("doValidateList>>>>>>>>>>>>>>>>>>>>>>>>>"+doValidateList);
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
            } else {
                
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteExistingShip_Bill_To : function(component, event){
        
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
        }
        else if(addressType === 'BILLTO'){
            objAddress = component.get("v.objBillTo");
            v_objAddress = 'v.objBillTo';
        }
        
        //calling apex method to delete the address from object
        this.deleteAddress(component, event, index, v_objAddress, objAddress);
        
        //customerAddress = objAddress[index];
        
        //objAddress.splice(index, 1); //removing array of index position
        //console.log('Removed data of index ' + index);
        //component.set(v_objAddress, objAddress);
    },
    sectionValidateAndUpdate : function(component, event) {
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
                    self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                } else {
                    console.log('Successfully sectionUpdateAddressDetails updated');
                }                                     
            }))
        .catch($A.getCallback(function(errorsresp) {
            self.logActionErrors(component, errorsresp);
        }));    
    },
    
    validateAndUpsert : function(component, event) {
        
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
            /********* US License Validation for Canada Starts***********/
            var country = component.get("v.countryCode");
            var licenseCmp = component.get("v.USLicenseDependantFields");
            if(country === 'CA'){
                var uslicenseRequired = false;
                var lcmp = component.find("licenseField");
                if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
                    licenseCmp.forEach( function (cmp){
                         if ($A.util.isEmpty(cmp.FieldValue_AGN__c)){
                            console.log("required US field missing>>>>>>>>>>>>>>>>"+cmp.Field_Name_AGN__c);
                            requiredMissing = true; 
                            cmp.FieldValue_Missing_AGN__c = true;
                            uslicenseRequired = true;
                         }  
                    });
                    console.log("uslicenseRequired>>>>>>>>>>>>>>>>>>",uslicenseRequired);
                    if(uslicenseRequired){
                        console.log("lcmp>>>>>>>>>>>>>>>>>>>>>",lcmp);
                        if($A.util.isArray(lcmp)){
                            lcmp.forEach( function (cmp){
                                console.log("isRequiredAdded>>>>>>>>>>>>>>>>>>>>>>>>>>>",cmp);
                                var actualVal = cmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    cmp.set("v.isRequiredAdded" , false);
                                }else{
                                    cmp.set("v.isRequiredAdded" , true);
                                }
                            });
                        }else{
                            var actualVal = lcmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    lcmp.set("v.isRequiredAdded" , false);
                                }else{
                                    lcmp.set("v.isRequiredAdded" , true);
                                }
                        }
                    }
                }
                
                //component.set("v.USLicenseDependantFields" , licenseCmp);
            }
            /********* US License Validation for Canada Ends*************/
            
             /********* Buying Group for Canada Starts***********/
            
            var bGroupCmp = component.get("v.BuyingGroupDependantFields");   
                var buyingGrpRequired = false;
                var bcmp = component.find("buyingGrpField");
                if(!$A.util.isEmpty(bcmp) && bcmp.get("v.required")){
                    bGroupCmp.forEach( function (cmp){
                         if ($A.util.isEmpty(cmp.FieldValue_AGN__c)){
                            console.log("required US field missing>>>>>>>>>>>>>>>>"+cmp.Field_Name_AGN__c);
                            requiredMissing = true; 
                            cmp.FieldValue_Missing_AGN__c = true;
                            buyingGrpRequired = true;
                         }  
                    });
                    if(buyingGrpRequired){
                         if($A.util.isArray(lcmp)){
                            bcmp.forEach( function (cmp){
                                console.log("isRequiredAdded>>>>>>>>>>>>>>>>>>>>>>>>>>>",cmp);
                                var actualVal = cmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    cmp.set("v.isRequiredAdded" , false);
                                }else{
                                    cmp.set("v.isRequiredAdded" , true);
                                }
                            });
                        }else{
                            var actualVal = bcmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    bcmp.set("v.isRequiredAdded" , false);
                                }else{
                                    bcmp.set("v.isRequiredAdded" , true);
                                }
                        }
                    }
                }
                
            /*********Buying Group Validation for Canada Ends*************/
            
            /********* Account Owner for Canada Starts***********/
                var lcmp = component.find("accountOwnerField");
                var accountownerRequired = false;
                
                if(!$A.util.isEmpty(lcmp) && component.get("v.isAccountOwner")){
                    var licenseCmp = component.get("v.AccountOwnerDependantFields");
                    licenseCmp.forEach( function (cmp){
                        
                        if(jQuery.trim(cmp.FieldValue_AGN__c) == ''){
                            console.log("account owner require field missing>>>>>>>>>>>>"+cmp.Field_Name_AGN__c);
                            requiredMissing = true;  
                            cmp.FieldValue_Missing_AGN__c = true;
                            cmp.Required_AGN__c = true;
                            accountownerRequired = true;
                        }  
                    });
                    //To display required red color in account owner fields
                    if(accountownerRequired){
                        if($A.util.isArray(lcmp)){
                            lcmp.forEach( function (cmp){
                                var actualVal = cmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    cmp.set("v.isRequiredAdded" , false);
                                }else{
                                    cmp.set("v.isRequiredAdded" , true);
                                }
                           });
                        }else{
                                var actualVal = lcmp.get("v.isRequiredAdded");
                                if(actualVal == true){
                                    lcmp.set("v.isRequiredAdded" , false);
                                }else{
                                    lcmp.set("v.isRequiredAdded" , true);
                                }
                        }
                        
                    }
                }
                console.log("Account Owner validation completed");
            /********* Account Owner Validation for Canada Ends*************/
            
            if(requiredMissing){
                //component.set("v.USLicenseDependantFields" , licenseCmp);
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                // alert($A.get("$Label.c.AGN_OAM_Body_PleaseFill"));
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
            /********* US License Format Validation for Canada Starts***********/
            var country = component.get("v.countryCode");
            if(country === 'CA'){
                var lcmp = component.find("licenseField");
                if(!$A.util.isEmpty(lcmp)){
                    var isValid = true;
                    var notFormattedFields = "";
                    var licenseCmp = component.get("v.USLicenseDependantFields");
                    licenseCmp.forEach( function (cmp){
                        if (!$A.util.isEmpty(cmp.Field_Regex_AGN__c) && !$A.util.isEmpty(cmp.FieldValue_AGN__c)){
                              if(!cmp.Is_Format_Valid_AGN__c){
                                  console.log("Not Formatted Fields>>>>>>"+cmp.Field_Name_AGN__c);
                                  wellFormatted = false;
                                  whichFields += cmp.Field_Label_AGN__c + ", ";
                                  isValid = false;
                                  notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                              }
                        }else{
                            //Add Field Value Missing condition
                        }  
                    });
                    if(!isValid){
                        if($A.util.isArray(lcmp)){
                            lcmp.forEach( function (cmp){
                                var actualVal = cmp.get("v.isFormatValid");
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
                                lcmp.set("v.notFormattedFields" , notFormattedFields);
                        }
                        
                    }
                }
            }
            /********* US License Format Validation for Canada Ends*************/
            
           /********* Buying Group Format Validation for Canada Starts***********/          
                var lcmp = component.find("buyingGrpField");
                if(!$A.util.isEmpty(lcmp)){
                    var isValid = true;
                    var notFormattedFields = "";
                    var licenseCmp = component.get("v.BuyingGroupDependantFields");
                    licenseCmp.forEach( function (cmp){
                        if (!$A.util.isEmpty(cmp.Field_Regex_AGN__c) && !$A.util.isEmpty(cmp.FieldValue_AGN__c)){
                              if(!cmp.Is_Format_Valid_AGN__c){
                                  console.log("Not Formatted Fields>>>>>>"+cmp.Field_Name_AGN__c);
                                  wellFormatted = false;
                                  whichFields += cmp.Field_Label_AGN__c + ", ";
                                  isValid = false;
                                  notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                              }
                        }else{
                            //Add Field Value Missing condition
                        }  
                    });
                    if(!isValid){
                        if($A.util.isArray(lcmp)){
                            lcmp.forEach( function (cmp){
                                var actualVal = cmp.get("v.isFormatValid");
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
                                lcmp.set("v.notFormattedFields" , notFormattedFields);
                        }
                        
                    }
                }
           
            /********* Buying Group Format Validation for Canada Ends*************/
            
            /********* Account Owner Format for Canada Starts***********/
                var lcmp = component.find("accountOwnerField");
                if(!$A.util.isEmpty(lcmp) && component.get("v.isAccountOwner")){
                    var notFormattedFields = "";
                    var licenseCmp = component.get("v.AccountOwnerDependantFields");
                    var isValid = true;
                    licenseCmp.forEach( function (cmp){
                        
                        if(!cmp.Is_Format_Valid_AGN__c){
							cmp.FieldValue_Missing_AGN__c = true; //to show red color bottom border
							wellFormatted = false;
							whichFields += cmp.Field_Label_AGN__c + ", ";
                            isValid = false;
                            notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
						}
						else{
							cmp.FieldValue_Missing_AGN__c = false; //to hide red color bottom border
						}	 
                    })
                    if(!isValid){
                        if($A.util.isArray(lcmp)){
                             lcmp.forEach( function (cmp){
                                var actualVal = cmp.get("v.isFormatValid");
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
                                lcmp.set("v.notFormattedFields" , notFormattedFields);
                        }
                        
                    }
                    
                    
                }
                console.log("Account Owner format validation completed");
            /********* Account Owner Format Validation for Canada Ends*************/
            
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{
                //calling registration process
                console.log("upsertAddressDetails Function");
                
                this.upsertAddressDetails(component, event);  
                //console.log('addressList = ' +JSON.stringify(component.get('v.objBillTo')));              
            }  
        }
    },
    upsertAddressDetails : function(component, event) { 
        try{
            console.log("Inside upsertRegistration");
            
            component.set("v.isSaved", true); // single time work on save button
            
            var soldToId = component.get('v.objSoldTo').Id;
            /********* US License Validation for Canada Starts***********/
            var country = component.get("v.countryCode");
            if(country === 'CA'){
               var objSoldTo = component.get('v.objSoldTo');
               var lcmp = component.find("licenseField");
               if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
                        var licenseCmp = component.get("v.USLicenseDependantFields");
                        licenseCmp.forEach( function (lcmp){
                            if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                                  objSoldTo[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                                  objSoldTo.US_License_HCP_AGN__c = true;
                             }  
                        })
               } 
               component.set('v.objSoldTo', objSoldTo);
            }
            /********* US License Validation for Canada Starts***********/
            
            /********* Buying Group Validation for Canada Starts***********/
           
               var objSoldTo = component.get('v.objSoldTo');
               var lcmp = component.find("buyingGrpField");
               if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
                        var licenseCmp = component.get("v.BuyingGroupDependantFields");
                        licenseCmp.forEach( function (lcmp){
                            if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                                  objSoldTo[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                             }  
                        })
               } 
               component.set('v.objSoldTo', objSoldTo);
           
            /*********Buying Group Validation for Canada End***********/
            
            /*var objSoldTo = component.get('v.objSoldTo');
            console.log("1>>>>>>>>>>>>>>>>>>>>>>>>>",objSoldTo);
            console.log("2>>>>>>>>>>>>>>>>>>>>>>>>>",objSoldTo['Id']);
            var fld = 'Id';
            console.log("3>>>>>>>>>>>>>>>>>>>>>>>>>",objSoldTo[fld]);*/
            
            
            var self = this; 
            //component.get('v.objSoldTo').Ship_To_AGN__c = true;
            
            var listAddress = [];
            
            //component.get('v.objSoldTo').Sold_To_AGN__c = true;
            //component.get('v.objSoldTo').Ship_To_AGN__c = false;
            //component.get('v.objSoldTo').Bill_To_AGN__c = false;
            //console.log('BillTo -->'+JSON.stringify(component.get("v.objSoldTo").Ship_To_AGN__c));
            
            //existing billto
            var objBillTo = component.get('v.objBillTo');
            /*for(var i in objBillTo){
                if(objBillTo[i].Id != soldToId){
                    objBillTo[i].Bill_To_AGN__c = true;
                    objBillTo[i].Sold_To_AGN__c = false;
                    objBillTo[i].Ship_To_AGN__c = false;
                }
            }
            */
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
            /*for(var i in objShipTo){
                if(objShipTo[i].Id != soldToId){
                    objShipTo[i].Bill_To_AGN__c = false;
                    objShipTo[i].Sold_To_AGN__c = false;
                    objShipTo[i].Ship_To_AGN__c = true;
                }
            }*/
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
            
            /*for(var i in component.get('v.obj_addNewShipTo')){
                component.get('v.obj_addNewShipTo')[i].Bill_To_AGN__c = false;
                component.get('v.obj_addNewShipTo')[i].Sold_To_AGN__c = false;
                component.get('v.obj_addNewShipTo')[i].Ship_To_AGN__c = true;
            }*/
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
            
            /*for(var i in component.get('v.obj_addNewBillTo')){
                component.get('v.obj_addNewBillTo')[i].Bill_To_AGN__c = true;
                component.get('v.obj_addNewBillTo')[i].Sold_To_AGN__c = false;
                component.get('v.obj_addNewBillTo')[i].Ship_To_AGN__c = false;
            }
            */
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
        }
        //return;
        
        /* Based on SameAsSoldTo Checkbox Related Functionality  --- Start 
        
        if(component.get("v.shipToSameAsSoldTo") == false){
            component.set("v.objSoldTo.Ship_To_AGN__c", false);
            //console.log('soldTo_ShipTo--->'+JSON.stringify(component.get('v.objSoldTo').Ship_To_AGN__c));
        }else{
            component.set("v.objSoldTo.Ship_To_AGN__c", true);
        }
         if(component.get("v.billToSameAsSoldTo") == false){
            component.set("v.objSoldTo.Bill_To_AGN__c", false);
           // console.log('soldTo_ShipTo--->'+JSON.stringify(component.get('v.objSoldTo').Bill_To_AGN__c));
        }else{
            component.set("v.objSoldTo.Bill_To_AGN__c", true);
        } */
        
        /* Based on SameAsSoldTo Checkbox Related Functionality  --- End */
        console.log("isSoldToVerified>>>>>>>>>>>>>>>>>>>>"+component.get("v.isSoldToVerified"));
        component.set('v.objSoldTo.Is_Verified_Address__c' , component.get("v.isSoldToVerified"));
        console.log("sold to after address validation" , component.get('v.objSoldTo.Is_Verified_Address__c'));
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
                    
                    //Avijit
                    /*jQuery('.add_det .infr_det').slideUp(500);
                    jQuery( ".add_det .edit_btn" ).show();
                    jQuery('.upload_doc .infr_det').slideDown(500);
                    jQuery( ".upload_doc .edit_btn" ).hide();
                    */
                    console.log('Successfully CustomerRegistration updated');
                }                                     
            }))
        .catch($A.getCallback(function(errorsresp) {
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
         console.log("calling dependant fields method>>>>>>>>>>>>>>>>>");
         var action = component.get('c.getDependantLayout');
         action.setParams({       
                'country': component.get("v.countryCode")
            });
        action.setCallback(this, function(response) {
            console.log("Dependent settings call status>>>>>>"+response.getState());
            if(response.getState() === 'SUCCESS') {
                var settings = [];
                var accountOwnerSettings = []; // for account owner
                var BGsettings = []; // for buying group
                
                var settingsMap = response.getReturnValue();
                for(var key in settingsMap){
                    if(key === 'US_License_HCP_AGN__c'){
                       var flist = settingsMap[key];
                       console.log(flist);
                       for(var item in flist){
                           var rec = flist[item];
                           rec.FieldValue_AGN__c = "";
                          settings.push(rec);
                       } 
                    }else if(key === 'Part_of_a_Buying_Group_AGN__c'){
                       var flist = settingsMap[key];
                       console.log(flist);
                       for(var item in flist){
                           var rec = flist[item];
                           rec.FieldValue_AGN__c = "";
                          BGsettings.push(rec);
                       } 
                    }else if(key === 'Doctors_Email_AGN__c'){
                        var flist = settingsMap[key];
                        //console.log(flist);
                        for(var item in flist){
                            var rec = flist[item];
                            console.log("Field Value >>> Account Owner>>>>>"+rec.FieldValue_AGN__c);
                            rec.FieldValue_AGN__c = "";
                            accountOwnerSettings.push(rec);
                        } 
                    }
                }
                console.log("settings>>>>>>>>>>>>>>"+JSON.stringify(settings));
                component.set("v.USLicenseDependantFields" , settings);                
                component.set("v.BuyingGroupDependantFields", BGsettings);
                component.set("v.AccountOwnerDependantFields" , accountOwnerSettings);
                var record = component.get("v.objMixType");
                var fieldName = "Doctors_Email_AGN__c";
                var doctorEmail = record[fieldName];
                if(!$A.util.isEmpty(accountOwnerSettings) && !$A.util.isEmpty(doctorEmail)){
                    component.set("v.showAccountOwner" , false);
                    component.set("v.isAccountOwner" , true);
                }
               console.log("Doctor Email007>>>>>>>>>>>>>>>>>>>>",record[fieldName]);
            } else {
                this.logActionErrors(component, response);
            }
            console.log(component.get("v.USLicenseDependantFields"));
        });
        $A.enqueueAction(action);
    },
    
    getLoqateAddress : function(component, selectedProvince) {
        console.log("inside loqate method>>>>>>>>>>>>>>",selectedProvince);
        console.log(component.get('v.objAddr'));
        //this.showSpinner(component);
        if(!$A.util.isEmpty(component.get('v.objAddr.Address_Line_1_AGN__c'))
           && !$A.util.isEmpty(component.get('v.objAddr.Zip_AGN__c'))
           && !$A.util.isEmpty(selectedProvince)){
            var selectedSuite = component.get('v.objAddr.Suite_AGN__c');  
            if($A.util.isEmpty(selectedSuite)){
                   component.set("v.addressType" , "Street");
            }else{
                   component.set("v.addressType" , "Address");
            }
            this.callServerAction(component, 'c.getValidAddressCA', {
                                                                 'customerAddress' : component.get('v.objAddr'),
                                                                 'province' : selectedProvince 
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
})