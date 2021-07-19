@isTest
private class AGN_OnlineConsent_EmailNotifyBatchTest {
	static testMethod void testEmailBatch()
    {
    	Datetime dt = Datetime.parse('16/07/2018 11:00');
    	
    	AGN_OnlineConsent_Info__c info = new AGN_OnlineConsent_Info__c();
    	info.Last_Batch_Run__c = dt;
    	info.Name = 'Consent Info';
    	insert info;
    	
        Map<String, String> consentRecordTypeMap = new Map<String, String>();
        
        List<RecordType> consentTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Consent_Type_vod__c'];
        for(RecordType rt : consentTypeRecordTypes){
            consentRecordTypeMap.put(rt.DeveloperName, rt.Id);
        } 
        
        Map<String, String> mccRecordTypeMap = new Map<String, String>();
        
        List<RecordType> mccTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Multichannel_Consent_vod__c'];
        for(RecordType rt : mccTypeRecordTypes){
            mccRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }         
        
        Country_vod__c countryGB = new Country_vod__c(Name = 'GB', Country_Name_vod__c = 'United Kingdom');
        insert countryGB;
        
        Account testAccount = new Account(FirstName='Test', LastName='Account', Country_vod__c = countryGB.Id);
        insert testAccount;
        
        Consent_Header_vod__c cheader = new Consent_Header_vod__c(Name = 'Capture consent', Language_vod__c = 'en_US', Country_vod__c = countryGB.Id, Status_vod__c = 'Inactive_vod');
        insert cheader;
        
        Consent_Type_vod__c consentAEvent = new Consent_Type_vod__c(Channel_Label_vod__c='Allergan Event', 
                                                                Channel_Source_vod__c='Account.PersonEmail;Account.Email_Internal_AGN__c',
                                                                Consent_Expires_In_vod__c='End_Of_Next_Calendar_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=1,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Approved_Email_vod')
                                                                );
        
        insert consentAEvent;
        
        Id recordtypeIdContentType = [Select Id from RecordType where sobjectType = 'Content_Type_vod__c' and DeveloperName = 'Content_Type_vod'].Id; //Schema.SObjectType.Content_Type_vod__c.getRecordTypeInfosByName().get('Content_Type_vod').getRecordTypeId();
        
        Content_Type_vod__c contentTypeAE = new Content_Type_vod__c( Name='Product and Service Direct Marketing Consent - email', External_Id_vod__c = 'Product_and_Service_Direct_Marketing_Consent_-_email', 
        																RecordTypeId = recordtypeIdContentType
        );
        insert contentTypeAE;
        
        Id recordtypeIdConsentLineAE = [Select Id from RecordType where sobjectType = 'Consent_Line_vod__c' and DeveloperName = 'Content_Type_vod'].Id;
        
        Consent_Line_vod__c consentLineAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAEvent.Id, Content_Type_vod__c = contentTypeAE.Id, Content_Type_Display_Name_vod__c = 'Product and Service Direct Marketing Consent - email', 
        																Display_Order_vod__c = 1);
        insert consentLineAE;
        
        
                    
        cheader.Status_vod__c = 'Active_vod';
        update cheader;
        
        Multichannel_Consent_vod__c mConsent = new Multichannel_Consent_vod__c(
                     RecordtypeId = mccRecordTypeMap.get('Approved_Email_vod'), 
                     Account_vod__c =  testAccount.Id,
                     Channel_Value_vod__c = 'test@test.com',
                     Opt_Type_vod__c =  'Opt_In_vod', 
                     Capture_Datetime_vod__c = dt.addMinutes(20),
            		 Consent_Type_vod__c = consentAEvent.Id,
            		 Consent_Line_vod__c = consentLineAE.Id,
            		 Content_Type_vod__c = contentTypeAE.Id,
            		 Last_Device_vod__c = 'Online_vod'
                     );
                     
      insert mConsent;
      
      Test.startTest();
      	Database.executeBatch(new AGN_OnlineConsent_EmailNotificationBatch(), 200);
      Test.stopTest();     	
    }
    
    static testMethod void testEmailBatchSchedule()
    {
    	Datetime dt = Datetime.parse('16/07/2018 11:00');
    	AGN_OnlineConsent_Info__c info = new AGN_OnlineConsent_Info__c();
    	info.Last_Batch_Run__c = dt;
    	info.Name = 'Consent Info';
    	insert info;
    	
        Map<String, String> consentRecordTypeMap = new Map<String, String>();
        
        List<RecordType> consentTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Consent_Type_vod__c'];
        for(RecordType rt : consentTypeRecordTypes){
            consentRecordTypeMap.put(rt.DeveloperName, rt.Id);
        } 
        
        Map<String, String> mccRecordTypeMap = new Map<String, String>();
        
        List<RecordType> mccTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Multichannel_Consent_vod__c'];
        for(RecordType rt : mccTypeRecordTypes){
            mccRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }         
        
        Country_vod__c countryGB = new Country_vod__c(Name = 'GB', Country_Name_vod__c = 'United Kingdom');
        insert countryGB;
        
        Account testAccount = new Account(FirstName='Test', LastName='Account', Country_vod__c = countryGB.Id);
        insert testAccount;
        
        Consent_Header_vod__c cheader = new Consent_Header_vod__c(Name = 'Capture consent', Language_vod__c = 'en_US', Country_vod__c = countryGB.Id, Status_vod__c = 'Inactive_vod');
        insert cheader;
        
        Consent_Type_vod__c consentAEvent = new Consent_Type_vod__c(Channel_Label_vod__c='Product and Service Direct Marketing Consent - email', 
                                                                Channel_Source_vod__c='Account.PersonEmail;Account.Email_Internal_AGN__c',
                                                                Consent_Expires_In_vod__c='End_Of_Next_Calendar_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=1,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Approved_Email_vod')
                                                                );
        
        insert consentAEvent;
        
        Id recordtypeIdContentType = [Select Id from RecordType where sobjectType = 'Content_Type_vod__c' and DeveloperName = 'Content_Type_vod'].Id; //Schema.SObjectType.Content_Type_vod__c.getRecordTypeInfosByName().get('Content_Type_vod').getRecordTypeId();
        
        Content_Type_vod__c contentTypeAE = new Content_Type_vod__c( Name='Product and Service Direct Marketing Consent - email', External_Id_vod__c = 'Product_and_Service_Direct_Marketing_Consent_-_email', 
        																RecordTypeId = recordtypeIdContentType
        );
        insert contentTypeAE;
        
        Id recordtypeIdConsentLineAE = [Select Id from RecordType where sobjectType = 'Consent_Line_vod__c' and DeveloperName = 'Content_Type_vod'].Id;
        
        Consent_Line_vod__c consentLineAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAEvent.Id, Content_Type_vod__c = contentTypeAE.Id, Content_Type_Display_Name_vod__c = 'Product and Service Direct Marketing Consent - email', 
        																Display_Order_vod__c = 1);
        insert consentLineAE;
        
        
                    
        cheader.Status_vod__c = 'Active_vod';
        update cheader;
        
        Multichannel_Consent_vod__c mConsent = new Multichannel_Consent_vod__c(
                     RecordtypeId = mccRecordTypeMap.get('Approved_Email_vod'), 
                     Account_vod__c =  testAccount.Id,
                     Channel_Value_vod__c = 'test@test.com',
                     Opt_Type_vod__c =  'Opt_In_vod', 
                     Capture_Datetime_vod__c = dt.addMinutes(20),
            		 Consent_Type_vod__c = consentAEvent.Id,
            		 Consent_Line_vod__c = consentLineAE.Id,
            		 Content_Type_vod__c = contentTypeAE.Id,
            		 Last_Device_vod__c = 'Online_vod'
                     );
                     
      insert mConsent;
      
      Test.startTest();
      	String sch = '0 55 * * * ?'; 
		System.schedule('Schedule Portal Email Notification', sch, new AGN_OnlineConsent_EmailSchedule());
      Test.stopTest();     	
    }
}