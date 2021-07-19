/*-------------------------------------------------------------------------------------------------------
* @author         Cognizant
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @modified      Preeti Achary
* @testClass     
* @Class Name    Batch_Task_Notification_TO_BO_GDPR_AGN
* --------------------------------------------------------------------------------------------------------
* @description -  Incorrect Scope was on user , changed it business_owner_task owner
-  Not bulkified - made it bulkified.
-  Incorrectly mail sending logic - corrected the logic to fire it for the right set of boTasks
-  Code didn't have best practices - Optimized(almost rewritten the entire batch logic again to  make it optimized)
*/
global class Batch_Task_Notification_TO_BO_GDPR_AGN implements Database.Batchable<SObject>, Database.Stateful  {
    
    global Map<Id,Business_Owner_Task_GDPR_AGN__c> boTaskIdToboTaskMap = new Map<Id,Business_Owner_Task_GDPR_AGN__c>();
    global Map<Id,String> userIdToEmailMap = new Map<Id,String>();
    global Map<Id,Set<Id>> queueIdToSetUserIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Set<Id>> mapOwnerIdToboTaskIdSet = new Map<Id, Set<Id>>();
    global Map<Id,Set<Id>> mapUserIdToboTaskIdSet = new Map<Id, Set<Id>>();
    global Map<Id,Set<Id>> userIdToSetboTaskIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Set<Id>> queueIdToSetboTaskIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Id> boTaskIdToQueueId = new Map<Id,Id>();
    global Map<Id, Set<Business_Owner_Task_GDPR_AGN__c>> userIdToNewSetboTaskMap = new Map<Id,  Set<Business_Owner_Task_GDPR_AGN__c>>();
    global Map<Id, Set<Business_Owner_Task_GDPR_AGN__c>> userIdToSetCcpaBoTaskMap = new Map<Id, Set<Business_Owner_Task_GDPR_AGN__c>>();
    global Map<Id, Set<Business_Owner_Task_GDPR_AGN__c>> userIdToSetGdprboTaskMap = new Map<Id, Set<Business_Owner_Task_GDPR_AGN__c>>();
    global Map<Id,Id> boTaskIdToUserId = new Map<Id, Id>();
    global List<Id> botaskIdList = new List<Id>();
    global Map<Id,Id> botaskIdToOrgWideIdMap = new Map<Id,Id>();
    global Map<String, Id> orgWideNameToOrgWideIdMap  = new Map<String, Id>(); 
    global Id ccpaOrgWideId;
    global Id gdprOrgWideId;
    
    //Added this to capture all the GroupMembers all in one go.- Added by Preeti Achary
    global Map<Id,Set<Id>> groupIdToUserGroupSetIdMap = new Map<Id,Set<Id>>();
    //global Map<Id,QueueSobject> groupIdToUserGroupSetIdMap = new Map<Id,QueueSobject>();
    global Map<Id,Set<Id>> userIdToboTaskIdSet_Map = new Map<Id, Set<Id>>();
    public Database.QueryLocator start(Database.BatchableContext context) {
      	 return Database.getQueryLocator([SELECT id,Due_Date_AGN__c,Days_to_Close_GDPR_AGN__c,CreatedDate,Assigned_To_GDPR_AGN__c,Task_Subject_GDPR_AGN__c,
                                         Assigned_To_GDPR_AGN__r.name,Assigned_To_GDPR_AGN__r.email,
                                         Assigned_To_GDPR_AGN__r.id,Case_Type_GDPR_AGN__c,Name,OwnerId,
                                         Related_to_GDPR_AGN__r.CaseNumber,Status_GDPR_AGN__c,Asset_GDPR_AGN__c,
                                         Owner.Email,Asset_GDPR_AGN__r.Name FROM Business_Owner_Task_GDPR_AGN__c
                                         WHERE Status_GDPR_AGN__c NOT IN ('Completed','Rejected') and
                                         OwnerId != null order by CreatedDate DESC]);
    }
    global Batch_Task_Notification_TO_BO_GDPR_AGN(){
        //Fetch groupIdToUserGroupSetIdMap
        for(GroupMember gpMember : [Select Id, UserOrGroupId,GroupId From GroupMember]){
            if(!groupIdToUserGroupSetIdMap.containsKey(gpMember.GroupId)){              
                groupIdToUserGroupSetIdMap.put(gpMember.GroupId, new Set<Id>{});
            }
            groupIdToUserGroupSetIdMap.get(gpMember.GroupId).add(gpMember.UserOrGroupId);
        }
    }
    public void execute(Database.BatchableContext context, List<Business_Owner_Task_GDPR_AGN__c> scope){
        
        
        for (Business_Owner_Task_GDPR_AGN__c boTask: scope) {
            
            //AllboTasks Map.
            boTaskIdToboTaskMap.put(boTask.Id , boTask);
            
            //Find boTask Owner Type.
            Schema.SObjectType sObjType = boTask.OwnerId.getSobjectType();
            String sObjTypeStr = String.valueOf(sObjType);
            System.debug('sObjTypeStr## '+sObjTypeStr);
            
            if(String.isNotBlank(sObjTypeStr) && sObjTypeStr.equalsIgnoreCase('User')){
                boTaskIdToUserId.put(boTask.Id,boTask.OwnerId);
                if(!userIdToSetboTaskIdMap.containsKey(boTask.ownerId)){
                    userIdToSetboTaskIdMap.put(boTask.ownerId, new Set<Id>{});
                }
                userIdToSetboTaskIdMap.get(boTask.ownerId).add(boTask.Id);
            }
            else if(String.isNotBlank(sObjTypeStr) && sObjTypeStr.equalsIgnoreCase('Group')){
                boTaskIdToQueueId.put(boTask.Id,boTask.OwnerId);
                System.debug('boTaskIdToQueueId## '+queueIdToSetboTaskIdMap);
                if(!queueIdToSetboTaskIdMap.containsKey(boTask.ownerId)){
                    queueIdToSetboTaskIdMap.put(boTask.ownerId, new Set<Id>{});
                }
                queueIdToSetboTaskIdMap.get(boTask.ownerId).add(boTask.Id);
            }
            System.debug('queueIdToSetboTaskIdMap## '+queueIdToSetboTaskIdMap);
            //mapOwnerIdToboTaskIdSet
            if(!mapOwnerIdToboTaskIdSet.containsKey(boTask.OwnerId)){
                mapOwnerIdToboTaskIdSet.put(boTask.OwnerId , new Set<Id> {} );
            }
            mapOwnerIdToboTaskIdSet.get(boTask.OwnerId).add(boTask.Id);
            
        }//loop_ends.
        //userIdToboTaskIdSet_Map
        for(Id ownerId : mapOwnerIdToboTaskIdSet.keySet()){
            //Find Group Member Type and create map accordingly. 
            Set<Id> boTaskIdSet = mapOwnerIdToboTaskIdSet.get(ownerId);
            if(!groupIdToUserGroupSetIdMap.isEmpty() && groupIdToUserGroupSetIdMap.containsKey(ownerId)){
                for(Id userOrGpId : groupIdToUserGroupSetIdMap.get(ownerId)){
                    //If Group contains another Group as Member
                    if(groupIdToUserGroupSetIdMap.containsKey(userOrGpId)){
                        Set<Id> pguserIdSet = groupIdToUserGroupSetIdMap.get(userOrGpId);
                        for(Id pgUserId : pguserIdSet){
                            //Else Group contains Users as Members. 
                            if(!userIdToboTaskIdSet_Map.containsKey(pgUserId)){
                                userIdToboTaskIdSet_Map.put(pgUserId, new Set<Id>{});
                            }
                            userIdToboTaskIdSet_Map.get(pgUserId).addAll(boTaskIdSet);
                        }
                    }
                    else{
                        //Else Group contains Users as Members. 
                        if(!userIdToboTaskIdSet_Map.containsKey(userOrGpId)){
                            userIdToboTaskIdSet_Map.put(userOrGpId, new Set<Id>{});
                        }
                        userIdToboTaskIdSet_Map.get(userOrGpId).addAll(boTaskIdSet);
                    }
                }
            }
            //In case the owner is a user instead of a queue or a public group.
            if(!userIdToboTaskIdSet_Map.containsKey(ownerId)){
                userIdToboTaskIdSet_Map.put(ownerId, new Set<Id>{});
            }
            userIdToboTaskIdSet_Map.get(ownerId).addAll(boTaskIdSet);
        }
        System.debug('userIdToboTaskIdSet_Map### '+userIdToboTaskIdSet_Map.keySet());
        System.debug('userIdToboTaskIdSet_MapValues### '+userIdToboTaskIdSet_Map.values());
        for(User userObj : [Select id,email from User where Id in :userIdToboTaskIdSet_Map.keySet()]){
            userIdToEmailMap.put(userObj.Id, userObj.Email);
        }
        System.debug('userIdToEmailMap##_execute '+userIdToEmailMap);
        
        //Fetch orgWideNameToOrgWideIdMap
        for(OrgWideEmailAddress orgWide : [select Id,DisplayName from OrgWideEmailAddress where DisplayName in(:AGN_GDPR_ConstantUtility.DATASUB_ACCESSREQ, :AGN_GDPR_ConstantUtility.CCPA_ACCESSREQ)]){
            orgWideNameToOrgWideIdMap.put(orgWide.DisplayName, orgWide.Id);
            //Modified for Prod Fix
            if(orgWide.DisplayName.contains(AGN_GDPR_ConstantUtility.CCPA_ACCESSREQ)){
                ccpaOrgWideId = orgWide.Id;
            }
            else{
                gdprOrgWideId = orgWide.Id;
            }
        }
        for(Id userId : userIdToboTaskIdSet_Map.keySet()){
            for(Id boTaskId : userIdToboTaskIdSet_Map.get(userId)){
                if(boTaskIdToboTaskMap.containsKey(boTaskId)){
                    Business_Owner_Task_GDPR_AGN__c boTask = boTaskIdToboTaskMap.get(boTaskId);
                    //CCPA Case Type Owners Vs their boTasks
                    if(!String.isBlank(boTask.Case_Type_GDPR_AGN__c)){
                        if(boTask.Case_Type_GDPR_AGN__c.equalsIgnoreCase(AGN_GDPR_ConstantUtility.CCPA)){
                            if(!userIdToSetCcpaBoTaskMap.containsKey(userId)){
                                userIdToSetCcpaBoTaskMap.put(userId, new Set<Business_Owner_Task_GDPR_AGN__c>{});
                            }
                            userIdToSetCcpaBoTaskMap.get(userId).add(boTask);
                        }
                        //GDPR Case Type Owners Vs their boTasks.
                        else if(boTask.Case_Type_GDPR_AGN__c.equalsIgnoreCase(AGN_GDPR_ConstantUtility.GDPR)){
                            if(!userIdToSetGdprboTaskMap.containsKey(userId)){
                                userIdToSetGdprboTaskMap.put(userId, new Set<Business_Owner_Task_GDPR_AGN__c>{});
                            }
                            userIdToSetGdprboTaskMap.get(userId).add(boTask);
                        }
                    }
                }
            }//loop_ends
        }//loop_ends
        System.debug('userIdToSetGdprboTaskMap## '+userIdToSetGdprboTaskMap);
        System.debug('userIdToSetCcpaBoTaskMap## '+userIdToSetCcpaBoTaskMap);
        System.debug('***********execute_ends*************');
    }
    public void finish(Database.BatchableContext context) {
        System.debug('***********finish_starts*************');
        List<EmailTemplate> emailTempList = [SELECT Id,HtmlValue,Body,Name FROM EmailTemplate WHERE Name = 'AGN GDPR BO Daily Task Details'];
        Id emailTempId;
        if(!emailTempList.isEmpty()){
            emailTempId = emailTempList.get(0).Id;
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        List<AGN_GDPR_FromEmailId_Settings__c> fromEmailAddList = [SELECT FromEmail_AGN__c FROM AGN_GDPR_FromEmailId_Settings__c];
        String fromEmailStr;
        if(!fromEmailAddList.isEmpty()){
            fromEmailStr = fromEmailAddList.get(0).FromEmail_AGN__c;
        }
        Map<Id,Set<String>> assetIdtoEmailSet = new Map<Id,Set<String>>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :context.getJobId()];
        
        // call some utility to send email
        Set<Business_Owner_Task_GDPR_AGN__c> newlyCreatedbotaskSet;
        List<String> listToEmailAddress;
        Messaging.SingleEmailMessage message;
        String htmlBody = '';
        //Line 199 To be removed for the DSRM 37 Requirement
        String subject = 'DSRM assigned NEW Task(s)';
        for(Id userId : userIdToboTaskIdSet_Map.keySet()){
            newlyCreatedbotaskSet = new Set<Business_Owner_Task_GDPR_AGN__c>();
            if(userIdToEmailMap.containsKey(userId)){
                //CCPA_Message_Processing
                if(userIdToSetCcpaBoTaskMap.containsKey(userId)){
                    listToEmailAddress = new List<String>();
                    listToEmailAddress.add(userIdToEmailMap.get(userId));
                    newlyCreatedbotaskSet = userIdToSetCcpaBoTaskMap.get(userId);
                    //Changes made on line 207 for the DSRM Release 3 Sprint 1 Req ID -DSRm 37 -"Add GDPR or CCPA into the subject of the email."
                   // String subject = System.Label.AGN_CCPA_BatchTaskEmailSubject;
                    message = AGN_GDPR_Utility.getGenericEmailMessage(listToEmailAddress, subject, userId);
                    if(message != null){
                        htmlBody = '';
                        htmlBody = AGN_EmailUtil.getTaskEmailBody(newlyCreatedbotaskSet,'CCPA');
                        System.debug('htmlBody#CCPA '+htmlBody );
                        if(!String.isBlank(htmlBody)){
                            message.setHtmlBody(htmlBody);
                        }
                        message.setOrgWideEmailAddressId(ccpaOrgWideId);  
                        System.debug('message##_ccpa '+message);
                        emailList.add(message);
                    }
                }
                //GDPR_Message_Processing
                if(userIdToSetGdprBoTaskMap.containsKey(userId)){
                    listToEmailAddress = new List<String>();
                    listToEmailAddress.add(userIdToEmailMap.get(userId));
                    //Changes made on line 226 for the DSRM Release 3 Sprint 1 Req ID -DSRm 37 -"Add GDPR or CCPA into the subject of the email."
                   // String subject = System.Label.AGN_GDPR_BatchTaskEmailSubject;
                    message = AGN_GDPR_Utility.getGenericEmailMessage(listToEmailAddress, subject, userId);
                    if(message != null){
                        htmlBody = '';
                        newlyCreatedbotaskSet = userIdToSetGdprBoTaskMap.get(userId);
                        htmlBody = AGN_EmailUtil.getTaskEmailBody(newlyCreatedbotaskSet,'GDPR');
                        System.debug('htmlBody#GDPR '+htmlBody );
                        if(!String.isBlank(htmlBody)){
                            message.setHtmlBody(htmlBody);
                        }
                        //message.setTemplateId(emailTempId);
                        //message.setWhatId(boTask.Id);
                        message.setOrgWideEmailAddressId(gdprOrgWideId);
                        System.debug('message##_gdpr '+message);
                        emailList.add(message);
                    }
                }
            }
        }//loop_ends.
        //Send_Email
        System.debug('emailList## '+emailList);
        if(!emailList.isEmpty()){
            System.debug('emailList## '+emailList);    
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            }
            else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        System.debug('***********finish_ends*************');
    }
}