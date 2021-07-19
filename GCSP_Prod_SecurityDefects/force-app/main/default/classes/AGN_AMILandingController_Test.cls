@isTest
public class AGN_AMILandingController_Test {
    
    static AMI_Language_AGN__c defLang;
    static AMI_Language_AGN__c language2;
    static AMI_Language_AGN__c language1;
    
    public void AGN_AMILandingController_Test()
    {}
    
    public static User dataCreation()
    {
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            //unVod = [SELECT Id FROM Country_vod__c Where Name = 'GB'];
           insert counVod;
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, AMI_Specialty_AGN__c = spcl.id, RecordTypeId = recordId);
            insert acc;
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        //////////////////////////////////////
        
        language1 = new AMI_Language_AGN__c(Language__c = 'English (SA)', Lang_Code__c = 'en_US');
        language2 = new AMI_Language_AGN__c(Language__c = 'English', Lang_Code__c = 'en_GB');
        defLang=new AMI_Language_AGN__c(Language__c = 'English', Lang_Code__c = 'en_GB');
        
        insert language1;
        insert language2;
        insert defLang;
        
        Country_vod__c country1=new Country_vod__c(AGN_Country_Name__c	='United Kingdom');
        Country_vod__c country2=new Country_vod__c(AGN_Country_Name__c	='Saudi Arabia');        
        insert country1;
        insert country2;
                 
     return u;
     
    }
    
    @isTest(SeeAllData=true)
    public static void testLandingController()
    {
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Landing_Link)); 
        //AMI_Language_AGN__c langC = new AMI_Language_AGN__c();
        System.currentPageReference().getParameters().put('country', 'SA');          
        System.currentPageReference().getParameters().put('emailId', 'soma.jana@cognizant.com');   
       // System.currentPageReference().getParameters().put('amiusername', 'soma.jana@cognizant.com');   
        System.currentPageReference().getParameters().put('amipassword', 'Password14$');
        System.currentPageReference().getParameters().put('lang', 'en_GB');    
        
        
        
        List<AMI_Language_AGN__c> lstLanguages=AMI_Language_AGN__c.getAll().values(); 
        
        system.debug ('lstLanguages in Line63:'+lstLanguages);
        
        
        AGN_AMILandingController landingController = new AGN_AMILandingController(); 
        
        landingController.errorLogin=False;
        landingController.USERNAME_SUFFIX ='ami';
        landingController.amipassword ='Password14$';
        landingController.langId ='ffff';
        
        landingController.defLang=language2;
        
        landingController.getcountryList();
        landingController.siteRedirect();
        PageReference testpr1 = landingController.amilogin();
                
        PageReference testpr2 = landingController.goToRegistrationPage();
        testpr2.setRedirect(true);
        
        PageReference testpr3 = landingController.goToForgetPassword();
        testpr3.setRedirect(true);
        
        Test.stopTest();
    }
}