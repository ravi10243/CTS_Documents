/*****************************************************************************************************************************************************************
Apex  Class- AGN_ConsentEmailNotifcationHelper
Description- This helper class is used to send Opt-In and Opt-Out email notification to Hcp's
Developer Name- Preeti Achary
LastModified Date- 25 Oct 2018
********************************************************************************************************************************************************************/

public class AGN_ConsentEmailNotifcationHelper {
    public Map<String, String> emailCustSetOptInMap;
    public Map<String, String> emailCustSetOptOutMap;
    public Set<String> tempNameSet; 
    public Map<EmailTemplate,String> emailTemplateSubjectOptIn;
    public Map<EmailTemplate,String> emailTemplateSubjectOptOut;
    public Map<String,EmailTemplate> templateMapOptIn;
    public Map<String,EmailTemplate> templateMapOptOut;
    public String defaultTempNameOptIn;
    public String defaultTempNameOptOut;
    public List<OrgWideEmailAddress> owea;
    private Set<String> ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getConsentCountryCodes();
        
    public AGN_ConsentEmailNotifcationHelper(){
        tempNameSet = new Set<String>();
        emailCustSetOptInMap = new map<String,String>();
        emailCustSetOptOutMap = new map<String,String>();
        templateMapOptIn =new Map<String,Emailtemplate>();
        templateMapOptOut=new Map<String,Emailtemplate>();
        emailTemplateSubjectOptIn = new Map<EmailTemplate,String>();
        emailTemplateSubjectOptOut = new Map<EmailTemplate,String>();
        owea = new List<OrgWideEmailAddress>();
        System.debug('BeforeDataFetch**:  ' + Limits.getCpuTime());
        //Loop Through Custom setting (AGN_Consent_Email_Template_Settings__c)
        for(AGN_Consent_Email_Template_Settings__c emailTempSt: AGN_Consent_Email_Template_Settings__c.getall().values()){
            String LangStr = emailTempSt.Language__c; 
            String templName = emailTempSt.Template_Name__c ; // DeveloperName of a template.
            /*****Opt_In_Starts*******/ 
            if(emailTempSt.OPT_IN__c && !String.isBlank(LangStr)){
                emailCustSetOptInMap.put(LangStr,templName);
                tempNameSet.add(templName);
                system.debug('emailCustSetOptInMap***'+emailCustSetOptInMap);
            }
            if(emailTempSt.OPT_IN__c && emailTempSt.Default__c && !String.isBlank(LangStr)){
                defaultTempNameOptIn =  templName;
            }
            /*****Opt_In_Ends*******/
            /*****Opt_Out_Starts*******/    
            if(!emailTempSt.OPT_IN__c && !String.isBlank(LangStr)){
                emailCustSetOptOutMap.put(LangStr,templName);
                tempNameSet.add(templName);
                system.debug('emailCustSetOptOutMap***'+emailCustSetOptOutMap);
            }
            if(emailTempSt.Default__c && !emailTempSt.OPT_IN__c && !String.isBlank(LangStr)){
                defaultTempNameOptOut = templName;
            }
            /*****Opt_Out_Ends*******/          
        }//Custom_Setting_loop_Ends./
        if(!tempNameSet.isEmpty()){
            for(EmailTemplate emailTemp : [SELECT Id,Name,Body,HTMLValue,developername,Subject FROM EmailTemplate WHERE developername in :tempNameSet]){
                String tempNameStr =  emailTemp.developername; 
                /*****Opt_In_Starts*******/ 
                if(!String.isBlank(tempNameStr) && tempNameStr.containsIgnoreCase('Opt_In')){
                    if(!templateMapOptIn.containskey(emailTemp.developername)){
                    templateMapOptIn.put(emailTemp.developername,emailTemp);
                    }
                    if(!emailTemplateSubjectOptIn.containskey(emailTemp)){
                        emailTemplateSubjectOptIn.put(emailTemp,emailTemp.subject);
                    }
                }
                /*****Opt_In_Ends*******/
                /*****Opt_Out_Starts*******/
                if(!String.isBlank(tempNameStr) && tempNameStr.containsIgnoreCase('Opt_Out')){
                    if(!templateMapOptOut.containskey(emailTemp.developername)){
                    templateMapOptOut.put(emailTemp.developername,emailTemp);
                    }
                    if(!emailTemplateSubjectOptOut.containskey(emailTemp)){
                        emailTemplateSubjectOptOut.put(emailTemp,emailTemp.subject);
                    }
                }
                /*****Opt_Out_Ends*******/
            }//Template_loop_Ends. 
        }
    }
    public void sendEmail(List<Multichannel_Consent_vod__c> mcConList){
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<String> allEmailList = new List<String>();
        owea = [select Id from OrgWideEmailAddress where DisplayName ='Allergan Notifications'];
        List<Multichannel_Consent_vod__c> mcList = new List<Multichannel_Consent_vod__c>();
        
        Map<Id,Id> consIdMcIdMap = new Map<Id,Id>();
        Map<Id,Id> contentIdMcIdMap = new Map<Id,Id>();
        set<Id> contentIds = new set<Id>();
        Map<Id,Multichannel_Consent_vod__c> mcIdTomcMap = new Map<Id, Multichannel_Consent_vod__c>();
        system.debug('countriesss'+ENABLED_COUNTRIES_CODES);
        List<Multichannel_Consent_vod__c> mcConsentsList = new List<Multichannel_Consent_vod__c>(); 
        List<string> contentName = new List<string>();
        List<string> countryName= new List<string>();
        
        mcList = [SELECT Consent_Type_vod__c,Account_vod__r.Language_vod__c, Account_vod__r.Country_vod__r.Name,Doctors_Name_AGN__c,AGN_Consent_Type_Multichannel__c,Optout_Event_Type_vod__c,Content_Type_vod__r.Name,Content_Type_vod__c,Account_vod__r.PersonEmail,Account_vod__r.Email_Internal_AGN__c,RecordType.Name,RecordType.DeveloperName, Consent_Line_vod__c, Consent_Line_vod__r.Content_Type_Display_Name_vod__c, Consent_Type_vod__r.Channel_Label_vod__c,Channel_Value_vod__c,Consent_Type_vod__r.Consent_Header_vod__r.Language_vod__c,FromGigya_AGN__c,Id,Opt_Type_vod__c,RecordTypeId FROM Multichannel_Consent_vod__c where id in:mcConList and Account_vod__r.Country_vod__r.Name IN:ENABLED_COUNTRIES_CODES AND Account_vod__r.RecordType.Name = 'Professional_vod' and FromGigya_AGN__c=False and (Account_vod__r.PersonEmail!=null OR Account_vod__r.Email_Internal_AGN__c!=null OR Channel_Value_vod__c!=null) and (Opt_Type_vod__c='Opt_In_vod' OR Opt_Type_vod__c='Opt_Out_vod')];
        
        for(Multichannel_Consent_vod__c mcon :mcList){
            mcIdTomcMap.put(mcon.Id, mcon);
            if(mcon.Consent_Type_vod__c!=null  && mcon.Consent_Line_vod__c == null && mcon.Content_Type_vod__c == null){
                consIdMcIdMap.put(mcon.Consent_Type_vod__c, mcon.Id);
            }
            else if(mcon.Content_Type_vod__c!=null && mcon.Consent_Type_vod__c == null  && mcon.Consent_Line_vod__c == null){
                //contentIds.add(mcon.Content_Type_vod__c);
                contentIdMcIdMap.put(mcon.Content_Type_vod__c, mcon.Id);
                countryName.add(mcon.Account_vod__r.Country_vod__r.Name);
                system.debug('countryName******'+countryName+'       contentId: '+contentIdMcIdMap.keyset());
            }
        }//loop_mch_ends
        List<Consent_Line_vod__c> conLineList = new List<Consent_Line_vod__c>();
        Multichannel_Consent_vod__c clonerec = new Multichannel_Consent_vod__c(); 
        Multichannel_Consent_vod__c  MCunsubscribeconsent = new Multichannel_Consent_vod__c();
        String displayLabel= '';
        
          
        for(Consent_Line_vod__c consentLine: [Select Id, Consent_Type_vod__c, Content_Type_vod__c,Consent_Country_Code_AGN__c,                                      Content_Type_vod__r.Name,Content_Type_Display_Name_vod__c 
                                              from Consent_Line_vod__c where Content_Type_vod__c in:contentIdMcIdMap.keyset() and Consent_Country_Code_AGN__c in: countryName]){
                                                
                                                Id mconsentId = contentIdMcIdMap.get(consentLine.Content_Type_vod__c);                                                  
                                              
                                                displayLabel = consentLine.Content_Type_Display_Name_vod__c ;
                                                 
                                                if(mcIdTomcMap.containsKey(mconsentId)){
                                                    MCunsubscribeconsent = mcIdTomcMap.get(mconsentId);
                                                    MCunsubscribeconsent.AGN_Consent_Type_Multichannel__c = displayLabel;
                                                    System.debug('*******MCunsubscribeconsent.AGN_Consent_Type_Multichannel__c******* '+MCunsubscribeconsent.AGN_Consent_Type_Multichannel__c);
                                                }
                                        //R:commented       displayLabel = consentLine.Content_Type_Display_Name_vod__c ;                                         
                                        }//consentLine Loop_ends.                                                       

        for(Consent_Type_vod__c consType : [Select Id, RecordTypeId, Consent_Header_vod__c, 
                                            RecordType.DeveloperName, Consent_Custom_Duration_vod__c, Consent_Expires_In_vod__c,
                                            Consent_Header_vod__r.Language_vod__c, Consent_Header_vod__r.Country_vod__c,
                                            (select Id, Consent_Type_vod__c, Content_Type_vod__c,Content_Type_Display_Name_vod__c from Consent_Type_vod__r where  Content_Type_vod__r.External_Id_vod__c!=null)
                                            from Consent_Type_vod__c where Consent_Header_vod__r.Status_vod__c = 'Active_vod' and Id in: consIdMcIdMap.keySet() and recordtype.DeveloperName = 'Approved_Email_vod' order by Display_Order_vod__c ]){
                                                Multichannel_Consent_vod__c  MCconsent = new Multichannel_Consent_vod__c(); 
                                               
                                                Id mconId = consIdMcIdMap.get(consType.Id);
                                                
                                                if(mcIdTomcMap.containsKey(mconId)){
                                                    MCconsent = mcIdTomcMap.get(mconId); 
                                                }
                                                
                                                conLineList = consType.Consent_Type_vod__r;                                        
                                                
                                                if(!conLineList.isEmpty()){                                                    
                                                    Integer count = 0;
                                                    for(Consent_Line_vod__c conLine :conLineList){
                                                        String displayName = conLine.Content_Type_Display_Name_vod__c; 
                                                                         
                                                        
                                                        if(displayName.contains('Product')){
                                                            MCconsent.AGN_Consent_Type_Multichannel__c = displayName;                                                             
                                                        }
                                                        else{
                                                            clonerec = MCconsent.clone(false, false, false,false);
                                                            System.debug('clonerec***');
                                                            clonerec.AGN_Consent_Type_Multichannel__c = displayName ;
                                                            mcConsentsList.add(clonerec);
                                                            count++;
                                                        }
                                                    }//line_loop_ends.
                                                }       
                                            }//consentLoop_ends.
        if(!mcConsentsList.isEmpty()){
            System.debug('mcConsentsListSize:  '+mcConsentsList.size());
            mcList.addAll(mcConsentsList);
        }
        for(Multichannel_Consent_vod__c Mconsent : mcList){
                System.debug('******mcConsent*******  :'+Mconsent.Consent_Type_vod__c + '  & '+Mconsent.AGN_Consent_Type_Multichannel__c);
                Set<string> MCEmailset = new Set<string>();
                String mcLang;
                String channelLabel;
                String accName;
                String body;
                if(Mconsent.Consent_Type_vod__c!=null && Mconsent.Consent_Type_vod__r.Consent_Header_vod__c!=null && Mconsent.Consent_Type_vod__r.Consent_Header_vod__r.Language_vod__c!=null){
                    mcLang = Mconsent.Consent_Type_vod__r.Consent_Header_vod__r.Language_vod__c;
                    system.debug('mclanguage'+mcLang);
                }
                else if(Mconsent.Consent_Type_vod__c == null && Mconsent.Content_Type_vod__c!=null && Mconsent.Optout_Event_Type_vod__c=='Unsubscribed_vod'){
                if(Mconsent.Account_vod__r.Language_vod__c!=null)
                {
                mcLang = Mconsent.Account_vod__r.Language_vod__c;
                }
                /*else{
                mcLang= UserInfo.getLocale();
                }*/
                }
                if(Mconsent.Consent_Line_vod__c!=null && Mconsent.Consent_Line_vod__r.Content_Type_Display_Name_vod__c!=null){
                    System.debug('ifExp**consentLine** : '+Mconsent.Consent_Line_vod__c);
                    channelLabel = Mconsent.Consent_Line_vod__r.Content_Type_Display_Name_vod__c;
                    system.debug(' channelLabel_4'+ channelLabel);
                } 
                else if(Mconsent.Consent_Type_vod__c!=null ){//Mconsent.Consent_Type_vod__r.Channel_Label_vod__c!=null)
                    if(Mconsent.AGN_Consent_Type_Multichannel__c!=null){
                        //String mcchannel = Mconsent.Agn_consent_type_multichannel__c;
                        channelLabel = Mconsent.Agn_consent_type_multichannel__c;
                        system.debug(' channelLabel_2'+ channelLabel);
                    }
                    else if(Mconsent.Consent_Type_vod__r.Channel_Label_vod__c!=null){
                        channelLabel = Mconsent.Consent_Type_vod__r.Channel_Label_vod__c;
                        system.debug(' channelLabel_3'+ channelLabel);
                    }
                }
                else if(Mconsent.Consent_Type_vod__c == null && Mconsent.Content_Type_vod__c!=null && Mconsent.Optout_Event_Type_vod__c=='Unsubscribed_vod')
                {
                        channelLabel = Mconsent.Agn_consent_type_multichannel__c;
                        system.debug(' channelLabel____4'+ channelLabel);
                    
                }
                if(Mconsent.Doctors_Name_AGN__c!=null){
                    accName = Mconsent.Doctors_Name_AGN__c;
                }
                system.debug('channellabel_1'+channelLabel);
                system.debug('consentHeaderId'+Mconsent.Consent_Type_vod__r.Consent_Header_vod__r.id);
                system.debug('templateMapOptIn***'+templateMapOptIn);
                system.debug('emailCustSetOptInMap***'+emailCustSetOptInMap);
                system.debug('templateMapOptOut***'+templateMapOptOut);
                system.debug('emailCustSetOptOutMap***'+emailCustSetOptOutMap);
                
                system.debug('RECORD TYPE'+Mconsent.RecordType.Name);
                if(Mconsent.Channel_Value_vod__c!=null && (AGNGigyaConsentFactory.EMAIL_BASED_CONSENTS.indexOf(Mconsent.RecordType.DeveloperName) >= 0)){
                    MCEmailset.add(Mconsent.Channel_Value_vod__c);
                    system.debug('MCEmailset'+MCEmailset);
                }
                else{
                    if(Mconsent.Account_vod__r.PersonEmail!=null){
                        MCEmailset.add(Mconsent.Account_vod__r.PersonEmail);
                        system.debug('accEmailset'+MCEmailset);
                    }
                    if(Mconsent.Account_vod__r.Email_Internal_AGN__c!=null){
                        MCEmailset.add(Mconsent.Account_vod__r.Email_Internal_AGN__c);
                        system.debug('accEmailset'+MCEmailset);
                    }
                }
                if(Mconsent.Opt_Type_vod__c=='Opt_In_vod' &&!templateMapOptIn.isEmpty() && !emailCustSetOptInMap.isEmpty() && emailCustSetOptInMap.containsKey(mcLang)){
                    system.debug('*****insideiffff****');
                    if(!MCEmailset.isEmpty()){
                        allEmailList.addAll(MCEmailset);
                        system.debug('==allEmailListOptIn=='+allEmailList);
                    }
                    system.debug('allEmailList***'+allEmailList);
                    string templateNameOptIn;
                    if(mcLang!=null){
                        templateNameOptIn = emailCustSetOptInMap.get(mcLang);
                    }
                    system.debug('templateNameOptIn***'+templateNameOptIn);
                    if(!String.isBlank(templateNameOptIn) && templateMapOptIn.containsKey(templateNameOptIn)){
                        system.debug('insidee2ndifff***');
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail = AGN_EmailUtilityClass.constructConsentEmail(emailTemplateSubjectOptIn.get(templateMapOptIn.get(templateNameOptIn)),allEmailList,owea,templateMapOptIn.get(templateNameOptIn).Id,templateMapOptIn.get(templateNameOptIn).HTMLValue,accName,channelLabel);
                        messageList.add(mail);
                    }
                    allEmailList.clear(); 
                }
                else if(Mconsent.Opt_Type_vod__c=='Opt_In_vod' && !String.isBlank(defaultTempNameOptIn) && !templateMapOptIn.isEmpty() && templateMapOptIn.containsKey(defaultTempNameOptIn)){
                    System.debug('*******DefaultCodeSectionOptIn******');
                    System.debug('*******defaultTempNameOptIn******'+defaultTempNameOptIn);
                    if(!MCEmailset.isEmpty()){
                        allEmailList.addAll(MCEmailset);
                        system.debug('==allEmailListOptInDefault=='+allEmailList);
                    }
                    system.debug('allEmailList***'+allEmailList);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail = AGN_EmailUtilityClass.constructConsentEmail(emailTemplateSubjectOptIn.get(templateMapOptIn.get(defaultTempNameOptIn)),allEmailList,owea,templateMapOptIn.get(defaultTempNameOptIn).Id,templateMapOptIn.get(defaultTempNameOptIn).HTMLValue,accName,channelLabel);
                    messageList.add(mail);
                    allEmailList.clear();
                } 
                else if(Mconsent.Opt_Type_vod__c=='Opt_Out_vod' &&!templateMapOptOut.isEmpty() && !emailCustSetOptOutMap.isEmpty() && emailCustSetOptOutMap.containsKey(mcLang)){
                    system.debug('*****insideelse****');
                    if(!MCEmailset.isEmpty()){
                        allEmailList.addAll(MCEmailset);
                        system.debug('==allEmailListOptOut=='+allEmailList);
                    }
                    system.debug('allEmailList***'+allEmailList);
                    string templateNameOptOut;
                    if(mcLang!=null){
                        templateNameOptOut = emailCustSetOptOutMap.get(mcLang);
                    }
                    system.debug('templateNameOptOut***'+templateNameOptOut);
                    if(!String.isBlank(templateNameOptOut) && templateMapOptOut.containsKey(templateNameOptOut)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail = AGN_EmailUtilityClass.constructConsentEmail(emailTemplateSubjectOptOut.get(templateMapOptOut.get(templateNameOptOut)),allEmailList,owea,templateMapOptOut.get(templateNameOptOut).Id,templateMapOptOut.get(templateNameOptOut).HTMLValue,accName,channelLabel);
                        messageList.add(mail);
                        system.debug('messageList***'+messageList);
                    }  
                    allEmailList.clear();
                }
                
                else if(Mconsent.Opt_Type_vod__c=='Opt_Out_vod' && !String.isBlank(defaultTempNameOptOut) && !templateMapOptOut.isEmpty() && templateMapOptOut.containsKey(defaultTempNameOptOut)){
                    System.debug('*******DefaultCodeSectionOptOut******');
                    System.debug('*******defaultTempNameOptOut******'+defaultTempNameOptOut);
                    if(!MCEmailset.isEmpty()){
                        allEmailList.addAll(MCEmailset);
                        system.debug('==allEmailListOptOutDefault=='+allEmailList);
                    }
                    system.debug('allEmailListOptOutDefault***'+allEmailList);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail = AGN_EmailUtilityClass.constructConsentEmail(emailTemplateSubjectOptOut.get(templateMapOptOut.get(defaultTempNameOptOut)),allEmailList,owea,templateMapOptOut.get(defaultTempNameOptOut).Id,templateMapOptOut.get(defaultTempNameOptOut).HTMLValue,accName,channelLabel);
                    messageList.add(mail);
                    allEmailList.clear();
                } 
            }//scope loop ends    
        list<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
        try{
            if(messageList!=null && messageList.size()>0){
                results = Messaging.sendEmail(messageList);
                System.debug('The email was sent successfully.'+results);
            }
        }
        Catch(Exception e){
            System.debug('The email failed to send: ' + e.getMessage());
        }
    }
}