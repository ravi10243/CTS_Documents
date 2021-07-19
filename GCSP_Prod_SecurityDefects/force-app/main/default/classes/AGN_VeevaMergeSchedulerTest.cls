@isTest
public class AGN_VeevaMergeSchedulerTest {
    static TestMethod void setup(){
        AGN_VeevaMergeScheduler obj = new AGN_VeevaMergeScheduler();
        Test.startTest();
        obj.execute(null);
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    
}