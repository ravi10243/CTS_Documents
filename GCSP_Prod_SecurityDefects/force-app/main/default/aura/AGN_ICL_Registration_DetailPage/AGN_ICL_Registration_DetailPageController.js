({
    doInit : function(component, event, helper) {
        
        var query = location.search.substr(1);
		query.split("&").forEach(function(part) {
		var item = part.split("=");
		 if(item[0] === 'lcid')
            {
                component.set("v.LocatorListingID",decodeURIComponent(item[1]));
                console.log('LocatorListingID'+component.get("v.LocatorListingID"));
            }
		   });
        //Get Clinic Admin Data from apex controller
        component.set("v.spinner",true);
                //Get Locator Listing data from apex controller  
                console.log('dfdfdfdfh'+component.get("v.LocatorListingID"));    
                var action2 = component.get("c.fetchLocatorListing");
                action2.setParams({
                    locId : component.get("v.LocatorListingID")       
                }); 
                action2.setCallback(this, function(a) {
                    var lc= a.getReturnValue(); 
                    component.set("v.Locator_Listing", lc);//set the data in view 
                    var brandstr = lc.Brand_AGN__c;
                    console.log('Brand list :'+brandstr);
                    if(brandstr.includes(';') === true)
                    {
                        var opt = [];
                        var singlebrand = brandstr.split(';');
                        for(var key in singlebrand)
                        {
                            console.log('Each brand'+singlebrand[key]);
                            opt.push(singlebrand[key]);
                        }
                        component.set("v.selectedBrandvalues",opt);
                    }
                    else
                    {
                        component.set("v.selectedBrandvalues",brandstr);
                    }
                    
                   
                    var a = component.get("c.calculateTime");
                    $A.enqueueAction(a);
                    
                    var lcc = component.get("v.Locator_Listing");                    
                    
                    var action3 = component.get("c.getCountryWiseFieldsWithoutAdminOAM");
                    action3.setCallback(this, function(response) {
                        if(response.getState() === 'SUCCESS') {
                            var lst = response.getReturnValue();
                            console.log('CountryWiseFields lst'+lst);
                            var arrayMapKeys = [];
                            for(var key in lst){
                                arrayMapKeys.push({key: key, value: lst[key]});
                            }
                            component.set("v.CountryWiseFieldsMap",arrayMapKeys);
                            var action4 = component.get("c.getBrandPicklistValues");
                            
                            //action.setStorable();
                            action4.setCallback(this, function(response) {
                                if(response.getState() === 'SUCCESS') {
                                    var lst = response.getReturnValue();
                                    var BrandList1 = [];
                                    for(var key in lst){
                                        console.log('nu'+key);
                                        BrandList1.push({label : lst[key],value : lst[key]});
                                    }
                                    component.set("v.BrandValues1",BrandList1);
                                    component.set("v.spinner",false);
                                }
                            });
                            $A.enqueueAction(action4);
                        }
                    });$A.enqueueAction(action3);
                }); $A.enqueueAction(action2);            
           
        //AWS
        var action10 = component.get("c.imagefetch"); 
        action10.setParams({
            "loclstId": component.get("v.LocatorListingID")
        });                
        action10.setCallback(this, function(response) {
            if(component.isValid()) {
                if(response.getState() === 'SUCCESS') {
                    var attachId = response.getReturnValue();
                    component.set("v.imageurl",attachId);
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
        //AWS
    },
    addPractitioner : function(component,event,helper){
        //jQuery.noConflict();
        //jQuery('.AddNewPractitioner').fadeIn('fast'); 
        console.log('dfdhfdhf');
        component.set("v.openModal",true);
    },
    HandlePopup : function(component,event,helper){
        component.set("v.openModal",false);
    },
    editButton : function(component,event,helper){
        component.set("v.editBtn",false);        
    } ,
    saveButton : function(component,event,helper)
    {       
        console.log('save button');
        helper.validateAndSaveRecords1(component); 
        // helper.updateTime(component);
        //component.set("v.editBtn",true);  
    },
    testbutton : function(component,event,helper){
        console.log('save button test');
    },
    handleBrandChange : function(component, event, helper) {
    },
    logout : function(component, event, helper) {
        var lcc = component.get("v.Locator_Listing");
        var cladm = component.get("v.Clinic_Admin_details");
        var country = cladm.Country_Code__c;
        var lang = lcc.User_Language_AGN__c;
        var baseUrl = $A.get("$Label.c.CommunityBaseURL");
        //gcldev-allergancore.cs84.force.com
        //window.location.replace("https://d17-allergan.cs88.force.com/allergancustomer/servlet/networks/switch?startURL=%2Fsecur%2Flogout.jsp?retUrl");
        window.location.replace('https://gcldev-allergancommunitycore.cs84.force.com/gcldevallergan' + '/AGN_ICL_Portal_Logout');
        //window.location.replace('https://gcldev-allergancore.cs84.force.com/GlobalClinicLocator');
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
    ValidateAndSaveRecords : function(component,event,helper){
        console.log('save button2222');
        component.set("v.editBtn","true");  
        // helper.validateAndSaveRecords(component,event);
    } ,
    
    /*updateTime : function(component,event)
    {
        
        const cmps = component.find("dateId");
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.value")) == ''){
                    console.log("Hello Fireinds Value de do ");
                    //missing message
                }
                else{
                    console.log('Balle Balle Time '+jQuery.trim(cmp.get("v.value")));
                    
                } 
            });
        }
        
        
    },*/
    calculateTime : function(component,event)
    {
        var lc =  component.get("v.Locator_Listing");
        //Calculating Start Time for Monday 
        var mnstart = lc.Monday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
            if(hours<10) 
            {
                lc.Monday_Close_Hours_AGN__c = '0'+hours+':'+minutes;
            }
            else
            {
                /*if(minutes === 0)
                {
                    lc.Monday_Close_Hours_AGN__c = hours+':'+'00';
                }
                else
                {*/
                    lc.Monday_Close_Hours_AGN__c = hours+':'+minutes;
               // }
                
            }
        }
        //Calculating Start Time for Tuesday 
        var mnstart = lc.Tuesday_Open_Hours_AGN__c;
        if(mnstart!= null)
        {
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnstart/3600000);  
            var min = parseInt(mnstart%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
            var hours = parseInt(mnend/3600000);  
            var min = parseInt(mnend%3600000);
            var min = min/3600000;  
            var minutes = min*60;
            minutes = (minutes === 0)? '00' : minutes;
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
    scriptsLoaded : function(component, event, helper) {
        jQuery.noConflict();
        console.log('*************** Inside do Init1 Method *****************')
        
        jQuery("document").ready(function(){
            
            console.log('Inside jquery'); 
            
            //alert("Jquery");
            
        });
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
            if (fileExt != 'png' && fileExt != 'jpeg' && fileExt != 'jpg' && fileExt != 'gif') {
                alert(' Only image files (png, jpeg, jpg and gif) are supported.\n Selected file type: .' + fileExt);
                return;
            }
       
       if (file.size <=750000) {
     
            fileName = file.name;
        
          component.set("v.imageurl",URL.createObjectURL(file));
                   
        }
            if (file.size > 750000) {
             alert($A.get("$Label.c.AGN_ICL_Filesize") + '\n' +
              $A.get("$Label.c.AGN_ICL_Selectedfile")  + file.size/1000 +'KB');
                 component.set("v.imageurl",null);
             component.set("v.showLoadingSpinner", false);
        return;
        
       
     
        }
          component.set("v.fileName", fileName);

            
    },
        fetchlocatorimage:function(component,event,Id)
    {
       var action = component.get("c.fetchimage"); 
      console.log('parentid'+parentid);
        action.setParams({
             parentId: Id
           
        });
 
        action.setCallback(this, function(response) {
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
            
       
            $A.enqueueAction(action); 
         
    },
    //AWS
    ValidateAndSaveRecords : function(component, event, helper){
        helper.validateAndSaveRecords(component,event);
    },
    backButton: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
                "url": "/agn-icl-cliniclistview"
            });
        urlEvent.fire();
    }
    
})