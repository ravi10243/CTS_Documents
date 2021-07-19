({
	validateFieldValue : function(component, event) {
        var fieldRequired  = component.get('v.required');
        var fieldValue1 = component.get('v.fieldValue');
        console.log('fieldValue1 '+fieldValue1);
        var fieldValue = event.getParam('value') !== undefined ? event.getParam('value') : event.getSource().get('v.value');
        if(typeof fieldValue === 'undefined'|| fieldValue === null || fieldValue === '' ) fieldValue = '';
		
        console.log('fieldValue '+fieldValue);
        var fieldValueMissing = fieldValue === null || fieldValue === '' || fieldValue === undefined;
        component.set('v.fieldValueMissing', (fieldRequired && fieldValueMissing));
        
        //var fieldMetadata = component.get('v.fieldMetadata');
        this.validate(component, event);
    },
    validate : function(component, event) {
        var field = component.find('inputField');
        var fieldValue = component.get('v.fieldValue');
        var regex = component.get('v.fieldRegex');///^[0-9+ ()-]+$/ ;
        //console.log('regex ' + regex);
        if(regex && !$A.util.isEmpty(field)){   
            if(fieldValue.match(regex)){
                component.set('v.isFormatValid', true);
            }else{
                component.set('v.isFormatValid', false);
            }
        }
    },
    parseFieldValue : function(component, event) {
        var record = component.get('v.record');
        var fieldName = component.get('v.fieldName');
        console.log('Has Property11'+record);
        console.log('Has Property22'+fieldName);
        if(record === null) return;
        
        console.log('Has Property33'+record.hasOwnProperty(fieldName));
        if(record.hasOwnProperty(fieldName)) {
            console.log('Has Property');
            component.set('v.fieldValue', record[fieldName]);
        }
    },
})