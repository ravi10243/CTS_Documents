global class AGN_AMI_Password_Reminder_Batch implements Database.Batchable<sObject>
{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Integer days = integer.valueof(system.label.AGN_AMI_Password_Reminder_Days);
        query = 'SELECT id, profile.name, LastPasswordChangeDate,AMI_Password_Reminder_Send_Date__c ' 
            + 'FROM User ' 
            + 'where LastPasswordChangeDate>=last_n_days:' + days 
            + ' and LastPasswordChangeDate<last_n_days:' + (days -1) 
            + ' and (Contact.Is_AMI_Contact_AGN__c = true or Account.AGN_AMI_Enabled__c = true )';
        
        /* query = 'SELECT id, profile.name, LastPasswordChangeDate,AMI_Password_Reminder_Send_Date__c ' 
            + 'FROM User ' 
            + 'where Email=\'\' '
            + ' and (Contact.Is_AMI_Contact_AGN__c = true or Account.AGN_AMI_Enabled__c = true )';*/
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch)
    {
        triggerEmail(batch);
    }
    global void finish(Database.BatchableContext BC) 
    { 
        
    }
    public void triggerEmail(List<sObject> batch)
    {
        List<user> userList = (List<user>)batch;
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AGN_AMI_Password_Reminder' limit 1];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();        
        for(user u : userList)
        {       
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setTargetObjectId(u.Id);            
            mail.setTemplateId(template.Id); 
            mail.setBccSender(false); 
            mail.setUseSignature(false); 
            mail.setSenderDisplayName('AMI Sender'); 
            mail.setSaveAsActivity(false); 
            u.AMI_Password_Reminder_Send_Date__c=system.Now();//CR 3747
            mailList.add(mail);           
             
        }         
        Messaging.sendEmail(mailList, true);
        if(userList.size()>0){
        	update userList; //CR 3747     
        }
    }
}