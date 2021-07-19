/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* Abstract factory class for consent REST calls.
* According to Gigya specs, consent can be either subscription and preference.
*/

public abstract class AGNGigyaConsentFactory {
    public Boolean emailBased = false;
    public static final List<String> EMAIL_BASED_CONSENTS = AGNGigyaMCConsentUtil.getEmailBasedConsents();
    public static final List<String> PHONE_CHANNELS = AGNGigyaMCConsentUtil.getPhoneChannels();
    public static final List<String> PHONE_CHANNEL_SOURCES = AGNGigyaMCConsentUtil.getPhoneChannelSources();
    public static Map<String, String> EMAIL_CONTENT_MAPPING = AGNGigyaMCConsentUtil.getContentTypeExtId_GigyaConsentIdMapping();
    private static final String TURKEY_COUNTRY_CODE = 'TR';

    public static List<Id> ENABLED_CONSENT_HEADERS_IDS = new List<Id>();

    static {
				Set<String> ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getConsentCountryCodes();
        //adding turkey code, we will include only records in cyprus
    		ENABLED_COUNTRIES_CODES.add(TURKEY_COUNTRY_CODE);

        //TODO what if something changes? does the ID change?
        List<Consent_Header_vod__c> chTemp = [SELECT Id FROM Consent_Header_vod__c
        WHERE Status_vod__c = 'Active_vod'
        AND Country_vod__r.Alpha_2_Code_vod__c IN :ENABLED_COUNTRIES_CODES];

        for (Consent_Header_vod__c ch : chTemp) {
            ENABLED_CONSENT_HEADERS_IDS.add(ch.Id);
        }
    }

    private static AGNGigyaPreferenceFactory preferenceFactory = new AGNGigyaPreferenceFactory();
    private static AGNGigyaSubscriptionFactory subscriptionFactory = new AGNGigyaSubscriptionFactory();

    public static AGNGigyaConsentFactory getFactory(String consentTypeRecordTypeDevName) {
        if (EMAIL_BASED_CONSENTS.indexOf(consentTypeRecordTypeDevName) >= 0) {
            AGNGigyaSubscriptionFactory obj = new AGNGigyaSubscriptionFactory();
            obj.emailBased = true;
            return obj;
        } else {
            return new AGNGigyaPreferenceFactory();
        }
    }
    public static AGNGigyaConsentFactory getFactory(AGNGigyaConsent gigyaConsent) {
        if (gigyaConsent.isSubscription) {
            AGNGigyaSubscriptionFactory obj = new AGNGigyaSubscriptionFactory();
            obj.emailBased = true;
            return obj;
        } else {
            return new AGNGigyaPreferenceFactory();
        }
    }

    public static List<AGNGigyaConsent> getConsentsByAccountId(String accountId) {
        List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
        result.addAll(subscriptionFactory.getListByAccountId(accountId));
        result.addAll(preferenceFactory.getListByAccountId(accountId));
        return result;
    }

    public static List<Object> getLastUpdatedConsents(String timestamp) {
        List<Object> result = new List<Object>();
        result.addAll(subscriptionFactory.getLastUpdated(timestamp));
        result.addAll(preferenceFactory.getLastUpdated(timestamp));
        return result;
    }

    public static List<AGNGigyaConsent> getSubscriptionsPreferences(Map<String, Object> user) {
        List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
        result.addAll(subscriptionFactory.getListByUserObject(user));
        result.addAll(preferenceFactory.getListByUserObject(user));
        return result;
    }

    public abstract String getConsentId(Multichannel_Consent_vod__c mcConsent);

    public abstract String getConsentIdFromConsentName(String userId, Multichannel_Consent_vod__c mcConsent);

    public abstract Boolean channelUpdated(String accountId, String oldChannel, String newChannel);

    public abstract void channelDeleted(String accountId, String channel);

    public abstract List<AGNGigyaConsent> getListByAccountId(String accountId);

    public abstract String getGigyaUserId(String accountId, String emailAddress, String externalId);

    public abstract List<AGNGigyaConsent> getListByUserObject(Map<String, Object> user);

    public abstract List<Object> getLastUpdated(String timestamp);

    public abstract Boolean setSchema(String schemaId, String description);

    public abstract Boolean setConsent(String userId, String consentId, Boolean subscribed, Datetime consentDatetime, Map<String, String> extraFields, List<String> tags);

    public abstract Boolean cleanSchema(String preferenceId);

    public abstract Boolean exists(String preferenceId);
}