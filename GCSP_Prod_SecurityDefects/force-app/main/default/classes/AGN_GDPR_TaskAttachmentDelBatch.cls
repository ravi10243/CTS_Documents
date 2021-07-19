global class AGN_GDPR_TaskAttachmentDelBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date currentDate = Date.today();
        AGN_GDPR_Record_Archive_Information__c gdprSettings = AGN_GDPR_Record_Archive_Information__c.getInstance();
        Date daysBack = currentDate-((Integer)gdprSettings.Case_Attachment_deletion_days_AGN__c);
        //String UId = '0051j000001SIoE';
        
        String InactiveUser = 'SELECT Id,ContactId from User where IsActive = false and LastModifiedDate = :daysBack';
        List<User> Users = Database.query(InactiveUser);
        Set<Id> UserConId=new Set<Id>();
        for(User u : Users)
        {
            UserConId.add(u.ContactId);
        }
        System.debug('Number of Inactive users are: '+UserConId.size());
        String CaseQuery ='SELECT Id,CreatedDate,RecordTypeId,RecordType.Name FROM Case '+
            'WHERE RecordType.Name in (\'CCPA Case\',\'GDPR Case\') AND ContactId in :UserConId AND Currently_Accessible_AGN__c = false';
        Set<Id> casesId=new Set<Id>();
        List<Case> cases = Database.query(CaseQuery);
        for(Case c : cases)
        {
            casesId.add(c.id);
        }
        System.debug('casesId.size(): '+casesId.size());
        String CaseTask = 'SELECT Id,Name,Related_to_GDPR_AGN__c,Status_GDPR_AGN__c FROM Business_Owner_Task_GDPR_AGN__c WHERE Related_to_GDPR_AGN__c =:casesId AND Status_GDPR_AGN__c =\'Completed\'';
        List<Business_Owner_Task_GDPR_AGN__c> Tasks = Database.query(CaseTask);
        Set<Id> TasksId=new Set<Id>();
        for(Business_Owner_Task_GDPR_AGN__c T : Tasks)
        {
            TasksId.add(T.id);
        }
        System.debug('Tasks are: '+TasksId.size());
        String ConDocLnk = 'SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in :TasksId';
        List<ContentDocumentLink> ConDocLink = Database.query(ConDocLnk);
        Set<Id> ConDocID = new Set<Id>();
        for(ContentDocumentLink objConDoc : ConDocLink)
        {
                ConDocID.add(objConDoc.ContentDocumentId);
        }
        String ConDoc = 'SELECT Id,Title,createdDate FROM ContentDocument WHERE Id in :ConDocID';
        //List<ContentDocument> ConDocu = Database.query(ConDoc);
        //String ConDocVersion = 'SELECT Id, ContentDocumentId, FileExtension FROM ContentVersion where ContentDocumentId in : ConDocu.Id and IsLatest = true';
        //String AttachmentQuery='SELECT Id,Name,ParentId FROM Attachment WHERE ParentId in: casesId'; */
        return Database.getQueryLocator(ConDoc);
    }
    
    global void execute(Database.BatchableContext BC,List<ContentDocument> ConDocu)
    {
        try
        {
            delete ConDocu;
            System.debug('Task Attachments are deleted succesfully');
        }
        catch(Exception e){
            System.debug('Error message: '+e.getMessage()+'\nError cause: '+e.getCause()+'\nLine number: '+e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}