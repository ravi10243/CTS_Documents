({
	doInit : function(component, event, helper) {
       	helper.getbannerImage(component);
        helper.getPicklistValues(component, event);
		helper.fetchUserDetails(component);
	},
	
    clickDoctor:function(component, event, helper) {
      component.set("v.userDetails.userData.Profession_Spark_AGN__c" , "Doctor");
      var usr = component.get("v.userDetails")  ;
    },
    
    clickNurse:function(component, event, helper) {
      component.set("v.userDetails.userData.Profession_Spark_AGN__c" , "Nurse");
        var usr = component.get("v.userDetails")  ;
    },
    
    clickDent:function(component, event, helper) {
      component.set("v.userDetails.userData.Profession_Spark_AGN__c" , "Dentist");
        var usr = component.get("v.userDetails")  ;
    },
    
    editProfile : function(component, event, helper) {
     helper.editProfile(component, event, helper);
    },
    
    clickYes: function(component, event, helper){
        component.set('v.userDetails.userData.Independent_Prescriber_Spark_AGN__c', 'Yes' );
    },
    
    clickNo: function(component, event, helper){
        component.set('v.userDetails.userData.Independent_Prescriber_Spark_AGN__c', 'No');
    },
    
    /*saveProfile : function(component, event, helper){
      helper.saveProfile(component, event, helper);  
    },*/
    
    Dentist:function(component, event, helper) {
     component.set("v.userDetails.userData.Profession_Spark_AGN__c" , "Dentist");
     var usr = component.get("v.userDetails")  ;
    }, 
    
    handleError : function (cmp, evt, helper){
        alert("An error was found in your input.");
    },
    
    updateProfile:function(component,event,helper){ 
        helper.updProfile(component, event);
    },
    
    handleChange: function (component, event) {
        var changeValue = event.getParam("value");
        component.set("v.currentPracticing", changeValue);
    },
    
    submit: function(component, event, helper) {
         if(helper.validateForm(component, event, helper)){
             helper.saveProfile(component, event, helper);
        };
    },
}
)