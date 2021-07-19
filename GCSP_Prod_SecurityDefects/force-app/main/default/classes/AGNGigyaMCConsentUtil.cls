public class AGNGigyaMCConsentUtil {

  public static Consent_Type_vod__c getConsentType(String ctRecordTypeName, String country, String language) {
    List<Consent_Type_vod__c> ctl = [SELECT Id
    FROM Consent_Type_vod__c
    WHERE RecordType.DeveloperName = :ctRecordTypeName
    AND Consent_Header_vod__c IN
    (
    SELECT Id FROM Consent_Header_vod__c
    WHERE Status_vod__c = 'Active_vod'
    AND Country_vod__r.Name = :country
    AND Language_vod__c = :language
    )];

    if (ctl.size() == 0) {
      return null;
    }
    if (ctl.size() == 1) {
      return ctl.get(0);
    }
    throw new AGNGigyaValidationException(-1, 'Too many consent types found.', 'Too many consent types found.');
  }

  public static Consent_Line_vod__c getConsentLineFromConsentTypeContentType(String ctRecordTypeName, String country, String language) {
    String contentTypeExternalId = getContentTypeExternalId(AGNGigyaMCConsentUtil.getApprovedEmailRecordType());
   
      if (String.isEmpty(contentTypeExternalId)) {
      return null;
    }
      system.debug('a--AGNGigyaMCConsentUtil.getApprovedEmailRecordType---->' +AGNGigyaMCConsentUtil.getApprovedEmailRecordType());
    List<Consent_Line_vod__c> ctl = [SELECT Id,
    Content_Type_vod__c,
    Consent_Type_vod__c
    FROM Consent_Line_vod__c
    WHERE Content_Type_vod__r.External_ID_vod__c = :contentTypeExternalId
    // AM AND Consent_Type_vod__c = :AGNGigyaMCConsentUtil.getApprovedEmailRecordType()
    AND Consent_Type_vod__r.RecordType.Name = :AGNGigyaMCConsentUtil.getApprovedEmailRecordType()
    ];
    
     
    if (ctl.size() == 0) {
      return null;
    }
    if (ctl.size() == 1) {
      return ctl.get(0);
    }
    throw new AGNGigyaValidationException(-1, 'Too many consent lines found.', 'Too many consent lines found.');
  }

  public static List<Multichannel_Consent_vod__c> getConsentList(Set<Id> mccIds) {
    List<Id> headerIds = AGNGigyaConsentFactory.ENABLED_CONSENT_HEADERS_IDS;
    String query = 'SELECT Id, Name, ' +
    'Account_vod__c, ' +
    'Account_vod__r.LastName, Account_vod__r.FirstName, ' +
    'Account_vod__r.PersonEmail, Account_vod__r.External_ID_vod__c, ' +
    'Account_vod__r.External_ID2_AGN__c, Account_vod__r.Country_vod__r.Name, ' +
    'Account_vod__r.Country_Name_AGN__c, Account_vod__r.Salutation, ' +
    'Account_vod__r.Status_AGN__c, Account_vod__r.Additional_Status_AGN__c, ' +
    'Account_vod__r.Specialty_Allergan_1_AGN__r.Name, Account_vod__r.Sub_Specialty_Allergan_AGN__r.Name, ' +
    'Account_vod__r.Specialty_1_AGN__r.Name, Account_vod__r.Specialty_2_AGN__r.Name, ' +
    'Account_vod__r.Email_Internal_AGN__c, Account_vod__r.MDM_ID_AGN__c, ' +
    'Opt_Type_vod__c, Channel_Value_vod__c, ' +
    'Consent_Type_vod__c, Consent_Line_vod__c, ' +
    'Consent_Type_vod__r.Channel_Label_vod__c, ' +
    'Consent_Type_vod__r.Consent_Expires_In_vod__c, ' +
    'Consent_Type_vod__r.Consent_Header_vod__c, ' +
    'Consent_Type_vod__r.Channel_Source_vod__c, ' +
    'Capture_Datetime_vod__c, ' +
    'Optout_Event_Type_vod__c, ' +
    'Content_Type_vod__r.External_Id_vod__c, ' +
    'Consent_User_Type_AGN__c, ' +
    'CreatedBy.Name, ' +
    'Consent_Type_vod__r.RecordTypeId, ' +
    'Account_vod__r.Country_vod__r.Alpha_2_Code_vod__c, '+                                                                 //Added by Ru
    'Consent_Type_vod__r.RecordType.DeveloperName ' +
    'FROM Multichannel_Consent_vod__c ' +
    'WHERE Id IN :mccIds ' +
    'AND Account_vod__r.Privacy_Law_Status_AGN__c = false ' +
    // relax constraint because some mcconsent don't have consent type (e.g. unsubscribe link)
    //    'AND Consent_Type_vod__r.Consent_Header_vod__c IN :headerIds ' +
    'AND FromGigya_AGN__c != true ' +
    'AND Account_vod__r.Country_vod__r.Name NOT IN (\'RU\',\'TR\')';
    return Database.query(query);
  }

  public static Set<Id> getConsentIds(String accountId, String channelValue, String externalId) {
    if (accountId == null && externalId == null) {
      return null;
    }

    List<Consent_Header_vod__c> chTemp = [SELECT Id FROM Consent_Header_vod__c
    WHERE Status_vod__c = 'Active_vod'];

    List<Id> consentHeaders = new List<Id>();

    for (Consent_Header_vod__c ch : chTemp) {
      consentHeaders.add(ch.Id);
    }

    String query = 'SELECT Id ' +
    'FROM Multichannel_Consent_vod__c ' +'WHERE Account_vod__r.Country_vod__r.Name NOT IN (\'RU\',\'TR\')' ;

    String channelValueQuery = '';
    if (channelValue != null && channelValue.length() > 0) {
      channelValueQuery += 'AND Channel_Value_vod__c = :channelValue ';
    } else {
      channelValueQuery += 'AND Channel_Value_vod__c = \'\' ';
    }

    query += 'WHERE ';
    query += '(';
    if (accountId != null && accountId != 'null') {
      query += '(Account_vod__c = :accountId ' + channelValueQuery + ') ';
    }
    if (externalId != null && externalId != 'null') {
      if (accountId != null && accountId != 'null') {
        query += ' OR ';
      }
      query += '(Account_vod__r.External_ID_vod__c = :externalId ' + channelValueQuery + ') ';
    }
    query += ') ';

    query += 'ORDER BY CreatedDate DESC';
    List<Multichannel_Consent_vod__c> res = Database.query(query);

    Set<Id> resOut = new Set<Id>();
    if (res == null) {
      return null;
    }
    for (Multichannel_Consent_vod__c obj : res) {
      resOut.add(obj.Id);
    }
    return resOut;
  }

    public static void deleteAllConsents(String accountId, String channel) {
        //Cognizant- CC - Line Number - 138
        List<Multichannel_Consent_vod__c> consents = [SELECT Id
                                                      FROM Multichannel_Consent_vod__c
                                                      WHERE Account_vod__c = :accountId
                                                      AND Channel_Value_vod__c = :channel AND Account_vod__r.Country_vod__r.Name NOT IN ('RU')];
        if(Multichannel_Consent_vod__c.sObjectType.getDescribe().isDeletable()){
            delete consents;
        }       
    }

  public static void optOutAllConsents(String accountId, String channel) {
      
      
    List<Multichannel_Consent_vod__c> consents = [SELECT Id, Account_vod__c,
    AGN_Consent_Type_Multichannel__c, Channel_Value_vod__c, Consent_Line_vod__c,
    Consent_Type_vod__c, Content_Type_vod__c, Email_Notification_For_Portal_AGN__c,
    FromGigya_AGN__c, Opt_Type_vod__c, RecordTypeId, Signature_ID_vod__c, Capture_Datetime_vod__c
    FROM Multichannel_Consent_vod__c
    WHERE Account_vod__c = :accountId
    AND Channel_Value_vod__c = :channel AND Account_vod__r.Country_vod__r.Name NOT IN ('RU','TR')];
    System.debug('consents|' + consents);
    List<Multichannel_Consent_vod__c> newConsents = new List<Multichannel_Consent_vod__c>();

    for (Multichannel_Consent_vod__c oldConsent : consents) {
      Multichannel_Consent_vod__c newConsent = oldConsent.clone(false, true);
        //Cognizant- CC - Line Number - 159,162,165
        if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isAccessible() && Schema.sObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){
            newConsent.Opt_Type_vod__c = 'Opt_Out_vod';
        }
        if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Signature_ID_vod__c.isCreateable()){
            newConsent.Signature_ID_vod__c = 'channel changed';
        }      
        if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){
            newConsent.Capture_Datetime_vod__c = Datetime.now();
        }
      
      newConsents.add(newConsent);
      System.debug('newConsent|' + newConsent);
    }
     
    insert newConsents;
      
  }

  public static String getContentTypeExternalId(String ctRecordTypeName) {
    for (String key : AGNGigyaConsentFactory.EMAIL_CONTENT_MAPPING.keySet()) {
      String value = AGNGigyaConsentFactory.EMAIL_CONTENT_MAPPING.get(key);
      if (value.equals(ctRecordTypeName)) {
        return key;
      }
    }
    return null;
  }

  public static Multichannel_Consent_vod__c getConsentFromVeeva(String accountId,
  String channelValue, String externalId, String mdmId,
  String ctRecordTypeName, String country, String language) {
    
      if (accountId == null && externalId == null) {
      system.debug('in this block');
          return null;
    }

    String contentTypeExternalId = null;
    if (AGNGigyaConsentFactory.EMAIL_BASED_CONSENTS.contains(ctRecordTypeName)) {
        
        contentTypeExternalId = getContentTypeExternalId(ctRecordTypeName);
        
    }

    List<Consent_Header_vod__c> chTemp = [SELECT Id FROM Consent_Header_vod__c
    WHERE Status_vod__c = 'Active_vod'
    AND Country_vod__r.Name = :country
    AND Language_vod__c = :language];
    
      
    List<Id> consentHeaders = new List<Id>();
    
    for (Consent_Header_vod__c ch : chTemp) {
      consentHeaders.add(ch.Id);
    }
    
    String query = 'SELECT Id, ' +
    'Account_vod__c, Account_vod__r.External_ID_vod__c, ' +
    'Account_vod__r.MDM_ID_AGN__c, ' +
    'Account_vod__r.LastName,Account_vod__r.Country_vod__r.Name, Account_vod__r.FirstName, ' +
    'Consent_Type_vod__c, Consent_Line_vod__c, ' +
    'Consent_Type_vod__r.Channel_Label_vod__c, ' +
    'RecordTypeId, ' +
    'Channel_Value_vod__c, ' +
    'Opt_Type_vod__c, CreatedDate, ' +
    'Content_Type_vod__c, ' +
    'Content_Type_vod__r.External_Id_vod__c, ' +
    'Consent_Type_vod__r.RecordType.DeveloperName ' +
    'FROM Multichannel_Consent_vod__c '; 
    
    String channelValueQuery = '';
    if (channelValue != null && channelValue.length() > 0) {
      channelValueQuery += 'AND Channel_Value_vod__c = :channelValue ';
    } else {
      channelValueQuery += 'AND Channel_Value_vod__c = \'\' ';
    }
    
   // comment due to change // query += 'WHERE ';
    query += 'AND ';
    query += '(';

    if (!String.isBlank(mdmId) && mdmId != 'null') {
      system.debug('in if');
        query += '(Account_vod__r.MDM_ID_AGN__c = :mdmId ' + channelValueQuery + ') ';
    } else if (!String.isBlank(externalId) && externalId != 'null') {
      system.debug('in 2nd if');
        query += '(Account_vod__r.External_ID_vod__c = :externalId ' + channelValueQuery + ') ';
    } else if (!String.isBlank(accountId) && accountId != 'null') {
     system.debug('in 3rd if'); 
     query += '(Account_vod__c = :accountId ' + channelValueQuery + ') ';
    } else {
      system.debug('in else');
        throw new AGNGigyaValidationException(-11, 'Impossible to find out the record because mdmId, externalId and sfdcId are blank.');
    }
    query += ') ';
    
    if (!String.isEmpty(contentTypeExternalId)) {
      system.debug('in if');
        query += 'AND Content_Type_vod__r.External_Id_vod__c = :contentTypeExternalId ';
    } else {
        system.debug('in else');      
        query += 'AND Consent_Type_vod__r.RecordType.DeveloperName = :ctRecordTypeName ';
    }

    query += 'AND Consent_Type_vod__r.Consent_Header_vod__c IN :consentHeaders ' + 'AND Account_vod__r.Country_vod__r.Name NOT IN (\'RU\',\'TR\')';

    query += 'ORDER BY CreatedDate DESC LIMIT 1';
    
      
    List<Multichannel_Consent_vod__c> res = Database.query(query);
   
      if (res.size() > 0) {
      system.debug('a----res.get(0)' +res.get(0));
      return res.get(0);
    }
      system.debug('a----returning null----->');
    return null;
  }

  public static String getValueNewGigyaObjectOrSetToEmpty(String veevaAccountField, String gigyaAccountField,
  String gigyaFieldName, List<String> fieldsToEmpty) {
    if (String.isEmpty(veevaAccountField)) {
      if(gigyaAccountField.length() > 0) {
        fieldsToEmpty.add(gigyaFieldName);
      }
    } else if (!gigyaAccountField.equals(veevaAccountField)) {
      System.debug(gigyaFieldName + ' is not the same');
      return veevaAccountField;
    }
    return null;
  }

  public static Boolean getBooleanValueNewGigyaObjectOrSetToEmpty(Boolean veevaAccountField, Boolean gigyaAccountField,
  String gigyaFieldName, List<String> fieldsToEmpty) {
    if (veevaAccountField == null) {
      if(gigyaAccountField != null) {
        fieldsToEmpty.add(gigyaFieldName);
      }
    } else if (gigyaAccountField != veevaAccountField) {
      System.debug(gigyaFieldName + ' is not the same');
      return veevaAccountField;
    }
    return null;
  }

  public static List<String> getEmailBasedConsents() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    List<String> EMAIL_BASED_CONSENTS = new List<String>();
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Email_Based_Consents_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    if (mtd != null && !String.isEmpty(mtd.Email_Based_Consents_AGN__c)) {
      for (String str : mtd.Email_Based_Consents_AGN__c.split(';')) {
        EMAIL_BASED_CONSENTS.add(str.trim());
      }
    }
      
    return EMAIL_BASED_CONSENTS;
  }
  public static String getApprovedEmailRecordType() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Approved_Email_Record_Type_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    return mtd.Approved_Email_Record_Type_AGN__c.trim();
  }
  public static String getUnsubscribeLinkOptOutEventType() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Unsubscribe_Link_Optout_Event_Type_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    return mtd.Unsubscribe_Link_Optout_Event_Type_AGN__c.trim();
  }
  public static List<String> getPhoneChannelSources() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    List<String> l = new List<String>();
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Phone_Channel_Sources_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    if (mtd != null && !String.isEmpty(mtd.Phone_Channel_Sources_AGN__c)) {
      for (String str : mtd.Phone_Channel_Sources_AGN__c.split(';')) {
        l.add(str.trim());
      }
    }
    return l;
  }
  public static List<String> getPhoneChannels() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    List<String> l = new List<String>();
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Phone_Channels_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    if (mtd != null && !String.isEmpty(mtd.Phone_Channels_AGN__c)) {
      for (String str : mtd.Phone_Channels_AGN__c.split(';')) {
        l.add(str.trim());
      }
    }
    return l;
  }

  public static Map<String, String> getContentTypeExtId_GigyaConsentIdMapping() {
    String gisan = Label.Gigya_Custom_Metadata_ApiName_AGN;
    Map<String, String> l = new Map<String, String>();
    Gigya_Integration_Setting_AGN__mdt mtd = [
    SELECT Content_Type_ExtId_Gigya_ConsentId_AGN__c
    FROM Gigya_Integration_Setting_AGN__mdt
    WHERE QualifiedApiName = :gisan
    LIMIT 1];
    if (mtd != null && !String.isEmpty(mtd.Content_Type_ExtId_Gigya_ConsentId_AGN__c)) {
      for (String row : mtd.Content_Type_ExtId_Gigya_ConsentId_AGN__c.split(';')) {
        String[] c = row.split(',');
        if (c.size() == 2) {
          l.put(c[0], c[1]);
        }
      }
    }
    return l;
  }

  public static AGNGigyaNotification getNewGigyaNotification(AGNgigyaNotification gigyaNotification, Account account, List<String> dataFieldsToEmpty) {
    AGNgigyaNotification newGigyaNotification = new AGNgigyaNotification();
    newGigyaNotification.setOid(gigyaNotification.getOid());
    // D005-2
    // if Privacy law Status is true
    //      and gigya notification GDPR Delete flag is false
    //      set Gigya GDPR Delete flag = true
    if (account.Privacy_Law_Status_AGN__c) {
      System.debug('--- privacy law status is true - no updates, but Privacy_Law_Status_AGN__c field is true');
      if (!gigyaNotification.getPrivacyLawStatus()) {
        System.debug('--- gdpr delete flag is false, then setting it as TRUE');
        newGigyaNotification.setPrivacyLawStatus(true);
      }
    } else {
      System.debug('--- privacy law status is false, then updating the notification');
      // D003
      // update notification fields
      // if a change occours in the fields below, a new records
      // is created in Gigya by AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA
      // 1. GDPR_Notification_Status_AGN__c
      // 2. Email_Template_Name_AGN__c
      newGigyaNotification.setLastName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.LastName, gigyaNotification.getLastName(), 'LastName', dataFieldsToEmpty));
      newGigyaNotification.setFirstName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.FirstName, gigyaNotification.getFirstName(), 'FirstName', dataFieldsToEmpty));
      newGigyaNotification.setExternalId(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.External_ID_vod__c, gigyaNotification.getExternalId(), 'External_ID_vod__c', dataFieldsToEmpty));
      newGigyaNotification.setSalutation(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Salutation, gigyaNotification.getSalutation(), 'Salutation', dataFieldsToEmpty));
      newGigyaNotification.setMiddleName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Middle_vod__c, gigyaNotification.getMiddleName(), 'Middle_vod__c', dataFieldsToEmpty));
      newGigyaNotification.setEmail(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.PersonEmail, gigyaNotification.getEmail(), 'Email', dataFieldsToEmpty));
      newGigyaNotification.setExternalId2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.External_ID2_AGN__c, gigyaNotification.getExternalId2(), 'External_ID2_AGN__c', dataFieldsToEmpty));
      newGigyaNotification.setCountryCode(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Country_vod__r.Name, gigyaNotification.getCountryCode(), 'Country_Code__c', dataFieldsToEmpty));
      newGigyaNotification.setCountryName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Country_Name_AGN__c, gigyaNotification.getCountryName(), 'Country_Name_AGN__c', dataFieldsToEmpty));
      newGigyaNotification.setSecondaryEmail(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Email_Internal_AGN__c, gigyaNotification.getSecondaryEmail(), 'SecondaryEmail', dataFieldsToEmpty));
      if (account.Email_Sent_Date_AGN__c != null) {
        newGigyaNotification.setEmailSentDate(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(String.valueOfGmt(account.Email_Sent_Date_AGN__c), gigyaNotification.getEmailSentDate(), 'Email_Sent_Date_AGN__c', dataFieldsToEmpty));
      }
      newGigyaNotification.setStatus(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Status_AGN__c, gigyaNotification.getStatus(), 'Status_AGN__c', dataFieldsToEmpty));
      newGigyaNotification.setAdditionalStatus(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Additional_Status_AGN__c, gigyaNotification.getAdditionalStatus(), 'Additional_Status_AGN__c', dataFieldsToEmpty));
      if (!String.isBlank(account.External_ID_vod__c) && account.External_ID_vod__c.startsWith('W')) {
        newGigyaNotification.setSpecialty1(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_1_AGN__r.Name, gigyaNotification.getSpecialty1(), 'Specialty_1_AGN__c', dataFieldsToEmpty));
        newGigyaNotification.setSpecialty2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_2_AGN__r.Name, gigyaNotification.getSpecialty2(), 'Specialty_2_AGN__c', dataFieldsToEmpty));
      } else {
        newGigyaNotification.setSpecialty1(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_Allergan_1_AGN__r.Name, gigyaNotification.getSpecialty1(), 'Specialty_1_AGN__c', dataFieldsToEmpty));
        newGigyaNotification.setSpecialty2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Sub_Specialty_Allergan_AGN__r.Name, gigyaNotification.getSpecialty2(), 'Specialty_2_AGN__c', dataFieldsToEmpty));
      }
      newGigyaNotification.setPrivacyLawStatus(AGNGigyaMCConsentUtil.getBooleanValueNewGigyaObjectOrSetToEmpty(account.Privacy_Law_Status_AGN__c, gigyaNotification.getPrivacyLawStatus(), 'GDPR_Delete_Flag', dataFieldsToEmpty));
    }
    return newGigyaNotification;
  }

  public static AGNGigyaAccount getNewGigyaAccount(AGNGigyaAccount gigyaAccount, Account account, List<String> profileFieldsToEmpty, List<String> dataFieldsToEmpty) {
    AGNGigyaAccount newGigyaAccount = new AGNGigyaAccount();
    newGigyaAccount.setUserId(gigyaAccount.getUserId());
	//AM Added by Brazil LGPD team to send account id to Gigya
      if(account.Country_vod__r.Name == 'BR'){
      newGigyaAccount.setId(gigyaAccount.getId());
      }
      //AM
    
      // D005-2
    // if Privacy law Status is true
    //      and gigya account GDPR Delete flag is false
    //      set Gigya GDPR Delete flag = true
    if (account.Privacy_Law_Status_AGN__c) {
      System.debug('--- privacy law status is true - no updates, but Privacy_Law_Status_AGN__c field is true');
      if (!gigyaAccount.getPrivacyLawStatus()) {
        System.debug('--- gdpr delete flag is false, then setting it as TRUE');
        newGigyaAccount.setPrivacyLawStatus(true);
      }
    } else {
      // D003
      newGigyaAccount.setFirstName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.FirstName, gigyaAccount.getFirstName(), 'firstName', profileFieldsToEmpty));
      newGigyaAccount.setLastName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.LastName, gigyaAccount.getLastName(), 'lastName', profileFieldsToEmpty));
      newGigyaAccount.setCountryName(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Country_Name_AGN__c, gigyaAccount.getCountryName(), 'country', profileFieldsToEmpty));
      newGigyaAccount.setStatus(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Status_AGN__c, gigyaAccount.getStatus(), 'Status_AGN__c', dataFieldsToEmpty));
      newGigyaAccount.setAdditionalStatus(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Additional_Status_AGN__c, gigyaAccount.getAdditionalStatus(), 'Additional_Status_AGN__c', dataFieldsToEmpty));
      newGigyaAccount.setSecondaryEmail(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Email_Internal_AGN__c, gigyaAccount.getSecondaryEmail(), 'SecondaryEmail', dataFieldsToEmpty));
      newGigyaAccount.setExternalId(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.External_ID_vod__c, gigyaAccount.getExternalId(), 'External_ID_vod__c', dataFieldsToEmpty));
      newGigyaAccount.setExternalId2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.External_ID2_AGN__c, gigyaAccount.getExternalId2(), 'External_ID2_AGN__c', dataFieldsToEmpty));
      newGigyaAccount.setMdmId(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.MDM_ID_AGN__c, gigyaAccount.getMdmId(), 'MDM_ID_AGN__c', dataFieldsToEmpty));
      newGigyaAccount.setCountryCode(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Country_vod__r.Name, gigyaAccount.getCountryCode(), 'Country_Code__c', dataFieldsToEmpty));
      if (!String.isBlank(account.External_ID_vod__c) && account.External_ID_vod__c.startsWith('W')) {
        newGigyaAccount.setSpecialty1(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_1_AGN__r.Name, gigyaAccount.getSpecialty1(), 'Specialty_1_AGN__c', dataFieldsToEmpty));
        newGigyaAccount.setSpecialty2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_2_AGN__r.Name, gigyaAccount.getSpecialty2(), 'Specialty_2_AGN__c', dataFieldsToEmpty));
      } else {
        newGigyaAccount.setSpecialty1(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Specialty_Allergan_1_AGN__r.Name, gigyaAccount.getSpecialty1(), 'Specialty_1_AGN__c', dataFieldsToEmpty));
        newGigyaAccount.setSpecialty2(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Sub_Specialty_Allergan_AGN__r.Name, gigyaAccount.getSpecialty2(), 'Specialty_2_AGN__c', dataFieldsToEmpty));
      }
      newGigyaAccount.setSalutation(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Salutation, gigyaAccount.getSalutation(), 'Salutation', dataFieldsToEmpty));
      newGigyaAccount.setPrivacyLawStatus(AGNGigyaMCConsentUtil.getBooleanValueNewGigyaObjectOrSetToEmpty(account.Privacy_Law_Status_AGN__c, gigyaAccount.getPrivacyLawStatus(), 'GDPR_Delete_Flag', dataFieldsToEmpty));
    }
      //AM Added by Brazil LGPD team to send distribution id and physician ref number to Gigya only for Brazil
      if(account.Country_vod__r.Name == 'BR'){
          if(!String.isBlank(account.Distribution_ID_AGN__c)) {
            newGigyaAccount.setDistributionID(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Distribution_ID_AGN__c, gigyaAccount.getdistributionID(), 'distributionID', dataFieldsToEmpty));
          }
      }
      if(account.Country_vod__r.Name == 'BR'){
          if(!String.isBlank(account.Physician_Registration_Reference_AGN__c)) {
            newGigyaAccount.setphysicianRefNumber(AGNGigyaMCConsentUtil.getValueNewGigyaObjectOrSetToEmpty(account.Physician_Registration_Reference_AGN__c, gigyaAccount.getphysicianRefNumber(), 'physicianRefNumber', dataFieldsToEmpty));
          }
      }
      //AM
    return newGigyaAccount;
  }
}