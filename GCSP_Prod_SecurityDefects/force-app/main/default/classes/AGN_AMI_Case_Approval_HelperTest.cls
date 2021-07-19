/**************************************************************************************************************************
@ Class:          AGN_AMI_Case_Approval_HelperTest 
@ Version:        1.0
@ Author:         Ambroz Khan (MdAmbroz.khan@cognizant.com)
@ Purpose:        This is a test class for AGN_AMI_Case_Approval_Helper class.
@ PMO:            CR-3257: Clinical Gallery Tab
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 23.06.2020 / Ambroz / Created the class.
***************************************************************************************************************************/
@isTest
public class AGN_AMI_Case_Approval_HelperTest 
{
    
    @isTest
    public static void test_createProjects(){
        Test.startTest();
        user hcpUser = AGN_AMI_TestData_Factory.createCommunityUser('U1');  
        user adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        List<case> list_of_cases = AGN_AMI_TestData_Factory.createAMIProjectAGNcaselist(hcpUser,adminUser,2);  
        List<ID> listofids = new List<ID>();
        
        for(case pr : list_of_cases) {
            ID idofobject = pr.id;
            listofids.add(idofobject) ;  
        }

        System.runAs(adminUser){
            AGN_AMI_Case_Approval_Helper.createProjects(listofids);
            List<case> project_test =[SELECT id FROM case];
            List<AMI_Project_AGN__c> projectList = new List<AMI_Project_AGN__c>();
            projectList = [SELECT id FROM AMI_Project_AGN__c];
            system.assertEquals(2,project_test.size());
            system.assertEquals(2,projectList.size());
            system.assertNOTEquals(6,project_test.size());
            system.assertNOTEquals(9,projectList.size());
        } 
        Test.stopTest();     
    }
    /*
@isTest
public static void test_bulkCase(){
Test.startTest();
user hcpUser = AGN_AMI_TestData_Factory.createCommunityUser('U1');   
user adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
List<case> list_of_cases = AGN_AMI_TestData_Factory.createAMIProjectAGNcaselist(hcpUser,adminUser,100); 
update list_of_cases;
Test.stopTest();     
}
*/
}