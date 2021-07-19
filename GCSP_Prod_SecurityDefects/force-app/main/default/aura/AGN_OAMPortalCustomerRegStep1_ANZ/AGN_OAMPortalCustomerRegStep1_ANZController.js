({
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        //jQuery.noConflict();
        
    },   
    
    
    doInit : function(component, event, helper) {
        //console.log("Local " + $A.get("$Locale.langLocale"));  
        //fetching terms and condition
        helper.fetchFooterConsents(component, event);
        //jQuery.noConflict();
        //communityBaseURL + v.communitySuffix
        var vfOrigin = '';//"https://gcspeudev-allergancommunityeu.cs84.force.com";      
        
        var action = component.get('c.getCummunityURL');
        
        action.setStorable();
        action.setCallback(this, function(response) {
            console.log('@@@response>>>'+response.getState());
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
		//var globalId = component.getGlobalId();
        //console.log(globalId);
        //console.log(jQuery(".uiInput--checkbox input").is(":focus"));
        //jQuery('body').css({'position':'fixed','width':'100%'});
        //component.find("chkTC").focus();
        //component.find("chkTC").getElement().focus();
       
    },
    
    tcAccept : function(component,event, helper){
        component.set("v.isTCAccepted", true);
        jQuery('.GDPRConsent').fadeOut('fast');
        //jQuery(".uiInput--checkbox input").focus();
        //jQuery('body').css({'position':'','width':''});
        component.find("chkTC").getElement().focus();
    },
    tcCancel : function(component,event, helper){
        component.set("v.isTCAccepted", false);
        jQuery('.GDPRConsent').fadeOut('fast');
        //jQuery(".uiInput--checkbox input").focus();
       component.find("chkTC").getElement().focus();
    },
    tcClose : function(component,event, helper){
        //component.set("v.isTCAccepted", false);
        //jQuery('.modalDialog').addClass('captcha-hide');
        component.set("v.doValidate" , true);
        component.set("v.selectedActiveAddress" , "");
        $A.util.addClass(component.find("openModal"), 'captcha-hide'); 
        
        component.find("chkTC").getElement().focus();
     
    },
    scrollToBottom : function(component, event, helper){
        //event.preventDefault();
        jQuery(".slds-modal__content").animate({
            scrollTop: jQuery("#btn_container").offset().top
        },500,function(){
            component.set("v.Likedisable",true);
            component.set("v.Likedisable1",false);
        });   
        
        event.stopImmediatePropagation();
    },
    scrollToTop : function(component, event, helper){
        //event.preventDefault();
        jQuery(".slds-modal__content").animate({
            scrollTop: jQuery(".slds-modal__content").offset().top - 3500
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
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });  
        console.log('doneRendering');
        
    },
    
    showForm: function(component, event, helper){
        //console.log("step1 event is firing>>>>>");
        //component.set("v.customerGroup",'');
        //helper.makeEmptyValue(component, event);
        
        var params = event.getParam('arguments');
        //console.log("inside showform>>>>>>>>>>>>>>>>>",params.countryCode,params.customerType,params.customerSubType);
        //console.log(JSON.stringify(params.countryOptions));
        //
                
        if(params && !$A.util.isEmpty(params.countryCode) 
           && !$A.util.isEmpty(params.customerType) 
           && !$A.util.isEmpty(params.customerSubType)){
            if(params.countryCode.toUpperCase()==='NZ'){
                component.set("v.CountryCode", 'AN');
                component.set("v.SAPCountryCode", 'NZ');
            }else if(params.countryCode.toUpperCase()==='AN'){
                component.set("v.CountryCode", 'AN');
                component.set("v.SAPCountryCode", 'AU');
            }else{
                component.set("v.CountryCode", params.countryCode);    
                component.set("v.SAPCountryCode", params.countryCode);
            }            
            //console.log("***********SELECTED COUNTRY CODE****************",params.countryCode);
            //console.log("***********SELECTED customerType****************",params.customerType);
            //console.log("***********SELECTED selectedCustomerSubType****************",params.customerSubType);
            component.set("v.selectedCountryCode", params.countryCode);
            component.set("v.selectedCustomerType", params.customerType);
            component.set("v.selectedCustomerSubType", params.customerSubType);
            component.set("v.countryOptions", params.countryOptions);
            component.set("v.customerTypeConfig", params.customerTypeConfig);
            //console.log('config :>>>>> '+JSON.stringify(params.customerTypeConfig));
            component.set("v.sectionHeaderMap", {});
            //fetching layouts from custom metadata config
            helper.fetchCountrySettings(component, event);
            
            //fetching layouts from dependent metada config
            helper.fetchDependantFields(component , params.countryCode);
            
            
            
            /* for get customer group -- start*/  
             
            var action = component.get("c.getCustomerGroup");          
            action.setParams({
                'countryCode' : component.get("v.selectedCountryCode"),
                'customerType': component.get("v.selectedCustomerType"),
                'customerSubType': component.get("v.selectedCustomerSubType")
            }); 
            action.setCallback(this, function(response) {            
                if(response.getState() === 'SUCCESS') {
                    //console.log("CUSTOMER GROUP>>>>>>>>>>>>>>>>",response.getReturnValue());
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
        var customerType = component.get("v.selectedCustomerType");
        if(customerType.toUpperCase() === 'HOSPITAL' 
           || customerType.toUpperCase() === 'PHARMACIES'
           || customerType.toUpperCase() === 'WHOLESALERS'){
           component.set("v.showPrescribingDr" , false); 
           component.set("v.disablePrescribingDr" , true);
        }else{
           component.set("v.showPrescribingDr" , false); 
           component.set("v.isPrescribingDr" , true); 
           component.set("v.disablePrescribingDr" , false); 
           component.set("v.clearPrescribingDrValues" , false);
           component.set("v.clearPrescribingDrRequiredFields" , false);
           component.set("v.PrescribingDoctorsDependantFields" , component.get("v.PrescribingDoctorsDependantFields"));
            
        }
        
        
    },
    resetBlock : function(component,event, helper){ 
        
        jQuery('.basic_details .infr_det').slideUp(500);
        jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
        //jQuery('.container').find('.input__field').val('');
    },
    
    handleshowPrescribingDrCheckBoxChange : function(component, event, helper){
        var isChecked = event.getSource().get("v.value");
        console.log("Prescribiing Dr : on check>>>>>>>>>>>>>>"+ isChecked);
        if(isChecked){
            component.set("v.isPrescribingDr" , false);
            component.set("v.clearPrescribingDrValues" , true);
            component.set("v.clearPrescribingDrRequiredFields" , true);
        }else{
            component.set("v.isPrescribingDr" , true);
            component.set("v.clearPrescribingDrValues" , false);
            component.set("v.clearPrescribingDrRequiredFields" , false);
            component.set("v.PrescribingDoctorsDependantFields" , component.get("v.PrescribingDoctorsDependantFields"));
        }
        
    },
    
    handleSubTypeChange :  function(component, event, helper){
        console.log("inside handleSubTypeChange>>>>>>>>>>>>>>>>>");
        var lcmp = component.find("PrescribingDrField");
        lcmp.set("v.clearValues",true);       
        /*if(!$A.util.isEmpty(lcmp) && component.get("v.isPrescribingDr")){
           lcmp.forEach( function (cmp){
                     cmp.set("v.fieldValue" , '');
                                
                                
                            }); 
            
        }*/
    },
    
    validateAndInsert : function(component, event, helper) {
        
        //validate reCaptcha
        var message = 'alohaCallingCAPTCHA';
        var vfOrigin = component.get("v.communityBaseURL");//"https://gcspeudev-allergancommunityeu.cs84.force.com";
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);  
        console.log('Calling Captcha'); 
        
        helper.validateAndInsert(component, event);       
     
    },
    assignAddress : function(component, event, helper){
        var selected = event.getSource().get("v.text");
        console.log("selected address>>>>>>>>>>>>>"+selected);
        component.set("v.selectedActiveAddress" , selected);
        component.set("v.showError" , false);
    },
    submitRequest : function(component, event, helper){
        
        component.set("v.doValidate" , false);
        var activeAddressFound = component.get("v.activeAddressFound");
        var selected = component.get("v.selectedActiveAddress"); //4767 Mosquito Creek Rd PALLAMALLAWA NSW 2399
        console.log("selected address>>>>>>>>>>>>>"+JSON.stringify(selected));
        if(activeAddressFound && !$A.util.isEmpty(selected)){
            try{ 
                if(selected != $A.get("$Label.c.AGN_OAM_CONTINUE_WITH_CURRENT_ADDRESS")){
                      var country = component.get("v.selectedCountryCode");
                      console.log("selected country code>>>>>>>>>>>>>"+country);
                      var address = selected.split(',');
                      var first = "";
                      var second = "";
                      var third = "";
                      var fourth = "";
                      var streetno = "";
                      var street = "";
                      var suburb = "";
                      var state = "";
                      var zip = "";
                      var states = "";
                      var cityZipString = "";
                      var last = "";
                      if(country === 'AN'){
                          states = 'NSW,QLD,SA,TAS,VIC,WA,ACT,NT';
                      }else if(country === 'NZ'){
                          states = 'WHANGAREI,AUCKLAND,HAMILTON,WHAKATANE,GISBORNE,NAPIER,STRATFORD,PALMERSTON NORTH,WHANGANUI,WELLINGTON,RICHMOND,NELSON,BLENHEIM,GREYMOUTH,CHRISTCHURCH,DUNEDIN,INVERCARGILL'; 
                      }
           
                   
                   var address = selected.split(',');
                      if(address.length > 3){
                        last = address[address.length-1];
                        cityZipString = last;
                      }else if(address.length == 3){
                        last = address[address.length-1];
                        cityZipString = last;
                      }else if(address.length == 2){
                        last = address[address.length-1];
                        cityZipString = last;
                      }
                      cityZipString = cityZipString.trim();
                      var spl = cityZipString.split(" ");
                      var i = 0;
                      var statepos;
                      var isFound = false;
                      spl.forEach(function(cmp){
                        var str = cmp.toUpperCase().trim();
                        console.log("str>>>>>>>>>>>>>>"+str);
                        if(states.includes(str) && i != spl.length){
                          console.log("found at position "+i);
                          statepos = i;
                          state = spl[statepos];
                          isFound = true;
                        }
                        i = i+1;
                      });
                      if(isFound){
                        if(country === 'AN'){
                            switch (state) {
                                  case "ACT":
                                    state = "AU-ACT";
                                    break;
                                  case "NT":
                                    state = "AU-NT";
                                    break;
                                  case "NSW":
                                    state = "AU-NSW";
                                    break;
                                  case "QLD":
                                    state = "AU-QLD";
                                    break;
                                  case "SA":
                                    state = "AU-SA";
                                    break;
                                  case "TAS":
                                    state = "AU-TAS";
                                    break;
                                  case "VIC":
                                    state = "AU-VIC";
                                    break;
                                  case "WA":
                                    state = "AU-WA";
                            }
                        }else if(country === 'NZ'){
                            switch (state) {
                                   case "WHANGAREI":
                                     state = "NZ-NTL";
                                     break;
                                   case "AUCKLAND":
                                     state = "NZ-AUK";
                                     break;
                                   case "HAMILTON":
                                     state = "NZ-WKO";
                                     break;
                                   case "WHAKATANE":
                                     state = "NZ-BOP";
                                     break;
                                   case "GISBORNE":
                                     state = "NZ-GIS";
                                     break;
                                   case "NAPIER":
                                     state = "NZ-HKB";
                                     break;
                                   case "STRATFORD":
                                     state = "NZ-TKI";
                                     break;
                                   case "PALMERSTON NORTH":
                                     state = "NZ-MWT";
                                     break;
                                   case "WHANGANUI":
                                     state = "NZ-MWT";
                                     break;
                                   case "WELLINGTON":
                                     state = "NZ-WGN";
                                     break;
                                   case "RICHMOND":
                                     state = "NZ-TAS";
                                     break;
                                   case "NELSON":
                                     state = "NZ-NSN";
                                     break;
                                   case "BLENHEIM":
                                     state = "NZ-MBH";
                                     break;
                                   case "GREYMOUTH":
                                     state = "NZ-WTC";
                                     break;
                                   case "CHRISTCHURCH":
                                     state = "NZ-CAN";
                                     break;
                                   case "DUNEDIN":
                                     state = "NZ-OTA";
                                     break;
                                   case "INVERCARGILL":
                                     state = "NZ-STL";
                              }  
                        }
                        
                      }else{
                          //find statepos
                          statepos = spl.length - 2;
                      }
                     console.log("statepos>>>>>>>>>>>>>>>>"+statepos);
                     if(statepos == 0){ //The final string is like 'NSW 2000' - without suburb
                        for(i = statepos+1 ; i<spl.length ; i++){
                            zip = zip + spl[i] + " ";
                        }
                     }else if(statepos > 0){//The final string is like 'SYDNEY NSW 2000' with suburb
                        for(i=0;i<statepos;i++){
                           suburb = suburb + spl[i] + " ";
                        }
                        for(i = statepos+1 ; i<spl.length ; i++){
                            zip = zip + spl[i] + " ";
                        }
                     }
                     if(address.length > 3){
                        if(statepos == 0){
                          for(i=address.length-2; i>=0; i--){
                             if(suburb === ""){
                               suburb = address[i];
                             }else if(street === ""){
                                street = address[i];
                             }else{
                                streetno = streetno + address[i] + " ";
                             }
                          }
                        }else if(statepos>0){
                           for(i=address.length-2; i>=0; i--){
                             if(street === ""){
                                street = address[i];
                             }else{
                                streetno = address[i] + streetno + " ";
                             }
                          }
                        }
                     }else if(address.length == 3){
                       if(statepos == 0){
                            suburb = address[1];
                            var first = address[0];
                            var firstSplit = first.split(" ");
                            if(firstSplit.length > 1){
                               streetno = firstSplit[0];
                               for(i=1;i<firstSplit.length;i++){
                                 street = street + firstSplit[i] + " ";
                               }
                            }
                       }else if(statepos>0){
                         for(i=address.length-2; i>=0; i--){
                           if(street === ""){
                             street = address[i];
                           }else{
                             streetno = address[i] + streetno + " ";
                           }
                         }
                       }
                     }else if(address.length == 2){
                       if(statepos == 0){
                          var first = address[0];
                          var firstSplit = first.split(" ");
                          if(firstSplit.length > 1){
                             streetno = firstSplit[0];
                             for(i=1;i<firstSplit.length;i++){
                               street = street + firstSplit[i] + " ";
                             }
                          }
                       }else if(statepos>0){
                         var first = address[0];
                           var firstSplit = first.split(" ");
                           streetno = firstSplit[0];
                           if(firstSplit.length > 1){
                               
                               for(i=1;i<firstSplit.length;i++){
                                   street = street + firstSplit[i] + " ";
                               }
                           } 
                       }
                     } 
                    
                      
                    console.log("street number>>>>>>>>>>>>>>>>>>>>>>>>>>>",streetno);
                    console.log("street>>>>>>>>>>>>>>>>>>>>>>>>>>>",street);
                    console.log("suburb>>>>>>>>>>>>>>>>>>>>>>>>>>>",suburb);
                    console.log("state>>>>>>>>>>>>>>>>>>>>>>>>>>>",state);
                    console.log("zip>>>>>>>>>>>>>>>>>>>>>>>>>>>",zip);
                    const cmps = component.find("fieldId");
                    if ($A.util.isArray(cmps)){
                        cmps.forEach( function (cmp){
                            if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                                var fieldName = cmp.get("v.fieldName");
                                if(fieldName === 'Address_Line_2_AGN__c'){
                                    cmp.set("v.fieldValue" , streetno);
                                }if(fieldName === 'Address_Line_1_AGN__c'){
                                    cmp.set("v.fieldValue" , street);
                                }else if(fieldName === 'City_AGN__c'){
                                    cmp.set("v.fieldValue" , suburb);
                                }else if(fieldName === 'State_AGN__c'){
                                    if(country === 'NZ'){
                                       state = cmp.get("v.fieldValue");   
                                    }
                                    cmp.set("v.fieldValue" , state);
                                    
                                }else if(fieldName === 'Zip_AGN__c'){
                                    cmp.set("v.fieldValue" , zip.trim());
                                }
                            }
                        });
                    } 
                    
                    component.set('v.objAGNCustAddrActive.Suite_AGN__c' , streetno);
                    component.set('v.objAGNCustAddrActive.Address_Line_1_AGN__c' , street);
                    component.set('v.objAGNCustAddrActive.City_AGN__c' , suburb);
                    component.set('v.objAGNCustAddrActive.State_AGN__c' , state);
                    component.set('v.objAGNCustAddrActive.Zip_AGN__c' , zip);
                    component.set('v.objAGNCustAddrActive.Is_Verified_Address__c' , true);
                    
                    
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
            //helper.validateFormatFields(component, event); commented on 24/5/2019
            component.set('v.isAddressVerified' , true);// added on 24/5/2019
            helper.validateAndInsert(component, event);
        }else{
            if(component.get("v.showError")){
                component.set("v.isOpen", false);
                component.set("v.showError" , false); 
                component.set('v.isAddressVerified' , true);
                helper.validateAndInsert(component, event);
            }else{
               component.set("v.showError" , true); 
            }
        }
        
    },
    closePopup : function(component, event, helper){
        
        component.set("v.isOpen", false);
        component.set("v.selectedActiveAddress" , "");
        component.set('v.isAddressVerified' , false);
    }
})