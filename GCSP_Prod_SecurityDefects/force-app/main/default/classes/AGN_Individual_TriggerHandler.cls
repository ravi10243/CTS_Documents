/*
Type Name: AGN_Individual_TriggerHandler
Reason: Trigger Handler class of AGN_Individual_Trigger on Individual Object.
Oct 5th, 2018 Initial version
*/
public class AGN_Individual_TriggerHandler{

    public void handlerAfterUpdate(List<Individual> individualnewList){
        
       List<Multichannel_Consent_vod__c> multichannelConsentList = new List<Multichannel_Consent_vod__c>();
        Map<Id, Id> invIdToAccIdMap = new Map<Id, Id>();
        List<Consent_Type_vod__c> consentTypeList = new List<Consent_Type_vod__c>();
        List<Consent_Type_vod__c> consentTypeLanguageList = new List<Consent_Type_vod__c>();
        List<Id> invIds = new List<Id>();
        Map<Id, Account> accountMap;
        Map<String, Id> multichannelRecordTypes = new Map<String, Id>();
        List<String> languages = new List<String>();
        List<String> countryIds = new List<String>();
        Map<String, Consent_Type_vod__c> consentTypeMap = new Map<String, Consent_Type_vod__c>();
        Map<String, Map<String, Consent_Type_vod__c>> consentMap = new Map<String, Map<String, Consent_Type_vod__c>>();
        
        Map<String, Consent_Type_vod__c> consentTypeLanguageMap = new Map<String, Consent_Type_vod__c>();
        Map<String, Map<String, Consent_Type_vod__c>> consentLanguageMap = new Map<String, Map<String, Consent_Type_vod__c>>();
        
        List<Consent_Line_vod__c> consentLinesList = new List<Consent_Line_vod__c>();
        Map<String, Consent_Line_vod__c> consentLineMap = new Map<String, Consent_Line_vod__c>();
        
    //Updated as a part of ICL project   

    for(Individual invi : individualnewList) 
        {
           
            if(invi.ICL_Flag_AGN__c==false)
            {  

       List<Country_vod__c> countryList = new List<Country_vod__c>();
        countryList = [Select Id from Country_vod__c where Name = 'FR' limit 1]; 
        String franceCountryCodeId = (countryList != null && countryList.size() > 0) ? countryList[0].Id : '';  //assuming france country record to exists.
                
      
      
       List<RecordType> mRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType = 'Multichannel_Consent_vod__c' ];
       
        for(RecordType rt : mRecordTypes)
            multichannelRecordTypes.put(rt.DeveloperName, rt.Id);
        
        for(Individual inv : individualnewList)
        {
            if(inv.Online_consent__c)
            {
               invIds.add(inv.Id); 
                               
               if(inv.Selected_Language__c != null) 
                    languages.add(inv.Selected_Language__c);
            }            
        }
        
        if(invIds != null && invIds.size() > 0)
            accountMap = new Map<Id, Account>([Select Id, Country_vod__c, PersonIndividualId , PersonEmail, Email_Internal_AGN__c, PersonMobilePhone 
                                               from Account where PersonIndividualId In : invIds]);
        
        if(accountMap != null && accountMap.size() > 0)
        {
            for(Id accId : accountMap.keySet())
            {
                if(accountMap.get(accId).PersonIndividualId != null)
                {
                        invIdToAccIdMap.put(accountMap.get(accId).PersonIndividualId, accId);
                      
                }       
                if(accountMap.get(accId).Country_vod__c != null)
                        countryIds.add(accountMap.get(accId).Country_vod__c);
            }
        }
        
        if(countryIds != null && countryIds.size() > 0 && languages !=null && languages.size() > 0)
        {
            consentTypeList = [Select Id, RecordTypeId, Consent_Header_vod__c, 
                                  RecordType.DeveloperName, Consent_Custom_Duration_vod__c, Consent_Expires_In_vod__c,
                                  Consent_Header_vod__r.Language_vod__c, Consent_Header_vod__r.Country_vod__c,
                                   (Select Id, Consent_Type_vod__c, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r)
                                  from Consent_Type_vod__c 
                                  where Consent_Header_vod__r.Language_vod__c In :languages
                                    and Consent_Header_vod__r.Country_vod__c In :countryIds
                                    and Consent_Header_vod__r.Status_vod__c = 'Active_vod' 
                                  order by Display_Order_vod__c];
        }       
        
        if(consentTypeList != null && consentTypeList.size() > 0)
        {
            for(Consent_Type_vod__c consentRec : consentTypeList)
            {
                String key = consentRec.Consent_Header_vod__r.Language_vod__c +'-'+consentRec.Consent_Header_vod__r.Country_vod__c;
                
                if(consentMap.isEmpty() || (!consentMap.isEmpty() && consentMap.size() > 0 && !consentMap.containsKey(key)))
                {
                    consentMap.put(key, new Map<String, Consent_Type_vod__c>{consentRec.RecordType.DeveloperName => consentRec});
                }
                else
                {
                    consentMap.get(key).put(consentRec.RecordType.DeveloperName, consentRec);     
                }                
                
                if(consentRec.RecordType.DeveloperName == 'Approved_Email_vod')
                { 
                    if(consentRec.Consent_Type_vod__r != null && !consentRec.Consent_Type_vod__r.isEmpty())
                        consentLinesList.addAll(consentRec.Consent_Type_vod__r); 
                }
            }            
        }  
        
        if(languages !=null && languages.size() > 0)
        {
            List<Consent_Header_vod__c> headerList = new List<Consent_Header_vod__c>();
            Map<String, String> languageToheaderIdMap = new Map<String, String>();
            
            headerList = [Select Id, Language_vod__c from Consent_Header_vod__c where Language_vod__c In :languages and Status_vod__c = 'Active_vod'];
            if(headerList != null && headerList.size() > 0)
            {
                for(Consent_Header_vod__c header : headerList)
                {
                    if(languageToheaderIdMap.isEmpty() || !languageToheaderIdMap.containskey(header.Language_vod__c))
                    {
                        languageToheaderIdMap.put(header.Language_vod__c, header.Id);
                    }
                }
            }
            
            if(languageToheaderIdMap != null && languageToheaderIdMap.size() > 0)
            {
                consentTypeLanguageList = [Select Id, RecordTypeId, Consent_Header_vod__c, 
                                  RecordType.DeveloperName, Consent_Custom_Duration_vod__c, Consent_Expires_In_vod__c,
                                  Consent_Header_vod__r.Language_vod__c, Consent_Header_vod__r.Country_vod__c,
                                  (Select Id, Consent_Type_vod__c, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r)
                                  from Consent_Type_vod__c 
                                  where Consent_Header_vod__c In :languageToheaderIdMap.values() 
                                  order by Display_Order_vod__c];
            }
        }
        
        if(consentTypeLanguageList != null && consentTypeLanguageList.size() > 0)
        {
            for(Consent_Type_vod__c consentRec : consentTypeLanguageList)
            {
                String key = consentRec.Consent_Header_vod__r.Language_vod__c;
                
                if(consentLanguageMap.isEmpty() || (!consentLanguageMap.isEmpty() && consentLanguageMap.size() > 0 && !consentLanguageMap.containsKey(key)))
                {
                    consentLanguageMap.put(key, new Map<String, Consent_Type_vod__c>{consentRec.RecordType.DeveloperName => consentRec});
                }
                else
                {
                    consentLanguageMap.get(key).put(consentRec.RecordType.DeveloperName, consentRec);     
                }
                
                if(consentRec.RecordType.DeveloperName == 'Approved_Email_vod')
                { 
                    if(consentRec.Consent_Type_vod__r != null && !consentRec.Consent_Type_vod__r.isEmpty())
                        consentLinesList.addAll(consentRec.Consent_Type_vod__r); 
                }
            }
        }
        
        if(consentLinesList != null && consentLinesList.size() > 0)
        {
            for(Consent_Line_vod__c conLine : consentLinesList)
            {
                String key = conLine.Consent_Type_vod__c + '-' + conLine.Content_Type_vod__r.External_Id_vod__c;            
                consentLineMap.put(key, conLine);                           
            }
        }
            
        for(Individual inv : individualnewList)
        {
             if(inv.Online_consent__c && invIdToAccIdMap != null && invIdToAccIdMap.size() > 0 && invIdToAccIdMap.get(inv.Id) != null)
             {
                 Account account = accountMap.get(invIdToAccIdMap.get(inv.Id));
                 String key = inv.Selected_Language__c +'-'+account.Country_vod__c;
                 Map<String, Consent_Type_vod__c> consentTypeInnerMap;
                                  
                 if(consentMap != null && consentMap.size() > 0 && consentMap.containsKey(key))
                 {
                     consentTypeInnerMap = consentMap.get(key);
                    
                 }
                 else
                 {
                     if(consentLanguageMap != null && consentLanguageMap.size() > 0 && consentLanguageMap.containsKey(inv.Selected_Language__c))
                     {
                         consentTypeInnerMap = consentLanguageMap.get(inv.Selected_Language__c);
                     }
                 }

                 if(inv.Approved_Primary_Email__c)
                 {                 
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null;                      
                     if(ct != null)
                     {
                        String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_PSMEmail_ExtId;
                        Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null; 
                        if(cl != null)
                        {
                            Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.PersonEmail, ct, 'Opt_In_vod', cl);
                            multichannelConsentList.add(mConsent);
                        }
                     }                     
                 }else{
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                     if(ct != null)
                     {
                         String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_PSMEmail_ExtId;
                         Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null; 
                         if(cl != null)
                         {
                             Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                             account.Id, account.PersonEmail, ct, 'Opt_Out_vod', cl);
                             multichannelConsentList.add(mConsent);
                         }
                     }
                 }
                 
                 if(inv.Approved_Additional_Email__c)
                 {       
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){                    
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null;
                         if(ct != null)
                         {
                            String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_PSMEmail_ExtId;
                            Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null; 
                            if(cl != null)
                            {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.Email_Internal_AGN__c, ct, 'Opt_In_vod', cl);
                                multichannelConsentList.add(mConsent);
                            }
                         }
                    }
                 }else{
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null;
                         if(ct != null)
                         {
                             String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_PSMEmail_ExtId;
                             Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null; 
                             if(cl != null)
                             {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                             account.Id, account.Email_Internal_AGN__c, ct, 'Opt_Out_vod', cl);
                                multichannelConsentList.add(mConsent);
                             }
                         }
                    }
                 }
                 
                 if(inv.Phone_Consent__c)
                 {
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Phone_AGN') != null) ? consentTypeInnerMap.get('Phone_AGN') : null;
                     if(ct != null)
                     {
                        Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Phone_AGN'), 
                                                                                     account.Id, account.PersonMobilePhone, ct, 'Opt_In_vod', null);
                        multichannelConsentList.add(mConsent);
                     }
                 }else{
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Phone_AGN') != null) ? consentTypeInnerMap.get('Phone_AGN') : null;
                     if(ct != null)
                     {
                        Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Phone_AGN'), 
                                                                                     account.Id, account.PersonMobilePhone, ct, 'Opt_Out_vod', null);
                        multichannelConsentList.add(mConsent);
                     }
                 }
                 
                 if(inv.TOV_Consent__c)
                 {
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('TOV_AGN') != null) ? consentTypeInnerMap.get('TOV_AGN') : null;
                    system.debug('consent type'+ct);
                    if(ct != null && account.Country_vod__c != franceCountryCodeId)
                     {
                         Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('TOV_AGN'), 
                                                                                         account.Id, '', ct, 'Opt_In_vod', null);
                         multichannelConsentList.add(mConsent);
                     }
                 }else{
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('TOV_AGN') != null) ? consentTypeInnerMap.get('TOV_AGN') : null;
                     if(ct != null && account.Country_vod__c != franceCountryCodeId)
                     {
                        Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('TOV_AGN'), 
                                                                                     account.Id, '', ct, 'Opt_Out_vod', null);
                        multichannelConsentList.add(mConsent);
                     }
                 }        

                     
             
                 /*******************Added new************************/                
                 if(inv.Allergan_Event_Consent__c )
                 {                 
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                     if(ct != null)
                     {
                        String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId;
                        Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null; 
                        if(cl != null)
                        {
                            Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                     account.Id, account.PersonEmail, ct, 'Opt_In_vod', cl);
                            multichannelConsentList.add(mConsent);
                        }
                     }
                 }else{
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                     if(ct != null)
                     {
                        String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId;
                        Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                        if(cl != null)
                        {
                            Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                     account.Id, account.PersonEmail, ct, 'Opt_Out_vod', cl);
                            multichannelConsentList.add(mConsent);
                        }
                     }
                 }
                 
                  if(inv.Allergan_Event_Adn_Email_Consent_AGN__c )
                 {     
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){            
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                         if(ct != null)
                         {
                            String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId;
                            Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                            if(cl != null)
                            {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.Email_Internal_AGN__c, ct, 'Opt_In_vod', cl);
                                multichannelConsentList.add(mConsent);
                            }
                         }
                    }
                 }else{
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                         if(ct != null)
                         {
                            String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId;
                            Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                            if(cl != null)
                            {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.Email_Internal_AGN__c, ct, 'Opt_Out_vod', cl);
                                multichannelConsentList.add(mConsent);
                            }
                         }
                    }
                 }
                 
                 if(inv.Non_Allergan_Event_Consent__c )
                 {                 
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                     if(ct != null)
                     {
                        String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId_Non_Allergan;
                        Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                        if(cl != null)
                        {
                            Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                     account.Id, account.PersonEmail, ct, 'Opt_In_vod', cl);
                            multichannelConsentList.add(mConsent);
                        }
                     }
                 }else{
                     Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                     if(ct != null)
                     {
                        String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId_Non_Allergan;
                        Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                        if(cl != null)
                        {
                            Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                     account.Id, account.PersonEmail, ct, 'Opt_Out_vod', cl);
                            multichannelConsentList.add(mConsent);
                        }
                     }
                 }
                 
                  if(inv.Non_Allergan_Event_Adn_Consent_AGN__c )
                 {        
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){         
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                         if(ct != null)
                         {
                            String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId_Non_Allergan;
                            Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                            if(cl != null)
                            {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.Email_Internal_AGN__c, ct, 'Opt_In_vod', cl);
                                multichannelConsentList.add(mConsent);
                            }
                         }
                    }
                 }else{
                    if(account.Email_Internal_AGN__c != null && (account.Email_Internal_AGN__c != account.PersonEmail)){
                         Consent_Type_vod__c ct = (consentTypeInnerMap != null && consentTypeInnerMap.size() > 0 && consentTypeInnerMap.get('Approved_Email_vod') != null) ? consentTypeInnerMap.get('Approved_Email_vod') : null; 
                         if(ct != null)
                         {
                            String keyCL = ct.Id + '-' + label.AGN_OnlineConsent_AllerganEvent_ExtId_Non_Allergan;
                            Consent_Line_vod__c cl = (consentLineMap != null && consentLineMap.size() > 0 && consentLineMap.get(keyCL) != null) ? consentLineMap.get(keyCL) : null;
                            if(cl != null)
                            {
                                Multichannel_Consent_vod__c mConsent = AGN_Individual_Utils.createMultichannelRecord(inv.Id, multichannelRecordTypes.get('Approved_Email_vod'), 
                                                                                         account.Id, account.Email_Internal_AGN__c, ct, 'Opt_Out_vod', cl);
                                multichannelConsentList.add(mConsent);
                            }
                         }
                    }
                 }
            }
        }
         System.debug('consent records:: '+multichannelConsentList);
        
        if(multichannelConsentList != null && multichannelConsentList.size() > 0)
        {
            //AG CC
            if (Schema.sObjectType.Multichannel_Consent_vod__c.isCreateable()){
                    insert multichannelConsentList;
                }
        }
        
       }
   
        
        //Updated as a part of ICL Project
        
        else
        {
        
           
           
            Multichannel_Consent_vod__c mcConsent = new Multichannel_Consent_vod__c();
            
            for(Individual icl : individualnewList)
            {
                 System.debug('invi************* '+invi);
              
         if(icl.ICL_Flag_AGN__c==true)
             {
             
                Account ac=[select Id,country_vod__c from Account where PersonIndividualId =:icl.Id];
                Consent_Type_vod__c ct=[select ID,Consent_Custom_Duration_vod__c from Consent_Type_vod__c where Consent_Header_vod__c in (select ID from Consent_Header_vod__c where Country_vod__c=:ac.country_vod__c and Status_vod__c='Active_vod' and Language_vod__c=:icl.Selected_Language__c) and recordtype.name='ICL Consent'];
                RecordType rt=[Select Id, DeveloperName from RecordType where SobjectType = 'Multichannel_Consent_vod__c' and DeveloperName='ICL_Consent_AGN'];
                     
                         Date expiryDate=system.today();
                         Decimal duration=ct.Consent_Custom_Duration_vod__c/12 ;
                         //AG CC
                         if (Schema.sObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){
                            mcConsent.Account_vod__c=ac.Id;
                         }
                         mcConsent.Last_Device_vod__c='Online';
                         mcConsent.Consent_Type_vod__c=ct.ID;
                         mcConsent.Capture_Datetime_vod__c=system.now();
                         mcConsent.Recordtypeid=rt.Id;
                 
                        //Ru
                         mcConsent.Individual_ID_AGN__c= icl.Id;
                        //Ru
                        
                        if(icl.ICL_Consent_AGN__c==true )
                        {
                              mcConsent.Opt_Type_vod__c='Opt_In_vod';
                              mcConsent.Opt_Expiration_Date_vod__c=expiryDate.addYears(Integer.valueOf(duration));
                              
                        }
                        else
                        {
                             mcConsent.Opt_Type_vod__c='Opt_Out_vod';
                             mcConsent.Opt_Expiration_Date_vod__c=Null;
                             
                        }
                        
                   }
              }    
              System.debug('mcconsent************ '+mcConsent);
              //AG CC
              if (Schema.sObjectType.Multichannel_Consent_vod__c.isCreateable()){
                  insert mcConsent;
              }            
            }                 //Updated as a part of ICL Project
          }              
       }
     }