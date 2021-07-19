({
    doInit : function(component, event, helper) {
        var query = location.search.substr(1);       
        component.set("v.IsMobileDevice",$A.get("$Browser.isPhone"));        
        //var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'language')
            {
                component.set("v.URLLanguage",decodeURIComponent(item[1]));
                component.set("v.Locator_Listing.User_Language_AGN__c",component.get("v.URLLanguage"));
            }
            if(item[0] === 'country')
            {
                component.set("v.URLCountry",decodeURIComponent(item[1]));
                component.set("v.Clinic_Admin_details.Country_Code__c",component.get("v.URLCountry"));
                component.set("v.Clinic_details.Country_Code__c",component.get("v.URLCountry"));
            }
            //result[item[0]] = decodeURIComponent(item[1]);
        });
        
        //getcountry for GTM
        var action1 = component.get("c.getcountry");
        
        action1.setParams({
            'country' :component.get("v.URLCountry")
        });
        
        action1.setCallback(this, function(response){
            
            if(response.getState() === 'SUCCESS') 
            {
                var countryval = response.getReturnValue();                
                component.set("v.GTMCountry",countryval);                
            }
            
        });
        $A.enqueueAction(action1);
        
        //GTM
        
        /*if(component.get("v.URLCountry") === 'AN')
        {
            helper.DefaultTimeAZ(component, event);
        }*/
        //var vfOrigin = '';
        var vfOrigin = component.get("v.CommunityBaseURL");//$A.getReference("$Label.c.AGN_ICL_Community_Base_URL");
        //alert(vfOrigin);
        
        var action = component.get("c.getBrandPicklistValues");
        action.setParams({	
            'countryCode': component.get("v.URLCountry")
        });
        //action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                var BrandList = [];
                var BrandList1 = [];
                var itr=0;
                for(var key in lst){
                    itr++;
                    BrandList.push({Name: lst[key], selected: false});
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                component.set("v.brandSize",itr);
                component.set("v.BrandValues",BrandList);
                component.set("v.BrandValues1",BrandList1);

            }
        });
        $A.enqueueAction(action);
        // Duallist Box Logic added for Brand 
            component.get("v.brandSize");
            var action5 = component.get("c.getMultipicklistBrandCount");
            action5.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var mbp = response.getReturnValue();               
                 if(component.get("v.brandSize") > mbp )
                 {
                  component.set("v.showMultiselect",true);
                 }
                }
            });
            $A.enqueueAction(action5);
        // Duallist Box Logic added for Brand END
        var action1 = component.get("c.getCountryWiseFields");
        action1.setParams({
            'CountryCode': component.get("v.URLCountry") 
        });
        //action.setStorable();
        action1.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in lst){
                    arrayMapKeys.push({key: key, value: lst[key]});
                    //console.log('Country list value :'+JSON.stringify(component.get("v.Locator_Listing")));
                }                
                component.set("v.CountryWiseFieldsMap",arrayMapKeys);
            }
        });
        //$A.enqueueAction(action);
        $A.enqueueAction(action1);
        //vfOrigin = 'https://gcldev-allergancommunitycore.cs84.force.com';//'https://iclhcp--gcldev--c.cs84.visual.force.com';
        window.addEventListener("message", function(event) {
            //alert(event.origin);
            if (event.origin !== vfOrigin) {
                return;
            }
            //alert(event.data.action);
            if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK'){
                component.set("v.isCaptchaValid", false);
                //alert('fgffg');
                //alert(component.get("v.isCaptchaValid"));
                
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK'){
                component.set("v.isCaptchaValid", true);
                //alert('fgffg');
                //alert(component.get("v.isCaptchaValid"));
                
            }
        }, false);
        
        //Added for New Terms of Condition
        var action = component.get("c.gettermsandcondition");
        
        action.setParams({
            'country': component.get("v.URLCountry"),
            'language': component.get("v.URLLanguage")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getres = response.getReturnValue();
                component.set("v.iclterms",getres);
                component.set("v.loadPage",true);
            }
        });
        $A.enqueueAction(action);
        //Added for New Terms of Condition
        
        //added as apart of two column layout
         var action = component.get("c.isTwoLayerLayout");
            action.setParams({
                'countryCode': component.get("v.URLCountry")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var a = response.getReturnValue();
                    component.set("v.twoLayerLayout", a);
                    //component.set("v.PickListValues", response.getReturnValue());
                } 
            });
            $A.enqueueAction(action);
        //End
        
        //Added as a part of Casl Consent for  Canada
        var action = component.get("c.getCaslConsent");
        
        action.setParams({
            'country': component.get("v.URLCountry"),
            'language': component.get("v.URLLanguage")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getres = response.getReturnValue();
                component.set("v.iclCasl",getres);
                component.set("v.loadPage",true);
            }
        });
        $A.enqueueAction(action);
        //Added as a part of Casl Consent for  Canada
        //get Disclaimer Setting from country setting
        var getDisclaimer = component.get("c.getDisclaimerSettings");
        getDisclaimer.setParams({
            'countryCode': component.get("v.URLCountry")
        });
        getDisclaimer.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getDis = response.getReturnValue();
                component.set("v.showCTDisclmr",getDis);              
            }
        });
        $A.enqueueAction(getDisclaimer);
        
        var getConsentCheck = component.get("c.isClinicConsentEnabled");
        getConsentCheck.setParams({
            'countryCode': component.get("v.URLCountry")
        });
        getConsentCheck.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getCheck = response.getReturnValue();
                component.set("v.showClinicConsent",getCheck);              
            }
        });
        $A.enqueueAction(getConsentCheck);  
        
        //CASL Consent 
        var getCASLCheck = component.get("c.isCaslConsentEnabled");
        getCASLCheck.setParams({
            'countryCode': component.get("v.URLCountry")
        });
        getCASLCheck.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getCASL = response.getReturnValue();
                component.set("v.showCASLConsent",getCASL);              
            }
        });
        $A.enqueueAction(getCASLCheck); 
        //CASL Consent end
     
        //TH CR
        var getTimingCheck = component.get("c.isClinicTimingEnabled");
        getTimingCheck.setParams({
            'countryCode': component.get("v.URLCountry")
        });
        getTimingCheck.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getCheck = response.getReturnValue();
                component.set("v.showClinicTiming",getCheck);              
            }
        });
        $A.enqueueAction(getTimingCheck);
        //TH CR
    },       
    setSalutationVal : function(component, event, helper){
        var a1 = component.get("v.SelectedSalutation");
        component.set("v.Clinic_Admin_details.Salutation",a1);
        // a.Salutation = a1;
    },
    ClinicCreationSection : function(component, event, helper){
        var clinic_admin = component.get("v.Clinic_Admin_details");
        //console.log('val '+clinic_admin);
        component.set("v.Clinic_Next",true);
    },
    scriptsLoaded : function(component, event, helper) {
        
        //GTM
        component.set("v.showGAInit",true);
        var pageURL=document.URL;
        pageURL =pageURL.split(".com")[1];
        pageURL =pageURL.split("?")[0];
        var pageTitile=document.title;
        component.set("v.GTMPageURL",pageURL);
        component.set("v.GTMPageTitle",pageTitile);
        jQuery.noConflict();
        //alert('*************** Inside do Init1 Method *****************')
        
        jQuery("document").ready(function(){
            
            //alert('Inside jquery'); 
            jQuery('.recaptcha-checkbox-checkmark').click(function(){
                //alert("asasdas");
            })
            //alert("Jquery");
            
        });
    },  
    ValidateAndSaveRecords : function(component, event, helper){ 
       if(component.get("v.IsMobileDevice"))
        {
            
            if(component.find("monstartid").getElement('v.value').value !='' && component.find("monstartid").getElement('v.value').value !=null && component.find("monstartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("monstartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Monday_Open_Hours_AGN__c",component.find("monstartid").getElement('v.value').value+':00.000');
                } 
                else{
                    component.set("v.Locator_Listing.Monday_Open_Hours_AGN__c",component.find("monstartid").getElement('v.value').value);
                }
            } 
            if(component.find("monendid").getElement('v.value').value !='' && component.find("monendid").getElement('v.value').value !=null && component.find("monendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("monendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Monday_Close_Hours_AGN__c",component.find("monendid").getElement('v.value').value+':00.000');
                }
                else{
                    component.set("v.Locator_Listing.Monday_Close_Hours_AGN__c",component.find("monendid").getElement('v.value').value);
                }
            } 
            if(component.find("tuestartid").getElement('v.value').value !='' && component.find("tuestartid").getElement('v.value').value !=null && component.find("tuestartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("tuestartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Tuesday_Open_Hours_AGN__c",component.find("tuestartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Tuesday_Open_Hours_AGN__c",component.find("tuestartid").getElement('v.value').value);
                }
            } 
            if(component.find("tueendid").getElement('v.value').value !='' && component.find("tueendid").getElement('v.value').value !=null && component.find("tueendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("tueendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Tuesday_Close_Hours_AGN__c",component.find("tueendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Tuesday_Close_Hours_AGN__c",component.find("tueendid").getElement('v.value').value);
                }
            } 
            if(component.find("wedstartid").getElement('v.value').value !='' && component.find("wedstartid").getElement('v.value').value !=null && component.find("wedstartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("wedstartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Wednesday_Open_Hours_AGN__c",component.find("wedstartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Wednesday_Open_Hours_AGN__c",component.find("wedstartid").getElement('v.value').value);
                }
            } 
            if(component.find("wedendid").getElement('v.value').value !='' && component.find("wedendid").getElement('v.value').value !=null && component.find("wedendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("wedendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Wednesday_Close_Hours_AGN__c",component.find("wedendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Wednesday_Close_Hours_AGN__c",component.find("wedendid").getElement('v.value').value);
                }
            } 
            if(component.find("thusstartid").getElement('v.value').value !='' && component.find("thusstartid").getElement('v.value').value !=null && component.find("thusstartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("thusstartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Thursday_Open_Hours_AGN__c",component.find("thusstartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Thursday_Open_Hours_AGN__c",component.find("thusstartid").getElement('v.value').value);
                }
            } 
            if(component.find("thusendid").getElement('v.value').value !='' && component.find("thusendid").getElement('v.value').value !=null && component.find("thusendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("thusendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Thursday_Close_Hours_AGN__c",component.find("thusendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Thursday_Close_Hours_AGN__c",component.find("thusendid").getElement('v.value').value);
                }
            } 
            if(component.find("fristartid").getElement('v.value').value !='' && component.find("fristartid").getElement('v.value').value !=null && component.find("fristartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("fristartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Friday_Open_Hours_AGN__c",component.find("fristartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Friday_Open_Hours_AGN__c",component.find("fristartid").getElement('v.value').value);
                }
            } 
            if(component.find("friendid").getElement('v.value').value !='' && component.find("friendid").getElement('v.value').value !=null && component.find("friendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("friendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Friday_Close_Hours_AGN__c",component.find("friendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Friday_Close_Hours_AGN__c",component.find("friendid").getElement('v.value').value);
                }
            } 
            if(component.find("satstartid").getElement('v.value').value !='' && component.find("satstartid").getElement('v.value').value !=null && component.find("satstartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("satstartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Saturday_Open_Hours_AGN__c",component.find("satstartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Saturday_Open_Hours_AGN__c",component.find("satstartid").getElement('v.value').value);
                }
            } 
            if(component.find("satendid").getElement('v.value').value !='' && component.find("satendid").getElement('v.value').value !=null && component.find("satendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("satendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Saturday_Close_Hours_AGN__c",component.find("satendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Saturday_Close_Hours_AGN__c",component.find("satendid").getElement('v.value').value);
                }
            } 
            if(component.find("sunstartid").getElement('v.value').value !='' && component.find("sunstartid").getElement('v.value').value !=null && component.find("sunstartid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("sunstartid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Sunday_Open_Hours_AGN__c",component.find("sunstartid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Sunday_Open_Hours_AGN__c",component.find("sunstartid").getElement('v.value').value);
                }
            } 
            if(component.find("sunendid").getElement('v.value').value !='' && component.find("sunendid").getElement('v.value').value !=null && component.find("sunendid").getElement('v.value').value !=undefined )
            {
                var timeString = component.find("sunendid").getElement('v.value').value;
                if(timeString.length<=6){
                    component.set("v.Locator_Listing.Sunday_Close_Hours_AGN__c",component.find("sunendid").getElement('v.value').value+':00.000');
                }
                 else{
                    component.set("v.Locator_Listing.Sunday_Close_Hours_AGN__c",component.find("sunendid").getElement('v.value').value);
                }
            }
        }
        
        
        //console.log(cmp.get('v.value'));
        //alert(lclist.Monday_Open_Hours_AGN__c);
        
        //component.set("v.RegistrationComplete",true);
        /*var message = 'alohaCallingCAPTCHA';
        var vfOrigin = component.get("v.CommunityBaseURL");//"https://gcspeudev-allergancommunityeu.cs84.force.com";
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);*/
        helper.validateAndSaveRecords(component,event);
    },
    doneRendering : function(component,event, helper){
        //console.log('doneRendering');
    },
    getBrandSelectedValues: function(component,event, helper){
        var FinalBrand = '';
        var Brand = event.getParam("values");
        for(var i=0; i< Brand.length;i++)
        {
            if(i === 0)
            {
                FinalBrand = Brand[i];
            }
            else
            {
                FinalBrand = FinalBrand + ';' + Brand[i];
            }
        }
        
        var loclst = component.get("v.Locator_Listing");
        loclst.Brand_AGN__c = FinalBrand;
        component.set("v.Locator_Listing",loclst);
    },
    cancelTermsCondition : function(component,event, helper){
        component.set("v.termsandcondition",false);
        component.set("v.termsandconditionpopup",false);
    },
    saveTermCondition : function(component,event, helper){
        component.set("v.termsandcondition",true);
        component.set("v.termsandconditionpopup",false);
    },
    TermsAndCondition: function(component,event, helper){
        if(event.getParam("value") == true)
        {
            //component.set("v.temptermsandcondition",event.getParam("value"));
            component.set("v.termsandconditionpopup",true);
        }
        else if(event.getParam("value") == false)
        {
            component.set("v.termsandcondition",false);   
        }
    },
    handleBrandChange: function(component,event, helper){
        
    },
    cancelClinicConsent : function(component,event, helper){
        component.set("v.clinicConsent",false);
        component.set("v.clinicConsentPopup",false);
    },
    saveClinicConsent : function(component,event, helper){
        component.set("v.clinicConsent",true);
        component.set("v.clinicConsentPopup",false);
    },
    
    ClinicConsentCheck: function(component,event, helper){
        if(event.getParam("value") == true)
        {
            component.set("v.clinicConsentPopup",true);
        }
        else if(event.getParam("value") == false)
        {
            component.set("v.clinicConsent",false);   
        }
    },  

  //CASL Consent Change
    cancelCASLConsent : function(component,event, helper){
        component.set("v.CASLConsent",false);
        component.set("v.CASLConsentPopup",false);
    },
    saveCASLConsent : function(component,event, helper){
        component.set("v.CASLConsent",true);
        component.set("v.CASLConsentPopup",false);
    },
    CASLConsentCheck: function(component,event, helper){
        if(event.getParam("value") == true)
        {
            component.set("v.CASLConsentPopup",true);
        }
        else if(event.getParam("value") == false)
        {
            component.set("v.CASLConsent",false);   
        }
    }, 
    //CASL Consent End
        
    timeBlurHandle : function(component,event, helper){
        if((event.getSource().get("v.value") != null) || event.getSource().get("v.value") != undefined)
        {
            var auraidvar = event.getSource().get("v.name");
            var toggleText = component.find(auraidvar);
            if(toggleText != null)
            {
                //console.log(toggleText.length+'abcdfd');
            }
            
            /*if ($A.util.isArray(toggleText)){
                  toggleText.forEach( function (toggleText){
                      $A.util.addClass(toggleText,'timelabeldisplay');
                      console.log('wee'+toggleText);
                  });
             }*/
            $A.util.addClass(toggleText,'timelabeldisplay');
            //console.log('abc');
            //component.set("v.containstimeValue",true);
        }
        else{
            //component.set("v.containstimeValue",false);
            var auraidvar = event.getSource().get("v.name");
            var toggleText = component.find(auraidvar);
            $A.util.removeClass(toggleText,'timelabeldisplay');
        }
        
    }    
    
})