public class AGN_CExhibitGigyaNotificationRetrBatch  implements Database.Batchable<AGNGigyaNotification>, Database.AllowsCallouts, Database.Stateful {
	private static AGN_GIGYA_REST_API__c gigyaSettings = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
	private List<AGN_GDPR_Notify_Contract_Exhibit__c> notifyCExhibitsToUpdate = new List<AGN_GDPR_Notify_Contract_Exhibit__c>();
	private Datetime syncStartDatetime;

	public List<AGNGigyaNotification> start(Database.BatchableContext batchableContext){
		this.syncStartDatetime = System.now();

		Datetime lastSync = gigyaSettings.AGN_Last_CENotificationRet_Sync_DateTime__c;
		String lastSyncString = lastSync == null ? '' : String.valueOf(lastSync.getTime());
		Schema.DescribeSObjectResult r = AGN_GDPR_Notify_Contract_Exhibit__c.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
		return AGNGigyaRESTNotification.getAllNotificationsStartWith(lastSyncString, keyPrefix);
	}

	public void execute(Database.BatchableContext batchableContext, List<AGNGigyaNotification> gigyaNotifications){
		Map<Id, AGN_GDPR_Notify_Contract_Exhibit__c> gigyaVeevaNotifyCExhibits = new Map<Id, AGN_GDPR_Notify_Contract_Exhibit__c>();
		List<String> populatedFields = new List<String>();
		for(AGNGigyaNotification gigyaNotification : gigyaNotifications) {
			try {
				// If we already have the notifyCExhibit in the map, skip it
				System.debug('gigyaNotification.getSfdcId()=' + gigyaNotification.getSfdcId());
				if(String.isEmpty(gigyaNotification.getSfdcId())) continue;
				if(gigyaVeevaNotifyCExhibits.containsKey(gigyaNotification.getSfdcId())) continue;

				// Any fields set on gigyaVersionOfNotifyCExhibits are later used to query Veeva's version of the notifyCExhibit
				// This is done dynamically, using the populatedFields variable, to make sure that when the notifCEs
				// are compared using hash codes, we are comparing the exact same fields
				AGN_GDPR_Notify_Contract_Exhibit__c gigyaVersionOfNotifyCExhibits = new AGN_GDPR_Notify_Contract_Exhibit__c(
				AGN_GDPR_Email_Notification_Received__c = gigyaNotification.isNotificationReceived(),
				AGN_GDPR_Email_Notification_Status__c   = gigyaNotification.getNotificationStatus(),
				Id                                = gigyaNotification.getSfdcId()
				);
				gigyaVeevaNotifyCExhibits.put(gigyaVersionOfNotifyCExhibits.Id, gigyaVersionOfNotifyCExhibits);

				// If we haven't added the fields yet, then add them - this will happen with the first notifyCExhibit
				if(populatedFields.isEmpty() && gigyaVersionOfNotifyCExhibits.getPopulatedFieldsAsMap().size() > 1) {
					populatedFields.addAll(gigyaVersionOfNotifyCExhibits.getPopulatedFieldsAsMap().keySet());
				}
			} catch(AGNGigyaValidationException e) {
				e.errorDetail = e.errorDetail + '|gigyaNotification:' + String.valueOf(gigyaNotification);
				validationExceptions.add(e);
			}
		}

		if(populatedFields.isEmpty()) return;

		for(AGN_GDPR_Notify_Contract_Exhibit__c notifyCExhibit : (List<AGN_GDPR_Notify_Contract_Exhibit__c>)Database.query(this.getNotifyCExhibitQuery(populatedFields, gigyaVeevaNotifyCExhibits))) {
			AGN_GDPR_Notify_Contract_Exhibit__c gigyaVersionOfNotifyCExhibits = gigyaVeevaNotifyCExhibits.get(notifyCExhibit.Id);

			// If the notifCE have different hash codes, then we need to update Veeva
			if(System.hashCode(gigyaVersionOfNotifyCExhibits) != System.hashCode(notifyCExhibit)) {
				notifyCExhibitsToUpdate.add(gigyaVersionOfNotifyCExhibits);
			}
		}
	}

	public void finish(Database.BatchableContext batchableContext){
		System.debug('updating ' + notifyCExhibitsToUpdate.size() + ' records');
		update notifyCExhibitsToUpdate;
        //Cognizant- CC - Line Number - 63
		if(Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_CENotificationRet_Sync_DateTime__c.isAccessible() && Schema.SobjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_CENotificationRet_Sync_DateTime__c.isupdateable()){
            gigyaSettings.AGN_Last_CENotificationRet_Sync_DateTime__c = this.syncStartDatetime;
        } 		
		update gigyaSettings;
		if(!validationExceptions.isEmpty()){
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, notifyCExhibitsToUpdate.size());
		} else {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, notifyCExhibitsToUpdate.size());
		}
	}


	private String getNotifyCExhibitQuery(List<String> populatedFields, Map<Id, AGN_GDPR_Notify_Contract_Exhibit__c> gigyaVeevaNotifyCExhibits) {
		List<Id> notifyCExhibitIds = new List<Id>(gigyaVeevaNotifyCExhibits.keySet());
		String notifyCExhibitIdString = '\'' + String.join(notifyCExhibitIds, '\',\'') + '\'';

		// We dynamically generate the query string to make sure we query for the exact same fields that are mapped from Gigya
		String q = 'SELECT ' + String.join(populatedFields, ', ') + ' FROM AGN_GDPR_Notify_Contract_Exhibit__c WHERE Id IN (' + notifyCExhibitIdString + ')';
		System.debug('query=' + q);
		return q;
	}

}