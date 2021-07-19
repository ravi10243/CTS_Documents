/*****************************************************************************************************************************************************************
Apex  Class- AGN_ContractExhibitNotificationBatch
Description- Batch class to send email notifications to contract exhibits. Kindly uncomment line no 42 if data is to be extracted from contract exhibit object
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/


global class AGN_ContractExhibitNotificationBatch implements Database.Batchable<sObject>, Database.Stateful
{       
    private Map<String,Id> tempNameToTempIdMap = new Map<String,Id>(); //Map template name to template id
    private Map<String,Id> langTempCustSettingMap= new Map<String,Id>(); //Map langauge to template id( for templates present in custom settings)
    private Map<Id, String> tempIdToLangMap= new Map<Id, String>(); //Map template id to Language
    private Map<Id,EmailTemplate> tempToHTMLMap= new Map<Id,EmailTemplate>(); //Map template id to template details
    private Map<Id,Set<String>> tempIdToEmailMap; //Map template id to set of email addresses.
    private Map<Id,List<attachment>> tempIdToAttachMap; //Map template id to attachments(helps when more than one attachment)
    private Map<String, String> emailToNameMap ; //Map email address to BC name Required for email salutation)
    
    Private Set<id> templateIdSet=new Set<Id>(); //Prepare template id set to extract attachment details
    private Set<String> emailSentSet=new Set<String>(); //An email addrs is not to notify more than once via same email template
    
    private List<AGN_GDPR_Notify_Contract_Exhibit__c> emailCEList; //Required to update template name, email sent date etc
    private List<EmailTemplate> templateList= new List<EmailTemplate>();
    
    private Integer emailFailCount=0;Integer count=0;
    private String defEmailTemp,defLang; //default email template - custom label
    private Id fromAdrs; //org wide email address
    
    List<AGN_customException> custExceptionList= new List<AGN_customException>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        emailCEList=new List<AGN_GDPR_Notify_Contract_Exhibit__c>();
        
        try{ 
            fromAdrs = [select Id from OrgWideEmailAddress where DisplayName =:System.Label.AGN_ORG_Wide_Email Limit 1].Id;
            defLang=[Select AGN_Email_Language__c,Template_Name__c From AGN_EmailTemplate_Setting__c where Set_as_Default__c=True].AGN_Email_Language__c;
            defEmailTemp=[Select AGN_Email_Language__c,Template_Name__c From AGN_EmailTemplate_Setting__c where Set_as_Default__c=True].Template_Name__c;
            System.debug('fromAdrs'+fromAdrs);
            System.debug('fromAdrs'+defLang);
            System.debug('defEmailTemp'+defEmailTemp);
            
        }
        catch(Exception ex){
            System.debug('Exception caught'+ex.getMessage());
        }
        
        //AGN_ContractExhibitUniqueEmailFinder.findUniqueEmailLangRecords();
        
        for(EmailTemplate emailTemp: [SELECT Id,DeveloperName ,Body,HTMLValue,Subject FROM EmailTemplate where Folder.Name=:System.Label.AGN_Template_Folder order by createdDate desc ]){
            tempNameToTempIdMap.put(emailTemp.DeveloperName ,emailTemp.Id);
            tempToHTMLMap.put(emailTemp.Id,emailTemp);
            System.debug('tempToHTMLMap'+tempToHTMLMap);
            System.debug('tempNameToTempIdMap'+tempNameToTempIdMap);
        } 
        System.debug('tempNameToTempIdMap.size'+tempNameToTempIdMap.size());
        
        for(AGN_EmailTemplate_Setting__c custSet : [Select AGN_Email_Language__c,Template_Name__c from AGN_EmailTemplate_Setting__c ]){
            if(tempNameToTempIdMap.containsKey(custSet.Template_Name__c)){
                langTempCustSettingMap.put(custSet.AGN_Email_Language__c,tempNameToTempIdMap.get(custSet.Template_Name__c));
                tempIdToLangMap.put(tempNameToTempIdMap.get(custSet.Template_Name__c),custSet.AGN_Email_Language__c);
                templateIdSet.add(tempNameToTempIdMap.get(custSet.Template_Name__c));
            }
            
            else if(tempNameToTempIdMap.containsKey(defEmailTemp)){
                langTempCustSettingMap.put(defLang,tempNameToTempIdMap.get(defEmailTemp));
                tempIdToLangMap.put(tempNameToTempIdMap.get(defEmailTemp),defLang);
                templateIdSet.add(tempNameToTempIdMap.get(custSet.Template_Name__c));
            }
        }
        
        System.debug('langTempCustSettingMap'+langTempCustSettingMap);
        System.debug('tempIdToLangMap'+tempIdToLangMap);
        System.debug('templateIdSet'+templateIdSet);
        
        tempIdToAttachMap=new Map<Id, List<attachment>>();
        for(Attachment attch:[Select Id,Name, Body, ContentType,parentId from Attachment where parentId in : templateIdSet]){
            System.debug('attch'+attch);
            if(tempIdToAttachMap.containsKey(attch.parentId)){
                List<attachment> attachmentList=new List<attachment>();
                attachmentList=tempIdToAttachMap.get(attch.parentId);
                attachmentList.add(attch);
                tempIdToAttachMap.put(attch.parentId,attachmentList);
            } else{
                List<attachment> attachmentlist= new List<attachment>();
                attachmentlist.add(attch);
                tempIdToAttachMap.put(attch.parentId,attachmentList);
            }
        }
        
        System.debug('tempIdToAttachMap'+tempIdToAttachMap);
        String query;
        query='SELECT AGNEmailLang__c,AGN_Contract_Language_Code__c,AGN_Customer_Signer_Email__c,AGN_BC_Name__c,AGN_GDPR_Email_Notification_Status__c,AGN_Email_Sent_Date__c, AGN_Email_Template_Name__c  FROM AGN_GDPR_Notify_Contract_Exhibit__c where AGN_GDPR_Email_Notification_Status__c=null' ;
        system.debug('data*** : '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<AGN_GDPR_Notify_Contract_Exhibit__c> scope) 
    {
        System.debug('In the execute block');
        String neEmailTemp;
        tempIdToEmailMap=new Map<Id,Set<String>>();
        emailToNameMap=new Map<String, String>();
        
        for(AGN_GDPR_Notify_Contract_Exhibit__c sendEmailCE:scope){
            String templateName, defTemplate;
            
            if(langTempCustSettingMap.containsKey(sendEmailCE.AGN_Contract_Language_Code__c)){
                neEmailTemp=langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c)+'-'+sendEmailCE.AGN_Customer_Signer_Email__c;
                String emailLang= sendEmailCE.AGN_Customer_Signer_Email__c+sendEmailCE.AGN_Contract_Language_Code__c;
                emailToNameMap.put(emailLang,sendEmailCE.AGN_BC_Name__c);
                templateName=tempToHTMLMap.get(langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c)).DeveloperName;
                System.debug('langTempCustSettingMap'+langTempCustSettingMap.keySet());
            }
            else{
                neEmailTemp=langTempCustSettingMap.get(defLang)+'-'+sendEmailCE.AGN_Customer_Signer_Email__c;
                String emailLang= sendEmailCE.AGN_Customer_Signer_Email__c+defLang;
                emailToNameMap.put(emailLang,sendEmailCE.AGN_BC_Name__c);
                templateName=tempToHTMLMap.get(langTempCustSettingMap.get(defLang)).DeveloperName;
                System.debug('langTempCustSettingMap'+langTempCustSettingMap.keySet());
            }
            
            if(emailSentSet.isEmpty() || !emailSentSet.contains(neEmailTemp)){
                if(tempIdToEmailMap.containsKey(langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c))){
                    Set<String> newEmailSet= new Set<String>(tempIdToEmailMap.get(langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c)));
                    newEmailSet.add(sendEmailCE.AGN_Customer_Signer_Email__c);
                    tempIdToEmailMap.put(langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c),newEmailSet);
                }
                
                else if(langTempCustSettingMap.containsKey(sendEmailCE.AGN_Contract_Language_Code__c)){
                    Set<String> emailSet = new Set<string>();
                    emailSet.add(sendEmailCE.AGN_Customer_Signer_Email__c);
                    tempIdToEmailMap.put(langTempCustSettingMap.get(sendEmailCE.AGN_Contract_Language_Code__c),emailSet);
                }
                
                else if(langTempCustSettingMap.containsKey(defEmailTemp)){
                    Set<String> emailSet = new Set<string>();
                    emailSet.add(sendEmailCE.AGN_Customer_Signer_Email__c);
                    tempIdToEmailMap.put(langTempCustSettingMap.get(defEmailTemp),emailSet);
                }
                
                else{
                     if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_GDPR_Email_Notification_Status__c.isUpdateable())
                     {
                         sendEmailCE.AGN_GDPR_Email_Notification_Status__c=null;
                     }
                }
                emailSentSet.add(neEmailTemp);
            }
            //AS CC
            if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_GDPR_Email_Notification_Status__c.isUpdateable())
            {
                sendEmailCE.AGN_GDPR_Email_Notification_Status__c='Initiated';
            }
            if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_Email_Sent_Date__c.isUpdateable())
            {
                sendEmailCE.AGN_Email_Sent_Date__c=system.today();
            }
            if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_Email_Template_Name__c.isUpdateable())
            {
                sendEmailCE.AGN_Email_Template_Name__c=templateName;
            }
            //AS CC
            
            emailCEList.add(sendEmailCE);
        }
        String response;
        System.debug('tempIdToEmailMap'+tempIdToEmailMap.keySet());
        try{
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            if(!tempIdToEmailMap.isEmpty()){
                System.debug('tempIdToEmailMap is not null');
                messageList= AGN_prepareMessageListutility.prepareMessageList(tempIdToEmailMap,tempToHTMLMap, tempIdToAttachMap,fromAdrs,emailToNameMap,tempIdToLangMap);
            }
            else{
                //AS CC
                if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.isUpdateable() )
                {
                    Update emailCEList;   
                }
            }
            if(!messageList.isEmpty()){
                list<Messaging.SendEmailResult> resultMail  = Messaging.sendEmail(messageList);
                resultMail[0].getErrors(); 
                if (resultMail[0].isSuccess()) {
                    response = 'ok sent!';
                    count  = count+scope.size();
                    System.debug('Email response'+response);
                    //AS CC
                    if (Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.isUpdateable() )
                    {
                        Update emailCEList;
                    }
                } else {
                    response = resultMail[0].getErrors().get(0).getMessage();
                    AGN_customException custException=new AGN_customException(resultMail[0].getErrors().size(),resultMail[0].getErrors().get(0).getMessage(),resultMail[0].getErrors().get(0).getTargetObjectId());
                    emailFailCount+=resultMail[0].getErrors().size();
                    System.debug('Email response'+response);
                }
            }
        } 
        catch (System.EmailException ex) {
            system.debug('============== email exception caught!!!=============');
            AGN_customException custException=new AGN_customException(ex.getNumDml(),ex.getMessage(),neEmailTemp);
            custExceptionList.add(custException);
            emailFailCount+=scope.size();
            response = ex.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        system.debug('Reached Finish** ');
        system.debug('Reached Finish** ');
        if(!custExceptionList.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(bc,custExceptionList,count); 
            
        } else{
            AGNInterfacePublishEvent.logBatchApex(bc,count);
        }
        // AGNInterfacePublishEvent.logBatchApex(bc,count);
        
    }   
}