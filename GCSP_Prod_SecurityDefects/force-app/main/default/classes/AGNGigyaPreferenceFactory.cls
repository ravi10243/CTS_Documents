/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class extends AGNGigyaConsentFactory
* and implements the preference mapping.
*/

public class AGNGigyaPreferenceFactory extends AGNGigyaConsentFactory {

	public override Boolean setConsent(String userId, String preferenceId, Boolean subscribed, Datetime consentDatetime, Map<String, String> extraFields, List<String> tags) {
		System.debug('setConsent||' + preferenceId);

		String allTags = '';
		if (tags != null && tags.size() > 0) {
			for (String tag : tags) {
				allTags += tag + ',';
			}
			allTags = allTags.substring(0, allTags.length() - 1);
		}

		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setAccountInfo');
		url.addParameter('UID', userId);
		url.addParameter('preferences', '{\'' + preferenceId + '\' : {\'isConsentGranted\' : ' + subscribed + ', \'tags\' : \'' + allTags + '\'}}');
		if (extraFields != null) {
			for (String key : extraFields.keySet()) {
				url.addParameter(key, extraFields.get(key));
			}
		}
		HttpResponse response = url.execute();
		return true;
	}

	public override Boolean channelUpdated(String accountId, String oldChannel, String newChannel) {
		String uid = AGNGigyaRESTAccount.searchUserId(accountId, null, null);
		if (AGNGigyaRESTHelper.isEmptyString(uid)) {
			return false;
		}

		for (AGNGigyaConsent gigyaConsent : this.getListByAccountId(accountId)) {
			if (gigyaConsent.channel == oldChannel) {
				this.setConsent(gigyaConsent.userId, gigyaConsent.getGigyaConsentId(), false, Datetime.now(), null, null);
			}
		}

		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setAccountInfo');
		url.addParameter('UID', uid);
		url.addParameter('profile', '{\'phones\' : [{\'number\' : \'' + newChannel + '\'}]}');

		HttpResponse response = url.execute();
		AGNGigyaMCConsentUtil.optOutAllConsents(accountId, oldChannel);
		return true;
	}

	public override void channelDeleted(String accountId, String channel) {
		this.channelUpdated(accountId, channel, '');
		AGNGigyaMCConsentUtil.optOutAllConsents(accountId, channel);
	}

	public override String getConsentId(Multichannel_Consent_vod__c mcConsent) {
		Consent_Header_vod__c header = [
		SELECT Id, Country_vod__r.Name, Language_vod__c
		FROM Consent_Header_vod__c
		WHERE Id = :mcConsent.Consent_Type_vod__r.Consent_Header_vod__c
		];
        //Cognizant- CC - Line Number - 68
        if(Schema.sObjectType.Consent_Header_vod__c.fields.Language_vod__c.isAccessible()){
            return AGNGigyaConsent.getGigyaConsentIdName(mcConsent.Consent_Type_vod__r.RecordType.DeveloperName, header.Country_vod__r.Name, header.Language_vod__c);
        }
		return null;
	}

	public override String getConsentIdFromConsentName(String userId, Multichannel_Consent_vod__c mcConsent) {
		return getConsentId(mcConsent);
	}

	public override List<Object> getLastUpdated(String timestamp) {
		String query = 'SELECT UID, data.SFDCId, data.MDM_ID_AGN__c, profile.phones, email, data.External_ID_vod__c, preferences, lastUpdatedTimestamp FROM accounts ';
		query += 'WHERE lastUpdatedTimestamp > ' + timestamp + ' ';
		query += 'AND preferences IS NOT NULL ';
		query += 'ORDER BY lastUpdatedTimestamp DESC ';
		if (timestamp != null && timestamp.length() > 1) {
			query += 'LIMIT 10000 ';
		} else {
			query += 'LIMIT 100 ';
		}

		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
		url.addParameter('query', query);

		HttpResponse response = url.execute();
		List<String> uids = new List<String>();
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> r = (List<Object>) m.get('results');
		return r;
	}

	public List<AGNGigyaConsent> getListByUserObject(Map<String, Object> user, Boolean includeTags) {
		List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
		Map<String, Object> profile = (Map<String, Object>) user.get('profile');
		Map<String, Object> data = (Map<String, Object>) user.get('data');
		Map<String, Object> preferences = (Map<String, Object>) user.get('preferences');
		if (preferences != null) {
			Set<String> preferencesKeys = preferences.keySet();
			try {
				for (String key : preferencesKeys) {
					Map<String, Object> preferenceCountries = (Map<String, Object>) preferences.get(key);
					for (String countryKey : preferenceCountries.keySet()) {
						Map<String, Object> preferenceLanguages = (Map<String, Object>) preferenceCountries.get(countryKey);
						for (String languageKey : preferenceLanguages.keySet()) {
							Map<String, Object> preference = (Map<String, Object>) preferenceLanguages.get(languageKey);
							AGNGigyaConsent gse = new AGNGigyaConsent();
							gse.consentId = key;
							gse.profile = profile;
							gse.data = data;
							gse.userId = String.valueOf(user.get('UID'));
							gse.updatedDate = (String) preference.get('lastConsentModified');
							if (profile != null) {
								List<Object> phones = (List<Object>) profile.get('phones');
								String phonesString = '';
								if (phones != null) {
									for (Object phone : phones) {
										phonesString += String.valueOf(phone) + ', ';
									}
									gse.phones = phonesString.substring(8, phonesString.length() - 3);
								}
							}
							gse.isSubscribed = (Boolean) preference.get('isConsentGranted');
							gse.isSubscription = false;
							gse.country = countryKey;
							gse.language = languageKey;
							if (PHONE_CHANNELS.indexOf(gse.consentId) >= 0) {
								gse.channel = gse.phones;
								gse.channelName = 'phone';
							}
							if (includeTags != null && includeTags) {
								//gse.tags = getTagsFromAudit(gse);
								gse.tags = getTagsFromGigyaPreference(preference);
							}
							result.add(gse);
						}
					}
				}
			} catch (TypeException e) {
				System.debug('TypeException|' + e);
			}
		}
		return result;
	}

	public override List<AGNGigyaConsent> getListByUserObject(Map<String, Object> user) {
		return getListByUserObject(user, true);
	}

	public List<String> getTagsFromAudit(AGNGigyaConsent gse) {
		if (gse == null) {
			return null;
		}

		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('audit.search');
		url.addParameter('query', 'SELECT * FROM auditLogEvents WHERE uid = \'' + gse.userId + '\' AND path=\'' + gse.getGigyaConsentId() + '\' AND tags LIKE \'Consent User%\' ORDER BY @timestamp DESC LIMIT 1');

		try {
			HttpResponse response = url.execute();
			Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			List<String> tags = new List<String>();
			List<Object> rAll = (List<Object>) m.get('results');
			System.debug(rAll);
			for (Object resultObject : rAll) {
				Map<String, Object> result = (Map<String, Object>) resultObject;

				List<Object> tagsObject = (List<Object>) result.get('tags');
				if (tagsObject != null) {
					for (Object tagObject : tagsObject) {
						tags.add(String.valueOf(tagObject));
					}
				}
			}
			return tags;
		} catch(Exception e) {
			System.debug(e);
		}
		return null;
	}

	public List<String> getTagsFromGigyaPreference(Map<String, Object> preference) {
		if (preference == null) {
			return null;
		}

		System.debug('preference|' + preference);
		List<String> preferenceTagsString = new List<String>();
		if (preference != null) {
			List<Object> preferenceTags = (List<Object>) preference.get('tags');
			System.debug('preferenceTags|' + preferenceTags);
			if (preferenceTags != null) {
				for (Object o : preferenceTags) {
					preferenceTagsString.add(String.valueOf(o));
				}
			}
		}
		return preferenceTagsString;
	}

	public override List<AGNGigyaConsent> getListByAccountId(String accountId) {
		List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
		url.addParameter('query', 'SELECT UID, profile, data, preferences FROM accounts WHERE SFDCId=\''+accountId+'\' AND preferences IS NOT NULL');

		HttpResponse response = url.execute();
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> rAll = (List<Object>) m.get('results');
		for (Object userObject : rAll) {
			Map<String, Object> user = (Map<String, Object>) userObject;
			result.addAll(getListByUserObject(user));
		}
		return result;
	}

	/* this method is used to update gigya accounts with new fields */
	public List<AGNGigyaConsent> getListToUpdate(String createdTimestamp) {
		if (createdTimestamp == null) {
			createdTimestamp = '0';
		}
		List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
		url.addParameter('query', 'SELECT UID, profile, data, preferences ' +
		'FROM accounts ' +
		'WHERE createdTimestamp >= ' + Long.valueOf(createdTimestamp) + ' ' +
		'AND preferences IS NOT NULL ' +
		'ORDER BY createdTimestamp ASC ' +
		'LIMIT 3000 '
		);

		HttpResponse response = url.execute();
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> rAll = (List<Object>) m.get('results');
		for (Object userObject : rAll) {
			Map<String, Object> user = (Map<String, Object>) userObject;
			result.addAll(getListByUserObject(user, true));
		}
		return result;
	}

	public override Boolean cleanSchema(String preferenceId) {
		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setSchema');
		url.addParameter('preferencesSchema', '{\'fields\' : { \''+ preferenceId + '\' : {\'description\' : \'null\', \'type\' : \'null\', \'required\' : null, \'currentDocVersion\' : 1.0}}}');
		HttpResponse response = url.execute();
		return true;
	}

	public override Boolean exists(String preferenceId) {
		for (AGNGigyaPreferenceSchema preference : getAllSchemas()) {
			if (preference.preferenceId == preferenceId) {
				return true;
			}
		}
		return false;
	}

	public override String getGigyaUserId(String accountId, String emailAddress, String externalId) {
		return AGNGigyaRESTAccount.searchUserId(accountId, externalId, null);
	}

	public override Boolean setSchema(String preferenceId, String description) {
		description = description.replace('&', 'and');
		String schema = '{\'fields\' : { ' +
		' \''+ preferenceId + '\' : {' +
		' \'description\' : \'' + description + '\', ' +
		' \'type\' : \'consent\', ' +
		' \'currentDocVersion\' : 1.0, ' +
		' \'minDocVersion\' : 1.0, ' +
		' \'required\' : false, ' +
		' \'writeAccess\' : \'clientModify\' ' +
		' }' +
		'}}';
		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setSchema');
		url.addParameter('preferencesSchema', schema);
		HttpResponse response = url.execute();
		return true;
	}

	public static List<AGNGigyaPreferenceSchema> getAllSchemas() {
		AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.getSchema');
		HttpResponse response = url.execute();
		String content = response.getBody();
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
		Map<String, Object> ss = (Map<String, Object>) m.get('preferencesSchema');
		Map<String, Object> preferences = (Map<String, Object>) ss.get('fields');

		List<AGNGigyaPreferenceSchema> result = new List<AGNGigyaPreferenceSchema>();

		Set<String> keys = preferences.keySet();
		for (String key : keys) {
			Map<String, Object> preference = (Map<String, Object>) preferences.get(key);
			AGNGigyaPreferenceSchema gse = new AGNGigyaPreferenceSchema();
			gse.description = (String) preference.get('description');
			gse.type = (String) preference.get('type');
			gse.required = (Boolean) preference.get('required');
			gse.currentDocVersion = (Decimal) preference.get('currentDocVersion');
			gse.preferenceId = key;
			result.add(gse);
		}
		return result;
	}
}