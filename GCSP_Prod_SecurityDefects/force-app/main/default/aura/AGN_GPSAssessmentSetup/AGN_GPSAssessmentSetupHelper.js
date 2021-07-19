({
    fetchGPSAssessment : function(component) {
        if(component.get('v.assessmentId') == null) {
            var newRecord = {'sobjectType': 'GPS_Assessment__c'};
            component.set('v.assessment', newRecord);
            return;
        }

        var action = component.get('c.getGPSAssessment');
        action.setParams({
            'assessmentId' : component.get('v.assessmentId')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                
                //PMO 3408: GPS Assessment: Start: Populate business unit values
                //component.set('v.assessment', response.getReturnValue());
                var assessment = response.getReturnValue();
                component.set('v.assessment', assessment);
                
                var selectedBusinessUnitString = assessment.Business_Unit_AGN__c;
                if(selectedBusinessUnitString != null){
                    component.set('v.selectedBusinessUnitList', selectedBusinessUnitString.split(';'));
                }
                //PMO 3408: GPS Assessment: End: Populate business unit values
                
                //PMO 3408: GPS Assessment: Start: Fetch Account GPS Assessments, used to enable or disable Export
        		this.fetchAccountGPSAssessmentsForEnablingOrDisablingExport(component);
                //PMO 3408: GPS Assessment: End: Fetch Account GPS Assessments, used to enable or disable Export
                
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    searchProducts : function(component, event) {
        var action = component.get('c.getProductCatalog');

        action.setParams({
            'assessmentId': component.get('v.assessmentId'),
            'searchString': component.get('v.productSearchString')
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set('v.products', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    createAssessmentProducts : function(component, event, productIds) {
        var action = component.get('c.createAssessmentProducts');
        action.setParams({
            'assessmentId': component.get('v.assessmentId'),
            'productIds': productIds
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                console.log('end:');
                //PMO 3408: GPS Assessment: Start: Refresh Assessment to update Product_List
                this.fetchGPSAssessment(component, event);
                //PMO 3408: GPS Assessment: End: Refresh Assessment to update Product_List
                this.fetchGPSAssessmentProducts(component, event);
                component.set('v.showAddProducts', false);

                var appEvent = $A.get('e.c:AGN_GPSAssessmentUpdatedEvt');
                appEvent.fire();
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    fetchGPSAssessmentProducts : function(component) {
        if(component.get('v.assessmentId') == null) return;

        var action = component.get('c.getGPSAssessmentProducts');
        action.setParams({
            assessmentId : component.get('v.assessmentId')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.assessmentProducts', response.getReturnValue());
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    //PMO 3408: GPS Assessment: Start: Fetch Account GPS Assessments, used to enable or disable Export
    fetchAccountGPSAssessmentsForEnablingOrDisablingExport : function(component) {
        component.set('v.accountAssessmentStatsByOwner', null);
        var action = component.get('c.getAccountGPSAssessmentStatsByOwner');
        action.setParams({
            assessmentId : component.get('v.assessmentId'),
            sortField : component.get('v.accountAssessmentStatsByOwnerSortField'),
            sortIsAsc : component.get('v.accountAssessmentStatsByOwnerSortIsAsc')
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var results = response.getReturnValue();
                console.log('accountAssessmentStats results');
                console.log(results);
                component.set('v.accountAssessmentStatsByOwner', results);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    //PMO 3408: GPS Assessment: End: Fetch Account GPS Assessments, used to enable or disable Export
    
    fetchAccountGPSAssessmentsByOwner : function(component) {
        component.set('v.accountAssessmentStatsByOwner', null);

        var action = component.get('c.getAccountGPSAssessmentStatsByOwner');
        action.setParams({
            assessmentId : component.get('v.assessmentId'),
            sortField : component.get('v.accountAssessmentStatsByOwnerSortField'),
            pageNumber : component.get('v.accountAssessmentStatsByOwnerPageNumber'),
            recordsPerPage : component.get('v.accountAssessmentStatsByOwnerRecordsPerPage'),
            sortIsAsc : component.get('v.accountAssessmentStatsByOwnerSortIsAsc')
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var results = response.getReturnValue();
                console.log('accountAssessmentStatsByOwner results');
                console.log(results);
                component.set('v.accountAssessmentStatsByOwner', results);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
               /* var errorDetails = [];
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);

                    // Loop through page errors
                    for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                        // Get page errors
                        errorDetails.push(errorWrapper.pageErrors[i].message);
                    }

                    // Loop through field errors
                    for(var fieldName in errorWrapper.fieldErrors) {
                        if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                            console.log('field errors');
                            // Get field errors
                            errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                        }
                    }
                }
                console.log('errorDetails');
                console.log(errorDetails);
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                toastNotificationEvent.fire();*/
            }
        });
        $A.enqueueAction(action);

        var totalsAction = component.get('c.getAccountGPSAssessmentStatsByOwnerTotalCount');
        totalsAction.setParams({assessmentId : component.get('v.assessmentId')});
        totalsAction.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var totalRecords = response.getReturnValue();
                component.set('v.accountAssessmentStatsByOwnerTotalRecords', totalRecords);

                var recordsPerPage = component.find('recordsPerPage').get('v.value');
                var totalPages = Math.ceil(totalRecords / recordsPerPage);
                component.set('v.accountAssessmentStatsByOwnerTotalPages', totalPages);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
            }
        });
        $A.enqueueAction(totalsAction);
    },
    fetchUsersWithMatchingProducts : function(component) {
        var action = component.get('c.getUsersToAdd');
        action.setParams({
            assessmentId : component.get('v.assessmentId')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set('v.usersWithMatchingProducts', response.getReturnValue());
                component.set('v.showSelectUsers', true);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    searchAccounts : function(component) {
        console.log('searchAccounts');
        var newAssessmentOwnerId = component.get('v.newAssessmentOwnerId');
        console.log('newAssessmentOwnerId');
        console.log(newAssessmentOwnerId);
        if(newAssessmentOwnerId == null || newAssessmentOwnerId == '') return;

        var action = component.get('c.getAccountsToAdd');
        action.setParams({
            assessmentId : component.get('v.assessmentId'),
            searchString : component.get('v.accountSearchString'),
            ownerId : component.get('v.newAssessmentOwnerId')
        });

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var accountsToAdd = response.getReturnValue();
                component.set('v.accountsToAdd', accountsToAdd);
                console.log('accountsToAdd');
                console.log(accountsToAdd);
                //this.fetchAccountGPSAssessmentsByOwner(component);
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
            }
        });
        $A.enqueueAction(action);
    },

    // Bulk Upload
    uploadBulkFile : function(component, fileInput, item) {
        console.log('[Speaker_FileUpload].[save]');
        var file = fileInput.files[0];

        if(item == 'csv') {
            if (file.size > this.MAX_DOC_FILE_SIZE) {
                alert('File size cannot exceed ' + this.MAX_DOC_FILE_SIZE + ' bytes.\n Selected file size: ' + file.size);
                return;
            }
            var fileExt = (file.name).substring((file.name).indexOf('.')+1);
            if (fileExt != 'csv') {
                alert(' Only document files (pdf, doc and docx) are supported.\n Selected file type: .' + fileExt);
                return;
            }
        }

        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            self.saveBulkFile(component, file, fileContents, item);
        };

        fr.readAsDataURL(file);
    },
    saveBulkFile : function(component, file, fileContents, item) {
        var action = component.get('c.createAccountAssessmentRecordsForBulkUpload');
        action.setParams({
            'assessmentId': component.get('v.assessmentId'),
            'fileName': file.name,
            'base64Data': encodeURIComponent(fileContents),
            'contentType': file.type,
            'item': item
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var successMessage = 'File uploaded. You will receive an email when the upload has been processed.';
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
                component.set('v.showUpload', false);
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
            }
        });

        $A.enqueueAction(action);
    },
    saveAssessment : function(component, event) {
        var action = component.get('c.saveGPSAssessment');
        
        //PMO 3408: GPS Assessment: Start: Store selected business unit values
        var assessmentToSave = component.get('v.assessment');
        //PMO 3408: GPS Assessment: Start: Make business size question mandatory
        assessmentToSave.Business_Size_Question_Mandatory_AGN__c = 'true'; //Setting true as business size question will always be mandatory as per requirements
        //PMO 3408: GPS Assessment: End: Make business size question mandatory
        action.setParams({assessment:assessmentToSave,
                         selectedBusinessUnitList:component.get('v.selectedBusinessUnitList')
                         });  
        //PMO 3408: GPS Assessment: End: Store selected business unit values
        
        action.setCallback(this, function(response){
            if(component.isValid()) {
                if(response.getState() == 'SUCCESS') {
                    component.set('v.assessment', response.getReturnValue());
                    component.set('v.assessmentId', response.getReturnValue().Id);
                    var appEvent = $A.get('e.c:AGN_GPSAssessmentUpdatedEvt');
                    appEvent.fire();

                    var successMessage = $A.get('$Label.c.Save_successful');
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                    toastNotificationEvent.fire();
                    console.log('[GPSAssessmentDetailsHelper].[saveGPSAssessment].success');
                } else {
                    console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //PMO 3408: GPS Assessment: Start: Export
    exportAssessment : function(component, event) {
        this.saveAssessment(component, event);

        var assessmentToExportId = component.get('v.assessmentId');
        var action = component.get('c.exportGPSAssessment');
        action.setParams({assessmentId:assessmentToExportId});
        action.setCallback(this, function(response){
            if(component.isValid()) {
                if(response.getState() == 'SUCCESS') {
                    var exportMap = response.getReturnValue();
                    
                    if(exportMap != null){
                        for(var key in exportMap){
                            
                            var hiddenElement = document.createElement('a');
                            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(exportMap[key]);
                            hiddenElement.target = '_self';
                            hiddenElement.download = key + '.csv';  // CSV file Name
                            document.body.appendChild(hiddenElement);
                            hiddenElement.click(); // Download csv file
                        }
                    }
                    
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : ['Assessment exported successfully']});
                    toastNotificationEvent.fire();
                    
                    console.log('Exported assessment: ' + assessmentToExportId.Id + ' successfully');
                } else {
                    console.log('Error while exporting assessment!');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    //PMO 3408: GPS Assessment: End: Export
    
    cloneAssessment : function(component, event) {
        this.saveAssessment(component, event);

        var action = component.get('c.cloneGPSAssessment');
        action.setParams({assessmentId:component.get('v.assessmentId')});
        action.setCallback(this, function(response){
            if(component.isValid()) {
                if(response.getState() == 'SUCCESS') {
                    var clonedAssessment = response.getReturnValue();
                    component.set('v.assessment', clonedAssessment);
                    component.set('v.assessmentId', clonedAssessment.Id);

                    // Show the new assessment
                    var appEvent = $A.get('e.c:AGN_GPSShowAssessmentEvt');
                    appEvent.setParams({'assessmentId' : response.getReturnValue().Id});
                    appEvent.fire();

                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : ['Assessment cloned successfully']});
                    toastNotificationEvent.fire();

                    // Update the list of assessments
                    var appEvent = $A.get('e.c:AGN_GPSAssessmentUpdatedEvt');
                    appEvent.fire();
                    console.log('[GPSAssessmentDetailsHelper].[cloneAssessment].success');
                } else {
                    console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    addAccountAssessments : function(component, accountIds) {
        var action = component.get('c.createAccountAssessmentRecordsForAccountIds');
        action.setParams({
            'assessmentId': component.get('v.assessmentId'),
            'ownerId': component.get('v.newAssessmentOwnerId'),
            'accountIds': accountIds
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                // Clear the previously selected user & search
                component.set('v.newAssessmentOwnerId', null);
                component.set('v.newAssessmentOwnerName', null);
                component.set('v.accountSearchString', null);

                var successMessage = 'Account added successfully.';
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
                component.set('v.showAddAccounts', false);
                this.fetchAccountGPSAssessmentsByOwner(component);
            } else {
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
            }
        });
        $A.enqueueAction(action);
    },
    viewAccountAssessments : function(component, event, ownerId) {
        var action = component.get('c.getAccountGPSAssessments');
        var ownerId = ownerId ? ownerId : event.getSource().get('v.value');
        console.log('assessmentId='+ component.get('v.assessmentId'));
        console.log('ownerId='+ownerId);
        action.setParams({
            assessmentId: component.get('v.assessmentId'),
            ownerId : ownerId
        });
        console.log('test');
        console.log(ownerId);
        action.setCallback(this, function(response) {
            console.log('callback test');

            if(response.getState() === 'SUCCESS') {
                console.log('got it');
                console.log(response.getReturnValue());
                component.set('v.accountAssessmentsByOwner', response.getReturnValue());
                component.set('v.showAccountAssessments', true);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                    var errorDetails = [];
                    for(var i=0; i < response.getError().length; i++) {
                        var errorWrapper = response.getError()[i];
                        console.log(errorWrapper);

                        // Loop through page errors
                        for(var i=0; i < errorWrapper.pageErrors.length; i++) {
                            // Get page errors
                            errorDetails.push(errorWrapper.pageErrors[i].message);
                        }

                        // Loop through field errors
                        for(var fieldName in errorWrapper.fieldErrors) {
                            if(errorWrapper.fieldErrors.hasOwnProperty(fieldName)) {
                                console.log('field errors');
                                // Get field errors
                                errorDetails.push(errorWrapper.fieldErrors[fieldName][0].message);
                            }
                        }
                    }
                    console.log('errorDetails');
                    console.log(errorDetails);
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'error', 'notificationDetails' : errorDetails});
                    toastNotificationEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    addTargetAccountsForUsers : function(component, event, userIds) {
        var action = component.get('c.createAccountAssessmentRecordsForUserIds');
        var ownerId = event.getSource().get('v.value');
        console.log('assessmentId='+ component.get('v.assessmentId'));
        console.log('ownerId='+ownerId);
        action.setParams({
            assessmentId: component.get('v.assessmentId'),
            userIds : userIds
        });
        action.setCallback(this, function(response) {

            if(response.getState() === 'SUCCESS') {
                component.set('v.showSelectUsers', false);
                var successMessage = 'Success - line managers & sales reps are being processed. You will receive an email when the process is completed.';
                var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                toastNotificationEvent.fire();
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++) {
                    var errorWrapper = response.getError()[i];
                    console.log(errorWrapper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteAccountAssessment : function(component, event) {
        var confirmed = confirm('Are you sure that you want to remove this account?');
        if(!confirmed) return;

        var action = component.get('c.deleteAccountGPSAssessment');
        var accountAssessmentId = event.getSource().get('v.value');
        action.setParams({
            accountAssessmentId : accountAssessmentId
        });
        console.log('test');
        console.log(accountAssessmentId);
        action.setCallback(this, function(response) {
            console.log('callback test');

            if(response.getState() === 'SUCCESS') {
                console.log('success');
                var ownerId = response.getReturnValue();
                console.log('ownerId');
                console.log(ownerId);
                //component.set('v.assessment', response.getReturnValue());
                //getGPSAssessmentProducts(component);
                this.viewAccountAssessments(component, event, ownerId);
                this.fetchAccountGPSAssessmentsByOwner(component);
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++) {
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteAssessmentProduct : function(component, event) {
        var confirmed = confirm('Are you sure that you want to remove this product?');
        if(!confirmed) return;

        var action = component.get('c.deleteGPSAssessmentProduct');
        var recordId = event.getSource().get('v.value');
        action.setParams({assessmentProductId : recordId});

        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                console.log('success');
                //PMO 3408: GPS Assessment: Start: Refresh Assessment to update Product_List
                this.fetchGPSAssessment(component, event);
                //PMO 3408: GPS Assessment: End: Refresh Assessment to update Product_List
                this.fetchGPSAssessmentProducts(component, event);
                var appEvent = $A.get('e.c:AGN_GPSAssessmentUpdatedEvt');
                appEvent.fire();
            } else if(response.getState() === 'ERROR') {
                console.log('Error');
                for(var i=0; i < response.getError().length; i++) {
                    console.log(response.getError()[i]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb
    uploadHelper: function(component, event) {
        console.log('start uploadHelper');
        // start/show the loading spinner
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        // create a FileReader object
        var objFileReader = new FileReader();
        // set onload function of FileReader object
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);

        var action = component.get('c.createAccountAssessmentRecordsForBulkUpload');
        action.setParams({
            'assessmentId': component.get('v.assessmentId'),
            'fileName': file.name,
            'base64Data': encodeURIComponent(getchunk),
            'contentType': file.type,
            'item': 'csv'
        });
        // set call back
        action.setCallback(this, function(response) {
            // store the response / Attachment Id
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion
                // then call again 'uploadInChunk' method ,
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    //alert('your File is uploaded successfully');
                    var successMessage = 'File uploaded. You will receive an email when the upload has been processed.';
                    var toastNotificationEvent = $A.get('e.c:toastNotificationEvent');
                    toastNotificationEvent.setParams({'type': 'success', 'notificationDetails' : [successMessage]});
                    toastNotificationEvent.fire();
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.showUpload", false);
                    component.set('v.fileName', null)
                }
                // handel the response errors
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    }
})