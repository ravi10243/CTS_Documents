@isTest(SeeAllData=true)
public class AGN_CoolNetSupportControllerTest {

static User currentUser;
static Contact Con ;


     static void CreateData(){
         
         Profile prof=[select Id from Profile where Name='CoolNet User'];
        
         currentUser= [Select Id From User Where profileid=:prof.id and isactive=true Limit 1];

         
     }
   
         
     static testMethod void TestMain() {
           
             CreateData();
             
             System.runas(currentUser){
             
                 Test.startTest();
                 AGN_CoolNetSupportController objTest=new AGN_CoolNetSupportController();
                 Test.stopTest();
                 
                 System.assertNotEquals(objTest.supportList,null);
         
             }
                 
     }

}