({
    fetchGPSAssessment : function(component) {
        component.set('v.displaySpinner', true);
        var action = component.get('c.getGPSAssessment');
        action.setParams({
            'assessmentId' : component.get('v.assessmentId')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var assessment = response.getReturnValue();
                component.set('v.assessment', assessment);
                component.set('v.isPersonAccounts', assessment.Assessment_Type_AGN__c == 'Customers');
                component.set('v.disableForm', assessment.Status_AGN__c == 'Locked');

                var colspan = 1;
                if(assessment.Data_Collection_Period_1_AGN__c) colspan++;
                if(assessment.Data_Collection_Period_2_AGN__c) colspan++;
                component.set('v.colspan', colspan);

                var customQuestionColspan = 0;
                if(assessment.Custom_Question_1_Type_AGN__c) {
                    component.set('v.picklistOptionsCustomQuestion1', this.generatePicklistOptions(assessment.Custom_Question_1_List_Of_Values_AGN__c));
                    customQuestionColspan++;
                }
                if(assessment.Custom_Question_2_Type_AGN__c) {
                    component.set('v.picklistOptionsCustomQuestion2', this.generatePicklistOptions(assessment.Custom_Question_2_List_Of_Values_AGN__c));
                    customQuestionColspan++;
                }
                if(assessment.Custom_Question_3_Type_AGN__c) {
                    component.set('v.picklistOptionsCustomQuestion3', this.generatePicklistOptions(assessment.Custom_Question_3_List_Of_Values_AGN__c));
                    customQuestionColspan++;
                }
                if(assessment.Custom_Question_4_Type_AGN__c) {
                    component.set('v.picklistOptionsCustomQuestion4', this.generatePicklistOptions(assessment.Custom_Question_4_List_Of_Values_AGN__c));
                    customQuestionColspan++;
                }
                component.set('v.customQuestionColspan', customQuestionColspan);
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    fetchAccountGPSAssessments : function(component, event) {
        component.set('v.displaySpinner', true);
        var filterIsCompleted =
            component.find('filterIsCompleted') === undefined || component.find('filterIsCompleted').get('v.value') == ''
            ? null : component.find('filterIsCompleted').get('v.value');

        var action = component.get('c.getAccountGPSAssessments');
        action.setParams({
            assessmentId      : component.get('v.assessmentId'),
            ownerId           : component.get('v.userId'),
            filterIsCompleted : filterIsCompleted,
            sortField         : component.get('v.sortField'),
            sortIsAsc         : component.get('v.sortIsAsc'),
            recordsPerPage    : component.find('recordsPerPage').get('v.value'),
            pageNumber        : component.get('v.pageNumber'),
            searchString      : component.get('v.searchString')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.accountAssessments', response.getReturnValue());
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    if(errorWrapper.pageErrors) {
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);

        var totalsAction = component.get('c.getAccountGPSAccountAssessmentsTotalCount');
        totalsAction.setParams({
            'assessmentId' : component.get('v.assessmentId'),
            'ownerId'      : component.get('v.userId')
        });
        totalsAction.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var totalRecords = response.getReturnValue();
                component.set('v.totalRecords', totalRecords);

                var recordsPerPage = component.find('recordsPerPage').get('v.value');
                var totalPages = Math.ceil(totalRecords / recordsPerPage);
                component.set('v.totalPages', totalPages);
            } else if (response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++){
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(totalsAction);
    },
    searchAccounts : function(component) {
        component.set('v.displaySpinner', true);
        console.log('searchAccounts');
        var action = component.get('c.getAccountsToAdd');
        action.setParams({
            assessmentId     : component.get('v.assessmentId'),
            searchString     : component.get('v.accountSearchString'),
            ownerId          : component.get('v.userId'),
            filterByProducts : false
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var accountsToAdd = response.getReturnValue();
                component.set('v.accountsToAdd', accountsToAdd);
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    addSelectedAccounts : function(component, accountIds) {
        component.set('v.displaySpinner', true);
        console.log(accountIds);
        var action = component.get('c.createAccountAssessmentRecordsForAccountIds');
        action.setParams({
            assessmentId : component.get('v.assessmentId'),
            ownerId : component.get('v.userId'),
            accountIds : accountIds
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var accountsToAdd = response.getReturnValue();
                this.fetchAccountGPSAssessments(component);
                component.set('v.showAddAccounts', !component.get('v.showAddAccounts'));
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    saveAccountAssessments : function(component, event) {
        console.log('saveAccountAssessments');
        component.set('v.displaySpinner', true);

        var recordsPerPage = component.find('recordsPerPage').get('v.value');
        var filterIsCompleted =
            component.find('filterIsCompleted') === undefined || component.find('filterIsCompleted').get('v.value') == ''
            ? null : component.find('filterIsCompleted').get('v.value');

        console.log('recordsPerPage=' + recordsPerPage);

        var action = component.get('c.saveAccountGPSAssessments');
        action.setParams({
            accountAssessments : component.get('v.accountAssessments'),
            filterIsCompleted  : filterIsCompleted,
            sortField          : component.get('v.sortField'),
            sortIsAsc          : component.get('v.sortIsAsc'),
            recordsPerPage     : recordsPerPage,
            pageNumber         : component.get('v.pageNumber'),
            searchString      : component.get('v.searchString')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var results = response.getReturnValue();
                component.set('v.accountAssessments', results);
                var successMessage = $A.get('$Label.c.Save_successful');
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    showAccountCustomerAssessmentForm : function(component, event) {
        var accountAssessmentId = event.getSource().get('v.value');
        component.find('accountCustomerAssessmentForm').set('v.accountAssessmentId', accountAssessmentId);
    },
    deleteAccountAssessment : function(component, event) {
        var confirmed = confirm($A.get('$Label.c.remove_account'));
        if(!confirmed) return;

        component.set('v.displaySpinner', true);

        var accountAssessmentId = event.getSource().get('v.value');
        var action = component.get('c.deleteAccountGPSAssessment');
        action.setParams({
            accountAssessmentId : accountAssessmentId
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                this.fetchAccountGPSAssessments(component);
                component.set('v.displaySpinner', false);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();
                component.set('v.displaySpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    generatePicklistOptions : function(listOfValues) {
        if(listOfValues == null) return;

        var picklistOptions = new Array();

        var emptypicklistOption = {};
        emptypicklistOption.label = '';
        emptypicklistOption.value = '';
        picklistOptions.push(emptypicklistOption);

        var splitListOfValues = listOfValues.split(/\r?\n/);
        for(var i=0; i < splitListOfValues.length; i++) {
            var val = splitListOfValues[i];

            var picklistOption = {};
            picklistOption.label = val;
            picklistOption.value = val;
            picklistOptions.push(picklistOption);
        }
        return picklistOptions;
    }
})