@isTest
public class AGN_AMI_Landing_FooterController_Test {
    
    public void AGN_AMI_Landing_FooterController_Test()
    {
        
    }
    
    @isTest
    public static void testFooterController()
    {
        Test.startTest();
        PageReference pageRef = Page.AGN_AMI_Landing_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('country', 'GB');    
        ApexPages.currentPage().getParameters().put('lang', 'en_US');   
        AGN_AMI_Landing_FooterController facultyController = new AGN_AMI_Landing_FooterController(); 
        System.assertNotEquals(null, facultyController);
        Test.stopTest();
    }
}