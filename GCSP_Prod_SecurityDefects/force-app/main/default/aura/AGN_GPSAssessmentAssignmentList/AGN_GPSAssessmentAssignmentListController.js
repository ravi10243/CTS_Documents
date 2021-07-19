({
    doInit : function(component, event, helper) {
        var userId = component.get('v.userId');
        //console.log('userId=' + userId);
        if(userId) helper.getAssessments(component, event);
        
        var assessmentId = component.get('v.assessmentId');
        console.log('assessmentId=' + assessmentId);
        if(assessmentId) {
            // Render the component
            component.set('v.showAssessmentAccountForm', true);
            // Fire the event to show the assessment
            var appEvent = $A.get('e.c:AGN_GPSShowAccountAssessmentsEvt');
        	appEvent.setParams({'assessmentId' : assessmentId});
        	appEvent.fire();
        }
       
    },
    handleShowAccountAssessments : function(component, event, helper) {
        component.find('assessmentAccountFormCmp').set('v.assessmentId', event.getParam('assessmentId'));

        $A.util.addClass(component.find('assessmentListCmpWrapper'), 'hidden');
        $A.util.removeClass(component.find('assessmentDetailsCmpWrapper'), 'hidden');
    },
    sortByField : function(component, event, helper) {
        var currentSortField = component.get('v.sortField');
        var fieldName = event.currentTarget.dataset.fieldname;
        component.set('v.sortField', fieldName);

        var sortIsAsc = component.get('v.sortIsAsc');
        if(fieldName == currentSortField) sortIsAsc = !sortIsAsc;
        component.set('v.sortIsAsc', sortIsAsc);
        var sortArrow = sortIsAsc ? '   ▲' : '   ▼'
        component.set('v.sortArrow', sortArrow);

        component.set('v.pageNumber', 1);
    },
    previousPage : function(component, event, helper) {
        var currentPageNumber = component.get('v.pageNumber');
        var previousPageNumber = currentPageNumber > 1 ? currentPageNumber - 1 : 1;
        component.set('v.pageNumber', previousPageNumber);
    },
    nextPage : function(component, event, helper) {
        var currentPageNumber = component.get('v.pageNumber');
        var totalPages = component.get('v.totalPages')
        var nextPageNumber = currentPageNumber < totalPages ? currentPageNumber + 1 : totalPages;
        component.set('v.pageNumber', nextPageNumber);
    },
    toggleAssessmentAccountForm : function(component, event, helper) {
        var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
        toastNotificationEvent.setParams({'type': null, 'notificationDetails' : null});
        toastNotificationEvent.fire();

        component.set('v.showAssessmentAccountForm', !component.get('v.showAssessmentAccountForm'));
        component.find('assessmentAccountFormCmp').set('v.assessmentId', event.target.id);
    },
    back : function(component, event, helper) {        
        component.set('v.displaySpinner', true);
        var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
        toastNotificationEvent.setParams({'type': null, 'notificationDetails' : null});
        toastNotificationEvent.fire();

        component.find('assessmentAccountFormCmp').set('v.assessmentId', null);
        component.set('v.showAssessmentAccountForm', !component.get('v.showAssessmentAccountForm'));
        // Requery the assessments & set paging information
        helper.getAssessments(component, event);
        component.set('v.displaySpinner', false);
    },
    viewAccountAssessments : function(compntnent, event, helper) {
        var appEvent = $A.get('e.c:AGN_GPSShowAccountAssessmentsEvt');
        appEvent.setParams({'assessmentId' : event.target.id});
        appEvent.fire();
    }
})