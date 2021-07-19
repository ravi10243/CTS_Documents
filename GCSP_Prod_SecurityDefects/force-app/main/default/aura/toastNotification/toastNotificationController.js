({
    doInit : function(component, event, helper) {
        console.log('doInit');
    },
    closeNotification : function(component, event, helper) {
        component.set('v.type', null);
    },
    handleNotification : function(component, event, helper) {
        component.set('v.type', event.getParam('type'));
        component.set('v.notificationDetails', event.getParam('notificationDetails'));
    }
})