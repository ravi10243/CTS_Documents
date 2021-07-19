/*
Type Name: AGN_CaseTriggerHandler
Reason: Utility class for Case Trigger methods.
22-08-2016 - SB - Close Milestones on Case.
27-09-2016 - SG - Validate ship to and sold to account affiliation with Contact.
10-07-2018 - SC - New method addAccountToCaseFromEmail() added for Coolsculpting implementation. This method will work for Email2Case.
*/
public class AGN_CaseTriggerHandler {
    
    /*Validation Sold to and Ship to Account based on Contact selected */
    public static void checkSoldTo_ShipTo(List<Case> lCase){
        
        
        map<Id, Id> caseSoldToMap = new map<Id, Id>();
        map<Id, Id> caseShipToMap = new map<Id, Id>();
        map<Id, set<Id>> soldAccountMap = new map<Id, set<Id>>();
        map<Id, set<Id>> shipAccountMap = new map<Id, set<Id>>();
        set<Id>  contactIds = new set<Id>();
        map<Id, Id> caseContactMap = new map<Id, Id>();
        
        User uInfo = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId()];
        if (AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c) != null && AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).SoldToShipToCheck__c){
            
            for (Case c: lcase){
                contactIds.add(c.ContactId);
            }
            
            for (Contact c : [Select Id, AccountId from Contact where Id IN : contactIds]){
                caseContactMap.put(c.Id, c.AccountId);
            }        
            
            for(Case c :lcase){                         
                if (c.ContactId != null && c.AccountId != null) caseSoldToMap.put(caseContactMap.get(c.ContactId), c.AccountId);
                if (c.ContactId != null && c.Ship_To_Account_AGN__c != null) caseShipToMap.put(caseContactMap.get(c.ContactId), c.Ship_To_Account_AGN__c);      
            }
            
            //check for sold to affiliation  
            if (!caseSoldToMap.isEmpty()) {
                for (Child_Account_vod__c ca : [select id,Parent_Account_vod__c,Child_Account_vod__C from Child_Account_vod__c where Parent_Account_vod__c IN :caseSoldToMap.values() 
                                                AND Child_Account_vod__c IN :caseSoldToMap.keySet() and Sold_To_AGN__c = true]){
                                                    if (!soldAccountMap.containsKey(ca.Child_Account_vod__c))
                                                        soldAccountMap.put(ca.Child_Account_vod__c, new set<ID>{ca.Parent_Account_vod__c});
                                                    else
                                                        soldAccountMap.get(ca.Child_Account_vod__c).add(ca.Parent_Account_vod__c);             
                                                }                                    
            }
            
            //check for ship to affiliation  
            if (!caseShipToMap.isEmpty()) {
                for(Child_Account_vod__c ca : [select id,Parent_Account_vod__c,Child_Account_vod__C from Child_Account_vod__c where Parent_Account_vod__c IN :caseShipToMap.values()  
                                               AND Child_Account_vod__c IN :caseShipToMap.keySet() and Ship_To_AGN__c = true ]){
                                                   if (!shipAccountMap.containsKey(ca.Child_Account_vod__c))
                                                       shipAccountMap.put(ca.Child_Account_vod__c, new set<Id>{ca.Parent_Account_vod__c});
                                                   else
                                                       shipAccountMap.get(ca.Child_Account_vod__c).add(ca.Parent_Account_vod__c);                                                     
                                                   
                                               }
            }
            
            
            for(Case c : lcase){
                
                if (c.ContactId != null){           
                    if (c.AccountId != null){
                        if(!soldAccountMap.containsKey(caseContactMap.get(c.ContactId)) || !soldAccountMap.get(caseContactMap.get(c.ContactId)).contains(c.AccountId)){             
                            c.AccountId.addError(Label.CaseInvalidSoldTo);
                        }
                    }
                    else if (c.Ship_To_Account_AGN__c != null){
                        if (!shipAccountMap.containsKey(caseContactMap.get(c.ContactId)) || !shipAccountMap.get(caseContactMap.get(c.ContactId)).contains(c.Ship_To_Account_AGN__c)){
                            c.Ship_To_Account_AGN__c.addError(Label.CaseInvalidShipTo);
                        }
                    }
                }
            }
        }                 
    }
    
    public static void closeMilestone( Map<Id, Case> caseOldValueMap , Map<Id, Case> caseNewValueMap ){
        
        List<CaseMilestone> mileStoneList = new List<CaseMilestone>();
        List<CaseMilestone> mileStoneListToUpdate = new List<CaseMilestone>();
        if (caseOldValueMap.keySet().size()>0){
            mileStoneList = [SELECT Id,
                             CaseId,
                             CreatedDate,
                             CompletionDate,
                             IsCompleted,
                             IsViolated,
                             StartDate,
                             TargetDate
                             FROM CaseMilestone WHERE CaseId IN:caseOldValueMap.keySet() AND IsCompleted = false
                             ORDER BY CreatedDate DESC];}
        
        map<Id, List<CaseMilestone>> caseIdRelatedMilestoneMap = new map<Id, List<CaseMilestone>>();
        if (mileStoneList!= Null){           
            for(CaseMilestone cm : mileStoneList){
                if(caseIdRelatedMilestoneMap.containsKey(cm.CaseId)){
                    caseIdRelatedMilestoneMap.get(cm.CaseId).add(cm);
                }else{
                    caseIdRelatedMilestoneMap.put(cm.CaseId, new List<CaseMilestone>{cm});
                }
            }
            for(Case c : caseOldValueMap.values() ){                
                if(c.Case_Step_Number_AGN__c < caseNewValueMap.get(c.Id).Case_Step_Number_AGN__c||
                   (c.Approval_Step_Number_AGN__c != caseNewValueMap.get(c.Id).Approval_Step_Number_AGN__c)||
                   (c.Status=='Pending Approval' &&  caseNewValueMap.get(c.Id).Status!='Pending Approval') ||
                   (caseNewValueMap.get(c.Id).OwnerId.getSobjectType()== Group.sObjectType && caseNewValueMap.get(c.Id).OwnerId != c.OwnerId)||
                   caseNewValueMap.get(c.Id).status== 'Closed'){                   
                       if(caseIdRelatedMilestoneMap.containsKey(c.Id)){
                           for(CaseMilestone cm: caseIdRelatedMilestoneMap.get(c.Id)){
                               Decimal diference = Decimal.ValueOf((DateTime.Now().getTime()/1000)-(cm.CreatedDate.getTime()/1000)).abs();
                               if(diference>5){
                                   cm.CompletionDate = DateTime.now();
                                   mileStoneListToUpdate.add(cm);
                               }
                           }
                       }
                   }   
            }
        }
        if(!mileStoneListToUpdate.isEmpty()){
            try{
                update mileStoneListToUpdate;
            }catch(Exception e){
                system.debug('Exception On Closing Milestone:: ' + e);
            }
        }
    }
    
    public static void updateCaseAfterApproval( Map<Id, Case> caseOldValueMap , Map<Id, Case> caseNewValueMap){
        
        List<Id> recordToUpdate = new List<Id>();
        
        for(case c : caseOldValueMap.values() ){
            /*Below Condition will check whether a record is leaving an approval process and getting assigned to a  queue (and only queue not any user), 
so that it sends the record to a future method for mocking the save/edit functionalilty to fire the milestone.  */                      
            
            if(c.Status=='Pending Approval' &&  caseNewValueMap.get(c.Id).Status!='Pending Approval' && 
               //c.OwnerId!=caseNewValueMap.get(c.Id).OwnerId &&
               c.Approval_Step_Number_AGN__c!= 0 &&
               caseNewValueMap.get(c.Id).Approval_Step_Number_AGN__c==0){
                   recordToUpdate.add(caseNewValueMap.get(c.Id).id);
               }                
            
        }
        if(!recordToUpdate.isEmpty()){
            updateCaseRecord(recordToUpdate);
        }
        
    }
    
    public static boolean inFutureContext = false;
    
    @future(callout=false)
    public static void updateCaseRecord( List<Id> recordToUpdate){
        
        List<Case> CaseRecordToUpdate = new List<Case>();
        for(id cId : recordToUpdate){
            case c = new case();
            c.Id=cId;
            //Set The Approval step number as 101 to bypass the validation rule m amd set the value to zero by workflow                 
            c.Approval_Step_Number_AGN__c=99;
            CaseRecordToUpdate.add(c);
        } 
        inFutureContext = true;
        if (!CaseRecordToUpdate.isEmpty())
            update CaseRecordToUpdate;        
    }
    
    public static void caseTeamSharing( Map<Id, Case> caseNewValueMap){
        List <CaseTeamMember> caseTeamList = new List <CaseTeamMember>();
        List <id> caseIdList = new List <id>();
        List <id> requesterIdList = new List <id>();
        Set <string> caseTeamIdSet = new Set <string>();
        Id TeamRoleId = [SELECT Id FROM CaseTeamRole WHERE AccessLevel = 'Read'].Id;
        
        for(Case c : caseNewValueMap.values() ) {
            caseIdList.add(c.id);
            requesterIdList.add(c.Sales_Rep_Requester_AGN__c);
        }
        
        List <CaseTeamMember> caseTeamExistingList = new List <CaseTeamMember> (
            [SELECT Id,MemberId,ParentId,TeamRoleId FROM CaseTeamMember 
             WHERE ParentId IN :caseIdList 
             AND MemberId IN :requesterIdList]);
        
        for(CaseTeamMember ctm : caseTeamExistingList ) {
            caseTeamIdSet.add(ctm.ParentId+'_'+ctm.MemberId);
        }
        
        for(Case c : caseNewValueMap.values()) {
            if(!caseTeamIdSet.contains(c.id+'_'+c.Sales_Rep_Requester_AGN__c)) {
                CaseTeamMember caseTeam = new CaseTeamMember();
                caseTeam.ParentId = c.Id;
                caseTeam.MemberId = c.Sales_Rep_Requester_AGN__c;
                caseTeam.TeamRoleId = TeamRoleId;
                if(!string.isblank(c.Sales_Rep_Requester_AGN__c))
                    caseTeamList.add(caseTeam);
            }
        }
        
        if(caseTeamList.size() > 0)
            insert caseTeamList;
    }
    
    public static void addAccountToCaseFromEmail(List<Case> newCases){
        
        Map<ID,String> rTypeMap = new Map<ID,String>();
        Map<String,ID> emailTemplateMap = new Map<String,ID>();
        Map<ID,String> userEmailMap = new Map<ID,String>();
        Map<ID,String> queueEmailMap = new Map<ID,String>();
        List<Account> accList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        Map<ID,ID> contactAccountMap = new Map<ID,ID>();
        List<Account> accToAdd = new List<Account>();
        List<String> caseEmailList = new List<String>();
        List<Case> email2CaseList = new List<Case>();
        List<Case> caseToUpdate = new List<Case>();
        List<Account> caseAccountList;
        Set<ID> accIdSet = new Set<ID>();
        Map<Id, List<Account>> caseAccountMap = new Map<Id,List<Account>>(); 
        List<String> emailAddressList;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //Added to resolve coolsculpting related error on user query : Too many query rows
        for(RecordType rType : [select Id, Name from RecordType where SObjectType = 'Case']){            
            rTypeMap.put(rType.Id, rType.Name);            
        }    
        for(EmailTemplate eTemp : [select Id, DeveloperName from EmailTemplate]){
            emailTemplateMap.put(eTemp.DeveloperName, eTemp.Id);
        }
        for(User u : [select Id, Email from User where isactive =true AND Profile.UserLicense.Name != 'Customer Community Login' ]){
            userEmailMap.put(u.Id, u.Email);
        }
        
        for(Group g : [select Id, Email from Group]){
            queueEmailMap.put(g.Id, g.Email);
        }
        
        try{
            /******* Create a List of Web Email IDs (Email IDs from where the Email has been sent) *******/
            /******* Create a List of Cases which have been created from Emails *******/ 
            for(Case c : newCases){
                if(c.Origin == 'Email-To-Case'){
                    if(c.AccountId == null){
                        caseEmailList.add(c.SuppliedEmail);
                        email2CaseList.add(c);
                    }                
                }
            }
            system.debug('@@ After first FOR() on Case. caseEmailList: ' + caseEmailList + '           |          email2CaseList: ' + email2CaseList);
            
            /******* Create a List of Accounts to which the sender Emails match *******/ 
            if(caseEmailList != null){
                accList = [select Id, PersonEmail, Email_Internal_AGN__c, Country_Code__c from Account where IsPersonAccount = true AND (PersonEmail in :caseEmailList OR Email_Internal_AGN__c in :caseEmailList)];
                for(Account accnt : accList){
                    accIdSet.add(accnt.Id);
                }
                /******* Create a List of Contacts for every Account in the accList *******/
                if(accIdSet != null){
                    contactList = [select Id, AccountId from Contact where AccountId in :accIdSet];
                    for(Contact c : contactList){
                        contactAccountMap.put(c.AccountId, c.Id);
                    }
                }
            }
            system.debug('@@ accList: ' + accList);
            
            if(email2CaseList != null){
                for(Case c : email2CaseList){
                    caseAccountList = new List<Account>();
                    
                    /******* Match the Case's sender's Email with the Account Email list to find the exact Account who had sent the Email *******/ 
                    if(accList != null){
                        for(Account acc : accList){
                            if(c.SuppliedEmail == acc.PersonEmail || c.SuppliedEmail == acc.Email_Internal_AGN__c){
                                caseAccountList.add(acc);
                            }
                        }                    
                    }
                    system.debug('@@ caseAccountList: ' + caseAccountList);
                    
                    /******* If Email is matched then update the Account field in Case *******/ 
                    if(caseAccountList.size() == 1){
                        caseAccountMap.put(c.Id, caseAccountList);    
                        system.debug('@@ caseAccountList.size() = 1     |     caseAccountMap: ' + caseAccountMap);
                    }else{
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        
                        /******* If Email is not matched or matched multiple times then send notification to Owner queue *******/ 
                        if(caseAccountList == null || caseAccountList.size() == 0){
                            system.debug('@@ caseAccountList.size() = 0');
                            mail.setTemplateId(emailTemplateMap.get('AGNEmail2CaseNotificationEmailNotMatched')); 
                            system.debug('@@ caseAccountList.size() = 0. TemplateId: ' + emailTemplateMap.get('AGNEmail2CaseNotificationEmailNotMatched'));
                        }else if(caseAccountList.size() > 1){
                            system.debug('@@ caseAccountList.size() > 1');
                            mail.setTemplateId(emailTemplateMap.get('AGNEmail2CaseNotifyMultipleEmailMatch'));
                            system.debug('@@ caseAccountList.size() > 1. TemplateId: ' + emailTemplateMap.get('AGNEmail2CaseNotifyMultipleEmailMatch'));
                            
                        }
                        emailAddressList = new List<String>();
                        if((String.valueOf(c.OwnerId)).left(3) == '00G'){
                            system.debug('@@ Owner is a Queue');
                            emailAddressList.add(queueEmailMap.get(c.OwnerId));
                            mail.setToAddresses(emailAddressList);
                            system.debug('@@ Queue Email Id: ' + emailAddressList);
                        }else if((String.valueOf(c.OwnerId)).left(3) == '005'){
                            system.debug('@@ Owner is an User');
                            emailAddressList.add(userEmailMap.get(c.OwnerId));
                            mail.setToAddresses(emailAddressList);
                            system.debug('@@ User Email Id: ' + emailAddressList);
                        }
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setTargetObjectId(c.CreatedById);
                        mail.setSenderDisplayName('Support');
                        mail.setWhatId(c.id);    
                        mail.setBccSender(false);
                        mail.setUseSignature(false);
                        mail.setSaveAsActivity(false);
                        emailList.add(mail);
                    }
                }
                if(emailList != null && emailList.size() > 0){
                    Messaging.sendEmail(emailList);
                }else if(caseAccountMap != null){
                    for(Case c : [select Id, AccountId, ContactId from Case where Id in :caseAccountMap.keySet()]){
                        accToAdd = caseAccountMap.get(c.Id);
                        //c.AccountId = accToAdd[0].Id;
                        c.ContactId = contactAccountMap.get(accToAdd[0].Id);
                        caseToUpdate.add(c);
                        system.debug('@@ accToAdd: ' + accToAdd + '        |        CaseId: ' + c.Id + '          |          c.ContactId: ' + c.ContactId + '        |        caseToUpdate: ' + caseToUpdate);
                        accToAdd.clear();
                    }
                    update caseToUpdate;   
                }
            }
        }catch(System.Exception e){
            system.debug('Exception Encountered: ' + e + '     |    Line Number: ' + e.getLineNumber());
        }
        
    }
    
    public static void caseSendAttachments(List<Case> newCases, List<Case> oldCases){
        
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        CoolSculpting_Setting_AGN__c csSettings = CoolSculpting_Setting_AGN__c.getOrgDefaults();        
        Map<Id, Messaging.SingleEmailMessage> mailMap = new Map<Id, Messaging.SingleEmailMessage>();        
        
        if(oldCases != null && oldCases.size() > 0){
            for(Case c : oldCases){
                oldCaseMap.put(c.Id, c);
            }
        }
        if(newCases != null && newCases.size() > 0){
            for(Case c : newCases){            
                if(!(oldCaseMap.get(c.Id)).Send_Attachment_Emails_CoolS_AGN__c && c.Send_Attachment_Emails_CoolS_AGN__c && !caseIdSet.contains(c.Id)){
                    caseIdSet.add(c.Id);
                }            
            }
        }
        
        if(!caseIdSet.isEmpty() && csSettings.Case_Attachment_Distribution_CoolS_AGN__c != null){
            
            List<Case> caseList = [SELECT Id, CaseNumber, Description, Subject, Account.Name, Contact.Name, Contact.Phone, Contact.Email, Owner.Name FROM Case WHERE Id IN :caseIdSet];
            
            Attachment[] caseAttachmentList = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :caseIdSet];
            
            Map<Id, SObject[]> attachmentsMap = new Map<Id, SObject[]>();
            
            for(Case c : caseList){
                if(!attachmentsMap.containsKey(c.Id))
                    attachmentsMap.put(c.Id, new SObject[]{});
                
                if(!mailMap.containsKey(c.Id))
                    mailMap.put(c.Id, new Messaging.SingleEmailMessage());
            }
            
            if(caseAttachmentList != null && caseAttachmentList.size() > 0){
                for(Attachment attachment : caseAttachmentList)
                    attachmentsMap.get(attachment.ParentId).add(attachment);
            }
            
            Map<Id, Messaging.EmailFileAttachment[]> attachmentFinal = new Map<Id, Messaging.EmailFileAttachment[]>();
            
            for(Case c : caseList){
                if(!attachmentFinal.containsKey(c.Id))
                    attachmentFinal.put(c.Id, new Messaging.EmailFileAttachment[]{});
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                email.setToAddresses(new String[]{csSettings.Case_Attachment_Distribution_CoolS_AGN__c});
                
                if((attachmentsMap.get(c.Id)) != null && (attachmentsMap.get(c.Id)).size() > 0){
                    for(SObject s : attachmentsMap.get(c.Id)){
                        Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                        try{
                            file.setFileName((String)s.get('Name'));
                            file.setBody((Blob)s.get('Body'));
                        }catch(Exception e){
                            System.debug(e.getMessage());
                        }
                        
                        attachmentFinal.get(c.Id).add(file);
                    }
                    email.setFileAttachments(attachmentFinal.get(c.Id));
                }
                email.setSubject(System.label.AGN_Case_Email_Attachment_Complaint_Number + c.CaseNumber + ': ' + c.Subject);
                
                email.setHtmlBody(System.label.AGN_Case_Email_Attachment_Name + c.Account.Name + '<br/>' + System.label.AGN_Case_Email_Attachment_Contact_Phone
                                  + c.Contact.Phone + '<br/>' + System.label.AGN_Case_Email_Attachment_Contact_Name + c.Contact.Name + '<br/>' + System.Label.AGN_Case_Email_Attachment_Contact_Email + c.Contact.Email + '<br/>' +System.Label.AGN_Case_Email_Attachment_Description + c.Description);
                email.setPlainTextBody(System.label.AGN_Case_Email_Attachment_Name + c.Account.Name + '<br/>' + System.label.AGN_Case_Email_Attachment_Contact_Phone
                                       + c.Contact.Phone + '<br/>' + System.label.AGN_Case_Email_Attachment_Contact_Name + c.Contact.Name + '<br/>' + System.Label.AGN_Case_Email_Attachment_Contact_Email + c.Contact.Email + '<br/>' +System.Label.AGN_Case_Email_Attachment_Description + c.Description);
                mailMap.put(c.Id, email);
            }
            
            if(!mailMap.values().isEmpty())
                Messaging.sendEmail(mailMap.values());    
        }
        
    }
    
     // R2 2020 Req No:3070:Same Email ID required for CoolSculpting Inbound and Outbound Emails
    public static void picklistFieldPopulate(List<Case> newCases){       
        try{
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        for(Case caseOb :newCases){
           if(String.isNotEmpty(caseOb.Account_Country_Code_AGN__c)){
               if(rt_map.get(caseOb.recordTypeID).getName().containsIgnoreCase('CoolSculpting')){
                caseOb.Country_Wise_Outbound_Email_AGN__c=caseOb.Account_Country_Code_AGN__c+'_'+'CoolSculpting';                
            }else{
                caseOb.Country_Wise_Outbound_Email_AGN__c=caseOb.Account_Country_Code_AGN__c;                
            }
          }
        }
          
        }catch(System.Exception e){
            system.debug('Exception Encountered: ' + e + '     |    Line Number: ' + e.getLineNumber());
        }
    }
    
}