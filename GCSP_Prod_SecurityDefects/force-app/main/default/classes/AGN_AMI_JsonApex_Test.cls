@isTest
public class AGN_AMI_JsonApex_Test {

@isTest
public static void testJSONApex()
    {
        Test.startTest();
        AGN_AMI_JsonApex jsonApex = new AGN_AMI_JsonApex();   
        AGN_AMI_JsonApex.parse('{}');
        Test.stopTest();
    }
}