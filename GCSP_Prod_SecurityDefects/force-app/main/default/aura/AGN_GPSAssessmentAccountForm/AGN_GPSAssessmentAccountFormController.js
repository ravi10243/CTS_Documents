({
    doInit : function(component, event, helper) {
        if(component.get('v.assessmentId') == null) {
            component.set('v.assessment', {});
            component.set('v.accountAssessments', []);
            return;
        }

        helper.fetchGPSAssessment(component, event);
        helper.fetchAccountGPSAssessments(component, event);
    },
    showSpinner : function(component, event, helper) {
        component.set('v.displaySpinner', true);
    },
    hideSpinner : function(component, event, helper) {
        component.set('v.isReady', true);
        component.set('v.displaySpinner', false);
    },
    changeRecordsPerPage : function(component, event, helper) {
        component.set('v.pageNumber', 1);
        helper.fetchAccountGPSAssessments(component, event);
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
    toggleAccountCustomerAssessmentForm : function(component, event, helper) {
        helper.showAccountCustomerAssessmentForm(component, event);
        component.set('v.showAccountCustomerAssessmentForm', !component.get('v.showAccountCustomerAssessmentForm'));
    },
    toggleAddAccounts : function(component, event, helper) {
        component.set('v.showAddAccounts', !component.get('v.showAddAccounts'));
        component.set('v.accountSearchString', null);
        helper.searchAccounts(component, event);
    },
    
    // Release 14 ------- Niladri --------- Start  
    searchAccountsByName : function(component, event, helper) {
        component.set('v.pageNumber', 1);
        helper.fetchAccountGPSAssessments(component, event);
    },
    // Release 14 ------- Niladri --------- End
    
    toggleBusinessSize : function(component, event, helper) {
        component.set('v.showBusinessSize', !component.get('v.showBusinessSize'));
    },
    toggleAGNShare : function(component, event, helper) {
        component.set('v.showAGNShare', !component.get('v.showAGNShare'));
    },
    toggleDosageTreatment : function(component, event, helper) {
        component.set('v.showDosageTreatment', !component.get('v.showDosageTreatment'));
    },
    toggleFrequencyTreatment : function(component, event, helper) {
        component.set('v.showFrequencyTreatment', !component.get('v.showFrequencyTreatment'));
    },
    toggleSecondaryBrands : function(component, event, helper) {
        component.set('v.showSecondaryBrands', !component.get('v.showSecondaryBrands'));
    },
    toggleCustomQuestions : function(component, event, helper) {
        component.set('v.showCustomQuestions', !component.get('v.showCustomQuestions'));
    },
    toggleFinancialProjections : function(component, event, helper) {
        component.set('v.showFinancialProjections', !component.get('v.showFinancialProjections'));
    },
    addSelectedAccounts : function(component, event, helper) {
        var elements = document.getElementsByName('checkbox');
        var accountIds = [];
        for(var i = 0; i < elements.length; i++) {
            if(elements.item(i).checked === false) continue;

            accountIds.push(elements.item(i).dataset.accountid);
        }

        helper.addSelectedAccounts(component, accountIds);
    },
    searchAccounts : function(component, event, helper) {
        helper.searchAccounts(component, event);
    },
    deleteAccountAssessment : function(component, event, helper) {
        helper.deleteAccountAssessment(component, event);
    },
    saveAccountAssessments : function(component, event, helper) {
        helper.saveAccountAssessments(component, event);
    },
})