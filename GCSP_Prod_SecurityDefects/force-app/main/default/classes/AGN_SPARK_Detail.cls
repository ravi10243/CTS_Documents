public without sharing class AGN_SPARK_Detail {
    @Auraenabled
    public static userDetails userDetailData(){
      //  :UserInfo.getUserId()
        Id accountId;
        Id contactId;
        user userData ;
        String email;
        for(user u :[SELECT Name,userName,Email,ContactId FROM User WHERE Id =: UserInfo.getUserId() ])
        {
            contactId = u.ContactId;
            email = u.Email;
            userData = u;
        }
        system.debug('contactId>>>>>>>' + contactId);
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
        for(AccountContactRelation acrL : [SELECT ContactId, AccountId FROM AccountContactRelation WHERE ContactId = :contactId AND Account.recordTypeId =:accRecordTypeId AND Account.isPersonAccount = true]){
            system.debug('acrLcontact>>>>>>>' + acrL.AccountId);
        	accountId = acrL.AccountId;
        }
        
        system.debug('userData>>>>>'+ userData);
        system.debug('AccountId'+ accountId);
        Allergan_Customer_Address_AGN__c addressDetails;
        Allergan_Customer_Registration_AGN__c userDetail ;
        Multichannel_Consent_vod__c mulChnl;
        system.debug('AccountId>>>>>>>'+ accountId);
        for (Allergan_Customer_Registration_AGN__c details:[SELECT Id,Name,	Registration_License_Number_AGN__c,Phone_AGN__c,Profession_Spark_AGN__C,Account_AGN__c ,Last_Name_AGN__c,First_Name_AGN__c,Independent_Prescriber_Spark_AGN__c,Accepted_Spark_privacy_policy_AGN__c,Number_Of_Aesthetics_Patients_Spark_AGN__c,Days_Per_Week_Spark_AGN__c,Planed_Days_Per_Week_Spark_AGN__c,Aesthetics_Stage_Spark_AGN__c,Current_Practice_Locations_Spark_AGN__c, (SELECT Id,Address_Line_1_AGN__c,Zip_AGN__c,Address_Line_2_AGN__c,City_AGN__c,Country_AGN__c from Allergan_Customer_Addresses__r) FROM Allergan_Customer_Registration_AGN__c WHERE Account_AGN__r.Id = :accountId])
        {
           userDetail =  details;
            system.debug('userDetail'+ userDetail);
            for(Allergan_Customer_Address_AGN__c addDtls :details.Allergan_Customer_Addresses__r){
                addressDetails = addDtls;
                system.debug('addressDetails'+ addressDetails);
            }
        }
        
        
        id  customerCountryId ;
        String customerCountryCode;
        String langCode;
        String countryName = addressDetails.Country_AGN__c;
		If('Ireland'.equals(countryName)){
			countryName = 'United Kingdom';
		}
		
        for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:countryName ]){
            customerCountryId 	= count.Id;
            customerCountryCode = count.Country_Name_vod__c;
        }
        
        
        /*for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:addressDetails.Country_AGN__c ]){
            customerCountryId 	= count.Id;
            customerCountryCode = count.Country_Name_vod__c;
        }
        if('IE'.equals(customerCountryCode)){
           customerCountryCode = 'GB';
        }*/
        AMI_Language_AGN__c lang=[select Lang_Code__c from AMI_Language_AGN__c where Country__c=:customerCountryCode limit 1];
        langCode = lang.Lang_Code__c;
        Map<String, Consent_Type_vod__c> cnstMap = new Map<String, Consent_Type_vod__c>();
        Map<String, Consent_Line_vod__c> cnstLnMap = new Map<String, Consent_Line_vod__c>();
        System.debug('Lang code '+ langCode +' , Customer countryId ' + customerCountryId);
        for (Consent_Type_vod__c ct : [Select Id, Consent_Header_vod__r.Language_vod__c,Consent_Header_vod__r.Status_vod__c,Consent_Header_vod__r.Country_vod__c,Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c,zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName,(Select Id, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r) from Consent_Type_vod__c where Consent_Header_vod__r.Status_vod__c='Active_vod' AND Consent_Header_vod__r.Language_vod__c=:langCode AND Consent_Header_vod__r.Country_vod__c=:customerCountryId]){
            for(Consent_Line_vod__c cl : ct.Consent_Type_vod__r) {
                cnstLnMap.put(cl.Content_Type_Display_Name_vod__c, cl);
            } 
            cnstMap.put(ct.RecordType.DeveloperName, ct);
        }
        
        
        Consent_Line_vod__c clMark = new Consent_Line_vod__c();
        clMark = cnstLnMap.get('Product and Service Direct Marketing Consent – E-mail');
        
        
        Consent_Line_vod__c clEvent = new Consent_Line_vod__c();
        clEvent = cnstLnMap.get('Allergan Event Invite & Registration Consent');
        
           
        Multichannel_Consent_vod__c mchMark = new Multichannel_Consent_vod__c();
        for (Multichannel_Consent_vod__c multiChannel:[SELECT Id, Opt_Type_vod__c,Content_Type_vod__c  FROM Multichannel_Consent_vod__c WHERE Account_vod__r.Id = :accountId AND Content_Type_vod__c =:clMark.Content_Type_vod__c order by createdDate DESC limit 1])
        {
           mchMark =  multiChannel;
        }
        
        
		Multichannel_Consent_vod__c mchEvent = new Multichannel_Consent_vod__c();
        for (Multichannel_Consent_vod__c multiChnl:[SELECT Id, Opt_Type_vod__c, Content_Type_vod__c  FROM Multichannel_Consent_vod__c WHERE Account_vod__r.Id = :accountId AND 	Content_Type_vod__c =:clEvent.Content_Type_vod__c order by createdDate DESC limit 1])
        {
           mchEvent =  multiChnl;
        }
        
        
        Consent_Type_vod__c ctPh = new Consent_Type_vod__c();
        ctPh = cnstMap.get('Phone_AGN');
        
        
        Multichannel_Consent_vod__c mchPhone = new Multichannel_Consent_vod__c();
        for (Multichannel_Consent_vod__c multiChnl:[SELECT Id, Opt_Type_vod__c, Consent_Type_vod__c  FROM Multichannel_Consent_vod__c WHERE Account_vod__r.Id = :accountId AND 	Consent_Type_vod__c =:ctPh.id order by createdDate DESC limit 1])
        {
           mchPhone =  multiChnl;
        }
        
        
        userDetails s = new userDetails(userDetail,addressDetails,userData,mchMark.Opt_Type_vod__c,mchEvent.Opt_Type_vod__c, mchPhone.Opt_Type_vod__c);
        
        return s ;
    }
    
    public class userDetails{
        @auraenabled public Allergan_Customer_Registration_AGN__c userData {get; set;}
        @auraenabled public Allergan_Customer_Address_AGN__c addressDetails {get; set;}
        @auraenabled public user userDetailed {get; set;}
		@auraenabled public Boolean mcMark {get; set;}
        @auraenabled public Boolean mcEvent {get; set;}
        @auraenabled public Boolean mcMarkUpt {get; set;}
        @auraenabled public Boolean mcEventUpt {get; set;}
        @auraenabled public Boolean mcPhone {get; set;}
        @auraenabled public Boolean mcPhoneUpt {get; set;}
        
        
        public userDetails (Allergan_Customer_Registration_AGN__c regData ,Allergan_Customer_Address_AGN__c addDetails,user usrDetails, String mulChnMar, String mulChnEvt, String mulChnPhn)
        {
            userData 		= regData;
            addressDetails 	= addDetails;
            userDetailed 	= usrDetails;
            if(mulChnMar == 'Opt_In_vod'){
                mcMark = True;
                mcMarkUpt = True;
            }else{
                mcMark = False;
                mcMarkUpt = False;
            }
            if(mulChnEvt == 'Opt_In_vod'){
                mcEvent = True;
                mcEventUpt= True;
            }else{
                mcEvent = False;
                mcEventUpt= False;
            }
            if(mulChnPhn == 'Opt_In_vod'){
                mcPhone		= True;
                mcPhoneUpt	= True;
            }else{
                mcPhone		= False;
                mcPhoneUpt	= False;
            }
            
        }
        public userDetails(){
            
        }
        
        
    }
    @AuraEnabled
   public static Map<String, String> getImages(){
        Map<String, String> imageMap = AGN_SPARK_Utility.getImageURL('EditMyProfilePage');
        return imageMap;
    }
    
    
    @Auraenabled
    Public static void updateDetails(userDetails usrDetails){
        Id accountId;
        Id contactId;
        user userData ;
        String email;
        for(user u :[SELECT Name,userName,Email,ContactId FROM User WHERE Id =: UserInfo.getUserId() ])
        {
            contactId = u.ContactId;
            email = u.Email;
            userData = u;
        }
        system.debug('contactId>>>>>>>' + contactId);
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
        for(AccountContactRelation acrL : [SELECT ContactId, AccountId FROM AccountContactRelation WHERE ContactId = :contactId AND Account.recordTypeId =:accRecordTypeId]){
            system.debug('acrLcontact>>>>>>>' + acrL.AccountId);
        	accountId = acrL.AccountId;
        }
        
      
        Allergan_Customer_Address_AGN__c addDetails = usrDetails.addressDetails;
       	Allergan_Customer_Registration_AGN__c regData = usrDetails.userData;
        user userDetail = usrDetails.userDetailed;
        
        
		id  customerCountryId ;
        String customerCountryCode;
        String langCode;
        /*for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:addDetails.Country_AGN__c ]){
            customerCountryId 	= count.Id;
            customerCountryCode = count.Country_Name_vod__c;
        }*/
        
        String countryName = addDetails.Country_AGN__c;
		If('Ireland'.equals(countryName)){
			countryName = 'United Kingdom';
		}
		
        for(Country_vod__c count: [SELECT Id,Country_Name_vod__c FROM Country_vod__c WHERE AGN_Country_Name__c =:countryName ]){
            customerCountryId 	= count.Id;
            customerCountryCode = count.Country_Name_vod__c;
        }
        
        
        AMI_Language_AGN__c lang=[select Lang_Code__c from AMI_Language_AGN__c where Country__c=:customerCountryCode limit 1];
        langCode = lang.Lang_Code__c;
        
        
        Map<String, Consent_Type_vod__c> cnstMap = new Map<String, Consent_Type_vod__c>();
        Map<String, Consent_Line_vod__c> cnstLnMap = new Map<String, Consent_Line_vod__c>();
        
        for (Consent_Type_vod__c ct : [Select Id, Consent_Header_vod__r.Language_vod__c,Consent_Header_vod__r.Status_vod__c,Consent_Header_vod__r.Country_vod__c,Channel_Label_vod__c, RecordTypeId, Consent_Header_vod__c, Disclaimer_Text_vod__c, Display_Order_vod__c,zvod_Consent_Default_Consent_Text_vod__c, RecordType.DeveloperName,(Select Id, Content_Type_Display_Name_vod__c, Content_Type_vod__c, Content_Type_vod__r.External_Id_vod__c From Consent_Type_vod__r) from Consent_Type_vod__c where Consent_Header_vod__r.Status_vod__c='Active_vod' AND Consent_Header_vod__r.Language_vod__c=:langCode AND Consent_Header_vod__r.Country_vod__c=:customerCountryId]){
            for(Consent_Line_vod__c cl : ct.Consent_Type_vod__r) {
                cnstLnMap.put(cl.Content_Type_Display_Name_vod__c, cl);
            } 
            cnstMap.put(ct.RecordType.DeveloperName, ct);
        }
              
        
        Id consentMarRecordTypeId	=  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Approved Email').getRecordTypeId();
        Id consentEveRecordTypeId	=  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Allergan Event').getRecordTypeId();
        Id consentPhnRecordTypeId	=  Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByName().get('Phone').getRecordTypeId();
        
        
        if(usrDetails.mcMark != usrDetails.mcMarkUpt){
            updateConsent( accountId, usrDetails.mcMarkUpt, email, cnstMap, cnstLnMap, consentMarRecordTypeId);
        }
        if(usrDetails.mcEvent != usrDetails.mcEventUpt){
            updateConsentEvent( accountId, usrDetails.mcEventUpt, email, cnstMap, cnstLnMap, consentEveRecordTypeId );
        }
        if(usrDetails.mcPhone != usrDetails.mcPhoneUpt){
            updateConsentPhone( accountId, usrDetails.mcPhoneUpt, email, cnstMap, consentPhnRecordTypeId);
        }
        
        try{
            update regData; 
            update userDetail;
            update addDetails;
        }
        catch(exception e)
        {
           
        }
        
    }
    /*Written for inserting the Multichannel records*/
    public static void updateConsent(Id accountId,Boolean mCMarketing,String email, Map<String, Consent_Type_vod__c> consMap, Map<String, Consent_Line_vod__c> contMap, String consentMarRecordTypeId){
        
        if (mCMarketing == true){
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Approved_Email_vod');
            
            
            Consent_Line_vod__c cl = new Consent_Line_vod__c();
            cl = contMap.get('Product and Service Direct Marketing Consent – E-mail');
            
            
            Multichannel_Consent_vod__c mMarketing = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
            	mMarketing.RecordTypeId                = consentMarRecordTypeId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Account_vod__c 	           = accountId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Capture_Datetime_vod__c     = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Signature_Datetime_vod__c   = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Channel_Value_vod__c        = email;
            //}
            mMarketing.Consent_Type_vod__c         = ct.id;
            mMarketing.Content_Type_vod__c         = cl.Content_Type_vod__c;
            mMarketing.Consent_Line_vod__c         = cl.id;	
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Opt_Type_vod__c	           = 'Opt_In_vod';
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
            	insert mMarketing;
            //}
            
        }
        else if (mCMarketing == false){
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Approved_Email_vod');
            
            
            Consent_Line_vod__c cl = new Consent_Line_vod__c();
            cl = contMap.get('Product and Service Direct Marketing Consent – E-mail');
            
            
            Multichannel_Consent_vod__c mMarketing = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
            	mMarketing.RecordTypeId                = consentMarRecordTypeId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Account_vod__c 	           = accountId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Capture_Datetime_vod__c     = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Signature_Datetime_vod__c   = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Channel_Value_vod__c        = email;
            //}
            mMarketing.Consent_Type_vod__c         = ct.id;
            mMarketing.Content_Type_vod__c         = cl.Content_Type_vod__c;
            mMarketing.Consent_Line_vod__c         = cl.id;	
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){ //cc_AD
            	mMarketing.Opt_Type_vod__c	           = 'Opt_Out_vod';
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
            	insert mMarketing;
            //}
            
        }
    }
    
    /*Written for inserting the Multichannel records*/
    public static void updateConsentEvent(Id accountId,Boolean mCEvent,String email, Map<String, Consent_Type_vod__c> consMap, Map<String, Consent_Line_vod__c> contMap, String consentEveRecordTypeId){
        
        if (mCEvent == true){
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Approved_Email_vod');
            system.debug('ct>>>>>' + ct);
            
            Consent_Line_vod__c cl = new Consent_Line_vod__c();
            cl = contMap.get('Allergan Event Invite & Registration Consent');
            system.debug('cl@@@@@@' + cl);
            Multichannel_Consent_vod__c mEvent = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
            	mEvent.RecordTypeId                = consentEveRecordTypeId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){ //cc_AD
            	mEvent.Account_vod__c 	           = accountId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){ //cc_AD
            	mEvent.Capture_Datetime_vod__c     = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isCreateable()){ //cc_AD
            	mEvent.Signature_Datetime_vod__c   = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){ //cc_AD
            	mEvent.Channel_Value_vod__c        = email;
            //}
            mEvent.Consent_Type_vod__c         = ct.id;
            mEvent.Content_Type_vod__c         = cl.Content_Type_vod__c; 
            mEvent.Consent_Line_vod__c         = cl.id;
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){ //cc_AD
            	mEvent.Opt_Type_vod__c	           = 'Opt_In_vod';
            //}
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
                
            	insert mEvent;
            //}
           
        }
        else if (mCEvent == false) {
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Approved_Email_vod');
            
            
            Consent_Line_vod__c cl = new Consent_Line_vod__c();
            cl = contMap.get('Allergan Event Invite & Registration Consent');
            
            
            Multichannel_Consent_vod__c mEvent = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isAccessible()){ //cc_AD
            	mEvent.RecordTypeId                = consentEveRecordTypeId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isAccessible()){ //cc_AD
            	mEvent.Account_vod__c 	           = accountId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isAccessible()){ //cc_AD
            	mEvent.Capture_Datetime_vod__c     = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isAccessible()){ //cc_AD
            	mEvent.Signature_Datetime_vod__c   = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isAccessible()){ //cc_AD
            	mEvent.Channel_Value_vod__c        = email;
            //}
            mEvent.Consent_Type_vod__c         = ct.id;
            mEvent.Content_Type_vod__c         = cl.Content_Type_vod__c; 
            mEvent.Consent_Line_vod__c         = cl.id;
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isAccessible()){ //cc_AD
            	mEvent.Opt_Type_vod__c	           = 'Opt_Out_vod';
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isUpdateable()){   //cc_AD
            	upsert mEvent;
            //}
            System.debug('mEventoptOut>>>'+ mEvent);
        }
    }
    
    /*Written for inserting the Multichannel Phone records*/
    public static void updateConsentPhone(Id accountId,Boolean mCPhone,String email, Map<String, Consent_Type_vod__c> consMap, String consentPhnRecordTypeId){
              
        if (mCPhone == true){
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Phone_AGN');
            system.debug('ct>>>>>' + ct);
            
            Multichannel_Consent_vod__c mPhone = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
            	mPhone.RecordTypeId = consentPhnRecordTypeId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){ //cc_AD
                mPhone.Account_vod__c = accountId;
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){ //cc_AD
            	mPhone.Capture_Datetime_vod__c     = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isCreateable()){ //cc_AD
            	mPhone.Signature_Datetime_vod__c   = System.now();
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){ //cc_AD
            	mPhone.Channel_Value_vod__c        = email;
            //}
            mPhone.Consent_Type_vod__c         = ct.id;
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){ //cc_AD
            	mPhone.Opt_Type_vod__c	           = 'Opt_In_vod';
            //}
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
            	insert mPhone;
            //}
            System.debug('mPhoneoptIn>>>'+ mPhone);
        }
        else if (mCPhone == false) {
            Consent_Type_vod__c ct = new Consent_Type_vod__c();
            ct = consMap.get('Phone_AGN');
            
            
            Multichannel_Consent_vod__c mPhone = new Multichannel_Consent_vod__c();
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){ //cc_AD
                mPhone.RecordTypeId = consentPhnRecordTypeId;
            //}    
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable()){ //cc_AD
                mPhone.Account_vod__c = accountId;
            //}
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){ //cc_AD
                mPhone.Capture_Datetime_vod__c = System.now();
            //}
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Signature_Datetime_vod__c.isCreateable()){ //cc_AD
               mPhone.Signature_Datetime_vod__c   = System.now(); 
            //}
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){ //cc_AD
                mPhone.Channel_Value_vod__c = email;
            //}
            
            mPhone.Consent_Type_vod__c         = ct.id;
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){ //cc_AD
                mPhone.Opt_Type_vod__c = 'Opt_Out_vod';
            //}    
            
            //if(Schema.SObjectType.Multichannel_Consent_vod__c.isCreateable()){   //cc_AD
            	insert mPhone;
            //}    
            
        }
    }
    
    @AuraEnabled
    public static List<PicklistValues> callUtility(string objectType , String selectedField){
        
        string pickKey;
        string pickVal;
        Map<string, string> valuesMap = new Map<string, string>(AGN_SPARK_Utility.getPicklist(objectType , selectedField)); 
        
        set<String> s = valuesMap.keySet();
        
        List<PicklistValues> lstValues = new List<PicklistValues>();
        for(string s1:s){
          pickKey = valuesMap.get(s1);
          
          pickVal = s1;
            
          PicklistValues pv = new PicklistValues(pickKey,pickVal);
           
          lstValues.add(pv);
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
}