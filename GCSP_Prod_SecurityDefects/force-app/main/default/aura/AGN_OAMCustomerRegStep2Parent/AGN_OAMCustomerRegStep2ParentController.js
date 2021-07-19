({
    scriptsLoaded : function(component, event, helper) {
		jQuery.noConflict();
	},
    onNotifyRegStepChange : function(component, event, helper){
        var operation = event.getParam("Operation");  
        var stepNo = parseInt(event.getParam("StepNo"));
        console.log( stepNo +' ' + operation);
        if(operation === 'CANCEL'){
            
            switch(stepNo){
                    
                case 2:                   
                    //Address
                    var actualRegStep = parseInt(component.get("v.customer.Online_Registration_Step_AGN__c"));
                    component.set("v.currentRegStep", actualRegStep);
                    //jQuery('.add_det .infr_det').slideUp(500);
                    //jQuery('.no_det.active').css("border", "2px solid #a3d233");
                    //jQuery( ".add_det .edit_btn" ).show();
                    if(actualRegStep > 2){
                        component.set("v.currentRegStep", actualRegStep);
                    	//jQuery( ".add_det .divider" ).hide();
                        jQuery( ".add_det .infr_det" ).slideUp(500);
                        jQuery( ".add_det .divider" ).slideUp();
                        jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                        jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
                        //jQuery( ".add_det .no_det span" ).hide();
                        jQuery( ".add_det .no_det img" ).show();                
                        jQuery( ".add_det .edit_btn" ).show();
                    }
                    //else{
                        //jQuery( ".add_det .divider" ).show();
                    //}
                    break;
                    
                case 3:
                    //Documents
                    var actualRegStep = parseInt(component.get("v.customer.Online_Registration_Step_AGN__c"));
                    component.set("v.currentRegStep", actualRegStep);
                    //jQuery('.upload_doc .infr_det').slideUp(500);
                    //jQuery('.upload_doc.active').css("border", "2px solid #a3d233");
                    //jQuery( ".upload_doc .edit_btn" ).show();
                    if(actualRegStep > 3){             
                        jQuery('.upload_doc .infr_det').slideUp(500);
                        jQuery( ".upload_doc .divider" ).slideUp();
                        jQuery( ".upload_doc .no_det").css("background", "#a3d233");
                        jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                        jQuery( ".upload_doc .no_det img" ).show();
                        jQuery( ".upload_doc .edit_btn" ).show();
                    }
                    else{
                        //jQuery( ".upload_doc .divider" ).show();
                    }
                    break;            
            }
        }
        else if(operation === 'UPDATE'){
            component.set("v.currentRegStep", stepNo);
            
        }
            else if(operation === 'FINISH'){
                component.set("v.currentRegStep", stepNo);
                jQuery('.basic_detail .no_det span').hide();
                jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                jQuery( ".basic_detail .no_det img.tick" ).show();
                jQuery( '.cus_details').hide();
                jQuery( ".add_det .no_det span" ).hide();
                jQuery( ".add_det .no_det img.tick" ).show();
                jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".add_det .divider" ).hide();
                jQuery( ".add_det .infr_det" ).hide();
                jQuery( ".upload_doc" ).css("margin-top", "30px");
                jQuery( ".upload_doc .no_det span" ).hide();
                jQuery( ".upload_doc .no_det img.tick" ).show();
                jQuery( '.upload_doc .no_det').css("background", "#a3d233");
                jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".upload_doc .divider" ).hide();
                jQuery( ".upload_doc .infr_det" ).hide();
                
                jQuery( ".payment" ).css("margin-top", "30px");
                jQuery( '.payment .no_det span').hide();
                jQuery( ".payment .divider" ).hide();
                jQuery( ".payment .no_det img.tick" ).show();
                jQuery( ".payment .no_det" ).css("background", "#a3d233");
                jQuery( ".payment .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".payment .infr_details" ).hide();
                jQuery( ".add_det .edit_btn" ).hide();
                jQuery( ".upload_doc .edit_btn" ).hide();
                jQuery( ".payment .edit_btn" ).hide();
                jQuery('.com_fully').slideDown();
                jQuery(".basic_details li" ).css("float", "left");
            }
    },
    
    doneRendering : function(component,event, helper){       
        jQuery.noConflict();
        var regStepNo = parseInt(component.get("v.currentRegStep"));
        var actualRegStep = parseInt(component.get("v.customer.Online_Registration_Step_AGN__c"));
        //var regStepNo = "4";
        console.log('regStepNo ====> '+ regStepNo);
        
        
        switch(regStepNo){
                
            case 2:
                
                //jQuery( ".basic_detail .no_det span" ).hide();
                jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".basic_detail .no_det img" ).show();
                
                
                //jQuery( ".upload_doc .no_det img" ).hide();
                //jQuery( ".payment .no_det img" ).hide();
                
                jQuery( ".upload_doc .infr_det" ).slideUp(1000);                
                jQuery( ".upload_doc .divider" ).slideUp(); 
                if(actualRegStep>=3){
                    jQuery( ".upload_doc .edit_btn" ).show();
                }
                else{
                    jQuery( ".upload_doc .edit_btn" ).hide();
                }
                
				jQuery( ".payment .divider" ).slideUp();
                if(actualRegStep<4){
                    jQuery( ".payment .edit_btn" ).hide();
                }
                else{
                    jQuery( ".payment .edit_btn" ).show();
                }
                
                jQuery( ".add_det .divider" ).slideDown();                
                setTimeout(function(){
                    jQuery( ".add_det .infr_det" ).slideDown(1000);                    
                },1000);
                jQuery( ".add_det .no_det" ).css("background", "#ffffff");
                jQuery( ".add_det .no_det").css("border", "2px solid #a3d233");            
                
                
                break;
                
            case 3:
                
                //jQuery( ".basic_detail .no_det span" ).hide();
                jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                //jQuery( ".basic_detail .no_det img" ).show();
                
                jQuery( ".add_det .infr_det" ).slideUp(500);
                jQuery( ".add_det .divider" ).slideUp();
                jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
                //jQuery( ".add_det .no_det span" ).hide();
                jQuery( ".add_det .no_det img" ).show();                
                jQuery( ".add_det .edit_btn" ).show();
                
                //jQuery( ".payment .no_det .tick" ).show();
                jQuery( ".payment .infr_det").slideUp(500);
                jQuery( ".payment .divider" ).slideUp();
                if(actualRegStep<4){
                    jQuery( ".payment .edit_btn" ).hide();
                }
                else{
                    jQuery( ".payment .edit_btn" ).show();
                }
                    
                
                //jQuery( ".upload_doc" ).css("margin-top", "30px");
                //jQuery( ".upload_doc" ).css("position", "relative");
                //jQuery( ".upload_doc" ).css("float", "left");
                //jQuery( ".infr_details" ).show(); 
                //jQuery( ".upload_doc .no_det img" ).hide();
                //jQuery( ".upload_doc .no_det span" ).show();
                jQuery( ".upload_doc .divider" ).slideDown();
                setTimeout(function(){
                    jQuery('.upload_doc .infr_det').slideDown(1000);
                },1000);
                jQuery( ".upload_doc .no_det" ).css("background", "#ffffff");
                jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".upload_doc .edit_btn" ).hide();               
                
                
                break;
                
            case 4:
                
                //jQuery( ".basic_detail .no_det span" ).hide();
                jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".basic_detail .no_det img" ).show();
                
                jQuery( ".add_det .infr_det" ).slideUp(500);
                jQuery( ".add_det .divider" ).slideUp();
                jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
               // jQuery( ".add_det .no_det span" ).hide();
                jQuery( ".add_det .no_det img" ).show();
                jQuery( ".add_det .edit_btn" ).show();
                                                               
                //jQuery( ".infr_details" ).show();                
                jQuery('.upload_doc .infr_det').slideUp(500);
                jQuery( ".upload_doc .divider" ).slideUp();
                jQuery( ".upload_doc .no_det").css("background", "#a3d233");
                jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                //jQuery( ".upload_doc" ).css("margin-top", "30px");
                //jQuery( ".upload_doc" ).css("position", "relative");
                //jQuery( ".upload_doc .no_det span" ).hide();
                jQuery( ".upload_doc .no_det img" ).show();
                jQuery( ".upload_doc .edit_btn" ).show();
                
                //jQuery( ".payment" ).css("margin-top", "30px");
                //jQuery( ".payment" ).css("position", "relative");
                //jQuery( ".payment" ).css("float", "left");  
                //jQuery('.upload_doc .no_det span').hide();
                //jQuery( ".infr_details" ).show();
                
                
                jQuery( ".payment .no_det img" ).hide();
                jQuery( ".payment .divider" ).slideDown();
                setTimeout(function(){
                    jQuery('.payment .infr_det').slideDown(1000);                    
                },1000);
                //jQuery( ".upload_doc .no_det img.tick" ).show();
                jQuery( ".payment .no_det" ).css("background", "#ffffff");
                jQuery( ".payment .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".payment .edit_btn" ).hide();
                
                break;
                
            case 5:
                
                jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".basic_detail .no_det img" ).show();
                
                jQuery( ".add_det .infr_det" ).slideUp(500);
                jQuery( ".add_det .divider" ).slideUp();
                jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
               // jQuery( ".add_det .no_det span" ).hide();
                jQuery( ".add_det .no_det img" ).show();
                jQuery( ".add_det .edit_btn" ).show();
                                                               
                //jQuery( ".infr_details" ).show();                
                jQuery('.upload_doc .infr_det').slideUp(500);
                jQuery( ".upload_doc .divider" ).slideUp();
                jQuery( ".upload_doc .no_det").css("background", "#a3d233");
                jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                //jQuery( ".upload_doc" ).css("margin-top", "30px");
                //jQuery( ".upload_doc" ).css("position", "relative");
                //jQuery( ".upload_doc .no_det span" ).hide();
                jQuery( ".upload_doc .no_det img" ).show();
                jQuery( ".upload_doc .edit_btn" ).show();
                
                
                
                jQuery( '.cus_details').hide();

                jQuery( ".payment .no_det img" ).show();
                jQuery( ".payment .no_det" ).css("background", "#a3d233");
                jQuery( ".payment .no_det" ).css("border", "2px solid #a3d233");
                jQuery( ".payment .infr_details" ).slideUp();
                jQuery( ".payment .divider" ).slideUp();

				jQuery( ".add_det .edit_btn" ).hide();
                jQuery( ".upload_doc .edit_btn" ).hide();
                jQuery( ".payment .edit_btn" ).hide();

                jQuery('.com_fully').slideDown();
                //jQuery(".basic_details li" ).css("float", "left");
                
                break;
        }
        
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        }); 
        
    }, 
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    editAddress : function(component,event, helper){
        var actualRegStep = parseInt(component.get("v.customer.Online_Registration_Step_AGN__c"));
        component.set("v.currentRegStep",2);
        jQuery('.add_det .infr_det').slideDown();
        //jQuery('.upload_doc .infr_det').slideUp();       
        jQuery( ".add_det .edit_btn" ).hide();
        
        if(actualRegStep >= 3){
            jQuery( ".upload_doc .edit_btn" ).show();
            //jQuery( ".upload_doc .divider" ).hide();
        }
        
        if(actualRegStep >= 4){
            jQuery( ".payment .edit_btn" ).show();
            //jQuery( ".payment .divider" ).hide();
        }
    },
    editDocs : function(component,event, helper){
        var actualRegStep = parseInt(component.get("v.customer.Online_Registration_Step_AGN__c"));
        component.set("v.currentRegStep",3);
        jQuery('.upload_doc .infr_det').slideDown();        
        jQuery( ".upload_doc .edit_btn" ).hide();
        
        if(actualRegStep >= 4){
            jQuery( ".payment .edit_btn" ).show();
            jQuery( ".payment .divider" ).hide();
        }
    },
    editPayment : function(component,event, helper){
        component.set("v.currentRegStep",4);
        jQuery('.payment .infr_det').slideDown();        
        jQuery( ".payment .edit_btn" ).hide();
    },
    doInit : function(component, event, helper) {
    
         console.log('@@@Language>>>>>>>'+$A.get("$Locale.language"));
        component.set("v.language",$A.get("$Locale.language"));
        
        var action = component.get("c.getCustomerRegDetails");
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
          //  console.log('response--->'+state);
            try{
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();  
               // console.log(JSON.stringify(storeResponse));
                component.set("v.customer", storeResponse);
                component.set("v.currentRegStep", parseInt(component.get("v.customer.Online_Registration_Step_AGN__c")));
                //component.set("v.currentRegStep", parseInt(component.get("v.customer.Online_Registration_Step_AGN__c")));
                //component.set("v.currentRegStep", '4');
            }
            }
            catch(err){
                console.log('error--> '+err.message);
            }
        });
        $A.enqueueAction(action);
        
        var configAction = component.get("c.getCustomertypeConfigDetails");        
        configAction.setCallback(this, function(response) {            
            var state = response.getState();           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();  
               // console.log(JSON.stringify(storeResponse));
                component.set("v.custConfig", storeResponse);
            }            
        });
        $A.enqueueAction(configAction);
    },
    
    onSubmitAddress : function(component, event, helper){
        var eventParam = event.getParam("formDataCCSu_Type");  
        
        var custRegID = eventParam.custRegID;
        
        var formStep3 = component.find("formStep3");
        
        formStep3.displayFormStep3(custRegID);
    },
    
    logInAD : function(component, event, helper){
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":'https://development-nab2b-allergan.demandware.net/on/demandware.store/Sites-algb2b-de-Site/en_US/SAML-Login'
        });
        urlEvent.fire();
        */
        
        var url = "https://development-nab2b-allergan.demandware.net/on/demandware.store/Sites-algb2b-us-Site/en_US/SAML-Login";
        /*try{
            var data = {};
            data.login = "submitted";
            data.original  = "avijit_DE@sharklasers.com";
            var json = JSON.stringify(data);
            
            var xhr = new XMLHttpRequest();
            xhr.open("POST", url, true);
            xhr.setRequestHeader('Content-type','application/json; charset=utf-8');
            xhr.onload = function () {
                var resp = JSON.parse(xhr.responseText);
                if (xhr.readyState == 4 && xhr.status == "200") {
                    console.log(resp);
                } else {
                    console.error(resp);
                }
            }
            xhr.send(json);
        }
        catch(err){
            console.log(err.message);
        }
        */
        
        jQuery.ajax({
            type: 'POST',
            crossOrigin: true,
            url: url,
            dataType: 'json',
            cache :false,
            data : {"login":"submitted","original":"avijit_DE@sharklasers.com"},
            success : function (data) {
                alert(data);
            },
            error : function (data, errorThrown, status) {
                alert(JSON.stringify(data) + ' status ' + errorThrown);
            }
        });
    }
})