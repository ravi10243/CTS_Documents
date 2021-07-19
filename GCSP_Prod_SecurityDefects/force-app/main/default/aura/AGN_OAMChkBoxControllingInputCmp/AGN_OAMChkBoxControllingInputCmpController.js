({
	doInit : function(component, event, helper) {
		var fieldName = component.get("v.fieldName");
           if(fieldName === 'Overseeing_accountID_AGN__c'){
                var overseeLabel = $A.get("$Label.c.AGN_OAM_Doctor_Overseeing_Account_in_Allergan");
                component.set("v.checkBoxLabel" , overseeLabel);
              
           }else if(fieldName === 'Buying_Group_Name_AGN__c'){
                var buyingGrpLabel = $A.get("$Label.c.AGN_OAM_Are_you_apart_Buying_Group");
                component.set("v.checkBoxLabel" , buyingGrpLabel);
           }else if(fieldName === 'Doctors_Email_AGN__c'){ //Account_Owner_Email_AGN__c
                component.find("ctrlChkBox").set("v.value" , true);
                
                var sateNameLabel = $A.get("$Label.c.AGN_OAM_ARE_YOU_ACCOUNT_OWNER");
                component.set("v.checkBoxLabel" , sateNameLabel); 
               
                var uploadAccountOwnerDocument = component.get("v.uploadAccountOwnerDocument");
                if(uploadAccountOwnerDocument){
                   component.find("ctrlChkBox").set("v.value" , uploadAccountOwnerDocument);
                   component.set("v.displayRequiredInput" , uploadAccountOwnerDocument );
                   component.set("v.required" , uploadAccountOwnerDocument);
                }
           } 
        
        
	},
    
    handleCheckBoxChange : function(component, event, helper) {
        var fieldName = component.get("v.fieldName");
        if(fieldName === 'Doctors_Email_AGN__c'){
            helper.handleAccountOwnerchkBox(component, event);
        }else{
            helper.handlechkBox(component, event);
        }
        //helper.handlechkBox(component, event);
	},
    
    handleAccountOwnerChange : function(component, event, helper) {
        /*console.log("handle change>>>>>>>>>>>>>>>>>>");
        var fieldName = component.get("v.fieldName");
        if(fieldName === 'Doctors_Email_AGN__c'){
            var uploadAccountOwnerDocument = component.get("v.uploadAccountOwnerDocument");
            console.log("handle change>>>>>>>>>>>>>>>>>>setting values?>>>"+uploadAccountOwnerDocument);
                if(uploadAccountOwnerDocument){
                   component.find("ctrlChkBox").set("v.value" , false);
                   component.set("v.displayRequiredInput" , uploadAccountOwnerDocument );
                   component.set("v.required" , uploadAccountOwnerDocument);
                }
        }*/
        //alert("checkbox change>>>>>>>>>>>>"+component.get("v.uploadAccountOwnerDocument"));
    }
})