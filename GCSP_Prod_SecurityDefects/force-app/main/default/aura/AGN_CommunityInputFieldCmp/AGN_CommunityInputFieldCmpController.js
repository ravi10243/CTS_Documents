({
    doInit : function(component, event, helper) {
        helper.fetchFieldMetadata(component, event);
		
        //custom label to support multiple language for country        
        var labelReference = $A.getReference("$Label.c." + component.get('v.customLabel'));
        component.set("v.customLabelName", labelReference);
        helper.parseFieldValue(component, event);
       // console.log('dsdsds>>>>>>>>>'+component.get('v.cmpHelpText'));
    },
    handleRecordChanged : function(component, event, helper) {
        var record     = component.get('v.record');
        var fieldName  = component.get('v.fieldName');
        
        if(record) component.set('v.fieldValue', record[fieldName]);
       // console.log('fieldValue>>>>>>>>>'+component.get('v.fieldValue'));
    },
    handleFieldValueChanged : function(component, event, helper) {
        helper.handleFieldValueChanged(component, event);
    },
    handleBlur : function(component, event, helper) {
        helper.validateFieldValue(component, event);
    }
})