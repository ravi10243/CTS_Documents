@isTest
public class AGN_SPARK_TermsOfUseTest {
    @isTest
    public  static void AGN_SPARK_TermsOfUseMethod(){
		test.startTest();
        	Map<String,String> getimg =AGN_SPARK_TermsOfUse.getImages();
        	system.assertEquals(True, getimg.size()>0, 'Do not neglect meaningful messages!');
        test.stopTest();
    }
}