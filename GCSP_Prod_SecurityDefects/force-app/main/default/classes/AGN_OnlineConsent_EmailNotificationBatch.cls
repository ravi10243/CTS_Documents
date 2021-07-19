/*
* This batch class is used to send email notifications to MCC records that was created by Consent Portal.
* Since the portal profile was not available in org wide addresses to send email notifications, this approach
* taken so that the context user could be sys admin instead of guest profile. 
*/
public class AGN_OnlineConsent_EmailNotificationBatch implements Database.Batchable<sObject>{
	
   	public Database.QueryLocator start(Database.BatchableContext BC){
   		Id consentUserId;
   		
   		AGN_OnlineConsent_Info__c info = AGN_OnlineConsent_Info__c.getValues('Consent Info');
   		Datetime dt = info.Last_Batch_Run__c;
   		
   		System.debug('time stamped*** '+dt);
   		
   		if(Test.isRunningTest())
   		{
   			consentUserId = UserInfo.getUserId();
   		}
   		else
   		{
   			consentUserId = [Select Id from User where Name = :Label.OnlineConsent_User_Name_AGN].Id;   		
   		}
   		
   		System.debug('user Id ***** '+consentUserId);
        
        //Quering those MCC records that was created by portal guest user.
   		String query = 'Select Id, Email_Notification_For_Portal_AGN__c from Multichannel_Consent_vod__c where CreatedById = :consentUserId and Capture_Datetime_vod__c >= :dt and Email_Notification_For_Portal_AGN__c = false';   	
      	return Database.getQueryLocator(query);
   	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope){
        //System.debug('scope: '+scope);
        
        List<Multichannel_Consent_vod__c> updateConsents = new List<Multichannel_Consent_vod__c>();
        for(Multichannel_Consent_vod__c con : (List<Multichannel_Consent_vod__c>)scope){
            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Email_Notification_For_Portal_AGN__c.isUpdateable()){ //cc_AD
               con.Email_Notification_For_Portal_AGN__c = true; 
            }
            updateConsents.add(con);
        }
        
        System.debug('updateConsents: '+updateConsents.size());
		if(updateConsents != null && updateConsents.size() > 0)
		{	
			//the custom setting records the last batch run time stamp.
		 	AGN_OnlineConsent_Info__c info = AGN_OnlineConsent_Info__c.getValues('Consent Info');
            if(Schema.sObjectType.AGN_OnlineConsent_Info__c.fields.Last_Batch_Run__c.isCreateable() && Schema.sObjectType.AGN_OnlineConsent_Info__c.fields.Last_Batch_Run__c.isUpdateable()){  //cc_AD
                info.Last_Batch_Run__c = System.now();
            }
            if(Schema.sObjectType.AGN_OnlineConsent_Info__c.isCreateable() && Schema.SObjectType.AGN_OnlineConsent_Info__c.isUpdateable()){ //cc_AD
                upsert info;
            }
   			     
            if(Schema.SObjectType.Multichannel_Consent_vod__c.isUpdateable()){ //cc_AD
                update updateConsents;
            }
		 	     	
		}
    }

   	public void finish(Database.BatchableContext BC){
   		
   	}
}