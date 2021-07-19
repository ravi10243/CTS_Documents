({
    doInit : function(component, event, helper) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": "Rejection_Reason_Code_AGN__c",
            "caseId":component.get("v.recordId")
        });
        var opts = [];
        var opts1 =[];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") 
            {
                var allValues = response.getReturnValue();
                console.log('Record Type Name --> ',allValues.CaseFields.Record_Type_Name_AGN__c);
                console.log('Status',allValues.cstatus);
                console.log('DS BODY ',allValues.CaseFields.DS_Email_Body_AGN__c);
                component.set("v.recordTypeName",allValues.CaseFields.Record_Type_Name_AGN__c);
                var lang1 = allValues.CaseFields.DS_Selected_Language_GDPR_AGN__c;
                var lang2= lang1.split(" ").join("");
                var lang3 = lang2.split("-").join("");
                console.log('DS Language after trim',lang3);
                component.set("v.DSLang",lang3);
                
                if(allValues.CaseFields.Record_Type_Name_AGN__c == 'CCPA_Case' || allValues.CaseFields.Record_Type_Name_AGN__c == 'Contact_Center_AGN' )
                {
                    component.set("v.dsmessage",$A.get("$Label.c.AGN_CCPA_Reject_Case_Message"));
                    var cLabel= '$Label.c.'+component.get("v.subjLabelConstant");   
                    component.set("v.subjectLine", $A.getReference(cLabel));
                    console.log('SubjectLine ',$A.getReference(cLabel));
                }
                else if(allValues.CaseFields.Record_Type_Name_AGN__c == 'GDPR_Case' || allValues.CaseFields.Record_Type_Name_AGN__c == 'GDPR_DPO')
                {
                    console.log('DS Language GDPR'+lang3);

                    if(allValues.CaseFields.DS_Selected_Language_GDPR_AGN__c =='English')
                    {
                        component.set("v.dsmessage",$A.get("$Label.c.AGN_GDPR_Reject_Case_Message1") +' ' +$A.get("$Label.c.AGN_GDPR_Reject_Case_Message2") );
                        var cLabel= '$Label.c.'+component.get("v.subjLabelConstantgdpr");   
                        component.set("v.subjectLine", $A.getReference(cLabel));
                        console.log('SubjectLine ',$A.getReference(cLabel));
                    }
                    else          
                    {
                      
                        var msg1 = '$Label.c.'+component.get("v.customLabelConstant")+lang3+'1';
                       // var msg2 = '$Label.c.'+component.get("v.customLabelConstant")+lang3+'2';
					
                        component.set("v.dsmessage",$A.getReference(msg1));
                        //component.set("v.dsmessage2",$A.getReference(msg2));
                        
                         //component.set("v.dsmessage",component.get("v.dsmessage1")+' '+component.get("v.dsmessage2"));
                        
                        var cLabel= '$Label.c.'+component.get("v.subjLabelConstant")+lang3;   
                        component.set("v.subjectLine", $A.getReference(cLabel));
                        console.log('SubjectLine Other Lang ',$A.getReference(cLabel));
                    }
                    
                    
                }
                
                if (allValues.CaseFields.Rejection_Reason_AGN__c !='')
                {
                    component.set("v.rejsn",allValues.CaseFields.Rejection_Reason_AGN__c);
                }
                if (allValues.CaseFields.DS_Email_Body_AGN__c !=undefined)
                {
                    component.set("v.dsmessage",allValues.CaseFields.DS_Email_Body_AGN__c);
                }
                if (allValues.CaseFields.Rejection_Reason_Code_AGN__c !='')
                {
                    component.set("v.rejcod",allValues.CaseFields.Rejection_Reason_Code_AGN__c);	
                }
                if (allValues.CaseFields.Case_Creation_Channel_GDPR_AGN__c !='')
                {
                    component.set("v.comchnl",allValues.CaseFields.Case_Creation_Channel_GDPR_AGN__c);	
                } 
                if(allValues.cstatus=='Invalid Status')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:$A.get("$Label.c.AGN_GDPR_CaseCannotbeRejLabel"),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire() ; 
                }
                else if(allValues.cstatus=='Case Rejected')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: $A.get("$Label.c.AGN_GDPR_CaseAlreadyRejected"),
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire() ; 
                }
                    else
                    {  
                        if(allValues.comchanel =='Email')
                        {
                            component.set("v.chanelcheck",false);
                        }
                        component.set("v.render",true);
                        component.set("v.norender",false); 
                        
                        console.log('XXXX',allValues.comchanel);
                        
                        if (allValues.allOpts != undefined && allValues.allOpts.length > 0)
                        {
                            opts.push({
                                class: "optionClass",
                                label: "--- None ---",
                                value: "None"
                            });
                        }
                        
                        for (var i = 0; i < allValues.allOpts.length; i++) 
                        {
                            opts.push({
                                class: "optionClass",
                                label: allValues.allOpts[i],
                                value: allValues.allOpts[i]
                            });
                        }
                        component.find('pickId').set("v.options",opts);
                        
                        
                        opts1.push({
                            class: "optionClass",
                            label: allValues.comchanel,
                            value: allValues.comchanel
                        });
                        
                        component.find('pickId2').set("v.options",opts1);
                        
                    }
            }
        });
        $A.enqueueAction(action);
    },
    
    cancel: function(component, event, helper) 
    {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire() ;       
    },
    onChangeCode: function(component,event,helper)
    { 
        component.set("v.rejsn",'');
        var idstr = component.find('pickId'); 
        var val = idstr.get("v.value");
        if(val != 'None')
        {
            if(component.get("v.recordTypeName") == 'CCPA_Case' || component.get("v.recordTypeName") == 'Contact_Center_AGN')
            {
                component.set("v.codecheck",false);
            }
            else if(component.get("v.recordTypeName") == 'GDPR_Case' || component.get("v.recordTypeName") == 'GDPR_DPO')
            {
                component.set("v.codecheck",false);
            }
        }
        else
        {
            if(component.get("v.recordTypeName") == 'CCPA_Case' || component.get("v.recordTypeName") == 'Contact_Center_AGN')
            {
                component.set("v.codecheck",true);
                component.set("v.dsmessage",$A.get("$Label.c.AGN_CCPA_Reject_Case_Message")+ ' ');
                component.set("v.rejsn",'');
            }
            else if(component.get("v.recordTypeName") == 'GDPR_Case' || component.get("v.recordTypeName") == 'GDPR_DPO')
            {
                component.set("v.codecheck",true);
                component.set("v.rejsn",'');
            }  
        }
    },
    onChangeReason: function(component,event,helper)
    {
        if(component.get("v.recordTypeName") == 'CCPA_Case' || component.get("v.recordTypeName") == 'Contact_Center_AGN')
        {   
            var val1 ='';
            var idstr1 = component.find('rejreason'); 
            val1 = idstr1.get("v.value");
            component.set("v.dsmessage",$A.get("$Label.c.AGN_CCPA_Reject_Case_Message") + ' ' + val1 + '.');
            
        }
        else if(component.get("v.recordTypeName") == 'GDPR_Case' || component.get("v.recordTypeName") == 'GDPR_DPO')
        {
            
            var val1 ='';
            if(component.get("v.DSLang") == 'English')
            {
                component.set("v.dsmessage",$A.get("$Label.c.AGN_GDPR_Reject_Case_Message1"));
            }
            else          
            {
                var msg1 = '$Label.c.'+component.get("v.customLabelConstant")+component.get("v.DSLang")+'1';
                component.set("v.dsmessage",$A.get(msg1));
            }
            
            var idstr1 = component.find('rejreason'); 
            val1 = idstr1.get("v.value");
            var msg111 =component.get("v.dsmessage");
            
            console.log('Message for DS GDPR --> ',msg111);
            
            if(component.get("v.DSLang") =='English')
            {
                 component.set("v.dsmessage",msg111 +' '+ val1 +' '+ $A.get("$Label.c.AGN_GDPR_Reject_Case_Message2")); 
                 
            }
            else
            {
                var msg2 ='$Label.c.'+component.get("v.customLabelConstant")+component.get("v.DSLang")+'2';
                component.set("v.dsmessage",msg111 +' '+ val1 +' '+ $A.get(msg2)); 
            }
            
        }        
    },
    rejectCase: function(component, event, helper) 
    {
        var comch = component.find("pickId2");
        var cch = comch.get("v.value");
        var rjcd = component.find("pickId");
        var rejcode=  rjcd.get("v.value");
        var rjrc = component.find("rejreason").get("v.value");
        var msg= component.find("message").get("v.value");
        var chk = component.find("checkbox").get("v.value");

        if(rejcode =='None' || rjrc==undefined || msg ==undefined || rjrc==' ' || msg ==' ')
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:$A.get("$Label.c.AGN_GDPR_Mandatory_Fields"),
                duration:'800',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();  
        }
        else
        {
            var extem = component.get("c.getextemail");
            extem.setParams({
                "caseId":component.get("v.recordId"),
                "rejcode":rejcode,
                "rjrc":rjrc,
                "msg":msg,
                "chk":chk,
                "cch":cch,
                "SubjectLine":component.get("v.subjectLine")
            });  
            extem.setCallback(this, function(response){
                if (response.getState() == "SUCCESS")
                {
                    var res = response.getReturnValue();
                    console.log('External Email Response ',res);
                }
            });
            $A.enqueueAction(extem);  
            
            var pdfgenerate = component.get("c.pdfgenerate");
            pdfgenerate.setParams({
                "caseId":component.get("v.recordId")
            });
            pdfgenerate.setCallback(this, function(response){
                var res = response.getReturnValue();
                console.log('Attachment PDF Response',res);
            });
            
            $A.enqueueAction(pdfgenerate);   
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire() ;
           //last enhancement 
           helper.refreshpage();

           
        } 
    }, 
    
    Save: function(component, event, helper)
    {   
        var comch1 = component.find("pickId2");
        var cch1 = comch1.get("v.value");
        var rjcd1 = component.find("pickId");
        var rejcode1=  rjcd1.get("v.value");
        var rjrc1 = component.find("rejreason").get("v.value");
        var msg1= component.find("message").get("v.value");
        var chk1 = component.find("checkbox").get("v.value");
        console.log('subject line',component.get("v.subjectLine"));
    
        var extem1 = component.get("c.SaveRejectCaseInput");
        extem1.setParams({
            "caseId1":component.get("v.recordId"),
            "rejcode1":rejcode1,
            "rjrc1":rjrc1,
            "msg1":msg1,
            "chk1":chk1,
            "cch1":cch1,
            "SubjectLine":component.get("v.subjectLine")
        });  
        extem1.setCallback(this, function(response){
            if (response.getState() == "SUCCESS")
            {
                var res = response.getReturnValue();
                console.log('Input save response: ',res);
            }
        });
        $A.enqueueAction(extem1); 
        
       
        $A.get("e.force:closeQuickAction").fire() ;
         $A.get('e.force:refreshView').fire();
    }
})