@isTest
public class AGN_SPARK_ContactUsTest {
    @isTest
    public  static void AGN_SPARK_ContactUsMethod(){
        test.startTest();
        	Map<String,String> getimg =AGN_SPARK_ContactUs.getImages();
        	system.assertEquals(True, getimg.size()>0, 'Do not neglect meaningful messages!');
        test.stopTest();
        
    }
}