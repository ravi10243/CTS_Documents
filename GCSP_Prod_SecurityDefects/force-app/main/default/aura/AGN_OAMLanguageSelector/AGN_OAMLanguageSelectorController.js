({
    doInit : function (component, event, helper) {
              
        //var language = $A.get("$Locale.language");//for setting the language select value on reload
        var defaultlanguage;
        var supportedlanguageList = [];
        
        var action = component.get('c.getLanguage'); 
        action.setCallback(this, function(resp){
            var state = resp.getState(); // get the response state 
            
            if(state === 'SUCCESS') {
                var langMap = resp.getReturnValue();
                
                //langMap['defaultlanguage'] => en_GB:English (UK)
                defaultlanguage = langMap['defaultlanguage'].split(':')[0]; //getting default language
                
                console.log('defaultlanguage ==> ' +defaultlanguage);
                console.log('defaultlanguage Label ==> ' +langMap['defaultlanguage'].split(':')[1]);
                //Adding default language to list
                supportedlanguageList.push({label:langMap['defaultlanguage'].split(':')[1], value:defaultlanguage});
                
                if(langMap['supportedlanguage'] != undefined){ //country support multilingual
                    //e.g. langMap['supportedlanguage'] => en_GB:English (UK);it:Italiano;fr:Français;
                    console.log(langMap['supportedlanguage']);
                    
                    var supportedlanguageArray = langMap['supportedlanguage'].split(';');
                    console.log('supportedlanguage ==> ' + supportedlanguageArray);
                    
                    supportedlanguageArray.forEach(function(lang) {
                        if(!$A.util.isEmpty(lang)){
                            var langArray = lang.split(':');
                            if(defaultlanguage != langArray[0]){
                                console.log('--------------------------');
                                console.log('value -> ' + langArray[0]);
                                console.log('label -> ' + langArray[1]);
                                
                                supportedlanguageList.push({label:langArray[1], value:langArray[0]});
                            }
                        }
                    });
                }
                //console.log(supportedlanguageList);
                component.set("v.languageOptions", supportedlanguageList);
                
                var sPageURL = decodeURIComponent(window.location.search.substring(1)); //get the whole decoded URL of the page.
                var sURLVariables = sPageURL.split('&'); //Split by & so that we get the key value pairs separately in a list
                var sParameterName;
                var i;
                
                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('='); //to split the key from the value.
                    
                    //finding language parameter in URL
                    if (sParameterName[0] === 'language') { 
                        if(sParameterName[1] === undefined){
                            component.set("v.selectedLang", defaultlanguage);
                        }
                        else{
                            component.set("v.selectedLang", sParameterName[1]);
                        }
                        console.log('--------------------------');
                        console.log('Param name = '+sParameterName[0]);
                        console.log('Param value = '+component.get("v.selectedLang"));
                    }
                    else{
                        //Setting default language
                        //var language ='en_US';
                        component.set("v.selectedLang", defaultlanguage);
                        var url = window.location.href.split('?')[0] + '?language=' + defaultlanguage;
                        window.location.href = url;
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    reloadPageForLanguage : function (component, event, helper) {
        //var language ='en_US';
        var language = component.get("v.selectedLang");
        //console.log('reloadPageForLanguage = '+language);
        //component.set("v.selectedLang", language);
                
       /*
        var url = window.location.href.split('?')[0] + '?language=' + language;
        window.location.href = url; */
        var idx = event.target.getAttribute('data-index');
        console.log('id>>>>>>'+idx);
        var lanops = component.get("v.languageOptions");
        console.log(JSON.stringify(lanops));
        var lang = component.get("v.languageOptions")[idx];
        
        var url = window.location.href.split('?')[0] + '?language=' + lang.value;
        window.location.href = url;
    } 

})