@isTest(SeeAllData=false)
public class AGN_CoolNetPageTemplateControllerTest {

static Marketing_Content_AGN__c obj5;
  
         
     static testMethod void TestMain() {
         pagereference ref1;
         
         Test.startTest();
         
         AGN_CoolNetPageTemplateController objTest=new AGN_CoolNetPageTemplateController();
         ref1=objTest.GoToSearchResults();
         
         Test.stopTest();
         
         System.assertNotEquals(ref1,null);
        

     }

}