({
    doInit : function(component, event, helper)
    {
        
        var action1 = component.get("c.ValidateCaseDetails");
        
        action1.setParams({"caseId": component.get("v.recordId")});
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            var res =JSON.stringify(response.getReturnValue());
            console.log('Response = '+ JSON.parse(res)[0].Status);
            
            if(JSON.parse(res)[0].Status=='In-Progress' || JSON.parse(res)[0].Status=='Closed' || JSON.parse(res)[0].Status=='Task Completed' || JSON.parse(res)[0].Status=='New' || JSON.parse(res)[0].Status=='Email Not Verified')
            {
                 $A.get('e.force:refreshView').fire();
                 $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Task Cannot be created as the Status of the Case is '+JSON.parse(res)[0].Status,
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
              
            }
            else
            {
                component.set("v.render",true);
                component.set("v.norender",false);
                
                var action = component.get("c.fetchCaseDetails");
                
                action.setParams({"caseId": component.get("v.recordId")});
                
                action.setCallback(this, function(response) 
                                   {       
                                       component.set("v.AssetList", response.getReturnValue());
                                       component.set("v.selectedCount", 0);
                                       component.find("box3").set("v.value", false);     
                                   });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action1);
    
    },
    
    checkboxSelect: function(component, event, helper) 
    { 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) 
        {
            getSelectedNumber++;
        }
        else 
        {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
    },
    
    selectAll: function(component, event, helper)
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("boxPack");
        if(! Array.isArray(getAllId))
        {
            if(selectedHeaderCheck == true)
            { 
                component.find("boxPack").set("v.value", true);
                component.set("v.selectedCount", 1);
            }
            else
            {
                component.find("boxPack").set("v.value", false);
                component.set("v.selectedCount", 0);
            }
        }
        else
        {
            if (selectedHeaderCheck == true)
            {
                for (var i = 0; i < getAllId.length; i++)
                {
                    component.find("boxPack")[i].set("v.value", true);
                    component.set("v.selectedCount", getAllId.length);
                }
            } 
            else
            {
                for (var i = 0; i < getAllId.length; i++) 
                {
                    component.find("boxPack")[i].set("v.value", false);
                    component.set("v.selectedCount", 0);
                }
            } 
        }  
    },
    createTaskSelected: function(component, event, helper) 
    {  
        var createtaskId = [];
        var getAllId = component.find("boxPack");
        
        if(! Array.isArray(getAllId))
        {
            if (getAllId.get("v.value") == true)
            {
                console.log('ID '+getAllId.get("v.text"));
                createtaskId.push(getAllId.get("v.text"));
            }
        }
        else
        {
            for (var i = 0; i < getAllId.length; i++)
            {
                if (getAllId[i].get("v.value") == true)
                {
                    createtaskId.push(getAllId[i].get("v.text"));
                    console.log('ID '+getAllId[i].get("v.text"));
                }
            }
        } 
        var recordId= component.get("v.recordId");
        helper.createTaskHelper(component, event, createtaskId,recordId); 
       
    },
    Cancel: function(component, event, helper) 
    {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire() ;
        
    }
    
})