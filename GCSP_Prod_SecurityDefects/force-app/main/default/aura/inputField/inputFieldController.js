({
    doInit : function(component, event, helper) {
        helper.fetchFieldMetadata(component, event);
        helper.parseFieldValue(component, event);
    },
    handleRecordChanged : function(component, event, helper) {
        var record     = component.get('v.record');
        var fieldName  = component.get('v.fieldName');

        if(record) component.set('v.fieldValue', record[fieldName]);
    },
    handleFieldValueChanged : function(component, event, helper) {
        helper.handleFieldValueChanged(component, event);
    },
    handleBlur : function(component, event, helper) {
        helper.validateFieldValue(component, event)
    }
})