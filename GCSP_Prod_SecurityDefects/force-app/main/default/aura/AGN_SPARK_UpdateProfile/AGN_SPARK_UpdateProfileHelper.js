({
	helperMethod : function(component, event,object) {
        if(object.Allergan_Customer_Registration_AGN__r.Profession_Spark_AGN__C !=null||object.Allergan_Customer_Registration_AGN__r.Profession_Spark_AGN__C !=''){
            if(object.Allergan_Customer_Registration_AGN__r.Profession_Spark_AGN__C =='Doctor'){
                var elements = document.getElementsByClassName("doctor");
                elements.classList.add("doctor");
                elements.classList.remove("patient");
                elements.classList.remove("dentist");
            }
            else if(object.Allergan_Customer_Registration_AGN__r.Profession_Spark_AGN__C == 'Nurse'){
                var elements = document.getElementsByClassName("patient");
                elements.classList.add("doctor");
                elements.classList.remove("patient");
                elements.classList.remove("dentist");
                var docelements = document.getElementsByClassName("doctor");
                docelements.classList.remove("doctor");
                docelements.classList.add("patient");
                
            }
            else{
                var elements = document.getElementsByClassName("dentist");
                elements.classList.add("doctor");
                elements.classList.remove("patient");
                elements.classList.remove("dentist");
                var docelements = document.getElementsByClassName("doctor");
                docelements.classList.remove("doctor");
                docelements.classList.add("patient");
            }
        }
	},
    fetchUserDetails : function(component){
        var action = component.get("c.userDetailData"); 
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
               var s = a.getReturnValue();
                
               component.set('v.userDetails', a.getReturnValue());
            }
            console.log(a.getReturnValue());
            //alert('Value '+ a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    editProfile : function(component, event, helper) {
        component.set("v.isView",false);    
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
    
    getPicklistValues:function(component,event,helper){ 
        var profession = component.get("c.callUtility");
        profession.setParams({ 
            objectType 			: 	'Allergan_Customer_Registration_AGN__c',
            selectedField 		:	"Aesthetics_Stage_Spark_AGN__c"
        });
        profession.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                component.set("v.profession",rtnValue);
            }
        });
        $A.enqueueAction(profession);
        
        var aestheticPat = component.get("c.callUtility");
        aestheticPat.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Number_Of_Aesthetics_Patients_Spark_AGN__c"
        });
        aestheticPat.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                component.set("v.aestheticPat",rtnValue);
            }
        });
        $A.enqueueAction(aestheticPat);
        
        var daysPerWeek = component.get("c.callUtility");
        daysPerWeek.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Days_Per_Week_Spark_AGN__c"
        });
        daysPerWeek.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                component.set("v.daysPerWeek",rtnValue);
            }
        });
        $A.enqueueAction(daysPerWeek);
        
        var planDays = component.get("c.callUtility");
        planDays.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Planed_Days_Per_Week_Spark_AGN__c"
        });
        planDays.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                component.set("v.planDays",rtnValue);
            }
        });
        $A.enqueueAction(planDays);
        
        
        var currLoc = component.get("c.callUtility");
        currLoc.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Current_Practice_Locations_Spark_AGN__c"
        });
        currLoc.setCallback(this, function(response){
            var rtnValue = response.getReturnValue();
            if (rtnValue != null) {
                component.set("v.currLoc",rtnValue);
            }
        });
        $A.enqueueAction(currLoc);
    },  
    
    validateForm: function(component, event, helper){
       /* var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var regNo 				= component.get('v.userDetails.userData.Registration_License_Number_AGN__c');
        var showMarketingcontnt = component.get('v.userDetails.userData.Accepted_Spark_Marketing_Consent_AGN__c');
        var showEventcontnt 	= component.get('v.userDetails.userData.Accepted_Spark_Event_Consent_AGN__c');
        var acceptPolicy 		= component.get('v.userDetails.userData.Accepted_Spark_privacy_policy_AGN__c');
        var phnNumber			= component.get("v.userDetails.userData.Phone_AGN__c");
        
        if(phnNumber.length != 10){
            allValid = false;
            component.set("v.errorMessage",["Please enter 10 digit valid phone number:" + phnNumber]);
        }
        
        if(regNo == '' || regNo == undefined){
            allValid = false;
            component.set("v.errorMessage", 'Please update the Medical Registration Number.');   
        }
        if(allValid == false){
            component.set("v.showError",true);
        }
        
        if(allValid == true){
            component.set("v.showError",false);
        }
        allValid =true;
        return allValid;*/
        return true;
    },
    
    saveProfile : function(component, event, helper){
        var showError = component.get("v.showError");  
        
        if(!showError){
            jQuery('#errorbot').html('Data is being submitted');
            jQuery('.saveButton').html('Saving data..');
            var usrdtls = component.get("v.userDetails")
            var action = component.get("c.updateDetails");      
            action.setParams({ 
                usrDetails :usrdtls
            });       
            action.setCallback(this, function(response){
                var saveProfileRtn = response.getReturnValue();  
                var state = response.getState();
                
                if(state == 'SUCCESS') {
                     jQuery('#saveButton').html('Save');
                    jQuery('#errorbot').html('');
                    component.set("v.isView",true);
                    var elmnt = document.getElementById("scrollUp");
					elmnt.scrollIntoView();
                   
                    location.reload();
                } 
            });
            $A.enqueueAction(action);
        }   
        else{
            jQuery('#errorbot').html('Please check validation error');_
        }
    },
    getbannerImage : function(component) {
       var action = component.get("c.getImages");
       action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	component.set("v.AGNSPARKImage", response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
	}
})