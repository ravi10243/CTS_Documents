({
	doInit : function(component, event, helper) {
        //console.log("inside wrapper"+component.get("v.fieldName")+">>>>>"+component.get("v.required"));
		var fieldName = component.get("v.fieldName");
       if(fieldName != 'Overseeing_accountID_AGN__c' 
               && fieldName != 'Buying_Group_Name_AGN__c' 
               && fieldName != 'Product_Interest_AGN__c'
               && fieldName != 'State_Name_AGN__c'
               && fieldName != 'License_Number_US_AGN__c' 
               && fieldName != 'Doctors_Email_AGN__c'){  //Account_Owner_Email_AGN__c
               // console.log(fieldName+"== Main");
                component.set("v.displayMainCmp" , true);
                component.set("v.displayChkBoxCmp" , false);
                component.set("v.displayMultiPicklistCmp" , false);
            }else if(fieldName === 'Overseeing_accountID_AGN__c' 
                   || fieldName === 'Buying_Group_Name_AGN__c'
                   || fieldName === 'Doctors_Email_AGN__c'){ //Account_Owner_Email_AGN__c
                 //console.log(fieldName+"==Checkbox");
               component.set("v.displayChkBoxCmp" , true);
                component.set("v.displayMainCmp" , false);
                component.set("v.displayMultiPicklistCmp" , false);
            }else if(fieldName === 'Product_Interest_AGN__c'){
               // console.log(fieldName+"==Multiselect");
                 component.set("v.displayMultiPicklistCmp" , true);
                 component.set("v.displayChkBoxCmp" , false);
                component.set("v.displayMainCmp" , false);  
            } 
	},
    onValueChange : function(component, event, helper) {
        var doValidate = component.get("v.doValidate");
        var selectedIndex = component.get('v.index');
        var addressType = component.get("v.addressType");
        var addrObj;
        //console.log("doValidate>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+doValidate);
        //console.log("addressType>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+addressType);
        var fieldName = component.get("v.fieldName");
        if(doValidate && 
           (fieldName === 'Suite_AGN__c' 
            || fieldName === 'Address_Line_1_AGN__c' 
            || fieldName === 'Zip_AGN__c' 
            || fieldName === 'City_AGN__c' 
            || fieldName === 'State_AGN__c') ){
            /**************************For Step1***********************/
            component.set("v.isAddressVerified" , false); 
            /**************************For Step2 - SoldTo***********************/
            var isSoldToVerified = component.get("v.isSoldToVerified");
            if(!$A.util.isEmpty(addressType) && addressType === 'SOLDTO' && isSoldToVerified){
                console.log("setting new verified as false");
                component.set("v.isSoldToVerified" , false);
            }
            
            if(doValidate && !$A.util.isEmpty(addressType) 
                   && (addressType === 'SHIPTOEDIT' || addressType === 'BILLTOEDIT' )){
                    //console.log("SHIPTOEDIT OR BILLTOEDIT");
                    addrObj = [];
                    if(addressType === 'SHIPTOEDIT'){
                       addrObj = component.get('v.objShipTo'); 
                    }else if(addressType === 'BILLTOEDIT'){
                       addrObj = component.get('v.objBillTo'); 
                    }
                    var i = 0;
                    addrObj.forEach(function (ship){
                        //console.log("index>>>>>>>>>>>>>>"+i);
                        //console.log("selectedIndex>>>>>>>>>>>>>>"+selectedIndex);
                          if(i == selectedIndex){
                              console.log("setting edit verified as false");
                              ship.Is_Verified_Address__c = false;
                          }
                          i = i+1;
                   });
            }else if(doValidate && !$A.util.isEmpty(addressType) 
                   && (addressType === 'SHIPTONEW' || addressType === 'BILLTONEW' )){
                    //console.log("SHIPTONEW OR BILLTONEW");
                    addrObj = [];
                    if(addressType === 'SHIPTONEW'){
                       addrObj = component.get('v.obj_addNewShipTo'); 
                    }else if(addressType === 'BILLTONEW'){
                       addrObj = component.get('v.obj_addNewBillTo'); 
                    }
                    //var shipLen = component.get("v.obj_addNewBillTo.length");
                    var i = 0;
                    addrObj.forEach(function (addr){
                        //console.log("index>>>>>>>>>>>>>>"+i);
                        //console.log("selectedIndex>>>>>>>>>>>>>>"+selectedIndex);
                          if(i == selectedIndex){
                              console.log("setting new verified as false");
                              addr.Is_Verified_Address__c = false;
                          }
                          i = i+1;
                   });
            }     
            
        } 
    }
})