@isTest
public class AGN_SPARK_PrivacyPolicyTest {
     @isTest
    public  static void AGN_SPARK_PrivacyPolicyMethod(){
        test.startTest();
        	Map<String,String> getimg = AGN_SPARK_PrivacyPolicy.getImages();
        	system.assertEquals(True, getimg.size()>0, 'Do not neglect meaningful messages!');
        test.stopTest();
    }

}