@isTest
public class AGN_AMI_SC_Static_Labels_Test { 
     @isTest
    public static void testAMIProfileController()
    {
        Test.startTest();           
            AGN_AMI_SC_Static_Labels labels = new AGN_AMI_SC_Static_Labels(); 
            System.assertNotEquals(null, labels);
        Test.stopTest();
    }

}