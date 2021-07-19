@isTest
public class AGN_AMI_BannerUtilControllerTest {

    @isTest
    public static void AGN_AMI_BannerUtilControllerTestMethod(){
         Test.startTest();
        
        
        // Creating Admin User
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        
        
        // Creating HCP user
        User hcpUser = AGN_AMI_TestData_Factory.createCommunityUser('U1');
        System.runAs(hcpUser){
            List<AMI_Banner_AGN__c> baner = AGN_AMI_TestData_Factory.createBanner(3);
            
            Attachment att=new Attachment(name='pallavi');
            ApexPages.StandardController sc = new ApexPages.StandardController(baner[0]);
        AGN_AMI_BannerUtilController bannerUtil =new AGN_AMI_BannerUtilController(sc);
            
        
        PageReference pageRef = apexpages.currentpage();
        pageRef.getParameters().put( 'Id', String.valueOf(baner[0].id));
        PageReference pr= bannerUtil.attachImage();
        Test.setCurrentPage(pageRef);
        
        }   
        
        
        }
        
        @isTest
         public static void AGN_AMI_BannerUtilControllerTestMethod1(){
         Test.startTest();
        
        
        // Creating Admin User
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        
        
        // Creating HCP user
         string bodyStr='this is body string';
        User hcpUser = AGN_AMI_TestData_Factory.createCommunityUser('U1');
        System.runAs(hcpUser){
            List<AMI_Banner_AGN__c> baner = AGN_AMI_TestData_Factory.createBanner(3);
           List<AMI_Banner_AGN__c>baner1= AGN_AMI_TestData_Factory.createBanner2();
          Attachment att=new Attachment(parentid=baner1[1].id, name='pallavi',body=Blob.valueOf(bodyStr));
           
            ApexPages.StandardController sc = new ApexPages.StandardController(baner1[1]);
        AGN_AMI_BannerUtilController bannerUtil =new AGN_AMI_BannerUtilController(sc);
            
        
        PageReference pageRef = apexpages.currentpage();//cuurent page
        //pageRef.getParameters().put('bannerId', att.id);
           pageRef.getParameters().put( 'Id', String.valueOf(baner1[1].id));
            bannerUtil.BannerImage=att;
       PageReference pr= bannerUtil.attachImage();
             PageReference pr1= bannerUtil.updateCallToAction();
            PageReference pr2= bannerUtil.updateBanner();
            
        Test.setCurrentPage(pageRef);
        
            
        
        
        
        }      
        
    }
    

}