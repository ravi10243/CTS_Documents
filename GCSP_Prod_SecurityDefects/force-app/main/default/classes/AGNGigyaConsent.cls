/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* Consent Value Object
*/

public class AGNGigyaConsent {
	public String consentId {get; set;}
	public String country {get; set;}
	public String language {get; set;}
	public String updatedDate {get; set;}
	public String userId {get; set;}
	public Boolean isSubscribed {get; set;}
	public Boolean isSubscription {get; set;}
	public String email {get; set {
			email = String.escapeSingleQuotes(value);
	}}
	public String channel {get; set;}
	public String channelName {get; set;}
	public String phones {get; set;}
	public String externalId {get; set;}
	public String externalId2 {get; set;}
	public String countryCode {get; set;}
	public String countryName {get; set {
			countryName = String.escapeSingleQuotes(value).replace('&', '%26');
	}}
	public String salutation {get; set;}
	public String status {get; set {
			status = String.escapeSingleQuotes(value).replace('&', '%26');
	}}
	public String additionalStatus {get; set {
			additionalStatus = String.escapeSingleQuotes(value).replace('&', '%26');
	}}
	public String specialty1 {get; set {
			specialty1 = String.escapeSingleQuotes(value).replace('&', '%26');
	}}
	public String specialty2 {get;  set {
			specialty2 = String.escapeSingleQuotes(value).replace('&', '%26');
	}}
	public Map<String, Object> rawData {get; set;}
	public Boolean gdprDeleteFlag {get; set;}
	public List<String> tags {get; set;}
	public String gigyaConsentId {get; set;}
	public Map<String, Object> profile {get; set;}
	public Map<String, Object> data {get; set;}

	public AGNGigyaConsent() {
		profile = new Map<String, Object>();
		data = new Map<String, Object>();
	}

	public void setConsentId(String consentId) {
		this.consentId = consentId;
		setGigyaConsentId();
	}
	public void setCountry(String country) {
		this.country = country;
		setGigyaConsentId();
	}
	public void setLanguage(String language) {
		this.language = language;
		setGigyaConsentId();
	}

	private void setGigyaConsentId() {
		gigyaConsentId = getGigyaConsentIdName(consentId, country, language);
	}

	public String getGigyaConsentId() {
		return getGigyaConsentIdName(consentId, country, language);
	}

	public static String getGigyaConsentIdName(String consent, String country, String language) {
		String res = consent;
		String temp = AGNGigyaConsentFactory.EMAIL_CONTENT_MAPPING.get(consent);
		if (!String.isEmpty(temp)) {
			res = temp;
		}
		if (country != null && country.length() > 0) {
			res += '.' + country.replace(' ', '_');
		}
		if (language != null && language.length() > 0) {
			res += '.' + language.replace(' ', '_').replace('-', '_');
		}
		return res;
	}

}