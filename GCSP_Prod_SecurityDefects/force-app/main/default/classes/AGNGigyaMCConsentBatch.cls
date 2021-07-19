/**
* --------------
* Allergan GDPR 
* March 2018
* --------------
* Main class istantiated by AGNMCConsentTrigger events
*/

global class AGNGigyaMCConsentBatch implements Database.Batchable<Multichannel_Consent_vod__c>, Database.AllowsCallouts, Database.Stateful {
    global final Set<Id> mcConsentIds;
    private Integer totalCount = 0;
    private List<Multichannel_Consent_vod__c> mcConsentsSubAll = new List<Multichannel_Consent_vod__c>();
    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    private Map<String, String> veevaAccountsGigyaAccounts = new Map<String, String>();
    
    global AGNGigyaMCConsentBatch(Set<Id> mcConsentIds){
        this.mcConsentIds = mcConsentIds;
    }
    
    global List<Multichannel_Consent_vod__c> start(Database.BatchableContext batchableContext){
        return AGNGigyaMCConsentUtil.getConsentList(mcConsentIds);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<Multichannel_Consent_vod__c> mcConsents) {
       processConsents(mcConsents);
        system.debug('mcConsents@@@@@@'+mcConsents.size());
        Map<Id,Id> consIdMcIdMap = new Map<Id,Id>();
        Map<Id,Multichannel_Consent_vod__c> mcIdTomcMap = new Map<Id, Multichannel_Consent_vod__c>();
        List<Multichannel_Consent_vod__c> mcConsentsList = new List<Multichannel_Consent_vod__c>();
        
        // including '(un)subscribe all' consents
        // if mcConsent.consenttype is "Approved Email" and mcConsent.consentline is empty
        //   create (but not save them) three mcconsents cloned from mcConsent with
        //     mcConsent.consenttype = approved email
        //     mcConsent.consentline = marketing, agn event, non agn event
        //     mcConsent.contenttype =  marketing, agn event, non agn event
        //   and add them to mcConsents
        for(Multichannel_Consent_vod__c mcConsent : mcConsents) {
            
            if(mcConsent.Consent_Type_vod__c!=null && mcConsent.Consent_Type_vod__r.recordtype.DeveloperName == 'Approved_Email_vod' && mcConsent.Consent_Line_vod__c == null){
                System.debug('*** creating new ***');
                consIdMcIdMap.put(mcConsent.Consent_Type_vod__c, mcConsent.Id);
                mcIdTomcMap.put(mcConsent.Id, mcConsent);
                
                List<Consent_Line_vod__c> conLineList = new List<Consent_Line_vod__c>();
                Multichannel_Consent_vod__c clonerec = new Multichannel_Consent_vod__c();
                Multichannel_Consent_vod__c  Mconsent = new Multichannel_Consent_vod__c();
                
                for(Consent_Type_vod__c consType : [Select Id, RecordTypeId, Consent_Header_vod__c,
                                                    RecordType.DeveloperName, Consent_Custom_Duration_vod__c, Consent_Expires_In_vod__c,
                                                    Consent_Header_vod__r.Language_vod__c, Consent_Header_vod__r.Country_vod__c,
                                                    (select Id, Consent_Type_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c, Content_Type_Display_Name_vod__c from Consent_Type_vod__r where  Content_Type_vod__r.External_Id_vod__c!=null)
                                                    from Consent_Type_vod__c where Consent_Header_vod__r.Status_vod__c = 'Active_vod' and Id in: consIdMcIdMap.keySet() and recordtype.DeveloperName = 'Approved_Email_vod'
                                                    order by Display_Order_vod__c]){
                                                        
                                                            Id mconId = consIdMcIdMap.get(consType.Id);
                                                            Mconsent = mcIdTomcMap.get(mconId);
                                                            conLineList = consType.Consent_Type_vod__r;
                                                        
                                                        
                                                    }//consentLoop_ends.
                if(!conLineList.isEmpty()){
                    for(Consent_Line_vod__c conLine :conLineList){
                        String displayName = conLine.Content_Type_Display_Name_vod__c;
                        if(displayName.contains('Product')){ //TODO check this
                            Mconsent.Consent_Line_vod__c = conLine.Id;
                            Mconsent.Content_Type_vod__r = conLine.Content_Type_vod__r;
                        }
                        else{
                            clonerec = Mconsent.clone(false, false, false,false);
                            clonerec.Consent_Line_vod__c = conLine.Id;
                            clonerec.Content_Type_vod__r = conLine.Content_Type_vod__r;
                            clonerec.Id = Mconsent.Id;
                            mcConsentsSubAll.add(clonerec);
                        }
                    }//line_loop_ends.
                }
            }
        }
        system.debug('size is '+mcConsentsSubAll.size());
        processConsents(mcConsentsSubAll);
    }
    
    global void finish(Database.BatchableContext batchableContext){
        if(!validationExceptions.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
            System.debug('>>> EXCEPTION <<<');
            System.debug(validationExceptions[0]);
            throw validationExceptions[0];
        } else{
            AGNInterfacePublishEvent.logBatchApex(batchableContext,totalCount);
        }
    }
    
    public void processConsents(List<Multichannel_Consent_vod__c> mcConsents) {
        totalCount = totalCount + mcConsents.size();
      
        Map<String, AGN_GDPR_Countries__c> mapstr = new Map<String, AGN_GDPR_Countries__c>();
            for(AGN_GDPR_Countries__c CountryLst:AGN_GDPR_Countries__c.getall().values()){
               
                    mapstr.get(CountryLst.Country__c);               
                
            }
        
        
       
        for(Multichannel_Consent_vod__c mcConsent : mcConsents) {
            try {
                String rtDeveloperName = '';
                if (mcConsent.Optout_Event_Type_vod__c == AGNGigyaMCConsentUtil.getUnsubscribeLinkOptOutEventType()) {
                    rtDeveloperName = AGNGigyaConsentFactory.EMAIL_CONTENT_MAPPING.get(mcConsent.Content_Type_vod__r.External_Id_vod__c);
                } else {
                    rtDeveloperName = mcConsent.Consent_Type_vod__r.RecordType.DeveloperName;
                }
                System.debug('mcConsent.Content_Type_vod__r.External_Id_vod__c|' + mcConsent.Content_Type_vod__r.External_Id_vod__c);
                System.debug('rtDeveloperName|' + rtDeveloperName);
                
                //*****************************RU/AS start******************************************** 
                System.debug('mcConsent.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c  ************ '+mcConsent.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c);
                    Boolean ICLcountry= mapstr.containskey(mcConsent.Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c);
                    system.debug('value is '+ICLcountry);
                   
                    if(ICLcountry == false && rtDeveloperName == 'ICL_Consent_AGN' )
                    {
                        
                        //do nothing
                    }
                    else
                    {  
                        //*****************************RU End********************************************   
                        
                        AGNGigyaConsentFactory consentFactory = AGNGigyaConsentFactory.getFactory(rtDeveloperName);
                        String gigyaUID = null;
                        system.debug('a-----veevaAccountsGigyaAccounts--->' +veevaAccountsGigyaAccounts);
                        if (veevaAccountsGigyaAccounts.containsKey(mcConsent.Account_vod__c + '' + mcConsent.Channel_Value_vod__c)) {
                            gigyaUID = veevaAccountsGigyaAccounts.get(mcConsent.Account_vod__c + '' + mcConsent.Channel_Value_vod__c);
                        } else {
                            gigyaUID = consentFactory.getGigyaUserId(mcConsent.Account_vod__c, mcConsent.Channel_Value_vod__c, mcConsent.Account_vod__r.External_ID_vod__c);
                        }
                        System.debug('a---gigyaUID101---> ' + gigyaUID);
                        if (gigyaUID == null) {
                            System.debug('gigya account not found|' + mcConsent.Account_vod__c + '|' + mcConsent.Channel_Value_vod__c);
                            AGNGigyaAccount gigyaAccount = new AGNGigyaAccount();
                            gigyaAccount.setId(mcConsent.Account_vod__c);
                            if (consentFactory.emailBased && mcConsent.Channel_Value_vod__c != null) {
                                gigyaAccount.setUsername(mcConsent.Channel_Value_vod__c);
                            } else {
                                gigyaAccount.setUsername(mcConsent.Account_vod__c);
                            }
                            gigyaAccount.setFirstName(mcConsent.Account_vod__r.FirstName);
                            gigyaAccount.setLastName(mcConsent.Account_vod__r.LastName);
                            if (consentFactory.emailBased) {
                                gigyaAccount.setEmail(mcConsent.Channel_Value_vod__c);
                            }
                            gigyaAccount.setSecondaryEmail(mcConsent.Account_vod__r.Email_Internal_AGN__c);
                            gigyaAccount.setExternalId(mcConsent.Account_vod__r.External_ID_vod__c);
                            gigyaAccount.setExternalId2(mcConsent.Account_vod__r.External_ID2_AGN__c);
                            gigyaAccount.setMdmId(mcConsent.Account_vod__r.MDM_ID_AGN__c);
                            gigyaAccount.setCountryCode(mcConsent.Account_vod__r.Country_vod__r.Name);
                            gigyaAccount.setCountryName(mcConsent.Account_vod__r.Country_Name_AGN__c);
                            gigyaAccount.setSalutation(mcConsent.Account_vod__r.Salutation);
                            gigyaAccount.setStatus(mcConsent.Account_vod__r.Status_AGN__c);
                            gigyaAccount.setAdditionalStatus(mcConsent.Account_vod__r.Additional_Status_AGN__c);
                            if (!String.isBlank(mcConsent.Account_vod__r.External_ID_vod__c) && mcConsent.Account_vod__r.External_ID_vod__c.startsWith('W')) {
                                gigyaAccount.setSpecialty1(mcConsent.Account_vod__r.Specialty_1_AGN__r.Name);
                                gigyaAccount.setSpecialty2(mcConsent.Account_vod__r.Specialty_2_AGN__r.Name);
                            } else {
                                gigyaAccount.setSpecialty1(mcConsent.Account_vod__r.Specialty_Allergan_1_AGN__r.Name);
                                gigyaAccount.setSpecialty2(mcConsent.Account_vod__r.Sub_Specialty_Allergan_AGN__r.Name);
                            }
                            System.debug('creating ' + gigyaAccount);
                            gigyaUID = AGNGigyaRESTAccount.registerAccount(gigyaAccount);
                        }
                    
                        veevaAccountsGigyaAccounts.put(mcConsent.Account_vod__c + '|' + mcConsent.Channel_Value_vod__c, gigyaUID);
                        
                        String consentId = '';
                        system.debug('a---mcConsent.Optout_Event_Type_vod__c-->' +mcConsent.Optout_Event_Type_vod__c + 'a--AGNGigyaMCConsentUtil.getUnsubscribeLinkOptOutEventType()' +AGNGigyaMCConsentUtil.getUnsubscribeLinkOptOutEventType());
                        if (mcConsent.Optout_Event_Type_vod__c == AGNGigyaMCConsentUtil.getUnsubscribeLinkOptOutEventType()) {
                            consentId = consentFactory.getConsentIdFromConsentName(gigyaUID, mcConsent);
                        } else {
                            consentId = consentFactory.getConsentId(mcConsent);
                        }
                        system.debug('a--consentId-->' +consentId);
                        system.debug('a--consentFactory-->' +consentFactory);
                        if (!consentFactory.exists(consentId)) {
                            String description = mcConsent.Consent_Type_vod__r.RecordType.DeveloperName;
                            system.debug('a---description--->' +description);
                            system.debug('a---mcConsent.Consent_Type_vod__r.Channel_Label_vod__c-->' +mcConsent.Consent_Type_vod__r.Channel_Label_vod__c);
                            if (mcConsent.Consent_Type_vod__r.Channel_Label_vod__c != null && mcConsent.Consent_Type_vod__r.Channel_Label_vod__c.length() > 0) {
                                description += ' - Channel label: ' + mcConsent.Consent_Type_vod__r.Channel_Label_vod__c;
                            }
                            system.debug('a---mcConsent.Consent_Type_vod__r.Consent_Expires_In_vod__c' +mcConsent.Consent_Type_vod__r.Consent_Expires_In_vod__c);
                            if (mcConsent.Consent_Type_vod__r.Consent_Expires_In_vod__c != null && mcConsent.Consent_Type_vod__r.Consent_Expires_In_vod__c.length() > 0) {
                                description += ' - It expires in: ' + mcConsent.Consent_Type_vod__r.Consent_Expires_In_vod__c;
                            }
                            
                            if (!consentFactory.setSchema(consentId, description)) {
                                System.debug('Gigya PreferencesSchema creation error');
                            }
                        }
                        Boolean subscribed = mcConsent.Opt_Type_vod__c == 'Opt_In_vod';
                        system.debug('a---subscribed---->' +subscribed);
                        
                        List<String> tags = new List<String>();
                        
                        system.debug('a---mcConsent.Id--->' +mcConsent.Id);
                        tags.add(mcConsent.Id);
                        tags.add('Consent User Type:' + mcConsent.Consent_User_Type_AGN__c);
                        if (mcConsent.Consent_Type_vod__c != null && mcConsent.Consent_Type_vod__r.Channel_Label_vod__c != null) {
                            tags.add('Consent Type - Channel Label:' + mcConsent.Consent_Type_vod__r.Channel_Label_vod__c);
                        }
                        if (mcConsent.Capture_Datetime_vod__c != null) {
                            tags.add('Consent Capture Datetime:' + mcConsent.Capture_Datetime_vod__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                        }
                        tags.add('Consent Created By:' + mcConsent.CreatedBy.Name);
                        
                        Map<String, String> extraFields = new Map<String, String>();
                        System.debug('mcConsent.Consent_Type_vod__r.Channel_Source_vod__c|' + mcConsent.Consent_Type_vod__r.Channel_Source_vod__c);
                        if (AGNGigyaConsentFactory.PHONE_CHANNEL_SOURCES.indexOf(mcConsent.Consent_Type_vod__r.Channel_Source_vod__c) >= 0) {
                            extraFields.put('profile', '{\'phones\' : [{\'number\' : \'' + mcConsent.Channel_Value_vod__c + '\'}]}');
                        }
                        Boolean rb = consentFactory.setConsent(gigyaUID, consentId, subscribed, mcConsent.Capture_Datetime_vod__c, extraFields, tags);
                        system.debug('a---rb--' +rb);
                        system.debug('a---rb--' +consentFactory.setConsent(gigyaUID, consentId, subscribed, mcConsent.Capture_Datetime_vod__c, extraFields, tags));
                        
                    } 
                 //*****************************RU start and end******************************************** 
                
            } catch(AGNGigyaValidationException e) {
                system.debug('in catch block');
                e.errorDetail = e.errorDetail + '|mcconsent:' + mcConsent.Id + '|account:' + mcConsent.Account_vod__c;
                validationExceptions.add(e);
            }
        }
    }
}