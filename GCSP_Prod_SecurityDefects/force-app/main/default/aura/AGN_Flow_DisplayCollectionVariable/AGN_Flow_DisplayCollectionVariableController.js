({
    init: function (cmp, event, helper) {
        var actions = [{ label: 'Delete', name: 'delete' }];
        cmp.set('v.columns', [
            {label: 'Name', fieldName: 'Company_Name_AGN__c', type: 'text', editable: false, typeAttributes: { required: true }},
            {label: 'Address', fieldName: 'Address_Line_1_AGN__c', type: 'text', editable: false },
            {label: 'Sold To', fieldName: 'Sold_To_AGN__c', type: 'boolean', editable: false },
            {label: 'Ship To', fieldName: 'Ship_To_AGN__c', type: 'boolean', editable: false },
            {label: 'SAP Id', fieldName: 'SAP_ID_AGN__c', type: 'text', editable: false },
            {type: 'action', typeAttributes: { rowActions: actions }}
        ]);
    },
    handleSaveEdition: function (cmp, event) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        object.assign(cmp.get(data), draftValues);
		//cmp.set("v.data", draftValues);        
    },
    handleCancelEdition: function (cmp) {
        // do nothing for now...
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'delete':
                helper.removeRecord(cmp, row);
                break;
        }
    }
});