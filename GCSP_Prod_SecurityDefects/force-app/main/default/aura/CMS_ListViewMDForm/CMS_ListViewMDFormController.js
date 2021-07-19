({
	doInit : function(component, event, helper) {
        let getDataAction = component.get("c.GetMDForms");
        getDataAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var res = response.getReturnValue();
                component.set("v.mdFormsData", res);
                helper.setFilteredForms(res, component);
            }
        });
        $A.enqueueAction(getDataAction);
	},
    refreshData : function(component, event, helper) {
        let getDataAction = component.get("c.GetMDForms");
        getDataAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var res = response.getReturnValue();
                component.set("v.mdFormsData", res);
                helper.setFilteredForms(res, component);
            }
        });
        $A.enqueueAction(getDataAction);
    },
    filterForms : function(component, event, helper) {
       	let query = component.get("v.filterQuery").trim();
        let forms = component.get("v.mdFormsData");
        if(query != "") {
        	let filteredForms = forms.filter(form => form.Name.toLowerCase().includes(query.toLowerCase()));
            component.set("v.currentPage", 1);
            helper.setFilteredForms(filteredForms, component);
            
        } else {
            helper.setFilteredForms(forms, component);
            component.set("v.isNameAscending", false);
            component.set("v.isNameSorted", false);
        }

    },
    
    showCreateNewFormModal : function(component, event, helper) {
        //console.log('button pressed -- '+event.getSource().get("v.name"));
        //pass the button to modal component as RecordType Name to set the record type when record is saved.
		$A.createComponent("c:CMS_ModalForm", {"recordId": null,
		                                        "mdRecordTypeName":event.getSource().get("v.name")}, function(modalComponent, status, errorMessage) {
            if (status === "SUCCESS") 
            {
                //Appending the newly created component in div
                var body = component.find('showChildModal').get("v.body");
                body.push(modalComponent);
                component.find('showChildModal').set("v.body", body);
            } 
            else if (status === "INCOMPLETE") 
            {
                console.log('Server issue or client is offline.');
            } 
                else if (status === "ERROR") 
                {
                    console.log('error');
                }
        });
    },
    
    toggleNameSort : function(component, event, helper) {
        let forms = component.get("v.filteredForms");
       	let isNameSorted = component.get("v.isNameSorted");
        if (isNameSorted) {
            let isNameAscending = component.get("v.isNameAscending");
            let sorted = forms.reverse();
            helper.setFilteredForms(sorted, component);
            component.set("v.isNameAscending", !isNameAscending);
            
        } else {
            let sorted = forms.sort((f1, f2) => f1.Name > f2.Name ? 1 : ((f1.Name < f2.Name) ? -1 : 0));
            helper.setFilteredForms(sorted, component);
            component.set("v.isNameAscending", true);
            component.set("v.isNameSorted", true);
            
        }
    },
    navigateToDesigner : function(component, event, helper){
        var urlToNavigate = "https://forms360.lightning.force.com/lightning/n/Designer_360?c__formId=" + event.target.id; 
        //alert(urlToNavigate);
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": urlToNavigate
        });
        urlEvent.fire();
    },
    nextPageEvent : function(component, event, helper) {
        let forms = component.get("v.filteredForms");
        let currentPage = component.get("v.currentPage");
        component.set("v.currentPage", currentPage + 1);
        helper.setFilteredForms(forms, component);
    },
    
    previousPageEvent : function(component, event, helper) {
        let forms = component.get("v.filteredForms");
        let currentPage = component.get("v.currentPage");
        component.set("v.currentPage", currentPage - 1);
        helper.setFilteredForms(forms, component);
    }
})