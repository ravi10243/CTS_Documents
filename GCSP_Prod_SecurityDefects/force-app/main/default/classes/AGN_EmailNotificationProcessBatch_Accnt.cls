/*****************************************************************************************************************************************************************
Apex  Class- AGN_EmailNotificationProcessBatch_Accnt
Description- This batch class is used to send email notification to HCP based on account(to be run on ad-hoc basis)
LastModified Date- 26/Apr/2021
********************************************************************************************************************************************************************/
global class AGN_EmailNotificationProcessBatch_Accnt implements Database.Batchable<sObject>, Database.Stateful{
   
    public Map<String,EmailTemplate> templateMap;
    public Map<EmailTemplate,String> emailTemplateSubject;
    public String defaultETempName ='';
    public String accName;
    public String templateName;
    public String templateNameCountry;
    public Set<String> setOfAllTempNames;
    public Map<String, String> MapcCodeTempName;
    public Map<id,string> mapAccIdsTempName;
    public List<AGN_EmailTemplate_Setting__c> emailCustSettingList; 
    public Map<String, String> emailCustSettingMap; 
    public List<Account> accountList;
    public List<OrgWideEmailAddress> oweaList;
    global List<Success_Error_History_AGN__c> listSEHistory = new List<Success_Error_History_AGN__c>(); 
    global List<Error_Table_AGN__c> listErrorTable = new List<Error_Table_AGN__c>();
    public Integer successCount = 0; 
    public Integer ErrorCount = 0; 
    public Map<Id,String> mapAccIdToError; 
    Public Map<Id,List<attachment>> tempIdToAttachMap;
    public set<id> templateIds = new set<id>();
    public Datetime emailDate;    
    public AGN_EmailNotificationProcessBatch_Accnt(){
        mapAccIdToError = new Map<Id,String>();
        emailCustSettingMap = new map<String,String>();
        //accountList = new List<Account>();
        oweaList = new List<OrgWideEmailAddress>();
        MapcCodeTempName = new Map<String, String>();
        setOfAllTempNames = new Set<String>();
        templateMap = new Map<String,Emailtemplate>();
        
        emailTemplateSubject = new Map<EmailTemplate,String>();
        //Fetch template mapping from Custom Setting (create custom setting record having its name as template unique name with respective Language)
        emailCustSettingList = AGN_EmailTemplate_Setting__c.getall().values();
        System.debug('BeforeDataFetch**:  ' + Limits.getCpuTime());
        //loop on Custom setting to fetch stored template info.
        
        for(AGN_EmailTemplate_Setting__c emailCset: emailCustSettingList){
            if(emailCset.Language__c!=null){
                //Template_Name__c- should necessarily be the developer name of a tempalte( because it is unique to fetch).
                emailCustSettingMap.put(emailCset.Language__c,emailCset.Template_Name__c);
            }
            //Default marked template can be only one in the custom setting, but still handled here keeping null check. So it will pick the first default in the list.
            if(emailCset.Set_as_Default__c && String.isBlank(defaultETempName)){
                defaultETempName = emailCset.Template_Name__c; 
            }
        }//loop_Ends
        
        for(Country_vod__c cntry :[select id,Country_Name_vod__c,Template_Name__c from Country_vod__c where Template_Name__c!=null and Country_Name_vod__c IN('AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IS','IE','IT','LV','LI','LT','LU','MT','NL','NO','PL','PT','RO','SK','SI','ES','SE','CH','GB')]){   
            system.debug('Countryrec**'+cntry);
            MapcCodeTempName.put(cntry.Country_Name_vod__c,cntry.Template_Name__c);
            
            system.debug('MapcCodeTempName**'+MapcCodeTempName);
        }//loop_Ends
        
        if(!MapcCodeTempName.isEmpty()){
            setOfAllTempNames.addAll(MapcCodeTempName.values());
        }
        if(!emailCustSettingMap.isEmpty()){
            setOfAllTempNames.addAll(emailCustSettingMap.values());
        }
        //Fetch template Id and name from template object using custom setting stored template name with language.
        if(!setOfAllTempNames.isEmpty()){
            System.debug('StoredTemplateNames: '+emailCustSettingMap.keySet());
            for(EmailTemplate emailTemp : [SELECT Id,Name,Body,HTMLValue,developername,Subject FROM EmailTemplate WHERE developername in :setOfAllTempNames]){
                if(!templateMap.containskey(emailTemp.developername)){
                    templateMap.put(emailTemp.developername,emailTemp);
                }
                if(!emailTemplateSubject.containskey(emailTemp)){
                    emailTemplateSubject.put(emailTemp,emailTemp.subject);
                }
            }//loop_Ends.
        }
        system.debug('templateMap.values===='+templateMap.values());
        for(EmailTemplate tempId :templateMap.values()){
            system.debug('templateMap.values'+templateMap.values());
            templateIds.add(tempId.Id);
        }
        system.debug('');
        tempIdToAttachMap=new Map<Id, List<attachment>>();
        for(Attachment attch:[Select Id,Name, Body, ContentType,parentId from Attachment where parentId in : templateIds]){
            System.debug('attch'+attch);
            if(!tempIdToAttachMap.containsKey(attch.parentId)){
                system.debug('tempIdToAttachMap==='+tempIdToAttachMap);
                List<attachment> attachmentList=new List<attachment>();
                attachmentList.add(attch);
                tempIdToAttachMap.put(attch.parentId,attachmentList);
            } 
        }
        system.debug('tempIdToAttachMap===='+tempIdToAttachMap);
        System.debug('AfterDataFetch**: ' + Limits.getCpuTime()); 
    }
    //String [] toAddresses;
    global Database.queryLocator start(Database.BatchableContext bc){
        String query = '';
        dateTime iRunDateTime;
        dateTime iRunDateTime2;
        List<Interface_Run_Details_AGN__c> iRunDList;
        
        iRunDList = [SELECT Name,End_Date_AGN__c from Interface_Run_Details_AGN__c where Interface_Run_Details_AGN__c.Name='AGN_EmailNotificationProcessBatch_Accnt' and Error_Record_Count_AGN__c = 0 and Run_Status__c = 'Completed' and End_Date_AGN__c!=null order by CreatedDate desc LIMIT 1];
        
        if(!iRunDList.isEmpty()){
            System.debug('EndDate** '+ iRunDList.get(0).End_Date_AGN__c);
            iRunDateTime = iRunDList.get(0).End_Date_AGN__c;
            System.debug('IRunDateTime_bfore****'+iRunDateTime);
            String formatedIRunDate = (iRunDateTime).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'' , 'GMT');
            system.debug('datetime***' +formatedIRunDate);
            query = String.valueOf(Label.AGN_EMAIL_NOTIFICATION_QUERY_Accnt) +' AND LastmodifiedDate>= ' + formatedIRunDate ;
        }
        else{
            query = String.valueOf(Label.AGN_EMAIL_NOTIFICATION_QUERY_Accnt);
        }
        system.debug('**query**'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<Id,String> mapAccIdToLang = new Map<Id,String>();
        Map<Id,String> mapAccidToCode = new Map<Id,String>();
        Map<Id,String> mapAccIdToName = new Map<Id,String>();
        Map<String,Set<String>> mapAccIdToEmailSet = new Map<String,Set<String>>();
        accountList = new List<Account>();
        for(Account acc : scope){
            Set<string> accEmailset = new Set<string>(); //Set of Emails w.r.t. one Account.
            String accLang = '';
            String accCode = '';
            Id accId; 
            if(acc.Country_vod__r.Name !=null){
                accId = acc.Id;
                accLang = acc.Language_vod__c;
               //accCode = dcr.Account_vod__r.Country_Code__c;
                accCode = acc.Country_vod__r.Name;
                system.debug('accCode ******'+accCode);
                accName=acc.Name;
                //Add Email_Internal_AGN__c if not blank
                if(acc.Email_Internal_AGN__c!=null){
                    accEmailset.add(acc.Email_Internal_AGN__c);
                }
                //Add PersonEmail if not blank, in case it is same as internal email it will be added once due to set property.
                if(acc.PersonEmail!=null){
                    accEmailset.add(acc.PersonEmail);
                }
                System.debug('accEmailset** '+accEmailset);             
                //email_Internal/email - No priority. if both blank- no action, if at least either of them is populate then only proceed.
                if(!accEmailset.isEmpty()){
                    if(!String.isBlank(accLang)){
                        mapAccIdToLang.put(accId,accLang);
                    }
                    if(!String.isBlank(acccode)){
                       mapAccIdToCode.put(accId,accCode);
                    }
                    if(!String.isBlank(accName)){
                       mapAccIdToName.put(accId,accName);
                    }
                    //mapAccIdToEmailSet - map of Account Id vs EmailSet available on Account.
                    if(!mapAccIdToEmailSet.containsKey(accId)){
                        mapAccIdToEmailSet.put(accId, new Set<String>(accEmailset));
                    }
                    else{
                        mapAccIdToEmailSet.get(accId).addAll(accEmailset);
                    }
                }
            }
        }//scope_loop_ends.
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        oweaList = [select Id from OrgWideEmailAddress where DisplayName = 'Allergan Notifications' Limit 1];
        MapAccidsTempName = new Map<Id,String>();
        for(Account acc :[select id,Name,Email_Template_Name_AGN__c from Account where Id in: mapAccIdToEmailSet.keySet()]){
            List<String> emailAddressList = new List<String>(mapAccIdToEmailSet.get(acc.id));
             System.debug('accid: '+acc.id);
            //If for a particular AccountId , email message is to be sent, then added a check not to send again for the same account again.
            if(!MapAccidsTempName.containsKey(acc.id) && !templateMap.isEmpty()){
                System.debug('templateMap***: '+templateMap.keySet());
                //Check if for a particular language, finds a record in stored template in custom setting then construct email message.
                System.debug('mapAccIdToLang**: '+mapAccIdToLang.size());
                System.debug('mapAccIdToLang**: '+mapAccIdToLang.containsKey(acc.id));
                System.debug('emailCustSettingMap**: '+emailCustSettingMap.containsKey(mapAccIdToLang.get(acc.id)));
                if(!mapAccIdToLang.isEmpty() &&  mapAccIdToLang.containsKey(acc.id) && !emailCustSettingMap.isEmpty() && emailCustSettingMap.containsKey(mapAccIdToLang.get(acc.id))){
                    System.debug('*******LanguageCodeSection_1******');
                    String accLang = mapAccIdToLang.get(acc.id);
                    String accName= mapAccIdToName.get(acc.id);
                    System.debug('accId_InLanguageSection**: '+acc.id+'***: accLang:: '+accLang);
                    templateName = emailCustSettingMap.get(accLang);
                    System.debug('templateName**:'+templateName);
                    
                    if(templateMap.containsKey(templateName)){
                        System.debug('*******LanguageCodeSection_2******');
                        //constructEmail(String subject, List<String> toAddresses ,oweaList, Id templateId , String body)
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        //attachments =[SELECT Id,Name, Body, ContentType FROM Attachment WHERE ParentId = :templateMap.get(templateName).Id];
                        //system.debug('attachments +++'+attachments);
                        List<Attachment> attach = new List<Attachment>();
                        attach=tempIdToAttachMap.get(templateMap.get(templateName).Id);
                        if(attach !=null){
                        List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
                         for(Attachment att : attach){
                         Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
                         email_att.setBody(att.Body);
                         email_att.setContentType(att.ContentType);
                         email_att.setFileName(att.Name);
                         email_att.setinline(false);
                         email_attachments.add(email_att);
                        }
                        mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(templateName)),emailAddressList,oweaList,templateMap.get(templateName).Id,templateMap.get(templateName).HTMLValue,accName,email_attachments);
                        }
                        else{
                        mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(templateName)),emailAddressList,oweaList,templateMap.get(templateName).Id,templateMap.get(templateName).HTMLValue,accName,null);
                        }
                        //AG CC
                        if(Schema.sObjectType.Account.fields.Email_Template_Name_AGN__c.isUpdateable()){
                            acc.Email_Template_Name_AGN__c =templateName;
                        }
                        system.debug('AccountTemplateName'+acc.Email_Template_Name_AGN__c);
                        messageList.add(mail);
                        if(!String.isBlank(acc.Email_Template_Name_AGN__c)){
                        mapAccIdsTempName.put(acc.id, acc.Email_Template_Name_AGN__c);
                        system.debug('MapofidTempName'+mapAccIdsTempName);
                        }
                    }
                }
                //if language not found, then check if country code is found in the country object , if matches then fetch respective templateName stored in country object.
                else if(!mapAccIdToCode.isEmpty() && mapAccIdToCode.containsKey(acc.id) && !MapcCodeTempName.isEmpty() && MapcCodeTempName.containsKey(mapAccIdToCode.get(acc.id))){
                    System.debug('*******CountryCodeSection_1******');
                    String accCode = mapAccIdToCode.get(acc.id);
                    string accName= mapAccIdToName.get(acc.id);
                    System.debug('accId_InCodeSection**: '+acc.id+'***: acccode:: '+acccode);
                    templateNameCountry = MapcCodeTempName.get(accCode);
                    if(templateMap.containsKey(templateNameCountry)){
                        System.debug('*******CountryCodeSection_2******');
                         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     List<Attachment> attach = new List<Attachment>();
                        attach=tempIdToAttachMap.get(templateMap.get(templateNameCountry).Id);
                        //attachments =[SELECT Id,Name, Body, ContentType FROM Attachment WHERE ParentId = :templateMap.get(templateNameCountry).Id];
                     if(attach !=null){
                     List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
                     for(Attachment att :attach ){
                      Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
                      email_att.setBody(att.Body);
                      email_att.setContentType(att.ContentType);
                      email_att.setFileName(att.Name);
                      email_att.setinline(false);
                      email_attachments.add(email_att);
                    }
                        //constructEmail(String subject, List<String> toAddresses , Id templateId , String body)
                        mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(templateNameCountry)),emailAddressList,oweaList,templateMap.get(templateNamecountry).Id,templateMap.get(templateNamecountry).HTMLValue,accName,email_attachments);
                        }
                        else{
                        mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(templateNameCountry)),emailAddressList,oweaList,templateMap.get(templateNamecountry).Id,templateMap.get(templateNamecountry).HTMLValue,accName,null);
                        }                        
                        acc.Email_Template_Name_AGN__c = templateNameCountry;
                        system.debug('AccountTemplateName'+acc.Email_Template_Name_AGN__c);
                        messageList.add(mail);
                        if(!String.isBlank(acc.Email_Template_Name_AGN__c)){
                        mapAccIdsTempName.put(acc.id, acc.Email_Template_Name_AGN__c);
                        system.debug('MapofidTempName'+mapAccIdsTempName);
                        }
                    }
                }
                //Neither language related template found in custom Setting nor code related template found in Country object.
                else if(!String.isBlank(defaultETempName) && templateMap.containsKey(defaultETempName)){
                    System.debug('*******DefaultCodeSection******');
                    string accName= mapAccIdToName.get(acc.id);
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<Attachment> attach = new List<Attachment>();
                    attach=tempIdToAttachMap.get(templateMap.get(defaultETempName).Id);
                    // attachments =[SELECT Id,Name, Body, ContentType FROM Attachment WHERE ParentId = :templateMap.get(defaultETempName).Id];
                     //system.debug('attachments +++'+attachments);
                     if(attach !=null){
                     List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
                     for(Attachment att : attach){
                     Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
                      email_att.setBody(att.Body);
                      email_att.setContentType(att.ContentType);
                      email_att.setFileName(att.Name);
                      email_att.setinline(false);
                      email_attachments.add(email_att);
                    }
                    //constructEmail(String subject, List<String> toAddresses , Id templateId , String body)
                    mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(defaultETempName)),emailAddressList,oweaList,templateMap.get(defaultETempName).Id,templateMap.get(defaultETempName).HTMLValue,accName,email_attachments);
                    }
                    else{
                     mail = AGN_EmailUtilityClass.constructEmail(emailTemplateSubject.get(templateMap.get(defaultETempName)),emailAddressList,oweaList,templateMap.get(defaultETempName).Id,templateMap.get(defaultETempName).HTMLValue,accName,null);
                      }
                    //AG CC(287)
                    if(Schema.sObjectType.Account.fields.Email_Template_Name_AGN__c.isUpdateable()){
                        acc.Email_Template_Name_AGN__c =defaultETempName;
                        }
                    system.debug('AccountTemplateName'+acc.Email_Template_Name_AGN__c);
                    messageList.add(mail);
                    if(!String.isBlank(acc.Email_Template_Name_AGN__c)){
                    mapAccIdsTempName.put(acc.id, acc.Email_Template_Name_AGN__c);
                    system.debug('MapofidTempName'+mapAccIdsTempName);
                    }
                }
            }
        }//loop_Ends.
        list<Messaging.SendEmailResult> results = new list<Messaging.SendEmailResult>();
        system.debug('messageListSize**'+messageList.size());
        try{
            if(messageList!=null && messageList.size()>0){
                results = Messaging.sendEmail(messageList,true); // when any of the messages fails due to an error, results  
                System.debug('The email was sent successfully.'+results);
            }
        }
        Catch(Exception e){
            System.debug('The email failed to send: ' + e.getMessage());
            ++ErrorCount;
            
            //error table
            Error_Table_AGN__c errorObj  = new Error_Table_AGN__c();
            //AG CC(311)
            if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isCreateable()){
                errorObj.Error_Details_AGN__c = 'The email failed to send due to this exception: \n'+e.getMessage();
                }
            //errorObj.Error_Code_AGN__c = Integer.valueOf(e.getStatusCode());
            //AG CC
            if(Error_Table_AGN__c.sObjectType.getDescribe().isCreateable()){
                insert errorObj;
                }
            
            //Success_Error_History_AGN__c
            Success_Error_History_AGN__c SEhistoryObj = new Success_Error_History_AGN__c();
            SEhistoryObj.Allergan_Error_Table__c = 'Error ';
            SEhistoryObj.Record_Details_AGN__c = e.getMessage();
            SEhistoryObj.Error_Id_AGN__c = errorObj.Id;
            listSEHistory.add(SEhistoryObj);
        }
        System.debug('The email results:  '+results);
        system.debug('listSEHistory******* : ' + listSEHistory.size());
        System.debug('AccIdProcessed: '+mapAccIdsTempName.keySet());
        
        Set<Id> setAccId = new Set<Id>();
        System.debug('AccIdProcessed: '+mapAccIdsTempName.keySet());
         emailDate = Datetime.now();
        if(!mapAccIdsTempName.keySet().isEmpty() && !results.isEmpty()){
            System.debug('AccountUpdateSectionStarts*******');
            for(Account acc: [select id,Email_Template_Name_AGN__c,GDPR_Notification_Status_AGN__c,(Select Id,AccountId,emailBouncedDate,EmailBouncedReason from Contacts),Email_Sent_Date_AGN__c from Account where Id in: mapAccIdsTempName.keySet()]){
                for(Contact con: acc.Contacts){
                    if(!setAccId.contains(con.AccountId)){
                        if(con.emailBouncedDate == null && con.EmailBouncedReason == null){
                            System.debug('bothDatesFoundBlank:: ');
                            //AG CC
                            if(Schema.sObjectType.Account.fields.GDPR_Notification_Status_AGN__c.isUpdateable()){
                                acc.GDPR_Notification_Status_AGN__c = Label.AGN_EMAIL_NOTIFICATION_STATUS_SENT;
                                }
                            if(Schema.sObjectType.Account.fields.Email_Sent_Date_AGN__c.isUpdateable()){
                                acc.Email_Sent_Date_AGN__c = emailDate;
                                }
                            if(Schema.sObjectType.Account.fields.Email_Template_Name_AGN__c.isUpdateable()){
                                acc.Email_Template_Name_AGN__c = mapAccIdsTempName.get(acc.Id);
                                }
                            system.debug('Account to be updated'  + con.AccountId);
                             setAccId.add(con.AccountId);
                             accountList.add(acc);
                           }
                        else{
                            //AG CC(344-345)
                            if(Schema.sObjectType.Account.fields.GDPR_Notification_Status_AGN__c.isUpdateable()){
                                acc.GDPR_Notification_Status_AGN__c = Label.AGN_EMAIL_NOTIFICATION_STATUS_FAILED;
                                }
                            if(Schema.sObjectType.Account.fields.Email_Sent_Date_AGN__c.isUpdateable()){
                                acc.Email_Sent_Date_AGN__c = emailDate;
                                }
                            system.debug('Account to be updated'  + con.AccountId);
                            acc.Email_Template_Name_AGN__c = mapAccIdsTempName.get(acc.Id);
                            setAccId.add(con.AccountId);
                            accountList.add(acc);
                        }
                    }
                }//con_loop_Ends
            }//acc_loop_Ends
            
            System.debug('AccountList: '+accountList.size());
            System.debug('AccountList: '+accountList);
            System.debug('listSEHistory:===332= '+listSEHistory.size());
            //Database method to update the records in List
            //AG CC
            Database.SaveResult[] acList;
            if(Account.sObjectType.getDescribe().isUpdateable()){
                acList = Database.update(accountList,false);
                system.debug('acList=='+acList.size());
            }
            // Iterate through each returned result by the method.
            for (Database.SaveResult saveRes : acList) {
                Id RecId = saveRes.getId();
                //For every succss and error save a record in Success_Error_History_AGN__c.
                Success_Error_History_AGN__c SEhistoryObj = new Success_Error_History_AGN__c();
                if (saveRes.isSuccess()) {
                      // This condition will be executed for successful records and will fetch
                      // the ids of successful records
                      System.debug('Successfully updated account. account ID is : ' + RecId);
                      SEhistoryObj.Allergan_Error_Table__c = 'Success';
                      SEhistoryObj.Record_Details_AGN__c = String.valueOf(RecId) ;
                     System.debug('listSEHistory:===347='+listSEHistory.size());
                      listSEHistory.add(SEhistoryObj);
                      ++successCount ;
                   
                }else {
                    // This condition will be executed for failed records.
                    for(Database.Error err : saveRes.getErrors()) {
                        System.debug('The following error has occurred.');
                        // Printing error message in Debug log
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        ++ErrorCount;
                        //Success/Error history 
                        SEhistoryObj.Allergan_Error_Table__c= 'Error ';
                        SEhistoryObj.Record_Details_AGN__c = 'Record Id : '+ RecId + 'The email failed to send due to this exception:   \n'+err.getMessage();
                        listSEHistory.add(SEhistoryObj);
                      
                        
                        //Error Table.
                       Error_Table_AGN__c errorObj  = new Error_Table_AGN__c();
                        //AG CC(391-392)
                        if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isCreateable()){
                            errorObj.Error_Details_AGN__c = 'Record Id : '+ RecId + 'The email failed to send due to this exception:   \n'+err.getMessage();
                            }
                        if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isCreateable()){
                            errorObj.Error_Code_AGN__c = Integer.valueOf(err.getStatusCode());
                            }
                        mapAccIdToError.put(RecId, '');
                        listErrorTable.add(errorObj);
                    }//loop_Ends.
                }
            }//loop_Ends.
            //AG CC
            if(!listErrorTable.isEmpty() && Error_Table_AGN__c.sObjectType.getDescribe().isCreateable()){
                insert listErrorTable; 
                //insert listSEHistory;
            }
            for(Id RecId  : mapAccIdToError.keySet()){
                for(Error_Table_AGN__c ETH : listErrorTable){
                    if(ETH.Error_Details_AGN__c !=null && ETH.Error_Details_AGN__c.contains(RecId)){
                        mapAccIdToError.put(RecId,ETH.Id);
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('*******BatchFinishes********');
        AsyncApexJob aJob = [SELECT Id,ApexClassID,Status, NumberOfErrors,CreatedDate,CompletedDate, ExtendedStatus,LastProcessed,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        ApexClass ac = [SELECT Id, Name FROM ApexClass WHERE Id =:aJob.ApexClassID];
        Interface_Run_Details_AGN__c iRunDetail = new Interface_Run_Details_AGN__c();
        //AG CC(417-423)
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isCreateable()){
            iRunDetail.End_Date_AGN__c = aJob.CompletedDate;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Error_Record_Count_AGN__c.isCreateable()){
            iRunDetail.Error_Record_Count_AGN__c = ErrorCount;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Status__c.isCreateable()){
            iRunDetail.Run_Status__c = aJob.Status;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Name.isCreateable()){
            iRunDetail.Name = ac.Name;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Name_AGN__c.isCreateable()){
            iRunDetail.Run_Name_AGN__c=ac.Name;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Start_Date_AGN__c.isCreateable()){
            iRunDetail.Start_Date_AGN__c = aJob.CreatedDate;
            }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isCreateable()){
            iRunDetail.Success_Record_Count_AGN__c = successCount; 
            }
        system.debug('###iRunDetail##'+iRunDetail);
        
        //Insert Interface_Run_Details_AGN__c.
        //AG CC
        if(Interface_Run_Details_AGN__c.sObjectType.getDescribe().isCreateable())
        {
            Database.insert(iRunDetail,false);
            system.debug('iRunDetail** : ' + iRunDetail);
        }
        
        List<Success_Error_History_AGN__c> list_SEHToUpdate = new List<Success_Error_History_AGN__c>();
        system.debug('listSEHistory******* : ' + listSEHistory.size());
        for(Success_Error_History_AGN__c SEH  :listSEHistory){
            //AG CC(434)
            if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Interface_Run_Details_AGN__c.isCreateable()){
                SEH.Allergan_Interface_Run_Details_AGN__c = iRunDetail.Id;
                }
            for(Id RecId  : mapAccIdToError.keySet()){
            //AG CC(437)
                if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Error_Id_AGN__c.isCreateable()
                && SEH.Record_Details_AGN__c!=null 
                && SEH.Record_Details_AGN__c.contains(RecId)){
                    SEH.Error_Id_AGN__c = mapAccIdToError.get(RecId);
                }
            }//inner_loop_ends.
            list_SEHToUpdate.add(SEH);
        }//outer_loop_Ends.
        //AG CC
        if(!list_SEHToUpdate.isEmpty() && Success_Error_History_AGN__c.sObjectType.getDescribe().isCreateable() ){
            insert list_SEHToUpdate; 
        }
        System.debug('ErrorCount: '+ ErrorCount);
        System.debug('successCount: '+ successCount);
        System.debug('list_SEHToUpdate: '+ list_SEHToUpdate.size());
        System.debug('Finishes****************************');
        
    }
}