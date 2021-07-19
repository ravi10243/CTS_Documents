({
    clsModal : function(component, event,helper) {
        document.body.style.overflow="auto";
        console.log("Entering the close modal helper");
        var modalCloseEvt = component.getEvent("ModalCloseEvent");
		modalCloseEvt.fire();
    },
    
    getPicklistValues:function(component,event,helper){ 
       	var profession = component.get("c.getPickListValues");
        profession.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Aesthetics_Stage_Spark_AGN__c"
        });
        profession.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.profession",rtnValue);
            }
        });
        $A.enqueueAction(profession);
        
        var aestheticPat = component.get("c.getPickListValues");
        aestheticPat.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Number_Of_Aesthetics_Patients_Spark_AGN__c"
        });
        aestheticPat.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.aestheticPat",rtnValue);
            }
        });
        $A.enqueueAction(aestheticPat);
        
        var daysPerWeek = component.get("c.getPickListValues");
        daysPerWeek.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Days_Per_Week_Spark_AGN__c"
        });
        daysPerWeek.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.daysPerWeek",rtnValue);
            }
        });
        $A.enqueueAction(daysPerWeek);
        
        var planDays = component.get("c.getPickListValues");
        planDays.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Planed_Days_Per_Week_Spark_AGN__c"
        });
        planDays.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.planDays",rtnValue);
            }
        });
        $A.enqueueAction(planDays);
        
        
        var currLoc = component.get("c.getPickListValues");
        currLoc.setParams({ 
            objectType 			: 	component.get("v.custDetail.sobjectType"),
            selectedField 		:	"Current_Practice_Locations_Spark_AGN__c"
        });
        currLoc.setCallback(this, function(response){
            console.log('response' + response);
            var rtnValue = response.getReturnValue();
            console.log('rtnValue' + rtnValue);
            if (rtnValue != null) {
                component.set("v.currLoc",rtnValue);
            }
        });
        $A.enqueueAction(currLoc);
    },
    
    
    updProfile: function(component, event) {
        console.log("entering the helper of complete my profile");
        var stg 		= component.get("v.custDetail.Aesthetics_Stage_Spark_AGN__c");
        var noAsth		= component.get("v.custDetail.Number_Of_Aesthetics_Patients_Spark_AGN__c");
        var daysPer 	= component.get("v.custDetail.Days_Per_Week_Spark_AGN__c");
        var daysPlanned = component.get("v.custDetail.Planed_Days_Per_Week_Spark_AGN__c");
        var currPrac	= component.get("v.custDetail.Current_Practice_Locations_Spark_AGN__c");
        console.log("stg>>>", stg);
        if(stg != undefined ||  noAsth!= undefined ||  daysPer!= undefined || daysPlanned!= undefined ||  currPrac!= undefined){
            console.log("entering the hepler>>>>>>>");
            var action = component.get("c.updateMyProfile");
            action.setParams({ 
                updateDetail 		: 	component.get("v.custDetail"),
                acrId				:   component.get("v.acrId")
            });
            action.setCallback(this, function(response) {
                var rtnValue = response.getReturnValue();
                console.log("rtnValue", rtnValue);
                if (rtnValue != null) {
                   this.clsModal(component);
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.showError",true);
            component.set("v.errorMessage", 'Please fill atleast one field to update');
        }     
    },
    
})