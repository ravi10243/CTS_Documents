/**
* --------------
* Allergan GDPR
* November 2018
* --------------
* This Batch class retrieves accounts from Gigya EPM
* gets the corresponding accounts in Veeva
* and push in Gigya the updated fields
* ************************************************************************************
* ALERT! This class cannot work because a Gigya issue: tags are stored in Gigya Audit
* 				but only if the consent status changes!
* ************************************************************************************
* It is executed one time to push in Gigya new Veeva preference fields for existing HCP.
*/
public class AGNGigyaPreferenceUpdateNewFieldsBatch implements Database.Batchable<AGNGigyaConsent>, Database.AllowsCallouts, Database.Stateful {
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
	private Map<String, Multichannel_Consent_vod__c> consentsMap = new Map<String, Multichannel_Consent_vod__c>();
	private Integer totalCount = 0;
	private AGNGigyaPreferenceFactory preferenceFactory = new AGNGigyaPreferenceFactory();
	private String externalLastSyncUpdatedTimestamp = '';
	private String lastSyncUpdatedTimestampRecord = '';

	public AGNGigyaPreferenceUpdateNewFieldsBatch(String externalLastSyncUpdatedTimestamp) {
		this.externalLastSyncUpdatedTimestamp = externalLastSyncUpdatedTimestamp;
	}
	public List<AGNGigyaConsent> start(Database.BatchableContext batchableContext) {
		List<AGNGigyaConsent> l = this.preferenceFactory.getListToUpdate(externalLastSyncUpdatedTimestamp);
		Set<Id> consentIds = new Set<Id>();
		for (AGNGigyaConsent gigyaConsent : l) {
			String consentId = getMCConsentId(gigyaConsent);
			if (consentId != null) {
				consentIds.add(consentId);
			}
		}
		Multichannel_Consent_vod__c[] consents = [SELECT Id, Consent_User_Type_AGN__c,
		Consent_Type_vod__c, Consent_Type_vod__r.Channel_Label_vod__c,
		Capture_Datetime_vod__c, CreatedBy.Name
		FROM Multichannel_Consent_vod__c WHERE Id IN :consentIds
		];
		for (Multichannel_Consent_vod__c consent : consents) {
			consentsMap.put(consent.Id, consent);
		}

		return l;
		//return null;
	}

	/**
	* max callouts = batch size
	* batch size = ???
	*/
	public void execute(Database.BatchableContext batchableContext, List<AGNGigyaConsent> gigyaConsents) {
		totalCount += gigyaConsents.size();
		System.debug('working on ' + gigyaConsents.size() + ' gigyaConsents');
		System.debug('++++ gigyaConsents|' + gigyaConsents);
		for (AGNGigyaConsent gigyaConsent : gigyaConsents) {
			lastSyncUpdatedTimestampRecord = gigyaConsent.updatedDate;
			Multichannel_Consent_vod__c mcConsent = null;
			String mcconsentId = getMCConsentId(gigyaConsent);
			if (!String.isBlank(mcconsentId)) {
				mcConsent = consentsMap.get(mcconsentId);
			}
			System.debug('mcConsent|' + mcConsent);
			if (mcConsent != null) {
				System.debug('gigyaConsent|' + gigyaConsent);
				List<String> tags = new List<String>();
				tags.add(mcConsent.Id);
				tags.add('Consent User Type:' + mcConsent.Consent_User_Type_AGN__c);
				if (mcConsent.Consent_Type_vod__c != null && mcConsent.Consent_Type_vod__r.Channel_Label_vod__c != null) {
					tags.add('Consent Type - Channel Label:' + mcConsent.Consent_Type_vod__r.Channel_Label_vod__c);
				}
				if (mcConsent.Capture_Datetime_vod__c != null) {
					tags.add('Consent Capture Datetime:' + mcConsent.Capture_Datetime_vod__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
				}
				tags.add('Consent Created By:' + mcConsent.CreatedBy.Name);
				System.debug('++++ tags|' + tags);
				try {
					System.debug('D002 - consent process - consent updated|'+ gigyaConsent.userId + '|' + mcconsentId);
					preferenceFactory.setConsent(gigyaConsent.userId, gigyaConsent.getGigyaConsentId(), gigyaConsent.isSubscribed, mcConsent.Capture_Datetime_vod__c, null, tags);
				} catch(AGNGigyaValidationException e) {
					e.errorDetail = e.errorDetail + '|mcConsent: ' + mcConsent + '|gigyaUID: ' + String.valueOf(gigyaConsent.userId);
					validationExceptions.add(e);
				}
			}
		}
	}

	public void finish(Database.BatchableContext batchableContext){
		System.debug('this.lastSyncUpdatedTimestampRecord|' + this.lastSyncUpdatedTimestampRecord);
		if(!validationExceptions.isEmpty()) {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
			System.debug('>>> EXCEPTION <<<');
			System.debug(validationExceptions[0]);
			throw validationExceptions[0];
		} else {
			AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
		}
	}

	private Boolean isValidId(String id) {
		return !String.isEmpty(id) && (id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id);
	}

	private String getMCConsentId(AGNGigyaConsent gigyaConsent) {
		if (gigyaConsent.tags != null) {
			for (String tag : gigyaConsent.tags) {
				if (isValidId(tag)) {
					System.debug('++++ mcconsent id tag ' + tag + ' found');
					return tag;
				}
			}
		}
		return null;
	}
}