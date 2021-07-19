({
    doInit : function(component, event, helper) {
        
        var query = location.search.substr(1);
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'accid')
            {
            	component.set("v.clinicID",decodeURIComponent(item[1]));
            }
        });
        
        component.set("v.spinner",true);
        var action2 = component.get("c.getBrandPicklistValues");
        
        //action.setStorable();
        action2.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                 var lst = response.getReturnValue();
                console.log('Salutation lst'+lst);
                var BrandList = [];
                var BrandList1 = [];
                for(var key in lst){
                    console.log('nu'+key);
                    BrandList.push({Name: lst[key], selected: false});
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                component.set("v.BrandValues",BrandList);
                component.set("v.BrandValues1",BrandList1);
                
            }
        });
        $A.enqueueAction(action2);
      
     var action8 = component.get("c.IsLocatorListingCreated"); 
            action8.setParams({
                "clinicID": component.get("v.clinicID")
            }); 
            action8.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    if(!response.getReturnValue())
                    {
            var action1 = component.get("c.fetchClinicDetails"); 
            action1.setParams({
                "clinicID": component.get("v.clinicID")
            }); 
            action1.setCallback(this, function(a) {
                component.set("v.Clinic_details", a.getReturnValue());//set data in view 
                var clinicAcc = component.get("v.Clinic_details");
                console.log('Clinic ccccc: '+clinicAcc.Id);
                var action5 = component.get("c.getAddressDetails");
                action5.setParams({
                    "clinicID": component.get("v.clinicID")
                }); 
                action5.setCallback(this, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        var lst = response.getReturnValue();
                        component.set("v.Address_details",lst);
                        
                        var action3 = component.get("c.getCountryWiseFields");
                        
                        action3.setCallback(this, function(response) {
                            if(response.getState() === 'SUCCESS') {
                                var lst = response.getReturnValue();
                                component.set("v.spinner",false);
                                var arrayMapKeys = [];
                                for(var key in lst){
                                    arrayMapKeys.push({key: key, value: lst[key]});
                                }
                                component.set("v.CountryWiseFieldsMap",arrayMapKeys);
                            }
                        });$A.enqueueAction(action3);
                    }
                });$A.enqueueAction(action5);
            });$A.enqueueAction(action1);
                }
                    else{
                        component.set("v.spinner",false);
                        component.set("v.RegistrationComplete",true);
                    }
                }
                });$A.enqueueAction(action8);
        //});$A.enqueueAction(action);
        
         var action6 = component.get("c.gettermsandcondition");
        action6.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var getres = response.getReturnValue();
               component.set("v.iclterms",getres);              
            }
        });
        $A.enqueueAction(action6);
        
    },
    getBrandSelectedValues: function(component,event,helper){
        var FinalBrand = '';
        var Brand = event.getParam("values");
        for(var i=0; i< Brand.length;i++)
        {
            if(i === 0)
            {
                FinalBrand = Brand[i];
                console.log('Zero'+FinalBrand);
            }
            else
            {
                FinalBrand = FinalBrand + ';' + Brand[i];
                console.log('More'+FinalBrand);
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
    ValidateAndSaveRecords : function(component, event, helper){
        //component.set("v.RegistrationComplete",true);
        helper.validateAndSaveRecords(component,event);
    },
    handleBrandChange: function(component,event, helper){
        
    },
    backbutton: function(component, event, helper) {
        helper.Backbuttonhelper(component,event);
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
            
             /*if ($A.util.isArray(toggleText)){
                  toggleText.forEach( function (toggleText){
                      $A.util.addClass(toggleText,'timelabeldisplay');
                      console.log('wee'+toggleText);
                  });
             }*/
        $A.util.addClass(toggleText,'timelabeldisplay');
            console.log('abc');
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