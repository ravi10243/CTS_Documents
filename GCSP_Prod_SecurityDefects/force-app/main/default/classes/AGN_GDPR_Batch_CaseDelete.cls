global class AGN_GDPR_Batch_CaseDelete implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date currDate = Date.today();
        AGN_GDPR_Record_Archive_Information__c gdprSettings = AGN_GDPR_Record_Archive_Information__c.getInstance();
        Date yearsBack = currDate-((Integer)gdprSettings.Case_deletion_days_AGN__c);
        System.debug('currDate: '+currDate+' yearsBack: '+yearsBack);
        String Casequery = 'SELECT Id,CaseNumber,Person_First_Name_GDPR_AGN__c,RecordTypeId,RecordType.Name FROM Case '+
            'WHERE RecordType.Name in (\'CCPA Case\',\'GDPR Case\') AND Status = \'Closed\' AND ClosedDate <: yearsBack';
        return Database.getQueryLocator(Casequery);
    }
    global void execute(Database.BatchableContext BC,List<Case> cases){
        try{
            System.debug('cases.size(): '+cases.size());
            delete cases;
            System.debug('Cases Sucessfully deleted');
        }
        catch(Exception e){
            System.debug('Error message: '+e.getMessage()+'\nError cause: '+e.getCause()+'\nLine number: '+e.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}