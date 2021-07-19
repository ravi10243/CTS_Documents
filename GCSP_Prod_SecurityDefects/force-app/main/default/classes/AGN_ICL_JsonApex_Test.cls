@isTest
public class AGN_ICL_JsonApex_Test {

@isTest
public static void testJSONApex()
    {
        Test.startTest();
        AGN_ICL_JsonApex jsonApex = new AGN_ICL_JsonApex();   
        AGN_ICL_JsonApex.parse('{}');
        Test.stopTest();
    }
}