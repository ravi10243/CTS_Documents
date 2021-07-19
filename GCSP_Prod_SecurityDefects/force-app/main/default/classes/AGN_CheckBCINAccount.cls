/*****************************************************************************************************************************************************************
Apex  Class- AGN_ContractExhibitNotificationBatch
Description- This class checks if any of the email address(irrespective of contract language) in AGN_GDPR_Notify_Contract_Exhibit__c for which the GDPR status is not success,
				is already present in Account, then update AGN_GDPR_Email_Notification_Status__c as success so that no email is triggered for such records	
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/


public with sharing class AGN_CheckBCINAccount {
    public static Set<String> accountEmailSet;
    public static void updateContractExhibit(){
		try{
        	//Check if any of the customer signer email exists in Account. If yes, then mark the GDPR status as Success
            accountEmailSet= (AGN_findAccountEmailSet.findEmailSet());
            Set<Id> bcId= new Set<ID>();
            for(AGN_GDPR_Notify_Contract_Exhibit__c updateGDPR: [Select AGN_Customer_Signer_Email__c,AGN_Contract_Language__c,AGNEmailLang__c,AGN_BC_Name__c,AGN_Email_Template_Name__c 
                                                           from AGN_GDPR_Notify_Contract_Exhibit__c where AGN_GDPR_Email_Notification_Status__c!='Success']){
                boolean isEmail= AGN_findAccountEmailSet.ifEmailExists(updateGDPR.AGN_Customer_Signer_Email__c,accountEmailSet);
                 if(isEmail){
                    bcId.add(updateGDPR.id); 
                 }   
                }
            accountEmailSet=null;
            List<AGN_GDPR_Notify_Contract_Exhibit__c> updateBCList= new List<AGN_GDPR_Notify_Contract_Exhibit__c>();
            for(AGN_GDPR_Notify_Contract_Exhibit__c updateBCGDPRStatus: [SELECT AGNEmailLang__c,AGN_Contract_Language__c,AGN_Customer_Signer_Email__c,AGN_Email_Received_Date__c,AGN_Email_Sent_Date__c,AGN_GDPR_Email_Notification_Status__c 
                                                                         FROM AGN_GDPR_Notify_Contract_Exhibit__c where id in :bcId]){
             //AG FLS create check
              if(Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.fields.AGN_GDPR_Email_Notification_Status__c.isUpdateable()){                                                              
               	updateBCGDPRStatus.AGN_GDPR_Email_Notification_Status__c='Success';
               }                                                             
               	updateBCList.add(updateBCGDPRStatus);                                                             
            }
           if(Schema.sObjectType.AGN_GDPR_Notify_Contract_Exhibit__c.isUpdateable()){
              update updateBCList;
            }
        } Catch(Exception ex){
            System.debug('Exception Message'+ex.getMessage());
       }
    }
}