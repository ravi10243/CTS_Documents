@isTest
global class AGN_ICL_TestRegFormCtrl_Test implements HttpCalloutMock {
    
    
      global HTTPResponse respond(HTTPRequest req) {
   
           
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'image/jpg');
        res.setStatusCode(200);
        return res;
    }

    @isTest(SeeAllData=true)
    public static void method1()
        
           
    {
       Account acc1= new Account();
        acc1.LastName='AccountRecord1';
        acc1.Country_Code__c='GB';
        insert acc1;
        
        Account acc2= new Account();
        acc2.LastName='AccountRecord2';
        acc2.Country_Code__c='ES';
        insert acc2;
       
        Locator_Listing_AGN__c l1 = new Locator_Listing_AGN__c();
        l1.Name='Locator Listing 1';
        l1.Clinic_Admin_AGN__c=acc1.id;
        l1.Clinic_Image_AGN__c='https://s3-eu-west-1.amazonaws.com/allergan-icl/a7q6E0000006XENQA2-Tulips.jpg';
        l1.Account_AGN__c=acc1.id;
        l1.Approval_Status__c = 'Rejected';
        l1.Active_AGN__c = true;
        //l1.Second_Level_Clinic_Approver_AGN__c=u.Id;
        l1.Brand_AGN__c='CoolSculpting';
        insert l1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u =new User(Alias = 'xyz', Email='xyz.pqr@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='pqr', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='xyz.pqr@testorg.com.int',Country_Code__c='GB',Locator_Listing_Id_AGN__c=l1.Id);
        insert u;
     
        
        String adminEmail='xyz.pqr@testorg.com';
        
        
        u.Locator_Listing_Id_AGN__c=l1.Id;
        update u;
       
        
        AWS_Login_AGN__c a = new AWS_Login_AGN__c();
        a.Name = 'Test';
        a.key_AGN__c='TestKey';
        a.secret_AGN__c='TestSecret';
        a.bucket_AGN__c='allergan-icl';
        a.host_AGN__c='s3.eu-west-1.amazonaws.com';
        insert a;
        
    
                  
        Test.startTest();
           Test.setMock(HttpCalloutMock.class, new AGN_ICL_TestRegFormCtrl_Test());
        
        AGN_ICL_TestRegFormCtrl obj = new AGN_ICL_TestRegFormCtrl();
        AGN_ICL_TestRegFormCtrl.fetchClinicAdminDetails();
        AGN_ICL_TestRegFormCtrl.fetchClinicDetails(acc1.id);
        AGN_ICL_TestRegFormCtrl.getCommunityURL();
        AGN_ICL_TestRegFormCtrl.fetchLocatorListing(acc1.id);
        AGN_ICL_TestRegFormCtrl.getBrandPicklistValues();
        AGN_ICL_TestRegFormCtrl.CheckDuplicateClinicAdmin(adminEmail);
        AGN_ICL_TestRegFormCtrl.getCountryWiseFields();
        String loc= JSON.serialize(l1);
        AGN_ICL_TestRegFormCtrl.updateRec(loc, l1.Id);
        Id parentid=Id.valueof('a7q6E0000006XEXQA2');
        system.debug('Id'+parentid);
        AGN_ICL_TestRegFormCtrl.locatorimage(l1.Id,'Tulips.jpg','images/jpg','/y17mO9niPP124');
        AGN_ICL_TestRegFormCtrl.imagefetch();
            
        Test.stopTest();
         
   
    }

}