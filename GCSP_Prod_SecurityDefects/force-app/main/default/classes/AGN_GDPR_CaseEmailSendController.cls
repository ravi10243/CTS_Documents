/* @author       Cognizant
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version       1.0
* @created        
* @modified      Cognizant
* @testClass     
* @Class Name    AGN_GDPR_CaseEmailSendController
* ----------------------------------------------------------------------------------------------------------------------------------------
* @description -  Class to Send Email from Case Email Component, Controller to the AGN_GDPR_Case_Email_Component.
				Populates the pre populated text that appears on the Case Email Component based on Regulation,Request Type , Status.
*/
global without sharing class AGN_GDPR_CaseEmailSendController  
{
    public class wrapperClassReturnsEmailContent {
        @AuraEnabled
        public String Salutation {get; set;}
        @AuraEnabled
        public String dsEmailBody {get; set;}
        @AuraEnabled
        public String dsEmailSubject {get; set;}
    }
    
    @AuraEnabled 
    public static Case getValues(Id caseId)
    {
        Case caseObject = new Case();
        if(caseId != null)
        {
            caseObject = [SELECT Id,Subject,Data_Subject_Email_GDPR_AGN__c,CaseNumber,
                          Full_Name_GDPR_AGN__c,Request_Type_GDPR_AGN_new__c,
                          DS_Email_Body_AGN__c,DS_Email_Subject_GDPR_AGN__c,RecordType.DeveloperName,
                          Status,Titile_AGN_GDPR__c,Last_Name_GDPR_AGN__c,First_Name_GDPR_AGN__c,DS_Selected_Language_GDPR_AGN__c from Case where ID = :caseId];
            System.debug('Case Id '+caseObject.Id);            
        }  
        return caseObject;  
    }
    
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody,Id caseId ,Id atachID)
    {     
        
        Case caseObj = new Case();
        caseObj = [SELECT Id,Subject,Data_Subject_Email_GDPR_AGN__c,CaseNumber,
                   Full_Name_GDPR_AGN__c,Request_Type_GDPR_AGN__c,
                   RecordType.DeveloperName,Status,DPO_Verified_the_Mail_Content_AGN__c from Case where ID = :caseId];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        String replyTo = System.Label.AGN_GDPR_From_Email;
        sendTo.add(mMail);
        mail.setToAddresses(sendTo);
        mail.setReplyTo(replyTo);
        mail.setSubject(mSubject);
        
        String mbody_ccpa;
 
        if(caseObj.RecordType.DeveloperName == System.Label.AGN_CCPA_Case || caseObj.RecordType.DeveloperName == System.Label.AGN_Contact_Center)
        {
            OrgWideEmailAddress[] oweaccpa = [select Id from OrgWideEmailAddress where DisplayName = :System.Label.AGN_CCPA_Data_Subject_Access_Request];
            
            if ( oweaccpa.size() > 0 ) 
            {
                mail.setOrgWideEmailAddressId(oweaccpa.get(0).Id);
            }
            mbody_ccpa = mbody;
            mail.setHtmlBody(mbody_ccpa);
        }
        else
        {
            OrgWideEmailAddress[] oweaccpa = [select Id from OrgWideEmailAddress where DisplayName = :System.Label.AGN_Data_Subject_Access_Request];
            if ( oweaccpa.size() > 0 ) 
            {
                mail.setOrgWideEmailAddressId(oweaccpa.get(0).Id);
            }
            mail.setHtmlBody(mbody);
        }
        if(atachID != NULL)
        {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            ContentDocumentLink a = [SELECT id,ContentDocument.Title,ContentDocument.FileType,
                                     ContentDocument.FileExtension,
                                     ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.VersionData  
                                     FROM ContentDocumentLink WHERE ContentDocumentId = :atachID AND LinkedEntityID = :caseId];
            
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.ContentDocument.Title+'.'+a.ContentDocument.FileExtension);
            efa.setBody(a.ContentDocument.LatestPublishedVersion.VersionData);
            fileAttachments.add(efa);
            
            mail.setFileAttachments(fileAttachments);
        }
        
        EmailMessage newemailMessage = new EmailMessage();
        newemailMessage.fromAddress=replyTo;
        insert newemailMessage;
        
        mails.add(mail);
        
        Messaging.sendEmail(mails);
        
        External_Email_Communication_GDPR_AGN__c externalEmailComm = new External_Email_Communication_GDPR_AGN__c();
        externalEmailComm.Associated_Case_GDPR_AGN__c = caseId; 
        externalEmailComm.Email_Sent_To__c = mMail;
        externalEmailComm.Email_Subject_GDPR_AGN__c = mSubject;
        externalEmailComm.Email_From_GDPR_AGN__c= System.Label.AGN_System_Owner;
        
        if(caseObj.RecordType.DeveloperName == System.Label.AGN_CCPA_Case || caseObj.RecordType.DeveloperName == System.Label.AGN_Contact_Center)
        {
            externalEmailComm.Email_Body_GDPR_AGN__c=mbody;
        }
        else
        {
            externalEmailComm.Email_Body_GDPR_AGN__c=mbody;
        }
        if(caseObj.RecordType.DeveloperName == System.Label.AGN_GDPR_Case || caseObj.RecordType.DeveloperName == System.Label.AGN_GDPR_DPO)
        {
            caseObj.DPO_Verified_the_Mail_Content_AGN__c = true;
            caseObj.DS_Email_Body_AGN__c = mbody;
            caseObj.DS_Email_Subject_GDPR_AGN__c = mSubject;
        }
        try 
        {
            insert externalEmailComm;
            update caseObj;
            system.debug('==>1 ' + externalEmailComm.Id);    
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
    }
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) 
    { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment emailAttachment = new Attachment();
        emailAttachment.parentId = parentId;
        
        emailAttachment.Body = EncodingUtil.base64Decode(base64Data);
        emailAttachment.Name = fileName;
        emailAttachment.ContentType = contentType;
        
        if(emailAttachment != null)
        {
            try
            {
                insert emailAttachment;
            }
            catch(Exception e )
            {
                System.debug('Error Occurend inserting attachment '+e);
            }
        }
        return emailAttachment.Id;
    }
    
 /** New Class Added as a Part of Production Open Defect Fix for the Defect D 48, deployed on 9th May 2020
	Text auto population for the Email Component for the GDPR Cases of Request Type Erasure or Rectification **/
    @AuraEnabled
    public static wrapperClassReturnsEmailContent setGDPREmailContent(String requestType,String dsLanguage)
    { 
        wrapperClassReturnsEmailContent wrapperClassInstance = new wrapperClassReturnsEmailContent();
        if(String.isNotBlank(requestType) && String.isNotBlank(dsLanguage))
        {       
            System.debug('Inside setGDPREmailContent');
            Map<string,AGN_GDPR_Language_Settings__c> languageCustomSetting = AGN_GDPR_Language_Settings__c.getAll();
            String LangCode = languageCustomSetting.get(dsLanguage).Language_Code_AGN__c;
            
            if(requestType == 'Rectification')
            {
                Set<String> customLabelName = new Set<String>();
                customLabelName.add('Dear_AGN');
                customLabelName.add('AGN_GDPR_Rectification_Task_Complete_Email_Subject');
                customLabelName.add('AGN_GDPR_Rectification_Task_Complete_Email_Body');
                
                
                // Custom Label value Fetch for English language 
                List<ExternalString> externalStringObjListUpdate = new List<ExternalString>();
                externalStringObjListUpdate = [SELECT Id,Language,Name,Value FROM ExternalString where Name IN :customLabelName];
                
                //Map to store English Label with their Values
                Map<String,String> customLabelValueEnglishMap = new Map<String,String>();
                
                // Set of Id of External String to Query on External String Localisation
                Set<Id> externalStringObjId = new Set<Id>();
                for(ExternalString externalStringObj : externalStringObjListUpdate)
                {
                    customLabelValueEnglishMap.put(externalStringObj.Name,externalStringObj.Value);
                    externalStringObjId.add(externalStringObj.Id);  
                }
                
                
                // Custom Label Value Fetch for OtherLang 
                List<ExternalStringLocalization> externalStringLocalisationListUpdate = new List<ExternalStringLocalization>();
                externalStringLocalisationListUpdate = [SELECT ExternalString.Name,ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId IN :externalStringObjId  and Language = :LangCode];
                
                // Map to store Other Language Translation
                Map<String,String> customLabelValueOtherLangMap = new Map<String,String>();
                
                for(ExternalStringLocalization externalStringLocalObj : externalStringLocalisationListUpdate)
                {
                    customLabelValueOtherLangMap.put(externalStringLocalObj.ExternalString.Name,externalStringLocalObj.Value);
                }
                
                
                if(dsLanguage == 'English' && externalStringObjListUpdate.size() > 0)
                {   
                    if(customLabelValueEnglishMap.containsKey('Dear_AGN'))
                    {
                        wrapperClassInstance.Salutation =customLabelValueEnglishMap.get('Dear_AGN');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Rectification_Task_Complete_Email_Subject'))
                    {
                        wrapperClassInstance.dsEmailSubject =customLabelValueEnglishMap.get('AGN_GDPR_Rectification_Task_Complete_Email_Subject');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Rectification_Task_Complete_Email_Body'))
                    {
                        wrapperClassInstance.dsEmailBody =customLabelValueEnglishMap.get('AGN_GDPR_Rectification_Task_Complete_Email_Body');
                    }                  
                }
                else if(dsLanguage !='English' && externalStringLocalisationListUpdate.size() > 0 )
                {
                    if(customLabelValueEnglishMap.containsKey('Dear_AGN'))
                    {
                        wrapperClassInstance.Salutation =customLabelValueOtherLangMap.get('Dear_AGN');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Rectification_Task_Complete_Email_Subject'))
                    {
                        wrapperClassInstance.dsEmailSubject=customLabelValueOtherLangMap.get('AGN_GDPR_Rectification_Task_Complete_Email_Subject');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Rectification_Task_Complete_Email_Body'))
                    {
                        wrapperClassInstance.dsEmailBody=customLabelValueOtherLangMap.get('AGN_GDPR_Rectification_Task_Complete_Email_Body');
                    }                  
                }
                else
                {
                    wrapperClassInstance.Salutation ='';
                    wrapperClassInstance.dsEmailBody='';
                    wrapperClassInstance.dsEmailSubject='';
                }
            }
            else if(requestType == 'Erasure')
            { 
                Set<String> customLabelName = new Set<String>();
                customLabelName.add('Dear_AGN');
                customLabelName.add('AGN_GDPR_Erasure_Task_Complete_Email_Subject');
                customLabelName.add('AGN_GDPR_Erasure_TaskComplete_Email_Body');
                
                  
                // Custom Label value Fetch for English language 
                List<ExternalString> externalStringObjListErasure = new List<ExternalString>();
                externalStringObjListErasure = [SELECT Id,Language,Name,Value FROM ExternalString where Name IN :customLabelName];
                
                //Map to store Label and English Values
                Map<String,String> customLabelValueEnglishMap = new Map<String,String>();
                
                // Set of External String ID's to query on ExternalStringLocalisation
                Set<Id> externalStringObjId = new Set<Id>();
                for(ExternalString externalStringObj : externalStringObjListErasure)
                {
                    customLabelValueEnglishMap.put(externalStringObj.Name,externalStringObj.Value);
                    externalStringObjId.add(externalStringObj.Id);  
                }
 
                // Custom Label Value Fetch for OtherLang 
                List<ExternalStringLocalization> externalStringLocalisationListErasure = new List<ExternalStringLocalization>();
                externalStringLocalisationListErasure = [SELECT ExternalString.Name,ExternalStringId,Id,Language,Value FROM ExternalStringLocalization WHERE ExternalStringId IN :externalStringObjId  and Language = :LangCode];
                
                // Map to store Other Language translations
                Map<String,String> customLabelValueOtherLangMap = new Map<String,String>();
                
                for(ExternalStringLocalization externalStringLocalObj : externalStringLocalisationListErasure)
                {
                    customLabelValueOtherLangMap.put(externalStringLocalObj.ExternalString.Name,externalStringLocalObj.Value);
                }
                
                
                if(dsLanguage == 'English' && externalStringObjListErasure.size() > 0)
                {   
                    if(customLabelValueEnglishMap.containsKey('Dear_AGN'))
                    {
                        wrapperClassInstance.Salutation =customLabelValueEnglishMap.get('Dear_AGN');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Erasure_Task_Complete_Email_Subject'))
                    {
                        wrapperClassInstance.dsEmailSubject =customLabelValueEnglishMap.get('AGN_GDPR_Erasure_Task_Complete_Email_Subject');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Erasure_TaskComplete_Email_Body'))
                    {
                        wrapperClassInstance.dsEmailBody =customLabelValueEnglishMap.get('AGN_GDPR_Erasure_TaskComplete_Email_Body');
                    }                  
                }
                else if(dsLanguage !='English' && externalStringLocalisationListErasure.size() > 0 )
                {
                    if(customLabelValueEnglishMap.containsKey('Dear_AGN'))
                    {
                        wrapperClassInstance.Salutation =customLabelValueOtherLangMap.get('Dear_AGN');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Erasure_Task_Complete_Email_Subject'))
                    {
                        wrapperClassInstance.dsEmailSubject=customLabelValueOtherLangMap.get('AGN_GDPR_Erasure_Task_Complete_Email_Subject');
                    }
                    if(customLabelValueEnglishMap.containsKey('AGN_GDPR_Erasure_TaskComplete_Email_Body'))
                    {
                        wrapperClassInstance.dsEmailBody=customLabelValueOtherLangMap.get('AGN_GDPR_Erasure_TaskComplete_Email_Body');
                    }                  
                }
                
                else
                {
                    wrapperClassInstance.Salutation ='';
                    wrapperClassInstance.dsEmailBody='';
                    wrapperClassInstance.dsEmailSubject='';
                }
            }
        }
        else
        {
            wrapperClassInstance.Salutation ='';
            wrapperClassInstance.dsEmailBody='';
            wrapperClassInstance.dsEmailSubject='';
        }
        System.debug('Return Value before sending '+wrapperClassInstance);
        return wrapperClassInstance;
    }
    
}