/* @author         Cognizant
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @modified      Preeti Achary
* @testClass     
* @Class Name    AGN_CCPAAssetWeeklyNotificationtoBOBatch
* --------------------------------------------------------------------------------------------------------
* @description -  Class used to send weekly notification to all business owners for CCPA filing system. 
*/
global class AGN_CCPAAssetWeeklyNotificationtoBOBatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Map<Id,Asset_Register_AGN__c> newlyCreatedAssetMap = new Map<Id,Asset_Register_AGN__c>();
    global Map<Id,Asset_Register_AGN__c> modifiedAssetMap = new Map<Id,Asset_Register_AGN__c>();
    global Map<Id,Asset_Register_AGN__c> rejectedAssetMap = new Map<Id,Asset_Register_AGN__c>();
    Map<Id, Set<Asset_Register_AGN__c>> userIdToNewSetAssetMap = new Map<Id, Set<Asset_Register_AGN__c>>();
    Map<Id, Set<Asset_Register_AGN__c>> userIdToOldSetAssetMap = new Map<Id, Set<Asset_Register_AGN__c>>();
    Map<Id, Set<Asset_Register_AGN__c>> userIdToRejectSetAssetMap = new Map<Id, Set<Asset_Register_AGN__c>>();
    global Map<Id, Set<Id>> userIdToSetAssetMap = new Map<Id, Set<Id>>();
    public Set<Id> userIdSet = new Set<Id>();
    Public Set<Id> queueIdSet = new Set<Id>();
    public List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
    global Map<Id,Id> assetIdToUserId = new Map<Id,Id>();
    global Map<Id,Set<Id>> userIdToSetAssetIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Set<Id>> queueIdToSetAssetIdMap = new Map<Id,Set<Id>>();
    public Map<Id,Id> assetIdToQueueId = new Map<Id,Id>();
    public Map<Id,Asset_Register_AGN__c> assetIdToAssetMap = new Map<Id,Asset_Register_AGN__c>();
    public Map<Id,String> userIdToEmailMap = new Map<Id,String>();
    public Map<Id,Set<Id>> queueIdToSetUserIdMap = new Map<Id,Set<Id>>();
    public Map<Id,Set<Id>> mapOwnerIdToAssetIdSet = new Map<Id, Set<Id>>();
    public Map<Id,Set<Id>> mapUserIdToAssetIdSet = new Map<Id, Set<Id>>();
    
    //Added this to capture all the GroupMembers all in one go.- Added by Preeti Achary
    global Map<Id,Set<Id>> groupIdToUserGroupSetIdMap = new Map<Id,Set<Id>>();
    //global Map<Id,QueueSobject> groupIdToUserGroupSetIdMap = new Map<Id,QueueSobject>();
    global Map<Id,Set<Id>> userIdToAssetIdSet_Map = new Map<Id, Set<Id>>();
    
    global AGN_CCPAAssetWeeklyNotificationtoBOBatch(){
        //Fetch groupIdToUserGroupSetIdMap
        for(GroupMember gpMember : [Select Id, UserOrGroupId,GroupId From GroupMember]){
            if(!groupIdToUserGroupSetIdMap.containsKey(gpMember.GroupId)){              
                groupIdToUserGroupSetIdMap.put(gpMember.GroupId, new Set<Id>{});
            }
            groupIdToUserGroupSetIdMap.get(gpMember.GroupId).add(gpMember.UserOrGroupId);
        }
    }
    //Asset_Register_AGN__c in Start - In Scope. (Asset Status : Draft and Updated Asset)
    global Database.QueryLocator start(Database.BatchableContext bc) {
    //Fetching Asset Registers for CCPA recordType, and are not Sent for Approved or renot approved yet.
        String queryStr = ' SELECT Id,Name, Asset_Status_AGN__c,recordTypeId,Recordtype.developerName,Top_Level_Business_Unit_GDPR_AGN__c,  ';
        queryStr += ' File_system_Type_GDPR_AGN__c,CreatedDate,Application_ID_EAL_ID_AGN__c,Created_Date_AGN__c,OwnerId FROM Asset_Register_AGN__c ';
        queryStr += ' WHERE RecordType.DeveloperName = \'CCPA_AGN\' ' ;
        queryStr += ' AND (Asset_Status_AGN__c = \'Draft\' OR Asset_Status_AGN__c = \'Updated Asset\' OR Asset_Status_AGN__c = \'Not Approved\')' ;
        queryStr += ' ORDER BY CreatedDate ';
        System.debug('queryStr## '+queryStr);
        return Database.getQueryLocator(queryStr); 
    }
    
    //Execute - Scoope Asset Registers
    global void execute(Database.BatchableContext bc, List<Asset_Register_AGN__c> scope){
        //process each batch of record
        for (Asset_Register_AGN__c asset: scope) {
            
            //AllAssets Map.
            assetIdToAssetMap.put(asset.Id , asset);
            
            if(String.isNotBlank(asset.Asset_Status_AGN__c)){
                //newlyCreatedAssetSet
                if(asset.Asset_Status_AGN__c.equalsIgnoreCase('Draft')){
                    newlyCreatedAssetMap.put(asset.Id , asset);
                }
                //modifiedAssetSet
                else if(asset.Asset_Status_AGN__c.equalsIgnoreCase('Updated Asset')){
                    modifiedAssetMap.put(asset.Id, asset);
                }
                //rejectedAssetSet
                else if(asset.Asset_Status_AGN__c.equalsIgnoreCase('Not Approved')){
                    rejectedAssetMap.put(asset.Id, asset);
                }
                //Find Asset Owner Type.
                Schema.SObjectType sObjType = asset.OwnerId.getSobjectType();
                String sObjTypeStr = String.valueOf(sObjType);
                System.debug('sObjTypeStr## '+sObjTypeStr);
                
                if(String.isNotBlank(sObjTypeStr) && sObjTypeStr.equalsIgnoreCase('User')){
                    assetIdToUserId.put(asset.Id,asset.OwnerId);
                    if(!userIdToSetAssetIdMap.containsKey(asset.ownerId)){
                        userIdToSetAssetIdMap.put(asset.ownerId, new Set<Id>{});
                    }
                    userIdToSetAssetIdMap.get(asset.ownerId).add(asset.Id);
                }
                else if(String.isNotBlank(sObjTypeStr) && sObjTypeStr.equalsIgnoreCase('Group')){
                    assetIdToQueueId.put(asset.Id,asset.OwnerId);
                    System.debug('assetIdToQueueId## '+queueIdToSetAssetIdMap);
                    if(!queueIdToSetAssetIdMap.containsKey(asset.ownerId)){
                        queueIdToSetAssetIdMap.put(asset.ownerId, new Set<Id>{});
                    }
                    queueIdToSetAssetIdMap.get(asset.ownerId).add(asset.Id);
                }
                System.debug('queueIdToSetAssetIdMap## '+queueIdToSetAssetIdMap);
                //mapOwnerIdToAssetIdSet
                if(!mapOwnerIdToAssetIdSet.containsKey(asset.OwnerId)){
                    mapOwnerIdToAssetIdSet.put(asset.OwnerId , new Set<Id> {} );
                }
                mapOwnerIdToAssetIdSet.get(asset.OwnerId).add(asset.Id);
            }
        }//loop_ends.
        // ---GroupMember---
        
        //userIdToAssetIdSet_Map
        for(Id ownerId : mapOwnerIdToAssetIdSet.keySet()){
            //Find Group Member Type and create map accordingly. 
            Set<Id> assetIdSet = mapOwnerIdToAssetIdSet.get(ownerId);
            if(!groupIdToUserGroupSetIdMap.isEmpty() && groupIdToUserGroupSetIdMap.containsKey(ownerId)){
                for(Id userOrGpId : groupIdToUserGroupSetIdMap.get(ownerId)){
                    //If Group contains another Group as Member
                    if(groupIdToUserGroupSetIdMap.containsKey(userOrGpId)){
                        Set<Id> pguserIdSet = groupIdToUserGroupSetIdMap.get(userOrGpId);
                        for(Id pgUserId : pguserIdSet){
                            //Else Group contains Users as Members. 
                            if(!userIdToAssetIdSet_Map.containsKey(pgUserId)){
                                userIdToAssetIdSet_Map.put(pgUserId, new Set<Id>{});
                            }
                            userIdToAssetIdSet_Map.get(pgUserId).addAll(assetIdSet);
                        }
                    }
                    else{
                        //Else Group contains Users as Members. 
                        if(!userIdToAssetIdSet_Map.containsKey(userOrGpId)){
                            userIdToAssetIdSet_Map.put(userOrGpId, new Set<Id>{});
                        }
                        userIdToAssetIdSet_Map.get(userOrGpId).addAll(assetIdSet);
                    }
                }
            }
            //In case the owner is a user instead of a queue or a public group.
            if(!userIdToAssetIdSet_Map.containsKey(ownerId)){
                userIdToAssetIdSet_Map.put(ownerId, new Set<Id>{});
            }
            userIdToAssetIdSet_Map.get(ownerId).addAll(assetIdSet);
        }
        
        for(User userObj : [Select id,email from User where Id in :userIdToAssetIdSet_Map.keySet()]){
            userIdToEmailMap.put(userObj.Id, userObj.Email);
        }
        System.debug('userIdToEmailMap##_execute '+userIdToEmailMap);
        Set<Id> queueUserIdSet = new Set<Id>();
        for(Id userId : userIdToAssetIdSet_Map.keySet()){
            for(Id assetId : userIdToAssetIdSet_Map.get(userId)){
                if(assetIdToAssetMap.containsKey(assetId)){
                    Asset_Register_AGN__c asset = assetIdToAssetMap.get(assetId);
                    if(!newlyCreatedAssetMap.isEmpty() && newlyCreatedAssetMap.containsKey(assetId)){
                        if(!userIdToNewSetAssetMap.containsKey(userId)){
                            userIdToNewSetAssetMap.put(userId, new Set<Asset_Register_AGN__c>{});
                        }
                        userIdToNewSetAssetMap.get(userId).add(asset);
                    }
                    else if(!modifiedAssetMap.isEmpty() && modifiedAssetMap.containsKey(assetId)){
                        if(!userIdToOldSetAssetMap.containsKey(userId)){
                            userIdToOldSetAssetMap.put(userId, new Set<Asset_Register_AGN__c>{});
                        }
                        userIdToOldSetAssetMap.get(userId).add(asset);
                    }
                    else if(!rejectedAssetMap.isEmpty() && rejectedAssetMap.containsKey(assetId)){
                        if(!userIdToRejectSetAssetMap.containsKey(userId)){
                            userIdToRejectSetAssetMap.put(userId, new Set<Asset_Register_AGN__c>{});
                        }
                        userIdToRejectSetAssetMap.get(userId).add(asset);
                    }
                }
                
            }
        }
              
    }    
   
    global void finish(Database.BatchableContext bc){
       Map<Id,Set<String>> assetIdtoEmailSet = new Map<Id,Set<String>>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        
        // call some utility to send email
        List<Messaging.SingleEmailMessage>  emailList = new List<Messaging.SingleEmailMessage>();
        oweaList = [select Id from OrgWideEmailAddress where DisplayName in(:AGN_GDPR_ConstantUtility.CCPA_ACCESSREQ)];
        String subject = 'Subject: Asset Registry – Outstanding items';
        String htmlBody =''; 
        
        
        for(Id userId : userIdToAssetIdSet_Map.keySet()){
            Set<Asset_Register_AGN__c> newlyCreatedAssetSet = new Set<Asset_Register_AGN__c>();
            Set<Asset_Register_AGN__c> modifiedAssetSet = new Set<Asset_Register_AGN__c>();
            Set<Asset_Register_AGN__c> rejectedAssetSet = new Set<Asset_Register_AGN__c>();
            if(userIdToNewSetAssetMap.containsKey(userId)){
                newlyCreatedAssetSet = userIdToNewSetAssetMap.get(userId); 
            }
            if(userIdToOldSetAssetMap.containsKey(userId)){
                modifiedAssetSet = userIdToOldSetAssetMap.get(userId);
            }
            if(userIdToRejectSetAssetMap.containsKey(userId)){
                rejectedAssetSet = userIdToRejectSetAssetMap.get(userId);
            }
            System.debug('userId## '+userId + '  new  '+newlyCreatedAssetSet + '    old  '+modifiedAssetSet);
            htmlBody = AGN_EmailUtil.getTableEmailBody(newlyCreatedAssetSet , modifiedAssetSet,rejectedAssetSet);
            
            List<String> listToEmailAddress = new List<String>();
            if(userIdToEmailMap.containsKey(userId) && String.isNotBlank(htmlBody)){
                listToEmailAddress.add(userIdToEmailMap.get(userId));
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                //message.setTargetObjectId(assetId); - Can only be standard objects. 
                message.setToAddresses(listToEmailAddress);
                if (oweaList.size()>0) {
                 message.setOrgWideEmailAddressId(oweaList.get(0).Id);
                }
                message.setSaveAsActivity(false);
                message.setSubject(subject);
                message.setHtmlBody(htmlBody);
                emailList.add(message);
                System.debug('emailList## '+emailList);
            }

        }//loop_ends.
        //Send_Email
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
    } 
}