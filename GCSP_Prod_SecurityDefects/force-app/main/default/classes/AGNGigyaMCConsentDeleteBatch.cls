/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* Main class istantiated by AGNMCConsentTrigger events
*/

global class AGNGigyaMCConsentDeleteBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	private Integer totalCount = 0;
	private List<Multichannel_Consent_vod__c> mcConsentsDeleted = new List<Multichannel_Consent_vod__c>();
	private List<Multichannel_Consent_vod__c> mcConsents = new List<Multichannel_Consent_vod__c>();
	private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();

	global AGNGigyaMCConsentDeleteBatch(List<Multichannel_Consent_vod__c> mcConsentsDeleted){
		this.mcConsentsDeleted = mcConsentsDeleted;
	}

	global List<Multichannel_Consent_vod__c> start(Database.BatchableContext batchableContext){
		System.debug('mcConsentsDeleted|' + mcConsentsDeleted);
		Set<Id> consentTypesId = new Set<Id>();
		Set<Id> contentTypesId = new Set<Id>();
		for (Multichannel_Consent_vod__c mcConsent : mcConsentsDeleted) {
			consentTypesId.add(mcConsent.Consent_Type_vod__c);
			contentTypesId.add(mcConsent.Content_Type_vod__c);
		}
		Map<Id, Consent_Type_vod__c> consentTypes = new Map<Id, Consent_Type_vod__c>([
		SELECT Id, Consent_Header_vod__c, RecordType.DeveloperName
		FROM Consent_Type_vod__c
		WHERE Id =: consentTypesId
		]);
		Map<Id, Content_Type_vod__c> contentTypes = new Map<Id, Content_Type_vod__c>([
		SELECT Id, External_Id_vod__c, RecordType.DeveloperName
		FROM Content_Type_vod__c
		WHERE Id =: contentTypesId
		]);
		for (Multichannel_Consent_vod__c mcConsentDeleted : mcConsentsDeleted) {
			Multichannel_Consent_vod__c mcConsent = mcConsentDeleted.clone();
			mcConsent.Consent_Type_vod__r = consentTypes.get(mcConsent.Consent_Type_vod__c);
			mcConsent.Content_Type_vod__r = contentTypes.get(mcConsent.Content_Type_vod__c);
			mcConsents.add(mcConsent);
		}
		return mcConsents;
	}

	global void execute(Database.BatchableContext batchableContext, List<Multichannel_Consent_vod__c> mcConsents) {
		executeOptOut(mcConsents);
	}

	global void executeOptOut(List<Multichannel_Consent_vod__c> mcConsents) {
		totalCount = totalCount + mcConsents.size();
		for (Multichannel_Consent_vod__c mcConsent : mcConsents) {
			try {
				Consent_Type_vod__c ct = [SELECT Consent_Header_vod__c, RecordType.DeveloperName FROM Consent_Type_vod__c WHERE Id = :mcConsent.Consent_Type_vod__c];
				AGNGigyaConsentFactory consentFactory = AGNGigyaConsentFactory.getFactory(ct.RecordType.DeveloperName);
				String gigyaUID = consentFactory.getGigyaUserId(mcConsent.Account_vod__c, mcConsent.Channel_Value_vod__c, mcConsent.Account_vod__r.External_ID_vod__c);
				if (gigyaUID == null || gigyaUID.length() < 1) {
					System.debug('gigyaUID not found');
					System.debug(mcConsent.Account_vod__c + '|' + mcConsent.Channel_Value_vod__c + '|' + mcConsent.Account_vod__r.External_ID_vod__c);
					return;
				}
				System.debug('gigyaUID|' + gigyaUID);

				Consent_Header_vod__c header = [
				SELECT Id, Country_vod__r.Name, Language_vod__c
				FROM Consent_Header_vod__c
				WHERE Id = :ct.Consent_Header_vod__c
				];
				String consentId = consentFactory.getConsentId(mcConsent);
				System.debug('consentFactory|' + consentFactory);
				System.debug('consentId|' + consentId);
				//String consentId = AGNGigyaConsent.getGigyaConsentIdName(ct.RecordType.DeveloperName, header.Country_vod__r.Name, header.Language_vod__c);
				if (consentFactory.exists(consentId)) {
					Boolean subscribed = false;
					List<String> tags = new List<String>();
					tags.add(mcConsent.Id);
					Map<String, String> extraFields = new Map<String, String>();
					Boolean rb = consentFactory.setConsent(gigyaUID, consentId, subscribed, mcConsent.Capture_Datetime_vod__c, extraFields, tags);
				}
			} catch(AGNGigyaValidationException e) {
				e.errorDetail = e.errorDetail + '|mcconsent:' + mcConsent.Id + '|account:' + mcConsent.Account_vod__c;
				validationExceptions.add(e);
			}
		}
	}

	global void finish(Database.BatchableContext batchableContext){
		if(!validationExceptions.isEmpty()){
			AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
			System.debug('>>> EXCEPTION <<<');
			System.debug(validationExceptions[0]);
			throw validationExceptions[0];
		} else{
			AGNInterfacePublishEvent.logBatchApex(batchableContext,totalCount);
		}
	}
}