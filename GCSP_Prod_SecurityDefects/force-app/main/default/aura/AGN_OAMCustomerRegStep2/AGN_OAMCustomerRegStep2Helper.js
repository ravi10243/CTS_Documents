({
    fetchCountrySettings : function(component, event) {
	//console.log('CTC : '+component.get("v.customerTypeConfig"));
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        //console.log('Country code' + country);
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '2'            
            });       
        }
        else{
            action.setParams({       
                'country': country, //FR, DE, GB, IE, ES //v.countryCode v.SAPCountryCode (to fetch meta data configuration)            
                'stepNo': '2',
                'customerType': component.get("v.customerType"),
                'customerSubType': component.get("v.customerSubType"),
                'custTypeConfig': component.get("v.customerTypeConfig")
            });
        } 
        action.setStorable();
        action.setCallback(this, function(response) {
            //console.log('response.getState() ->>' + response.getState());
            if(response.getState() === 'SUCCESS') {
                
                var settingsSoldTo = [];
                var settingsBillTo = [];
                var settingsShipTo = [];
                var settingsMap = response.getReturnValue();
                //console.log('settingsMap->>' + JSON.stringify(settingsMap));
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
                 //console.log('sectionHeaderMapBillTo---->'+JSON.stringify(component.get("v.sectionHeaderMapBillTo")));
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
                            /*if(addressList[i].Ship_To_AGN__c){
                                component.set('v.shipToSameAsSoldTo', true);
                            }
                            else if(addressList[i].Ship_To_AGN__c == false && component.get('v.shipToSameAsSoldTo') == false){
                                component.set('v.shipToSameAsSoldTo', false);
                            }*/
                            
                             var opt1 = $A.get("$Label.c.AGN_Article23_Relevant_Yes");
                            var opt2 = $A.get("$Label.c.AGN_Article23_Relevant_NO");
                            if(addressList[i].KB23_Article_AGN__c)
                            {
                                component.set('v.checked',opt1);
                                component.set('v.DisclaimerValue',true);
                            }
                            else{
                                component.set('v.checked',opt2);
                                component.set('v.DisclaimerValue',false);
                            }
                            
                            
                            console.log('jyggggggggg'+addressList[i].KB23_Article_AGN__c);
                           
                            
                            component.set('v.shipToSameAsSoldTo', addressList[i].Ship_To_AGN__c); //will set true/false
                            
                            /*if(addressList[i].Bill_To_AGN__c)
                            {
                                component.set('v.billToSameAsSoldTo', true);
                            }
                            else if(addressList[i].Bill_To_AGN__c == false && component.get('v.billToSameAsSoldTo') == false){
                                component.set('v.billToSameAsSoldTo', false);
                            }*/
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
                    //console.log('is empty');
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
        var requiredMissingVPPH=false;
        var requiredMissingBillTo=false;
        var requiredMissingShipTo=false;
        var requiredMissingBillShipTo=false;
        const cmpfieldSoldTo = component.find("fieldSoldTo");
        const cmpfieldBillTo = component.find("fieldBillTo");
        const cmpfieldShipTo = component.find("fieldShipTo");
        
        const cmpfieldnewShipTo = component.find("newShipTo");
        const cmpfieldnewBillTo = component.find("newBillTo");
        
        
        const cmpSBS = [];
        
        
                /*Article 23 France - Start */
            
            // 19R3 minor,FR
            
        var Article23 = component.get("v.DisclaimerValue");
        var customergroup = component.get("v.CustomerGrouptype");
        
        
        if((Article23 == true)  && component.get("v.SAPCountryCode") == 'FR'){

           component.set("v.objSoldTo.KB23_Article_AGN__c", true);
           component.set("v.objShipTo.KB23_Article_AGN__c", true);
                  }
        /*else{
                    component.set("v.objSoldTo.KB23_Article_AGN__c", false);
           			component.set("v.objShipTo.KB23_Article_AGN__c", false);          
        }*/

        
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
                    //if (cmp.get("v.required") && $A.util.isEmpty(cmp.get("v.fieldValue")) && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        //console.log('is empty');
                        cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                    }
                    else{
                        cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
            });
        } 
        /* Either Tax or Vat Number Mandatory - Start */
            
            // 19R3 minor,ES,for missing field validation,Start
                        

            var isTaxVatRequired = false;
            const cmpTaxVat = [];
            const cmpTaxVatExistBillTo = component.find("fieldVatTaxExist");
            var k=0;
            var countryCode=component.get("v.countryCode");
            if(countryCode=='ES' || countryCode=='IT')
            {
            if(cmpTaxVatExistBillTo)
            {
                cmpTaxVat.push(cmpTaxVatExistBillTo);
            }
             
            if (!cmpTaxVat) return;
                if ($A.util.isArray(cmpTaxVat)){
                    cmpTaxVat.forEach( function (cmps){                        
                        if($A.util.isArray(cmps)){
                            cmps.forEach( function (cmp){
                                console.log('inside bill to array');
                                var taxnumber = cmp.get("v.record.Tax_Number_AGN__c");
                                var vatNumber = cmp.get("v.record.VAT_Number_AGN__c");
                                if((taxnumber == null && vatNumber == null) || (jQuery.trim(taxnumber) == '' &&  jQuery.trim(vatNumber) == '') 
                                   || (taxnumber == undefined && vatNumber == undefined)){                                    
                                    cmp.set("v.VatNumberMissing", true);
                                    cmp.set("v.TaxNumberMissing", true);
                                    //isTaxVatRequired = true;
                                    k++;
                                    console.log('inside blank field'+k);
                                }else{
                                    cmp.set("v.VatNumberMissing", false);
                                    cmp.set("v.TaxNumberMissing", false);
                                    //isTaxVatRequired = false;
                                }
                                //alert('Multiple>>'+JSON.stringify(component.get("v.record.Tax_Number_AGN__c")+'--->'+cmp.get("v.record.VAT_Number_AGN__c")));
                            });
                            
                        }else{
                            console.log('inside bill to single');
                            var taxnumber = cmps.get("v.record.Tax_Number_AGN__c");
                            var vatNumber = cmps.get("v.record.VAT_Number_AGN__c");
                            if((taxnumber == null && vatNumber == null) || (jQuery.trim(taxnumber) == '' &&  jQuery.trim(vatNumber) == '') 
                               || (taxnumber == undefined && vatNumber == undefined)){
                                    cmps.set("v.VatNumberMissing", true);
                                    cmps.set("v.TaxNumberMissing", true);
                                    //isTaxVatRequired = true;
                                    k++;
                            }else{
                                cmps.set("v.VatNumberMissing", false);
                                cmps.set("v.TaxNumberMissing", false);
                                //isTaxVatRequired = false;
                            }
                            
                            //alert('Single>>'+JSON.stringify(cmps.get("v.record.Tax_Number_AGN__c")+'--->'+cmps.get("v.record.VAT_Number_AGN__c")));
                        }
                       
                    });
                    
                    if(k>0)
                    isTaxVatRequired = true;  
                    else
                    isTaxVatRequired = false;
                    
                    console.log('k: '+k);
                    console.log('isTaxVatRequired old bill to: '+isTaxVatRequired);
                }

        if(isTaxVatRequired){
            this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Pleae_Enter_VAT_TAX_Number"), 'dismissible'); 
            retrun;
        } 
        
               const cmpTaxVatNewBillTo = component.find("fieldVatTax");
                
                if(cmpTaxVatNewBillTo){
                    cmpTaxVat.push(cmpTaxVatNewBillTo);
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
                    this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Pleae_Enter_VAT_TAX_Number"), 'dismissible'); 
                    retrun;
                }
                
            }
                
          // 19R3 minor,ES,End
        /* Either Tax or Vat Number Mandatory - End */
            
            
            /********* ES Additional ShipTo validation***********/
            var country = component.get("v.countryCode");
            var customerType =component.get("v.customerType");           
            var obj_NewShipTo = component.get('v.obj_addNewShipTo');            
            var objShipToExistingVal = component.get('v.objShipTo');
            var objBillToExistingVal= component.get("v.objBillTo");
            var obj_NewBillTo = component.get('v.obj_addNewBillTo');
            
            var shipToSameAsSoldTo= component.get("v.shipToSameAsSoldTo");
            var billToSameAsSoldTo= component.get("v.billToSameAsSoldTo");
            let newShipTo = Object.values(obj_NewShipTo); 
            let newBillTo = Object.values(obj_NewBillTo); 
            let oldBillTo = Object.values(objBillToExistingVal);
            let oldShipTo = Object.values(objShipToExistingVal); 
            if(country === 'ES' && customerType=='Pharmacies'){                             
                var totalCount=newShipTo.length + oldShipTo.length;
                console.log('totalCount shipto : '+totalCount);
                if(totalCount >1){                        
                    //console.log('totalCount shipto if : ');
                    requiredMissingVPPH=false;
                    //requiredMissing = false;                        
                }else{
                    //console.log('totalCount shipto else : ');
                    requiredMissingVPPH=true;
                    //requiredMissing = true;
                }
                
                
            }
           
            if(country != 'ES'){
              
                var totalCountShipTo = 0;
                var totalCountBillTo = 0;
                if(!objShipToExistingVal || objShipToExistingVal.length == 0){
                    if(shipToSameAsSoldTo){
                        totalCountShipTo = newShipTo.length + 1;
                    }
                    else{
                        totalCountShipTo = newShipTo.length;
                    }
                }
                else{
                    
                    objShipToExistingVal.forEach( function (cmp){
                        if(cmp.Sold_To_AGN__c){
                            if(!shipToSameAsSoldTo){
                            	totalCountShipTo = newShipTo.length + oldShipTo.length - 1;
                            }
                            else{
                                totalCountShipTo = newShipTo.length + oldShipTo.length;
                            }
                        }
                        else{
                            totalCountShipTo += newShipTo.length + oldShipTo.length + (shipToSameAsSoldTo == true ? 1 : 0);
                        }
                    });
                }
                
                if(!objBillToExistingVal || objBillToExistingVal.length == 0){
                    if(billToSameAsSoldTo){
                        totalCountBillTo = newBillTo.length + 1;
                    }
                    else{
                        totalCountBillTo = newBillTo.length;
                    }
                }
                else{
                    
                    objBillToExistingVal.forEach( function (cmp){
                        console.log('cmp.Sold_To_AGN__c -->' + cmp.Sold_To_AGN__c);
                        if(cmp.Sold_To_AGN__c){
                            if(!billToSameAsSoldTo){
                            	totalCountBillTo = newBillTo.length + oldBillTo.length - 1;
                            }
                            else{
                                totalCountBillTo = newBillTo.length + oldBillTo.length;
                            }
                        }
                        else{
                            totalCountBillTo += newBillTo.length + oldBillTo.length + (billToSameAsSoldTo == true ? 1 : 0);
                        }
                    });
                }
                
               // console.log('totalCountShipTo : '+totalCountShipTo);
                //console.log('totalCountBillTo : '+totalCountBillTo); 
                //console.log('newBillTo.length : '+newBillTo.length); 
                //console.log('oldBillTo.length : '+oldBillTo.length); 
                //console.log('billToHasSoldTo : '+billToHasSoldTo); 
                if(totalCountShipTo>=1 && totalCountBillTo>=1){                        
                    
                    requiredMissingBillShipTo=false;
                    //requiredMissing = false;  
                    
                }else{
                    requiredMissingBillShipTo=true;
                    //requiredMissing = true;  
                    
                }
            }
            if(requiredMissingBillShipTo){               
                
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Additional_Bill_To_Ship_To_Missing"), 'dismissible');
                return;
            }
            
            
            if(requiredMissingVPPH){               
                
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Additional_Ship_To_Missing"), 'dismissible');
                return;
            }
            /********* ES Additional ShipTo validation Ends*************/
            
            //return;
            //
           if((Article23 == false )  && (component.get("v.SAPCountryCode") == 'FR') && (customergroup=='Chirurgie maxillo-faciale' || customergroup=='Optalmologie'  || customergroup=='Dermatologie' ||  customergroup=='Centre de rééducation'))

           {
               requiredMissing = true;
           }
           
            if(requiredMissing){
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                // alert($A.get("$Label.c.AGN_OAM_Body_PleaseFill"));
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
            }else{
                this.validateFormatFields(component, event);
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
            }); 
        }
        
         /* Either Tax or Vat Number Mandatory - Start */
            
                      // 19R3 minor,ES,for field formatting,Start
                      var objBillTo = component.get('v.objBillTo');
                      var soldToId = component.get('v.objSoldTo').Id;
                      var obj_NewBillTo = component.get('v.obj_addNewBillTo');
 
                      var TaxNumber;
                      var VatNumber;
                      var TaxNumberobj_NewBillTo;
                      var VatNumberobj_NewBillTo;
            
                      var countryCode =  component.get("v.countryCode");
            
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

                    if(countryCode=='ES' || countryCode=='IT')  { 
                        
                    objBillTo.forEach(function (bill){
                
                    console.log('Inside objBillToFormat');
                    console.log('Tax_Number_AGN__c_objBillTo: '+bill.Tax_Number_AGN__c);
                    console.log('VAT_Number_AGN__c_objBillTo: '+bill.VAT_Number_AGN__c);
                    TaxNumber = bill.Tax_Number_AGN__c ;
                    VatNumber = bill.VAT_Number_AGN__c ;
                        
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
            
                    obj_NewBillTo.forEach(function (nbill){
                    console.log('Inside obj_NewBillToFormat');
                    console.log('Tax_Number_AGN__c_obj_NewBillTo: '+nbill.Tax_Number_AGN__c);
                    console.log('VAT_Number_AGN__c_obj_NewBillTo: '+nbill.VAT_Number_AGN__c);
                    TaxNumber = nbill.Tax_Number_AGN__c ;
                    VatNumber = nbill.VAT_Number_AGN__c ;
                        
                        if(jQuery.trim(TaxNumber) != '' && jQuery.trim(VatNumber) != ''){
                            if(jQuery.trim(TaxNumber).toString().match(taxFormate) && jQuery.trim(VatNumber).toString().match(faxFormate)){
                                console.log('Tax number and Vat Number is wellFormatted');                                          
                            }else if(!jQuery.trim(TaxNumber).toString().match(taxFormate) && !jQuery.trim(VatNumber).toString().match(faxFormate)){                                      
                                wellFormatted = false; 
                                whichFields += $A.get("$Label.c.AGN_OAM_Tax_Number") + " (&&) " + $A.get("$Label.c.AGN_OAM_VAT_Number") + " ,";                                    
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
                     // 19R3 minor,ES,for field formatting,End
                        /* Either Tax or Vat Number Mandatory - End */
      
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
                return;
            }
            else{
                //calling registration process
                console.log("upsertAddressDetails Function");
                
                this.upsertAddressDetails(component, event);  
                //console.log('addressList = ' +JSON.stringify(component.get('v.objBillTo')));              
            }  
    },
    upsertAddressDetails : function(component, event) { 
        try{
            console.log("Inside upsertRegistration");
            var soldToId = component.get('v.objSoldTo').Id;
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
            // console.log('abdul 1 : '+objShipTo);
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
            // component.set('v.obj_addNewShipTo', obj_NewShipTo);
            // console.log('abdul 2 obj_addNewShipTo='+JSON.stringify(component.get('v.obj_addNewShipTo')));
            
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
        
        
        //*********upsert CustomerRegistration *************
        
        
        
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
        console.log(JSON.stringify(response, null, 2));
        
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
    }

})