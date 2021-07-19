global class AGN_UPDATE_ACCOUNT_DIRECT_MAIL_DE_PROF implements Database.Batchable<sObject>
{   
     global Database.QueryLocator start(Database.BatchableContext bc) 
     {
         String query='SELECT GDPR_Notification_Status_AGN__c from Account where country_vod__r.name=\'DE\' and RecordType.Name=\'Professional_vod\' and GDPR_Notification_Status_AGN__c=null ';
         return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<Account> scope) 
    {
        List<Account> gdprStatusMailList= new List<Account>();
        for(Account acc:scope)
        {
            acc.GDPR_Notification_Status_AGN__c='Ready to Send for Direct Mail';
            gdprStatusMailList.add(acc);
        }
        Update gdprStatusMailList;
        
    }
 
    global void finish(Database.BatchableContext bc) 
    {
        system.debug('Reached Finish** ');
        
    }
}