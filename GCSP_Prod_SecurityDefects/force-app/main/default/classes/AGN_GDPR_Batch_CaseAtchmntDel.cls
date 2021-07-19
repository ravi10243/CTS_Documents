global class AGN_GDPR_Batch_CaseAtchmntDel implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date currentDate = Date.today();
        AGN_GDPR_Record_Archive_Information__c gdprSettings = AGN_GDPR_Record_Archive_Information__c.getInstance();
        Date daysBack = currentDate-((Integer)gdprSettings.Case_Attachment_deletion_days_AGN__c);
        
        String CaseQuery ='SELECT Id,CreatedDate,RecordTypeId,RecordType.Name FROM Case '+
            'WHERE RecordType.Name in (\'CCPA Case\',\'GDPR Case\') AND createdDate =:daysBack';
        Set<Id> casesId=new Set<Id>();
        List<Case> cases = Database.query(CaseQuery);
        for(Case c : cases)
        {
            casesId.add(c.id);
        }
        System.debug('casesId.size(): '+casesId.size());
        String AttachmentQuery='SELECT Id,Name,ParentId FROM Attachment WHERE ParentId in: casesId';
        return Database.getQueryLocator(AttachmentQuery);
    }
    
    global void execute(Database.BatchableContext BC,List<Attachment> attachments)
    {
        try
        {
            delete attachments;
            System.debug('Attachments deleted succesfully');
        }
        catch(Exception e){
            System.debug('Error message: '+e.getMessage()+'\nError cause: '+e.getCause()+'\nLine number: '+e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddress = new List<String>();
        toAddress.add('DL-InternationApplicationSupport@allergan.com');
        email.setToAddresses(toAddress);
        email.setSubject('Successfully Batch Completed');
        email.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '
                               + a.NumberOfErrors + ' failures. AsyncApexJob id is '+ a.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        System.debug('Attachment removed Sucessfully');
    }
    
}