({	
    doInit : function(component, event, helper){
 
        console.log('inside doinit');
        var recordId3 = component.get("v.recordId");
        var action = component.get("c.getbooleanAttribute");
        console.log('sfda'+recordId3);
        action.setParams({"recordId" : recordId3});
        action.setCallback(this, function(response){
            console.log('STate@@@'+response.getState());
            console.log('state');
            if(response.getState() === "SUCCESS"){
                console.log('state');
                var listVariables = response.getReturnValue();
                console.log('@@@@list',listVariables);
                var listLength = listVariables.length;
        //        console.log('length '+listLength);
                component.set("v.ProcessAGN",listVariables[0]);
                var processAGN = component.get("v.ProcessAGN");
         //       console.log('processAGN '+processAGN);
                
                component.set("v.hasSAPIdForAllAdrs",listVariables[1]);
         //       var hasSAPIdForAllAdrs = component.get("v.hasSAPIdForAllAdrs");
         //       console.log('hasSAPIdForAllAdrs '+hasSAPIdForAllAdrs);
                component.set("v.hasEnableportalUserAllContacts",listVariables[2]);
         //       var hasEnableportalUserAllContacts = component.get("v.hasEnableportalUserAllContacts");
         //       console.log('hasEnableportalUserAllContacts '+hasEnableportalUserAllContacts);
                component.set("v.customerPortalBtnDisabled",listVariables[3]);
         //       var customerPortalBtnDisabled = component.get("v.customerPortalBtnDisabled");
         //       console.log('customerPortalBtnDisabled '+customerPortalBtnDisabled);
                component.set("v.showSendSAPBtn",listVariables[4]);
         //       var showSendSAPBtn = component.get("v.showSendSAPBtn");
          //      console.log('showSendSAPBtn '+showSendSAPBtn);
                component.set("v.sendToSAPBtnDisabled", listVariables[5]);
          //      var sendToSAPBtnDisabled = component.get("v.sendToSAPBtnDisabled");
          //      console.log('sendToSAPBtnDisabled '+sendToSAPBtnDisabled);
                component.set("v.ProcessBtnDisabled", listVariables[6]);
           //     var ProcessBtnDisabled = component.get("v.ProcessBtnDisabled");
           //     console.log('ProcessBtnDisabled '+ProcessBtnDisabled);
                component.set("v.showExtDataBtn", listVariables[7]);
           //     var showExtDataBtn = component.get("v.showExtDataBtn");
           //     console.log('showExtDataBtn '+showExtDataBtn);
                component.set("v.ExtDataBtnDisabled", listVariables[8]);
              //  var ExtDataBtnDisabled = component.get("v.ExtDataBtnDisabled");
              //  console.log('ExtDataBtnDisabled '+ExtDataBtnDisabled);
            }
        })
        $A.enqueueAction(action);  
        // console.log('process'+listVariables[0]);
    }, 
    callSendToSAP : function(component, event, helper) {
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
                    if (confirm(sendSAPDataMsg)) { //'Do you want to send the data to SAP ?click OK to send else cancel'
                        //   btnid.disabled = '{! v.objSerController.sendToSAPBtnDisabled}';
                        var action1 = component.get('c.sendtosap');
                        var recordId2 = component.get("v.recordId");
                        action1.setParams({"registrationId" : recordId2});
                        action1.setCallback(this, function(res){
                            if(res.getState()==="SUCCESS"){
                                console.log('state in customerPortal METHOD 2@@@@@ '+res.getState());
                                var responseMap = res.getReturnValue();
                                var successMsg = responseMap.SUCCESS;
                                var errorMsg = responseMap.ERROR;
                                if(successMsg!='') {
                                    component.set("v.successMsg",successMsg);
                                    component.set("v.refreshRequired",true);
                                    component.set("v.showLoader",false);
                                }
                                else if(errorMsg!='') {
                                    component.set("v.errorMsg",errorMsg);
                                    component.set("v.refreshRequired",true);
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
                    }
                    else {
                        component.set("v.showLoader",false);
                    }
                }
                
                else{            
                    alert($A.get("$Label.c.AGN_OAM_SAPIDExistsAllAddresses"));//'SAP ID exists for all addresses'
                }
            }
            else{}
        }
                          )
        $A.enqueueAction(action);
    },
    
    callProcess : function(component, event, helper){
        component.set("v.showLoader",true);
        var isdisable = false;
        console.log("inside callProcess function");
        var action = component.get('c.disableSendButton');
        action.setParams({'disable' : 'true'});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var btnid = component.find("prcsBtnID").get("v.aura:id");
                btnid.disabled = component.get("v.sendToSAPBtnDisabled");
            }
            else{}
        })
        console.log("outside disbalesendbutton function");
        var ProcessAGN = component.get("v.ProcessAGN");
        console.log('processagn@@@'+ProcessAGN);
        var ProceessRecardmsg =   $A.get("$Label.c.AGN_OAM_ProcessTheRecord");
        if(ProcessAGN === false){ 
            if (confirm(ProceessRecardmsg)) { 
                console.log('dsf3255');
                var action1 = component.get('c.processCase');
                console.log('inside apex method');
                var recordId2 = component.get("v.recordId");
                action1.setParams({"registrationId" : recordId2});
                console.log('recordid  process @@@@'+recordId2);
                
                action1.setCallback(this, function(res){
                    if(res.getState()==="SUCCESS"){
                        console.log('state in customerPortal METHOD 2@@@@@ '+res.getState());
                        var responseMap = res.getReturnValue();
                        var successMsg = responseMap.SUCCESS;
                        var errorMsg = responseMap.ERROR;
                        if(successMsg!='') {
                            component.set("v.successMsg",successMsg);
                            component.set("v.refreshRequired",true);
                            component.set("v.showLoader",false);
                        }
                        else if(errorMsg!='') {
                            component.set("v.errorMsg",errorMsg);
                            component.set("v.refreshRequired",true);
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
            }
            else {
                component.set("v.showLoader",false);
            }
        }
        
        else{       
            
            alert($A.get("$Label.c.AGN_OAM_TheRecordAlreadyProcessed"));//'This record is already processed'
        }
    },
    
    callSendToOkta : function(component, event, helper) {
        component.set("v.showLoader",true);
        var EnableCustomerportalUser = component.get("v.hasEnableportalUserAllContacts");
        
        if(EnableCustomerportalUser === true){
            console.log('EnableCustomerportalUser@@@'+EnableCustomerportalUser);
            var sendOktaDataMsg = $A.get("$Label.c.AGN_OAM_SendTheDataToOkta");
            if (confirm(sendOktaDataMsg)) { //'Do you want to send the data to Okta ?click Ok to send else cancel'
                var action = component.get('c.customerPortalApex');
                var recordId3 = component.get("v.recordId");
                action.setParams({"registrationId" : recordId3});
                console.log('recordid  process @@@@'+recordId3);
                action.setCallback(this, function(res){
                    if(res.getState()==="SUCCESS"){
                        console.log('state in customerPortal METHOD 2@@@@@ '+res.getState());
                        var responseMap = res.getReturnValue();
                        var successMsg = responseMap.SUCCESS;
                        var errorMsg = responseMap.ERROR;
                        if(successMsg!='') {
                            component.set("v.successMsg",successMsg);
                            component.set("v.refreshRequired",true);
                            component.set("v.showLoader",false);
                        }
                        else if(errorMsg!='') {
                            component.set("v.errorMsg",errorMsg);
                            component.set("v.refreshRequired",true);
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
                $A.enqueueAction(action);
            }
            else {
                component.set("v.showLoader",false);
            }
        }     
        
    },
    
    pageRefresh : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        component.set("v.errorMsg",null);
        component.set("v.successMsg",null);
        component.set("v.refreshRequired",false);
        var action = component.get('c.doInit');
        $A.enqueueAction(action);
    },
    
    downloadExcel : function(component, event, helper) {

     //   helper.loadFieldsList(component, event);
        helper.callExtractData(component, event, helper);
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
                     var stockData = component.get("v.ListofFields");
                   //  console.log('stockData ', stockData);
        var csv = helper.convertFieldsListToCSV(component,stockData); 
       // console.log('listoffieldsin js @@'+component.get("v.ListofFields"));
        if (csv == null){return;} 
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/xlsx;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self'; 
        var fileName = stockData[0]['Parent_AGN__r']['Name']+'_'+stockData[0]['Parent_AGN__r']['First_Name_AGN__c']+'_'+stockData[0]['Parent_AGN__r']['Last_Name_AGN__c']+'.csv'
        hiddenElement.download = fileName;  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();   
        component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction(action);
    }
})