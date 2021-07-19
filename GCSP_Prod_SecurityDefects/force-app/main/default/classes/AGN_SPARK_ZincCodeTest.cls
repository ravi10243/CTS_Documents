/*Test class of AGN_SPARK_ZincCode
*/
@isTest
public class AGN_SPARK_ZincCodeTest {
    public static testmethod void getZincDetail(){
      Test.startTest();
	   SPARK_Page_ZincCode_AGN__mdt znc =[SELECT Label,Date_of_Prep_AGN__c, Zinc_Code_AGN__c FROM SPARK_Page_ZincCode_AGN__mdt  LIMIT 1];
       SPARK_Page_ZincCode_AGN__mdt zincname=AGN_SPARK_ZincCode.getZincDetail(znc.Label);
      Test.stopTest();
     system.assertNotEquals(znc.Label, 'page');
    }   
}