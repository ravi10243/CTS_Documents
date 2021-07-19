({
    doInit:function(component, event, helper) {

        var singUpPage = component.find('signUpSpark'); 
        var acceptPage = component.find('accept');
        $A.util.addClass(singUpPage, 'slds-hide');
        $A.util.addClass(acceptPage, 'slds-hide');
        
        var action = component.get("c.getPickListValues");
        action.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Salutation_AGN__c"
        });
        action.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if(rtnValue != null){
                component.set("v.options",rtnValue);
            }
                        
        });
        $A.enqueueAction(action);
        var nxt = component.get('v.togglePage');
        var countryValue = component.get("c.getCountryList");
        countryValue.setParams({ 
            objectType 			:   "Country_vod__c",
            selectedField 		:	"Country_Name_vod__c"
        });
        
        
        countryValue.setCallback(this, function(response){

            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.countryOptions",rtnValue);
            }
        });
        $A.enqueueAction(countryValue);
	},
    
	next : function(component, event, helper) {
         var nxt = component.get('v.togglePage');
         if (nxt == 2){
             //alert('Selected country '+  component.get("v.custCountry"));
             helper.FormatUsernameValidation(component , event , helper);
             var uNameFormatVal = component.get('v.userNameFormatValidation');
             if(uNameFormatVal == false){
                 var countryValue = component.get("c.getCountryList");
            countryValue.setParams({ 
                    objectType 			:   "Country_vod__c",
                    selectedField 		:	"Country_Name_vod__c",
                    selectedCountry     :   component.get("v.custCountry")
            });

        countryValue.setCallback(this, function(response){

            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.countryOptions",rtnValue);
            }
        });
            $A.enqueueAction(countryValue);
                 helper.nextButton(component, event);
            }
         }
        
        else{
            helper.nextButton(component, event);	
        }
         
    },
    displayRegisterFormNew: function(component, event, helper){
        alert('new app event handled');
        
    },
    displayRegisterForm : function(component, event, helper) {

        helper.displayForm(component, event);
    }, 
    
    createAccount : function(component, event, helper) {

        if(helper.validateFinal(component, event)){
           helper.saveAccount(component, event); 
        };
    },
    
    showFullMarkCont : function(component, event, helper) {
        var tog = component.get("v.showMarketingcont");
        if(tog == true){
            component.set("v.showMarketingcont",false);
        }else{
            component.set("v.showMarketingcont",true);
        }
    },
    
    showFullEvtCont : function(component, event, helper) {
        var tog = component.get("v.showEventcont");
        if(tog == true){
            component.set("v.showEventcont",false);
        }else{
            component.set("v.showEventcont",true);
        }
    },
    
    showFullPhoneCont : function(component, event, helper) {
        var tog = component.get("v.showPhonecont");
        if(tog == true){
            component.set("v.showPhonecont",false);
        }else{
            component.set("v.showPhonecont",true);
        }
        
    },
    
    confirmHealthCare : function(component, event, helper) {
        var confirmHealthCareVal = component.get('v.firstCheck');
        component.set("v.firstCheck",!confirmHealthCareVal);
        var cb = document.getElementById("confirmCb").checked = !confirmHealthCareVal;
    },

    handleSelfRegister: function (component, event, helper) {
        helper.handleSelfRegister(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleSelfRegister(component, event, helper);
        }
    },
    
    closeModal: function(component, event, helper){
        helper.clsModal(component, event, helper);
        document.body.style.overflow="auto";
    },
    
    clickDoctor: function(component, event, helper){
        component.set('v.custDetail.Profession_Spark_AGN__c', 'Doctor' );
    },
    
    clickNurse: function(component, event, helper){
        component.set('v.custDetail.Profession_Spark_AGN__c','Nurse');
    },
    
    clickDent: function(component, event, helper){
        component.set('v.custDetail.Profession_Spark_AGN__c', 'Dentist');
    },
    
    clickYes: function(component, event, helper){
        component.set('v.custDetail.Independent_Prescriber_Spark_AGN__c', 'Yes' );
    },
    
    clickNo: function(component, event, helper){
        component.set('v.custDetail.Independent_Prescriber_Spark_AGN__c', 'No');
    },
    
    getUserName : function(component, event, helper){
        helper.validateUserName(component, event, helper);
    },
    getEmailId : function(component, event, helper) {
        
        helper.validateEmail(component, event, helper)
        component.set("v.userName",component.get("v.userEmail")); 
    },
    
    
    
    
    titleChange: function (component, event) {
        // Get the string of the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");

        component.set("v.salutation", selectedOptionValue);
    },
    
    custCountryChange: function (component, event) {
        // Get the string of the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");

        component.set("v.custCountry", selectedOptionValue);
    },
    
    addCountryChange: function (component, event) {
        // Get the string of the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");

        component.set("v.addCountry", selectedOptionValue);
    },
    acceptPolicy: function (component, event) {
        component.set("v.custDetail.Accepted_Spark_privacy_policy_AGN__c", true);
        window.open('/Spark/s/privacy-policy','_blank');
    }
    
})