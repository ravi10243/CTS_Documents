@isTest
public class AGN_AMI_RotatingBannerTestClass {
    
    @isTest
    public static void AGN_AMI_RotatingBannerTestMethod2(){
        Test.startTest();
        
        
        // Creating Admin User
        User adminUser2 = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        
        
        // Creating HCP user
        User hcpUser2 = AGN_AMI_TestData_Factory.createCommunityUser('U1');
        System.runAs(hcpUser2){
            
            //Method to test list of 5 banners in a for Loop
            //integer Number_of_banner = 5; 
            //List<AMI_Banner_AGN__c> baner = AGN_AMI_TestData_Factory.createBanner(Number_of_banner);
            //system.debug(baner + 'testing banner');
            
            //Method to test 5 banners with different configurations
            List<AMI_Banner_AGN__c> baner2 = AGN_AMI_TestData_Factory.createBanner2();
            
            //Initialising the class
            AGN_AMI_RotatingBannerController Test_Banner = new AGN_AMI_RotatingBannerController();
            
			// TC 1 - Validating the Direct Link page redirection for 1st banner
            PageReference pageRef = Page.AGN_AMI_Home_Page;
            Test.setCurrentPage(pageRef);
            ApexPages.Currentpage().getParameters().put('bannerId', baner2[0].id);			            
            PageReference pr=Test_Banner.setBannerPopup();
            PageReference expectedPage = new PageReference(baner2[0].Link_AGN_AMI__c);
            
            //To validate the Page redirection is working or not
            system.assertEquals(expectedPage.getUrl(),pr.getUrl());
            
            //TC 2,3,4 - Validating Active checkbox , global checkbox functionality and the date range
            //Active banners are only 7 out of 8, but only 5 are under valid date range or dates are null.
            //The banners other than for GB is not fetched since Global box is set false for them, hence we should have 5 banners displayed
            system.assertEquals(5,Test_Banner.banners.size());
            
            //TC 5 - Validate that the first banner fetched, has sequence number 1 to validate if sequence is working or not            
			system.assertEquals(1,Test_Banner.banners[0].Sequence_AGN_AMI__c);
            
        }
    }
}