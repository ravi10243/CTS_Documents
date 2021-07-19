({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
        
    },
    doneRendering : function(component,event, helper){
     
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
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
     
        helper.fetchDependantFields(component, country);//
        
        helper.doValidateLoqate(component, country);
              
        
       
        
    },
    
    resetBlock : function(component,event, helper){    
        
        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
        notifyRegStepChange.setParams({"Operation": 'CANCEL',
                                       "StepNo": '2'}
                                     );
        notifyRegStepChange.fire();
      
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
        var state = "";
        var taxNo = "";
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
                        }else if(fieldName === 'Tax_Number_AGN__c'){
                            taxNo = cmp.get("v.fieldValue");                               
                        }else if(fieldName.toUpperCase() == 'STATE_AGN__C'){
                             var input = cmp.get("v.fieldValue");
                             var fields = input.split('-'); 
                             state = fields[1];
                        }
                    }); 
                    var address = account +", ";
                    if(!$A.util.isEmpty(department)){
                        address = address + department+", ";
                    }
                    if(!$A.util.isEmpty(suite)){
                        address = address + suite+", ";
                    }
                    address = taxNo+", "+address+street+", "+city+", "+state+", "+zip+", "+phone+", "+email;
                    const soldToFlatView = component.find("soldToFlatView");
                    console.log("soldToFlatView>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+soldToFlatView.get("v.outPut"));
                    soldToFlatView.set("v.outPut" , address);
        }
                    
        var flatView = component.find("Registered_add_Show_FlatView");
        var registeredAddShow = component.find("Registered_add_Show");        
        $A.util.toggleClass(registeredAddShow, "Registered_add");        
        $A.util.toggleClass(flatView, "Registered_add");
     
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
        var state = "";
        var taxNo ="";
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
                            }else if(fieldName.toUpperCase() == 'STATE_AGN__C'){
                             var input = cmp.get("v.fieldValue");
                             var fields = input.split('-'); 
                             state = fields[1];
                        	}else if(fieldName === 'Tax_Number_AGN__c'){
                            taxNo = cmp.get("v.fieldValue");                               
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
                    if(!$A.util.isEmpty(taxNo)){
                        taxNo = taxNo + ", ";
                    }
        address = taxNo + address + street + ", " + city + ", " + state + ", " + zip + ", " + phone + ", " + email;
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
    
    updateSoldToForSameASShipto : function(component, event){     
        var objShipto = component.get("v.objShipTo");
        var ObjAddnewShipto = component.get("v.obj_addNewShipTo");
        var gcspSettings = component.get("v.gcspSettings.Number_Of_ShipTo_Allowed_AGN__c");
        var objSoldTo = component.get("v.objSoldTo");
        if(objSoldTo.Ship_To_AGN__c){
            
            if(!component.get("v.shipToSameAsSoldTo")){
                component.set("v.showHideAddButtonShipTo", 1);
            }else if((objShipto.length + ObjAddnewShipto.length - component.get("v.showHideAddButtonShipTo")) >= parseInt(gcspSettings) && component.get("v.shipToSameAsSoldTo")){
                alert($A.get("$Label.c.AGN_OAM_NumberOfShipTo_LimitExceed")); 
                component.set("v.shipToSameAsSoldTo", false);
            }else if((objShipto.length + ObjAddnewShipto.length - component.get("v.showHideAddButtonShipTo")) < parseInt(gcspSettings) && component.get("v.shipToSameAsSoldTo")){
                component.set("v.showHideAddButtonShipTo", 0);
            }
            
            
        }else{
            
            if(component.get("v.shipToSameAsSoldTo")){
                component.set("v.showHideAddButtonShipTo", -1); 
            }else{
                component.set("v.showHideAddButtonShipTo", 0); 
            }
            if((objShipto.length + ObjAddnewShipto.length - component.get("v.showHideAddButtonShipTo")) > parseInt(gcspSettings) && component.get("v.shipToSameAsSoldTo")){
                alert($A.get("$Label.c.AGN_OAM_NumberOfShipTo_LimitExceed"));   
                component.set("v.shipToSameAsSoldTo", false);
                component.set("v.showHideAddButtonShipTo", 0); 
            }else if((objShipto.length + ObjAddnewShipto.length - component.get("v.showHideAddButtonShipTo")) < parseInt(gcspSettings) && component.get("v.shipToSameAsSoldTo")){
                component.set("v.showHideAddButtonShipTo", 0);
            }
            
        }	
        
       /* if(component.get("v.shipToSameAsSoldTo") == false){
            component.set("v.objSoldTo.Ship_To_AGN__c", false);            
            //console.log('soldTo_ShipTo--->'+JSON.stringify(component.get('v.objSoldTo').Ship_To_AGN__c));           
        }else{
            component.set("v.objSoldTo.Ship_To_AGN__c", true);
        } */
    },
    
    updateSoldToForSameAsBillTo : function(component, event){
        var objBillto = component.get("v.objBillTo");
        var ObjAddnewBillto = component.get("v.obj_addNewBillTo");
        var gcspSettings = component.get("v.gcspSettings.Number_Of_BillTo_Allowed_AGN__c");
        
        var objSoldTo = component.get("v.objSoldTo");
        if(objSoldTo.Bill_To_AGN__c){
            
            if(!component.get("v.billToSameAsSoldTo")){
                component.set("v.showHideAddButton", 1);
            }else if((objBillto.length + ObjAddnewBillto.length - component.get("v.showHideAddButton")) >= parseInt(gcspSettings) && component.get("v.billToSameAsSoldTo")){
                alert($A.get("$Label.c.AGN_OAM_NumberOfBillTo_LimitExceed"));
                component.set("v.billToSameAsSoldTo", false);
            }else if((objBillto.length + ObjAddnewBillto.length - component.get("v.showHideAddButton")) < parseInt(gcspSettings) && component.get("v.billToSameAsSoldTo")){
                component.set("v.showHideAddButton", 0);
            }
            
            
        }else{
            
            if(component.get("v.billToSameAsSoldTo")){
                component.set("v.showHideAddButton", -1); 
            }else{
                component.set("v.showHideAddButton", 0); 
            }
            if((objBillto.length + ObjAddnewBillto.length - component.get("v.showHideAddButton")) > parseInt(gcspSettings) && component.get("v.billToSameAsSoldTo")){
                alert($A.get("$Label.c.AGN_OAM_NumberOfBillTo_LimitExceed"));   
                component.set("v.billToSameAsSoldTo", false);
                component.set("v.showHideAddButton", 0); 
            }else if((objBillto.length + ObjAddnewBillto.length - component.get("v.showHideAddButton")) < parseInt(gcspSettings) && component.get("v.billToSameAsSoldTo")){
                component.set("v.showHideAddButton", 0);
            }
            
        }	
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
       // component.set("v.showHideAddButtonShipTo", -1); 
        console.log('obj_addNewShipTo-->'+JSON.stringify(component.get("v.obj_addNewShipTo")));
        var buttonSave = component.find("buttonSave");  
        $A.util.addClass(buttonSave, "soldto");
       
    },
    addAnotherBillTo : function(component, event, helper){
       
        try{
            var objNewBillTo = component.get("v.obj_addNewBillTo"); 
            var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
            objNewBillTo.push(newRecord);
            component.set("v.obj_addNewBillTo", objNewBillTo);
            
           // component.set("v.showHideAddButton", -1);  
        }catch(err){
            console.error(err.message);
        }      
        
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
            //component.set("v.showHideAddButtonShipTo", 1); 
        }
        else if(addressType === 'BILLTO'){
            objAddress = component.get("v.obj_addNewBillTo");
            v_objAddress = 'v.obj_addNewBillTo';
           // component.set("v.showHideAddButton", 1); 
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
    
    verifyAddress : function(component, event, helper){
        console.log("inside verify address");
        const items = component.find("fieldSoldTo");
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
        console.log("Calling Loqate Validate Method>>>>>>>>>>>>>>",component.get("v.SAPCountryCode"));
        component.set("v.selectedButtontype",event.getSource().getLocalId());
        
        helper.getLoqateAddress(component , component.get("v.SAPCountryCode"));
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
                var country = component.get("v.SAPCountryCode");
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
                        if(fieldName === 'Address_Line_2_AGN__c'){
                            cmp.set("v.fieldValue" , streetno);
                        }else if(fieldName === 'Address_Line_1_AGN__c'){
                            cmp.set("v.fieldValue" , street);
                        }else if(fieldName === 'City_AGN__c'){
                            cmp.set("v.fieldValue" , suburb);
                        }else if(fieldName === 'State_AGN__c'){
                            if(country === 'NZ'){
                                state = cmp.get("v.fieldValue");
                            }
                            cmp.set("v.fieldValue" , state);
                        }else if(fieldName === 'Zip_AGN__c'){
                            cmp.set("v.fieldValue" , zip.trim());
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
                    if(!$A.util.isEmpty(streetno)){
                        address = address + streetno +", ";
                    }
                    address = address + street +", " + suburb + ", " + zip + ", " + phone +", " + email;
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
                            if(fieldName === 'Address_Line_2_AGN__c'){
                                cmp.set("v.fieldValue" , streetno);
                            }else if(fieldName === 'Address_Line_1_AGN__c'){
                                cmp.set("v.fieldValue" , street);
                            }else if(fieldName === 'City_AGN__c'){
                                cmp.set("v.fieldValue" , suburb);
                            }else if(fieldName === 'Zip_AGN__c'){
                                cmp.set("v.fieldValue" , zip.trim());
                            }else if(fieldName === 'State_AGN__c'){
                                console.log("yoo>>>>>>>>>>>>>>>");
                                console.log("selected country>>>>>>>>>>>>>>>"+country);
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
                    if(!$A.util.isEmpty(streetno)){
                        address = address + streetno +", ";
                    }
                    address = address+ street+", "+suburb+", "+zip +", "+phone+", "+email;
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
                        if($A.util.isArray(billToFlatView)){
                           billToFlatView.forEach(function(cmp){
                                var index = cmp.get("v.index");
                                console.log("index>>>>>>>>>>>>>>>>>>>>"+index);
                                console.log("selectedIndex>>>>>>>>>>>>>>>>>>>>"+selectedIndex);
                                if(index == selectedIndex){
                                   cmp.set("v.outPut" , address);
                                }
                            }); 
                        }else{
                            billToFlatView.set("v.outPut" , address);
                        }
                        
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
                            if(fieldName === 'Address_Line_2_AGN__c'){
                                cmp.set("v.fieldValue" , streetno);
                            }else if(fieldName === 'Address_Line_1_AGN__c'){
                                cmp.set("v.fieldValue" , street);
                            }else if(fieldName === 'City_AGN__c'){
                                cmp.set("v.fieldValue" , suburb);
                            }else if(fieldName === 'Zip_AGN__c'){
                                cmp.set("v.fieldValue" , zip.trim());
                            }else if(fieldName === 'State_AGN__c'){
                                console.log("selected country>>>>>>>>>>>>>>>"+country);
                                if(country === 'NZ'){
                                   state = cmp.get("v.fieldValue");
                                }
                                cmp.set("v.fieldValue" , state);
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
    },
    verifyNewAddress : function(component, event, helper){
        console.log("inside shipto verify address");
        
        var selectedIndex = event.target.id;
        var selectedButton = event.target.name;
        console.log("selectedIndex>>>>>>>>>>>>>>>",selectedIndex);
        console.log("selectedButton>>>>>>>>>>>>>>>",selectedButton);
        var streetno = "";
        var street = "";
        var suburb = "";
        var state = "";
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
                    if(fieldName === 'Address_Line_2_AGN__c'){
                        streetno = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Address_Line_1_AGN__c'){
                        street = cmp.get("v.fieldValue");
                    }else if(fieldName === 'City_AGN__c'){
                        suburb = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Zip_AGN__c'){
                        zip = cmp.get("v.fieldValue");
                    }else if(fieldName === 'State_AGN__c'){
                        state = cmp.get("v.fieldValue");
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
                    if(fieldName === 'Address_Line_2_AGN__c'){
                        streetno = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Address_Line_1_AGN__c'){
                        street = cmp.get("v.fieldValue");
                    }else if(fieldName === 'City_AGN__c'){
                        suburb = cmp.get("v.fieldValue");
                    }else if(fieldName === 'Zip_AGN__c'){
                        zip = cmp.get("v.fieldValue");
                    }else if(fieldName === 'State_AGN__c'){
                        state = cmp.get("v.fieldValue");
                    } 
                }
            });
        }
        
        console.log("streetno>>>>>>>>>>>>>>>>>>>>>>>>>"+streetno);
        console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>"+street);
        console.log("suburb>>>>>>>>>>>>>>>>>>>>>>>>>"+suburb);
        console.log("state>>>>>>>>>>>>>>>>>>>>>>>>>"+state);
        console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>"+zip);
        component.set('v.objAddr.Address_Line_2_AGN__c', streetno); 
        component.set('v.objAddr.Address_Line_1_AGN__c', street);
        component.set('v.objAddr.City_AGN__c', suburb);
        component.set('v.objAddr.Zip_AGN__c', zip);
        component.set('v.objAddr.State_AGN__c', state);
        component.set("v.selectedButtontype",selectedButton);
        component.set("v.selectedIndex" , selectedIndex);
        component.set("v.addressLength" , shipLen);
        helper.getLoqateAddress(component , component.get("v.SAPCountryCode"));
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
})