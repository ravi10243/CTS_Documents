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
})