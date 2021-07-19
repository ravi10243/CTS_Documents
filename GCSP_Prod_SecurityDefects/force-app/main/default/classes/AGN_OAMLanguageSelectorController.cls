public without sharing class AGN_OAMLanguageSelectorController {
    public String selectedLanguage {get;set;}
    
    public String baseURL{get;set;}
    
    public AGN_OAMLanguageSelectorController(){
        baseURL = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX;
    }
    
    public List<SelectOption> getLanguages() {
            List<SelectOption> options = new List<SelectOption>();
            /*String jsonLangStr = '{"es_VE":"Spanish (Venezuela)","es_UY":"Spanish (Uruguay)","es_US":"Spanish (United States)","es_PR":"Spanish (Puerto Rico)","es_PE":"Spanish (Peru)","es_PY":"Spanish (Paraguay)",'+
        '"es_PA":"Spanish (Panama)","es_NI":"Spanish (Nicaragua)","es_HN":"Spanish (Honduras)","es_GT":"Spanish (Guatemala)","es_SV":"Spanish (El Salvador)","es_EC":"Spanish (Ecuador)","es_DO":"Spanish (Dominican Republic)",'+
        '"es_CR":"Spanish (Costa Rica)","es_CO":"Spanish (Colombia)","es_CL":"Spanish (Chile)","es_BO":"Spanish (Bolivia)","es_AR":"Spanish (Argentina)","it_CH":"Italian (Switzerland)",'+
        '"de_LU":"German (Luxembourg)","fr_CH":"French (Switzerland)","fr_LU":"French (Luxembourg)","fr_BE":"French (Belgium)","en_ZA":"English (South Africa)","en_SG":"English (Singapore)",'+
        '"en_IE":"English (Ireland)","en_HK":"English (Hong Kong)","zh_HK":"Chinese (Hong Kong)","zh_SG":"Chinese (Singapore)","ar_YE":"Arabic (Yemen)","ar_AE":"Arabic (United Arab Emirates)",'+
        '"ar_TN":"Arabic (Tunisia)","ar_SY":"Arabic (Syria)","ar_SD":"Arabic (Sudan)","ar_SA":"Arabic (Saudi Arabia)","ar_QA":"Arabic (Qatar)","ar_OM":"Arabic (Oman)","ar_MA":"Arabic (Morocco)",'+
        '"ar_LY":"Arabic (Libya)","ar_LB":"Arabic (Lebanon)","ar_KW":"Arabic (Kuwait)","ar_JO":"Arabic (Jordan)","ar_IQ":"Arabic (Iraq)","ar_EG":"Arabic (Egypt)","ar_BH":"Arabic (Bahrain)",'+
        '"ar_DZ":"Arabic (Algeria)","ta":"Tamil","de_CH":"German (Switzerland)","de_AT":"German (Austria)","bn":"Bengali","ur":"Urdu","hi":"Hindi","hy":"Armenian","rm":"Romansh","lb":"Luxembourgish",'+
        '"tl":"Tagalog","ms":"Malay","is":"Icelandic","cy":"Welsh","eu":"Basque","ga":"Irish","mt":"Maltese","sh_ME":"Montenegrin","sq":"Albanian","et":"Estonian","lt":"Lithuanian","lv":"Latvian",'+
        '"mk":"Macedonian","bs":"Bosnian","ro_MD":"Romanian (Moldova)","en_CA":"English (Canadian)","en_PH":"English (Phillipines)","en_IN":"English (Indian)","en_MY":"English (Malaysian)",'+
        '"en_AU":"English (Australian)","sh":"Serbian (Latin)","sr":"Serbian (Cyrillic)","ka":"Georgian","fr_CA":"French (Canadian)","sl":"Slovene","hr":"Croatian","pt_PT":"Portuguese (European)",'+
        '"sk":"Slovak","ar":"Arabic","en_GB":"English (UK)","bg":"Bulgarian","el":"Greek","iw":"Hebrew","uk":"Ukrainian","vi":"Vietnamese","ro":"Romanian","in":"Indonesian","tr":"Turkish","cs":"Czech",'+
        '"pl":"Polish","hu":"Hungarian","no":"Norwegian","es_MX":"Spanish (Mexico)","ru":"Russian","fi":"Finnish","th":"Thai","da":"Danish","nl_NL":"Dutch","pt_BR":"Portuguese (Brazil)",'+
        '"zh_CN":"Chinese (Simplified)","zh_TW":"Chinese (Traditional)","ko":"Korean","sv":"Swedish","ja":"Japanese","it":"Italiano","fr":"Français","es":"Spanish","de":"Deutsch","en_US":"English"}';*/
        
        String jsonLangStr = '{"es_VE":"Spanish (Venezuela)","es_UY":"Spanish (Uruguay)","es_US":"Spanish (United States)","es_PR":"Spanish (Puerto Rico)","es_PE":"Spanish (Peru)","es_PY":"Spanish (Paraguay)",'+
        '"es_PA":"Spanish (Panama)","es_NI":"Spanish (Nicaragua)","es_HN":"Spanish (Honduras)","es_GT":"Spanish (Guatemala)","es_SV":"Spanish (El Salvador)","es_EC":"Spanish (Ecuador)","es_DO":"Spanish (Dominican Republic)",'+
        '"es_CR":"Spanish (Costa Rica)","es_CO":"Spanish (Colombia)","es_CL":"Spanish (Chile)","es_BO":"Spanish (Bolivia)","es_AR":"Spanish (Argentina)","it_CH":"Italian (Switzerland)",'+
        '"de_LU":"German (Luxembourg)","fr_CH":"French (Switzerland)","fr_LU":"French (Luxembourg)","fr_BE":"French (Belgium)","en_ZA":"English (South Africa)","en_SG":"English (Singapore)",'+
        '"en_IE":"English (Ireland)","en_HK":"English (Hong Kong)","zh_HK":"Chinese (Hong Kong)","zh_SG":"Chinese (Singapore)","ar_YE":"Arabic (Yemen)","ar_AE":"Arabic (United Arab Emirates)",'+
        '"ar_TN":"Arabic (Tunisia)","ar_SY":"Arabic (Syria)","ar_SD":"Arabic (Sudan)","ar_SA":"Arabic (Saudi Arabia)","ar_QA":"Arabic (Qatar)","ar_OM":"Arabic (Oman)","ar_MA":"Arabic (Morocco)",'+
        '"ar_LY":"Arabic (Libya)","ar_LB":"Arabic (Lebanon)","ar_KW":"Arabic (Kuwait)","ar_JO":"Arabic (Jordan)","ar_IQ":"Arabic (Iraq)","ar_EG":"Arabic (Egypt)","ar_BH":"Arabic (Bahrain)",'+
        '"ar_DZ":"Arabic (Algeria)","ta":"Tamil","de_CH":"German (Switzerland)","de_AT":"German (Austria)","bn":"Bengali","ur":"Urdu","hi":"Hindi","hy":"Armenian","rm":"Romansh","lb":"Luxembourgish",'+
        '"tl":"Tagalog","ms":"Malay","is":"Icelandic","cy":"Welsh","eu":"Basque","ga":"Irish","mt":"Maltese","sh_ME":"Montenegrin","sq":"Albanian","et":"Estonian","lt":"Lithuanian","lv":"Latvian",'+
        '"mk":"Macedonian","bs":"Bosnian","ro_MD":"Romanian (Moldova)","en_CA":"English","en_PH":"English (Phillipines)","en_IN":"English (Indian)","en_MY":"English (Malaysian)",'+
        '"en_AU":"English (Australian)","sh":"Serbian (Latin)","sr":"Serbian (Cyrillic)","ka":"Georgian","fr_CA":"French","sl":"Slovene","hr":"Croatian","pt_PT":"Portuguese (European)",'+
        '"sk":"Slovak","ar":"Arabic","en_GB":"English (UK)","bg":"Bulgarian","el":"Greek","iw":"Hebrew","uk":"Ukrainian","vi":"Vietnamese","ro":"Romanian","in":"Indonesian","tr":"Turkish","cs":"Czech",'+
        '"pl":"Polish","hu":"Hungarian","no":"Norwegian","es_MX":"Spanish (Mexico)","ru":"Russian","fi":"Finnish","th":"Thai","da":"Danish","nl_NL":"Dutch","pt_BR":"Portuguese (Brazil)",'+
        '"zh_CN":"Chinese (Simplified)","zh_TW":"Chinese (Traditional)","ko":"Korean","sv":"Swedish","ja":"Japanese","it":"Italiano","fr":"Français","es":"Spanish","de":"Deutsch","en_US":"English"}';
          Map<String, Object> availableLangMap = (Map<String, Object>) JSON.deserializeUntyped(jsonLangStr); 
            
            User usr = [select Supported_Languages_AGN__c,LocaleSidKey from user where id =: userinfo.getUserId()];
            String userlocale = usr.LocaleSidKey;
            system.debug(availableLangMap.get(userlocale));
            system.debug('defaultlanguage ==> ' +userlocale);
            system.debug('defaultlanguage Label ==> ' +availableLangMap.get(userlocale));
            String languageLabel = (String)availableLangMap.get(userlocale);
            options.add(new SelectOption(userlocale , languageLabel));
            if(usr.Supported_Languages_AGN__c != null){
               List<String> supportedLans = usr.Supported_Languages_AGN__c.split(';');
               for(String langs : supportedLans){
                    List<String> spl = langs.split(':');
                    system.debug(spl);
                    if(userlocale != spl[0]){
                      options.add(new SelectOption(spl[0],spl[1]));
                    }
                } 
            }
            system.debug('options>>>>>>>>>>>>>>>>>>>>>>>>>>'+options);
            return options;
    }
    
    public PageReference refreshLanguage(){
        system.debug('inside refresh language');
        if(String.isNotBlank(selectedLanguage)){
            PageReference page = new PageReference('/apex/AGN_CustomerPortalOktaLogin?language='+selectedLanguage);
            page.setRedirect(true);
            return page;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getLanguage(){
        String jsonLangStr = '{"es_VE":"Spanish (Venezuela)","es_UY":"Spanish (Uruguay)","es_US":"Spanish (United States)","es_PR":"Spanish (Puerto Rico)","es_PE":"Spanish (Peru)","es_PY":"Spanish (Paraguay)",'+
        '"es_PA":"Spanish (Panama)","es_NI":"Spanish (Nicaragua)","es_HN":"Spanish (Honduras)","es_GT":"Spanish (Guatemala)","es_SV":"Spanish (El Salvador)","es_EC":"Spanish (Ecuador)","es_DO":"Spanish (Dominican Republic)",'+
        '"es_CR":"Spanish (Costa Rica)","es_CO":"Spanish (Colombia)","es_CL":"Spanish (Chile)","es_BO":"Spanish (Bolivia)","es_AR":"Spanish (Argentina)","it_CH":"Italian (Switzerland)",'+
        '"de_LU":"German (Luxembourg)","fr_CH":"French (Switzerland)","fr_LU":"French (Luxembourg)","fr_BE":"French (Belgium)","en_ZA":"English (South Africa)","en_SG":"English (Singapore)",'+
        '"en_IE":"English (Ireland)","en_HK":"English (Hong Kong)","zh_HK":"Chinese (Hong Kong)","zh_SG":"Chinese (Singapore)","ar_YE":"Arabic (Yemen)","ar_AE":"Arabic (United Arab Emirates)",'+
        '"ar_TN":"Arabic (Tunisia)","ar_SY":"Arabic (Syria)","ar_SD":"Arabic (Sudan)","ar_SA":"Arabic (Saudi Arabia)","ar_QA":"Arabic (Qatar)","ar_OM":"Arabic (Oman)","ar_MA":"Arabic (Morocco)",'+
        '"ar_LY":"Arabic (Libya)","ar_LB":"Arabic (Lebanon)","ar_KW":"Arabic (Kuwait)","ar_JO":"Arabic (Jordan)","ar_IQ":"Arabic (Iraq)","ar_EG":"Arabic (Egypt)","ar_BH":"Arabic (Bahrain)",'+
        '"ar_DZ":"Arabic (Algeria)","ta":"Tamil","de_CH":"German (Switzerland)","de_AT":"German (Austria)","bn":"Bengali","ur":"Urdu","hi":"Hindi","hy":"Armenian","rm":"Romansh","lb":"Luxembourgish",'+
        '"tl":"Tagalog","ms":"Malay","is":"Icelandic","cy":"Welsh","eu":"Basque","ga":"Irish","mt":"Maltese","sh_ME":"Montenegrin","sq":"Albanian","et":"Estonian","lt":"Lithuanian","lv":"Latvian",'+
        '"mk":"Macedonian","bs":"Bosnian","ro_MD":"Romanian (Moldova)","en_CA":"English","en_PH":"English (Phillipines)","en_IN":"English (Indian)","en_MY":"English (Malaysian)",'+
        '"en_AU":"English (Australian)","sh":"Serbian (Latin)","sr":"Serbian (Cyrillic)","ka":"Georgian","fr_CA":"French (Canadian)","sl":"Slovene","hr":"Croatian","pt_PT":"Portuguese (European)",'+
        '"sk":"Slovak","ar":"Arabic","en_GB":"English (UK)","bg":"Bulgarian","el":"Greek","iw":"Hebrew","uk":"Ukrainian","vi":"Vietnamese","ro":"Romanian","in":"Indonesian","tr":"Turkish","cs":"Czech",'+
        '"pl":"Polish","hu":"Hungarian","no":"Norwegian","es_MX":"Spanish (Mexico)","ru":"Russian","fi":"Finnish","th":"Thai","da":"Danish","nl_NL":"Dutch","pt_BR":"Portuguese (Brazil)",'+
        '"zh_CN":"Chinese (Simplified)","zh_TW":"Chinese (Traditional)","ko":"Korean","sv":"Swedish","ja":"Japanese","it":"Italiano","fr":"Français","es":"Spanish","de":"Deutsch","en_US":"English"}';
        
        Map<String, Object> availableLangMap = (Map<String, Object>) JSON.deserializeUntyped(jsonLangStr); 
        
        //String language, userLanguage = UserInfo.getLanguage();
        String language, userLanguage = UserInfo.getLocale();
        system.debug('userLanguage>>>>>>>>>>>>>>>>>'+userLanguage);
        /*for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
            if(value.getValue() == userLanguage) {
                language = value.getLabel();
                break;
            }
        }
        */
        
        language = (String)availableLangMap.get(userLanguage); //getting language display name
            
        Map<String, String> lang = new Map<String, String>();
        
        String languageKeyVal = userLanguage +':'+ language;
        lang.put('defaultlanguage',languageKeyVal);
        
        System.debug('defaultlanguage >>' + languageKeyVal);
        
        User u = [SELECT Supported_Languages_AGN__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        lang.put('supportedlanguage',u.Supported_Languages_AGN__c);
        
        system.debug('supportedlanguage >>' + u.Supported_Languages_AGN__c); 
        
        return lang;
    }
}