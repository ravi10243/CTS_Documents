({
    getResults : function(component, event, helper) {
        component.set('v.selectedRowId', null);
        component.set('v.selectedRowType', null);
        component.set('v.showResult', true);
        helper.getResults(component, event);
    },
    handleRowSelection : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        for(var i = 0; i < selectedRows.length; i++){
            component.set('v.selectedRowId', selectedRows[i].Id);
            component.set('v.selectedRowType', selectedRows[i].Type);
        }
    },
    refineSelection : function(component, event, helper) {
        component.set('v.selectedRowType', null);
        helper.getResults(component, event);
    },
    saveSelection : function(component, event, helper) {
        //helper.saveSelection(component, event);
        helper.selectResult(component, event);
        component.set('v.showResult', false);
        component.set('v.selectedRowType', null);
    }
})