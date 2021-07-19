({
    showSpinner: function(component, event, helper) {
        component.set('v.displaySpinner', true);
    },
    hideSpinner: function(component, event, helper) {
        component.set('v.displaySpinner', false);
    },
    handleShowAssessment: function(component, event, helper) {
        component.set('v.assessmentId', event.getParam('assessmentId'));
        
        //PMO 3408: GPS Assessment: Start: Remove selected Business units
        component.set('v.selectedBusinessUnitList', []);
        //PMO 3408: GPS Assessment: End: Remove selected Business units
        
        //PMO 3408: GPS Assessment: Start: For disabling export button
        component.set('v.accountAssessmentStatsByOwner', null);
        //PMO 3408: GPS Assessment: End: For disabling export button
        
        component.set('v.assessmentProducts', null);
        helper.fetchGPSAssessment(component, event);
        helper.fetchGPSAssessmentProducts(component, event);
        window.scrollTo(0, 0);
    },
    fetchAccountGPSAssessmentsByOwner: function(component, event, helper) {
        helper.fetchAccountGPSAssessmentsByOwner(component, event);
    },
    toggleSelectUsers : function(component, event, helper) {
        helper.fetchUsersWithMatchingProducts(component, event, helper);
    },
    toggleUpload : function(component, event, helper) {
        var invertedValue = !component.get('v.showUpload');
        component.set('v.showUpload', invertedValue);
    },
    accountAssessmentStatsByOwnerSortByField : function(component, event, helper) {
        var currentSortField = component.get('v.accountAssessmentStatsByOwnerSortField');
        var fieldName = event.currentTarget.dataset.fieldname;
        component.set('v.accountAssessmentStatsByOwnerSortField', fieldName);

        var sortIsAsc = component.get('v.accountAssessmentStatsByOwnerSortIsAsc');
        if(fieldName == currentSortField) sortIsAsc = !sortIsAsc;
        component.set('v.accountAssessmentStatsByOwnerSortIsAsc', sortIsAsc);
        var sortArrow = sortIsAsc ? '   ▲' : '   ▼'
        component.set('v.accountAssessmentStatsByOwnerSortArrow', sortArrow);

        component.set('v.accountAssessmentStatsByOwnerPageNumber', 1);
    },
    accountAssessmentStatsByOwnerPreviousPage : function(component, event, helper) {
        var currentPageNumber = component.get('v.accountAssessmentStatsByOwnerPageNumber');
        var previousPageNumber = currentPageNumber > 1 ? currentPageNumber - 1 : 1;
        component.set('v.accountAssessmentStatsByOwnerPageNumber', previousPageNumber);
    },
    accountAssessmentStatsByOwnerNextPage : function(component, event, helper) {
        var currentPageNumber = component.get('v.accountAssessmentStatsByOwnerPageNumber');
        var totalPages = component.get('v.accountAssessmentStatsByOwnerTotalPages')
        var nextPageNumber = currentPageNumber < totalPages ? currentPageNumber + 1 : totalPages;
        component.set('v.accountAssessmentStatsByOwnerPageNumber', nextPageNumber);
    },
    updateNewAssessmentOwner : function(component, event, helper) {
        var selectedUserId = event.getSource().get('v.value');
        component.set('v.newAssessmentOwnerId', selectedUserId);
        var selectedUserName;
        var users = component.get('v.accountAssessmentStatsByOwner');
        for(var i=0; i < users.length; i++) {
            if(users[i].OwnerId === selectedUserId) selectedUserName = users[i].OwnerName;
        }
        component.set('v.accountSearchString', null);
        component.set('v.newAssessmentOwnerName', selectedUserName);

        helper.searchAccounts(component, event);
    },

    //PMO 3408: GPS Assessment: Start: Populate Business unit picklist values
    doInit: function(component, event, helper) {
        
        var action = component.get("c.getPiklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                if(result!=null){
                    for (var i = 0; i < result.length; i++) {
                        plValues.push({
                            label: result[i],
                            value: result[i]
                        });
                    }
                }
                component.set("v.businessUnitList", plValues);
            }
        });
        $A.enqueueAction(action);
    },  
    //PMO 3408: GPS Assessment: End: Populate Business unit picklist values
    
    // Add Products
    toggleAddProducts : function(component, event, helper) {
        component.set('v.productSearchString', null);
        var invertedValue = !component.get('v.showAddProducts');
        component.set('v.showAddProducts', invertedValue);
        if(component.get('v.showAddProducts')) helper.searchProducts(component, event);
    },
    searchProducts : function(component, event, helper) {
        helper.searchProducts(component, event);
    },
    addSelectedProducts : function (component, event, helper) {
        var elements = document.getElementsByName('checkbox');
        var productIds = [];
        for(var i = 0; i < elements.length; i++) {
            if(elements.item(i).checked === false) continue;

            productIds.push(elements.item(i).dataset.productid);

        }
        helper.createAssessmentProducts(component, event, productIds);
    },

    // Add Users & Accounts
    toggleAddAccounts : function(component, event, helper) {
        component.find('newAssessmentOwnerPicklist').set('v.value', null);
        component.set('v.newAssessmentOwnerId', null);
        component.set('v.newAssessmentOwnerName', null);
        component.set('v.accountSearchString', null);

        component.set('v.showAddAccounts', !component.get('v.showAddAccounts'));
    },
    searchAccounts : function(component, event, helper) {
        helper.searchAccounts(component, event);
    },
    selectDirectReports : function(component, event, helper) {
        var managerId = event.target.dataset.userid;
        var managerSelected = event.target.checked;

        var elements = document.getElementsByName('checkbox');
        for(var i = 0; i < elements.length; i++) {
            if(managerSelected == false) continue;
            if(managerId != elements.item(i).dataset.managerid) continue;

            elements.item(i).checked = true;
        }
    },
    addSelectedUsers : function(component, event, helper) {
        var elements = document.getElementsByName('checkbox');
        var userIds = [];
        console.log(elements);

        for(var i = 0; i < elements.length; i++) {
            if(elements.item(i).checked === false) continue;

            userIds.push(elements.item(i).dataset.userid);
        }

        helper.addTargetAccountsForUsers(component, event, userIds);
    },
    addSelectedAccounts : function(component, event, helper) {
        var elements = document.getElementsByName('checkbox');
        var accountIds = [];
        for(var i = 0; i < elements.length; i++) {
            if(elements.item(i).checked === false) continue;

            accountIds.push(elements.item(i).dataset.accountid);
        }
        helper.addAccountAssessments(component, accountIds);
    },

    // Bulk upload
    uploadBulkFile : function(component, event, helper) {

       var fileInput = component.find('fileUpload').getElement();
       helper.uploadBulkFile(component, fileInput, 'csv');

    },
    downloadImportTemplate : function(component, event, helper) {
        // Create and download the CSV file
        var fileName   = 'Account_Assessment_Import.csv';
        var csvContent = 'AccountId,UserId,Username';
        // Generate the CSV download based on the user's browser
        if(navigator.msSaveBlob) { // IE 10+
            var blob = new Blob([csvContent], {type: "text/csv;charset=utf-8;"});
            navigator.msSaveBlob(blob, fileName);
        } else {
            var link = document.createElement('a');
            link.setAttribute('download', fileName);
            // Set the link to open the content of the file
            link.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            // Set the visibility to hidden so that it does not show in the user's browser
            link.style = 'visibility:hidden';

            // Append the link, automatically click it, and then remove it
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    },

    // DML methods
    saveAssessment : function(component, event, helper) {
        helper.saveAssessment(component, event);
    },
    
    //PMO 3408: GPS Assessment: Start: Export
    exportAssessment : function(component, event, helper) {
        helper.exportAssessment(component, event);
    },
    //PMO 3408: GPS Assessment: End: Export
    
    cloneAssessment : function(component, event, helper) {
        helper.cloneAssessment(component, event);
    },
    viewAccountAssessments : function(component, event, helper) {
        helper.viewAccountAssessments(component, event);
    },
    deleteAccountAssessment : function(component, event, helper) {
        helper.deleteAccountAssessment(component, event);
    },
    deleteAssessmentProduct : function(component, event, helper) {
        helper.deleteAssessmentProduct(component, event);
    },
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
})