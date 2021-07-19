({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        //jQuery.noConflict();
        
    },   
    
   
    doInit : function(component, event, helper) {
        console.log("inside doinit");
        
       
        //fetching terms and condition
        helper.fetchFooterConsents(component, event);
        
        //jQuery.noConflict();
        //communityBaseURL + v.communitySuffix
        var vfOrigin = '';//"https://gcspeudev-allergancommunityeu.cs84.force.com";      
        
        var action = component.get('c.getCummunityURL');
        
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var commuUrl = response.getReturnValue();
                console.log(commuUrl);
                component.set("v.communityBaseURL",commuUrl[0]);
                component.set("v.communitySuffix",commuUrl[1]);
                vfOrigin = commuUrl[0];
            }
        });
        $A.enqueueAction(action);
        
        window.addEventListener("message", function(event) {
            console.log(event.data.action);
            console.log(event.data.alohaResponseCAPTCHA);
            console.log(event.origin);
            if (event.origin !== vfOrigin) {
                //alert('Not the expected origin: Reject the message!');
                return;
            }
            
            if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK'){
                //alert('Please do the captcha before submit!');
                component.set("v.isCaptchaValid", false);
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK'){
                console.log("Captcha Success1");
               	//var recaptchaCmp = component.find("openModal");
                $A.util.addClass(component.find("openModal"), 'captcha-hide');
                component.set("v.isCaptchaValid", true);
               	jQuery('.modalDialog').addClass("captcha-hide");
                console.log("Captcha Success2");
               // document.getElementById(‘test’).style.display = ‘none’;
            }
        }, false);
        
    },
    
    actionTCAccept: function(component, event){
        component.set("v.isTCAccepted", false);
        jQuery('.GDPRConsent').fadeIn('fast');
        jQuery('body').css({'position':'fixed','width':'100%'});
        
    },
    
    tcAccept : function(component,event, helper){
        component.set("v.isTCAccepted", true);
        jQuery('.GDPRConsent').fadeOut('fast');
        jQuery('body').css({'position':'','width':''});
    },
    tcCancel : function(component,event, helper){
        component.set("v.isTCAccepted", false);
        jQuery('.GDPRConsent').fadeOut('fast');
        jQuery('body').css({'position':'','width':''});
    },
    
    doneRendering : function(component,event, helper){
        jQuery.noConflict();
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
        
        /*jQuery('.slds-checkbox_faux').click(function(e){
            e.preventDefault();
            jQuery('.GDPRConsent').show();
            jQuery('body').css('overflow', 'hidden');
        });
        jQuery('.slds-button_brand').click(function(e){
            e.preventDefault();
            jQuery('.GDPRConsent').hide();
            jQuery('body').css('overflow', 'auto');
            jQuery('.slds-checkbox input[type=checkbox]').attr('checked',true);
            
        });
        jQuery('.slds-button_neutral').click(function(e){
            e.preventDefault();
            jQuery('.GDPRConsent').hide();
            jQuery('body').css('overflow', 'auto');
            if(('.slds-checkbox input[type=checkbox]').prop('checked')==true){
                jQuery('.slds-checkbox input[type=checkbox]').attr('checked',true);
            }else{
                jQuery('.slds-checkbox input[type=checkbox]').attr('checked',false);
            }
        });*/
        console.log('doneRendering');
        //jQuery('.Basic_det .infr_det').slideDown();
        //jQuery('.no_det.active').css("border", "2px solid #a3d233");
    },
    
    showForm: function(component, event, helper){
        //helper.makeEmptyValue(component, event);
        
        var params = event.getParam('arguments');
        
        //console.log(JSON.stringify(params.countryOptions));
        
        if(params && !$A.util.isEmpty(params.countryCode) 
           && !$A.util.isEmpty(params.customerType) 
           && !$A.util.isEmpty(params.customerSubType)){
            
            //IE GB fix
            console.log('params.countryCode--' + params.countryCode);
            if(params.countryCode.toUpperCase()==='IE'){
                component.set("v.CountryCode", 'GB');
                component.set("v.SAPCountryCode", 'IE');
            }
            else{
            	component.set("v.CountryCode", params.countryCode);    
                component.set("v.SAPCountryCode", params.countryCode);
            }
            component.set("v.selectedCountryCode", params.countryCode);
            component.set("v.selectedCustomerType", params.customerType);
            component.set("v.selectedCustomerSubType", params.customerSubType);
            component.set("v.countryOptions", params.countryOptions);
            component.set("v.customerTypeConfig", params.customerTypeConfig);
            //console.log('config :>>>>> '+JSON.stringify(params.customerTypeConfig));
            component.set("v.sectionHeaderMap", {});
            //fetching layouts from custom metadata config
            helper.fetchCountrySettings(component, event);
            
            
             /* for get ES customer group -- start*/  
            if(component.get("v.selectedCountryCode") === 'ES'){
                 var action = component.get("c.getCustomerGroup");
            action.setParams({
                'countryCode' : component.get("v.selectedCountryCode"),
                'customerType': component.get("v.selectedCustomerType"),
                'customerSubType': component.get("v.selectedCustomerSubType")
            }); 
            action.setCallback(this, function(response) {            
                if(response.getState() === 'SUCCESS') {
                    //alert(response.getReturnValue());
                    component.set("v.customerGroup",response.getReturnValue());
                } else {
                    this.logActionErrors(component, response);
                }
            });
            $A.enqueueAction(action);
            }
           
            /* for get ES customer group -- end*/
            
            
            
            
            
            jQuery('.Basic_det .infr_det').slideDown(500);
            jQuery('.no_det.active').css("border", "2px solid #a3d233");
        }
        else{
            jQuery('.basic_details .infr_det').slideUp(500);
            jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
        }
    },
    resetBlock : function(component,event, helper){ 
        
        jQuery('.basic_details .infr_det').slideUp(500);
        jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
        //jQuery('.container').find('.input__field').val('');
    },
    
    validateAndInsert : function(component, event, helper) {
        //validate reCaptcha
        var message = 'alohaCallingCAPTCHA';
        var vfOrigin = component.get("v.communityBaseURL");//"https://gcspeudev-allergancommunityeu.cs84.force.com";
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);
        console.log('Calling Captcha');
        /*var self=this;
         window.setTimeout(
                    $A.getCallback(function() {
                        if(component.get("v.isCaptchaValid")){
                            console.log("Captcha Pass");
                            //calling registration process
                            //self.createNewRegistration(component, event);                            
                        }
                        else
                        {
                            //show message
                            console.log("Captcha Error");
                            var recaptchaCmp = component.find("openModal");
                			$A.util.removeClass(component.find("openModal"), 'captcha-hide');
                            
                            //self.showTosteMessage(component, '', 'error', 'Please verify not a robot', 'dismissible');
                        }
                    }), 2000
                );*/
        helper.validateAndInsert(component, event);
    }
})