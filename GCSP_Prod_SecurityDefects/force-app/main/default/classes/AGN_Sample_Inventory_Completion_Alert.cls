/*R15 PMO 1975-12: Scheduler Class written in order to notify user if Sample Inventory is not submitted for more than 90 days */ 

global class AGN_Sample_Inventory_Completion_Alert implements Schedulable{
    List<Sample_Inventory_vod__c> smpl_invntry_list = new List <Sample_Inventory_vod__c>();
    List<Sample_Transaction_vod__c> smpl_trnsctn_list = new List <Sample_Transaction_vod__c>();
    Set<Id> smpl_invntry_idSet = new Set<Id>();
    Set<Id> smpl_trnsctn_idSet = new Set<Id>();
    List<User> UsrList = new List<User>();
    List<String> UsrEmailList = new List<String>();
    
    global void execute(SchedulableContext sc){
        sendEmail();
    }

/* sendEmail() sends email to set of users who haven't submitted sample inventory of more than 90 days*/ 
    
    public void sendEmail(){
        smpl_invntry_list = [SELECT Id,Name,Submitted_Date_vod__c,CreatedById FROM Sample_Inventory_vod__c 
                             WHERE Submitted_Date_vod__c >: Date.today() - 90];
        System.debug('## smpl_invntry_list -> '+smpl_invntry_list);
        for(Sample_Inventory_vod__c smpl_invntry : smpl_invntry_list){
            smpl_invntry_idSet.add(smpl_invntry.CreatedById);
        }
        System.debug('## smpl_invntry_idSet -> '+smpl_invntry_idSet);
        smpl_trnsctn_list = [SELECT Id,Name,Transfer_To_vod__c FROM Sample_Transaction_vod__c
                             WHERE Transfer_To_vod__c NOT in: smpl_invntry_idSet AND RecordType.Name =: 'Transfer_vod'];
        System.debug('## smpl_trnsctn_list -> '+smpl_trnsctn_list);
        for(Sample_Transaction_vod__c smpl_trnsctn : smpl_trnsctn_list){
            if(smpl_trnsctn.Transfer_To_vod__c != Null){
                smpl_trnsctn_idSet.add(smpl_trnsctn.Transfer_To_vod__c);
            }
        }
        System.debug('## smpl_trnsctn_idSet -> '+smpl_trnsctn_idSet);
        UsrList = [SELECT Email,Id,Name FROM User WHERE id in : smpl_trnsctn_idSet AND IsActive =: TRUE];
        system.debug('## UserList check '+UsrList);
        for (User Usr : UsrList){
            UsrEmailList.add(Usr.Email);
        }
        system.debug('## UsrEmailList -> '+UsrEmailList);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setBccAddresses(UsrEmailList);
        email.setSubject(Label.AGN_Sample_Inventory_Notify_Email_Subject);
        email.setPlainTextBody(Label.AGN_Dear_User + '\n\n' + Label.AGN_Sample_Inventory_Notify_Email_Body 
                               + '\n\n' + Label.Best_Regards + '\n**' + Label.Do_Not_Reply + '**');
        system.debug('## emailMessages check -> '+email);
        Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        system.debug('## Messaging.sendEmail(emailMessages) method ran successfully ');
    }
}