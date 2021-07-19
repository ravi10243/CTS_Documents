({
    //MAX_FILE_SIZE: 750000;
    doInit : function(component, event, helper) {
        component.set("v.IsMobileDevice",$A.get("$Browser.isPhone")); 
        component.set("v.isEdit",false);
        var LocatorlistingId = '';
        var query = location.search.substr(1);
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'lcid')
            {
                LocatorlistingId = decodeURIComponent(item[1]);
                console.log('LocatorlistingId : '+LocatorlistingId);
            }
        });
         /*TM2.0 Portal banner related change*/
        var serverAction = component.get("c.isSiteUnderMaintenance");
        serverAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isSiteUnderMaintenance", response.getReturnValue());
            }
        });
        $A.enqueueAction(serverAction);
        /*TM2.0 Portal banner related change*/
        //Get Clinic Admin Data from apex controller
        console.log('In INit');
        component.set("v.spinner",true);       
        var action = component.get("c.fetchClinicAdminDetails");
        action.setCallback(this, function(a) {
            component.set("v.Clinic_Admin_details", a.getReturnValue()); //set data in view
            var acc = component.get("v.Clinic_Admin_details");
            component.set("v.clinicID", acc.Primary_Parent_vod__c);
            
            //console.log('In INit11');
            //Get Clinic Data from apex controller    
            var action1 = component.get("c.fetchClinicDetails"); 
            action1.setParams({
                "loclstId": LocatorlistingId
            }); 
            action1.setCallback(this, function(a) {
                component.set("v.Clinic_details", a.getReturnValue());//set data in view 
                var acct = component.get("v.Clinic_details");
                //console.log('second method');
                // component.set("v.clinicID", acct.Id);
                //  console.log('CLinic ID  '+acct.Id);
                
                //Get Locator Listing data from apex controller      
                var action2 = component.get("c.fetchLocatorListing");
                //console.log('CLinic ID in Controller '+ component.get("v.clinicID"));
                action2.setParams({
                    "locId":LocatorlistingId
                }); 
                action2.setCallback(this, function(a) {
                    var lc= a.getReturnValue(); 
                    component.set("v.Locator_Listing", lc);//set the data in view 
                    var brandstr = lc.Brand_AGN__c;
                    //GTM
                    component.set("v.GTMCountry", lc.Country_AGN__c);
                    //GTM
                    console.log('Brand list :'+brandstr);                    
                    if(brandstr.includes(';') === true)
                    {
                        var opt = [];
                        var singlebrand = brandstr.split(';');
                        for(var key in singlebrand)
                        {
                            //console.log('Each brand'+singlebrand[key]);
                            opt.push(singlebrand[key]);
                        }
                        component.set("v.selectedBrandvalues",opt);
                    }
                    else
                    {
                        component.set("v.selectedBrandvalues",brandstr);
                    }
                    
                    //console.log('time value'+ lc.Monday_Open_Hours_AGN__c);
                    //mon_open = lc.Monday_Open_Hours_AGN__c;                 
                    
                    var lcc = component.get("v.Locator_Listing");                    
                    //console.log("LOcator listing got from apex "+ lcc.Id);
                    //console.log('JSON String'+JSON.stringify(component.get("v.Locator_Listing")));
                    component.set("v.LocatorListingID", lcc.Id);
                    
                    var action3 = component.get("c.getCountryWiseFields");
                    /*action3.setParams({
                        'CountryCode': component.get("v.Clinic_Admin_details.Country_Code__c") 
                    });*/
                    action3.setCallback(this, function(response) {
                        if(response.getState() === 'SUCCESS') {
                            var lst = response.getReturnValue();
                            console.log('CountryWiseFields lst'+lst);
                            var arrayMapKeys = [];
                            for(var key in lst){
                                arrayMapKeys.push({key: key, value: lst[key]});
                            }
                            
                            component.set("v.CountryWiseFieldsMap",arrayMapKeys);
                            component.set("v.spinner",false);                             
                            var Id=lcc.Id;
                            console.log('ID'+Id);                           
                            /* var action10 = component.get("c.imagefetch"); 
                              action10.setParams({
                                parentId:Id
                            });
                            
                            action10.setCallback(this, function(response) {
                                if(component.isValid()) {
                                    if(response.getState() === 'SUCCESS') {
                                        var attachId = response.getReturnValue();
                                        component.set("v.imageurl",attachId);
                                        console.log("DP"+compoent.get("v.imageurl"));
                                    }
                                    else
                                    {
                                        console.log('awserror');
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                            }
                                        }
                                    }
                                }
                            });
                            
                            
                            $A.enqueueAction(action10); */
                            //console.log('Salutation lst111'+component.get("v.SalutationList"));
                            component.set("v.pageLoaded",true); 
                            var a1 = component.get("c.calculateTime");
                            $A.enqueueAction(a1);
                        }
                    });$A.enqueueAction(action3);
                }); $A.enqueueAction(action2);            
            }); $A.enqueueAction(action1); 
        });$A.enqueueAction(action); 
        
        var action4 = component.get("c.getBrandPicklistValuesLoggedUser");								
        
        //action.setStorable();
        action4.setCallback(this, function(response) {
            console.log('response.getState()'+response.getState());
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                console.log('Salutation lst'+lst);
                //var BrandList = [];
                var BrandList1 = [];
                 var itr=0;  // Duallist Box Logic added for Brand  
                for(var key in lst){
                   itr++;    // Duallist Box Logic added for Brand 
                    console.log('nu'+key);
                    //BrandList.push({Name: lst[key], selected: false});
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                //component.set("v.BrandValues",BrandList);
                component.set("v.BrandValues1",BrandList1); 
                component.set("v.brandSize",itr);  // Duallist Box Logic added for Brand 
                //component.set("v.spinner",false);
                //console.log('Salutation lst111'+component.get("v.SalutationList"));
                //AWS

            
                
                //AWS
            }
        });
        $A.enqueueAction(action4);
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
        
        var action10 = component.get("c.imagefetch"); 
        
        action10.setParams({
            "loclstId": LocatorlistingId
        }); 
        
        action10.setCallback(this, function(response) {
            if(component.isValid()) {
                if(response.getState() === 'SUCCESS') {
                    var attachId = response.getReturnValue();
                    component.set("v.imageurl",attachId);
                    component.set("v.imageurlTemp",attachId);
                    //alert('fgdfkh');
                    //console.log('DP'+compoent.get("v.imageurl"));
                }
                else
                {
                    //console.log('awserror');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                }
            }
        });
        
        
        $A.enqueueAction(action10);
        //Show hide back button        
        var action11 = component.get("c.showhidebackbutton"); 
        
        action11.setParams({
            "loclstId": LocatorlistingId
        }); 
        
        action11.setCallback(this, function(response) {
            if(component.isValid()) {
                if(response.getState() === 'SUCCESS') {
                    var para = response.getReturnValue();
                    component.set("v.success",para);
                    
                }
                else
                {
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                }
            }
        });
        
        
        $A.enqueueAction(action11);
        //Show hide back button
        //Show/Hide Add Pactioner Section 
        var getHCPStatus = component.get("c.getHCPEnableStatus");       
        getHCPStatus.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getDis = response.getReturnValue();
                component.set("v.isHCPEnabled",getDis);  
                console.log("getDis>>"+getDis);
            }
        });
        $A.enqueueAction(getHCPStatus);
        
        var getDisclaimer = component.get("c.getDisclaimerSettings");        	
        getDisclaimer.setCallback(this, function(response) {	
            if(response.getState() === 'SUCCESS') {	
                var getDis = response.getReturnValue();	
                component.set("v.showCTDisclmr",getDis);              	
            }	
        });	
        $A.enqueueAction(getDisclaimer);
        
        //Thailand CR
        var getCountryCode = component.get("c.getUserCountryCode");           
        getCountryCode.setCallback(this, function(response) {  
            if(response.getState() === 'SUCCESS') {   
                var getCountry = response.getReturnValue();  
                component.set("v.URLCountry",getCountry); 
                var getImageCheck = component.get("c.isClinicImageEnabled");
                getImageCheck.setParams({
                    'countryCode': getCountry
                });
                getImageCheck.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        var getCheck = response.getReturnValue();
                        component.set("v.showClinicImage",getCheck);   
                    }
                });
                $A.enqueueAction(getImageCheck);
                //Thailand CR Clinic Timing
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
                //Thailand CR Clinic Timing
                
                //added as a part of two column layout for canada
                var getTwoLayer = component.get("c.isTwoLayerLayout");
                getTwoLayer.setParams({
                    'countryCode': component.get("v.URLCountry")
                });
                getTwoLayer.setCallback(this, function(response) {
                    //var state = response.getState();
                    if (response.getState() === "SUCCESS"){
                        var a = response.getReturnValue();
                        component.set("v.twoLayerLayout", a);
                        //console.log("twoLayerLayout ");
                        //component.set("v.PickListValues", response.getReturnValue());
                    } 
                });
            $A.enqueueAction(getTwoLayer);
        //End
            }  
        });   
        $A.enqueueAction(getCountryCode);
        //Thailand CR 
        
        
    },
    /*addPractitioner : function(component,event,helper){
        //jQuery.noConflict();
        //jQuery('.AddNewPractitioner').fadeIn('fast'); 
        component.set("v.openModal",true);
    },
    HandlePopup : function(component,event,helper){
        component.set("v.openModal",false);
    },*/
    editButton : function(component,event,helper){
        component.set("v.editBtn",false); 
        component.set("v.isEdit",true);
    } ,
    backButton : function(component,event,helper){
        var baseUrl = $A.get("$Label.c.AGN_ICL_Community_Base_URL");
        var suffixUrl = $A.get("$Label.c.AGN_ICL_Community_Suffix");
        var url = baseUrl + suffixUrl;
        window.location.replace(url + '/s/agn-icl-cliniclistviewpage');
        
    } ,
    saveButton : function(component,event,helper)
    {  
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
       
        helper.validateAndSaveRecords1(component);
        
        // helper.updateTime(component);
        //component.set("v.editBtn",true);  
    },
    testbutton : function(component,event,helper){
        console.log('save button test');
    },
    handleBrandChange : function(component, event, helper) {
    },
    logout : function(component, event) {
        var baseUrl = $A.get("$Label.c.AGN_ICL_Community_Base_URL");
        var suffixUrl = $A.get("$Label.c.AGN_ICL_Community_Suffix");
        var url = baseUrl + suffixUrl;
        //GTM
        component.set("v.fireLogout", true);
        var pageURL=document.URL;
        pageURL =pageURL.split(".com")[1];
        pageURL =pageURL.split("?")[0];
        var pageTitile=document.title;
        component.set("v.GTMPageURL",pageURL);
        component.set("v.GTMPageTitle",pageTitile);
        //GTM       
        var action = component.get("c.fetchUsercountry");       
        action.setCallback(this, function(a) {
            var country=a.getReturnValue();
            window.location.replace(url + '/AGN_ICL_Portal_Logout?country='+country);
        });
        $A.enqueueAction(action); 
    },
    NewClinic : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/agn-icl-newclinicregistration"
        });
        urlEvent.fire();
    },
    cancelButton : function(component, event, helper) {
        component.set("v.spinner",true);
        var action = component.get('c.doInit');
        action.setCallback(component,
                           function(response) {
                               var state = response.getState();
                               if (state === 'SUCCESS'){
                                   $A.get('e.force:refreshView').fire();
                                   component.set("v.spinner",false);
                               } else {
                                   //do something
                               }
                           }
                          );
        $A.enqueueAction(action);
        component.set("v.editBtn",true); 
    },
    AddClinicButton : function(component, event, helper) {
        
    },
    ValidateAndSaveRecords : function(component,event,helper){
        //console.log('save button2222');
        component.set("v.editBtn","true");  
        // helper.validateAndSaveRecords(component,event);
    } ,
    calculateTime : function(component,event)
    {
        
        var lc =  component.get("v.Locator_Listing");
        var mnstart = lc.Monday_Open_Hours_AGN__c;       
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            //alert(hours+'>>'+minutes)
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;           
            if(hours<10)
            {
                lc.Monday_Open_Hours_AGN__c ='0'+hours+':'+minutes;
            }
            else
            { 
                lc.Monday_Open_Hours_AGN__c =hours+':'+minutes;
            }
            $A.util.addClass(component.find("monstart"),'timelabeldisplay');
        }
        var mnend = lc.Monday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10) 
            {
                lc.Monday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Monday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("monend"),'timelabeldisplay');
        }
        //Calculating Start Time for Tuesday 
        var mnstart = lc.Tuesday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Tuesday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Tuesday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("tuestart"),'timelabeldisplay');
        }
        var mnend = lc.Tuesday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Tuesday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Tuesday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("tueend"),'timelabeldisplay');
        }
        //Calculating Start Time for Wednesday 
        var mnstart = lc.Wednesday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Wednesday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Wednesday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("wedstart"),'timelabeldisplay');
        }
        var mnend = lc.Wednesday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Wednesday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Wednesday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("wedend"),'timelabeldisplay');
        }
        //Calculating Start Time for Thursday 
        var mnstart = lc.Thursday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Thursday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Thursday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("thusstart"),'timelabeldisplay');
        }
        var mnend = lc.Thursday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Thursday_Close_Hours_AGN__c ='0'+hours+':'+minutes;
            }
            else
            {
                lc.Thursday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("thusend"),'timelabeldisplay');
        }
        //Calculating Start Time for Friday
        var mnstart = lc.Friday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Friday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Friday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("fristart"),'timelabeldisplay');
        }
        var mnend = lc.Friday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Friday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Friday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("friend"),'timelabeldisplay');
        }
        //Calculating Start Time for Saturday
        var mnstart = lc.Saturday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Saturday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Saturday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("satstart"),'timelabeldisplay');
        }
        var mnend = lc.Saturday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Saturday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Saturday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("satend"),'timelabeldisplay');
        }
        //Calculating Start Time for Sunday
        var mnstart = lc.Sunday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Sunday_Open_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Sunday_Open_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("sunstart"),'timelabeldisplay');
        }
        var mnend = lc.Sunday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;
            if(hours<10)
            {
                lc.Sunday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                lc.Sunday_Close_Hours_AGN__c = hours+':'+minutes;
            }
            $A.util.addClass(component.find("sunend"),'timelabeldisplay');
        }
        component.set("v.Locator_Listing", lc);
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
        //GTM
        jQuery.noConflict();
        //alert('*************** Inside do Init1 Method *****************')
        
        jQuery("document").ready(function(){
            
            //alert('Inside jquery'); 
            jQuery('.gcap-frame').click(function(){
                //alert("asasdas");
            })
            //alert("Jquery");
            
        });
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
    setSalutationVal : function(component, event, helper){
        console.log(component.get("v.SalutationList"));
        var a1 = component.get("v.SelectedSalutation");
        component.set("v.Clinic_Admin_details.Salutation",a1);
        // a.Salutation = a1;
        console.log(component.get("v.Clinic_Admin_details"));
    },
    ClinicCreationSection : function(component, event, helper){
        var clinic_admin = component.get("v.Clinic_Admin_details");
        console.log('val '+clinic_admin);
        component.set("v.Clinic_Next",true);
    },
    //AWS
    
    handleFilesChange: function(component, event, helper) {
        console.log('dosomething');
        var fileName = $A.get("$Label.c.AGN_ICL_NoneSelected") ;
        
        var fileInput = component.find("fileId").getElement();
        var file = fileInput.files[0];
        console.log('file',file);
        //var fileName;
        
        var fileExt = (file.name).substring((file.name).indexOf(".")+1);
        //if (fileExt != 'png' && fileExt != 'jpeg' && fileExt != 'jpg' && fileExt != 'gif') {
        
        if(!(file.name.indexOf(' ') >= 0)){            
            if(file.type == 'image/jpeg' || file.type =='image/png'){
                if (file.size <=750000) {
                    fileName = file.name;                
                    component.set("v.imageurl",URL.createObjectURL(file));
                }
                else{
                    alert($A.get("$Label.c.AGN_ICL_Filesize") + '\n' +
                          $A.get("$Label.c.AGN_ICL_Selectedfile")  + file.size/1000 +'KB');
                    component.set("v.imageurl",component.get("v.imageurlTemp"));
                    component.set("v.showLoadingSpinner", false);
                    return;
                }
            }
            else{
                alert($A.get('$Label.c.AGN_ICL_ClinicAdmin_ImgUploadErr') + fileExt);
                component.set("v.imageurl",component.get("v.imageurlTemp"));
                return;
            }
        }else{
            alert($A.get("$Label.c.AGN_ICL_ImageUpload_InvalidNameFormat"));
            component.set("v.imageurl",component.get("v.imageurlTemp"));
            return;
        }
        component.set("v.fileName", fileName);
    },
    fetchlocatorimage:function(component,event,Id)
    {
        var action = component.get("c.fetchimage"); 
        console.log('parentid'+Id);
        action.setParams({
            parentId: Id
            
        });
        
        action.setCallback(this, function(response) {
            if(component.isValid()) {
                if(response.getState() === 'SUCCESS') {
                    var attachId = response.getReturnValue();
                    component.set("v.imageurl",attachId);
                    console.log("DP"+component.get("v.imageurl"));
                }
                else
                {
                    console.log('awserror');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                }
            }
        });
        
        
        $A.enqueueAction(action); 
        
    },
    //AWS
    ValidateAndSaveRecords : function(component, event, helper){
        helper.validateAndSaveRecords(component,event);
    },
    //GTM
    handlePractionsersDetails : function(component, event, helper){
        var brand=  event.getParam("param").Brand_AGN__c;
        component.set("v.firePractionser",true);
        component.set("v.GTMbrand",brand);
        var pageURL=document.URL;
        pageURL =pageURL.split(".com")[1];
        pageURL =pageURL.split("?")[0];
        var pageTitile=document.title;
        component.set("v.GTMPageURL",pageURL);
        component.set("v.GTMPageTitle",pageTitile);
    }
    
})