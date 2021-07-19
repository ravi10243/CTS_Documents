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
        
        // component.set("v.showSpinner", true);
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
            console.log('state1>>>>>'+actionResult.getState());
            if(actionResult.getState()==="SUCCESS"){  
                component.set("v.controller", actionResult.getReturnValue());            
                component.set("v.SAPcountryCode",component.get("v.controller.newRegistration.SAP_Country_Code_AGN__c"));            
                component.set("v.countryCode", component.get("v.controller.newRegistration.Country_Code_AGN__c")); 
                component.set("v.customerGroup", component.get("v.controller.newRegistration.Customer_Group_AGN__c"));
                component.set("v.customerType", component.get("v.controller.newRegistration.Customer_Category_AGN__c"));
                component.set("v.customerSubType", component.get("v.controller.newRegistration.Customer_Sub_Category_AGN__c"));
                
                component.set("v.PaymentMethod1",component.get("v.controller.paymentMethod.Id"));
                component.set("v.PaymentTerm1",component.get("v.controller.paymentTerm.Id"));
                
                component.set("v.objMixType", component.get("v.controller.newAddress")); 
                component.set("v.address", component.get("v.controller.newAddress"));                        
                
                //alert('cogh--->'+JSON.stringify(component.get("v.controller.config.Customer_Group_AGN__c"))); 
                helper.fetchCountrySettings(component, event);
                helper.fetchDependantFields(component, event);
                
                //var prescribingDrEmail = component.get("v.controller.newAddress.Doctors_Email_AGN__c");
                //if(!$A.util.isEmpty(prescribingDrEmail)){
                var arePrescribingDr = component.get("v.controller.newAddress.Are_You_The_Prescribing_Doctor_AGN__c");            
                if(!arePrescribingDr){
                    component.set("v.showPrescribingDr", false);
                    component.set("v.isPrescribingDr" , true);
                } 
                
                if(component.get("v.type") === soldTo || component.get("v.type") === billTo){
                    console.log('cal payment');                
                    helper.fetchPaymentSettingdetails(component, event); 
                } 
                
                /* console.log('PaymentMethod1>>>>'+component.get("v.PaymentMethod1"));
                var payM = component.get("v.PaymentMethod1");
                //if(component.get("v.PaymentMethod1") != null){
                    if((payM && $A.util.isEmpty(payM)) || $A.util.isEmpty(component.get("v.PaymentTerm1"))){
                        helper.getPaymentMethodValues(component, event, helper);
                        component.set("v.isShowPaymentdropdown", true);
                    }   
               // }  */ 
                
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
            //$( "#here" ).load(window.location.href + " #here" );
            //sforce.one.navigateToURL(url['', false]);
          
        } 
        
        jQuery('.file').change(function(){
            console.log("file>>>>>>>>>>>>>>>>>>>");
            var fileInput = component.find("fileDoc").getElement();
            console.log("fileInput.files[0].name>>>>>>>>>>>>>>>>>>>>",fileInput.files[0].name);
            component.set("v.fileName", fileInput.files[0].name);
            jQuery(".upload_file").show();
            
        });
        
    },
    
    saveRecord : function(component, event, helper) {
        component.set("v.showSpinner",true);
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
    handleshowPrescribingDrCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        console.log("Prescribiing Dr : on check>>>>>>>>>>>>>>"+ isChecked);
        if(isChecked){
            component.set("v.isPrescribingDr" , false);
            component.set("v.clearPrescribingDrValues" , true);
            component.set("v.clearPrescribingDrRequiredFields" , true);
        }else{            
            component.set("v.isPrescribingDr" , true);
            component.set("v.clearPrescribingDrValues" , false);
            component.set("v.clearPrescribingDrRequiredFields" , false);
            component.set("v.PrescribingDoctorsDependantFields" , component.get("v.PrescribingDoctorsDependantFields"));
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
    deleteAttachment : function(component, event, helper) {
        console.log('delete attachment');  
        jQuery(".upload_file").hide();
        component.find("fileDoc").getElement().value = '';
        component.set("v.fileName", component.find("fileDoc").getElement().value);        
        
    },
    submitRequest : function(component, event, helper){
        var activeAddressFound = component.get("v.activeAddressFound");
        var selected = component.get("v.selectedActiveAddress");
        console.log("selected>>>>>>>>>>>>>>>>>>>>>"+activeAddressFound+">>>>"+selected);
        if(activeAddressFound && !$A.util.isEmpty(selected)){
            if(selected != $A.get("$Label.c.AGN_OAM_CONTINUE_WITH_CURRENT_ADDRESS")){
                var country = component.get("v.SAPcountryCode");
                console.log("selected country code>>>>>>>>>>>>>"+country);
                var address = selected.split(',');
                var first = "";
                var second = "";
                var third = "";
                var fourth = "";
                var streetno = "";
                var street = "";
                var suburb = "";
                var state = "";
                var zip = "";
                var states = "";
                var cityZipString = "";
                var last = "";
                if(country === 'AU'){
                    states = 'NSW,QLD,SA,TAS,VIC,WA,ACT,NT';
                }else if(country === 'NZ'){
                    states = 'WHANGAREI,AUCKLAND,HAMILTON,WHAKATANE,GISBORNE,NAPIER,STRATFORD,PALMERSTON NORTH,WHANGANUI,WELLINGTON,RICHMOND,NELSON,BLENHEIM,GREYMOUTH,CHRISTCHURCH,DUNEDIN,INVERCARGILL'; 
                }
                var address = selected.split(',');
                if(address.length > 3){
                    last = address[address.length-1];
                    cityZipString = last;
                }else if(address.length == 3){
                    last = address[address.length-1];
                    cityZipString = last;
                }else if(address.length == 2){
                    last = address[address.length-1];
                    cityZipString = last;
                }
                cityZipString = cityZipString.trim();
                var spl = cityZipString.split(" ");
                var i = 0;
                var statepos;
                var isFound = false;
                spl.forEach(function(cmp){
                    var str = cmp.toUpperCase().trim();
                    console.log("str>>>>>>>>>>>>>>"+str);
                    if(states.includes(str) && i != spl.length){
                        console.log("found at position "+i);
                        statepos = i;
                        state = spl[statepos];
                        isFound = true;
                    }
                    i = i+1;
                });
                if(isFound){
                    if(country === 'AU'){
                        switch (state) {
                            case "ACT":
                                state = "AU-ACT";
                                break;
                            case "NT":
                                state = "AU-NT";
                                break;
                            case "NSW":
                                state = "AU-NSW";
                                break;
                            case "QLD":
                                state = "AU-QLD";
                                break;
                            case "SA":
                                state = "AU-SA";
                                break;
                            case "TAS":
                                state = "AU-TAS";
                                break;
                            case "VIC":
                                state = "AU-VIC";
                                break;
                            case "WA":
                                state = "AU-WA";
                        }
                    }else if(country === 'NZ'){
                        switch (state) {
                            case "WHANGAREI":
                                state = "NZ-NTL";
                                break;
                            case "AUCKLAND":
                                state = "NZ-AUK";
                                break;
                            case "HAMILTON":
                                state = "NZ-WKO";
                                break;
                            case "WHAKATANE":
                                state = "NZ-BOP";
                                break;
                            case "GISBORNE":
                                state = "NZ-GIS";
                                break;
                            case "NAPIER":
                                state = "NZ-HKB";
                                break;
                            case "STRATFORD":
                                state = "NZ-TKI";
                                break;
                            case "PALMERSTON NORTH":
                                state = "NZ-MWT";
                                break;
                            case "WHANGANUI":
                                state = "NZ-MWT";
                                break;
                            case "WELLINGTON":
                                state = "NZ-WGN";
                                break;
                            case "RICHMOND":
                                state = "NZ-TAS";
                                break;
                            case "NELSON":
                                state = "NZ-NSN";
                                break;
                            case "BLENHEIM":
                                state = "NZ-MBH";
                                break;
                            case "GREYMOUTH":
                                state = "NZ-WTC";
                                break;
                            case "CHRISTCHURCH":
                                state = "NZ-CAN";
                                break;
                            case "DUNEDIN":
                                state = "NZ-OTA";
                                break;
                            case "INVERCARGILL":
                                state = "NZ-STL";
                        }  
                    }
                    
                }else{
                    statepos = spl.length - 2;
                }
                console.log("statepos>>>>>>>>>>>>>>>>"+statepos);
                if(statepos == 0){ //The final string is like 'NSW 2000' - without suburb
                    for(i = statepos+1 ; i<spl.length ; i++){
                        zip = zip + spl[i] + " ";
                    }
                }else if(statepos > 0){//The final string is like 'SYDNEY NSW 2000' with suburb
                    for(i=0;i<statepos;i++){
                        suburb = suburb + spl[i] + " ";
                    }
                    for(i = statepos+1 ; i<spl.length ; i++){
                        zip = zip + spl[i] + " ";
                    }
                }
                if(address.length > 3){
                    if(statepos == 0){
                        for(i=address.length-2; i>=0; i--){
                            if(suburb === ""){
                                suburb = address[i];
                            }else if(street === ""){
                                street = address[i];
                            }else{
                                streetno = streetno + address[i] + " ";
                            }
                        }
                    }else if(statepos>0){
                        for(i=address.length-2; i>=0; i--){
                            if(street === ""){
                                street = address[i];
                            }else{
                                streetno = address[i] + streetno + " ";
                            }
                        }
                    }
                }else if(address.length == 3){
                    if(statepos == 0){
                        suburb = address[1];
                        var first = address[0];
                        var firstSplit = first.split(" ");
                        if(firstSplit.length > 1){
                            streetno = firstSplit[0];
                            for(i=1;i<firstSplit.length;i++){
                                street = street + firstSplit[i] + " ";
                            }
                        }
                    }else if(statepos>0){
                        for(i=address.length-2; i>=0; i--){
                            if(street === ""){
                                street = address[i];
                            }else{
                                streetno = address[i] + streetno + " ";
                            }
                        }
                    }
                }else if(address.length == 2){
                    if(statepos == 0){
                        var first = address[0];
                        var firstSplit = first.split(" ");
                        if(firstSplit.length > 1){
                            streetno = firstSplit[0];
                            for(i=1;i<firstSplit.length;i++){
                                street = street + firstSplit[i] + " ";
                            }
                        }
                    }else if(statepos>0){
                        var first = address[0];
                        var firstSplit = first.split(" ");
                        streetno = firstSplit[0];
                        if(firstSplit.length > 1){
                            
                            for(i=1;i<firstSplit.length;i++){
                                street = street + firstSplit[i] + " ";
                            }
                        } 
                    }
                } 
                
                
                console.log("street number>>>>>>>>>>>>>>>>>>>>>>>>>>>",streetno);
                console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>>>",street);
                console.log("suburb>>>>>>>>>>>>>>>>>>>>>>>>>>>",suburb);
                console.log("state>>>>>>>>>>>>>>>>>>>>>>>>>>>",state);
                console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>>>",zip);
                
                var account = "";
                var department = "";
                var license = "";
                var phone = "";
                var email = "";
                
                var items = [];
                if(component.get("v.selectedButtontype") === 'soldToBtn'){
                    items = component.find("fieldSoldTo");
                }else if(component.get("v.selectedButtontype") === 'shipToBtn'){
                    items = component.find("fieldShipTo");
                }else if(component.get("v.selectedButtontype") === 'billToBtn'){
                    items = component.find("fieldBillTo");
                }
                
                component.set("v.doValidate" , false);
                
                items.forEach(function(cmp){
                    console.log(cmp.get("v.fieldValue"));
                    var fieldName = cmp.get("v.fieldName");
                    if(fieldName === 'Address_Line_2_AGN__c'){
                        cmp.set("v.fieldValue" , streetno);
                    }else if(fieldName === 'Address_Line_1_AGN__c'){
                        cmp.set("v.fieldValue" , street);
                    }else if(fieldName === 'City_AGN__c'){
                        cmp.set("v.fieldValue" , suburb);
                    }else if(fieldName === 'Zip_AGN__c'){
                        cmp.set("v.fieldValue" , zip.trim());
                    }else if(fieldName === 'State_AGN__c'){
                        if(country === 'NZ'){
                            state = cmp.get("v.fieldValue");
                        }
                        cmp.set("v.fieldValue" , state);
                    }else if(fieldName === 'Is_Verified_Address__c'){
                        cmp.set("v.fieldValue" , true);
                    }else if(fieldName === 'Company_Name_AGN__c'){
                        account = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Department_Name_AGN__c'){
                        department = cmp.get("v.fieldValue");
                    }else if(fieldName === 'State_License_Number_AGN__c'){
                        license = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Phone_AGN__c'){
                        phone = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Email_AGN__c'){
                        email = cmp.get("v.fieldValue");
                    }
                });
                component.set("v.doValidate" , true);
                
            }
            component.set("v.selectedButtontype" , "");
            component.set("v.isOpen", false);   
        }
        else{
            component.set("v.showError" , true);
        }
    },
    /*verifyAddress : function(component, event, helper){
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
    },*/
    verifyAddress : function(component, event, helper){
        console.log("inside verify address");
        //const items = component.find("fieldShipTo");
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
        var streetno = "";
        var street = "";
        var suburb = "";
        var state = "";
        var zip = "";
        items.forEach(function(cmp){
            console.log(cmp.get("v.fieldValue"));
            var fieldName = cmp.get("v.fieldName");
            if(fieldName === 'Address_Line_2_AGN__c'){
                streetno = cmp.get("v.fieldValue");
            }else if(fieldName === 'Address_Line_1_AGN__c'){
                street = cmp.get("v.fieldValue");
            }else if(fieldName === 'City_AGN__c'){
                suburb = cmp.get("v.fieldValue");
            }else if(fieldName === 'State_AGN__c'){
                state = cmp.get("v.fieldValue");
            }else if(fieldName === 'Zip_AGN__c'){
                zip = cmp.get("v.fieldValue");
            }
        });
        
        component.set('v.objAddr.Address_Line_2_AGN__c', streetno); 
        component.set('v.objAddr.Address_Line_1_AGN__c', street);
        component.set('v.objAddr.City_AGN__c', suburb);
        component.set('v.objAddr.State_AGN__c', state);
        component.set('v.objAddr.Zip_AGN__c', zip);
        console.log("Calling Loqate Validate Method>>>>>>>>>>>>>>",component.get("v.SAPcountryCode"));
        component.set("v.selectedButtontype", selectedButton);//event.getSource().getLocalId());
        
        helper.getLoqateAddress(component, component.get("v.SAPcountryCode"));
    }
})