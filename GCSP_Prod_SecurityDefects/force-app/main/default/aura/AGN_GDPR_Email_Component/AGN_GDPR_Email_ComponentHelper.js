({
    sendHelper: function(component, getEmail, getSubject, getbody)
    {
        
        var action = component.get("c.sendMailMethod");   
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'tskId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.mailStatus", true);
            }
            
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        
    },
    
    emailBodyHelper: function(component, event)
    {
        
        var action = component.get("c.getValues");  
        action.setParams({
            'tskId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            
            var res=JSON.stringify(response.getReturnValue());           
            var parseres= JSON.parse(res);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                //Updated by Arijit
                if(parseres.Case_Type_GDPR_AGN__c=="CCPA")
                 {
                     component.set("v.Checkregulation",true);
                component.set("v.subject",'[' + parseres.Name + '] ' + parseres.Task_Subject_GDPR_AGN__c);
                component.set("v.email",parseres.Third_Party_Email_GDPR_AGN__c);
                component.set("v.systemName",parseres.System_ID_AGN__c);
                component.set("v.body",$A.get('$Label.c.Allergan_has_received_a_CCPA_AGN') + ' ' + parseres.Request_Type_GDPR_AGN__c + ' ' + $A.get('$Label.c.Data_Subject_AGN') + ' ' +parseres.Days_to_Close_GDPR_AGN__c+ ' '+  $A.get('$Label.c.Days_to_indicate_AGN') 
                              +  '\n\n' + $A.get('$Label.c.Request_Type_value_AGN ') +(parseres.Request_Type_GDPR_AGN__c != undefined ? parseres.Request_Type_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Due_Date_AGN ') + (parseres.Due_Date_AGN__c != undefined ? parseres.Due_Date_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Type_of_Data_Subject_AGN ') + (parseres.Role_with_Allergan_GDPR_AGN__c != undefined ? parseres.Role_with_Allergan_GDPR_AGN__c : '')+ '\n\n'
                              +	$A.get('$Label.c.Title_AGN ') + (parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+ '\n'
                              +	$A.get('$Label.c.First_Name_AGN ') + (parseres.Requester_First_Name_GDPR_AGN__c != undefined ? parseres.Requester_First_Name_GDPR_AGN__c: '')+ '\n'
                              +	$A.get('$Label.c.Last_Name_AGN ') + (parseres.Requester_Last_Name_GDPR_AGN__c != undefined ? parseres.Requester_Last_Name_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Affiliation_Business_Clinic_Name_AGN ') + (parseres.Affiliation_GDPR_AGN__c != undefined ? parseres.Affiliation_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Street_Address_AGN ') + (parseres.Address_Line_1_Street_Address_GDPR_AGN__c != undefined ? parseres.Address_Line_1_Street_Address_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Town_City_AGN ') + (parseres.Address_Line_1_Town_City_GDPR_AGN__c != undefined ? parseres.Address_Line_1_Town_City_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.State_AGN ') + (parseres.Address_Line_1_State_GDPR_AGN__c != undefined ? parseres.Address_Line_1_State_GDPR_AGN__c : '')+ '\n'
                              +	$A.get('$Label.c.Country_AGN ') + (parseres.Address_Line_1_Country_GDPR_AGN__c != undefined ? parseres.Address_Line_1_Country_GDPR_AGN__c : '')+'\n'
                              +	$A.get('$Label.c.Zip_code_AGN ') + (parseres.Zip_AGN_GDPR__c != undefined ? parseres.Zip_AGN_GDPR__c : '')+'\n'
                              +	$A.get('$Label.c.E_mail_Address_AGN ') + (parseres.Address_Line_1_E_Mail_Address_GDPR_AGN__c != undefined ? parseres.Address_Line_1_E_Mail_Address_GDPR_AGN__c : '')+'\n'
                              +	$A.get('$Label.c.Phone_AGN ') + (parseres.Data_Subject_Phone_GDPR_AGN__c != undefined ? parseres.Data_Subject_Phone_GDPR_AGN__c : '')+'\n'
                              +	$A.get('$Label.c.Other_AGN ') + (parseres.Justification_for_Others_Role_GDPR_AGN__c != undefined ? parseres.Justification_for_Others_Role_GDPR_AGN__c : '')+'\n'
                              +  $A.get('$Label.c.If_You_Have_Any_Question_AGN')+'\n\n'
                              +  $A.get('$Label.c.Kind_Regards_AGN ')+'\n'
                              +  $A.get('$Label.c.Allergan_s_Global_Privacy_Office_AGN'));
               }
                if(parseres.Case_Type_GDPR_AGN__c=="GDPR")
                {
                    component.set("v.Checkregulation",false);
                     component.set("v.subject",'[' + parseres.Name + '] ' + parseres.Task_Subject_GDPR_AGN__c);
                    component.set("v.body","NOTE: DO NOT REMOVE THE SUBJECT LINE");
                }
            }     
            else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors)
                {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else
                {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);            
    },
    
})