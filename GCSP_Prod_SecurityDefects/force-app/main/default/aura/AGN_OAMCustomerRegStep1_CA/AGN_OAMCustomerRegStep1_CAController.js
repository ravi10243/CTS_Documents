({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        //jQuery.noConflict();
        
    },   
    
    
    doInit : function(component, event, helper) {
        
        
        // console.log("inside doinit");
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
            // console.log(event.data.action);
            // console.log(event.data.alohaResponseCAPTCHA);
            // console.log(event.origin);
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
    tcClose : function(component,event, helper){
        //component.set("v.isTCAccepted", false);
        //jQuery('.modalDialog').addClass('captcha-hide');
        component.set("v.doValidate" , true);
        component.set("v.selectedActiveAddress" , "");
        $A.util.addClass(component.find("openModal"), 'captcha-hide'); 
        
    },
    scrollToBottom : function(component, event, helper){
        //event.preventDefault();
        jQuery(".slds-modal__content").animate({
            scrollTop: jQuery("#btn_container").offset().top
        },500,function(){
            component.set("v.Likedisable",true);
            component.set("v.Likedisable1",false);
        });
        /*,function(){
            component.set("v.icon",
                          component.get("v.icon")=="utility:jump_to_bottom"?
                          "utility:jump_to_top":"utility:jump_to_bottom"); 
        }*/
        
        event.stopImmediatePropagation();
    },
    scrollToTop : function(component, event, helper){
        //event.preventDefault();
        jQuery(".slds-modal__content").animate({
            scrollTop: jQuery(".slds-modal__content").offset().top -210
        },500,function(){
            component.set("v.Likedisable",false);
            component.set("v.Likedisable1",true);
        });
        event.stopImmediatePropagation();
    },
    
    doneRendering : function(component,event, helper){
        jQuery.noConflict();
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                console.log("has value>>>>>>>");
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                console.log("no value>>>>>>>");
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
        //	***** Jump To bottom button in the Terms and Conditions modal start ******
        
        /*    jQuery("div.down_click").click(function(e){
                e.preventDefault();
                jQuery(".slds-modal__content").animate({
                    scrollTop: jQuery("#btn_container").offset().top
                },500);
                e.stopImmediatePropagation();
                jQuery("div.down_click button").prop('disabled', true);
                console.log("__accept",jQuery("#btn_container").offset().top);
               });*/
        
        //	***** Jump To bottom button in the Terms and Conditions modal end ******
        
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
        component.set("v.isDoctorOverseeAccount" , false);
        var params = event.getParam('arguments');
        
        //console.log(JSON.stringify(params.countryOptions));
        
        if(params && !$A.util.isEmpty(params.countryCode) 
           && !$A.util.isEmpty(params.customerType) 
           && !$A.util.isEmpty(params.customerSubType)){
            
            component.set("v.selectedCountryCode", params.countryCode);
            component.set("v.selectedCustomerType", params.customerType);
            component.set("v.selectedCustomerSubType", params.customerSubType);
            component.set("v.countryOptions", params.countryOptions);
            component.set("v.customerTypeConfig", params.customerTypeConfig);
            component.set("v.selectedProvince",params.customerProvince);
            //console.log('it');
            component.set("v.sectionHeaderMap", {});
            if(params.countryCode === 'CA'){
                helper.fetchDependantFields(component , params.countryCode);
                var buyingGroupLabel = $A.get("$Label.c.AGN_OAM_Are_you_apart_Buying_Group");
                component.set("v.buyingGroupLabel" , buyingGroupLabel);
            } 
            
              //fetching layouts from custom metadata config
            helper.fetchCountrySettings(component, event); 
            
            /* for get customer group -- start*/  
            
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
            /* for get customer group -- end*/
            
           
            
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
        console.log("validateAndInsert"+component.get("v.communityBaseURL"));
        //validate reCaptcha
        var message = 'alohaCallingCAPTCHA';           
        var vfOrigin = component.get("v.communityBaseURL");//"https://gcspeudev-allergancommunityeu.cs84.force.com";         
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        
        console.log('Captcha is Caling');
        vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);
        
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
    },
     handleCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        component.set("v.isBuyingGroup" , isChecked);
        console.log("on check>>>>>>>>>>>>>>"+ component.get("v.isBuyingGroup"));
        if(!isChecked){
            component.set("v.clearBuyingGroup" , true);
            component.set("v.clearBuyingGroupRequiredFields" , true);
        }else{
            console.log("BuyingGroupDependantFields>>>>>>>>>>>>>>>>>>>>"+component.get("v.BuyingGroupDependantFields"));
            component.set("v.BuyingGroupDependantFields" , component.get("v.BuyingGroupDependantFields"));
            component.set("v.clearBuyingGroup" , false);
            component.set("v.clearBuyingGroupRequiredFields" , false);
        }
        
    },
    handleAccountOwnerCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        
        
        
        console.log("account owner : on check>>>>>>>>>>>>>>"+ isChecked);
        if(isChecked){
            component.set("v.isAccountOwner" , false);
            component.set("v.clearAccountOwner" , true);
            component.set("v.clearAccountOwnerRequiredFields" , true);
        }else{
            component.set("v.isAccountOwner" , true);
            component.set("v.clearAccountOwner" , false);
            component.set("v.clearAccountOwnerRequiredFields" , false);
            component.set("v.AccountOwnerDependantFields" , component.get("v.AccountOwnerDependantFields"));
        }
        
    },
    /*verifyAddress : function(component, event, helper){
        
        const cmps = component.find("fieldId");
        var requiredMissing = false;
        var suite = "";
        var street = "";
        var city = "";
        var zip = "";
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                
                if (cmp.get("v.fieldName") == 'Suite_AGN__c' 
                    || cmp.get("v.fieldName") == 'Address_Line_1_AGN__c' 
                    || cmp.get("v.fieldName") == 'City_AGN__c' 
                    || cmp.get("v.fieldName") == 'Zip_AGN__c'){
                    console.log(cmp.get("v.fieldName") +"===>"+cmp.get("v.fieldValue"));
                    if(jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        requiredMissing = true; 
                    }else if(cmp.get("v.fieldName") == 'Suite_AGN__c'){
                        suite = cmp.get("v.fieldValue");
                    }else if(cmp.get("v.fieldName") == 'Address_Line_1_AGN__c'){
                        street = cmp.get("v.fieldValue");
                    }else if(cmp.get("v.fieldName") == 'City_AGN__c'){
                        city = cmp.get("v.fieldValue");
                    }else if(cmp.get("v.fieldName") == 'Zip_AGN__c'){
                        zip = cmp.get("v.fieldValue");
                    }
                }
            });
        }
        if(requiredMissing){
            alert("Please add values for address fields");
        }else{
            var searchString = suite +" "+ street +" "+ city +" "+ component.get("v.selectedProvince") +" "+ zip;
            console.log(searchString);
            //isValidAddress = helper.validateAddress(component , searchString);
            helper.validateAddress(component , searchString);
        }
    },*/
    assignAddress : function(component, event, helper){
        var selected = event.getSource().get("v.text");
        console.log("selected address>>>>>>>>>>>>>"+selected);
        component.set("v.selectedActiveAddress" , selected);
        component.set("v.showError" , false);
    },
    submitRequest : function(component, event, helper){
        component.set("v.doValidate" , false);
        var activeAddressFound = component.get("v.activeAddressFound");
        var selected = component.get("v.selectedActiveAddress");
        console.log("selected address>>>>>>>>>>>>>"+JSON.stringify(selected));
        if(activeAddressFound && !$A.util.isEmpty(selected)){
            //console.log("selected address>>>>>>>>>>>>>"+selected);
            try{ 
                if(selected != $A.get("$Label.c.AGN_OAM_CONTINUE_WITH_CURRENT_ADDRESS")){ 
                    var address = selected.split(',');
                    var first = address[0];
                    var second = address[1];
                    var firstSplit = first.split(' ');
                    var addressType = component.get("v.addressType");
                    var suite = "";
                    var street = "";
                    if(addressType === 'Address'){
                        suite = firstSplit[0];
                        for(i = 1 ; i<firstSplit.length ; i++){
                            street = street + firstSplit[i] + " ";
                        }
                        street = street.substring(0, street.length - 1);
                    }else if(addressType === 'Street'){
                        street = first;
                    }
                    var provinces = 'AB,BC,MB,NB,NL,NT,NS,NU,ON,PE,QC,SK,YT';
                    second = second.trim();
                    var spl = second.split(" ");
                    var i = 0;
                    var provincepos;
                    var province = "";
                    spl.forEach(function(cmp){
                        console.log(cmp);
                        if(provinces.includes(cmp) && 
                           i != 0 
                           && i != spl.length){
                            console.log("found at position "+i);
                            provincepos = i;
                            province = spl[provincepos];
                        }
                        i = i+1;
                    });
                    
                    console.log("Province>>>>>>>>>>>"+spl[provincepos]);
                    var city = "";
                    for(i = 0 ; i<provincepos ; i++){
                        city = city + spl[i] + " ";
                    }
                    city = city.substring(0, city.length - 1);
                    console.log("city>>>>>>>>>>>>>>>>"+city);
                    var zip = "";
                    for(i = provincepos + 1 ; i<spl.length ; i++){
                        zip = zip + spl[i] + " ";
                    }
                    zip = zip.substring(0, zip.length - 1);
                    if(zip.includes('Addresses')){
                        zip = zip.replace('Addresses' , '');
                    }
                    console.log("suite>>>>>>>>>>>>>>>>>>>>>>>>>>>",suite);
                    console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>>>",street);
                    console.log("city>>>>>>>>>>>>>>>>>>>>>>>>>>>",city);
                    console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>>>",zip);
                    const cmps = component.find("fieldId");
                    if ($A.util.isArray(cmps)){
                        cmps.forEach( function (cmp){
                            if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                                var fieldName = cmp.get("v.fieldName");
                                if(fieldName === 'Suite_AGN__c' && addressType === 'Address'){
                                    cmp.set("v.fieldValue" , suite);
                                }else if(fieldName === 'Address_Line_1_AGN__c'){
                                    cmp.set("v.fieldValue" , street);
                                }else if(fieldName === 'City_AGN__c'){
                                    cmp.set("v.fieldValue" , city);
                                }else if(fieldName === 'Zip_AGN__c'){
                                    cmp.set("v.fieldValue" , zip);
                                }
                                //var derivedField = 'v.objAGNCustAddr.' + cmp.get("v.fieldName"); 
                                //component.set(derivedField,cmp.get("v.fieldValue"));
                            }
                        });
                    }
                    
                    
                    
                    component.set('v.objAGNCustAddrActive.Suite_AGN__c' , suite);
                    component.set('v.objAGNCustAddrActive.Address_Line_1_AGN__c' , street);
                    component.set('v.objAGNCustAddrActive.City_AGN__c' , city);
                    component.set('v.objAGNCustAddrActive.Zip_AGN__c' , zip);
                    component.set('v.objAGNCustAddrActive.Is_Verified_Address__c' , true);
                    
                    console.log(JSON.stringify(component.get("v.objMixType")));//component.set("v.objMixType", "v.objAGNCustAddrActive");
                    
                    console.log("After set>>>>>>>>>>>>>>>>>>>>>>",component.get("v.objAGNCustAddrActive.Suite_AGN__c"));
                    component.set("v.userSelectedOneActiveAddress" , true);
                }else{
                    component.set('v.objAGNCustAddrActive.Is_Verified_Address__c' , false);
                    component.set("v.userSelectedOneActiveAddress" , false);
                }  
            } catch(err){
                console.log('catch error>>>'+err);
            }
            component.set("v.isOpen", false);
            //helper.createNewRegistration(component, event);
            helper.validateFormatFields(component, event);
        }else{
            component.set("v.showError" , true);
        }
        
    },
    closePopup : function(component, event, helper){
        
        component.set("v.isOpen", false);
        component.set("v.selectedActiveAddress" , "");
        component.set('v.isAddressVerified' , false);
    }
})