public without sharing class AGN_ICL_SendEmailNotification {
    
    @InvocableMethod(label='NotifyBusinessTeam')
    public static void SendNotificationToBexTeam(List<Locator_Listing_AGN__c>  locList) {
        
      
        String LocCountryCode = ''; 
        String LocLangCode = '';
        Boolean hasRecord = false;
        Map<String,List<Locator_Listing_AGN__c> > countryLocMap = new  Map<String,List<Locator_Listing_AGN__c> >();
        List<EmailTemplate> eTList = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        
        Map<String, EmailTemplate> eTMap = new Map<String, EmailTemplate>(); 
        Map<String,AGN_ICL_Mailing_List__mdt> countryMetadataMap = new Map<String,AGN_ICL_Mailing_List__mdt>();
        Map<String,List<String>> countryEmailListMap = new Map<String,List<String>>();
        Map<String,String> countryEmailTemplateMap = new Map<String,String>();
        
        Map<String,List<AGN_ICL_Mailing_List__mdt>> countryMetadataListMap = new Map<String,List<AGN_ICL_Mailing_List__mdt>>();
        
        Integer  counter =0;        
        try{
           
            
            Map <String,String> countryMap = new Map <String,String>();  
            Integer lmtr = Limits.getLimitQueryRows() - Limits.getQueryRows();  
            for(AGN_ICL_Country_Settings__c countryObj : [SELECT Country_AGN__c,Name 
                                                          FROM AGN_ICL_Country_Settings__c
                                                          LIMIT :lmtr])
            {
                if(!countryMap.containsKey(countryObj.Name)){
                    countryMap.put(countryObj.Name,countryObj.Country_AGN__c);
                }
            }
            
            for(Locator_Listing_AGN__c locObj:locList){
                if(countryLocMap.containsKey(countryMap.get(locObj.Country_AGN__c))){
                    countryLocMap.get(countryMap.get(locObj.Country_AGN__c)).add(locObj);
                }
                else{
                    countryLocMap.put(countryMap.get(locObj.Country_AGN__c),new List<Locator_Listing_AGN__c>());
                    countryLocMap.get(countryMap.get(locObj.Country_AGN__c)).add(locObj);
                }
            }
                    
            for(AGN_ICL_Mailing_List__mdt tempObj:[SELECT id,Country_AGN__c,EmailList_AGN__c,
                                                   EmailTemplateName_AGN__c
                                                   FROM AGN_ICL_Mailing_List__mdt 
                                                   WHERE Country_AGN__c IN:countryLocMap.keySet()])
            {
                //single entry for each country
                if(!countryMetadataMap.containskey(tempObj.Country_AGN__c)){                
                    countryMetadataMap.put(tempObj.Country_AGN__c,tempObj);
                    List<String> EmailLists = tempObj.EmailList_AGN__c.split(',');
                    countryEmailListMap.put(tempObj.Country_AGN__c,EmailLists);                
                    countryEmailTemplateMap.put(tempObj.Country_AGN__c,tempObj.EmailTemplateName_AGN__c); 
                    hasRecord = true;                    
                }
                               
            }
            
            
            if(hasRecord){
                OrgWideEmailAddress owea = [SELECT Id,Address 
                                            FROM OrgWideEmailAddress 
                                            WHERE Address =: fromEmailAddress LIMIT 1];
                for(EmailTemplate objCS : [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                                           FROM EmailTemplate 
                                           WHERE DeveloperName IN:countryEmailTemplateMap.values()])
                {
                    eTMap.put(objCS.DeveloperName, objCS);
                }
               
                for(Locator_Listing_AGN__c LocObj:locList){
                    if(countryMetadataMap.keySet().contains(countryMap.get(LocObj.Country_AGN__c))){
                      
                        counter++;
                        Messaging.SingleEmailMessage mailToBex = new Messaging.SingleEmailMessage();
                        mailToBex.setOrgWideEmailAddressId(owea.Id);
                        mailToBex.setToAddresses(countryEmailListMap.get(countryMap.get(LocObj.Country_AGN__c)));
                        mailToBex.setTargetObjectId(UserInfo.getUserId());
                        mailToBex.setWhatId(LocObj.Id);        
                        mailToBex.setTreatTargetObjectAsRecipient(false);        
                        mailToBex.setSaveAsActivity(false);  
                        mailToBex.setCharset('UTF-8');
                        mailToBex.setTemplateId(eTMap.get(countryEmailTemplateMap.get(countryMap.get(LocObj.Country_AGN__c))).id);          
                        mails.add(mailToBex);
                        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(countryEmailTemplateMap.get(countryMap.get(LocObj.Country_AGN__c))).id, null, LocObj.id);
                        emailLog.Subject_AGN__c =email.Subject;
                        emailLog.From_AGN__c = fromEmailAddress;          
                        emailLog.Body_AGN__c = email.getHtmlBody();
                        emailLog.Sent_On_AGN__c = datetime.now();
                        emailLog.To_AGN__c = getStringValue(countryEmailListMap.get(countryMap.get(LocObj.Country_AGN__c)));
                        logList.add(emailLog);
                    }
                    
                }
                               
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if(results.size() > 0){   
                    integer i=0;
                    for(Messaging.SendEmailResult result : results){  
                        logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                        i++;
                    }   
                    if(logList.size()>0){ 
                        //------CheckMarx Phase2--Added on 18/11/2020----------                        
                        String objlog = 'ICL_Email_Status_Log_AGN__c';
                        SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                        AGN_FLSCheck.check(logList,objlogType,'INSERT');
                        //------CheckMarx Phase2--Ends here----------
                        insert logList;  
                    }                    
                }
                
            }            
        }
        catch(exception ex){
            
        }
        
    }
    
    public static void sendMailLocatorListing(List<Locator_Listing_AGN__c> locList,String templateFieldName){
        
             
        String LocCountryCode = ''; 
        String LocLangCode = '';
        Boolean hasRecord = false;
        Map<String,List<Locator_Listing_AGN__c> > countryLocMap = new  Map<String,List<Locator_Listing_AGN__c> >();
        List<EmailTemplate> eTList = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        
        Map<String, EmailTemplate> eTMap = new Map<String, EmailTemplate>(); 
        Map<String,AGN_ICL_Email_Settings__c> countryMetadataMap = new Map<String,AGN_ICL_Email_Settings__c>();
        Map<String,String> countryEmailTemplateMap = new Map<String,String>();
        //Map<String,List<String>> countryEmailListMap = new Map<String,List<String>>();
        
        
        Map<String,List<AGN_ICL_Email_Settings__c>> countryMetadataListMap = new Map<String,List<AGN_ICL_Email_Settings__c>>();
        
        Integer  counter =0;        
        try{
            OrgWideEmailAddress owea = [SELECT Id,Address
                                        FROM OrgWideEmailAddress 
                                        WHERE Address =: fromEmailAddress LIMIT 1];
            
            Map <String,String> countryMap = new Map <String,String>();
            Integer lmtr = Limits.getLimitQueryRows() - Limits.getQueryRows();            
            for(AGN_ICL_Country_Settings__c countryObj : [SELECT Country_AGN__c,Name 
                                                          FROM AGN_ICL_Country_Settings__c
                                                          LIMIT :lmtr])
            {
                if(!countryMap.containsKey(countryObj.Name))
                {
                    countryMap.put(countryObj.Name,countryObj.Country_AGN__c);
                }
            }
            
            for(Locator_Listing_AGN__c locObj:locList){
                if(countryLocMap.containsKey(countryMap.get(locObj.Country_AGN__c)))
                {
                    countryLocMap.get(countryMap.get(locObj.Country_AGN__c)).add(locObj);
                }
                else
                {
                    countryLocMap.put(countryMap.get(locObj.Country_AGN__c),new List<Locator_Listing_AGN__c>());
                    countryLocMap.get(countryMap.get(locObj.Country_AGN__c)).add(locObj);
                }
            }
            
            for(AGN_ICL_Email_Settings__c tempObj:[SELECT id,Country_Code_AGN__c,ICL_Admin_Welcome_Mail_Template__c 
                                                   FROM AGN_ICL_Email_Settings__c 
                                                   WHERE Country_Code_AGN__c IN:countryLocMap.keySet()])
            {
                //single entry for each country
                if(!countryMetadataMap.containskey(tempObj.Country_Code_AGN__c)){                
                    countryMetadataMap.put(tempObj.Country_Code_AGN__c,tempObj);                                 
                    countryEmailTemplateMap.put(tempObj.Country_Code_AGN__c,tempObj.ICL_Admin_Welcome_Mail_Template__c); 
                    hasRecord = true;                    
                }
                
            }
            
            if(hasRecord){
                for(EmailTemplate objCS : [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                                           FROM EmailTemplate 
                                           WHERE DeveloperName IN:countryEmailTemplateMap.values()])
                {
                    eTMap.put(objCS.DeveloperName, objCS);
                }
               
                for(Locator_Listing_AGN__c LocObj:locList){
                    if(countryMetadataMap.keySet().contains(countryMap.get(LocObj.Country_AGN__c))&& countryEmailTemplateMap.get(countryMap.get(LocObj.Country_AGN__c))!=null)
                    {
                        
                        counter++;
                        Messaging.SingleEmailMessage mailToBex = new Messaging.SingleEmailMessage();
                        mailToBex.setOrgWideEmailAddressId(owea.Id);
                        //mailToBex.setSenderDisplayName('Allergan Clinic Locator Portal'); 
                        List<String> sendTo = new List<String>();
                        sendTo.add(LocObj.Email_AGN__c);
                        sendTo.add(LocObj.Clinic_Admin_Email_AGN__c);
                        mailToBex.setToAddresses(sendTo);
                        //mailToBex.setToAddresses(countryEmailListMap.get(countryMap.get(LocObj.Country_AGN__c)));
                        mailToBex.setTargetObjectId(UserInfo.getUserId());
                        mailToBex.setWhatId(LocObj.Id);        
                        mailToBex.setTreatTargetObjectAsRecipient(false);        
                        mailToBex.setSaveAsActivity(false); 
                        mailToBex.setCharset('UTF-8');
                        mailToBex.setTemplateId(eTMap.get(countryEmailTemplateMap.get(countryMap.get(LocObj.Country_AGN__c))).id);          
                        mails.add(mailToBex);
                        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(countryEmailTemplateMap.get(countryMap.get(LocObj.Country_AGN__c))).id, null, LocObj.id);
                        emailLog.Subject_AGN__c =email.Subject;
                        emailLog.From_AGN__c = fromEmailAddress;          
                        emailLog.Body_AGN__c = email.getHtmlBody();
                        emailLog.Sent_On_AGN__c = datetime.now();
                        emailLog.To_AGN__c = getStringValue(sendTo);
                        logList.add(emailLog);                        
                    }
                    
                }
               
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if(results.size() > 0){            
                    
                    integer i=0;
                    for(Messaging.SendEmailResult result : results){     
                        logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                        i++;
                    }   
                    if(logList.size()>0) {
                        //------CheckMarx Phase2--Added on 18/11/2020----------                        
                        String objlog = 'ICL_Email_Status_Log_AGN__c';
                        SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                        AGN_FLSCheck.check(logList,objlogType,'INSERT');
                        //------CheckMarx Phase2--Ends here----------
                        insert logList;  
                    }                    
                }
                
            }            
        }
        catch(exception ex){
           
        }
        
        
    }
    
    public static void sendSingleMailLoc(Locator_Listing_AGN__c locObj,String emailTemplate){
        
        EmailTemplate objCS = [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                               FROM EmailTemplate 
                               WHERE DeveloperName =:emailTemplate LIMIT 1];
      
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        OrgWideEmailAddress owea = [SELECT Id,Address 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address =: fromEmailAddress 
                                    LIMIT 1];
        Messaging.SingleEmailMessage mailToClimicAdmin = new Messaging.SingleEmailMessage();
        mailToClimicAdmin.setOrgWideEmailAddressId(owea.Id);
        //mailToBex.setSenderDisplayName('Allergan Clinic Locator Portal'); 
        List<String> sendTo = new List<String>();       
        sendTo.add(locObj.Clinic_Admin_Email_AGN__c);
        //sendTo.add(locObj.Email_AGN__c);
        mailToClimicAdmin.setToAddresses(sendTo);
        // mailToBex.setToAddresses(countryEmailListMap.get(countryMap.get(LocObj.Country_AGN__c)));
        mailToClimicAdmin.setTargetObjectId(UserInfo.getUserId());
        mailToClimicAdmin.setWhatId(locObj.Id);        
        mailToClimicAdmin.setTreatTargetObjectAsRecipient(false);        
        mailToClimicAdmin.setSaveAsActivity(false);     
        mailToClimicAdmin.setTemplateId(objCS.id); 
        mailToClimicAdmin.setCharset('UTF-8');
        mails.add(mailToClimicAdmin);
        
        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(objCS.id, null, locObj.id);
        emailLog.Subject_AGN__c =email.Subject;
        emailLog.From_AGN__c = fromEmailAddress;          
        emailLog.Body_AGN__c = email.getHtmlBody();
        emailLog.Sent_On_AGN__c = datetime.now();
        emailLog.To_AGN__c = getStringValue(sendTo);        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);  
        if(results.size() > 0)
        { 
            emailLog.Success_Error_Message_AGN__c = results[0].isSuccess() ? 'success' : JSON.serialize(results[0].errors);
            //------CheckMarx Phase2--Added on 18/11/2020----------
            List<ICL_Email_Status_Log_AGN__c> emailLogList =  new  List<ICL_Email_Status_Log_AGN__c> ();
            emailLogList.add(emailLog);
            String objlog = 'ICL_Email_Status_Log_AGN__c';
            SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
            AGN_FLSCheck.check(emailLogList,objlogType,'INSERT');
            //------CheckMarx Phase2--Ends here----------
            insert emailLog;
        }        
    }  
    
    public static string getStringValue(List<String> strList){
        String str;
        for(String st:strList){
            if(String.isEmpty(str)){
                str = st;
            }else{
                str =str+';'+st;
            }
        }
        return str;
    } 
    
}