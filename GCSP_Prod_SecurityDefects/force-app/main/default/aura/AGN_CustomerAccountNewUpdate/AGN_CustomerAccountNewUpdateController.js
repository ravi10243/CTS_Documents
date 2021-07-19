({
    init : function(component, event, helper) {
       // component.set("v.showSpinner", true);
        var addressId = helper.getParameterByName('addressId');
        var accountType = helper.getParameterByName('type');
        var activity= helper.getParameterByName('activity');
        component.set("v.activity", activity);
        console.log("====activity" +activity);
        if (accountType == 'SoldTo')
            component.set("v.type", 'Sold To');
        else if (accountType == 'ShipTo')
            component.set("v.type", 'Ship To');
        else if (accountType == 'BillTo')
            component.set("v.type", 'Bill To');
        
        var action = component.get("c.doInit");
        action.setParams({"addressId": addressId, "type": accountType});         
        action.setCallback(this, function(actionResult) {
        component.set("v.controller", actionResult.getReturnValue());   
            var setRegionAction = component.get("c.getRegionList");
        setRegionAction.setParams({"countryCode":component.get("v.controller.newRegistration.SAP_Country_Code_AGN__c")});
        console.log('[SAP_Country_Code_AGN__c]]'+ component.get("v.controller")); 
        setRegionAction.setCallback(this , function(result){
            var opts = result.getReturnValue();
            component.find("InputSelectState").set("v.options", opts);
        })
        $A.enqueueAction(setRegionAction);
        });
        $A.enqueueAction(action);   
        
        console.log("[State Code].[starting]"); 
        

    },
    scriptsLoaded : function(component, event, helper) {

        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },


    doneRendering : function(component,event, helper){
        jQuery.noConflict();
        /*console.log('Page loaded successfully :'+ jQuery('.findMyValue').html());*/
         console.log('Page loaded successfully2 :'+ component.get("v.caseDetail.CaseNumber"));
        jQuery('.input-identifier').each(function(){

            /*console.log("3:" + jQuery(this).attr("data-inputfiedlvalue"));
            console.log("4:"+ jQuery.trim(jQuery(this).attr("data-inputfiedlvalue")));*/

            if( jQuery(this).attr("data-inputfiedlvalue")== 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }           
            
        });
        
        //------------ Releae 14 Niladri -------- Sort Code format Start -----------------
        jQuery('.sort_code').each(function(){
             
             jQuery(this).keydown(function (e) {
                 var key = e.charCode || e.keyCode || 0;
                 var inputVar= jQuery(this); 
                 if (key !== 8 && key !== 9 && key !== 16) {
                     if (inputVar.val().length === 2) {
                         inputVar.val(inputVar.val() + '-');
                     } 
                     if (inputVar.val().length === 5) {
                         inputVar.val(inputVar.val() + '-');
                     }                                         
                 }                
                 return (key == 8 || key == 9 || key == 46 || (key >= 48 && key <= 57) || (key >= 96 && key <= 105));
             })    
         });
        //------------ Releae 14 Niladri -------- Sort Code format End -----------------
        
/*      // console.log('123--------'+jQuery(".basic_details").html());
        jQuery(".basic_details  ").slideUp(700);
        jQuery(".success_com").slideDown(1000);*/

        if(component.get("v.activity")=='delete'){

            jQuery('.input-identifier').each(function(){
                console.log(jQuery(this).find('input')[0]);
            });
        }

        if(component.get("v.caseDetail.CaseNumber")!='000000'){
            jQuery(".basic_details ").slideUp(1000);
            setTimeout(function(){jQuery(".success_com").slideDown(700); }, 1000);


        }
        
        jQuery('.file').change(function(){
            var fileInput = component.find("fileDoc").getElement();
            component.set("v.fileName", fileInput.files[0].name); 
        });

        //component.set("v.showSpinner", false);
    },
    
    saveRecord : function(component, event, helper) {
        var activity= component.get("v.activity");
        var isValidated = false
        //alert('1');
        if(activity== 'delete'){
            isValidated= true;
        }
        else{
            //alert('2');
            helper.validateAddressRequiredFields(component);
            if (component.get("v.fieldValidation")== true){
                isValidated=true;
            }            
        }
        
        
        //alert('3');
        

        var ctrl = component.get("v.controller");
        var address = ctrl.newAddress;
        var registration = ctrl.newRegistration;
        var activity= component.get("v.activity");
        var action = component.get("c.saveCustomerUpdate");
        if(isValidated){
            component.set("v.showSpinner", true);
            //alert('4');
            action.setParams({"newAddress": JSON.stringify(address), "newRegistration": JSON.stringify(registration) , "activity" : activity }); 
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();            
                component.set("v.showSpinner", false);
                if (state == "SUCCESS") {
                    //alert('5');
                    component.set("v.caseDetail", actionResult.getReturnValue());
                }
                else if (state == "ERROR") {
                    var errors = actionResult.getError();
                    console.log(errors);
                    throw new Error('An Error occurred while saving the Record.')
                    if (errors) {
                        errors.forEach( function (error){
                            if (error.fieldErrors){
                                error.fieldErrors.forEach( function(fieldError) {
                                    //alert("Error message: " + fieldError.message);                    
                                });
                            }
                        });
                    }
                }
                
                //console.log('fileInput--'+fileInput );
                //alert('You have successfully Saved the Account details. Thank You. You request reference is ' + actionResult.getReturnValue().CaseNumber); 
                if(activity!== 'delete'){
                    //alert('before file');
                    var fileInput = component.find("fileDoc").getElement();
                    //alert(fileInput);            
                    console.log("[FileUpload].[=====file=====]"+fileInput.files[0].name);
                    console.log("[FileUpload].[=====file type=====]"+typeof fileInput.files[0].name);
                    if (typeof fileInput.files[0].name !== "undefined" && fileInput.files[0].name!=='' ){           
                        helper.saveFile(component,fileInput);
                        console.log("[Dummy Method].[Calling]");
                        helper.callDummyMethod(component); // This is only required for file upload
                        console.log("[Dummy Method].[Called]");
                        //alert('after file');
                    }
                    component.set("v.showSpinner", false);
                }
            });
            $A.enqueueAction(action);     
        }
    },
    
    gotoHome : function (component, event, helper) {
        component.set("v.showSpinner", true);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/", "isredirect" : true
        });
        urlEvent.fire();

    },

    onChange : function(component){
        var dynamicCmp = component.find("InputSelectState");
        component.set("v.controller.newAddress.State_AGN__c", dynamicCmp.get("v.value"));
    }
})