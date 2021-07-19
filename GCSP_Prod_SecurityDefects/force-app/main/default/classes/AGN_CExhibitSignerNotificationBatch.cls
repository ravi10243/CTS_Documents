public class AGN_CExhibitSignerNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Set<String> ENABLED_COUNTRIES_CODES = new Set<String>();
    private static final String TURKEY_COUNTRY_CODE = 'TR';

    // used in other classes (e.g. AGN_ContractExhibitTriggerHandler)
    public final static Set<String> ENABLED_STATUS_CONTRACT = new Set<String>{System.Label.Contract_Exhibit_live};
    // use it for testing
    //public final static Set<String> ENABLED_STATUS_CONTRACT = new Set<String>{System.Label.Contract_Exhibit_pending};

    private Datetime syncStartDatetime;
    private Map<Id,Set<String>> templateIdToEmailMap; //Map template id to set of email addresses.
    private Map<Id,List<attachment>> templateIdToAttachmentMap; //Map template id to attachments(helps when more than one attachment)
    private Map<String, String> emailToNameMap; //Map email address to BC name Required for email salutation)

    private String defaultEmailTemplate, defaultLanguage; //default email template - custom label
    private Id fromOrgWideAddress; //org wide email address
    //Added by BRAZIL LGPD team
    private Id fromOrgWideAddress_BR; //org wide email address for BR
    
    //Added by BRAZIL LGPD team
    private Map<String,Id> templateLanguageToIdMap= new Map<String,Id>(); //Map langauge to template id( for templates present in custom settings)
    private Map<Id,EmailTemplate> templateIdToHTMLMap= new Map<Id,EmailTemplate>(); //Map template id to template details
    private Map<Id, String> templateIdToLanguageMap= new Map<Id, String>(); //Map template id to Language

    private List<AGN_customException> custExceptionList = new List<AGN_customException>();

    private static AGN_Contract_Exhibit_Notification__c notificationCustomSetting = AGN_Contract_Exhibit_Notification__c.getInstance('Contract_Exhibit_Notification_Info');

    private List<AGN_GDPR_Notify_Contract_Exhibit__c> contractExhibitsToProcess = new List<AGN_GDPR_Notify_Contract_Exhibit__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.syncStartDatetime = System.now();
        Map<String,Id> templateNameToIdMap = new Map<String,Id>(); //Map template name to template id
        Set<id> templateIdSet = new Set<Id>(); //Prepare template id set to extract attachment details

        // setting default variables
        ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getCountryCodes();
        if (ENABLED_COUNTRIES_CODES.size() == 0) {
            throw new AGN_customException(0, 'ENABLED_COUNTRIES_CODES is empty!');
        }
        //adding turkey code, in the execute method only Cyprus
        ENABLED_COUNTRIES_CODES.add(TURKEY_COUNTRY_CODE);

        try {
            fromOrgWideAddress = [
            SELECT Id
            FROM OrgWideEmailAddress
            where DisplayName =:System.Label.AGN_ORG_Wide_Email Limit 1].Id;
            //Added by BRAZIL LGPD Team
            fromOrgWideAddress_BR=[
            SELECT Id
            FROM OrgWideEmailAddress
            where DisplayName =:System.Label.AGN_ORG_Wide_Email_BR Limit 1].Id;
            //Added by BRAZIL LGPD Team
            defaultLanguage = [
            SELECT AGN_Email_Language__c, Template_Name__c
            FROM AGN_EmailTemplate_Setting__c
            where Set_as_Default__c=True].AGN_Email_Language__c;
            defaultEmailTemplate = [
            SELECT AGN_Email_Language__c, Template_Name__c
            FROM AGN_EmailTemplate_Setting__c
            where Set_as_Default__c=True].Template_Name__c;
            System.debug('fromOrgWideAddress|'+fromOrgWideAddress);
            System.debug('fromOrgWideAddress|'+defaultLanguage);
            System.debug('defaultEmailTemplate|'+defaultEmailTemplate);
            System.debug('fromOrgWideAddress_BR|'+fromOrgWideAddress_BR);
        } catch(Exception ex){
            System.debug('Exception caught'+ex.getMessage());
        }

        //set template maps
        for(EmailTemplate emailTemplate : [SELECT Id,DeveloperName, Body, HTMLValue, Subject FROM EmailTemplate where Folder.Name=:System.Label.AGN_Template_Folder order by createdDate desc ]){
            templateNameToIdMap.put(emailTemplate.DeveloperName, emailTemplate.Id);
            templateIdToHTMLMap.put(emailTemplate.Id, emailTemplate);
        }
        System.debug('templateNameToIdMap.size'+templateNameToIdMap.size());

        templateIdToEmailMap = new Map<Id,Set<String>>();
        emailToNameMap=new Map<String, String>();

        for(AGN_EmailTemplate_Setting__c custSet : [SELECT AGN_Email_Language__c, Template_Name__c from AGN_EmailTemplate_Setting__c]){
            if(templateNameToIdMap.containsKey(custSet.Template_Name__c)){
                system.debug('in this if:'+custSet.Template_Name__c);
                templateLanguageToIdMap.put(custSet.AGN_Email_Language__c, templateNameToIdMap.get(custSet.Template_Name__c));
                templateIdToLanguageMap.put(templateNameToIdMap.get(custSet.Template_Name__c),custSet.AGN_Email_Language__c);
                templateIdSet.add(templateNameToIdMap.get(custSet.Template_Name__c));
            } else if(templateNameToIdMap.containsKey(defaultEmailTemplate)) {
                system.debug('in else if:'+custSet.Template_Name__c);
                templateLanguageToIdMap.put(defaultLanguage,templateNameToIdMap.get(defaultEmailTemplate));
                templateIdToLanguageMap.put(templateNameToIdMap.get(defaultEmailTemplate),defaultLanguage);
                templateIdSet.add(templateNameToIdMap.get(custSet.Template_Name__c));
            }
        }

        templateIdToAttachmentMap = new Map<Id, List<attachment>>();
        for(Attachment attch:[Select Id,Name, Body, ContentType,parentId from Attachment where parentId in :templateIdSet]){
            if(templateIdToAttachmentMap.containsKey(attch.parentId)){
                List<attachment> attachmentList=new List<attachment>();
                attachmentList=templateIdToAttachmentMap.get(attch.parentId);
                attachmentList.add(attch);
                templateIdToAttachmentMap.put(attch.parentId,attachmentList);
            } else{
                List<attachment> attachmentlist= new List<attachment>();
                attachmentlist.add(attch);
                templateIdToAttachmentMap.put(attch.parentId,attachmentList);
            }
        }

        // prepare data
        Datetime lastSyncDate = notificationCustomSetting.AGN_Last_Notification_Sync_DateTime__c;
        String query = 'SELECT Customer_Signer_Email__c, Contract_Language__c, Customer_Signer_Fullname__c, ' +
        'Customer_Signer_LastName__c, Customer_Signer_FirstName__c, Customer_Signer_Title__c, ' +
        'Primary_Institution__r.Id, Primary_Institution__r.Country_code__c,Primary_Institution__r.Country_vod__r.Name ' +
        'FROM Contract_Exhibit__c ' +
        'WHERE Customer_Signer_Email__c != null ' +
        'AND Primary_Institution__r.Country_code__c in :ENABLED_COUNTRIES_CODES ' +
        'AND Contract__r.Contract_Status__c IN :ENABLED_STATUS_CONTRACT ';
        if(lastSyncDate != null) {
            query += 'AND LastModifiedDate >= :lastSyncDate ';
        }

        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext bc, List<Contract_Exhibit__c> ceListScope) {
        // prepare data for exclusion
        // * Turkey not Cyprus
        // * email already present in Account record
        // * email already processed in another contract exhibit
        Set<Id> primaryInstitutionTRIds = new Set<Id>();
        Set<String> emailLangToCheck = new Set<String>();
        Set<String> emailToCheck = new Set<String>();
        for(Contract_Exhibit__c ce : ceListScope) {
            if (ce.Primary_Institution__r.Country_code__c == TURKEY_COUNTRY_CODE) {
                primaryInstitutionTRIds.add(ce.Primary_Institution__r.Id);
            }
            emailToCheck.add(ce.Customer_Signer_Email__c);
            emailLangToCheck.add(getEmailLang(ce));
        }
        Set<Id> accountIdsInCyprus = AGN_GDPRCountriesUtil.getAccountIdsInCyprus(primaryInstitutionTRIds);
        Set<String> personEmailsInAccount = getPersonEmailsInAccount(emailToCheck);
        Set<String> internalEmailsInAccount = getInternalEmailsInAccount(emailToCheck);
        Set<String> emailLangsAlreadyProcessed = getEmailLangsAlreadyProcessed(emailLangToCheck);

        // exclude records
        List<Contract_Exhibit__c> ceList = new List<Contract_Exhibit__c>();
        for(Contract_Exhibit__c ce : ceListScope) {
            if (!internalEmailsInAccount.contains(ce.Customer_Signer_Email__c)
            && !personEmailsInAccount.contains(ce.Customer_Signer_Email__c)
            && !emailLangsAlreadyProcessed.contains(getEmailLang(ce))) {
                if (ce.Primary_Institution__r.Country_code__c != TURKEY_COUNTRY_CODE) {
                    // add not-Turkey Contract Exhibit
                    ceList.add(ce);
                } else if (accountIdsInCyprus.contains(ce.Primary_Institution__r.Id)) {
                    // add cyprus Contract Exhibit
                    ceList.add(ce);
                } else {
                    System.debug('excluding ' + ce.Customer_Signer_LastName__c + ' because is in Turkey-not-Cyprus');
                }
            }
        }

        System.debug('processing ' + ceList.size() + ' records');

        //Create set of new data, inserted after last sync. Insert this data into object 'AGN_GDPR_Notify_Contract_Exhibit__c'
        Set<String> ceEmailToLang = new Set<String>();
        Set<String> emailToSendSet=new Set<String>(); //An email addrs is not to notify more than once via same email template
        for(Contract_Exhibit__c ce : ceList){
            String neEmailTemp = null;
            String emailLangT1 = getEmailLang(ce);

            if(!ceEmailToLang.contains(emailLangT1)) {
                ceEmailToLang.add(emailLangT1);
                // set fields
                AGN_GDPR_Notify_Contract_Exhibit__c gdprContractExhibit = new AGN_GDPR_Notify_Contract_Exhibit__c();
                gdprContractExhibit.AGN_Customer_Signer_Email__c = ce.Customer_Signer_Email__c;
                gdprContractExhibit.AGN_Contract_Language__c = ce.Contract_Language__c;
                gdprContractExhibit.AGN_BC_Name__c = ce.Customer_Signer_Fullname__c;
                gdprContractExhibit.AGN_Customer_Signer_LastName__c = ce.Customer_Signer_LastName__c;
                gdprContractExhibit.AGN_Customer_Signer_FirstName__c = ce.Customer_Signer_FirstName__c;
                gdprContractExhibit.AGN_Customer_Signer_Title__c = ce.Customer_Signer_Title__c;
               //Added by BRAZIL LGPD Team
                if(ce.Primary_Institution__r.Country_vod__r.Name =='BR'){
                    gdprContractExhibit.AGN_Contract_Language_Code__c = ce.Contract_Language__c;
                }
                //Added by BRAZIL LGPD Team
                else{
                    gdprContractExhibit.AGN_Contract_Language_Code__c = ce.Contract_Language__c.split(' ')[0];
                }
                gdprContractExhibit.AGN_GDPR_Email_Notification_Status__c='Initiated';
                gdprContractExhibit.AGN_Email_Sent_Date__c=system.today();
                system.debug('status:'+gdprContractExhibit.AGN_GDPR_Email_Notification_Status__c);
                system.debug('templatelanguage----->:'+templateLanguageToIdMap.keySet());
                system.debug('templateId----->:'+templateLanguageToIdMap.values());
                system.debug('contract language code:'+gdprContractExhibit.AGN_Contract_Language_Code__c);
                system.debug('default email temp------>'+ defaultEmailTemplate);
                
                // set AGN_Email_Template_Name__c field
                if(templateLanguageToIdMap.containsKey(gdprContractExhibit.AGN_Contract_Language_Code__c)) {
                    system.debug('in correct if');
                    neEmailTemp=templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c)+'-'+gdprContractExhibit.AGN_Customer_Signer_Email__c;
                    String emailLang= gdprContractExhibit.AGN_Customer_Signer_Email__c+gdprContractExhibit.AGN_Contract_Language_Code__c;
                    emailToNameMap.put(emailLang,gdprContractExhibit.AGN_BC_Name__c);
                    gdprContractExhibit.AGN_Email_Template_Name__c=templateIdToHTMLMap.get(templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c)).DeveloperName;
                    system.debug('template name--------->'+gdprContractExhibit.AGN_Email_Template_Name__c);
                } else {
                    neEmailTemp=templateLanguageToIdMap.get(defaultLanguage)+'-'+gdprContractExhibit.AGN_Customer_Signer_Email__c;
                    String emailLang= gdprContractExhibit.AGN_Customer_Signer_Email__c+defaultLanguage;
                    emailToNameMap.put(emailLang,gdprContractExhibit.AGN_BC_Name__c);
                    gdprContractExhibit.AGN_Email_Template_Name__c=templateIdToHTMLMap.get(templateLanguageToIdMap.get(defaultLanguage)).DeveloperName;
                    system.debug('temp name========>'+ gdprContractExhibit.AGN_Email_Template_Name__c);
                }

                if(emailToSendSet.isEmpty() || !emailToSendSet.contains(neEmailTemp)){
                    // if templateIdToEmailMap already contains the current contract exhibit language,
                    // append the new email address
                    if(templateIdToEmailMap.containsKey(templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c))){
                        system.debug('in 1st if');
                        Set<String> newEmailSet= new Set<String>(templateIdToEmailMap.get(templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c)));
                        newEmailSet.add(gdprContractExhibit.AGN_Customer_Signer_Email__c);
                        templateIdToEmailMap.put(templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c), newEmailSet);
                        // else if the current contract exhibit language is mapped into a template,
                        // create a new entry into templateIdToEmailMap
                    } else if (templateLanguageToIdMap.containsKey(gdprContractExhibit.AGN_Contract_Language_Code__c)) {
                        system.debug('in 2nd if');
                        Set<String> emailSet = new Set<string>();
                        emailSet.add(gdprContractExhibit.AGN_Customer_Signer_Email__c);
                        templateIdToEmailMap.put(templateLanguageToIdMap.get(gdprContractExhibit.AGN_Contract_Language_Code__c),emailSet);
                        // else if the default email template is mapped into a template
                        // create a new entry into templateIdToEmailMap
                    } else if (templateLanguageToIdMap.containsKey(defaultEmailTemplate)){
                        system.debug('in 3rd if');
                        Set<String> emailSet = new Set<string>();
                        emailSet.add(gdprContractExhibit.AGN_Customer_Signer_Email__c);
                        templateIdToEmailMap.put(templateLanguageToIdMap.get(defaultEmailTemplate),emailSet);
                    } else{
                        // this case shouldn't ever happen: at least, the previous condition will be true!
                        system.debug('in final if');
                        gdprContractExhibit.AGN_GDPR_Email_Notification_Status__c = null;
                    }
                    emailToSendSet.add(neEmailTemp);
                }
                contractExhibitsToProcess.add(gdprContractExhibit);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        // sending email step
        try{
            // prepare data to send emails
            
            if(!templateIdToEmailMap.isEmpty()) {
                List<Messaging.SingleEmailMessage> messageList = prepareMessageList(templateIdToEmailMap, templateIdToHTMLMap, templateIdToAttachmentMap, fromOrgWideAddress, fromOrgWideAddress_BR, emailToNameMap, templateIdToLanguageMap);// Added the parameter fromOrgWideAddress_BR for Brazil LGPD
                // if message list is not empty, send emails
                if(!messageList.isEmpty()) {
                    List<Messaging.SendEmailResult> resultMail  = Messaging.sendEmail(messageList);
                    resultMail[0].getErrors();
                    String response;
                    if (resultMail[0].isSuccess()) {
                        response = 'ok sent!';
                        System.debug('Email response|'+response);
                    } else {
                        response = resultMail[0].getErrors().get(0).getMessage();
                        AGN_customException custException = new AGN_customException(resultMail[0].getErrors().size(),resultMail[0].getErrors().get(0).getMessage(),resultMail[0].getErrors().get(0).getTargetObjectId());
                        custExceptionList.add(custException);
                        System.debug('Email response|'+response);
                    }
                }
            }

            insert contractExhibitsToProcess;

            notificationCustomSetting.AGN_Last_Notification_Sync_DateTime__c = this.syncStartDatetime;
            update notificationCustomSetting;

        } catch (System.EmailException ex) {
            System.debug('============== email exception caught ==============');
            AGN_customException custException = new AGN_customException(ex.getNumDml(),ex.getMessage());
            custExceptionList.add(custException);
            System.debug(ex.getMessage());
        }

        if(!custExceptionList.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(bc, custExceptionList, contractExhibitsToProcess.size());
        } else{
            AGNInterfacePublishEvent.logBatchApex(bc, contractExhibitsToProcess.size());
        }
    }
    //
    // private Boolean notifiedToAccount(String email) {
    //  try {
    //      Id a = [SELECT Id
    //      FROM Account
    //      where RecordType.Name = 'Professional_vod'
    //      AND (Email_Internal_AGN__c = :email  OR PersonEmail = :email)
    //      AND Account.Country_Code__c in :ENABLED_COUNTRIES_CODES].Id;
    //      if (a != null) {
    //          System.debug(email + ' already processed in an account');
    //          return true;
    //      }
    //      return false;
    //  }catch (Exception e) {
    //      return false;
    //  }
    // }

    private Set<String> getPersonEmailsInAccount(Set<String> emails) {
        try {
            List<Account> l = [SELECT PersonEmail
            FROM Account
            where RecordType.Name = 'Professional_vod'
            AND PersonEmail IN :emails
            AND Account.Country_Code__c in :ENABLED_COUNTRIES_CODES];

            Set<String> result = new Set<String>();
            for (Account a : l) {
                result.add(a.PersonEmail);
            }
            System.debug('personEmailsInAccount|' + result);
            return result;
        }catch (Exception e) {
            return new Set<String>();
        }
    }

    private Set<String> getInternalEmailsInAccount(Set<String> emails) {
        try {
            List<Account> l = [SELECT Email_Internal_AGN__c
            FROM Account
            where RecordType.Name = 'Professional_vod'
            AND Email_Internal_AGN__c IN :emails
            AND Account.Country_Code__c in :ENABLED_COUNTRIES_CODES];

            Set<String> result = new Set<String>();
            for (Account a : l) {
                result.add(a.Email_Internal_AGN__c);
            }
            System.debug('internalEmailsInAccount|' + result);
            return result;
        }catch (Exception e) {
            return new Set<String>();
        }
    }
    //
    // private Boolean isAlreadyProcessed(String emailLang) {
    //  try {
    //      Id a = [SELECT Id
    //      FROM AGN_GDPR_Notify_Contract_Exhibit__c
    //      where AGNEmailLang__c = :emailLang].Id;
    //      if (a != null) {
    //          System.debug(emailLang + ' already processed in another contract exhibit');
    //          return true;
    //      }
    //      return false;
    //  }catch (Exception e) {
    //      return false;
    //  }
    // }

    private Set<String> getEmailLangsAlreadyProcessed(Set<String> emailLang) {
        try {
            List<AGN_GDPR_Notify_Contract_Exhibit__c> l = [SELECT AGNEmailLang__c
            FROM AGN_GDPR_Notify_Contract_Exhibit__c
            where AGNEmailLang__c IN :emailLang];
            Set<String> result = new Set<String>();
            for (AGN_GDPR_Notify_Contract_Exhibit__c a : l) {
                result.add(a.AGNEmailLang__c);
            }
            System.debug('emailLangsAlreadyProcessed|' + result);
            return result;
        } catch (Exception e) {
            return new Set<String>();
        }
    }
    //Added 'fromAdrs_BR' to maintain method signature by Brazil LGPD team//
    private static List<Messaging.SingleEmailMessage> prepareMessageList(Map<Id,Set<String>> templateIdToEmailMap,Map<Id,EmailTemplate> templateIdToHTMLMap, Map<Id,List<attachment>> tempIdToAttachMap, Id fromAdrs, Id fromAdrs_BR, Map<String, String> emailToNameMap ,Map<Id,String> tempIdToLangMap){
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<String> emailSuccessList;
        Id tempId=[select Id from EmailTemplate where DeveloperName =: System.Label.AGN_LGPDTemplate_Name Limit 1].Id;//Added by BRAZIL LGPD Team
        for(Id temp:templateIdToEmailMap.keySet() ){
            System.debug('preparing email');
            for(String email: templateIdToEmailMap.get(temp)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(temp);
                emailSuccessList= new List<String>(templateIdToEmailMap.get(temp));
                //Added by Brazil LGPD Team//
                if(temp==tempId){
                  mail.setOrgWideEmailAddressId(fromAdrs_BR);  
                }
                //Added by Brazil LGPD Team//
                else{
                mail.setOrgWideEmailAddressId(fromAdrs);
                }
                List<String> emailSet= new List<String>();
                emailSet.add(email);
                mail.setToAddresses(emailSet);
                mail.setSubject(templateIdToHTMLMap.get(temp).Subject);
                String body= templateIdToHTMLMap.get(temp).HTMLValue;
                String emailLang=email+tempIdToLangMap.get(temp);
                //Added by Brazil LGPD Team//
                if(temp==tempId){
                    body= body.replace('{!Account.FirstName}{!Account.LastName}', emailToNameMap.get(emailLang));
                }
                //Added by Brazil LGPD Team//
                else{
                  body= body.replace('{!Data_Change_Request_vod__c.Doctor_Name_AGN__c}', emailToNameMap.get(emailLang));  
                }
                
                mail.setHtmlBody(body);
                List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
                if(tempIdToAttachMap.containsKey(temp)) {
                    for(attachment att: tempIdToAttachMap.get(temp)){
                        Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
                        email_att.setBody(att.Body);
                        email_att.setContentType(att.ContentType);
                        email_att.setFileName(att.Name);
                        email_att.setinline(false);
                        email_attachments.add(email_att);
                    }
                }
                mail.setFileAttachments(email_attachments);
                messageList.add(mail);
            }
        }
        return messageList;
    }
    private String getEmailLang(Contract_Exhibit__c ce) {
        if(ce.Contract_Language__c != null){
            return ce.Customer_Signer_Email__c +ce.Contract_Language__c ;
        }
        return ce.Customer_Signer_Email__c +'English (UK & I)';
    }
}