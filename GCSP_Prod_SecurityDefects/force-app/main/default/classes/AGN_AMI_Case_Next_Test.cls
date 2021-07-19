@isTest
public class AGN_AMI_Case_Next_Test {
   
    @isTest(SeeAllData=true)
    public static void testCaseNextController()
    {
        Test.startTest();  
        Case caseObj = [select id, casenumber from case limit 1];
        System.assertEquals(caseObj.Id,AGN_AMI_Case_Next.gotoNextStep(caseObj.Id));
        Test.stopTest();
    }
}