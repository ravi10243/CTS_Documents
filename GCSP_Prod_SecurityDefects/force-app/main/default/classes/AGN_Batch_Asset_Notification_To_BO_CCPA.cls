/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      GDPR Case management Project Team
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        27.02.2020
* @modified      
* @testClass     
* @Class Name    AGN_Batch_Asset_Notification_To_BO_CCPA 
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 27-Feb-2020           
*  Apex Batch Class to send BO users their Filing System List for quarterly health checkup (Requirement ID: 47 March Release)
*-------------------------------------------------------------------------------------------------------------------------------+
*/
global class AGN_Batch_Asset_Notification_To_BO_CCPA implements Database.Batchable<sobject>, Database.Stateful {
    
    public List<Asset_Register_AGN__c> assetUpdateList = new List<Asset_Register_AGN__c>(); 
    global Map<Id,List<Id>> mapBOtoAsset = new Map<Id,List<Id>>();
    global Map<String,List<Id>> userEmailtoAsset = new Map<String,List<Id>>();
    public List<Id> listOfNotValidatedAssetsToBO = new List<Id>();
    global Map<Id,String> UserIdToEmailMap =  new Map<Id,String>();
    public Set<Id> listOfNotValidatedAssetsCCPA = new Set<Id>();
    public List<Id> boAssetIdList = new List<Id>();
    public Map<Id,Asset_Register_AGN__c> assetIdToAssetMap = new Map<Id,Asset_Register_AGN__c>();
    global Map<Id,Set<Id>> userIdToSetAssetIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Set<Id>> queueIdToSetAssetIdMap = new Map<Id,Set<Id>>();
    public Map<Id,Set<Id>> mapOwnerIdToAssetIdSet = new Map<Id, Set<Id>>();
    Map<Id, Set<Asset_Register_AGN__c>> userIdToNewSetAssetMap = new Map<Id, Set<Asset_Register_AGN__c>>();
    global Map<Id,Id> assetIdToUserId = new Map<Id,Id>();
    public Map<Id,Id> assetIdToQueueId = new Map<Id,Id>();
    global Map<Id,Set<Id>> groupIdToUserGroupSetIdMap = new Map<Id,Set<Id>>();
    global Map<Id,Set<Id>> userIdToAssetIdSet_Map = new Map<Id, Set<Id>>();
    global List<Id> assetIdList = new List<Id>();
    public List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
    
    global AGN_Batch_Asset_Notification_To_BO_CCPA(){
        //Fetch groupIdToUserGroupSetIdMap
        for(GroupMember gpMember : [Select Id, UserOrGroupId,GroupId From GroupMember]){
            if(!groupIdToUserGroupSetIdMap.containsKey(gpMember.GroupId)){              
                groupIdToUserGroupSetIdMap.put(gpMember.GroupId, new Set<Id>{});
            }
            groupIdToUserGroupSetIdMap.get(gpMember.GroupId).add(gpMember.UserOrGroupId);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([SELECT Name,AGN_Assign_Primary_Owner_in_queue__c,Asset_Status_AGN__c,Application_Status_AGN__c,Id,IsApproved_AGN__c,Is_Active_AGN__c,RecordTypeId,RecordType.Name,Top_Level_Business_Unit_GDPR_AGN__c,Validated_Filing_System_AGN__c,OwnerId,Owner.Name,File_system_Type_GDPR_AGN__c,Application_ID_EAL_ID_AGN__c,Created_Date_AGN__c,Validation_Date_AGN__c FROM Asset_Register_AGN__c Where Is_Active_AGN__c =True And Asset_Status_AGN__c NOT IN ('Sent For Approval','Under Review') AND RecordType.Name = 'CCPA']);
    }
    global void execute(Database.BatchableContext context, List<Asset_Register_AGN__c> scope) 
    {
        
        system.debug('Before update'+scope);
        // Uncheck all active assets validated checkbox        
        for(Asset_Register_AGN__c assetUpdate: scope)
        {
            assetUpdate.Validated_Filing_System_AGN__c = false;
            assetUpdateList.add(assetUpdate);
        }       
        if(assetUpdateList.size()>0)
        {
            update assetUpdateList;
        }
        
        system.debug('UpdatedAsset### '+assetUpdateList);
        //map to store all the public group and queues member list; group/queue as keysets and members as value
        Map<Id,Set<Id>> mapGroupIDToGroupMember = new Map<Id,Set<Id>>();
        Set<Id> groupMemberSet =  new Set<Id>();
        for(GroupMember gpMember: [Select Id,UserOrGroupId,GroupId,Group.type From GroupMember where Group.type = 'Queue' or Group.type = 'Regular'])
        {
            if(mapGroupIDToGroupMember.containsKey(gpMember.GroupId))
            {
                mapGroupIDToGroupMember.get(gpMember.GroupId).add(gpMember.UserOrGroupId);
            }
            else
            {
                groupMemberSet.add(gpMember.UserOrGroupId);    
                mapGroupIDToGroupMember.put(gpMember.GroupId, groupMemberSet);
            }
        }
        System.debug('mapGroupIDToGroupMember### '+mapGroupIDToGroupMember.keySet());
        System.debug('mapGroupIDToGroupMember### '+mapGroupIDToGroupMember.values());
    
        /*CodeReview_March - Updated**/
        for(Asset_Register_AGN__c asset : assetUpdateList){
            assetIdToAssetMap.put(asset.Id , asset);
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
        }//loop_ends.
        
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
        }//loop_ends
        System.debug('userIdToAssetIdSet_Map### '+userIdToAssetIdSet_Map.keySet());
        System.debug('userIdToAssetIdSet_MapValues### '+userIdToAssetIdSet_Map.values());
        for(User userObj : [Select id,email from User where Id in :userIdToAssetIdSet_Map.keySet()]){
            userIdToEmailMap.put(userObj.Id, userObj.Email);
        }//loop_ends
        System.debug('userIdToEmailMap##_execute '+userIdToEmailMap);
        Set<Id> queueUserIdSet = new Set<Id>();
        for(Id userId : userIdToAssetIdSet_Map.keySet()){
            for(Id assetId : userIdToAssetIdSet_Map.get(userId)){
                if(assetIdToAssetMap.containsKey(assetId)){
                    Asset_Register_AGN__c asset = assetIdToAssetMap.get(assetId);
                    if(!userIdToNewSetAssetMap.containsKey(userId)){
                        userIdToNewSetAssetMap.put(userId, new Set<Asset_Register_AGN__c>{});
                    }
                    userIdToNewSetAssetMap.get(userId).add(asset);
                }
            }//loop_ends
        }//loop_ends
        System.debug('userIdToNewSetAssetMap## '+userIdToNewSetAssetMap);
        
        
    }
    global void finish(Database.BatchableContext context) {
        Map<Id,Set<String>> assetIdtoEmailSet = new Map<Id,Set<String>>();
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :context.getJobId()];
            List<Messaging.SingleEmailMessage>  emailList = new List<Messaging.SingleEmailMessage>();
        oweaList = [select Id,DisplayName from OrgWideEmailAddress where DisplayName in(:AGN_GDPR_ConstantUtility.CCPA_ACCESSREQ)];
        String subject = 'Quarterly validation of filing system';
        //String htmlBody ='';   
        System.debug('userIdToNewSetAssetMap## '+ userIdToNewSetAssetMap);
        String htmlBody ='';
        //EmailTemplate CCPATemplate = [SELECT Id,HtmlValue,Body,Name FROM EmailTemplate WHERE Name = 'AGN CCPA BO Filing System Notification']; 
        Set<Asset_Register_AGN__c> newlyCreatedAssetSet;
        List<String> listToEmailAddress;
        Messaging.SingleEmailMessage message;
        for(Id userId : userIdToAssetIdSet_Map.keySet()){
            newlyCreatedAssetSet = new Set<Asset_Register_AGN__c>();
            if(userIdToNewSetAssetMap.containsKey(userId)){
                newlyCreatedAssetSet = userIdToNewSetAssetMap.get(userId); 
            }
            htmlBody = AGN_EmailUtil.getQuaterlyEmailBody(newlyCreatedAssetSet);
            assetIdList.addAll(userIdToAssetIdSet_Map.get(userId));
            listToEmailAddress = new List<String>();
            if(userIdToEmailMap.containsKey(userId)){
                listToEmailAddress.add(userIdToEmailMap.get(userId));
                message = new Messaging.SingleEmailMessage();
                //message.setTargetObjectId(assetId); - Can only be standard objects. 
                message.setToAddresses(listToEmailAddress);
                if (oweaList.size()>0) {
                 message.setOrgWideEmailAddressId(oweaList.get(0).Id);
                }   
                message.setSaveAsActivity(false);
                message.setSubject(subject);
                message.setHtmlBody(htmlBody);
                //message.setTemplateId(CCPATemplate.Id);
                message.setTargetObjectId(userId);
                message.setWhatId(assetIdList[0]);
                System.debug('message## '+message);
                emailList.add(message);
                System.debug('emailList## '+emailList);
                
            }
        }
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