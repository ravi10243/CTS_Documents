({
    fetchCountrySettings : function(component, event) {
        
        var action = component.get('c.getLayout');   
        //if(component.get("v.controller.config.Country_Code_AGN__c") === 'IT'){
        if(component.get("v.SAPCountryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '2'            
            });       
        }
        else{
            
            // console.log('config--->'+component.get("v.controller.config"));
            // console.log('Country_Code-->'+component.get("v.controller.config.Country_Code_AGN__c"));
            // console.log('Category_AGN-->'+component.get("v.controller.config.Category_AGN__c"));
            //  console.log('Sub_Category-->'+component.get("v.controller.config.Sub_Category__c"));
            
            action.setParams({       
                'country': component.get("v.SAPCountryCode"), //component.get("v.controller.config.Country_Code_AGN__c"), //FR, DE, GB, IE, ES ...            
                'stepNo': '2',
                'customerType': component.get("v.controller.config.Category_AGN__c"), //Pharmacies',//
                'customerSubType': component.get("v.controller.config.Sub_Category__c") //'Pharmacies with wholesaler licence'// 
            });
        } 
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var settingsSoldTo = [];
                var settingsBillTo = [];
                var settingsShipTo = [];
                var settingsMap = response.getReturnValue();
                
                for(var key in settingsMap){
                    //settingsSoldTo.push({value:settingsMap[key], key:key});
                    // console.log('method colling for de-->'+JSON.stringify(settingsSoldTo));
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
                
                component.set('v.address',component.get('v.controller.newAddress'));
                
                component.set("v.showSpinner", false);
                
            } else {
                component.set("v.showSpinner", false);
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);        
        
    },
    
    fetchPaymentSettingdetails : function(component, event){        
        var action = component.get('c.getLayout');
        if(component.get("v.SAPCountryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '4'            
            });       
        }
        else{
            //console.log('Country_Code-->'+component.get("v.controller.config.Country_Code_AGN__c"));
            // console.log('Category_AGN-->'+component.get("v.controller.config.Category_AGN__c"));
            // console.log('Sub_Category-->'+component.get("v.controller.config.Sub_Category__c"));
            
            action.setParams({       
                'country': component.get("v.SAPCountryCode"), //FR, DE            
                'stepNo': '4',
                'customerType': component.get("v.controller.config.Category_AGN__c"), //Pharmacies',//
                'customerSubType': component.get("v.controller.config.Sub_Category__c") //'Pharmacies with wholesaler licence'// 
            });
        } 
        
        
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var settingsPayment = [];
                var settingsMap = response.getReturnValue();
                const cmpSBS = [];
                for(var key in settingsMap){              
                    cmpSBS.push({value:settingsMap[key], key:key});  
                }
                if ($A.util.isArray(cmpSBS)){                      
                    cmpSBS.forEach( function (cmps){
                        //console.log('value-->'+JSON.stringify(cmps.value));
                        cmps.value.forEach( function (cmp){                                   
                            // console.log('value1-->'+JSON.stringify(cmp.Field_Name_AGN__c));
                            if(cmp.SObject_Name_AGN__c == 'Allergan_Customer_Address_AGN__c' && cmp.Field_Name_AGN__c != 'Address_Line_1_AGN__c'){
                                // console.log('value-->'+JSON.stringify(cmp));
                                settingsPayment.push(cmp);
                            }
                            
                        });                              
                        
                    });
                    //console.log('form of payment '+ component.get('v.controller.config.Country_Code_AGN__c'));
                }
                
                component.set('v.sectionHeaderMapPayment', settingsPayment);
                component.set('v.address',component.get('v.controller.newAddress'));
                console.log('map ---->'+JSON.stringify(component.get("v.controller.newAddress")));
                //console.log('map---->'+JSON.stringify(component.get("v.sectionHeaderMapPayment")));
                
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getParameterByName : function (name) {
        var url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    
    /* -------------- if Customer Payment is isNull ---------------- Start  */
    
    
    getPaymentMethodValues : function(component, event, helper){
        
        //console.log('getPaymentMethodValues -1');
        
        var action = component.get("c.getPickListValues");
        var columnName='Form_Of_Payment_Label_AGN__c';
        var columnId='Id';
        var objectName='Form_Of_Payment_AGN__c';
        var country = component.get("v.SAPCountryCode");
        //console.log('SAPCountryCode -6');
        var countryCode = "'" + country + "'";
		//console.log('getPaymentMethodValues -6');
        var whereCondition=' where SAP_Country_Code_AGN__c='+countryCode+' AND Active_AGN__c= true';
        //action.setStorable();
       //console.log('SAPCountryCode -6');
        action.setParams({
            objectName : objectName,
            columnName : columnName,
            columnId : columnId,
            whereCondition: whereCondition
        });
        
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS') {
                //console.log('v.PaymentMethod===>'+JSON.stringify(actionResult.getReturnValue()));
            	component.set("v.PaymentMethod", actionResult.getReturnValue());       
            	//console.log('v.PaymentMethod===>'+JSON.stringify(component.get("v.PaymentMethod")));
            }
            else{
                console.log('getPaymentMethodValues --> ' +actionResult.getState()); 
            }
        });       
        
        $A.enqueueAction(action); 
        
    },
    
    onChangePaymentMethod : function(component, event, helper){
        try{
            var pmethod = component.find("paymentMethod").get("v.value");
            if(pmethod != null && pmethod != '' ){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                console.log('pmethodvalue-->'+pmethodvalue);
                var columnName='Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__c='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();
                    console.log('v.PaymentTerm===>'+JSON.stringify(paymentTermval));
                    if(component.get('v.controller.config.Country_Code_AGN__c') == 'IT'){                        
                        for(var i in paymentTermval){
                            component.set("v.PaymentTerm1", paymentTermval[i].SAP_Payment_Term_Code_AGN__c);                           
                        } 
                        helper.onChangePaymentTerm(component, event, helper);
                    }else{
                        component.set("v.PaymentTerm", paymentTermval);
                    }
                });        
                
                $A.enqueueAction(action);  
            }else{
                component.set('v.isShow',false);
                component.set("v.PaymentTerm", '');
                component.set("v.PaymentTerm1", '');
                component.set("v.isPaymentTerm", true);
            }
            
        }catch(err){
            console.log('err'+err.message);
        }
        
    }, 
    
    onChangePaymentTerm: function(component, event, helper){
        
        var pmethod = component.find("paymentMethod").get("v.value");
        var paymentTerm = component.get("v.PaymentTerm1");
        if(pmethod != null && pmethod != '' && paymentTerm != null && paymentTerm != ''){
            component.set('v.isShow',true);
        }else{
            component.set('v.isShow',false);
        }
        console.log('@@pmethod>>'+pmethod+'@@@paymentTerm>>>>'+paymentTerm + 'ccode>>>'+component.get('v.SAPCountryCode'));
        
        var action = component.get("c.getPaymentDetails");         
        action.setParams({       
            "formofPayment": pmethod,                
            "paymentTerm": paymentTerm,
            "countryCode" : component.get('v.SAPCountryCode')           
        }); 
        action.setCallback(this, function(a) {
            var objVal = a.getReturnValue();
            
            component.set('v.controller.newRegistration.Form_of_Payment_AGN__c', pmethod);
            component.set('v.controller.newRegistration.Payment_Term_AGN__c', objVal[0].Id);
            console.log('@@@@@Form_of_Payment_AGN__c>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')));
            console.log('@@@@@Payment_Term_AGN__c>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Payment_Term_AGN__c')));
            
        });        
        $A.enqueueAction(action);  
        
        
    },
    
    /* -------------- if Customer Payment is isNull ------------------ End  */
    
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  start  ---------*/
    
    getPaymentTermValues : function(component, event, helper){
        
        try{
            //var pmethod = component.get("v.controller.paymentMethod.Form_Of_Payment_Label_AGN__c");           
            var pmethod = component.get("v.controller.paymentMethod.Id");
            console.log('pmethod - getPaymentTermValues()>>>>>'+pmethod);
            
            if(pmethod != null && pmethod != '' ){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                //console.log('pmethodvalue-->'+pmethodvalue);
                var columnName='Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__c='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();
                    console.log('v.PaymentTerm===>'+JSON.stringify(paymentTermval));
                    if(component.get('v.controller.config.Country_Code_AGN__c') == 'IT'){                        
                        for(var i in paymentTermval){
                            component.set("v.PaymentTerm1", paymentTermval[i].SAP_Payment_Term_Code_AGN__c);                           
                        } 
                        helper.onChangePaymentTermForCustPayment(component, event, helper);
                    }else{
                        component.set("v.PaymentTerm", paymentTermval);
                    }
                });        
                
                $A.enqueueAction(action);  
            }else{
                component.set('v.isShow',false);
                component.set("v.PaymentTerm", '');
                component.set("v.PaymentTerm1", '');
                component.set("v.isPaymentTerm", true);
            }
            
        }catch(err){
            console.log('err'+err.message);
        }
        
    },
    
    onChangePaymentTermForCustPayment : function(component, event, helper){
        
        var pmethod = component.get("v.controller.paymentMethod.Id");
        var paymentTerm = component.get("v.PaymentTerm1");
        
        
        if(pmethod != null && pmethod != '' && paymentTerm != null && paymentTerm != ''){
            component.set('v.isShow',true);
        }else{
            component.set('v.isShow',false);
        }
        console.log('@@pmethod>>'+pmethod+'@@@paymentTerm>>>>'+paymentTerm + 'ccode>>>'+component.get('v.SAPCountryCode'));
        
        var action = component.get("c.getPaymentDetails");         
        action.setParams({       
            "formofPayment": pmethod,                
            "paymentTerm": paymentTerm,
            "countryCode" : component.get('v.SAPCountryCode')           
        }); 
        action.setCallback(this, function(a) {
            var objVal = a.getReturnValue();
            
            component.set('v.controller.newRegistration.Form_of_Payment_AGN__c', pmethod);
            component.set('v.controller.newRegistration.Payment_Term_AGN__c', objVal[0].Id);
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')));
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Payment_Term_AGN__c')));
            
        });        
        $A.enqueueAction(action);  
        
        
    },
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  end  ---------*/
    
    
    MAX_DOC_FILE_SIZE: 2500000, /* 1 000 000 * 3/4 to account for base64 */
    // MAX_DOC_FILE_SIZE: 5000000,
    saveuploadFile : function(component,fileInput) {
        
       // component.set("v.showSpinner", true);
        console.log("[FileUpload].[save]--->");
        var file = fileInput.files[0];
        
        
        if (file.size > this.MAX_DOC_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_DOC_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + file.size);
            return;
        } 
        
        var fr = new FileReader();
        
        var self = this;
        
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            
            fileContents = fileContents.substring(dataStart);
            
            console.log("[FileUpload].[Calling Upload]");
            self.upload(component, file, fileContents);
            console.log("[FileUpload].[Called Upload]");
        };
        
        
        fr.readAsDataURL(file);
    },
    
    upload : function(component, file, fileContents) {
        console.log("inside upload function. parent="+component.get("v.caseDetail.Id"));
        var actionFile;
        console.log("[FileUpload].["+ file.name+ "]");
        actionFile = component.get("c.saveFile");
        actionFile.setParams({
            "parentId": component.get("v.caseDetail.Id"),
            "fileName": file.name,
            "base64Data": encodeURIComponent(fileContents),
            "contentType": file.type
        });
        console.log("rrr-1");
        
        actionFile.setCallback(this, function(response) {
            
            var status = response.getState();
            if(status === "SUCCESS"){
                
                console.log("rrr-2");            
                component.set("v.fileUploadmsg", status);
                component.set("v.showSpinner", false);
                
            }
            else {
                alert("failed to upload file");
                component.set("v.showSpinner", false);
            }
        });
        console.log("rrr-5");
        $A.enqueueAction(actionFile);
        console.log("rrr-6");
    },
    
    callDummyMethod : function(component){
        component.set("v.showSpinner", false);
        console.log("[Dummy Method].[inside Method]");
        action = component.get("c.savetestFile");
        console.log("[Dummy Method].[Called Apex method]");
        action.setCallback(this, function(response) {     
            console.log("[Dummy Method].[inside callBack]");       
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                console.log("Dummy Case Number : "+response.getReturnValue());
                component.set("v.showSpinner", false);
            }
            else component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    
    ValidateAndSaveAddressRecords: function(component, event) {
        component.set("v.showSpinner", true);
        component.set("v.isSaved", true);
        console.log('<<<<<ValidateAndSaveAddressRecords>>>>>>');
        jQuery.noConflict();       
        component.set("v.requireFieldMissing",false);
        component.set("v.fieldWellFormated",true);
        var requiredMissing = false;
        
        const cmpsSoldTo =  component.find("fieldSoldTo");
        // const cmpSoldToPayment =   component.find("fieldSoldToPayment");
        const cmpsShipTo = component.find("fieldShipTo");
        const cmpsBillTo = component.find("fieldBillTo");
        
        const cmpSBS = [];
        
        if(component.get("v.type") === component.get("v.soldTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsSoldTo);
            
            /* for customer Payment Is Null ----- Start */
            if(component.get("v.controller.custPayment.length") <= 0){
                
                var pmethod = component.find("paymentMethod").get("v.value");
                var paymentTerm = component.get("v.PaymentTerm1"); //component.find("paymentTerm").get("v.value");                
                if($A.util.isEmpty(pmethod)){ 
                    requiredMissing = true;
                    component.set("v.required", true);
                    component.set("v.PMfieldValueMissing", true);
                    
                }else{
                    component.set("v.required", false);
                    component.set("v.PMfieldValueMissing", false);
                }
                console.log('PT Value>>>>>>>>>>>>>>>>>'+paymentTerm);
                if($A.util.isEmpty(paymentTerm)){           
                    requiredMissing = true;
                    component.set("v.required", true);
                    component.set("v.PTfieldValueMissing", true);
                    
                }else{
                    component.set("v.required", false);
                    component.set("v.PTfieldValueMissing", false);
                }
            }
            /* for customer Payment Is Null ----- End */
            
            /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  start  ---------*/
            
            if(component.get("v.controller.custPayment.length") > 0){
                var paymentTerm = component.get("v.PaymentTerm1");
                if($A.util.isEmpty(paymentTerm)){           
                    requiredMissing = true;
                    console.log('<<<<<<paymentTerm>>>>>>');
                    component.set("v.required", true);
                    component.set("v.PTfieldValueMissing", true);
                    
                }else{
                    component.set("v.required", false);
                    component.set("v.PTfieldValueMissing", false);
                }
            }
            
            /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  end		  ---------*/          
            
        }else if(component.get("v.type") === component.get("v.shipTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsShipTo);
            
            
        }else if(component.get("v.type") === component.get("v.billTo")){
            console.log('v.type--->'+component.get("v.type")); 
            cmpSBS.push(cmpsBillTo);
        }
        
        //const cmps = component.find("fieldId");
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            cmpSBS.forEach( function (cmps){
                cmps.forEach( function (cmp){
                    //console.log('fieldName >>' + cmp.get("v.fieldName"));
                    //    console.log('object name >>' + cmp.get("v.sobjectName"));
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        console.log('is empty >>' + cmp.get("v.fieldName"));
                        console.log('object name >>' + cmp.get("v.sobjectName"));
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                    }
                    else{
                        cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
            });
            /* Either Tax or Vat Number Mandatory - Start */
            
            // 19R3 minor,ES,for missing field validation,Start
                        
            var isTaxVatRequired = false;
            const cmpTaxVat = [];
            var k=0;
            var countryCode = component.get("v.countryCode");
            const cmpTaxVatBillTo = component.find("fieldVatTax");
            
            if(countryCode == 'ES' || countryCode == 'IT')
                {
                if(cmpTaxVatBillTo){
                    cmpTaxVat.push(cmpTaxVatBillTo);
                }
                if (!cmpTaxVat) return;
                if ($A.util.isArray(cmpTaxVat)){
                    cmpTaxVat.forEach( function (cmps){ 
                        if($A.util.isArray(cmps)){
                            cmps.forEach( function (cmp){
                                var taxnumber = cmp.get("v.record.Tax_Number_AGN__c");
                                var vatNumber = cmp.get("v.record.VAT_Number_AGN__c");
                                if((taxnumber == null && vatNumber == null) || (jQuery.trim(taxnumber) == '' &&  jQuery.trim(vatNumber) == '') 
                                   || (taxnumber == undefined && vatNumber == undefined)){                                    
                                    cmp.set("v.VatNumberMissing", true);
                                    cmp.set("v.TaxNumberMissing", true);
                                    //isTaxVatRequired = true;
                                    k++;
                                }else{
                                    cmp.set("v.VatNumberMissing", false);
                                    cmp.set("v.TaxNumberMissing", false);
                                    isTaxVatRequired = false;
                                }
                                //alert('Multiple>>'+JSON.stringify(component.get("v.record.Tax_Number_AGN__c")+'--->'+cmp.get("v.record.VAT_Number_AGN__c")));
                            });
                            
                        }else{
                            var taxnumber = cmps.get("v.record.Tax_Number_AGN__c");
                            var vatNumber = cmps.get("v.record.VAT_Number_AGN__c");
                            if((taxnumber == null && vatNumber == null) || (jQuery.trim(taxnumber) == '' &&  jQuery.trim(vatNumber) == '') 
                               || (taxnumber == undefined && vatNumber == undefined)){
                                    cmps.set("v.VatNumberMissing", true);
                                    cmps.set("v.TaxNumberMissing", true);
                                    //isTaxVatRequired = true;
                                    console.log('inside single value');
                                    k++;
                            }else{
                                cmps.set("v.VatNumberMissing", false);
                                cmps.set("v.TaxNumberMissing", false);
                                isTaxVatRequired = false;
                            }
                            
                            //alert('Single>>'+JSON.stringify(cmps.get("v.record.Tax_Number_AGN__c")+'--->'+cmps.get("v.record.VAT_Number_AGN__c")));
                        }
                       
                    });
                }
                
                    if(k>0)
                    isTaxVatRequired = true;  
                    else
                    isTaxVatRequired = false;
                    
                    console.log('k: '+k);
                    console.log('isTaxVatRequired new bill to: '+isTaxVatRequired);
        
                if(isTaxVatRequired){
                    component.set("v.showSpinner", false);
                    component.set("v.isSaved", false);
                    this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Pleae_Enter_VAT_TAX_Number"), 'dismissible'); 
                    retrun;
                }
                    
             }
                
          // 19R3 minor,ES,End
        /* Either Tax or Vat Number Mandatory - End */
            if(requiredMissing){
                component.set("v.showSpinner", false);
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                component.set("v.isSaved", false);
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
        
        const cmpsSoldTo =  component.find("fieldSoldTo");
        // const cmpSoldToPayment =   component.find("fieldSoldToPayment");
        const cmpsShipTo = component.find("fieldShipTo");
        const cmpsBillTo = component.find("fieldBillTo");
        
        const cmpSBS = [];
        
        if(component.get("v.type") === component.get("v.soldTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsSoldTo);
            
            
        }else if(component.get("v.type") === component.get("v.shipTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsShipTo);
            
            
        }else if(component.get("v.type") === component.get("v.billTo")){
            console.log('v.type--->'+component.get("v.type")); 
            cmpSBS.push(cmpsBillTo);
        }
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){ 
            cmpSBS.forEach( function (cmps){
                cmps.forEach(function (cmp){
                    if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && !$A.util.isEmpty(cmp.get("v.fieldValue")) ){
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
            });
            
            /* Either Tax or Vat Number Mandatory - Start */
            
        // 19R3 minor,ES,for field formatting,Start
            
            if(countryCode== 'IT')
            {
                var taxFormate = /^[A-Za-z0-9]{0,16}$/;
                var faxFormate = /^[A-Za-z0-9]{0,11}$/;
            }
            else if (countryCode== 'ES')
            {
                var taxFormate = /^[A-Za-z0-9]{0,9}$/;
                var faxFormate = /^[ES]{2}([0-9A-Za-z][0-9]{7}[0-9A-Za-z])$/;  
            }
        
        const cmpTaxVat = [];
        const cmpTaxVatBillTo = component.find("fieldVatTax");
        var countryCode = component.get("v.countryCode");   
            
            if(countryCode == 'ES' || countryCode == 'IT')
            {
            if(cmpTaxVatBillTo){
                    cmpTaxVat.push(cmpTaxVatBillTo);
                }
                if (!cmpTaxVat) return;
                if ($A.util.isArray(cmpTaxVat)){
                    cmpTaxVat.forEach( function (cmp){ 
                        
                                var TaxNumber = cmp.get("v.record.Tax_Number_AGN__c");
                                var VatNumber = cmp.get("v.record.VAT_Number_AGN__c");
                        
                               if(jQuery.trim(TaxNumber) != '' && jQuery.trim(VatNumber) != ''){
                                if(jQuery.trim(TaxNumber).toString().match(taxFormate) && jQuery.trim(VatNumber).toString().match(faxFormate)){
                                    console.log('Tax number and Vat Number is wellFormatted');                                          
                                }else if(!jQuery.trim(TaxNumber).toString().match(taxFormate) && !jQuery.trim(VatNumber).toString().match(faxFormate)){                                      
                                    wellFormatted = false; 
                                    whichFields += $A.get("$Label.c.AGN_OAM_Tax_Number") + " & " + $A.get("$Label.c.AGN_OAM_VAT_Number") + " ,";                                    
                                }
                                    else if(jQuery.trim(TaxNumber).toString().match(taxFormate) && !jQuery.trim(VatNumber).toString().match(faxFormate)){                                  
                                        wellFormatted = false; 
                                        whichFields += $A.get("$Label.c.AGN_OAM_VAT_Number") + " ,";
                                        console.log('inside vat number');
                                    }
                                        else if(!jQuery.trim(TaxNumber).toString().match(taxFormate) && jQuery.trim(VatNumber).toString().match(faxFormate)){                                   
                                            wellFormatted = false; 
                                            whichFields += $A.get("$Label.c.AGN_OAM_Tax_Number") + " ,";                                    
                                        }
                            }      
                            
                            if(jQuery.trim(TaxNumber) != '' || jQuery.trim(VatNumber) != ''){    
                                if(jQuery.trim(TaxNumber) != '' && jQuery.trim(VatNumber) == ''){ 
                                    if(jQuery.trim(TaxNumber).toString().match(taxFormate)){
                                        console.log('Tax number is wellFormatted --tax'); 
                                    }else{ 
                                        wellFormatted = false;
                                        whichFields += $A.get("$Label.c.AGN_OAM_Tax_Number") + " ,";
                                        console.log('whichFields: '+whichFields);
                                    }
                                }else if(jQuery.trim(TaxNumber) == '' && jQuery.trim(VatNumber) != ''){
                                    if(jQuery.trim(VatNumber).toString().match(faxFormate)){                 
                                        console.log('Vat number is wellFormatted --VAT');    
                                    }else{  
                                        wellFormatted = false;
                                        whichFields += $A.get("$Label.c.AGN_OAM_VAT_Number") + " ,";
                                    } 
                                }
                            }
                            console.log('whichFields: '+whichFields);
                            console.log('wellFormatted: '+wellFormatted); 
                            }); 
                            }
            }
            
            /* Either Tax or Vat Number Mandatory - End */
            
            if(!wellFormatted){
                component.set("v.showSpinner", false);
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
                component.set("v.isSaved", false);
            }
            else{                
                console.log("SaveAddressRecords");                
                this.SaveAddressRecords(component, event);
            }  
        }
        
    },
    
    SaveAddressRecords : function(component, event){
       // component.set("v.isSaved", true);
        
        console.log('1');        
        var ctrl = component.get("v.controller");
        var address = ctrl.newAddress;
        var registration = ctrl.newRegistration;
        var activity= component.get("v.activity");
        
        /* console.log('1>>>>'+ctrl);   
        console.log('1>>>>'+address);   
        console.log('1>>>>'+JSON.stringify(registration));   
        console.log('1>>>>'+activity);   */
        
        var self = this;         
        
        this.callServerAction(component,"c.saveCustomerUpdate", {
            "newAddress": JSON.stringify(address),
            "newRegistration": JSON.stringify(registration), 
            "activity" : activity 
        })
        .then(
            $A.getCallback(function(resp) {
                
                if($A.util.isEmpty(resp)){
                    
                    throw new Error('An Error occurred while saving the Record.')
                    component.set("v.showSpinner", false);
                    component.set("v.isSaved", false);
                    var errors = resp;
                    if (errors) {
                        errors.forEach( function (error){
                            if (error.fieldErrors){
                                error.fieldErrors.forEach( function(fieldError) {
                                    //alert("Error message: " + fieldError.message);                    
                                });
                            }
                        });
                    } 
                    
                }else {                                     
                    console.log('Hi--->'+JSON.stringify(resp));
                    component.set("v.caseDetail", resp);
                    component.set("v.showSpinner", false);
                    if(activity!== 'delete'){
                        //alert('before file');
                        var fileInput = component.find("fileDoc").getElement();
                        //alert(fileInput);            
                        console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
                        console.log("[FileUpload].[=====file type=====]"+typeof fileInput.files[0].name);
                        if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){      
                            console.log('=========save file before=======');
                            try{
                                self.saveuploadFile(component,fileInput);
                                console.log("[Dummy Method].[Calling]");
                                self.callDummyMethod(component); // This is only required for file upload
                                console.log("[Dummy Method].[Called]");
                                
                            }catch(err){
                                console.log('error--> '+err.message);
                                component.set("v.isSaved", false);
                            }
                        }
                        component.set("v.showSpinner", false);                         
                    }
                    
                    
                }
                
            }))
        .catch($A.getCallback(function(errorsresp) {
            component.set("v.showSpinner", false);
            component.set("v.isSaved", false);
            self.logActionErrors(component, errorsresp);                                                    
            //*********save Address record *************
        }));
        
        
    },
    logActionErrors : function(component, response) {
        // console.log(JSON.stringify(response, null, 2));
        
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
                console.log('validnot--->'+response.getState());
                if (component.isValid() && response.getState() === 'SUCCESS'){
                    
                    resolve(response.getReturnValue());
                } else {                   
                    console.log('Error calling action "' + actionName + '" with state: ' + response.getState());                   
                    reject(response); 
                }
            });
            $A.enqueueAction(action);
        });       
        return p;
    },
    
})