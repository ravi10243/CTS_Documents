/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class extends AGNGigyaConsentFactory and implements the subscription mapping
*/

public class AGNGigyaSubscriptionFactory extends AGNGigyaConsentFactory {
    
    public override Boolean setConsent(String userId, String subscriptionId, Boolean subscribed, Datetime consentDatetime, Map<String, String> extraFields, List<String> tags) {
        String consentDatetimeString = consentDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        
        String allTags = '\'null\'';
        if (tags != null && tags.size() > 0) {
            allTags = JSON.serialize(tags);
        }
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setAccountInfo');
        url.addParameter('UID', userId);
        url.addParameter('subscriptions', '{\'' + subscriptionId + '\' : {\'email\' : {\'isSubscribed\' : \'' + subscribed + '\', \'tags\' : ' + allTags + '}}}');
        if (extraFields != null) {
            for (String key : extraFields.keySet()) {
                url.addParameter(key, extraFields.get(key));
            }
        }
        HttpResponse response = url.execute();
        return true;
    }
    
    public override List<Object> getLastUpdated(String timestamp) {
        String query = 'SELECT UID, data.SFDCId, email, data.External_ID_vod__c, data.MDM_ID_AGN__c, lastUpdatedTimestamp, subscriptions FROM emailAccounts ';
        query += 'WHERE lastUpdatedTimestamp > ' + timestamp + ' ';
        //query += 'AND subscriptions IS NOT NULL ';
        query += 'ORDER BY lastUpdatedTimestamp DESC ';
        if (timestamp != null && timestamp.length() > 1) {
            query += 'LIMIT 10000';
        } else {
            query += 'LIMIT 100';
        }
        
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', query);
        
        HttpResponse response = url.execute();
        List<String> uids = new List<String>();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        return r;
    }
    
    public override Boolean channelUpdated(String accountId, String oldChannel, String newChannel) {
        String uid = AGNGigyaRESTAccount.searchUserId(accountId, null, oldChannel);
        System.debug('uid|' + uid);
        if (AGNGigyaRESTHelper.isEmptyString(uid)) {
            return false;
        }
        
        for (AGNGigyaConsent gigyaConsent : this.getListByAccountId(accountId)) {
            System.debug('gigyaConsent|' + gigyaConsent);
            if (gigyaConsent.channel == oldChannel) {
                this.setConsent(gigyaConsent.userId, gigyaConsent.getGigyaConsentId(), false, Datetime.now(), null, null);
            }
        }
        
        String uidNew = AGNGigyaRESTAccount.getUserIdByEmailOrUsername(newChannel);
        if (AGNGigyaRESTHelper.isEmptyString(uidNew)) {
            AGNGigyaAccount account = new AGNGigyaAccount();
            account.setUserId(uid);
            account.setEmail(newChannel);
            account.setUsername(newChannel);
            AGNGigyaRESTAccount.setAccountInfo(account);
            AGNGigyaMCConsentUtil.optOutAllConsents(accountId, oldChannel);
            return true;
        } else {
            throw new AGNGigyaValidationException(-11, 'Username/Email address already present in Gigya', 'email:' + newChannel + ' GigyaUID:' + uidNew);
        }
    }
    
    public override void channelDeleted(String accountId, String channel) {
        for (AGNGigyaConsent gigyaConsent : this.getListByAccountId(accountId)) {
            if (gigyaConsent.channel == channel) {
                this.setConsent(gigyaConsent.userId, gigyaConsent.getGigyaConsentId(), false, Datetime.now(), null, null);
                //AGNGigyaRESTAccount.deleteAccount(gigyaConsent.userId);
            }
        }
        AGNGigyaMCConsentUtil.optOutAllConsents(accountId, channel);
    }
    
    public override String getConsentId(Multichannel_Consent_vod__c mcConsent) {
        Consent_Header_vod__c header = [
            SELECT Id, Country_vod__r.Name, Language_vod__c
            FROM Consent_Header_vod__c
            WHERE Id = :mcConsent.Consent_Type_vod__r.Consent_Header_vod__c
        ];
        if (!String.isEmpty(mcConsent.Content_Type_vod__r.External_Id_vod__c)) {
            if(Schema.sObjectType.Consent_Header_vod__c.fields.Language_vod__c.isAccessible()){//If clause added by Cognizant team for FLS issues//
                   
                   return AGNGigyaConsent.getGigyaConsentIdName(mcConsent.Content_Type_vod__r.External_Id_vod__c, header.Country_vod__r.Name, header.Language_vod__c);
               }
            else{//Extra Else clause added by Cognizant team for corresponding If clause in context of FLS issues//
                return null;
            }
        } else {
            if(Schema.sObjectType.Consent_Header_vod__c.fields.Language_vod__c.isAccessible()){ //If clause added by Cognizant team for FLS issues//  
                   return AGNGigyaConsent.getGigyaConsentIdName(mcConsent.Consent_Type_vod__r.RecordType.DeveloperName, header.Country_vod__r.Name, header.Language_vod__c);
               }
            else{//Extra Else clause added by Cognizant team for corresponding If clause in context of FLS issues//
                return null;
            }
        }
    }
    
    public override String getConsentIdFromConsentName(String userId, Multichannel_Consent_vod__c mcConsent) {
        String consentName = AGNGigyaConsentFactory.EMAIL_CONTENT_MAPPING.get(mcConsent.Content_Type_vod__r.External_Id_vod__c);
        
        List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'SELECT subscriptions FROM emailAccounts WHERE UID=\''+userId+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> rAll = (List<Object>) m.get('results');
        
        if (rAll.size() > 0) {
            Map<String, Object> gigyaUser = (Map<String, Object>) rAll[0];
            Map<String, Object> subscriptions = (Map<String, Object>) gigyaUser.get('subscriptions');
            Set<String> keys = subscriptions.keySet();
            for (String key : keys) {
                if (key.startsWithIgnoreCase(consentName)) {
                    return key;
                }
            }
        }
        return null;
    }
    
    public override List<AGNGigyaConsent> getListByUserObject(Map<String, Object> user) {
        List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
        Map<String, Object> profile = (Map<String, Object>) user.get('profile');
        Map<String, Object> data = (Map<String, Object>) user.get('data');
        Map<String, Object> subscriptions = (Map<String, Object>) user.get('subscriptions');
        if (subscriptions != null) {
            Set<String> keys = subscriptions.keySet();
            for (String key : keys) {
                Map<String, Object> temp = (Map<String, Object>) subscriptions.get(key);
                Map<String, Object> subscription = (Map<String, Object>) temp.get('email');
                AGNGigyaConsent gse = new AGNGigyaConsent();
                gse.profile = profile;
                gse.data = data;
                gse.userId = String.valueOf(user.get('UID'));
                gse.email = String.valueOf(user.get('email'));
                gse.channel = String.valueOf(user.get('email'));
                gse.channelName = 'email';
                gse.updatedDate = (String) subscription.get('lastUpdatedSubscriptionState');
                gse.isSubscribed = (Boolean) subscription.get('isSubscribed');
                gse.isSubscription = true;
                String[] temp2 = key.split('\\.');
                if (temp2.size() != 3) {
                    System.debug('consent Id not valid for preference |' + key);
                    continue;
                }
                gse.consentId = temp2[0];
                gse.country = temp2[1];
                gse.language = temp2[2];
                gse.tags = getTagsFromGigyaAccount(user, gse.getGigyaConsentId());
                gse.rawData = user;
                result.add(gse);
            }
        }
        return result;
    }
    
    public override List<AGNGigyaConsent> getListByAccountId(String accountId) {
        List<AGNGigyaConsent> result = new List<AGNGigyaConsent>();
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'SELECT UID, email, data, profile, subscriptions FROM emailAccounts WHERE data.SFDCId=\''+accountId+'\'');
        HttpResponse response = url.execute();
        System.debug('accountId|' + accountId);
        System.debug('query|' + 'SELECT UID, email, data, profile, subscriptions FROM emailAccounts WHERE data.SFDCId=\''+accountId+'\'');
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
        url.addParameter('query', 'SELECT UID, profile, data, subscriptions ' +
                         'FROM emailAccounts ' +
                         'WHERE createdTimestamp >= ' + Long.valueOf(createdTimestamp) + ' ' +
                         'ORDER BY createdTimestamp ASC ' +
                         'LIMIT 3000 '
                        );
        
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> rAll = (List<Object>) m.get('results');
        for (Object userObject : rAll) {
            Map<String, Object> user = (Map<String, Object>) userObject;
            result.addAll(getListByUserObject(user));
        }
        return result;
    }
    
    public override Boolean cleanSchema(String subscriptionId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setSchema');
        url.addParameter('subscriptionsSchema', '{\'fields\' : { \''+ subscriptionId + '\' : {\'description\' : \'null\', \'type\' : \'null\', \'required\' : null, \'doubleOptIn\' : null}}}');
        HttpResponse response = url.execute();
        return true;
    }
    
    public override String getGigyaUserId(String accountId, String emailAddress, String externalId) {
        return AGNGigyaRESTAccount.searchUserId(accountId, externalId, emailAddress);
    }
    
    public override Boolean exists(String subscriptionId) {
        for (AGNGigyaSubscriptionSchema subscription : getAllSchemas()) {
            if (subscription.subscriptionId == subscriptionId) {
                return true;
            }
        }
        return false;
    }
    
    public override Boolean setSchema(String subscriptionId, String description) {
        description = description.replace('&', 'and');
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setSchema');
        url.addParameter('subscriptionsSchema', '{\'fields\' : { \''+ subscriptionId + '\' : {\'description\' : \'' + description + '\', \'type\' : \'subscription\', \'required\' : false, \'doubleOptIn\' : false}}}');
        HttpResponse response = url.execute();
        return true;
    }
    
    private List<String> getTags(String userId, String consentId) {
        return getTagsFromGigyaAccount(AGNGigyaRESTAccount.getByUserId(userId), consentId);
    }
    
    public List<String> getTagsFromGigyaAccount(Map<String, Object> account, String consentId) {
        if (account == null) {
            return null;
        }
        Map<String, Object> subscriptions = (Map<String, Object>) account.get('subscriptions');
        
        Map<String, Object> subscription = (Map<String, Object>) subscriptions.get(consentId);
        List<String> subscriptionEmailTagsString = new List<String>();
        if (subscription != null) {
            Map<String, Object> subscriptionEmail = (Map<String, Object>) subscription.get('email');
            if (subscriptionEmail != null) {
                List<Object> subscriptionEmailTags = (List<Object>) subscriptionEmail.get('tags');
                if (subscriptionEmailTags != null) {
                    for (Object o : subscriptionEmailTags) {
                        subscriptionEmailTagsString.add(String.valueOf(o));
                    }
                }
            }
        }
        return subscriptionEmailTagsString;
    }
    
    public static List<AGNGigyaSubscriptionSchema> getAllSchemas() {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.getSchema');
        HttpResponse response = url.execute();
        String content = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
        Map<String, Object> ss = (Map<String, Object>) m.get('subscriptionsSchema');
        Map<String, Object> subscriptions = (Map<String, Object>) ss.get('fields');
        
        List<AGNGigyaSubscriptionSchema> result = new List<AGNGigyaSubscriptionSchema>();
        
        Set<String> keys = subscriptions.keySet();
        for (String key : keys) {
            Map<String, Object> subscription = (Map<String, Object>) subscriptions.get(key);
            Map<String, Object> subscriptionEmail = (Map<String, Object>) subscription.get('email');
            AGNGigyaSubscriptionSchema gse = new AGNGigyaSubscriptionSchema();
            gse.description = (String) subscriptionEmail.get('description');
            gse.type = (String) subscriptionEmail.get('type');
            gse.required = (Boolean) subscriptionEmail.get('required');
            gse.doubleOptIn = (Boolean) subscriptionEmail.get('doubleOptIn');
            gse.subscriptionId = key;
            result.add(gse);
        }
        return result;
    }
}