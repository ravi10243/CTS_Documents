/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class manages the integration between Veeva HCP/HCO and Gigya accounts.
* It manages both basic personal data and consent update.
*/

public class AGNGigyaRESTAccount {
    public static String registerAccount(AGNGigyaAccount account) {
        String regToken = getToken();
        system.debug('a----regToken--->' +regToken);
        if (regToken == null || regToken == '') {
            system.debug('a---regtoken--->' +regToken);
            throw new AGNGigyaValidationException(-2,'impossible retrieve regToken from Gigya', 'impossible retrieve regToken from Gigya');
        }
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.register');
        system.debug('a---account.getEmail()--->' +account.getEmail());
        if (account.getEmail() != null && account.getEmail().length() > 0) {
           
            url.addParameter('email', account.getEmail());
            system.debug('a---account.getEmail()--->' +account.getEmail());
        }
        url.addParameter('username', account.getUsername());
        
        url.addParameter('password', AGNGigyaRESTHelper.generateRandomString(8));
        url.addParameter('data', '{\'SFDCId\': \'' + account.getId() + '\'}');
        url.addParameter('regToken', regToken);
        system.debug('a---account.getUsername()--->' +account.getUsername());
        if(account.getCountryCode() =='BR'){
            url.addParameter('regSource', 'Veeva' );
        }        
        url.addParameter('finalizeRegistration', 'true');
      /*  if(account.getCountryCode() =='BR'){
        String profileParams = '{';    
        if (!AGNGigyaRESTHelper.isEmptyString(account.getFirstName())  ) {
            profileParams += '\'firstName\' : \''+account.getFirstName()+'\', ';
        }
        
        if (!AGNGigyaRESTHelper.isEmptyString(account.getLastName())  ) {
            profileParams += '\'lastName\' : \''+account.getLastName()+'\', ';
        }
        
        if (!AGNGigyaRESTHelper.isEmptyString(account.getCountryName()))  {
            profileParams += '\'country\' : \''+account.getCountryName()+'\', ';
        }       
        if (account.getEmail() != null && AGNGigyaRESTHelper.validateEmail(account.getEmail())) {
            profileParams += '\'email\' : \''+account.getEmail()+'\', ';
            
        }      
        
        
        if (profileParams.length() > 1) {
            profileParams = profileParams.substring(0, profileParams.length() - 2);
        }
        profileParams += '}';
        
        url.addParameter('profile', profileParams);
            }*/
        //AM Added by Brazil LGPD team to send Distribution Id & PhysicianRefNumber fields information to Gigya for BRAZIL
        if(account.getCountryCode() =='BR'){
            url.addParameter('distributionId', account.getdistributionID());
        } 
        if(account.getCountryCode() =='BR'){
            url.addParameter('physicianRefNumber', account.getphysicianRefNumber());
        } 
        //AM
        system.debug('a--url--->' +url);
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        account.setUserId((String) m.get('UID'));
        if (setAccountInfo(account)) {
            return account.getUserId();
        } else {
            deleteAccount(account.getUserId());
            return null;
        }
    }
    
    public static Boolean setAccountInfo(AGNGigyaAccount account) {
        return AGNGigyaRESTAccount.setAccountInfo(account, null, null);
    }
    
    public static Boolean setAccountInfo(AGNGigyaAccount account, List<String> profileFieldsToEmpty, List<String> dataFieldsToEmpty) {
        if (profileFieldsToEmpty == null) {
            profileFieldsToEmpty = new List<String>();
        }
        if (dataFieldsToEmpty == null) {
            dataFieldsToEmpty = new List<String>();
        }
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.setAccountInfo');
        String profileParams = '{';
        
        if (!AGNGigyaRESTHelper.isEmptyString(account.getFirstName()) && !profileFieldsToEmpty.contains('firstName')) {
            profileParams += '\'firstName\' : \''+account.getFirstName()+'\', ';
        }
        
        if (!AGNGigyaRESTHelper.isEmptyString(account.getLastName()) && !profileFieldsToEmpty.contains('lastName')) {
            profileParams += '\'lastName\' : \''+account.getLastName()+'\', ';
        }
        
        if (!AGNGigyaRESTHelper.isEmptyString(account.getCountryName()) && !profileFieldsToEmpty.contains('country')) {
            profileParams += '\'country\' : \''+account.getCountryName()+'\', ';
        }
        
        if (account.getEmail() != null && AGNGigyaRESTHelper.validateEmail(account.getEmail())) {
            profileParams += '\'email\' : \''+account.getEmail()+'\', ';
            if (!AGNGigyaRESTHelper.isEmptyString(account.getUsername())) {
                profileParams += '\'username\' : \''+account.getUsername()+'\', ';
            }
        }
        
        for (String fieldToForce : profileFieldsToEmpty) {
            profileParams += '\''+fieldToForce+'\' : \'\', ';
        }
        
        if (profileParams.length() > 1) {
            profileParams = profileParams.substring(0, profileParams.length() - 2);
        }
        profileParams += '}';
        
        url.addParameter('profile', profileParams);
        
        String dataParams = '';
        if (!String.isEmpty(account.getSecondaryEmail()) && !dataFieldsToEmpty.contains('SecondaryEmail')) {
            dataParams += '\'SecondaryEmail\' : \''+account.getSecondaryEmail()+'\', ';
        }
        if (!String.isEmpty(account.getExternalId()) && !dataFieldsToEmpty.contains('External_ID_vod__c')) {
            dataParams += '\'External_ID_vod__c\' : \''+account.getExternalId()+'\', ';
        }
        if (!String.isEmpty(account.getExternalId2()) && !dataFieldsToEmpty.contains('External_ID2_AGN__c')) {
            dataParams += '\'External_ID2_AGN__c\' : \''+account.getExternalId2()+'\', ';
        }
        if (!String.isEmpty(account.getMdmId()) && !dataFieldsToEmpty.contains('MDM_ID_AGN__c')) {
            dataParams += '\'MDM_ID_AGN__c\' : \''+account.getMdmId()+'\', ';
        }
        if (!String.isEmpty(account.getCountryCode()) &&(!dataFieldsToEmpty.contains('Country_Code__c') || !dataFieldsToEmpty.contains('Country_Code__c'))) {
            if(account.getCountryCode() == 'BR'){
                dataParams += '\'Country_Code__C\' : \''+account.getCountryCode()+'\', ';
            }else{
                dataParams += '\'Country_Code__c\' : \''+account.getCountryCode()+'\', ';
            }
            
            
        }
        /* if (!String.isEmpty(account.getCountryCode()) && !dataFieldsToEmpty.contains('Country_Code__C')) {
dataParams += '\'Country_Code__C\' : \''+account.getCountryCode()+'\', ';
}*/
        
        if (!String.isEmpty(account.getSalutation()) && !dataFieldsToEmpty.contains('Salutation')) {
            dataParams += '\'Salutation\' : \''+account.getSalutation()+'\', ';
        }
        if (!String.isEmpty(account.getStatus()) && !dataFieldsToEmpty.contains('Status_AGN__c')) {
            dataParams += '\'Status_AGN__c\' : \''+account.getStatus()+'\', ';
        }
        if (!String.isEmpty(account.getAdditionalStatus()) && !dataFieldsToEmpty.contains('Additional_Status_AGN__c')) {
            dataParams += '\'Additional_Status_AGN__c\' : \''+account.getAdditionalStatus()+'\', ';
        }
        if (!String.isEmpty(account.getSpecialty1()) && !dataFieldsToEmpty.contains('Specialty_1_AGN__c')) {
            dataParams += '\'Specialty_1_AGN__c\' : \''+account.getSpecialty1()+'\', ';
        }
        if (!String.isEmpty(account.getSpecialty2()) && !dataFieldsToEmpty.contains('Specialty_2_AGN__c')) {
            dataParams += '\'Specialty_2_AGN__c\' : \''+account.getSpecialty2()+'\', ';
        }
        if (!String.isEmpty(account.getdistributionID()) && !dataFieldsToEmpty.contains('distributionID')) {
            if(account.getCountryCode() == 'BR'){
                dataParams += '\'distributionID\' : \''+account.getdistributionID()+'\', ';
            }            
        }
        if (!String.isEmpty(account.getphysicianRefNumber()) && !dataFieldsToEmpty.contains('physicianRefNumber')) {
            if(account.getCountryCode() == 'BR'){
                dataParams += '\'physicianRefNumber\' : \''+account.getphysicianRefNumber()+'\', ';
            }            
        }
        
        //Added for Brazil Country
        if (account.getPrivacyLawStatus() != null && account.getPrivacyLawStatus()) {
            if(account.getCountryCode() == 'BR'){
                dataParams += '\'LGPD_Delete_Flag\' : true, ';
            }else{
                dataParams += '\'GDPR_Delete_Flag\' : true, ';
            }
            
        } else {
            if(account.getCountryCode() == 'BR'){
                dataParams += '\'LGPD_Delete_Flag\' : false, ';
            }else{
                dataParams += '\'GDPR_Delete_Flag\' : false, ';
            }
            
        }
        
        for (String fieldToForce : dataFieldsToEmpty) {
            dataParams += '\''+fieldToForce+'\' : \'\', ';
        }
        
        if (dataParams.length() > 1) {
            dataParams = dataParams.substring(0, dataParams.length() - 2);
        }
        
        url.addParameter('data', '{'+dataParams+'}');
        url.addParameter('UID', account.getUserId());
        HttpResponse response = url.execute();
        return true;
    }
    
    public static Boolean deleteAccount(String userId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.deleteAccount');
        url.addParameter('UID', userId);
        HttpResponse response = url.execute();
        return true;
    }
    
    public static Map<String, Object> getByUserId(String userId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.getAccountInfo');
        url.addParameter('UID', userId);
        HttpResponse response = url.execute();
        return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    }
    
    // DEPRECATED maybe not used anymore
    public static List<Object> getUsersByAccountId(String accountId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select email, UID, SFDCId, preferences, subscriptions from emailAccounts where SFDCId=\''+accountId+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        return r;
    }
    
    // DEPRECATED maybe not used anymore
    public static List<Object> getUserIdsByAccountId(String accountId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select UID from accounts where SFDCId=\''+accountId+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        return r;
    }
    
    public static List<AGNGigyaAccount> getUsersByAccount(String accountId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select createdTimestamp, profile, data, UID from accounts where SFDCId=\''+accountId+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        
        return getUsersByResults(r);
    }
    
    public static Map<String, List<AGNGigyaAccount>> getUsersByAccountsMap(List<String> accountIds) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        
        String idsSet = '';
        for (String accountId : accountIds) {
            idsSet += '\'' + accountId + '\', ';
        }
        Map<String, List<AGNGigyaAccount>> res = new Map<String, List<AGNGigyaAccount>>();
        if (idsSet.length() > 1) {
            idsSet = idsSet.left(idsSet.length() - 2);
        } else {
            return res;
        }
        
        url.addParameter('query', 'select createdTimestamp, profile, data, UID from accounts where SFDCId IN (' + idsSet + ') LIMIT 10000');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        system.debug('a--->m' + m);
        List<Object> r = (List<Object>) m.get('results');
       system.debug('a--->res' + r);
        
        List<AGNGigyaAccount> gigyaAccounts = getUsersByResults(r);
        if (gigyaAccounts != null) {
            for (AGNGigyaAccount gigyaAccount : gigyaAccounts) {
                List<AGNGigyaAccount> lTemp = res.get(gigyaAccount.getId());
                if (lTemp == null) {
                    lTemp = new List<AGNGigyaAccount>();
                }
                lTemp.add(gigyaAccount);
                res.put(gigyaAccount.getId(), lTemp);
            }
            
        }
        return res;
    }
    
    public static Set<String> getEmailsFromEmails(Set<String> emails) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        Set<String> res = new Set<String>();
        
        String emailsSet = '';
        for (String email : emails) {
            emailsSet += '\'' + email + '\', ';
        }
        if (emailsSet.length() > 1) {
            emailsSet = emailsSet.left(emailsSet.length() - 2);
        } else {
            return res;
        }
        
        url.addParameter('query', 'select profile.email from accounts where profile.email IN (' + emailsSet + ') LIMIT 10000');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        for (Object userObject : r) {
            Map<String, Object> user = (Map<String, Object>) userObject;
            Map<String, Object> profile = (Map<String, Object>) user.get('profile');
            if (profile != null) {
                if (!String.isBlank((String)profile.get('email'))) {
                    res.add((String)profile.get('email'));
                }
            }
        }
        return res;
    }
    
    /* this method is used to update gigya accounts with new fields */
    public static List<AGNGigyaAccount> getUsersToUpdate(String createdTimestamp) {
        if (createdTimestamp == null) {
            createdTimestamp = '0';
        }
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'SELECT createdTimestamp, profile, data, preferences, UID '+
                         'FROM accounts '+
                         'WHERE (Country_Code__C = \'\' OR Country_Code__C = null) ' +
                         'AND createdTimestamp >= ' + Long.valueOf(createdTimestamp) + ' ' +
                         'ORDER BY createdTimestamp ASC ' +
                         'LIMIT 4000 '
                        );
        
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        
        return getUsersByResults(r);
    }
    
    public static String getUserIdByUsername(String username) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select UID from accounts where username=\''+username+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        if (r.size() > 0) {
            Map<String, Object> account = (Map<String, Object>) r.get(0);
            return (String) account.get('UID');
        }
        return null;
    }
    
    public static String getUserIdByEmailOrUsername(String email) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select UID from accounts where profile.email=\''+email+'\' OR username=\''+email+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        if (r.size() > 0) {
            Map<String, Object> account = (Map<String, Object>) r.get(0);
            return (String) account.get('UID');
        }
        return null;
    }
    
    public static Map<String, Object> getUsersByUserId(String userId) {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        url.addParameter('query', 'select email, UID, SFDCId, preferences, subscriptions from emailAccounts where UID=\''+userId+'\'');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        if (r.size() == 1) {
            Map<String, Object> account = (Map<String, Object>) r.get(0);
            return account;
        }
        return null;
    }
    
    public static String searchUserId(String accountId, String externalId, String email) {
        String includeEmailQuery = '';
        if (email != null && email.length() > 0) {
            includeEmailQuery += ' AND profile.email = \'' + email + '\'';
        } else {
            includeEmailQuery += ' AND profile.email IS NULL';
        }
        
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.search');
        String query = 'SELECT UID FROM accounts WHERE ';
        query += '(';
        query += 'SFDCId=\''+accountId+'\'' + includeEmailQuery;
        query += ') ';
        if (externalId != null && externalId != 'null') {
            query += 'OR (';
            query += 'data.External_ID_vod__c=\''+externalId+'\'' + includeEmailQuery;
            query += ')';
        }
        query += ' LIMIT 1';
        System.debug('query|' + query);
        url.addParameter('query', query);
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> r = (List<Object>) m.get('results');
        if (r.size() == 1) {
            Map<String, Object> account = (Map<String, Object>) r.get(0);
            return (String) account.get('UID');
        }
        return null;
    }
    
    private static List<AGNGigyaAccount> getUsersByResults(List<Object> results) {
        List<Object> r = results;
        List<AGNGigyaAccount> res = new List<AGNGigyaAccount>();
        for (Object userObject : r) {
            Map<String, Object> user = (Map<String, Object>) userObject;
            Map<String, Object> profile = (Map<String, Object>) user.get('profile');
            Map<String, Object> data = (Map<String, Object>) user.get('data');
            Map<String, Object> preferences = (Map<String, Object>) user.get('preferences');
            Map<String, Object> subscriptions = (Map<String, Object>) user.get('subscriptions');
            
            AGNGigyaAccount acc = new AGNGigyaAccount();
            acc.setUserId((String)user.get('UID'));
            system.debug('a--profile--->' +profile);
            if (profile != null) {
                acc.setFirstName((String)profile.get('firstName'));
                acc.setLastName((String)profile.get('lastName'));
                acc.setCountryName((String)profile.get('country'));
                acc.setEmail((String)profile.get('email'));
                acc.setUsername((String)profile.get('username'));
            }
            system.debug('a--data--->' +data);
            if (data != null) {
                acc.setId((String)data.get('SFDCId'));
                acc.setStatus((String)data.get('Status_AGN__c'));
                acc.setAdditionalStatus((String)data.get('Additional_Status_AGN__c'));
                if (  acc.getCountryCode()== 'BR') {
                     if (data.get('LGPD_Delete_Flag') != null ) {
                        acc.setPrivacyLawStatus(Boolean.valueOf(data.get('LGPD_Delete_Flag')));
                    }                
                    
                }else{
                    
                   if(data.get('GDPR_Delete_Flag') != null){
                        acc.setPrivacyLawStatus(Boolean.valueOf(data.get('GDPR_Delete_Flag')));
                    }
                }             
                acc.setSecondaryEmail((String)data.get('SecondaryEmail'));
                acc.setExternalId((String)data.get('External_ID_vod__c'));
                acc.setExternalId2((String)data.get('External_ID2_AGN__c'));
                acc.setMdmId((String)data.get('MDM_ID_AGN__c'));
                if(acc.getCountryCode() =='BR'){
                    acc.setCountryCode((String)data.get('Country_Code__C')); 
                    acc.setDistributionID((String)data.get('distributionID')); 
                    acc.setphysicianRefNumber((String)data.get('physicianRefNumber'));
                                      
                }else{
                    acc.setCountryCode((String)data.get('Country_Code__c')); 
                }                
                acc.setSpecialty1((String)data.get('Specialty_1_AGN__c'));
                acc.setSpecialty2((String)data.get('Specialty_2_AGN__c'));               
                acc.setSalutation((String)data.get('Salutation'));
                acc.setCreatedTimestamp(String.valueOf(user.get('createdTimestamp')));
            }
            acc.setRawData(user);
            res.add(acc);
        }
        return res;
    }
    
    public static void printSchema() {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.getSchema');
        HttpResponse response = url.execute();
        System.debug(response.getBody());
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Set<String> keys = m.keySet();
        for (String key : keys) {
            System.debug(m.get(key));
        }
    }
    
    private static String getToken() {
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('accounts.initRegistration');
        HttpResponse response = url.execute();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        return (String) m.get('regToken');
    }
}