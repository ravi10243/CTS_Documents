({
    nextButton : function(component, event) {
        var nxt = component.get('v.togglePage');
        if (nxt == 1){
            var firstCheck = component.get('v.firstCheck');
            if( firstCheck == true){
                var nxtValue = nxt + 1;
                component.set('v.togglePage', nxtValue);
                var nBut = component.find("nextBtn").disabled = false;
                component.set("v.showError",false);
            }
            else{
                component.set("v.showError",true);
                component.set("v.errorMessage", 'Please confirm Healthcare profession');
            }
        }
        
        if (nxt == 2){
           var allValid = true;
          // var val		= component.get('v.accountDetail.Phone');
           var emailVal = component.get('v.userEmailValidation');
           var userNameVal = component.get('v.userNameValidation');
           var allValids = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            /*if(val.length != 10){
                allValid = false;
                component.set("v.errorMessage",["Please enter 10 digit valid phone number:" + val]);
                component.set("v.showError",true);
            }*/
            if(emailVal == true){
                allValid = false;
                component.set("v.errorMessage",$A.get("{!$Label.c.AGN_SPARK_Email_Already_Exist}"));
                component.set("v.showError",true);
            }
            if(userNameVal == true){
                allValid = false;
                component.set("v.errorMessage",$A.get("{!$Label.c.AGN_SPARK_Username_Already_Exist}"));
                component.set("v.showError",true);
            }
            
            if (allValid == true) {
               component.set("v.showError",false);
            } 
            if (allValids == true && allValid == true) {
                component.set("v.showError",false);
                var nxtValue = nxt + 1;
                component.set('v.togglePage', nxtValue);
            } 
        }

        if (nxt == 3){
            var allValid = true;
           // var val=component.get('v.addressDetail.Phone_AGN__c');
            var allValids = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            /*if(val.length != 10){
                allValid = false;
                component.set("v.errorMessage",["Please enter 10 digit valid phone number:" + val]);
                component.set("v.showError",true);
            }*/
            if (allValid == true) {
                component.set("v.showError",false);
            }
            if (allValids == true && allValid == true) {
                component.set("v.showError",false);
                var nxtValue = nxt + 1;
                component.set('v.togglePage', nxtValue);
                var elmnt = document.getElementById("nxtScroll");
                elmnt.scrollTop = 0;
            }  
        }
        
        if (nxt == 4){
            var regNo = component.get('v.custDetail.Registration_License_Number_AGN__c');
            var prof  = component.get('v.custDetail.Profession_Spark_AGN__c');
            var indep = component.get('v.custDetail.Independent_Prescriber_Spark_AGN__c');
            var allValid  = true;
            if((prof != 'Doctor' && prof != 'Nurse' && prof != 'Dentist')|| prof == undefined){
                allValid  = false;
                component.set("v.errorMessage", $A.get("{!$Label.c.AGN_SPARK_Select_Profession}"));
            }
            else if(regNo == '' || regNo == undefined){
                allValid  = false;
                component.set("v.errorMessage", $A.get("{!$Label.c.AGN_SPARK_MedReg_Number}"));
            }
            else if((indep != 'Yes' && indep != 'No') ||indep == undefined){
                allValid  = false;
                component.set("v.errorMessage", $A.get("{!$Label.c.AGN_SPARK_Independent_Prescriber}"));	 
            }
            if(allValid == false){
                component.set("v.showError",true);
            }
            if(allValid == true){
                component.set("v.showError",false);
                var nxtValue = nxt + 1;
                component.set('v.togglePage', nxtValue);
                var elmnt = document.getElementById("nxtScroll");
                elmnt.scrollTop = 0;
            }
            return allValid;
        } 
        
        if (nxt == 5){
            var nxtValue = nxt + 1;
            component.set('v.togglePage', nxtValue);
        } 
        
        var nextBtnHide = component.find('nextBtn');
        if (nxtValue == 6){
            $A.util.addClass(nextBtnHide, 'slds-hide');
        }
    },
    
    validateUserName: function(component, event) {
     var uName = component.get('v.userName');
     var action = component.get('c.checkUserNameExist');
        
        action.setParams({userName: uName
                        });
        action.setCallback(this, function(response){
            var retnValue = response.getReturnValue();
            
            if (retnValue != null){
                component.set("v.userNameValidation",true);
            }
            else{
                component.set("v.userNameValidation",false);
            }
        }); 
        $A.enqueueAction(action);
    },  
    
    
    validateEmail: function(component, event) {
     var email = component.get('v.userEmail');
     var action = component.get('c.checkUserExist');
        action.setParams({userEmail: email
                        });
        action.setCallback(this, function(response){
            var retnValue = response.getReturnValue();
            if (retnValue != null){
                component.set("v.userEmailValidation",true);
            }
            else{
                component.set("v.userEmailValidation",false);
            }
        }); 
        $A.enqueueAction(action);
    },        
    
    validateFinal : function(component, event) {
       // var val		= component.get('v.accountDetail.Phone');
        //var valAdd	= component.get('v.addressDetail.Phone_AGN__c');
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        /*if(val.length != 10){
            allValid = false;
            component.set("v.errorMessage",["Please enter 10 digit valid phone number:" + val]);
            component.set("v.showError",true);
        }
        if(valAdd.length != 10){
            allValid = false;
            component.set("v.errorMessage",["Please enter 10 digit valid phone number:" + val]);
            component.set("v.showError",true);
        }*/
        
        var regNo 				= component.get('v.custDetail.Registration_License_Number_AGN__c');
        var nxt 				= component.get('v.togglePage');
        
        if(regNo == '' || regNo == undefined){
            component.set("v.errorMessage", $A.get("{!$Label.c.AGN_SPARK_MedReg_Number}"));
            allValid = false;
        }

        if (nxt == 6){
            var acceptPolicy = component.get('v.custDetail.Accepted_Spark_privacy_policy_AGN__c');
            if(acceptPolicy == false || acceptPolicy == undefined){
            	component.set("v.errorMessage", $A.get("{!$Label.c.AGN_SPARK_Accept_Privacy}"));
                allValid = false;
            }
        }
        if(allValid == false){
            component.set("v.showError",true);
        }
        else{
            component.set("v.showError",false);
        }
        return allValid;
    },
    
    saveAccount : function(component, event) {
        var newButton = component.find("newButtonDiv");
        $A.util.toggleClass(newButton, "slds-hide");
        var action = component.get("c.selfRegister");
        action.setParams({ 
            customerDetail 	: 	component.get("v.custDetail"),
            addDetail 		:	component.get("v.addressDetail"),
            accountDetails  :	component.get("v.accountDetail"),
            email			:	component.get("v.userEmail"),
            salutation		:	component.get("v.salutation"),
            custCountry		:	component.get("v.custCountry"),
            addCountry		:	component.get("v.addCountry"),
            mCMarketing		:	component.get("v.multiChannelConsent.Opt_Type_vod__c"),
            mCEvent			:	component.get("v.multiChannelEvent.Opt_Type_vod__c"),
            mCPhone			:	component.get("v.multiChannelPhone.Opt_Type_vod__c"),
            phoneNum	    :   component.get('v.accountDetail.Phone'),
        });
        this.showCommunitySpinner(component);
        action.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                var elmnt = document.getElementById("regScroll");
				elmnt.scrollIntoView();
                this.createUser(component, rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    createUser : function(component, rtnValue){
        var email		= component.get("v.userEmail");
        var userName 	= component.get("v.userName");
        var params = { 
            customerDetail 	: 	component.get("v.custDetail"),
            accountDetails  :	component.get("v.accountDetail"),
            accountId		:	rtnValue,
            userName        :   userName,
            email			:	email,
            custCountry		:	component.get("v.custCountry"),
        };
        var action = component.get("c.communityUserCreation");
        action.setParams(params);
        action.setCallback(this, function(response){
            var retnValue = response.getReturnValue();
            var res = JSON.parse(retnValue);
            
            if (res.success == false) {
                component.set("v.errorMessage",res.message);
                component.set("v.showError",true);
                this.hideCommunitySpinner(component);
            }else{
                this.hideCommunitySpinner(component);
                component.set("v.welcomePage", true);
            }
        });
        $A.enqueueAction(action);
    },
        
    displayForm :function (component, event) {
    	component.set("v.showRegisterForm",true);
    },
    
    setBrandingCookie: function (component, event, helper) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){
			//Inherited from saleforce provided Registration component
            });
            $A.enqueueAction(action);
        }
    },
    
    resetValues: function(component, event){
        component.set("v.showRegisterForm",false);
        component.set("v.accountDetail.LastName", '');
        component.set("v.accountDetail.FirstName", '');
        component.set("v.accountDetail.Phone", '');
        component.set("v.custDetail.First_Name_AGN__c", '');
        component.set("v.custDetail.Last_Name_AGN__c", '');
        component.set("v.addressDetail.Address_Line_1_AGN__c", '');
        component.set("v.addressDetail.Address_Line_2_AGN__c", '');
        component.set("v.addressDetail.Phone_AGN__c", '');
        component.set("v.addressDetail.Zip_AGN__c", '');
        component.set("v.togglePage", 1);
        component.set("v.userName", '');
        component.set("v.userEmail", '');
        component.set("v.custDetail.Accepted_Spark_Marketing_Consent_AGN__c",false);
        component.set("v.custDetail.Accepted_Spark_Event_Consent_AGN__c",false);
        component.set("v.firstCheck",false);
        component.set("v.custDetail.Accepted_Spark_privacy_policy_AGN__c",false);
        component.set('v.custDetail.Profession_Spark_AGN__c', '');
        component.set('v.custDetail.Registration_License_Number_AGN__c', '');
        component.set('v.custDetail.Independent_Prescriber_Spark_AGN__c', '');
        component.set("v.showError",false);
        component.set("v.welcomePage",false);
        component.set("v.custDetail.salutation", '');
        component.set("v.custDetail.custCountry", '');
        component.set("v.addressDetail.addCountry", '');
    },
    
    clsModal:function (component, event) {
       this.resetValues(component, event);
    },
    
    showCommunitySpinner: function(component){       
        $A.util.removeClass(component.find("siteSpinner"), "hideEl");        
	},
    
    hideCommunitySpinner: function(component){
        $A.util.addClass(component.find("siteSpinner"), "hideEl");
    },
    
    FormatUsernameValidation : function(component , event , helper) { 
        var unameField = component.find("uname");
        var unameFieldValue = unameField.get("v.value");
        // Store Regular Expression
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        // check if Email field in not blank,
        // and if Email field value is valid then set error message to null, and remove error CSS class.
        // ELSE if Email field value is invalid then add Error Style Css Class, and set the error Message.          
        if(!$A.util.isEmpty(unameFieldValue)){   
            if(unameFieldValue.match(regExpEmailformat)){
                component.set("v.userNameFormatValidation" , false);
                component.set("v.showError",false);
            }
            else{
                component.set("v.userNameFormatValidation" , true);
                component.set("v.errorMessage",$A.get("{!$Label.c.AGN_SPARK_Username_InvalidFormat}"));
                component.set("v.showError",true);
            }
        }
        else{
               /* component.set("v.userNameFormatValidation" , true);
                component.set("v.errorMessage",$A.get("{!$Label.c.AGN_SPARK_Username_Format}"));
                component.set("v.showError",true);*/
                
            }
    },
    

});