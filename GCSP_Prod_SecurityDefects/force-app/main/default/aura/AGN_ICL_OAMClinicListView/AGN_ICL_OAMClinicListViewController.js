({
	doInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
		helper.getAllAccountsAndLL(component, event);
	},
    RegistrationOrDetailpage : function(component, event,helper) {
        var target = event.getSource();
        var accllval = target.get("v.value");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        if(accllval.HasLocatorListing === false)
        {
            urlEvent.setParams({
                "url": "/registerationicl?accid="+accllval.AccId
            });
            urlEvent.fire();
        }
        else 
        {
            console.log('Active');
            if(accllval.IsLocatorListingActive === true)
            {
                console.log('In active');
                urlEvent.setParams({
                    "url": "/agn-icl-clinic-details?lcid="+accllval.LocatorListingId
                });
                urlEvent.fire();
            }
            else if(accllval.IsLLRejected === true)
            {
                helper.showTosteMessage(component, '', 'info',$A.get("$Label.c.AGN_ICL_OAM_Rejection_Message"), 'dismissible');
                /*urlEvent.setParams({
                    "url": "/agn-icl-message?pd=false"
                });*/
            }
            else
            {
                helper.showTosteMessage(component, '', 'info',$A.get("$Label.c.AGN_ICL_OAM_Pending_Message"), 'dismissible');
                /*urlEvent.setParams({
                    "url": "/agn-icl-message?pd=true"
                });*/
            }
        }
        //urlEvent.fire();
    },
    NextPage : function(component, event) {
        var stval = component.get("v.start");
        var endval = component.get("v.end");
        var previousval = component.get("v.previous");
        var diffval = endval - stval;
        
        var cliniclst = component.get("v.Accountdetails");
        if(diffval>10)
        {
            var paginationList = [];
            for(var i=stval; i<stval+10; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            //component.set("v.previous",stval);
            //component.set("v.start",stval+10);
            component.set("v.isnextdisable",false);
            component.set("v.ispreviousdisable",false);
            component.set("v.paginationAccountDetails",paginationList);
        }
        else
        {
            var paginationList = [];
            for(var i=stval; i<endval; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            //component.set("v.previous",stval);
            //component.set("v.previous",stval);
            //component.set("v.start",stval+10);
            component.set("v.ispreviousdisable",false);
            component.set("v.paginationAccountDetails",paginationList);
            component.set("v.isnextdisable",true);
        }
        component.set("v.previous",stval);
        component.set("v.start",stval+10);
        
    },
    PreviousPage : function(component, event) {
        var stval = component.get("v.start");
        var endval = component.get("v.end");
        var previousval = component.get("v.previous");
        var diffval = endval - stval;
        var cliniclst = component.get("v.Accountdetails");
        
        var paginationList = [];
      
            for(var i=previousval-10; i<previousval; i++)
            {
                paginationList.push(cliniclst[i]);
            }
            component.set("v.start",stval-10);
            
       
        if(previousval-10 === 0)
        {
            component.set("v.ispreviousdisable",true);
        }
        else
        {
            component.set("v.previous",previousval-10);
        }
        
        
            component.set("v.isnextdisable",false);
        
        component.set("v.paginationAccountDetails",paginationList);
    },
    deleteLocatorListing :  function(component,event,helper) {
        if(confirm('Are you sure?'))
            helper.deleteLocatorListing(component,event);
        
    }
   
})