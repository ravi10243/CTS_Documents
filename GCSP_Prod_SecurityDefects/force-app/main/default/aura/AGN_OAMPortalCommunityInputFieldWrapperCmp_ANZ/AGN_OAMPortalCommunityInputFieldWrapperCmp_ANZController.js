({
	doInit : function(component, event, helper) {
       
        var fieldName = component.get("v.fieldName");
       if(fieldName != 'Overseeing_accountID_AGN__c' 
               && fieldName != 'Buying_Group_Name_AGN__c' 
               && fieldName != 'Product_Interest_AGN__c'
               && fieldName != 'State_Name_AGN__c'
               && fieldName != 'License_Number_US_AGN__c' 
               && fieldName != 'Doctors_Email_AGN__c'){  
                component.set("v.displayMainCmp" , true);
                component.set("v.displayChkBoxCmp" , false);
                component.set("v.displayMultiPicklistCmp" , false);
            }else if(fieldName === 'Overseeing_accountID_AGN__c' 
                   || fieldName === 'Buying_Group_Name_AGN__c'
                   || fieldName === 'Doctors_Email_AGN__c'){ 
               component.set("v.displayChkBoxCmp" , true);
                component.set("v.displayMainCmp" , false);
                component.set("v.displayMultiPicklistCmp" , false);
            }else if(fieldName === 'Product_Interest_AGN__c'){
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
        var fieldName = component.get("v.fieldName");
        if(doValidate && 
           (fieldName === 'Suite_AGN__c' 
            || fieldName === 'Address_Line_1_AGN__c' 
            || fieldName === 'Address_Line_2_AGN__c'
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
                    addrObj = [];
                    if(addressType === 'SHIPTOEDIT'){
                       addrObj = component.get('v.objShipTo'); 
                    }else if(addressType === 'BILLTOEDIT'){
                       addrObj = component.get('v.objBillTo'); 
                    }
                    var i = 0;
                    addrObj.forEach(function (ship){
                          if(i == selectedIndex){
                              ship.Is_Verified_Address__c = false;
                          }
                          i = i+1;
                   });
            }else if(doValidate && !$A.util.isEmpty(addressType) 
                   && (addressType === 'SHIPTONEW' || addressType === 'BILLTONEW' )){
                    addrObj = [];
                    if(addressType === 'SHIPTONEW'){
                       addrObj = component.get('v.obj_addNewShipTo'); 
                    }else if(addressType === 'BILLTONEW'){
                       addrObj = component.get('v.obj_addNewBillTo'); 
                    }
                    var i = 0;
                    addrObj.forEach(function (addr){
                          if(i == selectedIndex){
                              addr.Is_Verified_Address__c = false;
                          }
                          i = i+1;
                   });
            }     
            
        } 
    }
})