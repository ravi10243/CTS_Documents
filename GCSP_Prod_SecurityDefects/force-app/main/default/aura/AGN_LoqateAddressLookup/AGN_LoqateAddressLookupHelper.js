({
    getResults : function(component, event) {
        var searchTerm = component.get('v.searchTerm');

        if(!searchTerm) return;

        var action = component.get('c.getSearchResults');
        action.setParams({
            searchTerm  : searchTerm,
            containerId : component.get('v.selectedRowId')
        });
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var searchResponse = response.getReturnValue();
                console.log('searchResponse');
                console.log(searchResponse);
                component.set('v.response', searchResponse);
            } else if(response.getState() === 'ERROR') {
                this.processCallbackErrors(response);
            }
        });
        $A.enqueueAction(action);
    },
    
     selectResult : function(component, event) {        
        var selectedRowId = component.get('v.selectedRowId');
        var action = component.get('c.selectedResult');
        action.setParams({           
            selectedAddressId : selectedRowId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                console.log(response.getReturnValue());                
                var evt = $A.get('e.c:AGN_SelectAddress');
        		evt.setParams({'address' : response.getReturnValue()});               
        		evt.fire();
            }
            else if(response.getState() === 'ERROR') {
                this.processCallbackErrors(response);
            }
        });
        $A.enqueueAction(action);
    },
    saveSelection : function(component, event) {
        var recordId      = component.get('v.recordId');
        var selectedRowId = component.get('v.selectedRowId');

        var action = component.get('c.saveSelectedResult');
        action.setParams({
            recordId          : recordId,
            selectedAddressId : selectedRowId
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                console.log(response.getReturnValue());
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:showToast').setParams({
                    message : 'Address successfully saved',
                    type    : 'success'
                }).fire();
            } else if(response.getState() === 'ERROR') {
                this.processCallbackErrors(response);
            }
        });
        $A.enqueueAction(action);
    },
    processCallbackErrors : function(response) {
        for(var i=0; i < response.getError().length; i++) {
           console.log(response.getError()[i]);
           alert();
           $A.get('e.force:showToast').setParams({
                message : response.getError()[i],
                type    : 'error'
            }).fire();
        }
    }
})