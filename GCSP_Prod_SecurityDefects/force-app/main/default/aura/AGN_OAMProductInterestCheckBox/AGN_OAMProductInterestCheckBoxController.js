({
	onChange : function(component, event, helper) {
		console.log(event.getSource().get("v.value"));
        var isSelected = event.getSource().get("v.value");
        var fieldValue = component.get("v.fieldValue");
        var selectedValue = component.get("v.chkVal");
        console.log("selected option",selectedValue);
        if(isSelected){
           if($A.util.isEmpty(fieldValue)){
               fieldValue = selectedValue + ';';
           }else{
               fieldValue += selectedValue + ';';
           } 
           component.set("v.fieldValue" , fieldValue);
        }else{
            var selectedOp = selectedValue + ";";
            console.log(selectedOp);
            if(fieldValue.includes(selectedOp)){
                 console.log("includes true");
                 var newVal = fieldValue.replace(selectedOp, '');
                 console.log("newVal>>>>>>>>"+newVal);
                 component.set("v.fieldValue" , newVal);
            }else{
                console.log("includes false");
            } 
        }
        console.log("selected val>>>>>>>",component.get("v.fieldValue"));
        
	}
})