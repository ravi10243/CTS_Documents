({
	getAllAccountsAndLL : function(component, event) {
		component.set("v.ispreviousdisable",true);
        var action = component.get("c.getAllAccounts");
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS')
            {
                var acclst = response.getReturnValue();
                component.set("v.Accountdetails",acclst);
                var cliniclength = response.getReturnValue().length;
                component.set("v.previous",0);
                component.set("v.start",10);
                component.set("v.end",cliniclength);
                console.log('cliniclength'+cliniclength);
                if(cliniclength > 10)
                {
                    var paginationList = [];
                    for(var i=0; i<10; i++)
                    {
                        paginationList.push(response.getReturnValue()[i]);
                    }
                    component.set("v.paginationAccountDetails",paginationList);
                    component.set("v.isnextdisable",false);
                }
                else
                {
                    component.set("v.paginationAccountDetails", response.getReturnValue());
                    component.set("v.isnextdisable",true);
                }
            }
        });
        $A.enqueueAction(action);
	},
    deleteLocatorListing: function(component, event) {
         var target = event.getSource();
           var txtVal = target.get("v.value") ;
        console.log('txtVal'+txtVal);
         var action1 = component.get("c.InactivateLocatorListing");
         action1.setParams({
            'loclstId': txtVal 
            });
        action1.setCallback(this,function(response){
            console.log('response.getState()'+response.getState());
            if(response.getState() === 'SUCCESS')
            {
                this.getAllAccountsAndLL(component, event);
            }
        });
        $A.enqueueAction(action1);
    },
     showTosteMessage : function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent){
            toastEvent.setParams({
                title: title,
                type: type,
                message: message,
                key: 'info_alt',
                mode: mode
            });
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(message);
        }
    }
})