({
    doInit : function(component, event, helper) {
        component.set("v.IsMobileDevice",$A.get("$Browser.isPhone")); 
        var query = location.search.substr(1);
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'lcid')
            {
                console.log('dfdf');
                component.set("v.LocatorlistingId",decodeURIComponent(item[1]));
                var lc = component.get("v.Locator_Listing");
                lc.Id = component.get("v.LocatorlistingId");
                component.set("v.Locator_Listing",lc);
            }
            //console.log('component.get'+component.get("v.LocatorlistingId")+item[0]+item[1]);
        });
        if(component.get("v.LocatorlistingId") != null)
        {
            var action = component.get("c.fetchLocatorListing");
            action.setParams({
                'locId' : component.get("v.LocatorlistingId")
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS')
                {
                    component.set("v.Locator_Listing",response.getReturnValue());
                    var loclst = response.getReturnValue();
                    console.log('LOC : '+JSON.stringify(loclst));
                    //Added to get the country code required for CANADA layout
                    component.set("v.CustomCountryCode",loclst.Country_Code_AGN__r.Alpha_2_Code_vod__c);
                    if(loclst.IsUpdatedByAdmin_AGN__c === false)
                    {
                        component.set("v.spinner",true);
                        var brandstr = loclst.Brand_AGN__c;
                        if(brandstr.includes(';') === true)
                        {
                            var opt = [];
                            var singlebrand = brandstr.split(';');
                            for(var key in singlebrand)
                            {
                                opt.push(singlebrand[key]);
                            }
                            component.set("v.selectedBrandvalues",opt);
                        }
                        else
                        {
                            component.set("v.selectedBrandvalues",brandstr);
                        }
                        var action1 = component.get("c.getCountryWiseFieldsWithoutAdmin");
                        action1.setParams({
                            'countryid' : loclst.Country_Code_AGN__c
                        });
                        action1.setCallback(this, function(response) {
                            console.log('response.getState()'+response.getState());
                            if(response.getState() === 'SUCCESS') {
                                var lst = response.getReturnValue();
                                var arrayMapKeys = [];
                                for(var key in lst){
                                    arrayMapKeys.push({key: key, value: lst[key]});
                                    //console.log('Country list value :'+JSON.stringify(component.get("v.Locator_Listing")));
                                }
                                component.set("v.CountryWiseFieldsMap",arrayMapKeys);
                                component.set("v.spinner",false);                               
                                //console.log('Country list value :'+JSON.stringify(component.get("v.CountryWiseFieldsMap")));
                            }
                        });
                        //$A.enqueueAction(action);
                        $A.enqueueAction(action1);
                        //added as apart of two column layout
                        var action = component.get("c.isTwoLayerLayout");
                        action.setParams({
                            'countryCode': component.get("v.CustomCountryCode")
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
                        //Thailand CR Clinic Timing
                        var getTimingCheck = component.get("c.isClinicTimingEnabled");
                        getTimingCheck.setParams({
                           'countryCode': loclst.Country_Code_AGN__r.Alpha_2_Code_vod__c
                        });
                        getTimingCheck.setCallback(this, function(response) {
                            if(response.getState() === 'SUCCESS') {
                                var getCheck = response.getReturnValue();
                                component.set("v.showClinicTiming",getCheck); 
                                var timecalculation = component.get("c.calculateTime");
                                $A.enqueueAction(timecalculation);
                            }
                        });
                        $A.enqueueAction(getTimingCheck);
                        //Thailand CR Clinic Timing   
                        var action4 = component.get("c.getBrandPicklistValues");
                        action4.setParams({	
                            'countryCode': loclst.Country_Code_AGN__r.Alpha_2_Code_vod__c
                        });  
                        action4.setCallback(this, function(response) {
                            console.log('response.brand'+response.getState());
                            if(response.getState() === 'SUCCESS') {
                                var lst = response.getReturnValue();
                                var BrandList1 = [];
                                var itr=0;// Duallist Box Logic added for Brand
                                for(var key in lst){
                                    itr++;// Duallist Box Logic added for Brand
                                    BrandList1.push({label : lst[key],value : lst[key]});
                                }
                                component.set("v.BrandValues1",BrandList1);
                                console.log('BrandList1'+BrandList1);
                                component.set("v.pageloaded",true);
                                component.set("v.brandSize",itr);// Duallist Box Logic added for Brand
                            }
                        });
                        $A.enqueueAction(action4); 
                        // Duallist Box Logic added for Brand 
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
                        
                    }
                    else
                    {
                        component.set("v.UpdateSubmitted",true);
                        component.set("v.spinner",false);
                    }
                }
            });$A.enqueueAction(action); 
  
        }
        
        
    },
     
             
           
    calculateTime : function(component,event)
    {
        
        var lc =  component.get("v.Locator_Listing");
        var mnstart = lc.Monday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {            
            var toggleText = component.find("monstart");
            $A.util.addClass(toggleText,'timelabeldisplay');
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            
            minutes = (minutes === 0)? '00' :(minutes < 10)?'0'+minutes : minutes;  
            
            if(hours<10)
            {
                lc.Monday_Open_Hours_AGN__c ='0'+hours+':'+minutes;
            }
            else
            {         
                lc.Monday_Open_Hours_AGN__c = hours+':'+minutes;
            }
        }
        var mnend = lc.Monday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("monend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Tuesday 
        var mnstart = lc.Tuesday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("tuestart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Tuesday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("tueend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Wednesday 
        var mnstart = lc.Wednesday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("wedstart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Wednesday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("wedend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Thursday 
        var mnstart = lc.Thursday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("thusstart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Thursday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("thusend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Friday
        var mnstart = lc.Friday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("fristart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Friday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("friend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Saturday
        var mnstart = lc.Saturday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("satstart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Saturday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("satend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        //Calculating Start Time for Sunday
        var mnstart = lc.Sunday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var toggleText = component.find("sunstart");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        var mnend = lc.Sunday_Close_Hours_AGN__c;
        if(mnend!= null)
        {
            var toggleText = component.find("sunend");
            $A.util.addClass(toggleText,'timelabeldisplay');
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
        }
        component.set("v.Locator_Listing", lc);
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
    backButton : function(component,event,helper){
        
        window.history.back();
        
    }
})