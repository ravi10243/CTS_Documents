({
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
        
        
    },
    
    doInit: function(component, event, helper){ 
        
        
        jQuery("document").ready(function(){
            console.log('loaded');
            console.log(jQuery(window).width()<500);
            if(jQuery(window).width() < 500){
                console.log("mobile view");
                //jQuery('#Registered_Address').addClass('sold');
                console.log(jquery('.regi_add_1').find('#Registered_Address'));
            }else{
                jQuery('#Registered_Address,#Delivery_Address').removeClass('sold');
            }
        });
        component.set("v.sectionHeaderMap", {});
        
        helper.fetchCountrySettings(component, event);          
        
        helper.fetchAddressDetails(component, event);
        
        helper.getGCSPSettingsDetails(component, event);
        
        var country = component.get("v.countryCode");
        console.log('country>>>>>>>>>>>>>>>>>'+country);
        if(country === 'CA'){
            var usLicenseLabel = $A.get("$Label.c.AGN_OAM_US_License_HCP");
            component.set("v.usLicenseLabel" , usLicenseLabel);
            
            component.set("v.buyingGroupLabel", $A.get("$Label.c.AGN_OAM_Are_you_apart_Buying_Group"));
            helper.fetchDependantFields(component, country);
        }
        
    },
    
    resetBlock : function(component,event, helper){    
        
        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
        notifyRegStepChange.setParams({"Operation": 'CANCEL',
                                       "StepNo": '2'}
                                     );
        notifyRegStepChange.fire();
        
        //avijit
        /*jQuery('.add_det .infr_det').slideUp(500);
        jQuery('.no_det.active').css("border", "2px solid #a3d233");
        jQuery( ".add_det .edit_btn" ).show();
        jQuery( ".upload_doc .edit_btn" ).show();*/
    },
    
    
    
    validateAndUpsert : function(component,event, helper){
        
        helper.validateAndUpsert(component, event); 
        
        //helper.fireEvent(component, event);        
    },
    
    sectionValidateAndUpdate : function(component,event, helper){
        
        helper.sectionValidateAndUpdate(component, event);
    },
    show_hide_SoldTo_Address: function(component, event, helper){
        /******************To Set Flat View Address********************/
        var suite = "";
        var street = "";
        var city = "";
        var zip = "";
        var account = "";
        var department = "";
        var phone = "";
        var email = "";
        const items = component.find("fieldSoldTo");
        if(!$A.util.isEmpty(items)){
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
                        }else if(fieldName === 'Company_Name_AGN__c'){
                            account = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Department_Name_AGN__c'){
                            department = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Phone_AGN__c'){
                            phone = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Email_AGN__c'){
                            email = cmp.get("v.fieldValue");
                        }
                    }); 
                    var address = account +", ";
                    if(!$A.util.isEmpty(department)){
                        address = address + department+", ";
                    }
                    if(!$A.util.isEmpty(suite)){
                        address = address + suite+", ";
                    }
                    address = address+street+", "+city+", "+zip+", "+phone+", "+email;
                    const soldToFlatView = component.find("soldToFlatView");
                    console.log("soldToFlatView>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+soldToFlatView.get("v.outPut"));
                    soldToFlatView.set("v.outPut" , address);
        }
                    
        var flatView = component.find("Registered_add_Show_FlatView");
        var registeredAddShow = component.find("Registered_add_Show");        
        $A.util.toggleClass(registeredAddShow, "Registered_add");        
        $A.util.toggleClass(flatView, "Registered_add");
        
        //	Modal functionality for editing the address
        //jQuery("#modalBackground").addClass("slds-backdrop slds-backdrop_open");
        //jQuery("#Registered_Address").css({"background-color":"white","z-index":"90001","box-shadow":"0 0 5px #fff","padding":"15px 0 15px 15px"});
        
    },
    
    show_hide_Ship_Bill_To_Address: function(component, event, helper){
        var flatViewId;
        var fullViewId;
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        console.log(index);
        component.set("v.currentShipToIndex" , index);
        
        var addressType = ctarget.getAttribute("data-address-type");
        console.log('addressType => '+ addressType);
        
        var items = [];
        var address;
        var selectedIndex = index;
        var suite = "";
        var street = "";
        var city = "";
        var zip = "";
        var account = "";
        var department = "";
        var phone = "";
        var province = "";
        var email = "";
        var license = "";
        if(addressType === 'SHIPTO'){
            flatViewId = document.getElementById('shipTo_addr_Show_Small_View-'+index);
            fullViewId =  document.getElementById('shipTo_addr_Show_Full_View-'+index);
            items = component.find("fieldShipTo");        
        }
        else if(addressType === 'BILLTO'){
            flatViewId = document.getElementById('billTo_addr_Show_Small_View-'+index);
            fullViewId =  document.getElementById('billTo_addr_Show_Full_View-'+index);
            items = component.find("fieldBillTo"); 
        }
        items.forEach(function(cmp){
                        var index = cmp.get("v.index");
                        if(index == selectedIndex){
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
                            }else if(fieldName === 'Is_Verified_Address__c'){
                                suite = cmp.get("v.fieldValue");
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
                        }
                    });
                    address = account +", ";
                    if(!$A.util.isEmpty(license)){
                        address = address + license +", ";
                    }
                    if(!$A.util.isEmpty(department)){
                        address = address + department +", ";
                    }
                    if(!$A.util.isEmpty(suite)){
                        address = address + suite+", ";
                    }
        address = address + street + ", " + city + ", " + zip + ", " + phone + ", " + email;
        if(addressType === 'SHIPTO'){
            var shipToFlatView = [];
            shipToFlatView = component.find("shipToFlatView");
            console.log("shipToFlatView>>>>>>>>>>>>>>>>>>>>>>>>",shipToFlatView);
            
            if($A.util.isArray(shipToFlatView)){
                shipToFlatView.forEach(function(cmp){
                      console.log("cmp>>>>>>>>>>>>>>>>>",cmp);
                      var index = cmp.get("v.index");
                      console.log("index>>>>>>>>>>>>>"+index);
                      console.log("selectedIndex>>>>>>>>>>>>>"+selectedIndex);
                      if(index == selectedIndex){
                           cmp.set("v.outPut" , address);
                      }
                });
           }
              
        }else if(addressType === 'BILLTO'){
            var billToFlatView = [];
            billToFlatView = component.find("billToFlatView");
            console.log("billToFlatView>>>>>>>>>>>>>>>>>>>>>>>>"+billToFlatView);
            if($A.util.isArray(billToFlatView)){
               billToFlatView.forEach(function(cmp){
                  var index = cmp.get("v.index");
                  if(index == selectedIndex){
                       cmp.set("v.outPut" , address);
                  }
               }); 
            }
              
        }
        $A.util.toggleClass(fullViewId, "Registered_add");        
        $A.util.toggleClass(flatViewId, "Registered_add"); 
    },
    
    updateSoldToForSameShiptoBillTo : function(component, event){
        
        if(component.get("v.shipToSameAsSoldTo") == false){
            component.set("v.objSoldTo.Ship_To_AGN__c", false);
            //console.log('soldTo_ShipTo--->'+JSON.stringify(component.get('v.objSoldTo').Ship_To_AGN__c));
        }else{
            component.set("v.objSoldTo.Ship_To_AGN__c", true);
        }
        if(component.get("v.billToSameAsSoldTo") == false){
            component.set("v.objSoldTo.Bill_To_AGN__c", false);
            // console.log('soldTo_ShipTo--->'+JSON.stringify(component.get('v.objBillTo').Sold_To_AGN__c));
        }else{
            component.set("v.objSoldTo.Bill_To_AGN__c", true);
        }
        
        
        /*  var shipToToggleComp = component.find("chkboxSameAsSoldToforShipTo");
        var billToToggleComp = component.find("chkboxSameAsSoldToforBillTo");  

        shipToSameAsSoldTo = shipToToggleComp.get("v.value");
        billToSameAsSoldTo = billToToggleComp.get("v.value");
        
        componet.set('v.objSoldTo.Ship_To_AGN__c', shipToSameAsSoldTo);
        componet.set('v.objBillTo.Sold_To_AGN__c',billToSameAsSoldTo);  
       */
    },
    
    addAnotherShipTo : function(component, event, helper){
        console.log("inside addAnotherShipTo",event.currentTarget.id);
        var selectedButton = event.currentTarget.id;
        console.log("selected button>>>>>>>>>>>>>>>>>"+selectedButton);
        if(selectedButton == 'first'){
            component.set("v.currentShipToIndex" , 0);
        }else if(selectedButton == 'second'){
            component.set("v.currentShipToIndex" , 1);
        }
        var objNewShipTo = component.get("v.obj_addNewShipTo");
        var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
        objNewShipTo.push(newRecord);
        component.set("v.obj_addNewShipTo", objNewShipTo);
        
        /*var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        console.log("index>>>>>>>>>>>>>>>>>"+index);*/
        
        
        
        /* try{
            var checkCmp = component.find("chkboxSameAsSoldToforShipTo");
            var isSameAsSoldTo = checkCmp.get("v.value"); //true/false
            var objNewShipTo = component.get("v.obj_addNewShipTo"); //assigning 
            
            if(!isSameAsSoldTo){
                var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
                objNewShipTo.push(newRecord);
            }
            else{
                var newRecord = {} ;
                var data = component.get("v.objSoldTo"); //SoldTo data
                var mapFieldsConfig = component.get("v.sectionHeaderMapShipTo");
                
                //console.log('mapFieldsConfig-->'+ JSON.stringify(mapFieldsConfig[0].value));
                
                newRecord['sobjectType'] = 'Allergan_Customer_Address_AGN__c';
                
                for(var i in mapFieldsConfig[0].value){
                    newRecord[mapFieldsConfig[0].value[i].Field_Name_AGN__c] = data[mapFieldsConfig[0].value[i].Field_Name_AGN__c];
                }
                
                newRecord['sameassoldto'] = true;
                
                component.get("v.objSoldTo").Ship_To_AGN__c = true;
                objNewShipTo.push(newRecord);
            }            
            component.set("v.obj_addNewShipTo", objNewShipTo);
        } catch(err){
            console.error(err.message);
        }*/
        
        console.log('obj_addNewShipTo-->'+JSON.stringify(component.get("v.obj_addNewShipTo")));
        var buttonSave = component.find("buttonSave");  
        $A.util.addClass(buttonSave, "soldto");
        //	adding modal popup
        //jQuery("#Delivery_Address_new").css({"background-color":"white","z-index":"90001","box-shadow":"0 0 5px #fff","padding":"15px 0 15px 15px"});
        //jQuery("#modalBackground_NewShipTo").addClass("slds-backdrop slds-backdrop_open");
        
    },
    addAnotherBillTo : function(component, event, helper){
        //	adding modal popup
        //jQuery("#Delivery_Address_BillTo").css({"background-color":"white","z-index":"90001","box-shadow":"0 0 5px #fff","padding":"15px 0 15px 15px"});
        //jQuery("#modalBackground_NewBillTo").addClass("slds-backdrop slds-backdrop_open");
        
        try{
            var objNewBillTo = component.get("v.obj_addNewBillTo"); 
            var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
            objNewBillTo.push(newRecord);
            component.set("v.obj_addNewBillTo", objNewBillTo);
        }catch(err){
            console.error(err.message);
        }
        /* try{
            var checkCmp = component.find("chkboxSameAsSoldToforBillTo");
            var isSameAsSoldTo = checkCmp.get("v.value"); //true/false
            var objNewBillTo = component.get("v.obj_addNewBillTo"); //assigning 
            
            if(!isSameAsSoldTo){
                var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
                objNewBillTo.push(newRecord);
            }
            else{
                var newRecord = {} ;
                var data = component.get("v.objSoldTo"); //SoldTo data
                var mapFieldsConfig = component.get("v.sectionHeaderMapBillTo");
                
                //console.log('mapFieldsConfig-->'+ JSON.stringify(mapFieldsConfig[0].value));
                
                newRecord['sobjectType'] = 'Allergan_Customer_Address_AGN__c';
                
                for(var i in mapFieldsConfig[0].value){
                    newRecord[mapFieldsConfig[0].value[i].Field_Name_AGN__c] = data[mapFieldsConfig[0].value[i].Field_Name_AGN__c];
                }
                
                newRecord['sameassoldto'] = true;
                
                component.get("v.objSoldTo").Bill_To_AGN__c = true;
                objNewBillTo.push(newRecord);
            }            
            component.set("v.obj_addNewBillTo", objNewBillTo);
        } catch(err){
            console.log(err.message);
        } */
        
        console.log('obj_addNewBillTo-->'+JSON.stringify(component.get("v.obj_addNewBillTo")));
    },
    cancelModal : function(component, event, helper){ 
        jQuery("#Registered_Address,#Delivery_Address_BillTo,#Delivery_Address_new").removeAttr('style');
        jQuery("#modalBackground,#modalBackground_NewShipTo,#modalBackground_NewBillTo").removeClass("slds-backdrop slds-backdrop_open");
        var flatView = component.find("Registered_add_Show_FlatView");
        var registeredAddShow = component.find("Registered_add_Show");        
        $A.util.toggleClass(registeredAddShow, "Registered_add");        
        $A.util.toggleClass(flatView, "Registered_add");
    },
    removeNewShip_Bill_To : function(component, event, helper){     
        //	removing modal popup
        //jQuery("#Registered_Address,#Delivery_Address_BillTo,#Delivery_Address_new").removeAttr('style');
        jQuery("#modalBackground,#modalBackground_NewShipTo,#modalBackground_NewBillTo").removeClass("slds-backdrop slds-backdrop_open");
        
        var objAddress;
        var v_objAddress;
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value; //ctarget.getAttribute("data-selected-Index");
        console.log(index);
        
        var addressType = ctarget.getAttribute("data-address-type");
        console.log('addressType => '+ addressType);
        
        if(addressType === 'SHIPTO'){
            objAddress = component.get("v.obj_addNewShipTo");
            v_objAddress = 'v.obj_addNewShipTo';
        }
        else if(addressType === 'BILLTO'){
            objAddress = component.get("v.obj_addNewBillTo");
            v_objAddress = 'v.obj_addNewBillTo';
        }
        
        objAddress.splice(index, 1); //removing array of index position
        console.log('Removed data of index ' + index);
        component.set(v_objAddress, objAddress);
        
    },
    
    deleteExistingShip_Bill_To : function(component, event, helper){
        
        var result = confirm("Want to delete?");
        if (result) {           
            helper.deleteExistingShip_Bill_To(component, event);
        }
    },
    
    select_Addr : function(component, event, helper){
        component.set("v.isOpen", true);
    },
    
    closePopUp: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    submitPopUp: function(component, event, helper) {
        
        
        component.set("v.isOpen", false);
    },
    onCheck : function(component, event, helper) {
        
        var checkCmp = component.find("chkbox");
        
        console.log('abdul : '+checkCmp.get("v.value"));
        // console.log("value : " + checkCmp.get("v.text"))
        console.log("value : " + JSON.stringify(checkCmp.get("v.text").Account_Type_AGN__c)); 
        // component.set("v.selectedval",JSON.stringify(checkCmp.get("v.text").Account_Type_AGN__c));
        
        var jsonString = JSON.parse(JSON.stringify(checkCmp.get("v.text")));        
        //console.log('XXXXX : '+jsonString.Id);
        var companyName=jsonString.Company_Name_AGN__c  
        var deptName= jsonString.Department_Name_AGN__c
        var address=jsonString.Address_Line_1_AGN__c
        var city= jsonString.City_AGN__c
        var zip= jsonString.Zip_AGN__c
        var phone=jsonString.Phone_AGN__c
        var email=jsonString.Email_AGN__c
        
        var concatString=companyName+','+deptName+','+address+','+city+','+zip+','+phone+','+email;
        component.set("v.selectedval",concatString);
        component.set("v.isOpenSelectAddres", true);
    },
    new_address_from_popup: function(component, event, helper){
        
        component.set("v.NewAddresPopup", true);
        component.set("v.isOpen", false);            
    },
     handleCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        component.set("v.isUSLicensedHCP" , isChecked);
        console.log("on check>>>>>>>>>>>>>>"+ component.get("v.isUSLicensedHCP"));
        if(!isChecked){
            component.set("v.clearUsLicense" ,  true);
            component.set("v.clearUSLicenseRequiredFields" ,  true);
            
        }else{
            console.log("USLicenseDependantFields>>>>>>>>>>>>>>>>>>>>",component.get("v.USLicenseDependantFields"));
            component.set("v.USLicenseDependantFields" , component.get("v.USLicenseDependantFields"));
            component.set("v.clearUsLicense" ,  false);
            component.set("v.clearUSLicenseRequiredFields" ,  false);
        }
        
    },
  
    /* for Buying Group -- Start */
    handleBGCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        component.set("v.isBuyingGroup" , isChecked);
        console.log("on check Buying Group>>>>>>>>>>>>>>"+ component.get("v.isBuyingGroup"));
        if(!isChecked){
            component.set("v.clearBuyingGroup" ,  true);
            component.set("v.clearBuyingGroupRequiredFields" ,  true);
            
        }else{
            console.log("BuyingGroupDependantFields>>>>>>>>>>>>>>>>>>>>"+component.get("v.BuyingGroupDependantFields"));
            component.set("v.BuyingGroupDependantFields" , component.get("v.BuyingGroupDependantFields"));
            component.set("v.clearBuyingGroup" ,  false);
            component.set("v.clearBuyingGroupRequiredFields" ,  false);
        }
        
    },
    
    /* for Buying Group -- End */
    
    verifyAddress : function(component, event, helper){
        console.log("inside verify address");
        const items = component.find("fieldSoldTo");
        console.log("SoldTo Address>>>>>>>>>>>",items);
        var suite = "";
        var street = "";
        var city = "";
        var zip = "";
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
            }
        });
        /*component.set('v.objSoldTo.Suite_AGN__c', suite); 
        component.set('v.objSoldTo.Address_Line_1_AGN__c', street);
        component.set('v.objSoldTo.City_AGN__c', city);
        component.set('v.objSoldTo.Zip_AGN__c', zip);*/
        component.set('v.objAddr.Suite_AGN__c', suite); 
        component.set('v.objAddr.Address_Line_1_AGN__c', street);
        component.set('v.objAddr.City_AGN__c', city);
        component.set('v.objAddr.Zip_AGN__c', zip);
        component.set("v.selectedButtontype",event.getSource().getLocalId());
        helper.getLoqateAddress(component , component.get("v.selectedProvince"));
    },
    closePopup : function(component, event, helper){
        component.set("v.isOpen", false);
        component.set("v.selectedActiveAddress" , "");
    },
    assignAddress : function(component, event, helper){
        component.set("v.showError" , false);
        var selected = event.getSource().get("v.text");
        component.set("v.selectedActiveAddress" , selected);
    },
    submitRequest : function(component, event, helper){
        var activeAddressFound = component.get("v.activeAddressFound");
        var selected = component.get("v.selectedActiveAddress");
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
                var account = "";
                var department = "";
                var license = "";
                var phone = "";
                var email = "";
                if(component.get("v.selectedButtontype") === 'soldToBtn'){
                    const items = component.find("fieldSoldTo");
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
                        }else if(fieldName === 'Company_Name_AGN__c'){
                            account = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Department_Name_AGN__c'){
                            department = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Phone_AGN__c'){
                            phone = cmp.get("v.fieldValue");
                        }else if(fieldName === 'Email_AGN__c'){
                            email = cmp.get("v.fieldValue");
                        }
                    });
                    component.set("v.doValidate" , true);
                    component.set("v.isSoldToVerified",true);
                    
                    /****************************SET FLAT VIEW ADDRESS************************/
                    var address = account + ", ";
                    if(!$A.util.isEmpty(department)){
                        address = address + department + ", ";
                    }
                    if(!$A.util.isEmpty(suite)){
                        address = address + suite +", ";
                    }
                    address = address + street +", " + city + ", " + zip + ", " + phone +", " + email;
                    const soldToFlatView = component.find("soldToFlatView");
                    console.log("soldToFlatView>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+soldToFlatView.get("v.outPut"));
                    soldToFlatView.set("v.outPut" , address);
                    
                }else if(component.get("v.selectedButtontype") === 'shipToEditBtn' || 
                         component.get("v.selectedButtontype") === 'billToEditBtn'){
                    var items = [];
                    var selectedIndex = component.get("v.selectedIndex");
                    if(component.get("v.selectedButtontype") === 'shipToEditBtn'){
                        items = component.find("fieldShipTo");
                        var sTo = component.get("v.objShipTo");
                        sTo[selectedIndex].Is_Verified_Address__c = true;
                        component.set("v.objShipTo",sTo);
                    }else if(component.get("v.selectedButtontype") === 'billToEditBtn'){
                        items = component.find("fieldBillTo");
                        var bTo = component.get("v.objBillTo");
                        bTo[selectedIndex].Is_Verified_Address__c = true;
                        component.set("v.objBillTo",bTo);
                    } 
                    component.set("v.doValidate" , false);
                    
                    
                    items.forEach(function(cmp){
                        var index = cmp.get("v.index");
                        if(index == selectedIndex){
                            console.log(cmp.get("v.fieldValue"));
                            var fieldName = cmp.get("v.fieldName");
                            if(fieldName === 'Suite_AGN__c'){
                                cmp.set("v.fieldValue" , suite);
                            }else if(fieldName === 'Address_Line_1_AGN__c'){
                                cmp.set("v.fieldValue" , street);
                            }else if(fieldName === 'City_AGN__c'){
                                cmp.set("v.fieldValue" , city);
                            }else if(fieldName === 'Zip_AGN__c'){
                                cmp.set("v.fieldValue" , zip);
                            }else if(fieldName === 'State_AGN__c'){
                                cmp.set("v.fieldValue" , "CA-"+province);
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
                            
                        }
                    });
                    component.set("v.doValidate" , true);
                    
                    /****************************SET FLAT VIEW ADDRESS************************/
                    var address = account + ", ";
                    if(!$A.util.isEmpty(license)){
                        address = address + license + ", ";
                    }
                    if(!$A.util.isEmpty(department)){
                        address = address + department +", ";
                    }
                    if(!$A.util.isEmpty(suite)){
                        address = address + suite +", ";
                    }
                    address = address+ street+", "+city+", "+zip +", "+phone+", "+email;
                    console.log("selectedIndex>>>>>>>>>>>>>"+selectedIndex);
                    if(component.get("v.selectedButtontype") === 'shipToEditBtn'){
                        const shipToFlatView = component.find("shipToFlatView");
                        console.log("shipToFlatView>>>>>>>>>>>>>>>>>>>>>>>>"+shipToFlatView);
                        shipToFlatView.forEach(function(cmp){
                            var index = cmp.get("v.index");
                            console.log("index>>>>>>>>>>>>>>>>>>>>"+index);
                            console.log("selectedIndex>>>>>>>>>>>>>>>>>>>>"+selectedIndex);
                            if(index == selectedIndex){
                               cmp.set("v.outPut" , address);
                            }
                        });
                    }else if(component.get("v.selectedButtontype") === 'billToEditBtn'){
                        const billToFlatView = component.find("billToFlatView");
                        console.log("billToFlatView>>>>>>>>>>>>>>>>>>>>>>>>"+billToFlatView);
                        billToFlatView.forEach(function(cmp){
                            var index = cmp.get("v.index");
                            console.log("index>>>>>>>>>>>>>>>>>>>>"+index);
                            console.log("selectedIndex>>>>>>>>>>>>>>>>>>>>"+selectedIndex);
                            if(index == selectedIndex){
                               cmp.set("v.outPut" , address);
                            }
                        });
                    }
                    
                    
                }else if(component.get("v.selectedButtontype") === 'shipToNewBtn' 
                         || component.get("v.selectedButtontype") === 'billToNewBtn'){
                    var items = [];
                    var selectedIndex = component.get("v.selectedIndex");
                    var shipLen = component.get("v.addressLength");
                    if(component.get("v.selectedButtontype") === 'shipToNewBtn'){
                        items = component.find("newShipTo");
                        if(shipLen == 1){
                            var sTo = component.get("v.obj_addNewShipTo");
                            sTo[0].Is_Verified_Address__c = true;
                            component.set("v.obj_addNewShipTo",sTo);
                        }else if(shipLen > 1){
                            var sTo = component.get("v.obj_addNewShipTo");
                            sTo[selectedIndex].Is_Verified_Address__c = true;
                            component.set("v.obj_addNewShipTo",sTo);
                        }
                    }else if(component.get("v.selectedButtontype") === 'billToNewBtn'){
                        items = component.find("newBillTo");
                        if(shipLen == 1){
                            var sTo = component.get("v.obj_addNewBillTo");
                            sTo[0].Is_Verified_Address__c = true;
                            component.set("v.obj_addNewBillTo",sTo);
                        }else if(shipLen > 1){
                            var sTo = component.get("v.obj_addNewBillTo");
                            sTo[selectedIndex].Is_Verified_Address__c = true;
                            component.set("v.obj_addNewBillTo",sTo);
                        }
                    } 
                    
                    component.set("v.doValidate" , false);
                    
                    
                    items.forEach(function(cmp){
                        var index = cmp.get("v.index");
                        if(shipLen == 1 || (shipLen > 1 && index == selectedIndex)){
                            var fieldName = cmp.get("v.fieldName");
                            if(fieldName === 'Suite_AGN__c'){
                                cmp.set("v.fieldValue" , suite);
                            }else if(fieldName === 'Address_Line_1_AGN__c'){
                                cmp.set("v.fieldValue" , street);
                            }else if(fieldName === 'City_AGN__c'){
                                cmp.set("v.fieldValue" , city);
                            }else if(fieldName === 'Zip_AGN__c'){
                                cmp.set("v.fieldValue" , zip);
                            }else if(fieldName === 'State_AGN__c'){
                                cmp.set("v.fieldValue" , "CA-"+province);
                            }else if(fieldName === 'Is_Verified_Address__c'){
                                cmp.set("v.fieldValue" , true);
                            }  
                        }
                    });
                    component.set("v.doValidate" , true);
                            
                        }
                
            }else{
                console.log("user selected current address>>>>>>>>>>>>>>>>");
                /**************For Verify Button****************/
                //NOT VERIFIED
                if(component.get("v.selectedButtontype") === 'soldToBtn'){
                    component.set("v.isSoldToVerified",false);
                }else if(component.get("v.selectedButtontype") === 'shipToEditBtn' || 
                         component.get("v.selectedButtontype") === 'billToEditBtn'){
                   
                    var items = [];
                    if(component.get("v.selectedButtontype") === 'shipToEditBtn'){
                        items = component.find("fieldShipTo");
                    }else if(component.get("v.selectedButtontype") === 'billToEditBtn'){
                        items = component.find("fieldBillTo");
                    } 
                    component.set("v.doValidate" , false);
                    var selectedIndex = component.get("v.selectedIndex");
                    items.forEach(function(cmp){
                        var index = cmp.get("v.index");
                        if(index == selectedIndex){
                            console.log(cmp.get("v.fieldValue"));
                            var fieldName = cmp.get("v.fieldName");
                            if(fieldName === 'Is_Verified_Address__c'){
                                cmp.set("v.fieldValue" , false);
                            } 
                        }
                    });
                    component.set("v.doValidate" , true);
                }else if(component.get("v.selectedButtontype") === 'shipToNewBtn' || 
                         component.get("v.selectedButtontype") === 'billToNewBtn'){
                   
                    var items = [];
                    if(component.get("v.selectedButtontype") === 'shipToNewBtn'){
                        items = component.find("newShipTo");
                    }else if(component.get("v.selectedButtontype") === 'billToNewBtn'){
                        items = component.find("newBillTo");
                    } 
                    var selectedIndex = component.get("v.selectedIndex");
                    var shipLen = component.get("v.addressLength");
                    component.set("v.doValidate" , false);
                    items.forEach(function(cmp){
                        var index = cmp.get("v.index");
                        console.log("index>>>>>>>>>>>>>>"+index);
                        console.log("selectedIndex>>>>>>>>>>>>>>"+selectedIndex);
                        if(shipLen == 1 || (shipLen > 1 && index == selectedIndex)){
                            var fieldName = cmp.get("v.fieldName");
                            if(fieldName === 'Is_Verified_Address__c'){
                                cmp.set("v.fieldValue" , false);
                            }  
                        }
                    });
                    component.set("v.doValidate" , true);
                }
                
                
            } 
            component.set("v.selectedButtontype" , "");
            component.set("v.isOpen", false);
        }else{
            //alert("Select one option");
            component.set("v.showError" , true);
        }
        //To collapse section
        /*if(component.get("v.selectedButtontype") === 'soldToBtn'){
            var flatView = component.find("Registered_add_Show_FlatView");
            var registeredAddShow = component.find("Registered_add_Show");        
            $A.util.toggleClass(registeredAddShow, "Registered_add");        
            $A.util.toggleClass(flatView, "Registered_add");
        }else if(component.get("v.selectedButtontype") === 'shipToEditBtn'){
            var fullViewId;
            var flatViewId;
            var selectedIndex = component.get("v.selectedIndex");
            flatViewId = document.getElementById('shipTo_addr_Show_Small_View-'+selectedIndex);
            fullViewId =  document.getElementById('shipTo_addr_Show_Full_View-'+selectedIndex);
            $A.util.toggleClass(fullViewId, "Registered_add");        
            $A.util.toggleClass(flatViewId, "Registered_add"); 
        }else if(component.get("v.selectedButtontype") === 'billToEditBtn'){
            var fullViewId;
            var flatViewId;
            var selectedIndex = component.get("v.selectedIndex");
            flatViewId = document.getElementById('billTo_addr_Show_Small_View-'+selectedIndex);
            fullViewId =  document.getElementById('billTo_addr_Show_Full_View-'+selectedIndex);
            $A.util.toggleClass(fullViewId, "Registered_add");        
            $A.util.toggleClass(flatViewId, "Registered_add"); 
        }*/
        
        
    },
    verifyNewAddress : function(component, event, helper){
        console.log("inside shipto verify address");
        
        var selectedIndex = event.target.id;
        var selectedButton = event.target.name;
        console.log("selectedIndex>>>>>>>>>>>>>>>",selectedIndex);
        console.log("selectedButton>>>>>>>>>>>>>>>",selectedButton);
        var suite = "";
        var street = "";
        var city = "";
        var province = "";
        var zip = "";
        if(selectedButton === 'shipToNewBtn' 
           || selectedButton === 'billToNewBtn'){
            var shipLen = 0;
            var items = [];
            if(selectedButton === 'shipToNewBtn'){
                shipLen = component.get("v.obj_addNewShipTo.length"); 
                items = component.find("newShipTo");
            }else if(selectedButton === 'billToNewBtn'){
                shipLen = component.get("v.obj_addNewBillTo.length"); 
                items = component.find("newBillTo");
            }
            console.log("items>>>>>>>>>>>>>"+items);
            items.forEach(function(cmp){
                var index = cmp.get("v.index");
                console.log("index>>>>>>>>>>>>>>"+index);
                console.log("selectedIndex>>>>>>>>>>>>>>"+selectedIndex);
                console.log("fieldValue>>>>>>>>>>>>>>>"+cmp.get("v.fieldValue"));
                if(shipLen == 1 || (shipLen > 1 && index == selectedIndex)){
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
                }
            });
        }else if(selectedButton === 'shipToEditBtn' 
                 || selectedButton === 'billToEditBtn'){
            var items = [];
            if(selectedButton === 'shipToEditBtn'){
                items = component.find("fieldShipTo");
            }else if(selectedButton === 'billToEditBtn'){
                items = component.find("fieldBillTo");
            }
            console.log("items>>>>>>>>>>>>>"+items);
            items.forEach(function(cmp){
                var index = cmp.get("v.index");
                console.log("index>>>>>>>>>>>>>>"+index);
                console.log("selectedIndex>>>>>>>>>>>>>>"+selectedIndex);
                console.log("fieldValue>>>>>>>>>>>>>>>"+cmp.get("v.fieldValue"));
                if(index == selectedIndex){
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
                }
            });
        }
        
        console.log("suite>>>>>>>>>>>>>>>>>>>>>>>>>"+suite);
        console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>"+street);
        console.log("city>>>>>>>>>>>>>>>>>>>>>>>>>"+city);
        console.log("province>>>>>>>>>>>>>>>>>>>>>>>>>"+province);
        console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>"+zip);
        component.set('v.objAddr.Suite_AGN__c', suite); 
        component.set('v.objAddr.Address_Line_1_AGN__c', street);
        component.set('v.objAddr.City_AGN__c', city);
        component.set('v.objAddr.Zip_AGN__c', zip);
        component.set("v.selectedButtontype",selectedButton);
        component.set("v.selectedIndex" , selectedIndex);
        component.set("v.addressLength" , shipLen);
        helper.getLoqateAddress(component , province);
    },
    handleAccountOwnerCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        console.log("account owner : on check>>>>>>>>>>>>>>"+ isChecked);
        if(isChecked){
            component.set("v.isAccountOwner" , false);
            component.set("v.clearAccountOwner" , true);
            component.set("v.clearAccountOwnerRequiredFields" ,  true);
        }else{
            component.set("v.isAccountOwner" , true);
            component.set("v.clearAccountOwner" , false);
            component.set("v.clearAccountOwnerRequiredFields" ,  false);
            component.set("v.AccountOwnerDependantFields" , component.get("v.AccountOwnerDependantFields"));
        }
        
    },
})