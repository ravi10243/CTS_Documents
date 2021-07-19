({
	doInit : function(component, event, helper) {
        
        //component.set("v.spinner",true);
        //$A.get('e.force:refreshView').fire();
        //document.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.add('hideEl');
        var query = location.search.substr(1);
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'pd')
            {
            	component.set("v.isApprovelpending",decodeURIComponent(item[1]));
            }
        });
        
        if(component.get("v.isApprovelpending"))
        {
            var labelReference = $A.getReference("$Label.c.AGN_ICL_OAM_Pending_Message");
            component.set("v.Message", labelReference);
        }
        else
        {
            var labelReference = $A.getReference("$Label.c.AGN_ICL_OAM_Rejection_Message");
            component.set("v.Message", labelReference);
        }
        //component.set("v.spinner",false);
        //$A.get('e.force:refreshView').fire();
		  /*var action = component.get("c.isLocatorListingActive");
            action.setCallback(this, function(response) {
                console.log('Statee'+response.getState());
                if(response.getState() === 'SUCCESS') {
                   if(response.getReturnValue() == true)
                   {
                       console.log('Success');
                       var urlEvent = $A.get("e.force:navigateToURL");
                       urlEvent.setParams({
                           "url": "/agn-icl-clinic-details"
                       });
                       urlEvent.fire();
                   }
                    else
                    {
                         var action2 = component.get("c.isPendingforApprovalOrRejected");
                       action2.setCallback(this, function(response) {
                           if(response.getState() === 'SUCCESS') {
                                var result = response.getReturnValue();
                               if(result == true)
                               {
                                   //component.set("v.isApprovelpending",true);
                                   var labelReference = $A.getReference("$Label.c.AGN_ICL_OAM_Pending_Message");
                                   component.set("v.Message", labelReference);
                                   component.set("v.spinner",false);
                               }
                               else
                               {
                                   //component.set("v.isApprovelpending",false);
                                   var labelReference = $A.getReference("$Label.c.AGN_ICL_OAM_Rejection_Message");
                                   component.set("v.Message", labelReference);
                                   component.set("v.spinner",false);
                               }
                           }
                       });
                       $A.enqueueAction(action2);
                    }
                }
            });
            $A.enqueueAction(action);*/
    },
    backButton: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
                "url": "/agn-icl-cliniclistview"
            });
        urlEvent.fire();
    }
})