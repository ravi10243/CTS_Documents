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
        
        console.log('CustomerGrouptype :'+component.get("v.CustomerGrouptype"));
        var opt1 = $A.get("$Label.c.AGN_Article23_Relevant_Yes");
        var opt2 = $A.get("$Label.c.AGN_Article23_Relevant_NO");
        var options = [];
        options.push({label:opt1 ,value : opt1});
        options.push({label:opt2 ,value : opt2});
            //console.log("Options" +options);
            component.set('v.options', options);
               
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
        
       
    },
    
    resetBlock : function(component,event, helper){    
        
        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
        notifyRegStepChange.setParams({"Operation": 'CANCEL',
                                       "StepNo": '3'}
                                     );
        notifyRegStepChange.fire();
        
        //avijit
        /*jQuery('.add_det .infr_det').slideUp(500);
        jQuery('.no_det.active').css("border", "2px solid #a3d233");
        jQuery( ".add_det .edit_btn" ).show();
        jQuery( ".upload_doc .edit_btn" ).show();*/
    },
    
    
    
    validateAndUpsert : function(component,event, helper){
        	        var inputcmp= component.find("mygroup");		
        var countrycode = component.get("v.SAPCountryCode");		
        if((countrycode == 'IE' || countrycode == 'DE') && (inputcmp.get("v.value") == undefined || inputcmp.get("v.value") == null))		
           {		
         helper.showTosteMessage(component,'', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"),'dismissible');		
        //inputcmp.setCustomValidity("Error");		
         }        		
        else{		
        helper.validateAndUpsert(component, event); 
                    //helper.fireEvent(component, event);        

        }		
 },
        
        
    
    sectionValidateAndUpdate : function(component,event, helper){
        
        helper.sectionValidateAndUpdate(component, event);
    },
    show_hide_SoldTo_Address: function(component, event, helper){
        
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
        
        var addressType = ctarget.getAttribute("data-address-type");
        console.log('addressType => '+ addressType);
        
        if(addressType === 'SHIPTO'){
            flatViewId = document.getElementById('shipTo_addr_Show_Small_View-'+index);
            fullViewId =  document.getElementById('shipTo_addr_Show_Full_View-'+index);
        }
        else if(addressType === 'BILLTO'){
            flatViewId = document.getElementById('billTo_addr_Show_Small_View-'+index);
            fullViewId =  document.getElementById('billTo_addr_Show_Full_View-'+index);
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
        
        var objNewShipTo = component.get("v.obj_addNewShipTo");
        var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};
        objNewShipTo.push(newRecord);
        component.set("v.obj_addNewShipTo", objNewShipTo);
        jQuery(".slds-backdrop").fadeIn('fast',function(){
            jQuery(".slds-backdrop").addClass("slds-backdrop_open"); 	//adding the modal grey background
        });
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
    },
    addAnotherBillTo : function(component, event, helper){
        try{
            var objNewBillTo = component.get("v.obj_addNewBillTo"); 
            var newRecord = {'sobjectType': 'Allergan_Customer_Address_AGN__c'};            
           
            /*  added by Ravi for soldTo email assign to New BillTo  -- Start  */
            
           var soldToEmail = component.get('v.objSoldTo');
            newRecord.Email_AGN__c = soldToEmail.Email_AGN__c;
            
            /*  added by Ravi for soldTo email assign to New BillTo  -- End  */
            
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
    removeNewShip_Bill_To : function(component, event, helper){ 
        jQuery(".slds-backdrop").fadeOut('slow',function(){
        	jQuery(".slds-backdrop").removeClass("slds-backdrop_open"); //removing the modal grey background    
        });
        
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
    
    handleChange : function(component,event, helper){
         var radiovalue = component.get("v.checked");
         var opt1 = $A.get("$Label.c.AGN_Article23_Relevant_Yes");
         var opt2 = $A.get("$Label.c.AGN_Article23_Relevant_NO");
         if( radiovalue === opt1 ){
           component.set("v.objSoldTo.KB23_Article_AGN__c", true);
           component.set("v.objShipTo.KB23_Article_AGN__c", true);

         }
         else{
             component.set("v.objSoldTo.KB23_Article_AGN__c", false);
       }
       
       },

       
})