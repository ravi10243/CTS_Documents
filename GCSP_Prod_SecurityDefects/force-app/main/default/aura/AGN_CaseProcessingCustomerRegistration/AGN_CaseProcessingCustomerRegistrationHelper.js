({	    /*        loadFieldsList: function(component, event) {
            var recordId = component.get("v.recordId");
            //   console.log('record id in helper' + recordId);
            var action = component.get('c.createExcel');
            action.setParams({'recordId' : recordId});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    //console.log('stateinhelper@@ '+state);
                    component.set('v.ListofFields', response.getReturnValue());
                    console.log('listoffieldsin helper @@',component.get("v.ListofFields"));
                }
            });
            $A.enqueueAction(action);
        }, 
        */
            callExtractData : function(component, event, helper) {
                component.set("v.showLoader",true);
                //  console.log('sapId '+SAPIDValue);
                var isdisable = false;
                console.log("inside callSend2SAPMethod");
                var action = component.get('c.disableSendButton');
                console.log('dfssfsdfsdfhaskf');
                action.setParams({'disable' : 'true'});
                action.setCallback(this, function(response) {
                    if(response.getState() === "SUCCESS") {
                        console.log('state in sendtosap@@@@@ '+response.getState());
                        var btnid = component.find("sapBtnID").get("v.aura:id");
                        //    btnid.disabled = "{!v.objSerController.sendToSAPBtnDisabled}";
                        var SAPIDValue =component.get("v.hasSAPIdForAllAdrs");
                        
                        console.log('sapidvalue '+SAPIDValue);
                        
                        if(SAPIDValue=== false){
                            var sendSAPDataMsg =$A.get("$Label.c.AGN_OAM_SendTheDataToSAP");
                            console.log('alert msg'+sendSAPDataMsg);
                            //     if (confirm(sendSAPDataMsg)) { //'Do you want to send the data to SAP ?click OK to send else cancel'
                            //   btnid.disabled = '{! v.objSerController.sendToSAPBtnDisabled}';
                            var action1 = component.get('c.sendtosap');
                            var recordId2 = component.get("v.recordId");
                            action1.setParams({"registrationId" : recordId2});
                            action1.setCallback(this, function(res){
                                if(res.getState()==="SUCCESS"){
                                    console.log('state in customerPortal METHOD 2@@@@@ '+res.getState());
                                    var responseMap = res.getReturnValue();
                                    //     var successMsg = responseMap.SUCCESS;
                                    var errorMsg = responseMap.ERROR;
                                    //          if(successMsg!='') {
                                    //            component.set("v.successMsg",successMsg);
                                    //          component.set("v.refreshRequired",true);
                                    //        component.set("v.showLoader",false);
                                    // }
                                    if(errorMsg!=='') {
                                        component.set("v.errorMsg",errorMsg);
                                        component.set("v.refreshRequired",true);
                                        component.set("v.showLoader",false);
                                    }
                                    else if(errorMsg === null){
                                        component.set("v.showLoader",false);
                                    }
                                }
                                else if (res.getState() === "ERROR") {
                                    var errors = res.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            component.set("v.errorMsg",errors[0].message);
                                            component.set("v.refreshRequired",true);
                                            component.set("v.showLoader",false);
                                        }
                                    } else {
                                        console.log("Unknown error");
                                    }
                                }
                            }) 
                            $A.enqueueAction(action1);
                            // }
                            //   else {
                            //     component.set("v.showLoader",false);
                            //}
                        }
                        
                        else{            
                            //alert($A.get("$Label.c.AGN_OAM_SAPIDExistsAllAddresses"));//'SAP ID exists for all addresses'
                        }
                    }
                    else{}
                }
                                  )
                $A.enqueueAction(action);
            },
                convertFieldsListToCSV : function(component,objectRecords){
                    // this.loadFieldsList(component, event);
                    
                    // loadFieldsList(component, event);
                    var columnHeader,csvStringResult, counter, keys, columnDivider, lineDivider;
                    columnHeader = ["Name","Reference Account","Name1","Name2","Name3","Search Term 1","Street","City postal code",
                                    "City","Telephone no.","Fax number","E-Mail Address","Customer group","Terms of Payment","Payment Method","Customer group 1","Customer group 2",
                                    "Doctor's First Name","Sold To","Ship To","Bill To","SAP Account Group",
                                    "VAT Number","BIC Code","SAP Id","SAP Referenced Customer ID","Record Type","State License Number",
                                    "CoolSculpting Machine","Article 23 relevance"];
                    keys = ['Name','Account_AGN__c','SAP_Name_1_AGN__c','SAP_Name_2_AGN__c','SAP_Name_3_AGN__c', 
                            'SAP_Search_Term_1_AGN__c','Address_Line_1_AGN__c','Zip_AGN__c','City_AGN__c','Phone_AGN__c','Fax_AGN__c',
                            'Email_AGN__c','Customer_Group_AGN__c','Payment_Term_AGN__c','Form_Of_Payment_AGN__c','Customer_group_1_AGN__c','Customer_group_2_AGN__c',
                            'Doctors_First_Name_AGN__c','Sold_To_AGN__c','Ship_To_AGN__c','Bill_To_AGN__c',
                            'SAP_Account_Group_AGN__c','VAT_Number_AGN__c','SWIFT_BIC_AGN__c','SAP_ID_AGN__c','SAP_Referenced_Customer_ID_AGN__c',
                            'RecordType','State_License_Number_AGN__c','Coolsculpting_Machine_AGN__c',
                            'KB23_Article_AGN__c'];
                    
                    
                    if (objectRecords == null || !objectRecords.length) {
                        return null;
                    }
                    
                    columnDivider = ',';
                    lineDivider =  '\n';
                    csvStringResult = "";
                    csvStringResult += columnHeader.join(columnDivider);
                    csvStringResult += lineDivider;
                    
                    for(var i=0; i < objectRecords.length; i++){   
                        counter = 0;
                        
                        for(var sTempkey in keys) {
                            var skey = keys[sTempkey] ;  
                            
                            console.log('key ',skey);   
                            if(counter > 0){ 
                                csvStringResult += columnDivider; 
                                
                            }
                            
                            
                            if(objectRecords[i][skey]!== null && objectRecords[i][skey]	!== undefined){
                                if(skey == 'Account_AGN__c'){
                                    csvStringResult += '"'+ objectRecords[i]['Account_AGN__r']['Name']+'"';  
                                }else if(skey== 'Form_Of_Payment_AGN__c'){
                                    csvStringResult += '"'+ objectRecords[i]['Form_Of_Payment_AGN__r']['SAP_Code_AGN__c']+'"'; 
                                }else if(skey=='Payment_Term_AGN__c'){
                                    csvStringResult += '"'+ objectRecords[i]['Payment_Term_AGN__r']['Name']+'"';
                                }else if(skey=='RecordType'){
                                    csvStringResult += '"'+ objectRecords[i]['RecordType']['Name']+'"';
                                }else {
                                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                                }
                                
                                
                            }
                            else {csvStringResult += '""';}
                            counter++;
                            
                        } 
                        csvStringResult += lineDivider;
                        
                    }
                    return csvStringResult;        
                }
     })