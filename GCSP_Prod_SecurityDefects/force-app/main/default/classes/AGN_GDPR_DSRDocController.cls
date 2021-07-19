public class AGN_GDPR_DSRDocController {
	// public Account account {get;}

	//public Id accountId {get;set;}
	public Account account {get;set;}
	public Multichannel_Consent_vod__c marketingEmailConsent {get;set;}
	public Multichannel_Consent_vod__c marketingPhoneConsent {get;set;}
	public Multichannel_Consent_vod__c tovConsent {get;set;}
	public Multichannel_Consent_vod__c allerganEventConsent {get;set;}
	public Multichannel_Consent_vod__c nonAllerganEventConsent {get;set;}
	public Call2_vod__c lastCall {get;set;}
	public Event_Attendee_vod__c lastMeeting {get;set;}

	public AGN_GDPR_DSRDocController() {
		Id accountId = apexpages.currentpage().getparameters().get('accountId');
		account = [SELECT Name, FirstName, LastName, PersonEmail, Email_Internal_AGN__c,
		Language_vod__c, GDPR_Notification_Status_AGN__c, External_ID_vod__c
		FROM Account
		where Id = :accountId];

		// retrieving consents
		try {
			marketingEmailConsent = [
			SELECT Id, Capture_Datetime_vod__c, Opt_Type_vod__c
			FROM Multichannel_Consent_vod__c
			WHERE Account_vod__c = :accountId
			AND Consent_Type_vod__r.RecordType.DeveloperName = 'Approved_Email_vod'
			ORDER BY CreatedDate DESC LIMIT 1
			];
		} catch (Exception e) {
		}
		try {
			marketingPhoneConsent = [
			SELECT Id, Capture_Datetime_vod__c, Opt_Type_vod__c
			FROM Multichannel_Consent_vod__c
			WHERE Account_vod__c = :accountId
			AND Consent_Type_vod__r.RecordType.DeveloperName = 'Phone_AGN'
			ORDER BY CreatedDate DESC LIMIT 1
			];
		} catch (Exception e) {
		}
		try {
			tovConsent = [
			SELECT Id, Capture_Datetime_vod__c, Opt_Type_vod__c
			FROM Multichannel_Consent_vod__c
			WHERE Account_vod__c = :accountId
			AND RecordType.DeveloperName = 'TOV_AGN'
			ORDER BY CreatedDate DESC LIMIT 1
			];
		} catch (Exception e) {
		}
		try {
			allerganEventConsent = [
			SELECT Id, Capture_Datetime_vod__c, Opt_Type_vod__c
			FROM Multichannel_Consent_vod__c
			WHERE Account_vod__c = :accountId
			AND Consent_Type_vod__r.RecordType.DeveloperName = 'Allergan_Event_AGN'
			ORDER BY CreatedDate DESC LIMIT 1
			];
		} catch (Exception e) {
		}
		try {
			nonAllerganEventConsent = [
			SELECT Id, Capture_Datetime_vod__c, Opt_Type_vod__c
			FROM Multichannel_Consent_vod__c
			WHERE Account_vod__c = :accountId
			AND Consent_Type_vod__r.RecordType.DeveloperName = 'Non_Allergan_Event_AGN'
			ORDER BY CreatedDate DESC LIMIT 1
			];
		} catch (Exception e) {
		}

		// retrieving the last call
		try {
			lastCall = [
			SELECT Id, Call_Datetime_vod__c
			FROM Call2_vod__c
			where Account_vod__c = :accountId
			ORDER BY Call_Datetime_vod__c DESC
			LIMIT 1
			];
		} catch (Exception e) {
		}

		// retrieving the last meeting
		try {
			lastMeeting = [
			SELECT Id, CreatedDate
			FROM Event_Attendee_vod__c
			where Account_vod__c = :accountId
			ORDER BY CreatedDate DESC
			LIMIT 1
			];
		} catch (Exception e) {
		}
	}
}