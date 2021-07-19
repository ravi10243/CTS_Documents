({
    init : function(component, event, helper) {
        
       component.set("v.showSpinner", true);
        
        var addressId = helper.getParameterByName('addressId');
        var accountType = helper.getParameterByName('type');
        var activity= helper.getParameterByName('activity');
        
        var soldTo = $A.get("$Label.c.AGN_OAM_Body_Sold_To");
        component.set("v.soldTo", soldTo);
        
        var shipTo = $A.get("$Label.c.AGN_OAM_Body_Ship_To");
        component.set("v.shipTo", shipTo);
        
        var billTo= $A.get("$Label.c.AGN_OAM_Body_Bill_To");
        component.set("v.billTo", billTo);
        
        component.set("v.activity", activity);
        console.log("====activity" +activity);
        
        if (accountType == 'SoldTo')
            component.set("v.type",soldTo);
        
        else if (accountType == 'ShipTo') 
            component.set("v.type", shipTo );  
        
            else if (accountType == 'BillTo')
                component.set("v.type", billTo);
        
        var action = component.get("c.doInit");
        action.setParams({"addressId": addressId, "type": accountType});         
        action.setCallback(this, function(actionResult) {
            component.set("v.controller", actionResult.getReturnValue());
            
            //console.log('controller-->>>' + JSON.stringify(component.get("v.controller.config.Customer_Country_AGN__r.Alpha_2_Code_vod__c")));
            component.set("v.countryCode", component.get("v.controller.config.Country_Code_AGN__c"));
            component.set("v.SAPCountryCode", component.get("v.controller.config.Customer_Country_AGN__r.Alpha_2_Code_vod__c"));
            
            // console.log('cogh--->'+JSON.stringify(component.get("v.controller.config.Country_Code_AGN__c")) + JSON.stringify(component.get("v.controller.config"))); 
            
            helper.fetchCountrySettings(component, event); 
            if(component.get("v.type") === soldTo || component.get("v.type") === billTo){
                console.log('cal payment');
                helper.fetchPaymentSettingdetails(component, event);
            }
           /* if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") <= 0){
                helper.getPaymentMethodValues(component, event, helper); 
            } 
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") == null){
                helper.getPaymentTermValues(component, event, helper); 
            }
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm") != null && !$A.util.isEmpty(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c"))){
                component.set("v.PaymentTerm1",component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c"));
            } */
            
            if(component.get("v.type") === soldTo && component.get("v.controller.paymentMethod.Form_Of_Payment_Label_AGN__c") == null){
                //console.log('controller.paymentMethod' + JSON.stringify(component.get("v.controller.paymentMethod")));
                helper.getPaymentMethodValues(component, event, helper);                
            }
            
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c") == null){
                helper.getPaymentTermValues(component, event, helper); 
            }
            if(component.get("v.type") === soldTo && component.get("v.controller.custPayment.length") > 0 && component.get("v.controller.paymentTerm") != null && !$A.util.isEmpty(component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c"))){
                component.set("v.PaymentTerm1",component.get("v.controller.paymentTerm.SAP_Payment_Term_Code_AGN__c"));
            }
        });
        
        $A.enqueueAction(action);  
        console.log("[State Code].[starting]"); 
        
    },
    
    /* -------------- if Customer Payment is isNull ---------------- Start  */
    
    onChangePaymentMethod : function(component, event, helper){
        
        helper.onChangePaymentMethod(component, event, helper);
        
    }, 
    
    onChangePaymentTerm: function(component, event, helper){
        
        helper.onChangePaymentTerm(component, event, helper);
        
    },
    
    
    /* -------------- if Customer Payment is isNull ------------------ End  */
    
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  start  ---------*/
    onChangePaymentTermForCustPayment: function(component, event, helper){
        
        helper.onChangePaymentTermForCustPayment(component, event, helper);
        
    },
    
    /* --------------- if if Customer Payment Term is notNull and PaymentTerm is isNull --  end		  ---------*/
    
    
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },
    
    doneRendering : function(component,event, helper){
        
        //console.log("doneRendering");
        //jQuery.noConflict();
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
        jQuery('.Basic_det .infr_det').slideDown();
        jQuery('.no_det.active').css("border", "2px solid #a3d233");
        
        if(component.get("v.activity")=='delete'){
            
            jQuery('.input-identifier').each(function(){
                console.log(jQuery(this).find('input')[0]);
            });
        }
        
        if(component.get("v.caseDetail.CaseNumber")!='000000' ){
            jQuery(".basic_details ").slideUp(1000);            
            setTimeout(function(){jQuery(".success_com").slideDown(700); }, 1000);          
            $( "#here" ).load(window.location.href + " #here" );
        }
        
        jQuery('.file').change(function(){
            var fileInput = component.find("fileDoc").getElement();
            component.set("v.fileName", fileInput.files[0].name); 
        });
        //component.set("v.showSpinner", false);
    },
    
    saveRecord : function(component, event, helper) {
        
        helper.ValidateAndSaveAddressRecords(component, event);         
        
    },
    
    gotoHome : function (component, event, helper) {
        component.set("v.showSpinner", true);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/customerupdate", "isredirect" : true
        });
        urlEvent.fire();
        
    },
    
    onChange : function(component){
        var dynamicCmp = component.find("InputSelectState");
        component.set("v.controller.newAddress.State_AGN__c", dynamicCmp.get("v.value"));
    }
})