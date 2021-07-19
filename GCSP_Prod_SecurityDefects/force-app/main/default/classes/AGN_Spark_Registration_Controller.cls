global without sharing class AGN_Spark_Registration_Controller {
    
    
    /* This method is to get the Picklist values of Salutation field from the Allergan Customer Registration object based on the selected field. 
    It will get the values dynamically from the object. This will return the list of picklist values*/
    @AuraEnabled
    public static List<PicklistValues> getPickListValues(string objectType , String selectedField){
        Map<string, string> valuesMap = new Map<string, string>(AGN_SPARK_Utility.getPicklist(objectType , selectedField)); 
        List<PicklistValues> lstValues = new List<PicklistValues>();
        for(string pkVal:valuesMap.keySet()){
          PicklistValues pv = new PicklistValues(valuesMap.get(pkVal), pkVal);
          lstValues.add(pv);
        }
        return lstValues;
    }
    
    /*This method is to get the Picklist values from the country object based on the Custom settings AGN_SPARK_Enable_Countries__c and Country_Enabled__c field,
    It will restrict the country values. This will get the country values based on the custom setting creation for the particular country
    This method will return the list of picklist values*/  
    
    
    
    
    @AuraEnabled
    public static List<PicklistValues> getCountryList(string objectType , String selectedField , String selectedCountry){
        Map<string, string> valuesMap = new Map<string, string>(AGN_SPARK_Utility.getPicklist(objectType , selectedField)); 
        List<PicklistValues> lstValues = new List<PicklistValues>();
        
        /*
          Spark CR 2914
          Used custom list AGN_SPARK_Enabled_Countries__c in order to achieve Spark CR 2914
        */
        String[] sparkEnabledCountries ;
        List<AGN_SPARK_Enabled_Countries__c> enCountries;
        if(selectedCountry == null || selectedCountry == ''){
          enCountries = new List<AGN_SPARK_Enabled_Countries__c>([select id, Country_Enabled__c from AGN_SPARK_Enabled_Countries__c order by Country_Enabled__c]);
        }
        else{
          //Country_vod__c=:countryId
          enCountries = new List<AGN_SPARK_Enabled_Countries__c>([select id, Country_Enabled__c from AGN_SPARK_Enabled_Countries__c where Country_Enabled__c =: selectedCountry order by Country_Enabled__c]);
        }
        if(enCountries.size() > 0){
            sparkEnabledCountries = new String[enCountries.size()];
        }
        
        Integer count =0;
        for (AGN_SPARK_Enabled_Countries__c cont : enCountries) {
             sparkEnabledCountries[count] = cont.Country_Enabled__c; 
             count++;    
        }
        
        if(enCountries.size() == 0){
            for(string pkVal:valuesMap.keySet()){
              PicklistValues pv = new PicklistValues(valuesMap.get(pkVal), pkVal);
              lstValues.add(pv);
            }
        }
        else{
            for(String country : sparkEnabledCountries){
                PicklistValues pv = new PicklistValues(country, country);
                lstValues.add(pv);
            }
            
        }
        return lstValues;
    }
  
    public class PicklistValues{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        public PicklistValues(string labels,string values){
            label = labels;
            value = values;
        } 
    }
        
    /* This method is created to get the selected values from the registration from in the form of objects.
     * In this Case, Account, Allergan Customer Registration, Allergan Customer Address, Contact & User records and initiates the DCR process    *  
       This method will return the Account Id back to the Helper class for the user creation*/          
    @AuraEnabled
    public static string selfRegister(Allergan_Customer_Registration_AGN__c customerDetail, Allergan_Customer_Address_AGN__c addDetail, Account accountDetails, String mCMarketing, String mCEvent, String mCPhone, String email, String salutation, String custCountry, String addCountry, String phoneNum) { 
        
        
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            /*Insertion of case*/
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Request - SPARK Customer Registration').getRecordTypeId();
            Case cs = new Case();
            if(Schema.sObjectType.Case.fields.Status.isCreateable()){   //cc_AD
                cs.Status = 'New';
            }
            if(Schema.sObjectType.Case.fields.RecordTypeId.isCreateable()){   //cc_AD
                cs.RecordTypeId = devRecordTypeId;
            }
            
            if(Schema.SObjectType.Case.isCreateable()){ //cc_AD
              insert cs;
            }
            
            /*For Account Insertion we need an owner, from the Custom setting we are getting the system admin id*/
            AGN_SPARK_Settings__c obj = AGN_SPARK_Utility.SPARK_SETTINGS ;
            
            /*Insertion of Person Account*/
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
            if(Schema.sObjectType.Account.fields.RecordTypeId.isCreateable()){  //cc_AD
                accountDetails.RecordTypeId         = accRecordTypeId;
            }
            
            if(Schema.sObjectType.Account.fields.OwnerId.isCreateable()){    //cc_AD
                accountDetails.OwnerId              = obj.SPARK_Admin_UserId__c;
            }
            
            if(Schema.sObjectType.Account.fields.PersonEmail.isCreateable()){   //cc_AD
                accountDetails.PersonEmail          = email;
            }
            
            if(Schema.sObjectType.Account.fields.Salutation.isCreateable()){   //cc_AD
                accountDetails.Salutation           = salutation;
            }
            
            if(Schema.sObjectType.Account.fields.AGN_SPARK_Account__c.isCreateable()){  //cc_AD
                accountDetails.AGN_SPARK_Account__c = True;
            }
            
            if(Schema.SObjectType.Account.isCreateable()){  //cc_AD
                Insert accountDetails;
			}
            
            System.debug('Testing after account details insertion' + accountDetails);
            
            /*Inorder to get the Country Id we are querying the Country object based on 
            the Allergan customer Registration country*/
            
            Id customerCountryId;
            String customerCountryCode;
            String langCode;
            
            System.debug('Customer country value -- ' + custCountry);
            /*
              Spark CR 2914
              Customer for country Ireland will be treated as United Kingdom. Saves the record under GB except user country code. 
            */
           
            
            for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:custCountry]){
                customerCountryId   = count.Id;
                customerCountryCode = count.Country_Name_vod__c;
            }
            
            If(custCountry != null && custCountry.equals('Ireland')){
               //custCountry = 'United Kingdom';
               customerCountryCode = 'GB';
            }
             
            System.debug('Testing after country query Customer country id' + customerCountryId +' Country code '+  customerCountryCode  );  
            
            /*Inorder to get the Country code we are querying the AMI_Language_AGN__c custom setting based on 
            the Allergan customer Registration country*/
            
            //String custCountryCode = 'GB';
            /*
              Spark CR 2914
              Customer for country Ireland will be treated as United Kingdom. Saves the record under GB except user country code. 
            */
           
            /*System.debug('Customer code equals '+ customerCountryCode.equals('IE'));
            if('IE'.equals(customerCountryCode)){
              custCountryCode = 'GB';
            }*/
            
            System.debug('Testing after country query Customer country id' + customerCountryId +' Country code '+  customerCountryCode );
            //AMI_Language_AGN__c lang=[select Lang_Code__c from AMI_Language_AGN__c where Country__c=:custCountryCode limit 1];
            AMI_Language_AGN__c lang=[select Lang_Code__c from AMI_Language_AGN__c where Country__c=:customerCountryCode limit 1];
            langCode = lang.Lang_Code__c;
            
            /*Insert Multichannel consent Insert-Start*/
            /*This method is created to insert the Multichannel records based on the selection of user in the registration form */
            /*For Ireland customers use the consent of United Kingdom. This logic is implemented explicitely for Ireland customer */
            
            If(custCountry != null && custCountry.equals('Ireland')){
                String countryIdRemap;
               for(Country_vod__c country : [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:'United Kingdom']){
                  countryIdRemap   = country.Id;
                }
                updateConsent(accountDetails.id,mCEvent,mCMarketing,email,langCode,mCPhone,countryIdRemap,phoneNum);
            }
            else{
                updateConsent(accountDetails.id,mCEvent,mCMarketing,email,langCode,mCPhone,customerCountryId,phoneNum);
            }
            
            /*Insert Multichannel consent Insert-End*/
            System.debug('Testing--'+accountDetails.id);
            System.debug(mCEvent);
            System.debug(mCMarketing);
            System.debug(email);
            System.debug(langCode);
            System.debug(mCPhone);
            System.debug(' Log customercountry id '+customerCountryId);
            System.debug(phoneNum);
            System.debug('Testing before cust detail');
            /*Insertion of Allergan Customer Registration record based on the Registration form*/
            Id custRecordTypeId = Schema.SObjectType.Allergan_Customer_Registration_AGN__c.getRecordTypeInfosByName().get('New SPARK').getRecordTypeId();
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Case_AGN__c.isCreateable()){
                customerDetail.Case_AGN__c = cs.Id;
            }    
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Account_AGN__c.isCreateable()){
                customerDetail.Account_AGN__c = accountDetails.id;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Salutation_AGN__c.isCreateable()){
                customerDetail.Salutation_AGN__c = accountDetails.Salutation;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.First_Name_AGN__c.isCreateable()){
                customerDetail.First_Name_AGN__c = accountDetails.FirstName;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Last_Name_AGN__c.isCreateable()){
                customerDetail.Last_Name_AGN__c = accountDetails.LastName;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Phone_AGN__c.isCreateable()){
                customerDetail.Phone_AGN__c = accountDetails.Phone;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.RecordTypeId.isCreateable()){
                customerDetail.RecordTypeId = custRecordTypeId;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Email_AGN__c.isCreateable()){
                customerDetail.Email_AGN__c = email;
            } 
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Portal_Access_AGN__c.isCreateable()){
                customerDetail.Portal_Access_AGN__c = 'Spark';
            }
            customerDetail.Account_Status_AGN__c = 'Active';
            System.debug('Customer country id '+ customerCountryId);
            //if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Country_AGN__c.isCreateable()){
                System.debug('Inside Customer country id '+ customerCountryId);
                customerDetail.Country_AGN__c = customerCountryId;
            //}
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Country_Code_AGN__c.isCreateable()){
                customerDetail.Country_Code_AGN__c = customerCountryCode;
            }
            if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.Language_AGN__c.isCreateable()){
                customerDetail.Language_AGN__c = lang.Lang_Code__c;
            }
            
            if(Schema.SObjectType.Allergan_Customer_Registration_AGN__c.isCreateable()){   //cc_AD
                try{
                   insert customerDetail;    
                }
                Catch(DmlException ex){
                    System.debug('Customer registration data ' + customerDetail);
					System.debug('Error occurred during customer registration insertion '+ ex.getMessage());                    
                }
                
			}
            
            
            System.debug('Testing after customer details insertion' + customerDetail);
            
            /*Insertion of Allergan Customer Address record based on the Registration form*/
            Id custAddRecordTypeId  = Schema.SObjectType.Allergan_Customer_Address_AGN__c.getRecordTypeInfosByName().get('New SPARK').getRecordTypeId();
            if(Schema.sObjectType.Allergan_Customer_Address_AGN__c.fields.Parent_AGN__c.isCreateable()){   //cc_AD
              addDetail.Parent_AGN__c = customerDetail.id;
            }
            if(Schema.sObjectType.Allergan_Customer_Address_AGN__c.fields.RecordTypeId.isCreateable()){   //cc_AD
               addDetail.RecordTypeId  = custAddRecordTypeId;
            }
            if(Schema.sObjectType.Allergan_Customer_Address_AGN__c.fields.Country_AGN__c.isCreateable()){   //cc_AD
                addDetail.Country_AGN__c= addCountry;
            }    
            
            if(Schema.sObjectType.Allergan_Customer_Address_AGN__c.fields.Email_AGN__c.isCreateable()){   //cc_AD
                addDetail.Email_AGN__c = customerDetail.Email_AGN__c;
            }    
            
            if(Schema.sObjectType.Allergan_Customer_Address_AGN__c.fields.Phone_AGN__c.isCreateable()){   //cc_AD
                addDetail.Phone_AGN__c = customerDetail.Phone_AGN__c;
            }    
            
            System.debug('Allergan customer address ' + addDetail);
            if(Schema.SObjectType.Allergan_Customer_Address_AGN__c.isCreateable()){ //cc_AD
              System.debug('Inside Allergan customer address ' + addDetail);
                try{
                  insert addDetail;  
                }
                Catch(DmlException ex){
                    System.debug('Error occurred during customer address insertion '+ ex.getMessage());
                }
              
            }
            
            System.debug('Testing after customer details insertion' + customerDetail);
            
            
            /*Calling the DCR Process Starts*/
            AGN_SPARK_CRO_ProcessUtility.Process(customerDetail);
            /*Calling the DCR Process Ends*/
            System.debug('Testing after processing utility');
            
            System.debug('Account Id:--' +accountDetails.id);
            return accountDetails.id;
    
        }
        catch (Exception ex) {
            Database.rollback(sp);
            System.debug('Error during account creation '+ex.getMessage());
            Error_Log_AGN__c errorLog =  AGN_SPARK_ErrorLogHandler.createExceptionsLog(ex, 'AGN_SPARK_ErrorLogHandler');
            return ex.getMessage();   
            
                    
        }
    }
    // @future
    // Updating consent data to Veeva consent Module
    /* This method is created to insert the Multichannel records based on the consent checkbox selection of user in the registration form*/
    public static void updateConsent(Id accountId,String mCEvent, String mCMarketing,String email, String lang, String mCPhone, id countryId, String phone){ 
        Id consentMarRecordTypeId   =  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Approved Email').getRecordTypeId();
       Id consentEveRecordTypeId   =  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Approved Email').getRecordTypeId();
       //Id consentEveRecordTypeId   =  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Allergan Event').getRecordTypeId();
      Id consentPhnRecordTypeId   =  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Phone').getRecordTypeId();
        
        Map<String, Consent_Type_vod__c> cnstMap = new Map<String, Consent_Type_vod__c>();
        Map<String, Consent_Line_vod__c> cnstLnMap = new Map<String, Consent_Line_vod__c>();
        System.debug('Query executed language ' +lang +'Country Id '+countryId);
        for (Consent_Type_vod__c ct : [Select Id, Consent_Header_vod__r.Language_vod__c,Consent_Header_vod__r.Status_vod__c,Consent_Header_vod__r.Country_vod__c,Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c,zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName,(Select Id, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r) from Consent_Type_vod__c where Consent_Header_vod__r.Status_vod__c='Active_vod' AND Consent_Header_vod__r.Language_vod__c=:lang AND Consent_Header_vod__r.Country_vod__c=:countryId]){
            for(Consent_Line_vod__c cl : ct.Consent_Type_vod__r) {
                cnstLnMap.put(cl.Content_Type_Display_Name_vod__c, cl);
            } 
            cnstMap.put(ct.RecordType.DeveloperName, ct);
        }
        if (mCEvent == 'true'){
            try{
                Consent_Type_vod__c ct = new Consent_Type_vod__c();
                ct = cnstMap.get('Approved_Email_vod');
                
                Consent_Line_vod__c cl = new Consent_Line_vod__c();
                cl = cnstLnMap.get('Allergan Event Invite & Registration Consent');
               if(ct != null || cl != null){ 
                Multichannel_Consent_vod__c mEvent = new Multichannel_Consent_vod__c();
                if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
                    mEvent.RecordTypeId = consentEveRecordTypeId;
				}   
                if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){  //cc_AD
                    mEvent.Account_vod__c = accountId;
                }    
                
                mEvent.Capture_Datetime_vod__c     = System.now();
                mEvent.Signature_Datetime_vod__c   = System.now();
                mEvent.Channel_Value_vod__c        = email;
                if(ct != null){
                   mEvent.Consent_Type_vod__c         = ct.id;
                }
                if(cl != null){
                  mEvent.Content_Type_vod__c         = cl.Content_Type_vod__c; 
                  mEvent.Consent_Line_vod__c         = cl.id;
                }
                mEvent.Opt_Type_vod__c             = 'Opt_In_vod';
                if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
                  insert mEvent;
                }
                }
            }catch(DmlException e){
                Error_Log_AGN__c errorLog =  AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_ErrorLogHandler');
            }
        }
        
        if (mCMarketing == 'true'){
             try{
             
                 Consent_Type_vod__c ct = new Consent_Type_vod__c();
                 ct = cnstMap.get('Approved_Email_vod');
                 
                 Consent_Line_vod__c cl = new Consent_Line_vod__c();
                 cl = cnstLnMap.get('Product and Service Direct Marketing Consent – E-mail');
                if(ct != null || cl != null){ 
                 Multichannel_Consent_vod__c mMarketing = new Multichannel_Consent_vod__c();
                 if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
                     mMarketing.RecordTypeId = consentMarRecordTypeId;
                 }    
                 if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){  //cc_AD
                     mMarketing.Account_vod__c = accountId;
                 }    
                 
                 mMarketing.Capture_Datetime_vod__c     = System.now();
                 mMarketing.Signature_Datetime_vod__c   = System.now();
                 mMarketing.Channel_Value_vod__c        = email;
                 if(ct != null){
                   mMarketing.Consent_Type_vod__c         = ct.id;
                 }
                  if(cl != null){
                    mMarketing.Content_Type_vod__c         = cl.Content_Type_vod__c;
                    mMarketing.Consent_Line_vod__c         = cl.id;   
                 }                     
                 mMarketing.Opt_Type_vod__c            = 'Opt_In_vod';
                 if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
                    insert mMarketing;
                 }    
                }
             }catch(DmlException e){
                Error_Log_AGN__c errorLog =  AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_ErrorLogHandler');
            }
        }
        
        if (mCPhone == 'true'){
            try{
                Consent_Type_vod__c ct = new Consent_Type_vod__c();
                ct = cnstMap.get('Phone_AGN');
                
                if(ct != null){ 
                Multichannel_Consent_vod__c mPhone = new Multichannel_Consent_vod__c();
                if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
                    mPhone.RecordTypeId = consentPhnRecordTypeId;
                }    
                if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){  //cc_AD
                    mPhone.Account_vod__c = accountId;
                }    
                
                mPhone.Capture_Datetime_vod__c     = System.now();
                mPhone.Signature_Datetime_vod__c   = System.now();
                mPhone.Channel_Value_vod__c        = phone;
                mPhone.Consent_Type_vod__c         = ct.id;                     
                mPhone.Opt_Type_vod__c             = 'Opt_In_vod';
                if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
                    insert mPhone;
				}    
                
                }
            }catch(DmlException e){
                Error_Log_AGN__c errorLog =  AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_ErrorLogHandler');
            }
        }
    }
    
       /*This method is created for the Community user creation*/
    @AuraEnabled
    public static String communityUserCreation(Allergan_Customer_Registration_AGN__c customerDetail, String accountId, String email, String userName, Account accountDetails, string custCountry) {        
        
        /*Inorder to get the Country Id we are querying the Country object based on 
            the Allergan customer Registration country*/
            Id customerCountryId;
            String customerCountryCode;
            String userCountryCode;
            String langCode;
            System.debug('Testing before query on country '+ custCountry);
            for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:custCountry]){
                customerCountryId   = count.Id;
                customerCountryCode = count.Country_Name_vod__c;
                userCountryCode = count.Country_Name_vod__c;
            }
            
            /*
              Spark CR 2914
              Customer for country Ireland will be treated as United Kingdom. Saves the record under GB except user country code.
              usr.Country_code__c     = customerCountryCode; Line no - 378
              usr.MA_User_Country_Code_AGN__c = userCountryCode ; Line no - 379
            */
            
            if(userCountryCode != null && userCountryCode.equals('IE')){
               customerCountryCode = 'GB';
            }
            
            //System.debug('Testing after query on customer country '+ customerCountryCode+' User country code '+ userCountryCode + 'Country ' + customerCountryId +' Cust country'+ custCountry);
        
        //AGN_SPARK_User_Settings__c userSetting = AGN_SPARK_Utility.SPARK_USER_SETTINGS; AGN_SPARK_User_Setting__c.getValues('GB');
        AGN_SPARK_User_Setting__c userSetting =  [SELECT id, Name,User_Language__c,Email_Encoding__c,User_Locale__c,User_Timezone__c,User_Profile__c FROM AGN_SPARK_User_Setting__c WHERE Name =: customerCountryCode];
        Boolean isSuccess = true;
        String message ='created';
        //System.debug('Newly created accountID '+ accountId );
        System.debug('Testing before user object creation '+ userSetting );
        try{
        /*This query is created to get the Profile Id from the custom settings*/    
        Profile comProfile  = [SELECT Id FROM Profile WHERE Name =:userSetting.User_Profile__c];
        
        AccountContactRelation acrL = [SELECT ContactId, AccountId FROM AccountContactRelation WHERE AccountId = :accountId];    
        
        System.debug('Testing before user creation account contact relation' + acrL );                    
        //User Insertion
         User usr            = new User();
       
           
        usr.Username        = userName;
        usr.ProfileId       = comProfile.id;
        usr.FirstName       = accountDetails.FirstName;
        usr.LastName        = accountDetails.LastName;
        usr.ContactId       = acrL.ContactId;  
        
        //below section of code is blocked in order to avoid user creation failed as this section of code can't generate unique alias name
        // in every condition
        
        /*string alias = '';
        if (usr.FirstName.length() > 0){
            alias += usr.FirstName.substring(0, 1);
        }
            
        if(usr.LastName.length()>0){
            alias += usr.LastName.substring(0,Math.min(usr.LastName.length(), 4));
        }
            
        // Alias uniqueness handling
        integer existingUserCount = [SELECT COUNT() FROM User WHERE SMB_Alias_External_Id__c LIKE :alias + '%'];
        System.debug('Testing after existing user count ' + existingUserCount );
        if(existingUserCount > 0){
            alias += existingUserCount;
            
        }*/     
        
        String nickname = ((accountDetails.FirstName != null && accountDetails.LastName.length() > 0) ? accountDetails.FirstName.substring(0,1) : '' ) + accountDetails.LastName.substring(0,1);
        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
        usr.put('CommunityNickname', nickname);
        
        /*
          commented out line 338 - 353
          generateAliasName method created to generate unique alias name
          
        */
        //usr.Alias = alias;
        usr.Alias = AGN_SPARK_Register_Utility.generateAliasName(usr.FirstName , usr.LastName);  
        usr.LanguageLocaleKey   = userSetting.User_Language__c;
        usr.EmailEncodingKey    = userSetting.Email_Encoding__c;      
        usr.LocalesIdKey        = userSetting.User_Locale__c;
        usr.TimezonesIdKey      = userSetting.User_Timezone__c;
        usr.Email               = email;
        usr.Country_code__c     = customerCountryCode;
        usr.MA_User_Country_Code_AGN__c = userCountryCode ;
        System.debug('Testing just before user insertion ' + usr); 
        if(Schema.SObjectType.User.isCreateable()){ //cc_AD
           insert usr;
        }
        
        System.debug('Testing after insertion successful.');
        System.debug('Testing after user creation ' + usr);  
        
        /*This query is created for selecting the Allergan customer registration record based on the account id*/    
        Allergan_Customer_Registration_AGN__c acr = [SELECT Id FROM Allergan_Customer_Registration_AGN__c WHERE Account_AGN__r.Id = :accountId];
        
        /*This instance is created to share the Allergan customer registration record to the community user*/
        AGN_SPARK_SharingACRRecords.setACRAccessForUser(acr.Id, usr.id);
        System.debug('Testing after acr records creation ' ); 
        message = ''+ usr.id;
        }catch(Exception e){
            isSuccess = false;
            Error_Log_AGN__c errorLog =  AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_ErrorLogHandler');
            message = 'Unexpected error occured';
            
            //rollbackAllreferences(accountDetails);
            
        }
        return '{"success":'+isSuccess+', "message":"'+message+'"}';
    }
    
    /*This method is used for the Complete my profile popup box, once it is filled, 
    it will update the allergan customer registration record*/
    @AuraEnabled
    public static String updateMyProfile(Allergan_Customer_Registration_AGN__c updateDetail, String acrId) {
       updateDetail.Id                              = acrId;
       if(Schema.sObjectType.Allergan_Customer_Registration_AGN__c.fields.AGN_SPARK_Update_my_Profile__c.isUpdateable()){    //cc_AD 
          updateDetail.AGN_SPARK_Update_my_Profile__c  = True;
       }
       if(Schema.SObjectType.Allergan_Customer_Registration_AGN__c.isUpdateable()){  //cc_AD
         Update updateDetail;     
       } 
       
       return updateDetail.Id;
    }
    
    /*This method is created for checking the user's email is already registered in any profile*/
    @AuraEnabled
    public static String checkUserNameExist(String userName) {
       List<User> usr = [SELECT Id, Username FROM User WHERE Username =: userName];
        String st;
        if(!usr.isEmpty()){        
            
         st=usr[0].Id;

                          }   
        else{
            st=null;
        }
    return st;
    }
    
    /*This method is created for checking the user's email is already registered for Spark*/
    @AuraEnabled
    public static String checkUserExist(String userEmail) {
       List<User> usr = [SELECT Id, Email FROM User WHERE Email =: userEmail AND Profile.Name='Spark Community Profile'];
        String st;
        if(!usr.isEmpty()){        
            
         st=usr[0].Id;

                          }   
        else{
            st=null;
        }
    return st;
    }
    
    
    
    
    //newly introduced method to delete all refrences of account and related list if user creation has failed by any reason. This helps
    //to remove duplicate account records
    public static void deleteRecordById(String field1 , Id param1 , String field2 , Id param2 , String fromObject){
       Id removeId;
       String query = 'SELECT Id ';
                 query += 'FROM ' + fromObject + ' ';
            query += 'WHERE '+field1+' = \'' + param1 + '\' ';
            if(field2 != null){
               query += ' AND '+field2+' = \'' + param2 + '\' ';
             }
            query += 'LIMIT 1';

        List<SObject> listToRemove = Database.query(query);

        delete listToRemove;
    }
    
        
    }