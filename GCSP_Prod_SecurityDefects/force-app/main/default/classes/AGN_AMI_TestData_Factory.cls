/**************************************************************************************************************************
@ Class:          AGN_AMI_TestData_Factory
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Utility class for test data generation.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.04.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

@isTest
public class AGN_AMI_TestData_Factory {
    
    /**********************************************************************************************************************
@ Method:         createUser 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static User createUser(String profileName, String exId) {
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName]; 
        
        User usr = new User(ProfileId                = p.Id, 
                            LastName                 = 'TestU' + Math.random(), 
                            Alias                    = 'Tusr' + exId, 
                            Email                    = 'usr' + Math.random() + '@org.com', 
                            EmailEncodingKey         = 'UTF-8', 
                            LanguageLocaleKey        = 'en_US', 
                            LocaleSidKey             = 'en_US', 
                            TimeZoneSidKey           = 'America/Los_Angeles',
                            UserName                 = 'usr' + Math.random() + '@org.com',
                            Country_Code__c          = 'GB',
                            SMB_Alias_External_Id__c = exId);
        
        insert usr;
        return usr;
    }
    
    /**********************************************************************************************************************
@ Method:         createCommunityUser 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static User createCommunityUser(String exId) {
        
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', 
                                         Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
           
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, 
                              AMI_Specialty_AGN__c = spcl.id, RecordTypeId = recordId);
            insert acc;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt' + exId, email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB',
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', Country_code__c = 'GB', 
                         username='standarduser@allergan.example.com', 
                         SMB_Alias_External_Id__c = exId,
                         contactId = ConId);
            insert u;
            
        }
        return u;
    }
    
    /**********************************************************************************************************************
@ Method:         createAccount 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static Account createAccount() {
        
        Country_vod__c counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', 
                                                    Country_Name_vod__c = 'United Kingdom', 
                                                    Alpha_2_Code_vod__c = 'GB', 
                                                    Name = 'GB');
        insert counVod;
        
        AMI_SPecality_AGN__c spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
        insert spcl;
        
        Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
        
        Account ac = new Account(lastname = 'Test Hospital', 
                                 Country_code__c = 'GB', 
                                 Country_vod__c = counVod.Id, 
                                 AMI_Specialty_AGN__c = spcl.id, 
                                 RecordTypeId = recordId);
        insert ac;
        return ac;
    }
    
    /**********************************************************************************************************************
@ Method:         createContact 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static Contact createContact() {
        
        Contact con = new Contact(LastName ='testCon', AccountId = createAccount().Id);
        insert con;
        return con;
    }
    
    /**********************************************************************************************************************
@ Method:         createMeeting 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static Medical_Event_vod__c createMeeting(String recordType) {
        
        Id eventRecTypeId = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName()
            .get(recordType).getRecordTypeId();                            
        
        Medical_Event_vod__c mtng = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                             Name = 'testEvent',
                                                             Start_Time_vod__c = DateTime.Now(),
                                                             End_Time_vod__c = DateTime.Now().addHours(1),
                                                             AMI_Event_Type_AGN__c = 'Public');
        
        insert mtng;
        return mtng;
    }
    
    /**********************************************************************************************************************
@ Method:         createBulkMeetings 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static List<Medical_Event_vod__c> createBulkMeetings(String recordType, Integer count) {
        
        List<Medical_Event_vod__c> meetings = new List<Medical_Event_vod__c>();
        
        Id eventRecTypeId = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName()
            .get(recordType).getRecordTypeId(); 
        
        for(Integer i = 0; i <= count; i++) {
            meetings.add(new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                  Name = 'testEvent' + i,
                                                  Start_Time_vod__c = DateTime.Now(),
                                                  End_Time_vod__c = DateTime.Now().addHours(4),
                                                  AMI_Event_Type_AGN__c = 'Public',
                                                  AMI_Event_Status_AGN__c = 'live'));
        }
        
        insert meetings;
        return meetings;
    }
    
    /**********************************************************************************************************************
@ Method:         createMeetings 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static Map<String, Medical_Event_vod__c> createMeetings(String recordType) {
        
        Map<String, Medical_Event_vod__c> mtngs = new Map<String, Medical_Event_vod__c>();
        
        Id eventRecTypeId = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName()
            .get(recordType).getRecordTypeId();                            
        
        /*past event*/
        Medical_Event_vod__c m1 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent1',
                                                           Start_Time_vod__c = DateTime.Now(),
                                                           End_Time_vod__c = DateTime.Now().addHours(4),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Completed');
        
        /*planned event 1*/
        Medical_Event_vod__c m2 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent2',
                                                           Start_Time_vod__c = DateTime.Now().addDays(5),
                                                           End_Time_vod__c = DateTime.Now().addDays(6),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Planned');
        
        /*planned event 2*/
        Medical_Event_vod__c m3 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent3',
                                                           Start_Time_vod__c = DateTime.Now().addDays(15),
                                                           End_Time_vod__c = DateTime.Now().addDays(16),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Planned');                                                     
        
        /*planned event 2*/
        Medical_Event_vod__c m4 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent4',
                                                           Start_Time_vod__c = DateTime.Now().addDays(15),
                                                           End_Time_vod__c = DateTime.Now().addDays(16),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Planned');
        
        /*live event - past event*/
        Medical_Event_vod__c m5 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent5',
                                                           Start_Time_vod__c = DateTime.Now().addHours(-100),
                                                           End_Time_vod__c = DateTime.Now().addHours(-96),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Live');
        
        /*live event - starts today - scheduled*/
        Medical_Event_vod__c m6 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent6',
                                                           Start_Time_vod__c = DateTime.Now().addHours(2),
                                                           End_Time_vod__c = DateTime.Now().addHours(7),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Live'); 
        
        /*live event - starts tomorrow - scheduled*/
        Medical_Event_vod__c m7 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent7',
                                                           Start_Time_vod__c = DateTime.Now().addHours(24),
                                                           End_Time_vod__c = DateTime.Now().addHours(30),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Live'); 
        
        /*live event - starts day after tomorrow - scheduled*/
        Medical_Event_vod__c m8 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent8',
                                                           Start_Time_vod__c = DateTime.Now().addHours(25),
                                                           End_Time_vod__c = DateTime.Now().addHours(50),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Live');
        
        /*live event - starts 4 days later - scheduled*/
        Medical_Event_vod__c m9 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                           Name = 'testEvent9',
                                                           Start_Time_vod__c = DateTime.Now().addHours(96),
                                                           End_Time_vod__c = DateTime.Now().addHours(100),
                                                           AMI_Event_Type_AGN__c = 'Public',
                                                           AMI_Event_Status_AGN__c = 'Live');
        
        /*live event - past event but ongoing*/
        Medical_Event_vod__c m10 = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                            Name = 'testEvent10',
                                                            Start_Time_vod__c = DateTime.Now().addHours(-8),
                                                            End_Time_vod__c = DateTime.Now().addHours(10),
                                                            AMI_Event_Type_AGN__c = 'Public',
                                                            AMI_Event_Status_AGN__c = 'Live');                                                     
        
        List<Medical_Event_vod__c> ms = new List<Medical_Event_vod__c>();
        ms.add(m1); ms.add(m2); ms.add(m3); ms.add(m4); ms.add(m5); 
        ms.add(m6); ms.add(m7); ms.add(m8); ms.add(m9); ms.add(m10);
        
        insert ms;
        
        mtngs.put('completed', m1);
        mtngs.put('planned1', m2);
        mtngs.put('planned2', m3);
        mtngs.put('planned2', m4);        
        mtngs.put('live1', m5);        
        mtngs.put('live2', m6);        /*expected in banner console list view*/
        mtngs.put('live3', m7);        /*expected in banner console list view*/
        mtngs.put('live4', m8);        /*expected in banner console list view*/
        mtngs.put('live5', m9);        
        mtngs.put('live6', m10);       /*expected in banner console list view*/
        
        return mtngs;
    }
    
    /**********************************************************************************************************************
@ Method:         createPushNotCustomSetting 
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
***********************************************************************************************************************/
    public static AMIPortalPushNotification__c createPushNotCustomSetting(String setting) {
        
        AMIPortalPushNotification__c psh = new AMIPortalPushNotification__c(Name = setting, Enabled__c = false);
        insert psh;
        return psh;
    }
    /**********************************************************************************************************************
@ Method:         createAMIProjectAGN 
@ Author:         Pallavi (pallavi.p3@cognizant.com)
***********************************************************************************************************************/
    
    public static AMI_Project_AGN__c createAMIProjectAGN()  {
        /*  Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();	

Country_vod__c counVod1 = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB1');
insert counVod1; 
Account  acc = new Account(lastname = 'Testpa',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod1.Id, RecordTypeId = recordId,Consent_to_Meeting_AGN__c= True);
insert acc;
//  Account_AGN_AMI__c=acc.id*/
        AMI_Project_AGN__c project=new AMI_Project_AGN__c(HCP_Image_AGN_AMI__c='dummy1',Content_Link_AGN_AMI__c='https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',Title_AGN_AMI__c='ceo',
                                                          Category_AGN_AMI__c='Case studies and case management');
        
        insert project;
        return project;
    }  
    
    /**********************************************************************************************************************
@ Method:         createAMIProjectcase 
@ Author:         Ambroz (mdambroz.khan@cognizant.com)
***********************************************************************************************************************/    
    
       public static List<case> createAMIProjectAGNcaselist(user usr,user adminuser,integer Number_of_cases){
               
        List<case> listofcases = new List<case>();
		integer i=0;
        for(i=1;i<=Number_of_cases;i++){
        case case_i =  new case(ownerid=adminuser.id,AccountId=usr.AccountId,ContactId=usr.ContactId,Description='D D D',
                           Category_AGN_AMI__c='Case studies and case management',Title_Submitted_AGN_AMI__c ='ceo'); 
 
        listofcases.add(case_i);
        }
           
         
        //case case1 = new case(ownerid=adminuser.id,AccountId=usr.AccountId,Contact_AGN_AMI__c=usr.ContactId,Description='D D D',
        //                      Category_AGN_AMI__c='Case studies and case management',Title_Submitted_AGN_AMI__c ='ceo');   

        // case case2 = new case(ownerid=adminuser.id,Account_AGN_AMI__c=usr.AccountId,Contact_AGN_AMI__c=usr.ContactId,Description='D r D',
        //                      Category_AGN_AMI__c='Case studies and case management',Title_Submitted_AGN_AMI__c ='ceo');
       // case case3 = new case(ownerid=adminuser.id,Account_AGN_AMI__c=usr.AccountId,Contact_AGN_AMI__c=usr.ContactId,Description='D g D',Category_AGN_AMI__c='Case studies and case management',Title_Submitted_AGN_AMI__c ='ceo');   
        
        
        //listofcases.add(case1);listofcases.add(case2);listofcases.add(case3);
        insert listofcases;
        return listofcases;     
    }
    
        /**********************************************************************************************************************
@ Method:         createAMIProjectcase 
@ Author:         Ambroz (mdambroz.khan@cognizant.com)
***********************************************************************************************************************/ 

    
    
    /**********************************************************************************************************************
@ Method:         createAMIProjectAGNNew 
@ Author:         Ambroz (MDambroz.khan@cognizant.com)
***********************************************************************************************************************/
    
    public static AMI_Project_AGN__c createAMIProjectAGNNew()  {
        
        AMI_Project_AGN__c project = new AMI_Project_AGN__c(Preview_Description_AGN_AMI__c='This preview Desc',
                                                            Country_AGN__c='GB',
                                                            Category_AGN_AMI__c='Case studies and case management',
                                                            Description_AGN_AMI__c='Desc Desc Desc',
                                                            Title_AGN_AMI__c='Dummy Title');
        
        insert project;
        return project;
    }     
    
    /**********************************************************************************************************************
@ Method:         createAMIProjectAGNcase 
@ Author:         Ambroz (MDambroz.khan@cognizant.com)
***********************************************************************************************************************/
    
    public static case createAMIProjectAGNcase(){
        Account acc =AGN_AMI_TestData_Factory.createAccountNew();
        Contact con = AGN_AMI_TestData_Factory.createContact();
        
        case casez = new case(AccountId=acc.id,ContactId=con.id,Description='D D D',Category_AGN_AMI__c='Case studies and case management',
                              Title_Submitted_AGN_AMI__c ='ceo');
        
        insert casez;
        return casez;
    }   
    /**********************************************************************************************************************
@ Method:         createAccountNew 
@ Author:   Sujan Guha (sujan.guha@cognizant.com)
***********************************************************************************************************************/
    
    public static Account createAccountNew(){
        Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
        Account acc = new Account(Status_AGN__c = 'Active',lastname = 'Test',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', RecordTypeId = recordId);
        insert acc;
        return acc;
    }
    /**********************************************************************************************************************
@ Method:         createBanner 
@ Author:         Ambroz (Mdambroz.khan@cognizant.com)
***********************************************************************************************************************/ 
        public static List<AMI_Banner_AGN__c> createBanner(integer Number_of_banners){
            
        List<AMI_Banner_AGN__c> listofbanners = new List<AMI_Banner_AGN__c>();    
		integer i=0;
        for(i=1;i<=Number_of_banners;i++){
        AMI_Banner_AGN__c banners_i = new AMI_Banner_AGN__c(Name='abc',Behaviour_AGN_AMI__c='Direct Link',
                                                          Link_AGN_AMI__c='https://www.google.com',Action_Count_AGN_AMI__c=4,BannerImageId_AGN_AMI__c='abc',
                                                          	Description_AGN_AMI__c='thehe',Vault_code_AGN_AMI__c='fhfhf',
                                                          ButtonLabel_AGN_AMI__c='fhfh', TagLine_AGN_AMI__c='sdfjgrjkfg');
        
        listofbanners.add(banners_i);
        }
        
        insert listofbanners;
        return listofbanners;
    }
    /**********************************************************************************************************************
    @ Method:         createBanner 
    @ Author:         Ambroz (Mdambroz.khan@cognizant.com)
    ***********************************************************************************************************************/ 
    public static List<AMI_Banner_AGN__c> createBanner2(){
        
        List<AMI_Banner_AGN__c> listofbanners2 = new List<AMI_Banner_AGN__c>();
        
        //Should get displayed
        AMI_Banner_AGN__c banner1 = new AMI_Banner_AGN__c(Name='Banner 1',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=true,Sequence_AGN_AMI__c=3,
                                                          Country_AGN_AMI__c='',Behaviour_AGN_AMI__c='Direct Link',
                                                          Link_AGN_AMI__c='https://www.google.com',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 1',
                                                          Vault_code_AGN_AMI__c='',ButtonLabel_AGN_AMI__c='download1',
                                                          TagLine_AGN_AMI__c='Tagline 1',BannerImageId_AGN_AMI__c=null,
                                                          Start_Date_AGN_AMI__c=null,End_Date_AGN_AMI__c=null);
        //Should get displayed
        AMI_Banner_AGN__c banner2 = new AMI_Banner_AGN__c(Name='Banner 2',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=true,Sequence_AGN_AMI__c=4,Country_AGN_AMI__c='',
                                                          Behaviour_AGN_AMI__c='Pop-Up',Link_AGN_AMI__c='',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 2',
                                                          Vault_code_AGN_AMI__c='vault code 1',ButtonLabel_AGN_AMI__c='download2',
                                                          TagLine_AGN_AMI__c='Tagline 2',BannerImageId_AGN_AMI__c=null,
                                                          Start_Date_AGN_AMI__c=null,End_Date_AGN_AMI__c=null);
        //Should get displayed
        AMI_Banner_AGN__c banner3 = new AMI_Banner_AGN__c(Name='Banner 3',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=false,Sequence_AGN_AMI__c=1,
                                                          Country_AGN_AMI__c ='GB',Behaviour_AGN_AMI__c='None',
                                                          Link_AGN_AMI__c='',Action_Count_AGN_AMI__c=4,
                                                          Description_AGN_AMI__c='Description 3',Vault_code_AGN_AMI__c='',
                                                          ButtonLabel_AGN_AMI__c='download3',TagLine_AGN_AMI__c='Tagline 3',
                                                          BannerImageId_AGN_AMI__c=null,Start_Date_AGN_AMI__c=null,
                                                          End_Date_AGN_AMI__c=null);    
        //Should get displayed
        AMI_Banner_AGN__c banner4 = new AMI_Banner_AGN__c(Name='Banner 4',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=false,Sequence_AGN_AMI__c=2,
                                                          Country_AGN_AMI__c='GB',Behaviour_AGN_AMI__c='Direct Link',
                                                          Link_AGN_AMI__c='https://www.google.com',Action_Count_AGN_AMI__c=4,
                                                          Description_AGN_AMI__c='Description 4',Vault_code_AGN_AMI__c='',
                                                          ButtonLabel_AGN_AMI__c='download4',TagLine_AGN_AMI__c='Tagline 4',
                                                          BannerImageId_AGN_AMI__c=null,Start_Date_AGN_AMI__c=null,
                                                          End_Date_AGN_AMI__c=null);    
        //Should not get displayed Global = false and for AN
        AMI_Banner_AGN__c banner5 = new AMI_Banner_AGN__c(Name='Banner 5',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=false,Sequence_AGN_AMI__c=5,Country_AGN_AMI__c='AN',
                                                          Behaviour_AGN_AMI__c='Direct Link',Link_AGN_AMI__c='https://www.google.com',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 4',
                                                          Vault_code_AGN_AMI__c='',ButtonLabel_AGN_AMI__c='download4',
                                                          TagLine_AGN_AMI__c='Tagline 4',BannerImageId_AGN_AMI__c=null,
                                                          Start_Date_AGN_AMI__c=null,End_Date_AGN_AMI__c=null);
        //Should not get displayed Active = false
        AMI_Banner_AGN__c banner6 = new AMI_Banner_AGN__c(Name='Banner 6',Active_AGN_AMI__c=false,
                                                          Global_AGN_AMI__c=true,Sequence_AGN_AMI__c=8,Country_AGN_AMI__c='AN',
                                                          Behaviour_AGN_AMI__c='Direct Link',Link_AGN_AMI__c='https://www.google.com',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 5',
                                                          ButtonLabel_AGN_AMI__c='download5',TagLine_AGN_AMI__c='Tagline 5',
                                                          BannerImageId_AGN_AMI__c=null);
        //Should get displayed
        AMI_Banner_AGN__c banner7 = new AMI_Banner_AGN__c(Name='Banner 7',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=true,Sequence_AGN_AMI__c=3,Country_AGN_AMI__c='',
                                                          Behaviour_AGN_AMI__c='Direct Link',Link_AGN_AMI__c='https://www.google.com',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 1',
                                                          Vault_code_AGN_AMI__c='',ButtonLabel_AGN_AMI__c='download1',
                                                          TagLine_AGN_AMI__c='Tagline 1',BannerImageId_AGN_AMI__c=null,
                                                          Start_Date_AGN_AMI__c = System.today() - 1,End_Date_AGN_AMI__c = System.today() + 1);
        //Should not get displayed Date not valid range
        AMI_Banner_AGN__c banner8 = new AMI_Banner_AGN__c(Name='Banner 8',Active_AGN_AMI__c=true,
                                                          Global_AGN_AMI__c=true,Sequence_AGN_AMI__c=3,Country_AGN_AMI__c='',
                                                          Behaviour_AGN_AMI__c='Direct Link',Link_AGN_AMI__c='https://www.google.com',
                                                          Action_Count_AGN_AMI__c=4,Description_AGN_AMI__c='Description 1',
                                                          Vault_code_AGN_AMI__c='',ButtonLabel_AGN_AMI__c='download1',
                                                          TagLine_AGN_AMI__c='Tagline 1',BannerImageId_AGN_AMI__c=null,
                                                          Start_Date_AGN_AMI__c = System.today() + 1,
                                                          End_Date_AGN_AMI__c = System.today() + 2);
        
        listofbanners2.add(banner1);
        listofbanners2.add(banner2);
        listofbanners2.add(banner3);
        listofbanners2.add(banner4);
        listofbanners2.add(banner5);
        listofbanners2.add(banner6);
        listofbanners2.add(banner7);
        listofbanners2.add(banner8);
        
        
        insert listofbanners2;
        return listofbanners2; 
    }
    /**********************************************************************************************************************
    @ Method:         createInfocus 
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    ***********************************************************************************************************************/ 
    public static AMI_InFocus_AGN__c createInFocus(){
        AMI_InFocus_AGN__c infocus = new AMI_InFocus_AGN__c();
        insert infocus;
        return infocus;
    }
    
    /**********************************************************************************************************************
    @ Method:         createInfocus 
    @ Author:         Ayush Basak (ayush.basak@cognizant.com)
    ***********************************************************************************************************************/ 
    public static ContentDistribution createContentDelivery(String relatedId){
        
        ContentVersion newVersion = new ContentVersion();
        newVersion.Title = 'my version title';
        newVersion.pathOnClient = 'url';
        newVersion.VersionData=blob.valueof('test data');
        insert newVersion;

        ContentDistribution distribution = new ContentDistribution();
        distribution.Name = newVersion.title + ' ' +  Date.today();
        distribution.ContentVersionId = newVersion.Id;
        distribution.PreferencesNotifyOnVisit = false;
        distribution.PreferencesNotifyRndtnComplete = false;
        distribution.RelatedRecordId = relatedId;
        insert distribution;
        
        return distribution;
    }
	/**********************************************************************************************************************
	@ Method:         createDigitalMeetings 
	@ Author:         Sujan Guha (sujan.guha@cognizant.com)
	***********************************************************************************************************************/
    public static List<Medical_Event_vod__c> createDigitalMeetings(String recordType, Integer count) {
        
        List<Medical_Event_vod__c> meetings = new List<Medical_Event_vod__c>();
        
        Id eventRecTypeId = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName()
            .get(recordType).getRecordTypeId(); 
        
        for(Integer i = 0; i <= count; i++) {
            meetings.add(new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                  Name = 'testEvent Digital' + i,
                                                  Start_Time_vod__c = DateTime.Now(),
                                                  End_Time_vod__c = DateTime.Now().addHours(4),
                                                  AMI_Event_Type_AGN__c = 'Public',
                                                  AMI_Event_Status_AGN__c = 'Planned'));
        }
        
        insert meetings;
        return meetings;
    }
    
    /**********************************************************************************************************************	
	@ Method:         createMeeting 
	@ Author:         Sujan Guha (sujan.guha@cognizant.com)
	***********************************************************************************************************************/
    public static Medical_Event_vod__c createDigitalEvent(String recordType) {
        
        Id eventRecTypeId = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        
        Medical_Event_vod__c mtng = new Medical_Event_vod__c(RecordTypeId = eventRecTypeId,
                                                             Name = 'testEvent Digital',
                                                             Start_time_vod__c = DATETIME.now(),
                                                             End_time_vod__c = DATETIME.now().adddays(1),
                                                             AMI_Event_Type_AGN__c = 'Public',
                                                             AMI_Event_Status_AGN__c='Planned');
        
        insert mtng;
        return mtng;
    }
    
    /**********************************************************************************************************************	
	@ Method:         createMeetingSpeaker 
	@ Author:         Sujan Guha (sujan.guha@cognizant.com)
	***********************************************************************************************************************/

    public static Meeting_Speaker_AGN__c createMeetingSpeaker(Medical_Event_vod__c mc,Country_vod__c coun){
        	AMI_Faculty_AGN__c faculty;
        	faculty = new AMI_Faculty_AGN__c(Name_AGN__c ='Dr. A Kaz', Country_AGN__c = 'UK', Country_LKP_AGN__c = coun.id);
            insert faculty;
        	ID medID1;
            medID1 = mc.Id;
        	Meeting_Speaker_AGN__c meetingSpeaker = new Meeting_Speaker_AGN__c(Meeting_AGN__c = medID1,
                                                                          AMI_Primary_Speaker_AGN__c = True, AMI_Faculty_AGN__c = faculty.id);

            insert meetingSpeaker;
			return meetingSpeaker;
			
    }
    
    public static AGN_AMI_Meeting_Doc__c createMeetingDoc(Medical_Event_vod__c me){

        AGN_AMI_Meeting_Doc__c meetingDoc = new AGN_AMI_Meeting_Doc__c(Name='Demo Meeting Doc', Link_AGN__c='test.demo',
                                                                       AGN_AMI_Document_Section__c='Digital talks',
                                                                       Meeting_AGN__c=me.Id);
        insert meetingDoc;
        return meetingDoc;
        
    }
}