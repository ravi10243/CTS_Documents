({
	validate : function(component, event) {
        var field = component.find('inputField');
        var fieldValue = component.get("v.fieldValue");
        var regex = component.get("v.fieldRegex");///^[0-9+ ()-]+$/ ;
        //console.log('regex ' + regex);
        if(regex != undefined && !$A.util.isEmpty(field)){
            console.log('In if');
            if(fieldValue.match(regex)){
                //console.log('regex true');
                component.set('v.isFormatValid', true);
            }else{
                //console.log('regex false');
                component.set('v.isFormatValid', false);
            }
        }
    }
})