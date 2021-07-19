/**
* --------------
* Allergan GDPR
* November 2018
* --------------
* This Batch class retrieves notifications from Gigya Notifications Datastore
* gets the corresponding account in Veeva
* and push in Gigya the updated fields
*
* It is executed one time to push in Gigya new Veeva account fields for existing HCP.
*/
public class AGNGigyaNotificationUpdateNewFieldsBatch implements Database.Batchable<AGNGigyaNotification>, Database.AllowsCallouts, Database.Stateful {
	private static AGN_GIGYA_REST_API__c gigyaSettings = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
	private Map<String, Account> accountsMap = new Map<String, Account>();
	private Integer totalCount = 0;
	private String lastSync = '';
	private String externalLastSyncCreatedTimestamp = '';
	//private Datetime externalLastSyncCreatedDatetime = '';
	private String lastSyncCreatedTimestampRecord = '';
	private Datetime syncStartDatetime;

	public AGNGigyaNotificationUpdateNewFieldsBatch() {
	}
	public AGNGigyaNotificationUpdateNewFieldsBatch(String externalLastSyncCreatedTimestamp) {
		this.externalLastSyncCreatedTimestamp = externalLastSyncCreatedTimestamp;
	}
	public List<AGNGigyaNotification> start(Database.BatchableContext batchableContext) {
		this.syncStartDatetime = System.now();
		String lastSync = null;
		if (externalLastSyncCreatedTimestamp != null) {
			lastSync = externalLastSyncCreatedTimestamp;
		} else {
			lastSync = gigyaSettings.AGN_Last_NotificationNF_Sync_datetime__c;
		}

		List<AGNGigyaNotification> l = AGNGigyaRESTNotification.getNotificationsToUpdate(lastSync);

		Set<Id> accountIds = new Set<Id>();
		for (AGNGigyaNotification obj : l) {
			if (isValidId(obj.getSFDCId())) {
				accountIds.add(obj.getSFDCId());
			}
		}

		Account[] accounts = [SELECT Id, FirstName, LastName, PersonEmail, Country_Name_AGN__c, Status_AGN__c,
		Additional_Status_AGN__c, Email_Internal_AGN__c, External_ID_vod__c, External_ID2_AGN__c, Middle_vod__c,
		Specialty_Allergan_1_AGN__r.Name, Sub_Specialty_Allergan_AGN__r.Name, Email_Sent_Date_AGN__c,
		Country_vod__r.Name, Specialty_1_AGN__r.Name, Specialty_2_AGN__r.Name, Salutation, Privacy_Law_Status_AGN__c
		FROM Account WHERE Id IN :accountIds
		];
		for (Account account : accounts) {
			accountsMap.put(account.Id, account);
		}
		return l;
	}

	/**
	* max callouts = batch size
	* batch size = 100
	*/
	public void execute(Database.BatchableContext batchableContext, List<AGNGigyaNotification> gigyaNotifications) {
		totalCount += gigyaNotifications.size();
		for (AGNGigyaNotification gigyaNotification : gigyaNotifications) {
			System.debug('-- oid|' + gigyaNotification.getOid());
			System.debug('-- working on gigyaNotification|' + gigyaNotification);
			lastSyncCreatedTimestampRecord = gigyaNotification.getCreatedTimestamp();
			Account account = accountsMap.get(gigyaNotification.getSFDCId());
			if (account != null) {
				List<String> dataFieldsToEmpty = new List<String>();
				AGNgigyaNotification newGigyaNotification = AGNGigyaMCConsentUtil.getNewGigyaNotification(gigyaNotification, account, dataFieldsToEmpty);
				try {
					if (newGigyaNotification.isUpdated() || dataFieldsToEmpty.size() > 0) {
						System.debug('D003 - notification process - notification updated|' + newGigyaNotification);
						AGNGigyaRESTNotification.setNotification(newGigyaNotification, dataFieldsToEmpty);
					}
				} catch(AGNGigyaValidationException e) {
					e.errorDetail = e.errorDetail + '|account: ' + account + '|gigyaUID: ' + String.valueOf(gigyaNotification.getUserId());
					validationExceptions.add(e);
				}
			}
		}
	}

	public void finish(Database.BatchableContext batchableContext){
		if (!String.isBlank(this.externalLastSyncCreatedTimestamp)) {
			System.debug('this.lastSyncCreatedTimestampRecord|' + this.lastSyncCreatedTimestampRecord);
		} else {
            //Cognizant- CC - Line Number - 90
            if(Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_NotificationNF_Sync_datetime__c.isAccessible() && Schema.SobjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_NotificationNF_Sync_datetime__c.isupdateable()){
            	gigyaSettings.AGN_Last_NotificationNF_Sync_datetime__c = this.lastSyncCreatedTimestampRecord;
            }
			
			update gigyaSettings;
		}
		if(!validationExceptions.isEmpty()) {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
			System.debug('>>> EXCEPTION <<<');
			System.debug(validationExceptions[0]);
			//throw validationExceptions[0];
		} else {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
		}
	}

	private Boolean isValidId(String id) {
		return !String.isEmpty(id) && (id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id);
	}
}