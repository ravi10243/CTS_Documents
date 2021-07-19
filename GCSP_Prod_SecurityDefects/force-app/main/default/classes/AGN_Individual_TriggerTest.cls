@isTest
private class AGN_Individual_TriggerTest 
{
	static testMethod void testIndividualInsert()
    {
        Map<String, String> consentRecordTypeMap = new Map<String, String>();
        
        List<RecordType> consentTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Consent_Type_vod__c'];
        for(RecordType rt : consentTypeRecordTypes){
            consentRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }        
        
        Country_vod__c countryGB = new Country_vod__c(Name = 'GB', Country_Name_vod__c = 'United Kingdom');
        insert countryGB;
        
        Country_vod__c countryFR = new Country_vod__c(Name = 'FR', Country_Name_vod__c = 'France');
        insert countryFR;
        
        Account testAccount = new Account(FirstName='Test', LastName='Account', Country_vod__c = countryGB.Id);
        insert testAccount;
        
        Consent_Header_vod__c cheader = new Consent_Header_vod__c(Name = 'Capture consent', Language_vod__c = 'en_US', Country_vod__c = countryGB.Id, Status_vod__c = 'Inactive_vod');
        insert cheader;
        
        Consent_Type_vod__c consentAE = new Consent_Type_vod__c(Channel_Label_vod__c='Approved Email', 
                                                                Channel_Source_vod__c='Account.PersonEmail;Account.Email_Internal_AGN__c',
                                                                Consent_Custom_Duration_vod__c = 24, Consent_Expires_In_vod__c='Custom_Duration_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=1,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Approved_Email_vod')
                                                                );
        Consent_Type_vod__c consentPhone = new Consent_Type_vod__c(Channel_Label_vod__c='Phone', 
                                                                Channel_Source_vod__c='Account.Phone',
                                                                Consent_Expires_In_vod__c='One_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=2,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Phone_AGN')
                                                                );
        Consent_Type_vod__c consentTOV = new Consent_Type_vod__c(Channel_Label_vod__c='TOV', 
                                                                Channel_Source_vod__c='',
                                                                Consent_Expires_In_vod__c='End_Of_Calendar_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=3,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('TOV_AGN')
                                                                );
        
        insert new List<Consent_Type_vod__c>{consentAE, consentPhone, consentTOV};
        
        Id recordtypeIdContentType = [Select Id from RecordType where sobjectType = 'Content_Type_vod__c' and DeveloperName = 'Content_Type_vod'].Id; //Schema.SObjectType.Content_Type_vod__c.getRecordTypeInfosByName().get('Content_Type_vod').getRecordTypeId();
        
        Content_Type_vod__c contentTypePS = new Content_Type_vod__c( Name='Product and Service Direct Marketing Consent - email', External_Id_vod__c = 'Product_and_Service_Direct_Marketing_Consent_-_email', 
        																RecordTypeId = recordtypeIdContentType);
        																
        Content_Type_vod__c contentTypeAE = new Content_Type_vod__c( Name='AGN Event Invite & Registration Consent', External_Id_vod__c = 'AGN_Event_Invite_&_Registration_Consent', 
        																RecordTypeId = recordtypeIdContentType);
        																
        Content_Type_vod__c contentTypeNAE = new Content_Type_vod__c( Name='Non-Allergan Event Invite & Registration Consent', External_Id_vod__c = 'Non_Allergan_Event_Invite_&_Registration_Consent', 
        																RecordTypeId = recordtypeIdContentType);																													
        insert new List<Content_Type_vod__c>{contentTypePS, contentTypeAE, contentTypeNAE};
        
        
        Id recordtypeIdConsentLineAE = [Select Id from RecordType where sobjectType = 'Consent_Line_vod__c' and DeveloperName = 'Content_Type_vod'].Id;
        
        Consent_Line_vod__c consentLinePS = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypePS.Id, Content_Type_Display_Name_vod__c = 'Product and Service Direct Marketing Consent - email', 
        																Display_Order_vod__c = 1);
        Consent_Line_vod__c consentLineAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypeAE.Id, Content_Type_Display_Name_vod__c = 'AGN Event Invite & Registration Consent', 
        																Display_Order_vod__c = 1);
        Consent_Line_vod__c consentLineNAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypeNAE.Id, Content_Type_Display_Name_vod__c = 'Non-Allergan Event Invite & Registration Consent', 
        																Display_Order_vod__c = 1);																																
        insert new List<Consent_Line_vod__c>{consentLinePS, consentLineAE, consentLineNAE};
            
        cheader.Status_vod__c = 'Active_vod';
        update cheader;
        
        Test.startTest();
        Individual ind = new Individual(LastName = 'Test Account');
        insert ind;
        
        testAccount.PersonIndividualId  = ind.Id;
        update testAccount;
        
        ind = new Individual(Id = ind.Id, Salutation = 'Mr', FirstName = 'Test',
                             LastName = 'Account', Online_consent__c = true,                                           
                             Selected_Language__c = 'en_US',
                             Country__c = countryGB.Id, Approved_Primary_Email__c=true,
                             Approved_Additional_Email__c=true,
                             Phone_Consent__c=true, TOV_Consent__c=true,
                             Allergan_Event_Consent__c=true, Non_Allergan_Event_Consent__c= true,
                             Mobile_Number__c='074562435'
                            );
        update ind;
        
        Test.stopTest();
        
        List<Multichannel_Consent_vod__c> mcrecords = [Select Id from Multichannel_Consent_vod__c where Account_vod__c = :testAccount.Id];
        
        System.assert(mcrecords != null);
    }
    
    static testMethod void testIndividualInsertOptOut()
    {
        Map<String, String> consentRecordTypeMap = new Map<String, String>();
        
        List<RecordType> consentTypeRecordTypes = [Select Id, DeveloperName from RecordType where SobjectType='Consent_Type_vod__c'];
        for(RecordType rt : consentTypeRecordTypes){
            consentRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }        
        
        Country_vod__c countryGB = new Country_vod__c(Name = 'GB', Country_Name_vod__c = 'United Kingdom');
        insert countryGB;
        
        Country_vod__c countryFR = new Country_vod__c(Name = 'FR', Country_Name_vod__c = 'France');
        insert countryFR;
        
        Account testAccount = new Account(FirstName='Test', LastName='Account', Country_vod__c = countryGB.Id);
        insert testAccount;
        
        Consent_Header_vod__c cheader = new Consent_Header_vod__c(Name = 'Capture consent', Language_vod__c = 'en_US', Country_vod__c = countryGB.Id, Status_vod__c = 'Inactive_vod');
        insert cheader;
        
        Consent_Type_vod__c consentAE = new Consent_Type_vod__c(Channel_Label_vod__c='Approved Email', 
                                                                Channel_Source_vod__c='Account.PersonEmail;Account.Email_Internal_AGN__c',
                                                                Consent_Custom_Duration_vod__c = 24, Consent_Expires_In_vod__c='Custom_Duration_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=1,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Approved_Email_vod')
                                                                );
        Consent_Type_vod__c consentPhone = new Consent_Type_vod__c(Channel_Label_vod__c='Phone', 
                                                                Channel_Source_vod__c='Account.Phone',
                                                                Consent_Expires_In_vod__c='One_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=2,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('Phone_AGN')
                                                                );
        Consent_Type_vod__c consentTOV = new Consent_Type_vod__c(Channel_Label_vod__c='TOV', 
                                                                Channel_Source_vod__c='',
                                                                Consent_Expires_In_vod__c='End_Of_Calendar_Year_vod',
                                                                Consent_Header_vod__c = cheader.Id,
                                                                Disclaimer_Text_vod__c='Display this text',
                                                                Display_Order_vod__c=3,
                                                                zvod_Consent_Default_Consent_Text_vod__c = 'default text',
                                                                RecordTypeId = consentRecordTypeMap.get('TOV_AGN')
                                                                );
        
        insert new List<Consent_Type_vod__c>{consentAE, consentPhone, consentTOV};
        
        Id recordtypeIdContentType = [Select Id from RecordType where sobjectType = 'Content_Type_vod__c' and DeveloperName = 'Content_Type_vod'].Id; //Schema.SObjectType.Content_Type_vod__c.getRecordTypeInfosByName().get('Content_Type_vod').getRecordTypeId();
        
        Content_Type_vod__c contentTypePS = new Content_Type_vod__c( Name='Product and Service Direct Marketing Consent - email', External_Id_vod__c = 'Product_and_Service_Direct_Marketing_Consent_-_email', 
        																RecordTypeId = recordtypeIdContentType);
        																
        Content_Type_vod__c contentTypeAE = new Content_Type_vod__c( Name='AGN Event Invite & Registration Consent', External_Id_vod__c = 'AGN_Event_Invite_&_Registration_Consent', 
        																RecordTypeId = recordtypeIdContentType);
        																
        Content_Type_vod__c contentTypeNAE = new Content_Type_vod__c( Name='Non-Allergan Event Invite & Registration Consent', External_Id_vod__c = 'Non_Allergan_Event_Invite_&_Registration_Consent', 
        																RecordTypeId = recordtypeIdContentType);																													
        insert new List<Content_Type_vod__c>{contentTypePS, contentTypeAE, contentTypeNAE};
        
        
        Id recordtypeIdConsentLineAE = [Select Id from RecordType where sobjectType = 'Consent_Line_vod__c' and DeveloperName = 'Content_Type_vod'].Id;
        
        Consent_Line_vod__c consentLinePS = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypePS.Id, Content_Type_Display_Name_vod__c = 'Product and Service Direct Marketing Consent - email', 
        																Display_Order_vod__c = 1);
        Consent_Line_vod__c consentLineAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypeAE.Id, Content_Type_Display_Name_vod__c = 'AGN Event Invite & Registration Consent', 
        																Display_Order_vod__c = 1);
        Consent_Line_vod__c consentLineNAE = new Consent_Line_vod__c( RecordTypeId = recordtypeIdConsentLineAE,
        																Consent_Type_vod__c = consentAE.Id, Content_Type_vod__c = contentTypeNAE.Id, Content_Type_Display_Name_vod__c = 'Non-Allergan Event Invite & Registration Consent', 
        																Display_Order_vod__c = 1);																																
        insert new List<Consent_Line_vod__c>{consentLinePS, consentLineAE, consentLineNAE};
            
        cheader.Status_vod__c = 'Active_vod';
        update cheader;
        
        Test.startTest();
        Individual ind = new Individual(LastName = 'Test Account');
        insert ind;
        
        testAccount.PersonIndividualId  = ind.Id;
        update testAccount;
        
        ind = new Individual(Id = ind.Id, Salutation = 'Mr', FirstName = 'Test',
                             LastName = 'Account', Online_consent__c = true,                                           
                             Selected_Language__c = 'en_US',
                             Country__c = countryGB.Id, Approved_Primary_Email__c=false,
                             Approved_Additional_Email__c=false,
                             Phone_Consent__c=true, TOV_Consent__c=false,
                             Allergan_Event_Consent__c=true, Non_Allergan_Event_Consent__c= false,
                             Mobile_Number__c='074562435'
                            );
        update ind;
        
        Test.stopTest();
        
        List<Multichannel_Consent_vod__c> mcrecords = [Select Id from Multichannel_Consent_vod__c where Account_vod__c = :testAccount.Id];
        
        System.assert(mcrecords != null);
    }
}