({
    sendHelper: function(component, getEmail, getSubject, getbody)
    {
        component.set("v.showLoadingSpinner",true); 
        var action = component.get("c.sendMailMethod");   
        action.setParams({
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'atachID':component.get("v.attachId"),
            'caseId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var res=JSON.stringify(response.getReturnValue());           
            var parseres= JSON.parse(res);
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.subject",$A.get('$Label.c.CCPA_Access_Request_Email_Body_AGN'));
                var storeResponse = response.getReturnValue();
              //  component.set("v.Spinner",false);
                component.set("v.mailStatus", true);     
            }
            
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    
 	// Added by Namrata :Changes done for EmailType
 	
     populateEmailBodyForEmailType:function(component, event){
        var action = component.get("c.getValues");   
        action.setParams({
            'caseId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
           var res=JSON.stringify(response.getReturnValue());           
           var parseres= JSON.parse(res);
            console.log('Namrata1'+component.get("v.emailType"));
            if(component.get("v.emailType") == "Information Task Completed"){
            
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Information_Complete_subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Information_Complete_Email_Body_AGN'));
            }
            else if(component.get("v.emailType") == "Information Task Failed"){
                
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Information_Failed_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Information_Failed_Email_Body_AGN'));
            }
            else if(component.get("v.emailType") == "Others Selected For Information"){
               component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Information_Request_Email_Subject_AGN'));
               component.set("v.body"," "); 
            }
            else if(component.get("v.emailType") == "Information Generic Info Required"){
               component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Information_Info_Required_Generic_Subject_AGN'));
               component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Information_Info_Required_Generic_Email_Body_AGN'));
            }
            else if(component.get("v.emailType") == "Access Request Type Failed"){
                console.log("Access type");
               component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Failed_Subject_AGN'));
               component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Access_Failed_Email_Body_AGN'));
            }
            else if(component.get("v.emailType") == "Others Selected For Access"){
               component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Request_Email_Subject_AGN'));
               component.set("v.body"," ");
            }
            else if(component.get("v.emailType") == "Access Generic Info Required"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Info_Required_Generic_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Access_Info_Required_Generic_Email_Body_AGN'));  
            }
            else if(component.get("v.emailType") == "Access Info Required"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Info_Required_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Access_Info_Required_Email_Body_AGN_1') +'\n' + $A.get('$Label.c.CCPA_Access_Info_Required_Email_Body_AGN_2'));
            
            }
            else if(component.get("v.emailType") == "Deletion Completed"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.Deletion_Complete_Status_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.Deletion_Complete_Email_Body_AGN'));
            }
            else if(component.get("v.emailType") == "Deletion Partially Completed"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.Deletion_Partial_Complete_Status_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.Deletion_Partial_Complete_Email_Body_AGN'));   
            }
            else if(component.get("v.emailType") == "Deletion Failed"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.Deletion_Failed_Status_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.Deletion_Failed_Email_Body_AGN'));  
            }
            else if(component.get("v.emailType") == "Others Selected For Deletion"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.Deletion_Failed_Status_AGN'));
              component.set("v.body"," ");  
            }
            else if(component.get("v.emailType") == "Deletion Info Required"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Deletion_Info_Required_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Deletion_Info_Required_Email_Body_AGN_1') +'\n' + $A.get('$Label.c.CCPA_Deletion_Info_Required_Email_Body_AGN_2'));
            }
            else if(component.get("v.emailType") == "Deletion Confirmation Mail"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Deletion_Confirmation_mail_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Deletion_Confirmation_mail_Email_Body_AGN')); 
            }
            else if(component.get("v.emailType") == "Deletion Generic Info Required"){
              component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Deletion_Info_Required_Generic_Subject_AGN'));
              component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Deletion_Info_Required_Generic_Email_Body_AGN')); 
            }
        });
        $A.enqueueAction(action);
    },

    //Updated By Namrata: Email requirement.
    //TODO: remove the commented sections
    emailBodyHelper: function(component, event)
    {
        var action = component.get("c.getValues");   
        action.setParams({
            'caseId':component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var res=JSON.stringify(response.getReturnValue());           
            var parseres= JSON.parse(res);
                //component.set("v.subject",'['+parseres.CaseNumber+'] ' +parseres.Full_Name_GDPR_AGN__c+' - '+parseres.Request_Type_GDPR_AGN__c);
                //component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Request_Email_Subject_AGN'));
                if(parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN"){
                    if(parseres.Request_Type_GDPR_AGN_new__c=="Categories of personal information (Information)"){
                        component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Information_Request_Email_Subject_AGN'));
                    }
                    if(parseres.Request_Type_GDPR_AGN_new__c=="Specific pieces of personal information (Access)"){
                        component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Access_Request_Email_Subject_AGN'));
                    }
                   if(parseres.Request_Type_GDPR_AGN_new__c=="Deletion"){
                        component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.Deletion_Failed_Status_AGN'));
                    }
                }
                component.set("v.email",parseres.Data_Subject_Email_GDPR_AGN__c);
                //component.set("v.body","NOTE: DO NOT REMOVE THE SUBJECT LINE");\
                if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Specific pieces of personal information (Access)") && (parseres.Status=="Task Completed"))
                {
                    component.set("v.isRequestTypeAccess",true); 
                     component.set("v.displayEmailTypeForAccess",false);  
               
                       }
                
           		if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Specific pieces of personal information (Access)") && !(parseres.Status == "Task Completed" || parseres.Status == "Closed"))
                {
                    component.set("v.displayEmailTypeForAccess",true);  
                   component.set("v.isRequestTypeAccess",false); 
					            
                }
           		if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Categories of personal information (Information)") && (parseres.Status=="Task Completed"))
                {
                    component.set("v.isRequestTypeInformation",true);
                    component.set("v.displayEmailTypeForInformation",false);  
                   /* component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Access_Request_Email_Body_AGN'));*/
                    component.set("v.viewattachment",true);    
                }
                if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Categories of personal information (Information)") && !(parseres.Status == "Task Completed" || parseres.Status == "Closed"))
                {
                   component.set("v.displayEmailTypeForInformation",true);  
					component.set("v.isRequestTypeInformation",false);                    
                }
                if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Deletion") && (parseres.Status=="Task Completed"))
                {
                    component.set("v.isRequestTypeDeletion",true);
                    component.set("v.displayEmailTypeForDeletion",false);
                    /*component.set("v.subject",'['+parseres.CaseNumber+'] ' + $A.get('$Label.c.CCPA_Deletion_Request_Completion_Email_Subject_AGN'));
                    component.set("v.body",$A.get('$Label.c.Dear_AGN')+' '+(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+' '+(parseres.First_Name_GDPR_AGN__c != undefined ? parseres.First_Name_GDPR_AGN__c : '')+' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n' 
                                  + $A.get('$Label.c.CCPA_Deletion_Request_Completion_Email_Body_AGN'));*/
                }
                
                if((parseres.RecordType.DeveloperName=="CCPA_Case"||parseres.RecordType.DeveloperName=="Contact_Center_AGN") && (parseres.Request_Type_GDPR_AGN_new__c=="Deletion") && !(parseres.Status == "Task Completed" || parseres.Status == "Closed"))
                {
                    component.set("v.displayEmailTypeForDeletion",true);
                     component.set("v.isRequestTypeDeletion",false);
                }
            
            //Updated by Kunal: Change required to populate ds email body on send email tab
            if((parseres.RecordType.DeveloperName=="GDPR_Case"||parseres.RecordType.DeveloperName=="GDPR_DPO") && (parseres.Status!="Task Completed"))
            {  
                console.log('Task Not Completed');
                component.set("v.isGDPRCase", true);
                component.set("v.subject",'['+parseres.CaseNumber+'] ' +parseres.Full_Name_GDPR_AGN__c+' - '+parseres.Request_Type_GDPR_AGN_new__c);
               // component.set("v.subject",'['+parseres.CaseNumber+'] ' +parseres.Subject);
               
                
            }
  
            
            //Updated by Rajeev for GDPR Erasure and Update Request Type: Change required to populate ds email body on send email tab
            //DSRM Open defect Fix Defect ID - D 48 Release Date - 9th May 2020
            //Defect D 48 changes Starts here 
            
            if((parseres.RecordType.DeveloperName=="GDPR_Case"||parseres.RecordType.DeveloperName=="GDPR_DPO") && (parseres.Status=="Task Completed"))
            {  
                console.log('Task Completed');
                console.log('DS Language GDPR '+parseres.DS_Selected_Language_GDPR_AGN__c);
                console.log('DS Request Type '+parseres.Request_Type_GDPR_AGN_new__c);
                
                if(parseres.Request_Type_GDPR_AGN_new__c =='Erasure' || parseres.Request_Type_GDPR_AGN_new__c =='Rectification')
                {
                    var action1 = component.get("c.setGDPREmailContent");   
                    action1.setParams({
                        'requestType': parseres.Request_Type_GDPR_AGN_new__c,
                        'dsLanguage': parseres.DS_Selected_Language_GDPR_AGN__c
                    });
                    action1.setCallback(this, function(response) {
                        var res=response.getReturnValue();    
                        console.log('Resposne Recieved for GDPR TAsk Completed Changed' +res);
                        console.log('Salutation '+res.Salutation+' Subject '+res.dsEmailSubject+' Body '+res.dsEmailBody);
                        var state = response.getState();
                        if (state === "SUCCESS") 
                        {
                            //modified to include caseNumber in Email Subject (In case email tab)
                            component.set("v.subject",'['+(parseres.CaseNumber != undefined ? parseres.CaseNumber : '')+'] ' +(res.dsEmailSubject != undefined ? res.dsEmailSubject : ''));
                            
                            component.set("v.body",(res.Salutation != undefined ? res.Salutation : '')+' '
                                          +(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')+
                                          ' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n'
                                          + (res.dsEmailBody != undefined ? res.dsEmailBody : ''));  
                            
                        }
                        
                    });
                    $A.enqueueAction(action1);
                }
                //if the Request Type is other than Erasure and Update
                else
                {
                    component.set("v.subject",'['+parseres.CaseNumber+'] ' +(parseres.DS_Email_Subject_GDPR_AGN__c != undefined ? parseres.DS_Email_Subject_GDPR_AGN__c :''));
                    component.set("v.body",(parseres.Titile_AGN_GDPR__c != undefined ? parseres.Titile_AGN_GDPR__c : '')
                                  +' '+(parseres.Last_Name_GDPR_AGN__c != undefined ? parseres.Last_Name_GDPR_AGN__c : '')+','+'\n');
                }
            } // Defect D-48 Changes ends here.           
        });
            
        $A.enqueueAction(action);   
       
    },
    
})