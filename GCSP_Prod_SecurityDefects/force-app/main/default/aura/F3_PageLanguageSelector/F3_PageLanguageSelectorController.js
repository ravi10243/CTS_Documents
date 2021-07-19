({
    doInit : function(component, event, helper){
        var currentLangCode = component.get("v.langCode");
        var selectedValue = component.get("v.selectedValue");
        selectedValue = currentLangCode;
        component.set("v.selectedValue", currentLangCode);
        component.find("langSelectorId").set("v.value", currentLangCode);
        //alert('Langau selector---');
        /*var action = component.get("c.getAllLanguages");
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('lang selector--- state--'+state);
            if(state == 'SUCCESS'){
            	console.log('all Langaues---'+ state+ ' --'+JSON.stringify(response.getReturnValue()));
            	component.set("v.languageOptions",response.getReturnValue());
                component.set("v.selectedValue", currentLangCode);
                
                console.log('currentLangCode--****'+ currentLangCode);
                 // Let DOM state catch up.
                window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our preferred value
                        component.find("langSelectorId").set("v.value", currentLangCode);
                }));
                
            } else {
                console.log('Error in getting languages--****');
            }
        });
        $A.enqueueAction(action); */
    },
	onLanguageChange : function(component, event, helper) {
		var selectedLang = event.getSource().get("v.value");
        var paramPageKey = component.get("v.pageKey");
        //alert('selectedLang' + selectedLang);
        var currentLangCode = component.get("v.langCode");
        //alert('currentLangCode' + currentLangCode);
        var selectedValue = component.get("v.selectedValue");
        //alert('selectedValue' + selectedValue);
        var currentURL = window.location.href;
        var communityURL = currentURL.substring(currentURL.indexOf('.com')+4,currentURL.indexOf('?'));
        //alert('URL---'+communityURL);
        if(selectedLang)
        {
            var answer = confirm('You will loose the data which you may have saved. Do you want to continue?');
            if(answer)
            {
            	window.open(communityURL+'?lng='+ selectedLang + '&pagekey=' + paramPageKey, '_self'); 
            	//CheckATradeDemo  
            	//window.open('/CheckATradeDemo/s/traderapplication?lng='+ selectedLang + '&pagekey=' + paramPageKey, '_self'); 
            }
            else
            {
                component.set("v.selectedValue", currentLangCode);
            }
        }
	}
})