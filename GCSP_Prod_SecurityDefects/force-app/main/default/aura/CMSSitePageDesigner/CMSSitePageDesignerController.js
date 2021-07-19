({
    doInit : function(component, event, helper) {
        var pageParameterMap = helper.pageParameterReader(component, event, helper);
        var recordId  = pageParameterMap['c__formId'];
        
        try 
        {
            component.set("v.recordId", recordId);
            helper.refreshBuilder(component, helper);
        }
        catch (err) 
        {
            //console.error(err);
            component.set("v.recordId", recordId);
            helper.refreshBuilder(component, helper);
        }
    },
    changeViewToWizard : function(component, event, helper) {
        component.set("v.currentUserViewMode",'WIZARD');
    },
    changeViewToDesigner : function(component, event, helper) {
        component.set("v.currentUserViewMode",'DESIGNER');
    },
    refreshCurrentView : function(component, event, helper) {
        try {
            helper.refreshBuilder(component, helper);
        } catch (err) {
            console.log(err);
        }
        
    },
    openPreview : function(component, event, helper) {
        alert('Coming Soon..');
    },
    onChangeViewModeClick: function(component, event, helper){
        var menuItemValue = event.getParam("value");
        //alert(menuItemValue);
        component.set("v.currentUserViewMode", menuItemValue);
        helper.refreshBuilder(component, helper);
    },
})