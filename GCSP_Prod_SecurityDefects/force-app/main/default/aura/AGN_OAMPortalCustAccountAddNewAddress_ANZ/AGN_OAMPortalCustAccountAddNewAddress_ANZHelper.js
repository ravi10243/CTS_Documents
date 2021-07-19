({
    fetchCountrySettings : function(component, event) {
        
        var action = component.get('c.getLayout');
        console.log('method colling for de-->'+JSON.stringify(component.get("v.SAPcountryCode")));
        console.log('method colling for de-->'+JSON.stringify(component.get("v.customerType")));
        console.log('method colling for de-->'+JSON.stringify(component.get("v.customerSubType")));
        action.setParams({       
            'country': component.get("v.SAPcountryCode"), //FR, DE            
            'stepNo': '2',
            'customerType': component.get("v.customerType"), //Pharmacies',//
            'customerSubType': component.get("v.customerSubType") //'Pharmacies with wholesaler licence'// 
        });
        
        // action.setStorable();
        action.setCallback(this, function(response) {
           // console.log('response.getState()-->'+response.getState());
            if(response.getState() === 'SUCCESS') {
                var settingsSoldTo = [];
                var settingsBillTo = [];
                var settingsShipTo = [];
                var settingsMap = response.getReturnValue();
               // console.log('method colling for settingsMap-->'+JSON.stringify(settingsMap));
                for(var key in settingsMap){
                    //settingsSoldTo.push({value:settingsMap[key], key:key});                     
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
               
                
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);        
        
    },
    
    fetchPaymentSettingdetails : function(component, event){        
       var action = component.get('c.getLayout');      
        action.setParams({       
            'country': component.get("v.SAPcountryCode"), //FR, DE            
            'stepNo': '4',
            'customerType': component.get("v.customerType"), //Pharmacies',//
            'customerSubType': component.get("v.customerSubType")
        });        
        
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
                       //console.log('value-->'+JSON.stringify(cmps.value));
                        cmps.value.forEach( function (cmp){ 
                            settingsPayment.push(cmp);                          
                        });                              
                        
                    });
                }
                var billTo= $A.get("$Label.c.AGN_OAM_Body_Bill_To");
                
                var pMethod = component.get("v.controller.paymentMethod.Name");
                var pTerm = component.get("v.controller.paymentTerm.Id");
                console.log(pMethod+'>>>>>>'+pTerm);                
                
                if(typeof(pMethod) != "undefined" || typeof(pTerm) != "undefined"){
                  if(pMethod.toUpperCase() == $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month") && !$A.util.isEmpty(pMethod) && !$A.util.isEmpty(pTerm)){//
                    component.set("v.isShowreferenceFields",true);
                    component.set('v.sectionHeaderMapPayment', settingsPayment);                    
                	}   
                }
                
                if($A.util.isEmpty(pMethod) || $A.util.isEmpty(pTerm) || typeof(pMethod) == "undefined" || typeof(pTerm) == "undefined"){ 
                    component.set('v.sectionHeaderMapPayment', settingsPayment);               
                    	
                    component.set("v.isShowPaymentdropdown", true);
                    	this.getPaymentMethodValues(component, event);
                        
                }              
                
                //component.set('v.sectionHeaderMapPayment', settingsPayment); 
                component.set('v.address',component.get('v.controller.newAddress'));
                
               //console.log('map---->'+JSON.stringify(component.get("v.sectionHeaderMapPayment")));
                
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    fetchDependantFields : function(component , event){      
          
        var action = component.get('c.getDependantLayout');
        action.setParams({       
            'country': component.get("v.SAPcountryCode")
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
                component.set("v.disablePrescribingDr" , true); 
                component.set("v.clearPrescribingDrValues" , false);
                component.set("v.clearPrescribingDrRequiredFields" , false);
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
    
    
    getPaymentMethodValues : function(component, event){//, helper){
        //var self = this;
        console.log('form of payment >>>'+ component.get('v.SAPcountryCode'));
        
 		var country = component.get("v.SAPcountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        
        var action = component.get("c.getPickListValues");      
        var columnName = 'Name,Form_Of_Payment_Label_AGN__c'
        var columnId='Id';
        var objectName='Form_Of_Payment_AGN__c';
        var countryCode = "'" + country + "'";
        var whereCondition=' where SAP_Country_Code_AGN__c='+countryCode+' AND Active_AGN__c= true';
   //console.log('respState -- >1');
        //action.setStorable();        
        action.setParams({
            objectName : objectName,
            columnName : columnName,
            columnId : columnId,
            whereCondition: whereCondition
        });
        //console.log('respState -- >2');
        action.setCallback(self, function(rs) {
            console.log('respState -- >4');
           //console.log("@@@fop val resopnce>>>"+ rs.getReturnValue());
           //console.log('@@@fopresopnce>>>'+actionResult.getState());
           var respState = rs.getState();
            console.log('respState -- >' + respState);
            
            var paymentMethodVal = rs.getReturnValue();
			console.log('v.PaymentMethod===>'+JSON.stringify(paymentMethodVal));            
            var PmVal=[];
            if(!paymentMethodVal) return;
            if($A.util.isArray(paymentMethodVal)){
                for(var i in paymentMethodVal){                 
                    PmVal.push(paymentMethodVal[i]);                                            
                }
            }
            
            component.set("v.PaymentMethod", PmVal);                  
            
             console.log('v.PaymentMethod===>'+JSON.stringify(component.get("v.PaymentMethod"))); 
        }); 
        //console.log('respState -- >3');
        $A.enqueueAction(action); 
        
    },
    
    onChangePaymentMethod : function(component, event, helper){
        try{
            var pmethod = component.find("paymentMethod").get("v.value");
            if(!$A.util.isEmpty(pmethod)){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                console.log('pmethodvalue-->'+pmethodvalue);
                var columnName='ID,Name,Payment_Term_Label_AGN__c';
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
                    component.set("v.PaymentTerm", paymentTermval);
                    this.onChangePaymentTerm(component, event, helper);
                    
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
        console.log('@@@Payment>>',PaymentSecFields);
        if(!$A.util.isEmpty(pmethod) && !$A.util.isEmpty(paymentTerm)){
             var paymentMethodVal = component.get("v.PaymentMethod"), 
                value = component.find("paymentMethod").get("v.value"),
                index = paymentMethodVal.findIndex(item => item.Id == value),
                pName = index >= 0? paymentMethodVal[index].Name: null;
            
            if(pName.toUpperCase() === $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month")){
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
        //console.log('@@pmethod>>'+pmethod+'@@@paymentTerm>>>>'+paymentTerm + '>>>ccode>>>'+component.get('v.SAPcountryCode'));
        //console.log('@@TradeReferenceFields>>',component.get('v.sectionPaymentCreditList'));
        //component.set('v.controller.newRegistration.Form_of_Payment_AGN__c', pmethod);
        //component.set('v.controller.newRegistration.Payment_Term_AGN__c', paymentTerm);
        component.set('v.controller.newAddress.Form_of_Payment_AGN__c', pmethod);
        component.set('v.controller.newAddress.Payment_Term_AGN__c', paymentTerm);
        
        //console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Form_of_Payment_AGN__c')));
       // console.log('@@@@@objVal>>>>'+JSON.stringify(component.get('v.controller.newRegistration.Payment_Term_AGN__c'))); 
        
    },    
    /* -------------- if Customer Payment is isNull ------------------ End  */  
    
    
    MAX_DOC_FILE_SIZE: 2500000, /* 1 000 000 * 3/4 to account for base64 */
    // MAX_DOC_FILE_SIZE: 5000000,
    saveuploadFile : function(component,fileInput) {
        
        component.set("v.showSpinner", true);
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
            }else if(component.get("v.isShowreferenceFields")){
                //component.get("v.controller.paymentMethod.Name") == $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month") && component.get("v.controller.paymentTerm.Id") != null
                
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
            }else if(component.get("v.isShowreferenceFields")){
                //component.get("v.controller.paymentMethod.Name") == $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month") && component.get("v.controller.paymentTerm.Id") != null
                cmpSBS.push(cmpBillToPayment);
            }
        } 
        console.log('cmpSBS>>>>>',cmpSBS);
        var PMethod = component.get("v.PaymentMethod1");//component.get('v.controller.newRegistration.Form_of_Payment_AGN__c');
        var PTerm = component.get("v.PaymentTerm1");//component.get('v.controller.newRegistration.Payment_Term_AGN__c');
        console.log('PMethod>>>>>'+PMethod+'>>>PTerm'+PTerm);
        if(component.get("v.type") != component.get("v.shipTo") && component.get("v.isShowPaymentdropdown")){
            //(component.get("v.controller.paymentTerm") == null || component.get("v.controller.paymentMethod") == null)           
            if($A.util.isEmpty(PTerm)){
                component.set("v.PTfieldValueMissing",true); 
                requiredMissing = true;
            }else{
                component.set("v.PTfieldValueMissing",false); 
                requiredMissing = false;
            }
            if($A.util.isEmpty(PMethod)){            
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
                console.log('fieldValue>>>',cmps);
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        console.log('is empty');
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                        
                        console.log("Required Fields>>>>"+cmp.get("v.customLabelName"));
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
                component.set("v.showSpinner",false);
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
            }else if(component.get("v.isShowreferenceFields")){
                //component.get("v.controller.paymentMethod.Name") == $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month") && component.get("v.controller.paymentTerm.Id") != null
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
            }else if(component.get("v.isShowreferenceFields")){
                //component.get("v.controller.paymentMethod.Name") == $A.get("$Label.c.AGN_OAM_30Days_End_Of_Month") && component.get("v.controller.paymentTerm.Id") != null){ 
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
                component.set("v.showSpinner",false);
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
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
        
        /********* Prescribing Dr data Start ***********/           
        var objSoldTo = component.get('v.objSoldTo');
        var lcmp = component.find("PrescribingDrField");
        var hasValue = true;
        if(!$A.util.isEmpty(lcmp) && lcmp.get("v.required")){
            var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
            licenseCmp.forEach( function (lcmp){
                if (!$A.util.isEmpty(lcmp.FieldValue_AGN__c)){
                    address[lcmp.Field_Name_AGN__c] =  lcmp.FieldValue_AGN__c; 
                    hasValue = false;
                }  
            })
        }             
        component.set("v.address.Are_You_The_Prescribing_Doctor_AGN__c" , hasValue);
        
        
        /********* Prescribing Dr data End ***********/        
        
        
        this.callServerAction(component,"c.saveCustomerUpdate", {
            "newAddress": JSON.stringify(address),
            "newRegistration": JSON.stringify(registration), 
            "activity" : activity 
        })
        .then(
            $A.getCallback(function(resp) {
                
                if($A.util.isEmpty(resp)){
                    
                    throw new Error('An Error occurred while saving the Record.')
                    component.set("v.showSpinner",false);
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
                    component.set("v.showSpinner", false); 
                    component.set("v.caseDetail", resp);
                    if(activity == 'new'){
	                    //component.set("v.showSpinner", true);                         
                        const fileInputList = [];  
                        var fileInput = component.find("fileDoc").getElement();
                        console.log('fileInput>>>>>'+JSON.stringify(fileInput.files[0].name));
                        fileInputList.push(fileInput);                                            
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
                                        console.log('error--> '+err.message);
                                        component.set("v.showSpinner", false); 
                                        component.set("v.isSaved", false);
                                    }
                                }
                            });
                        }                                        
                        
                    }
                    
                }
                
            }))
        .catch($A.getCallback(function(errorsresp) {
            self.logActionErrors(component, errorsresp); 
            component.set("v.showSpinner", false);
            component.set("v.isSaved", false);
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
    /*
    getLoqateAddress : function(component, selectedCountry) {
        console.log("inside loqate method>>>>>>>>>>>>>>",selectedCountry);
        console.log(component.get('v.objAddr'));
        //this.showSpinner(component);
        if(!$A.util.isEmpty(component.get('v.objAddr.Address_Line_1_AGN__c'))
           && !$A.util.isEmpty(component.get('v.objAddr.Zip_AGN__c'))
           && !$A.util.isEmpty(selectedCountry)){
            var selectedSuite = component.get('v.objAddr.Suite_AGN__c');  
            if($A.util.isEmpty(selectedSuite)){
                component.set("v.addressType" , "Street");
            }else{
                component.set("v.addressType" , "Address");
            }
            this.callServerAction(component, 'c.getValidAddress', {
                'customerAddress' : component.get('v.objAddr'),
                'country' : selectedCountry 
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
    },*/
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
    
})