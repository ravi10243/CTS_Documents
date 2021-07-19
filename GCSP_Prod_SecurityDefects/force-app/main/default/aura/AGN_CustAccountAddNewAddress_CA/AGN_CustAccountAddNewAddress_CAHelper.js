({
    fetchCountrySettings : function(component, event) {
        
        var action = component.get('c.getLayout');   
        if(component.get("v.controller.config.Country_Code_AGN__c") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '2'            
            });       
        }
        else{
             /*console.log('ccode-->'+component.get("v.controller.config.Country_Code_AGN__c"));
             console.log('ccode-->'+component.get("v.controller.config.Category_AGN__c"));
             console.log('ccode-->'+component.get("v.controller.config.Sub_Category__c")); */
            
            action.setParams({       
                'country': component.get("v.controller.config.Country_Code_AGN__c"), //FR, DE            
                'stepNo': '2',
                'customerType': component.get("v.controller.config.Category_AGN__c"), //Pharmacies',//
                'customerSubType': component.get("v.controller.config.Sub_Category__c") //'Pharmacies with wholesaler licence'// 
            });
        } 
        // action.setStorable();
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
                
                /* for UsLicense and Buying Group ----- start */  
                
                var usLicenseLabel = $A.get("$Label.c.AGN_OAM_US_License_HCP");
                component.set("v.usLicenseLabel" , usLicenseLabel);            
                component.set("v.buyingGroupLabel", $A.get("$Label.c.AGN_OAM_Are_you_apart_Buying_Group"));
                var country= component.get("v.controller.config.Country_Code_AGN__c");
                this.fetchDependantFields(component, country);
                
                /* for UsLicense and Buying Group ------- End */  
                
               
                
                console.log('map---->'+JSON.stringify(component.get("v.sectionHeaderMapShipTo")));
                
            } else {
                component.set("v.showSpinner", false);
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);        
        
    },
    
    fetchPaymentSettingdetails : function(component, event){        
        var action = component.get('c.getLayout');
        if(component.get("v.controller.config.Country_Code_AGN__c") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '4'            
            });       
        }
        else{
            action.setParams({       
                'country': component.get("v.controller.config.Country_Code_AGN__c"), //FR, DE            
                'stepNo': '4',
                'customerType': component.get("v.controller.config.Category_AGN__c"), //Pharmacies',//
                'customerSubType': component.get("v.controller.config.Sub_Category__c") //'Pharmacies with wholesaler licence'// 
            });
        } 
        
        //action.setStorable();
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
                        // console.log('value-->'+JSON.stringify(cmps.value));
                        cmps.value.forEach( function (cmp){                                   
                            //console.log('value1-->'+JSON.stringify(cmp.Field_Name_AGN__c));
                            if(cmp.SObject_Name_AGN__c == 'Allergan_Customer_Address_AGN__c' && cmp.Field_Name_AGN__c != 'Address_Line_1_AGN__c'){
                                // console.log('value-->'+JSON.stringify(cmp));
                                settingsPayment.push(cmp);
                            }
                            
                        });                              
                        
                    });
                }
                var billTo= $A.get("$Label.c.AGN_OAM_Body_Bill_To");
                var CG = component.get("v.customerGroup");               
                var pMethod = component.get("v.controller.paymentMethod.Name");
                if(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != 'CCNT' ){ 
                    component.set('v.sectionHeaderMapPayment', settingsPayment); 
                    
                }else if(component.get("v.activity") == 'new' && component.get("v.type") == billTo){
                    component.set('v.sectionHeaderMapPayment', settingsPayment);
                } 
                
                component.set('v.address',component.get('v.controller.newAddress'));
                
                //console.log('map---->'+JSON.stringify(component.get("v.sectionHeaderMapPayment")));
                
            } else {
                
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    fetchDependantFields : function(component , country){
        //console.log("calling dependant fields method>>>>>>>>>>>>>>>>>"+country);
        var action = component.get('c.getDependantLayout');
        action.setParams({       
            'country': country
        });
        action.setCallback(this, function(response) {
            console.log("Dependent settings call status>>>>>>"+response.getState());
            if(response.getState() === 'SUCCESS') {
                var settings = [];                
                var BGsettings = []; // for buying group
                var accountOwnerSettings = [];
                
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
                    }
                    if(key === 'Part_of_a_Buying_Group_AGN__c'){
                        var flist = settingsMap[key];
                        console.log(flist);
                        for(var item in flist){
                            var rec = flist[item];
                            rec.FieldValue_AGN__c = "";
                            BGsettings.push(rec);
                        } 
                    }
                    if(key === 'Doctors_Email_AGN__c'){
                        var flist = settingsMap[key];
                        //console.log(flist);
                        for(var item in flist){
                            var rec = flist[item];
                            rec.FieldValue_AGN__c = "";
                            accountOwnerSettings.push(rec);
                        } 
                    }
                }
                //  console.log("settings>>>>>>>>>>>>>>"+JSON.stringify(settings));
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
               component.set("v.showSpinner", false); 
            } else {
                component.set("v.showSpinner", false); 
                this.logActionErrors(component, response);
            }
            console.log(component.get("v.USLicenseDependantFields"));
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
        
        console.log('form of payment >>>'+ component.get('v.controller.config.Country_Code_AGN__c'));
        
        var action = component.get("c.getPickListValues");
        var columnName='Name,Form_Of_Payment_Label_AGN__c';
        var columnId='Id';
        var objectName='Form_Of_Payment_AGN__c';
        var country = component.get('v.controller.config.Country_Code_AGN__c');
        var countryCode = "'" + country + "'";
        var whereCondition=' where SAP_Country_Code_AGN__c='+countryCode+' AND Active_AGN__c= true';
        //action.setStorable();
        action.setParams({
            objectName : objectName,
            columnName : columnName,
            columnId : columnId,
            whereCondition: whereCondition
        });  
        action.setCallback(this, function(a) {              
            var paymentMethodVal = a.getReturnValue();           
            var CG = component.get("v.customerGroup");
            var PmVal=[]; 
            var CGForPaymentinfo = $A.get("$Label.c.AGN_OAM_CG_PaymentInfoSection"); 
            if(!paymentMethodVal) return;
            if($A.util.isArray(paymentMethodVal)){
                for(var i in paymentMethodVal){                    
                    if(country =='CA' && CGForPaymentinfo.includes(CG) ){     //(cGroup ==='HR' || cGroup ==='HS')                  
                        if(paymentMethodVal[i].Name!= $A.get("$Label.c.AGN_OAM_CreditCard")){                            
                            PmVal.push(paymentMethodVal[i]);                            
                        }
                        
                    }else{                         
                        PmVal.push(paymentMethodVal[i]);                        
                    }                        
                }
            }
            component.set("v.PaymentMethod", PmVal);       
            console.log('v.PaymentMethod===>'+JSON.stringify(component.get("v.PaymentMethod")));
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
                var columnName='Name,Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__r.Form_Of_Payment_Label_AGN__c='+pmethodvalue+'OR Form_Of_Payment__r.Name='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();
                    
                    if(pmethod != $A.get("$Label.c.AGN_OAM_CreditCard")){                        
                        for(var i in paymentTermval){
                            component.set("v.PaymentTerm1", paymentTermval[i].Name);                           
                        } 
                        this.onChangePaymentTerm(component, event, helper);
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
        var PaymentSecFields =component.get('v.sectionHeaderMapPayment');
        var secVal =[];
        if(pmethod != null && pmethod != '' && paymentTerm != null && paymentTerm != ''){
            if(paymentTerm != $A.get("$Label.c.AGN_OAM_Payment_Time_of_Order")){
                component.set('v.isShow',true);
                component.set('v.sectionPaymentCreditList', PaymentSecFields);
            }else{                               
                component.set('v.sectionPaymentCreditList', secVal);
                component.set('v.isShow',false);                
            }           
            
        }else{
            component.set('v.isShow',false);
            component.set('v.sectionPaymentCreditList', secVal);
        }
        console.log('@@pmethod>>'+pmethod+'@@@paymentTerm>>>>'+paymentTerm + 'ccode>>>'+component.get('v.controller.config.Country_Code_AGN__c'));
        console.log('@@TradeReferenceFields>>',component.get('v.sectionPaymentCreditList'));
        var action = component.get("c.getPaymentDetails");         
        action.setParams({       
            "formofPayment": pmethod,                
            "paymentTerm": paymentTerm,
            "countryCode" : component.get('v.controller.config.Country_Code_AGN__c')           
        }); 
        action.setCallback(this, function(a) {
            var objVal = a.getReturnValue();
            
            component.set('v.controller.newRegistration.Form_of_Payment_AGN__c', objVal[0].Id);
            component.set('v.controller.newRegistration.Payment_Term_AGN__c', objVal[1].Id);
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')));
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Payment_Term_AGN__c')));
            
        });        
        $A.enqueueAction(action);  
        
        
    },
    
    /* -------------- if Customer Payment is isNull ------------------ End  */
    
    
    /* --------------- if if Customer Payment Mathod is notNull and PaymentTerm is isNull --  start  ---------*/
    
    getPaymentTermValues : function(component, event, helper){
        
        try{
            var pmethod = component.get("v.controller.paymentMethod.Name");           
            // console.log('pmethod>>>>>'+pmethod);
            
            if(pmethod != null && pmethod != '' ){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                console.log('pmethodvalue-->'+pmethodvalue);
                var columnName='Name,Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__r.Form_Of_Payment_Label_AGN__c='+pmethodvalue+'OR Form_Of_Payment__r.Name ='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();
                    //console.log('v.PaymentTerm===>'+JSON.stringify(paymentTermval));
                    if(pmethod != $A.get("$Label.c.AGN_OAM_CreditCard")){                        
                        for(var i in paymentTermval){
                            component.set("v.PaymentTerm1", paymentTermval[i].Name);                           
                        } 
                        this.onChangePaymentTermForCustPayment(component, event, helper);
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
        
        var pmethod = component.get("v.controller.paymentMethod.Name");
        var paymentTerm = component.get("v.PaymentTerm1"); 
        var PaymentSecFields =component.get('v.sectionHeaderMapPayment');
        var secVal =[];
        if(pmethod != null && pmethod != '' && paymentTerm != null && paymentTerm != ''){
            if(paymentTerm != $A.get("$Label.c.AGN_OAM_Payment_Time_of_Order")){
                component.set('v.isShow',true);
                component.set('v.sectionPaymentCreditList', PaymentSecFields);                
            }else{
                component.set('v.isShow',false);
                component.set('v.sectionPaymentCreditList', secVal);
            }           
            
        }else{
            component.set('v.isShow',false);
            component.set('v.sectionPaymentCreditList', secVal);
        }
        console.log('@@pmethod>>'+pmethod+'@@@paymentTerm>>>>'+paymentTerm + 'ccode>>>'+component.get('v.controller.config.Country_Code_AGN__c'));
        console.log('@@TradeReferenceFields2>>',component.get('v.sectionPaymentCreditList'));
        var action = component.get("c.getPaymentDetails");         
        action.setParams({       
            "formofPayment": pmethod,                
            "paymentTerm": paymentTerm,
            "countryCode" : component.get('v.controller.config.Country_Code_AGN__c')           
        }); 
        action.setCallback(this, function(a) {
            var objVal = a.getReturnValue();
            
            component.set('v.controller.newRegistration.Form_of_Payment_AGN__c', objVal[0].Id);
            component.set('v.controller.newRegistration.Payment_Term_AGN__c', objVal[1].Id);
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')));
            console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Payment_Term_AGN__c')));
            
        });        
        $A.enqueueAction(action);  
        
        
    },
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  end  ---------*/
    
    
    getDocumentForSignDoc : function(component, event){
        console.log("type>>>>>>>>>>"+component.get("v.type"));
        var actionDoc = component.get("c.getDocument");
        actionDoc.setParams({
            "type": component.get("v.type"),
            "CustomerGroup":component.get("v.customerGroup")
        });      
        actionDoc.setCallback(this, function(a) {
            var status = a.getState();
            console.log("status>>>>>>>>>>"+a.getReturnValue());
            if(status === "SUCCESS"){
                component.set("v.DownLodWetSignDoc",a.getReturnValue());                
            }
            else {                
                component.set("v.showSpinner", false);
            }
            
        }); 
        $A.enqueueAction(actionDoc);
        console.log("getDocumentForSignDoc>>>>>>>>>>"+component.get("v.DownLodWetSignDoc"));
    },
    
    MAX_DOC_FILE_SIZE: 2500000, /* 1 000 000 * 3/4 to account for base64 */
    // MAX_DOC_FILE_SIZE: 5000000,
    saveuploadFile : function(component,fileInput) {
        
        //component.set("v.showSpinner", true);
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
        jQuery.noConflict();       
        component.set("v.requireFieldMissing",false);
        component.set("v.fieldWellFormated",true);
        var requiredMissing = false;
        
        const cmpsSoldTo =  component.find("fieldSoldTo");
        const cmpSoldToPayment = component.find("fieldSoldToPayment");
        const cmpSoldToPayment1 = component.find("fieldSoldToPayment1");
        const cmpsShipTo = component.find("fieldShipTo");
        const cmpsBillTo = component.find("fieldBillTo");
        const cmpBillToPayment = component.find("fieldBillToPayment");
        const cmpBillToPayment1 = component.find("fieldBillToPayment1");
        
        const cmpSBS = [];
        
        if(component.get("v.type") === component.get("v.soldTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsSoldTo);  
            
            if(component.get('v.isShow')){
                cmpSBS.push(cmpSoldToPayment1);
            }else if(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != 'CCNT' && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != null){
                cmpSBS.push(cmpSoldToPayment);
            }
            
        }else if(component.get("v.type") === component.get("v.shipTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsShipTo);
            
            
        }else if(component.get("v.type") === component.get("v.billTo")){
            console.log('v.type--->'+component.get("v.type")); 
            cmpSBS.push(cmpsBillTo);
            if(component.get('v.isShow')){
                cmpSBS.push(cmpBillToPayment1);
            }else if(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != 'CCNT' && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != null){
                cmpSBS.push(cmpBillToPayment);
            }
        } 
        
        var PMethod = component.get('v.controller.newRegistration.Payment_Term_AGN__c');
        var PTerm = component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')
        if(component.get("v.type") != component.get("v.shipTo") && (component.get("v.controller.paymentTerm") == null || component.get("v.controller.paymentMethod") == null)){           
             if( PMethod == null){
                component.set("v.PTfieldValueMissing",true); 
                requiredMissing = true;
            }else{
                component.set("v.PTfieldValueMissing",false); 
                requiredMissing = false;
            }
            if( PTerm == null){            
                component.set("v.PMfieldValueMissing",true); 
                requiredMissing = true;
            }else{
                component.set("v.PMfieldValueMissing",false); 
                requiredMissing = false;
            }
        }
       
        //const cmps = component.find("fieldId");
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            cmpSBS.forEach( function (cmps){
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        //console.log('is empty');
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                        
                        console.log("Required Fields>>>>"+cmp.get("v.customLabelName"));
                    }
                    else{
                        cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
            });
            
           /********* US License Validation for Canada Starts***********/
            
            var licenseCmp = component.get("v.USLicenseDependantFields");   
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
                console.log("US license validation completed>>>>"+requiredMissing);
            }
            //component.set("v.USLicenseDependantFields" , licenseCmp);
            
            /********* US License Validation for Canada Ends*************/
            
            /********* Account Owner for Canada Starts***********/
            
            var lcmp = component.find("accountOwnerField");
            var accountownerRequired = false;           
            
            if(!$A.util.isEmpty(lcmp) && component.get("v.isAccountOwner")){
                var licenseCmp = component.get("v.AccountOwnerDependantFields");
                licenseCmp.forEach( function (cmp){
                    // console.log("yo>>>>>>>>>>>>>>>>",cmp);
                    if ($A.util.isEmpty(cmp.FieldValue_AGN__c)){
                        console.log("account owner require field missing>>>>>>>>>>>>"+cmp.Field_Name_AGN__c);
                        requiredMissing = true;  
                        cmp.FieldValue_Missing_AGN__c = true;
                        accountownerRequired = true;
                    }
                });
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
                console.log("Account Owner validation completed>>>>"+requiredMissing);
            }
            
            /********* Account Owner Validation for Canada Ends*************/
            
            /********* Buying Group for Canada Starts***********/
            
            var bGroupCmp = component.get("v.BuyingGroupDependantFields");  
            var buyingGrpRequired = false;
            var bcmp = component.find("buyingGrpField");
            if(!$A.util.isEmpty(bcmp) && bcmp.get("v.required")){
                bGroupCmp.forEach( function (cmp){
                    if ($A.util.isEmpty(cmp.FieldValue_AGN__c)){
                        console.log("required Buying field missing>>>>>>>>>>>>>>>>"+cmp.Field_Name_AGN__c);
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
                console.log("Buying Group validation completed>>>>"+requiredMissing);
            }
            
            /*********Buying Group Validation for Canada Ends*************/
            
            if(requiredMissing){
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
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
        
        const cmpsSoldTo =  component.find("fieldSoldTo");
        const cmpSoldToPayment = component.find("fieldSoldToPayment");
        const cmpSoldToPayment1 = component.find("fieldSoldToPayment1");
        const cmpsShipTo = component.find("fieldShipTo");
        const cmpsBillTo = component.find("fieldBillTo");
        const cmpBillToPayment = component.find("fieldBillToPayment");
        const cmpBillToPayment1 = component.find("fieldBillToPayment1");
        
        const cmpSBS = [];
        
        if(component.get("v.type") === component.get("v.soldTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsSoldTo);  
            
            if(component.get('v.isShow')){
                cmpSBS.push(cmpSoldToPayment1);
            }else if(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != 'CCNT' && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != null){
                cmpSBS.push(cmpSoldToPayment);
            }
            
        }else if(component.get("v.type") === component.get("v.shipTo")){
            console.log('v.type--->'+component.get("v.type"));
            cmpSBS.push(cmpsShipTo);            
            
        }else if(component.get("v.type") === component.get("v.billTo")){
            console.log('v.type--->'+component.get("v.type")); 
            cmpSBS.push(cmpsBillTo);
            if(component.get('v.isShow')){                
                cmpSBS.push(cmpBillToPayment1);
            }else if(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != 'CCNT' && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") != null){ 
                cmpSBS.push(cmpBillToPayment);
            }
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
            /********* US License Format Validation for Canada Starts***********/
            
            var lcmp = component.find("licenseField");
            if(!$A.util.isEmpty(lcmp)){
                var isValid = true;
                var notFormattedFields = "";
                var licenseCmp = component.get("v.USLicenseDependantFields");
                licenseCmp.forEach( function (cmp){
                    if (!$A.util.isEmpty(cmp.Field_Regex_AGN__c) && !$A.util.isEmpty(cmp.FieldValue_AGN__c)){
                        if(!cmp.Is_Format_Valid_AGN__c){
                            // console.log("Not Formatted Fields>>>>>>"+cmp.Field_Name_AGN__c);
                            wellFormatted = false;
                            whichFields += cmp.Field_Label_AGN__c + ", ";
                            isValid = false;
                            notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                        }
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
            
            /********* US License Format Validation for Canada Ends*************/
            
            /********* Account Owner Format for Canada Starts***********/
            var lcmp = component.find("accountOwnerField");
            //console.log("Account Owner>>>>>>>>>>>>",lcmp,"<<<<<<<<<<<<<<<");
            //console.log(component.get("v.isAccountOwner"));
            //console.log(component.get("v.AccountOwnerDependantFields"));
            
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
            console.log("Account Owner format validation completed");
            /********* Account Owner Format Validation for Canada Ends*************/
            
            
            /********* Buying Group Format Validation for Canada Starts***********/          
            var lcmp = component.find("buyingGrpField");
            if(!$A.util.isEmpty(lcmp)){
                var isValid = true;
                var notFormattedFields = "";
                var licenseCmp = component.get("v.BuyingGroupDependantFields");
                licenseCmp.forEach( function (cmp){
                    if (!$A.util.isEmpty(cmp.Field_Regex_AGN__c) && !$A.util.isEmpty(cmp.FieldValue_AGN__c)){
                        if(!cmp.Is_Format_Valid_AGN__c){
                            //console.log("Not Formatted Fields>>>>>>"+cmp.Field_Name_AGN__c);
                            wellFormatted = false;
                            whichFields += cmp.Field_Label_AGN__c + ", ";
                            isValid = false;
                            notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                        }
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
            
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                component.set("v.showSpinner", false);
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;                
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{                
                console.log("SaveAddressRecords");                
                this.SaveAddressRecords(component, event);
            }  
        }
        
    },
    
    SaveAddressRecords : function(component, event){
        
        component.set("v.isSaved", true);
        var activity= component.get("v.activity");
        
        console.log('1');        
        var ctrl = component.get("v.controller");
        var address = ctrl.newAddress;
        var registration = ctrl.newRegistration;
        var activity= component.get("v.activity");
        
        var self = this; 
        
       // component.set("v.showSpinner", true);
        
        /********* US License Validation for Canada Starts***********/
        
        // var objSoldTo = address;
        var lcmp = component.find("licenseField");
        if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
            var licenseCmp = component.get("v.USLicenseDependantFields");
            licenseCmp.forEach( function (lcmp){
                if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                    address[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c;
                    address.US_License_HCP_AGN__c = true;
                }else{
                    address.US_License_HCP_AGN__c = false;
                }  
            })
        } 
        // component.set(address, objSoldTo);
        
        /********* US License Validation for Canada Starts***********/
        
        /********* Account Owner for Canada Starts***********/
        
        //var objSoldTo = address;
        var lcmp = component.find("accountOwnerField");
        if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
            var licenseCmp = component.get("v.AccountOwnerDependantFields");
            licenseCmp.forEach( function (lcmp){
                if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                    address[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                    address.Registering_on_behalf_of_owner_AGN__c = true;
                }else{
                    address.Registering_on_behalf_of_owner_AGN__c = false;
                }  
            })
        } 
        // component.set(address, objSoldTo);       
       
        
        /*********Account Owner for Canada End***********/
        
        /********* Buying Group Validation for Canada Starts***********/
        
        //var objSoldTo = address;
        var lcmp = component.find("buyingGrpField");
        if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
            var licenseCmp = component.get("v.BuyingGroupDependantFields");
            licenseCmp.forEach( function (lcmp){
                if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                    address[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                }  
            })
        } 
        // component.set(address, objSoldTo);
        
        console.log('Address>>>'+JSON.stringify(address));
        
        /*********Buying Group Validation for Canada End***********/
        
        this.callServerAction(component,"c.saveCustomerUpdate", {
            "newAddress": JSON.stringify(address),
            "newRegistration": JSON.stringify(registration), 
            "activity" : activity 
        })
        .then(
            $A.getCallback(function(resp) {
                
                if($A.util.isEmpty(resp)){
                    component.set("v.showSpinner", false);
                    throw new Error('An Error occurred while saving the Record.')
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
                        
                        const fileInputList = [];  
                        var fileInput = component.find("fileDoc").getElement();
                        console.log('fileInput>>>>>'+JSON.stringify(fileInput.files[0].name));
                        fileInputList.push(fileInput);
                        if(component.get("v.type") == component.get("v.soldTo")){
                            var fileInput3 = component.find("fileDoc3").getElement();
                            console.log('fileInput3>>>>>'+JSON.stringify(fileInput3.files[0].name));
                            fileInputList.push(fileInput3);
                        }
                        if(component.get("v.isLicenseDocument")){
                            var fileInput2 = component.find("fileDoc2").getElement();
                            var fileInput1 = component.find("fileDoc1").getElement(); 
                            fileInputList.push(fileInput1);
                            fileInputList.push(fileInput2);
                        }
                        if(component.get("v.isLicenseDocumentForBC")){
                            var fileInput6 = component.find("fileDoc6").getElement();
                            console.log('fileInput6>>>>>'+JSON.stringify(fileInput6.files[0].name));
                            fileInputList.push(fileInput6);
                        }
                        if(component.get("v.isLicenseDocumentAB")){
                            var fileInput4 = component.find("fileDoc4").getElement();
                            var fileInput5 = component.find("fileDoc5").getElement(); 
                            fileInputList.push(fileInput4);
                            fileInputList.push(fileInput5);
                        }
                        
                        if (!fileInputList) return;
                        if ($A.util.isArray(fileInputList)){
                            fileInputList.forEach( function (cmps){
                                console.log('fileInputList[i]>>>>>>>>>'+JSON.stringify(cmps.files[0].name));
                                if (typeof cmps.files[0].name !== "undefined" && cmps.files[0].name!=='' ){ 
                                    try{
                                        self.saveuploadFile(component,cmps);
                                        console.log("[Dummy Method].[Calling]");
                                        self.callDummyMethod(component); // This is only required for file upload
                                        console.log("[Dummy Method].[Called]");
                                        component.set("v.showSpinner", false);
                                    }catch(err){
                                        component.set("v.showSpinner", false);
                                        component.set("v.isSaved", false);
                                        console.log('error--> '+err.message);
                                    }
                                }
                            });
                        }
                        
                        
                        /*  //alert('before file');                        
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
                            }
                        } */
                        component.set("v.showSpinner", false);                         
                        
                    }
                    component.set("v.showSpinner", false);
                }
                
            }))
        .catch($A.getCallback(function(errorsresp) {
            self.logActionErrors(component, errorsresp); 
            component.set("v.isSaved", false);
            component.set("v.showSpinner", false);
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
                console.log("Address Respose>>>>>>>>>>>>>",resp);
                if(resp.length > 0){
                    component.set("v.activeAddressFound" , true);
                    component.set("v.addressOps" , resp);
                    component.set("v.isOpen" , true);
                }else{
                    alert("No valid address found");
                }
            })) 
            .catch($A.getCallback(function(errorsresp) {
                self.logActionErrors(component, errorsresp);         
            }));
        }else{
            alert("Please add values for required address fields");
        }
    },
    
})