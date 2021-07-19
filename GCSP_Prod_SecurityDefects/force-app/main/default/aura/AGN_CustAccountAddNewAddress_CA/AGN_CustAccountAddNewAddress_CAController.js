({
    init : function(component, event, helper) {
        
        var selectedLanguage =  $A.get("$Locale.langLocale"); //Ex: 'en_CA' 
        var selectedLanguageVar = selectedLanguage.split('_');
        var userLanguage = "";
        if(selectedLanguageVar.length > 1){
            userLanguage = selectedLanguageVar[0];
        }
        //alert('>>>'+userLanguage);
        component.set("v.CurrentUserLanguage", userLanguage);
        
        component.set("v.showSpinner", true);
        var addressId = helper.getParameterByName('addressId');
        var accountType = helper.getParameterByName('type');
        var activity= helper.getParameterByName('activity');
        
        var soldTo = $A.get("$Label.c.AGN_OAM_Body_Sold_To");
        component.set("v.soldTo", soldTo);
        
        var shipTo = $A.get("$Label.c.AGN_OAM_Body_Ship_To");
        component.set("v.shipTo", shipTo);
        
        var billTo= $A.get("$Label.c.AGN_OAM_Body_Bill_To");
        component.set("v.billTo", billTo);
        
        component.set("v.activity", activity);
        console.log("====activity" +activity);
        
        if (accountType == 'SoldTo')
            component.set("v.type",soldTo);
        
        else if (accountType == 'ShipTo') 
            component.set("v.type", shipTo );  
        
            else if (accountType == 'BillTo')
                component.set("v.type", billTo);
        
        var action = component.get("c.doInit");
        action.setParams({"addressId": addressId, "type": accountType});
        
        action.setCallback(this, function(actionResult) {            
            component.set("v.controller", actionResult.getReturnValue()); 
            component.set("v.countryCode", component.get("v.controller.config.Country_Code_AGN__c")); 
            component.set("v.customerGroup", component.get("v.controller.config.Customer_Group_AGN__c"));
            if(!component.get("v.activity") === 'new'){
                var province = component.get("v.controller.newAddress.State_AGN__c");           
                if(province.includes("-")){
                    var pro = province.split("-");
                    province = pro[1].trim();
                }
                component.set("v.selectedProvince",province); 
            }
            
            
           /* if(component.get("v.controller.newAddress.Doctors_Email_AGN__c") != null ){
                component.set("v.uploadAccountOwnerDocument", true);
            } */
            component.set("v.objMixType", component.get("v.controller.newAddress")); 
                        
            var USLicenseNumber = component.get("v.controller.newAddress.License_Number_US_AGN__c");
            var UsState = component.get("v.controller.newAddress.US_State_AGN__c");
            
            var buyingGroup = component.get("v.controller.newAddress.Buying_Group_Name_AGN__c");
            var memberAccNo = component.get("v.controller.newAddress.Member_Account_Number_AGN__c");
            if(!$A.util.isEmpty(USLicenseNumber) || !$A.util.isEmpty(UsState)){
                component.set("v.showUSLicensedHCP", true);
                component.set("v.isUSLicensedHCP", true);
            }
            if(!$A.util.isEmpty(buyingGroup) || !$A.util.isEmpty(memberAccNo)){
                component.set("v.showBuyingGroup", true);
                component.set("v.isBuyingGroup", true);
            }
            
           // alert('cogh--->'+JSON.stringify(component.get("v.controller.config.Customer_Group_AGN__c"))); 
            helper.fetchCountrySettings(component, event); 
            
            if(component.get("v.type") != billTo){                
                helper.getDocumentForSignDoc(component, event); 
            }
            
            if(component.get("v.type") === soldTo || component.get("v.type") === billTo){
                console.log('cal payment');                
                helper.fetchPaymentSettingdetails(component, event); 
            }
            if(component.get("v.type") === billTo && component.get("v.activity") === 'new'){
                helper.getPaymentMethodValues(component, event, helper);
            }
            
            if(component.get("v.type") === soldTo  && component.get("v.controller.paymentMethod.Form_Of_Payment_Label_AGN__c") == null){
                helper.getPaymentMethodValues(component, event, helper);                
            }
            
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") == null){
                helper.getPaymentTermValues(component, event, helper); 
            }
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm") != null && !$A.util.isEmpty(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c"))){
                component.set("v.PaymentTerm1",component.get("v.controller.paymentTerm.Name"));
            }
        });
        
        $A.enqueueAction(action);  
        console.log("[State Code].[starting]"); 
        
    },
    
    /* -------------- if Customer Payment is isNull ---------------- Start  */
    
    onChangePaymentMethod : function(component, event, helper){
        
        helper.onChangePaymentMethod(component, event, helper);
        
    }, 
    
    onChangePaymentTerm: function(component, event, helper){
        
        helper.onChangePaymentTerm(component, event, helper);
        
    },
    
    
    /* -------------- if Customer Payment is isNull ------------------ End  */
    
    
    /* --------------- if if Customer Payment method is notNull and PaymentTerm is isNull --  start  ---------*/
    onChangePaymentTermForCustPayment: function(component, event, helper){
        
        helper.onChangePaymentTermForCustPayment(component, event, helper);
        
    },
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  end		  ---------*/
    
    /* ---- for UsLicense ---- */
    handleCheckBoxChange : function(component, event, helper){
      	var isChecked = event.getSource().get("v.value");
       if(!isChecked){
           component.set("v.isUSLicensedHCP" , false);
           component.set("v.clearUsLicense" ,  true);
           component.set("v.clearUSLicenseRequiredFields" ,  true);
        }else{
            component.set("v.USLicenseDependantFields" , component.get("v.USLicenseDependantFields"));  
            component.set("v.isUSLicensedHCP" , true);
            component.set("v.clearUsLicense" ,  false);
           component.set("v.clearUSLicenseRequiredFields" ,  false);
        }
        
    },
    
     /* ---- for Account Owner  ---- */
    handleAccountOwnerCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");      
        console.log("account owner : on check>>>>>>>>>>>>>>"+ isChecked);
        if(isChecked){
            component.set("v.isAccountOwner" , false);
            component.set("v.clearAccountOwner" , true);
            component.set("v.clearAccountOwnerRequiredFields" , true);
            component.set("v.uploadAccountOwnerDocument", false); // for Document Upload
        }else{
            component.set("v.isAccountOwner" , true); 
            component.set("v.clearAccountOwner" , false);
            component.set("v.AccountOwnerDependantFields" , component.get("v.AccountOwnerDependantFields"));
            component.set("v.clearAccountOwnerRequiredFields" , false);
            component.set("v.uploadAccountOwnerDocument", true); // for Document Upload
           
          
        }
        
    }, 
    onChangeAccOwner : function (component, event, helper) {
         
       var record = component.get("v.objMixType");
        var fieldName = "Doctors_Email_AGN__c";
        var doctorEmail = record[fieldName];
        var OldValue = component.get("v.controller.newAddress.Doctors_Email_AGN__c");
       // alert('OldValue>>>>>'+OldValue+'>>>>NewValue>>>>>>>'+ doctorEmail );  && OldValue != doctorEmail
        if(!$A.util.isEmpty(doctorEmail) ){
             component.set("v.uploadAccountOwnerDocument", true);            
        }else{
             component.set("v.uploadAccountOwnerDocument", false);   
        }     
        
    },
    /* for Buying Group -- Start */
    handleBGCheckBoxChange : function(component, event, helper){
      var isChecked = event.getSource().get("v.value");
        if(!isChecked){
            component.set("v.isBuyingGroup" , false);
            component.set("v.clearBuyingGroup" ,  true);
            component.set("v.clearBuyingGroupRequiredFields" ,  true);
        }else{
            component.set("v.BuyingGroupDependantFields" , component.get("v.BuyingGroupDependantFields"));
            component.set("v.isBuyingGroup" , true);
            component.set("v.clearBuyingGroup" ,  false);
            component.set("v.clearBuyingGroupRequiredFields" ,  false);
        } 
        
    },
    
    /* for Buying Group -- End */
    
    
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },
    
    doneRendering : function(component,event, helper){
        
        //console.log("doneRendering");
        //jQuery.noConflict();
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
        jQuery('.Basic_det .infr_det').slideDown();
        jQuery('.no_det.active').css("border", "2px solid #a3d233");
        
        if(component.get("v.activity")=='delete'){
            
            jQuery('.input-identifier').each(function(){
                console.log(jQuery(this).find('input')[0]);
            });
        }
        
        if(component.get("v.caseDetail.CaseNumber")!='000000' ){
            jQuery(".basic_details ").slideUp(1000);            
            setTimeout(function(){jQuery(".success_com").slideDown(700); }, 1000);          
            $( "#here" ).load(window.location.href + " #here" );
        }
        
        jQuery('.file').change(function(){
            console.log("file>>>>>>>>>>>>>>>>>>>");
            var fileInput = component.find("fileDoc").getElement();
            console.log("fileInput.files[0].name>>>>>>>>>>>>>>>>>>>>",fileInput.files[0].name);
            component.set("v.fileName", fileInput.files[0].name);
            
            
        });
        jQuery('.file1').change(function(){
            
            var fileInput1 = component.find("fileDoc1").getElement();
            console.log("fileInput1.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput1.files[0].name);
            //var file = component.get("v.fileName1");
            component.set("v.fileName1", fileInput1.files[0].name); 
            console.log("file1>>>>>>>>>>>>>>>>>>>"+component.get("v.fileName1"));
            
        });
        jQuery('.file2').change(function(){
            console.log("file2>>>>>>>>>>>>>>>>>>>");
            var fileInput2 = component.find("fileDoc2").getElement();
            console.log("fileInput2.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput2.files[0].name);
            component.set("v.fileName2", fileInput2.files[0].name); 
            
        });
        jQuery('.file3').change(function(){
            console.log("file3>>>>>>>>>>>>>>>>>>>");
            var fileInput3 = component.find("fileDoc3").getElement();
            console.log("fileInput3.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput3.files[0].name);
            component.set("v.fileName3", fileInput3.files[0].name); 
            
        });
         jQuery('.file4').change(function(){
            console.log("file4>>>>>>>>>>>>>>>>>>>");
            var fileInput4 = component.find("fileDoc4").getElement();
            console.log("fileInput4.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput4.files[0].name);
            component.set("v.fileName4", fileInput4.files[0].name); 
            
        });
         jQuery('.file5').change(function(){
            console.log("file5>>>>>>>>>>>>>>>>>>>");
            var fileInput5 = component.find("fileDoc5").getElement();
            console.log("fileInput5.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput5.files[0].name);
            component.set("v.fileName5", fileInput5.files[0].name); 
            
        });
         jQuery('.file6').change(function(){
            console.log("file6>>>>>>>>>>>>>>>>>>>");
            var fileInput6 = component.find("fileDoc6").getElement();
            console.log("fileInput6.files[0].name>>>>>>>>>>>>>>>>>>>>"+fileInput6.files[0].name);
            component.set("v.fileName6", fileInput6.files[0].name); 
            
        });
       // component.set("v.showSpinner", false);
    },
    
    saveRecord : function(component, event, helper) {
        
        helper.ValidateAndSaveAddressRecords(component, event);          
        
    },
    
    gotoHome : function (component, event, helper) {
        component.set("v.showSpinner", true);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/customerupdate", "isredirect" : true
        });
        urlEvent.fire();
        
    },
    
    onChange : function(component){
        var dynamicCmp = component.find("InputSelectState");
        component.set("v.controller.newAddress.State_AGN__c", dynamicCmp.get("v.value"));
    },
    onChangeLicenseNuber : function (component, event, helper) {
        const cmps = component.find("fieldShipTo");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){            
            cmps.forEach( function (cmp){                
                //storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c' && cmp.get("v.fieldName")==='State_License_Number_AGN__c'){
                    var LicenseVal = component.get("v.controller.newAddress.State_License_Number_AGN__c");
                    if(!$A.util.isEmpty(LicenseVal)){
                        //alert('@@@@@[Licence Val]@@@'+component.get("v.controller.newAddress.State_License_Number_AGN__c")); 
                        component.set("v.isLicenseDocument", true);
                        component.set("v.LicenseValue", LicenseVal);
                    }else{
                        component.set("v.isLicenseDocument", false);
                    }
                    
                }else if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c' && cmp.get("v.fieldName")==='State_AGN__c'){
                    var ProvinceVal = component.get("v.controller.newAddress.State_AGN__c");
    				var LicenseVal = component.get("v.controller.newAddress.State_License_Number_AGN__c");
                    var cGroup = component.get("v.customerGroup");
    				 //alert('@@@@@[Licence Val]@@@'+ProvinceVal); 
    					if(!$A.util.isEmpty(ProvinceVal) && !$A.util.isEmpty(LicenseVal)){
    						if(ProvinceVal.includes('BC') && (cGroup == 'DN' || cGroup=='OM')){                       
                        		component.set("v.isLicenseDocumentForBC", true);
    							component.set("v.isLicenseDocumentAB", false);
							}else if(ProvinceVal.includes('AB') && (cGroup == 'DN' || cGroup=='OM')){
    							component.set("v.isLicenseDocumentAB", true);
    							component.set("v.isLicenseDocumentForBC", false);
							}else if(!ProvinceVal.includes('AB') && !ProvinceVal.includes('BC')) {
                                component.set("v.isLicenseDocumentForBC", false);
                        		component.set("v.isLicenseDocumentAB", false);
                            } 
    						
                    }else{
                        component.set("v.isLicenseDocumentForBC", false);
                        component.set("v.isLicenseDocumentAB", false);
						
                    }
                }
            });
            //end forEach
        }
    },
    
    closePopup : function(component, event, helper){
        component.set("v.isOpen", false);
        component.set("v.selectedActiveAddress" , "");
    },
    assignAddress : function(component, event, helper){
        component.set("v.showError" , false);
        var selected = event.getSource().get("v.text");
        console.log("selected address>>>>>>>>>>>>>"+selected);
        component.set("v.selectedActiveAddress" , selected);
    },
    submitRequest : function(component, event, helper){
        var activeAddressFound = component.get("v.activeAddressFound");
        var selected = component.get("v.selectedActiveAddress");
        console.log("selected>>>>>>>>>>>>>>>>>>>>>"+activeAddressFound+">>>>"+selected);
        if(activeAddressFound && !$A.util.isEmpty(selected)){
            if(selected != $A.get("$Label.c.AGN_OAM_CONTINUE_WITH_CURRENT_ADDRESS")){
                var address = selected.split(',');
                var first = address[0];
                var second = address[1];
                var firstSplit = first.split(' ');
                var addressType = component.get("v.addressType");
                var suite = "";
                var street = "";
                if(addressType === 'Address'){
                    suite = firstSplit[0];
                    for(i = 1 ; i<firstSplit.length ; i++){
                        street = street + firstSplit[i] + " ";
                    }
                    street = street.substring(0, street.length - 1);
                }else if(addressType === 'Street'){
                    street = first;
                } 
                var provinces = 'AB,BC,MB,NB,NL,NT,NS,NU,ON,PE,QC,SK,YT';
                second = second.trim();
                var spl = second.split(" ");
                var i = 0;
                var provincepos;
                var province = "";
                spl.forEach(function(cmp){
                    console.log(cmp);
                    if(provinces.includes(cmp) && 
                       i != 0 
                       && i != spl.length){
                        console.log("found at position "+i);
                        provincepos = i;
                        province = spl[provincepos];
                    }
                    i = i+1;
                });
                
                console.log("Province>>>>>>>>>>>"+spl[provincepos]);
                var city = "";
                for(i = 0 ; i<provincepos ; i++){
                    city = city + spl[i] + " ";
                }
                city = city.substring(0, city.length - 1);
                console.log("city>>>>>>>>>>>>>>>>"+city);
                var zip = "";
                for(i = provincepos + 1 ; i<spl.length ; i++){
                    zip = zip + spl[i] + " ";
                }
                zip = zip.substring(0, zip.length - 1);
                console.log("suite>>>>>>>>>>>>>>>>>>>>>>>>>>>",suite);
                console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>>>",street);
                console.log("city>>>>>>>>>>>>>>>>>>>>>>>>>>>",city);
                console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>>>",zip);
                console.log("province>>>>>>>>>>>>>>>>>>>>>>>>>>>",province);
                console.log("Button Id>>>>>>>>>>>>>>>>>>>>>"+component.get("v.selectedButtontype"));
                var account = "";
                var department = "";
                var license = "";
                var phone = "";
                var email = "";
                var items = [];
                if(component.get("v.selectedButtontype") === 'soldToBtn'){
                    items = component.find("fieldSoldTo");
                    component.set("v.isSoldToVerified",true);
                }else if(component.get("v.selectedButtontype") === 'shipToBtn'){
                    items = component.find("fieldShipTo");
                    //component.set("v.isSoldToVerified",true); CHANGE TO SHIPTO
                }else if(component.get("v.selectedButtontype") === 'billToBtn'){
                    items = component.find("fieldBillTo");
                    //component.set("v.isSoldToVerified",true); CHANGE TO SHIPTO
                }
                component.set("v.doValidate" , false);
                items.forEach(function(cmp){
                    console.log(cmp.get("v.fieldValue"));
                    var fieldName = cmp.get("v.fieldName");
                    if(fieldName === 'Suite_AGN__c' && addressType === 'Address'){
                        cmp.set("v.fieldValue" , suite);
                    }else if(fieldName === 'Address_Line_1_AGN__c'){
                        cmp.set("v.fieldValue" , street);
                    }else if(fieldName === 'City_AGN__c'){
                        cmp.set("v.fieldValue" , city);
                    }else if(fieldName === 'Zip_AGN__c'){
                        cmp.set("v.fieldValue" , zip);
                    }else if(component.get("v.selectedButtontype") != 'soldToBtn' &&  fieldName === 'State_AGN__c'){
                        cmp.set("v.fieldValue" , "CA-"+province);
                    }
                    
                });
                component.set("v.doValidate" , true);
                
            }
            
            component.set("v.selectedButtontype" , "");
            component.set("v.isOpen", false);           
            
        }else{
            component.set("v.showError" , true);
        }
    },
    verifyAddress : function(component, event, helper){
        console.log("inside verify address");
        var selectedIndex = event.target.id;
        var selectedButton = event.target.name;
        var items = [];
        if(selectedButton === 'soldToBtn'){
            items = component.find("fieldSoldTo");
        }else if(selectedButton === 'shipToBtn'){
            items = component.find("fieldShipTo");
        }else if(selectedButton === 'billToBtn'){
            items = component.find("fieldBillTo");
        } 
        console.log("SoldTo Address>>>>>>>>>>>",items);
        var suite = "";
        var street = "";
        var city = "";
        var zip = "";
        var province = "";
        items.forEach(function(cmp){
            console.log(cmp.get("v.fieldValue"));
            var fieldName = cmp.get("v.fieldName");
            if(fieldName === 'Suite_AGN__c'){
                suite = cmp.get("v.fieldValue");
            }else if(fieldName === 'Address_Line_1_AGN__c'){
                street = cmp.get("v.fieldValue");
            }else if(fieldName === 'City_AGN__c'){
                city = cmp.get("v.fieldValue");
            }else if(fieldName === 'Zip_AGN__c'){
                zip = cmp.get("v.fieldValue");
            }else if(fieldName === 'State_AGN__c'){
                 province = cmp.get("v.fieldValue");
            } 
        });
        component.set('v.objAddr.Suite_AGN__c', suite); 
        component.set('v.objAddr.Address_Line_1_AGN__c', street);
        component.set('v.objAddr.City_AGN__c', city);
        component.set('v.objAddr.Zip_AGN__c', zip);
        var selectedProvince = "";
        if(selectedButton === 'shipToBtn' || selectedButton === 'billToBtn'){
           selectedProvince = province;
        }else{
           selectedProvince =  component.get("v.selectedProvince");
        }
        
        component.set("v.selectedButtontype",selectedButton);
        helper.getLoqateAddress(component , selectedProvince);
    },
})