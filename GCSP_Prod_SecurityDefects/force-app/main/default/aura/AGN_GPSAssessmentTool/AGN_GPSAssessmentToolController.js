({
    doInit : function(component, event, helper) {
        console.log('test');
        helper.getUserInfo(component, event);
        helper.getSettings(component, event);
    },
    toggleDevelopmentPanel : function(component, event, helper) {
        console.log('v.showDevelopmentPanel');
        console.log(component.get('v.showDevelopmentPanel'));
        component.set('v.showDevelopmentPanel', !component.get('v.showDevelopmentPanel'));
    },
    busiessExcellenceView : function(component, event, helper) {
        component.set('v.view', 'BusinessExcellence');
    },
    lineManagerView : function(component, event, helper) {
        component.set('v.view', 'LineManager');
    },
    salesRepView : function(component, event, helper) {
        component.set('v.view', 'SalesRep');
    },
    handleShowAssessment : function(component, event, helper) {
        component.find('assessmentDetailsCmp').set('v.assessmentId', event.getParam('assessmentId'));

        $A.util.addClass(component.find('assessmentListCmpWrapper'), 'hidden');
        $A.util.removeClass(component.find('assessmentDetailsCmpWrapper'), 'hidden');
    },
    showAssessmentList : function(component, event, helper) {
        var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
        toastNotificationEvent.setParams({'type': null, 'notificationDetails' : null});
        toastNotificationEvent.fire();

        $A.util.addClass(component.find('assessmentDetailsCmpWrapper'), 'hidden');
        $A.util.removeClass(component.find('assessmentListCmpWrapper'), 'hidden');
    }
})