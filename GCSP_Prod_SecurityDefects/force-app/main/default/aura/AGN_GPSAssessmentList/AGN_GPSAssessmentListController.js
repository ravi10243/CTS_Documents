({
    doInit : function(component, event, helper) {
        console.log('doInit');
        helper.getAssessments(component, event);
        window.scrollTo(0, 0);
    },
    showSpinner: function(component, event, helper) {
        component.set('v.displaySpinner', true);
    },
    hideSpinner: function(component, event, helper) {
        component.set('v.displaySpinner', false);
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
    createAssessment : function(component, event, helper) {        
        console.log('Firing [GPSAssessmentListController].[createAssessment]');
        var appEvent = $A.get('e.c:AGN_GPSShowAssessmentEvt');
        appEvent.fire();
    },
    viewAssessmentDetail : function(component, event, helper) {
        console.log('Firing [GPSAssessmentListController].[viewAssessmentDetail]');
        console.log(event.target.id);

        var appEvent = $A.get('e.c:AGN_GPSShowAssessmentEvt');
        appEvent.setParams({'assessmentId' : event.target.id});
        appEvent.fire();
    }
})