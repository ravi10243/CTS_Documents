/**
* @File Name          : AGN_GCSP_Utilities.cls
* @Description        : Utility class
* @Author             : Dev Team
* @Group              :
* @Last Modified By   : Dev Team
* @Last Modified On   : 13/01/2021
* @Modification Log   :
* Ver       Date            Author                  Modification
* 1.0    13/01/2021  Dev Team    Initial Version
**/
public without sharing class AGN_GCSP_Utilities { 
    
    
    /**
* @description : To get common settings
* @author Dev Team
* @return custom metadata type AGN_GCSP_Common_Setting_AGN__mdt
**/
    @AuraEnabled(cacheable=true)
    public static AGN_GCSP_Common_Setting_AGN__mdt getGCSPCommonSetting(){
        return [Select Account_Activation_Page_Name_AGN__c,
                Community_Base_URL_AGN__c,
                Community_Suffix_AGN__c,
                Encrypt_Decrypt_Private_Key_AGN__c,
                Manage_Password_Page_Name_AGN__c,
                OAM_Step1_Registration_Page_AGN__c,
                OAM_Step2_Registration_Page_AGN__c,
                OAM_Step3_Registration_Page_AGN__c,
                OAM_Step4_Registration_Page_AGN__c,
                OAM_Step5_Registration_Page_AGN__c,
                OAM_User_Profile_AGN__c,
                Okta_API_Key_AGN__c,
                Okta_Base_URL_AGN__c,
                Okta_Redirect_URL_AGN__c,
                UsernameSuffix_AGN__c,
                GoogleCapcha_AGN__c,
                Redirection_Page__c,
                Site_Landing_URL_AGN__c
                from AGN_GCSP_Common_Setting_AGN__mdt
                where DeveloperName = 'COMMON'];
    }
    
    
    /**
* @description : To get common settings
* @author Dev Team
* @return custom metadata type AGN_GCSP_Common_Setting_AGN__mdt
**/
    @AuraEnabled
    public static List<User> geUserDetails(String oktaUserName){
        
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = getGCSPCommonSetting();
        String suffix = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
        String sfdcUserName = oktaUserName + suffix;
        
        return [Select Username, User.ContactID, FirstName, LastName, Country_Code__c, MA_User_Country_Code_AGN__c, Email, LocaleSidKey, LanguageLocaleKey
                from User where username =: sfdcUserName and isactive = true limit 1];
    }
    
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
    @TestVisible
    private static User uInfo {
        get {
            return [SELECT Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        }
    }
    
    public static string getUserCountryCode {
        get {
            return uInfo.Country_Code__c;
        }
    }
    
    public static string getUserLanguage {
        get {
            return UserInfo.getLanguage();
        }
    }
    
    public static string getUserLocale {
        get {
            return UserInfo.getLocale();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getLabelString(String lang){
        
        system.debug('lang ->'+ lang);
        String custLabelVal;
        
        switch on lang {
            when 'DE' {
                return System.Label.AGN_OAM_Okta_Security_Question_de;
            }
            when 'ES' {
                return System.Label.AGN_OAM_Okta_Security_Question_es;
            }
            when 'FR' {
                return System.Label.AGN_OAM_Okta_Security_Question_fr;
            }
            when 'IT' {
                return System.Label.AGN_OAM_Okta_Security_Question_it;
            }
            when 'EN_AU' {
                return System.Label.AGN_OAM_Okta_Security_Question_en_AU;
            }
            when 'EN_GB' {
                return System.Label.AGN_OAM_Okta_Security_Question_en_gb;
            }
            when 'EN_NZ' {
                return System.Label.AGN_OAM_Okta_Security_Question_en_nz;
            }
            when 'EN_US' {
                return System.Label.AGN_OAM_Okta_Security_Question_en_US;
            }
            when 'EN_CA' {
                return System.Label.AGN_OAM_Okta_Security_Question_en_CA;
            }
            when 'FR_CA' {
                return System.Label.AGN_OAM_Okta_Security_Question_fr_CA;
            }
            when 'PT_BR' {
                return System.Label.AGN_OAM_Okta_Security_Question_pt_BR;
            }
        }
        return custLabelVal;
    }
    
    public static void sendEmail(List<AGN_EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName, String fromEmailAddress) {
        Messaging.reserveSingleEmailCapacity(2);
        List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];  
        
        //getting attachment lists
        List<Attachment> attachmentLst = [select Name, Body, BodyLength from Attachment where ParentId = :emailTemplate.Id];
        
        for (AGN_EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            else{
                mail.setSenderDisplayName('Allergan Customer Portal'); 
            } 
            //if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)
            //    mail.setReplyTo(emailMessageWrapper.FromAddress);
            if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
                mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
            else
                mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
                mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            String subject = null;
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            else{
                subject = emailTemplate.Subject;
            }
            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet()){
                subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
            }
            
            mail.setSubject(subject);
            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }
            
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            
            
            //Set email file attachments
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (Attachment a : attachmentLst)
            {
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                fileAttachments.add(efa);
            }
            mail.setFileAttachments(fileAttachments);
            
            listSingleEmailMessages.add(mail);
        }
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        } 
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    /**
* @description : Find the User in based on Contact.
* @author Dev Team
* @param contactId
* @param userName
* @return Boolean
**/
    public static Boolean findUserBy(Id contactId, String userName){
        
        for(User u : [SELECT Id, ContactId, UserName FROM User WHERE (ContactId = : contactId OR UserName =: userName)]) {
            if(contactId != null && (u.ContactId == contactId)) {
                return true;
            }
            
            if(userName != null && (u.UserName.equalsIgnoreCase(userName))) {
                return true;
            }
        }
        return false;
    }
    
    /**
* @description : Get The Records based on Object Name.
* @author deploymentadmin.cpteam@allergan.eu.eucpdev | 1/6/2020 
* @param objName 
* @param columnName 
* @param columnId 
* @param wherecondion 
* @param limitVal 
* @param orderby 
* @return List<sobject> 
**/
    @AuraEnabled
    public static List<sobject> getsObjectDetails(String objName, String columnName, String columnId, String wherecondion, String limitVal, String orderby) {
        
        String wherecond = String.isNotEmpty(wherecondion) ? String.valueOf(wherecondion) : '';
        
        String RecordSize = String.isNotEmpty(limitVal) ? ' LIMIT ' + limitVal : '';
        
        String OrderedBy = String.isNotEmpty(orderby) ? ' ORDER BY ' + orderby : '';
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below lines to avoid SOQL/SOSL Injection - start
        // String query = 'SELECT '+String.valueOf(columnName)+','+String.valueOf(columnId)+' FROM ' + objName + ' ' + wherecond + OrderedBy + RecordSize;
        String query = 'SELECT '+String.escapeSingleQuotes(String.valueOf(columnName))+','+String.escapeSingleQuotes(String.valueOf(columnId))+' FROM ' + String.escapeSingleQuotes(objName) + ' ' + wherecond + OrderedBy + RecordSize;
        system.debug('@@@@query@@@'+ query);
        
        return Database.query(query);
    }
    
    @AuraEnabled
    public static String getADRegStepInfos(){
        List<User> uslist = [SELECT ContactId, contact.Customer_Registration_AGN__c FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
        Boolean isInprogressOam = (!uslist[0].contact.Customer_Registration_AGN__c.equalsIgnoreCase('Complete')) ? true : false;
        Boolean isCompletedOam = (uslist[0].contact.Customer_Registration_AGN__c.equalsIgnoreCase('Complete')) ? true : false;
        // Boolean isInprogressAMIToAD = (uslist[0].contact.Portal_Access_AGN__c.equalsIgnoreCase('AMI') && !uslist[0].contact.Portal_Access_AGN__c.equalsIgnoreCase('OAM') && uslist[0].contact.Customer_Registration_AGN__c.equalsIgnoreCase('Complete')) ? true : false;
        if(isInprogressOam)
        { 
            List<Allergan_Customer_Contact_AGN__c> customerContact = [SELECT Parent_AGN__r.Online_Registration_Step_AGN__c FROM Allergan_Customer_Contact_AGN__c 
                                                                      WHERE Contact_AGN__c =: uslist[0].ContactId 
                                                                      AND Parent_AGN__r.Case_AGN__r.recordType.DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                                                      AND Contact_AGN__r.Customer_Registration_AGN__c != 'Complete'];
            if(!customerContact.isEmpty() && customerContact.size() == 1)
            {
                return customerContact[0].Parent_AGN__r.Online_Registration_Step_AGN__c;
            }
        }
        else{
            return 'Complete';
        }
        
        return null;
    }
    
    @AuraEnabled
    Public static String getADRegCurrentStepUrl(String RegStepNo){
        
        String urlToRedirect;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        final String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        final String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
        
        String urlRedirectPage = '';
        
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/') ) {
            urlToRedirect = COMMUNITY_BASE_URL;
        }
        else{
            urlToRedirect = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        if(String.isNotEmpty(RegStepNo) && RegStepNo != '5')
        {
            Switch on RegStepNo {
                When '1' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step1_Registration_Page_AGN__c; 
                }
                
                When '2' {
                    urlRedirectPage = commonOktaConfig.OAM_Step2_Registration_Page_AGN__c;
                }
                
                When '3' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step3_Registration_Page_AGN__c;
                }
                
                When '4' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }                
                
            }
            
            urlToRedirect += urlRedirectPage +'?language=' + AGN_GCSP_Utilities.getUserLocale;
            
        }else{
            urlToRedirect += '/s/' + '?language=' + AGN_GCSP_Utilities.getUserLocale;
        }
        
        return urlToRedirect;            
    }
    
    @AuraEnabled
    public static Case saveCaseRequest(Case caseData, String strFileName, String base64Data, String contentType) { //Id idParent, 
        
        /*  // Create a savepoint while AccountNumber is null
Savepoint sp = Database.setSavepoint();
// Decoding base64Data
base64Data = String.isNotEmpty(base64Data) ? EncodingUtil.urlDecode(base64Data, 'UTF-8') : '';        
// inserting Attachment
Attachment att = new Attachment();  
att.Body = EncodingUtil.base64Decode(base64Data);
att.Name = String.isNotEmpty(strFileName) ? strFileName : '';
att.contentType = String.isNotEmpty(contentType) ? contentType : '';
try
{

insert caseData;

if(String.isNotEmpty(strFileName) && String.isNotEmpty(base64Data) && String.isNotEmpty(contentType)){
att.parentId = caseData.Id;
insert att;  
}
return [SELECT Id, Status, Origin, Owner.Name, Reason, Subject, Type, CaseNumber, LastModifiedDate FROM Case WHERE Id =: caseData.Id];
}
catch (Exception e) 
{
Database.rollback(sp);
throw new AuraHandledException(e.getMessage());            
}    */    
        return new Case();
    }
    
    
    
    @auraenabled
    public static Boolean CheckRegistrationStatus(){
        
        /*  list<User> uslist = [SELECT Id, ContactId, AccountId, contact.Portal_Access_AGN__c, contact.Customer_Registration_AGN__c FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];

//User u = uslist.isEmpty() ? new User() : uslist[0];
Boolean isInprogress;
if(!uslist.isEmpty())
{
isInprogress = (uslist[0].contact.Portal_Access_AGN__c.containsIgnoreCase('OAM') && !uslist[0].contact.Customer_Registration_AGN__c.equalsIgnoreCase('Complete')) ? true : false;
}       

if(!isInprogress)
{
list<Allergan_Customer_Contact_AGN__c> acConList = [SELECT Id, Parent_AGN__c,Parent_AGN__r.Portal_Access_AGN__c FROM Allergan_Customer_Contact_AGN__c 
WHERE Parent_AGN__r.Case_AGN__r.Full_Registation_AGN__c = true 
AND Contact_AGN__c =:uslist[0].contactId LIMIT 1];
if(!acConList.isEmpty() && !acConList[0].Parent_AGN__r.Portal_Access_AGN__c.containsIgnoreCase('AMI') && acConList[0].Parent_AGN__r.Portal_Access_AGN__c.containsIgnoreCase('OAM'))
{

return true;
}
else{

return isInprogress; 
}
}

return isInprogress;  */
        
        return null;
    }
    
}