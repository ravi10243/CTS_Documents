({
	doInit : function(component, event, helper) {
		
        component.set("v.IsMobileDevice",$A.get("$Browser.isPhone")); 
        var action = component.get("c.getBrandPicklistValues");
        
        //action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                var BrandList1 = [];
                var itr=0;// Duallist Box Logic added for Brand
                for(var key in lst){
                     itr++;// Duallist Box Logic added for Brand
                    console.log('nu'+key);
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                component.set("v.BrandValues1",BrandList1);
                component.set("v.brandSize",itr);  // Duallist Box Logic added for Brand    
            }
        });
        $A.enqueueAction(action);
          // Duallist Box Logic added for Brand 
               component.get("v.brandSize");
            var action5 = component.get("c.getMultipicklistBrandCount");
            action5.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var mbp = response.getReturnValue();               
                 if( component.get("v.brandSize") > mbp )
                 {
                  component.set("v.showMultiselect",true);
                 }
                }
            });
            $A.enqueueAction(action5);
        // Duallist Box Logic added for Brand END
        
        
        var action1 = component.get("c.getCountryWiseFields");
        action1.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in lst){
                    arrayMapKeys.push({key: key, value: lst[key]});
                    //console.log('Country list value :'+JSON.stringify(component.get("v.Locator_Listing")));
                }
                component.set("v.CountryWiseFieldsMap",arrayMapKeys);
                component.set("v.pageLoaded",true);
                console.log('Country list value :'+JSON.stringify(component.get("v.CountryWiseFieldsMap")));
            }
        });
        //$A.enqueueAction(action);
		$A.enqueueAction(action1);
        
       /* var action2 = component.get("c.fetchfullName");
        
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.UserName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);*/
        var action2 = component.get("c.getclinicadminname");
        
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.UserName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);
        //get Disclaimer Setting from country setting	
        var getDisclaimer = component.get("c.getDisclaimerSettings");        	
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
               
        //Get the country code	
        var getCountryCode = component.get("c.getUserCountryCode");        	
        getCountryCode.setCallback(this, function(response) {	
            if(response.getState() === 'SUCCESS') {	
                var getCountry = response.getReturnValue();	
                component.set("v.iclCountry",getCountry);
                //TH Clinic Timing Disable                
                var getTimingCheck = component.get("c.isClinicTimingEnabled");
                getTimingCheck.setParams({
                    'countryCode': getCountry
                });
                getTimingCheck.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        var getCheck = response.getReturnValue();
                        component.set("v.showClinicTiming",getCheck);              
                    }
                    
                });
                $A.enqueueAction(getTimingCheck);
                //TH Clinic Timing Disable
                
                //added as apart of two column layout
                var action = component.get("c.isTwoLayerLayout");
                action.setParams({
                    'countryCode': component.get("v.iclCountry")
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
            }	
        });	
        $A.enqueueAction(getCountryCode);
        
        	},
     
    timeBlurHandle : function(component,event, helper){
        console.log(event.getSource().get("v.value"));
        if((event.getSource().get("v.value") != null) || event.getSource().get("v.value") != undefined)
        {
            var auraidvar = event.getSource().get("v.name");
            var toggleText = component.find(auraidvar);
            if(toggleText != null)
            {
                console.log(toggleText+'abcdfd');
                //console.log(toggleText.length+'abcdfd');
            }
            
        $A.util.addClass(toggleText,'timelabeldisplay');
        }
        else{
            //component.set("v.containstimeValue",false);
            var auraidvar = event.getSource().get("v.name");
            var toggleText = component.find(auraidvar);
            $A.util.removeClass(toggleText,'timelabeldisplay');
        }
        
    },
     scriptsLoaded : function(component, event, helper) {
        jQuery.noConflict();
       
    },
    ValidateAndSaveRecords : function(component, event, helper) {
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
        helper.validateAndSaveRecords(component,event);
    },
    handleBrandChange: function(component,event, helper){
        
    },
    logout : function(component, event) {
        var baseUrl = $A.get("$Label.c.AGN_ICL_Community_Base_URL");
        var suffixUrl = $A.get("$Label.c.AGN_ICL_Community_Suffix");
        var url = baseUrl + suffixUrl;
        
        var action = component.get("c.fetchUsercountry");
        var country;
        action.setCallback(this, function(a) {
              var usr=a.getReturnValue();
             console.log('country1',usr);
            window.location.replace(url + '/AGN_ICL_Portal_Logout?country='+usr);
 		 });
        $A.enqueueAction(action); 
                    
    },
    RedirectBack : function(component, event) {
        var action = component.get("c.getNoOfLocatorListing");
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                
                var loclst = response.getReturnValue();
                
                /*var lcid = loclst[0].Id;
                    console.log('lcid11'+lcid);*/
                if(loclst.length >1)
                {
                    /*var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/agn-icl-cliniclistviewpage"
                    });
                    urlEvent.fire();*/
                    var baseUrl = $A.get("$Label.c.AGN_ICL_Community_Base_URL");
                    var suffixUrl = $A.get("$Label.c.AGN_ICL_Community_Suffix");
                    var url = baseUrl + suffixUrl;
                    window.location.replace( url + "/s/agn-icl-cliniclistviewpage");
                }
                else if(loclst.length == 1)
                {
                    var lcid = loclst[0].Id;
                    console.log('lcid'+lcid);
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/agn-icl-detailpage?lcid="+lcid
                    });
                    urlEvent.fire();
                }
                    
                 }
        });
        $A.enqueueAction(action);
    },
     backButton : function(component,event,helper){
            
	   window.history.back();
    
    } ,
     cancelClinicConsent : function(component,event, helper){
        console.log('cancel4');
        component.set("v.clinicConsent",false);
        component.set("v.clinicConsentPopup",false);
    },
    saveClinicConsent : function(component,event, helper){
        console.log('cancel5');        
        component.set("v.clinicConsent",true);
        component.set("v.clinicConsentPopup",false);
    },
    ClinicConsentCheck: function(component,event, helper){
         console.log('cancel6');
        if(event.getParam("value") == true)
        {
            component.set("v.clinicConsentPopup",true);
        }
        else if(event.getParam("value") == false)
        {
            component.set("v.clinicConsent",false);   
        }
    },    
})