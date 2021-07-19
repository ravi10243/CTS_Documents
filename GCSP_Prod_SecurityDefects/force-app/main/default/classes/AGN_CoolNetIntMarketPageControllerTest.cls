@isTest(SeeAllData=false)
public class AGN_CoolNetIntMarketPageControllerTest {

static Marketing_Content_AGN__c obj5;

     static void CreateData(){
          
         Marketing_Data_AGN__c obj1=new Marketing_Data_AGN__c();

         obj1.Category_AGN__c='Internal Marketing';
         obj1.Marketing_Position_AGN__c=1;
         obj1.Name='Internal Marketing';
         insert obj1;
         
         
        
     }
         
     static testMethod void TestMain() {

         CreateData();
         
         Test.startTest();
         
         AGN_CoolNetIntMarketPageController objTest=new AGN_CoolNetIntMarketPageController();
         
         Test.stopTest();
         
         System.assertNotEquals(objTest.intMarketingDataList,null);
        

     }

}