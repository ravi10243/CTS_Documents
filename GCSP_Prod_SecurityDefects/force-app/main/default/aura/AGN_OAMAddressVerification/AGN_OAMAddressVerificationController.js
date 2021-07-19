({
	doInit : function(component, event, helper) {
		
	},
    verifyAddress : function(component, event, helper) {
        var headerMap =  component.get("v.sectionHeaderMap");
        headerMap.forEach(function(cmp){
            for(var i in cmp.value){
                console.log(i);
                console.log(cmp);
                console.log(cmp[i]);
            }
        });
		alert("verify address");
	}
})