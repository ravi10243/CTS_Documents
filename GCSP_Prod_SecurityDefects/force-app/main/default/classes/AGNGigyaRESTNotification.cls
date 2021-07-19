/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This logic-less class implements the notification integration.
*/

public class AGNGigyaRESTNotification {
    
    public static AGNGigyaError error;
    public static Boolean setNotification(AGNGigyaNotification notification) {
        return AGNGigyaRESTNotification.setNotification(notification, null);
    }
    
    public static Boolean setNotification(AGNGigyaNotification notification, List<String> dataFieldsToEmpty) {
        if (dataFieldsToEmpty == null) {
            dataFieldsToEmpty = new List<String>();
        }
        
        if (String.isEmpty(notification.getOid())) {
            notification.setOid('auto');
        }
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('ds.store', 'ds');
        
        String params = '{';
        if (!String.isEmpty(notification.getLastName()) && !dataFieldsToEmpty.contains('LastName')) {
            params += '\'LastName\' : \''+notification.getLastName()+'\', ';
        }
        if (!String.isEmpty(notification.getFirstName()) && !dataFieldsToEmpty.contains('FirstName')) {
            params += '\'FirstName\' : \''+notification.getFirstName()+'\', ';
        }
        if (!String.isEmpty(notification.getExternalId()) && !dataFieldsToEmpty.contains('External_ID_vod__c')) {
            params += '\'External_ID_vod__c\' : \''+notification.getExternalId()+'\', ';
        }
        if (!String.isEmpty(notification.getSalutation()) && !dataFieldsToEmpty.contains('Salutation')) {
            params += '\'Salutation\' : \''+notification.getSalutation()+'\', ';
        }
        if (!String.isEmpty(notification.getMiddleName()) && !dataFieldsToEmpty.contains('Middle_vod__c')) {
            params += '\'Middle_vod__c\' : \''+notification.getMiddleName()+'\', ';
        }
        
        if (notification.isNotificationReceived() != null && notification.isNotificationReceived()) {
            if(notification.getCountryCode() == 'BR'){
                params += '\'LGPD_Notification_Received_AGN__c\' : true, ';
            }else{
                params += '\'GDPR_Notification_Received_AGN__c\' : true, ';
            }
            
        } else {
            if(notification.getCountryCode() == 'BR'){
                params += '\'LGPD_Notification_Received_AGN__c\' : false, ';
            }else{
                params += '\'GDPR_Notification_Received_AGN__c\' : false, ';
            }
            
        }
        
        if (!String.isEmpty(notification.getNotificationStatus()) && !dataFieldsToEmpty.contains('GDPR_Notification_Status_AGN__c') ) {
            if( notification.getCountryCode() != 'BR'){
                params += '\'GDPR_Notification_Status_AGN__c\' : \''+notification.getNotificationStatus()+'\', ';
            }
            
        }
        if (!String.isEmpty(notification.getNotificationStatusBR()) && !dataFieldsToEmpty.contains('LGPD_Notification_Status_AGN__c') ) {
            if(notification.getCountryCode() == 'BR'){
                params += '\'LGPD_Notification_Status_AGN__c\' : \''+notification.getNotificationStatusBR()+'\', ';
            }
            
        }
        if (notification.getEmail() != null && AGNGigyaRESTHelper.validateEmail(notification.getEmail()) && !dataFieldsToEmpty.contains('Email')) {
            params += '\'Email\' : \''+notification.getEmail()+'\', ';
        }
        if (!String.isEmpty(notification.getEmailTemplateName()) && !dataFieldsToEmpty.contains('Email_Template_Name_AGN__c')) {
            params += '\'Email_Template_Name_AGN__c\' : \''+notification.getEmailTemplateName()+'\', ';
        }
        if (!String.isEmpty(notification.getEmailSentDate())) {
            params += '\'Email_Sent_Date_AGN__c\' : \''+notification.getEmailSentDate()+'\', ';
        }
        if (!String.isEmpty(notification.getSfdcId())) {
            params += '\'SFDCId\' : \''+notification.getSfdcId()+'\', ';
        }
        if (notification.getVeevaCreatedDate() != null) {
            String dateStr = notification.getVeevaCreatedDate().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            if (dateStr != null && dateStr.length() > 0) {
                params += '\'Veeva_Created_Date\' : \''+dateStr+'\', ';
            }
        }
        if (notification.getemailSentRecDate() != null  ) {
            if(notification.getCountryCode() == 'BR'){
                String dateStr = notification.getemailSentRecDate().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                if (dateStr != null && dateStr.length() > 0) {
                    params += '\'Email_Sent_Received_Date_AGN__c\' : \''+dateStr+'\', ';
                }
            }
            
        }
        if (!String.isEmpty(notification.getExternalId2()) && !dataFieldsToEmpty.contains('External_ID2_AGN__c')) {
            params += '\'External_ID2_AGN__c\' : \''+notification.getExternalId2()+'\', ';
        }
        if (!String.isEmpty(notification.getCountryCode()) && !dataFieldsToEmpty.contains('Country_Code__c')) {
           
                params += '\'Country_Code__c\' : \''+notification.getCountryCode()+'\', ';
            
            
        }
        if (!String.isEmpty(notification.getCountryName()) && !dataFieldsToEmpty.contains('Country_Name_AGN__c')) {
            params += '\'Country_Name_AGN__c\' : \''+notification.getCountryName()+'\', ';
        }
        if (!String.isEmpty(notification.getSecondaryEmail()) && !dataFieldsToEmpty.contains('SecondaryEmail')) {
            params += '\'SecondaryEmail\' : \''+notification.getSecondaryEmail()+'\', ';
        }
        if (!String.isEmpty(notification.getStatus()) && !dataFieldsToEmpty.contains('Status_AGN__c')) {
            params += '\'Status_AGN__c\' : \''+notification.getStatus()+'\', ';
        }
        if (!String.isEmpty(notification.getAdditionalStatus()) && !dataFieldsToEmpty.contains('Additional_Status_AGN__c')) {
            params += '\'Additional_Status_AGN__c\' : \''+notification.getAdditionalStatus()+'\', ';
        }
        if (!String.isEmpty(notification.getSpecialty1()) && !dataFieldsToEmpty.contains('Specialty_1_AGN__c')) {
            params += '\'Specialty_1_AGN__c\' : \''+notification.getSpecialty1()+'\', ';
        }
        if (!String.isEmpty(notification.getSpecialty2()) && !dataFieldsToEmpty.contains('Specialty_2_AGN__c')) {
            params += '\'Specialty_2_AGN__c\' : \''+notification.getSpecialty2()+'\', ';
        }
        if (notification.getPrivacyLawStatus() != null) {
            if(notification.getCountryCode() == 'BR'){
                
                params += '\'LGPD_Delete_Flag\' : \''+notification.getPrivacyLawStatus()+'\', ';
            }else{
                params += '\'GDPR_Delete_Flag\' : \''+notification.getPrivacyLawStatus()+'\', ';
            }
            
        }
        for (String fieldToForce : dataFieldsToEmpty) {
            params += '\''+fieldToForce+'\' : \'\', ';
        }
        if (params.length() > 1) {
            params = params.substring(0, params.length() - 2);
        }
        
        params += '}';
        url.addParameter('data', params);
        url.addParameter('type', 'notifications');
        url.addParameter('oid', notification.getOid());
        
        HttpResponse response = url.execute();
        return true;
    }
    public static List<AGNGigyaNotification> getAllNotifications(String timestamp, String accountId) {
        String query = 'SELECT * FROM notifications ';
        Boolean whereAdded = false;
        if (timestamp != null && timestamp.length() > 0) {
            query += 'WHERE created > ' + timestamp + ' ';
            whereAdded = true;
        }
        if (accountId != null && accountId.length() > 0) {
            if (whereAdded == false) {
                query += 'WHERE ';
                whereAdded = true;
            } else {
                query += 'AND ';
            }
            query += 'SFDCId = \'' + accountId + '\' ';
        }
        
        String recordLimit = '10000';
        if (timestamp == null && accountId == null) {
            recordLimit = '100';
        }
        query += 'ORDER BY createdTime DESC ';
        query += 'LIMIT ' + recordLimit;
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('ds.search', 'ds');
        url.addParameter('query', query);
        
        HttpResponse response = url.execute();
        String content = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
        List<Object> results = (List<Object>) m.get('results');
        //List<Object> results = new List<Object>();
        //results.add(m.get('results'));
        return getNotificationsFromResults(results);
    }
    
    public static Map<String, List<AGNGigyaNotification>> getAllNotificationsByAccountIdsMap(List<String> accountIds) {
        String idsSet = '';
        for (String accountId : accountIds) {
            idsSet += '\'' + accountId + '\', ';
        }
        Map<String, List<AGNGigyaNotification>> res = new Map<String, List<AGNGigyaNotification>>();
        if (idsSet.length() > 1) {
            idsSet = idsSet.left(idsSet.length() - 2);
        } else {
            return res;
        }
        
        String query = 'SELECT * FROM notifications ';
        query += 'WHERE SFDCId IN (' + idsSet + ') ';
        
        String recordLimit = '10000';
        query += 'ORDER BY createdTime DESC ';
        query += 'LIMIT ' + recordLimit;
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('ds.search', 'ds');
        url.addParameter('query', query);
        
        HttpResponse response = url.execute();
        String content = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
        List<Object> results = (List<Object>) m.get('results');
        
        List<AGNGigyaNotification> gigyaAccounts = getNotificationsFromResults(results);
        if (gigyaAccounts != null) {
            for (AGNGigyaNotification gigyaAccount : gigyaAccounts) {
                List<AGNGigyaNotification> lTemp = res.get(gigyaAccount.getSFDCId());
                if (lTemp == null) {
                    lTemp = new List<AGNGigyaNotification>();
                }
                lTemp.add(gigyaAccount);
                res.put(gigyaAccount.getSFDCId(), lTemp);
            }
            
        }
        return res;
    }
    
    /* this method is used to update gigya accounts with new fields */
    public static List<AGNGigyaNotification> getNotificationsToUpdate(String created) {
        if (String.isBlank(created)) {
            created = '0';
        }
        String query = 'SELECT * FROM notifications ' +
            'WHERE (data.Country_Code__c = \'\' OR data.Country_Code__c = null ) ';
        query += 'AND created >= ' + Long.valueOf(created) + ' ';
        query += 'ORDER BY created ASC ';
        query += 'LIMIT 6000';
        
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('ds.search', 'ds');
        url.addParameter('query', query);
        
        HttpResponse response = url.execute();
        String content = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
        List<Object> results = (List<Object>) m.get('results');
        
        return getNotificationsFromResults(results);
        
    }
    
    public static List<AGNGigyaNotification> getAllNotificationsStartWith(String timestamp, String prefix) {
        String query = 'SELECT * FROM notifications ';
        Boolean whereAdded = false;
        if (timestamp != null && timestamp.length() > 0) {
            query += 'WHERE created > ' + timestamp + ' ';
            whereAdded = true;
        }
        if (prefix != null && prefix.length() > 0) {
            if (whereAdded == false) {
                query += 'WHERE ';
                whereAdded = true;
            } else {
                query += 'AND ';
            }
            query += 'SFDCId LIKE \'' + prefix + '%\' ';
        }
        
        String recordLimit = '10000';
        if (timestamp == null && prefix == null) {
            recordLimit = '100';
        }
        query += 'ORDER BY createdTime DESC ';
        query += 'LIMIT ' + recordLimit;
        AGNGigyaRESTUrlBuilder url = new AGNGigyaRESTUrlBuilder('ds.search', 'ds');
        url.addParameter('query', query);
        
        HttpResponse response = url.execute();
        
        return extractNotificationList(response);
    }
    
    private static List<AGNGigyaNotification> extractNotificationList(HTTPResponse response) {
        String content = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(content);
        List<Object> results = (List<Object>) m.get('results');
        
        List<AGNGigyaNotification> notifications = new List<AGNGigyaNotification>();
        for (Object r : results) {
            Map<String, Object> result = (Map<String, Object>) r;
            Map<String, Object> dataResult = (Map<String, Object>) result.get('data');
            AGNGigyaNotification notification = new AGNGigyaNotification();
            
            if (dataResult.get('Email') != null) {
                notification.setEmail(String.valueOf(dataResult.get('Email')));
            }
            if (dataResult.get('External_ID_vod__c') != null) {
                notification.setExternalId(String.valueOf(dataResult.get('External_ID_vod__c')));
            }
            if (dataResult.get('FirstName') != null) {
                notification.setFirstName(String.valueOf(dataResult.get('FirstName')));
            }
            if (dataResult.get('GDPR_Notification_Status_AGN__c') != null) {
                notification.setNotificationStatus(String.valueOf(dataResult.get('GDPR_Notification_Status_AGN__c')));
            }
            if (dataResult.get('LGPD_Notification_Status_AGN__c') != null) {
                notification.setNotificationStatusBR(String.valueOf(dataResult.get('LGPD_Notification_Status_AGN__c')));
            }
            if (dataResult.get('LGPD_Notification_Received_AGN__c') != null ) {
                if(notification.getCountryCode() == 'BR'){
                    notification.setNotificationReceived(Boolean.valueOf(dataResult.get('LGPD_Notification_Received_AGN__c')));
                }else{
                    if(dataResult.get('GDPR_Notification_Received_AGN__c') != null){
                         notification.setNotificationReceived(Boolean.valueOf(dataResult.get('GDPR_Notification_Received_AGN__c')));
                    }
                }                
            }
            if (dataResult.get('LastName') != null) {
                notification.setLastName(String.valueOf(dataResult.get('LastName')));
            }
            if (dataResult.get('Middle_vod__c') != null) {
                notification.setMiddleName(String.valueOf(dataResult.get('Middle_vod__c')));
            }
            if (dataResult.get('Salutation') != null) {
                notification.setSalutation(String.valueOf(dataResult.get('Salutation')));
            }
            if (dataResult.get('SFDCId') != null) {
                notification.setSfdcId(String.valueOf(dataResult.get('SFDCId')));
            }
            if (dataResult.get('Email_Template_Name_AGN__c') != null) {
                notification.setEmailTemplateName(String.valueOf(dataResult.get('Email_Template_Name_AGN__c')));
            }
            if (result.get('createdTime') != null) {
                notification.setCreatedTime(String.valueOf(result.get('createdTime')));
            }
            if (dataResult.get('Veeva_Created_Date') != null) {
                String dateStr = String.valueOf(dataResult.get('Veeva_Created_Date'));
                String newDateStr = dateStr.left(10) + ' ' + dateStr.substring(11);
                notification.setVeevaCreatedDate(DateTime.valueOf(newDateStr));
            }
            if (dataResult.get('Email_Sent_Received_Date_AGN__c') != null ) {
                if(notification.getCountryCode() == 'BR'){
                    String dateStr = String.valueOf(dataResult.get('Email_Sent_Received_Date_AGN__c'));
                    String newDateStr = dateStr.left(10) + ' ' + dateStr.substring(11);
                    notification.setemailSentRecDate(DateTime.valueOf(newDateStr));
                }
                
            }
            
            notifications.add(notification);
        }
        return notifications;
        
    }
    public static List<AGNGigyaNotification> getAllNotifications(String timestamp) {
        return getAllNotifications(null, null);
    }
    
    public static List<AGNGigyaNotification> getAllNotifications() {
        return getAllNotifications(null);
    }
    
    public static List<AGNGigyaNotification> getAllNotificationsByAccountId(String accountId) {
        return getAllNotifications(null, accountId);
    }
    
    private static List<AGNGigyaNotification> getNotificationsFromResults(List<Object> results) {
        List<AGNGigyaNotification> notifications = new List<AGNGigyaNotification>();
        for (Object r : results) {
            Map<String, Object> result = (Map<String, Object>) r;
            Map<String, Object> dataResult = (Map<String, Object>) result.get('data');
            AGNGigyaNotification notification = new AGNGigyaNotification();
            if (result.get('oid') != null) {
                notification.setOid(String.valueOf(result.get('oid')));
            }
            if (dataResult.get('Email') != null) {
                notification.setEmail(String.valueOf(dataResult.get('Email')));
            }
            if (dataResult.get('External_ID_vod__c') != null) {
                notification.setExternalId(String.valueOf(dataResult.get('External_ID_vod__c')));
            }
            if (dataResult.get('FirstName') != null) {
                notification.setFirstName(String.valueOf(dataResult.get('FirstName')));
            }
            if (dataResult.get('GDPR_Notification_Status_AGN__c') != null  ) {
                if(notification.getCountryCode() != 'BR'){
                     notification.setNotificationStatus(String.valueOf(dataResult.get('GDPR_Notification_Status_AGN__c')));
                }
               
            }
            if (dataResult.get('LGPD_Notification_Status_AGN__c') != null) {
                if(notification.getCountryCode() == 'BR'){
                     notification.setNotificationStatusBR(String.valueOf(dataResult.get('LGPD_Notification_Status_AGN__c')));
                }
               
            }
      
            if (dataResult.get('LGPD_Notification_Received_AGN__c') != null ) {
                if(notification.getCountryCode() == 'BR'){
                    notification.setNotificationReceived(Boolean.valueOf(dataResult.get('LGPD_Notification_Received_AGN__c')));
                }else{
                    if(dataResult.get('GDPR_Notification_Received_AGN__c') != null){
                        notification.setNotificationReceived(Boolean.valueOf(dataResult.get('GDPR_Notification_Received_AGN__c')));
                    }
                }
                
            }
            if (dataResult.get('LastName') != null) {
                notification.setLastName(String.valueOf(dataResult.get('LastName')));
            }
            if (dataResult.get('Middle_vod__c') != null) {
                notification.setMiddleName(String.valueOf(dataResult.get('Middle_vod__c')));
            }
            if (dataResult.get('Salutation') != null) {
                notification.setSalutation(String.valueOf(dataResult.get('Salutation')));
            }
            if (dataResult.get('SFDCId') != null) {
                notification.setSfdcId(String.valueOf(dataResult.get('SFDCId')));
            }
            if (dataResult.get('Email_Template_Name_AGN__c') != null) {
                notification.setEmailTemplateName(String.valueOf(dataResult.get('Email_Template_Name_AGN__c')));
            }
            if (result.get('createdTime') != null) {
                notification.setCreatedTime(String.valueOf(result.get('createdTime')));
            }
            if (result.get('created') != null) {
                notification.setCreatedTimestamp(String.valueOf(result.get('created')));
            }
            if (dataResult.get('External_ID2_AGN__c') != null) {
                notification.setExternalId2(String.valueOf(dataResult.get('External_ID2_AGN__c')));
            }
            if (dataResult.get('Country_Code__c') != null) {
                notification.setCountryCode(String.valueOf(dataResult.get('Country_Code__c')));
            }
            if (dataResult.get('Country_Name_AGN__c') != null) {
                notification.setCountryName(String.valueOf(dataResult.get('Country_Name_AGN__c')));
            }
            if (dataResult.get('SecondaryEmail') != null) {
                notification.setSecondaryEmail(String.valueOf(dataResult.get('SecondaryEmail')));
            }
            if (dataResult.get('Status_AGN__c') != null) {
                notification.setStatus(String.valueOf(dataResult.get('Status_AGN__c')));
            }
            if (dataResult.get('Additional_Status_AGN__c') != null) {
                notification.setAdditionalStatus(String.valueOf(dataResult.get('Additional_Status_AGN__c')));
            }
            if (dataResult.get('Specialty_1_AGN__c') != null) {
                notification.setSpecialty1(String.valueOf(dataResult.get('Specialty_1_AGN__c')));
            }
            if (dataResult.get('Specialty_2_AGN__c') != null) {
                notification.setSpecialty2(String.valueOf(dataResult.get('Specialty_2_AGN__c')));
            }
            if (dataResult.get('LGPD_Delete_Flag') != null ) {
                if(notification.getCountryCode() == 'BR'){
                    notification.setPrivacyLawStatus(Boolean.valueOf(dataResult.get('LGPD_Delete_Flag')));
                }else{
                    if(dataResult.get('GDPR_Delete_Flag') != null){
                        notification.setPrivacyLawStatus(Boolean.valueOf(dataResult.get('GDPR_Delete_Flag')));
                    }
                }            
            }           
            
            if (dataResult.get('Veeva_Created_Date') != null) {
                String dateStr = String.valueOf(dataResult.get('Veeva_Created_Date'));
                String newDateStr = dateStr.left(10) + ' ' + dateStr.substring(11);
                notification.setVeevaCreatedDate(DateTime.valueOf(newDateStr));
            }
            
             if (dataResult.get('Email_Sent_Received_Date_AGN__c') != null ) {
                if(notification.getCountryCode() == 'BR'){
                    String dateStr = String.valueOf(dataResult.get('Email_Sent_Received_Date_AGN__c'));
                    String newDateStr = dateStr.left(10) + ' ' + dateStr.substring(11);
                    notification.setemailSentRecDate(DateTime.valueOf(newDateStr));
                }
                
            }
            Map<String, Object> temp = new Map<String, Object>();
            temp.putAll(dataResult);
            temp.put('oid', notification.getOid());
            notification.setRawData(temp);
            
            notifications.add(notification);
        }
        return notifications;
    }
}