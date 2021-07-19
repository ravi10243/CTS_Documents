/**********************************************************************************************************************
@ Class:          AGN_AMI_CommunityDetail_Controller_Test 
@ Version:        1.0
@ Author:         PALLAVI   (pallavi.p3@cognizant.com)
@ Purpose:        creating test class for AGN_AMI_CommunityDetail_Controller
-----------------------------------------------------------------------------------------------------------------------
@ Change history: 06.06.2020 / PALLAVI / Created Test class.
***********************************************************************************************************************/

@isTest
public class AGN_AMI_CommunityDetail_Controller_Test {
    
    /**********************************************************************************************************************
@ Method:        AGN_AMI_CommunityDetail_ControllerTest 
@ Version:        1.0
@ Author:         PALLAVI   (pallavi.p3@cognizant.com)
@ Purpose:        creating test method to cover contactPage,back and AGN_AMI_CommunityDetail_Controller 
-----------------------------------------------------------------------------------------------------------------------
@ Change history: 18.06.2020 / PALLAVI / Created Test Method.
***********************************************************************************************************************/
    
    
    @isTest
    public static void AGN_AMI_CommunityDetail_ControllerTest() {
        Test.startTest();
        
        /** TEST DATA **/
        User Us =AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        
        group gp=[ SELECT id,DeveloperName 
                  FROM group 
                  WHERE DeveloperName ='AGN_AMI_Admin_GB'];
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId =Us.id;
        grpMem1.GroupId = gp.Id;
        insert grpMem1;
        
        User hcp = AGN_AMI_TestData_Factory.createCommunityUser('U3');
        
        
        
        
        //Profile Setting
        System.runAs(hcp) {
            
            
            AMI_Project_AGN__c pro=AGN_AMI_TestData_Factory.createAMIProjectAGN();
            
            
            //Step 1 : Launching detail page of project in clinical gallery 
            ApexPages.Currentpage().getParameters().put('projectId', pro.id);
            AGN_AMI_CommunityDetail_Controller com=new AGN_AMI_CommunityDetail_Controller();
            
            //Step 2 : Contact to find out more information on this project
            com.contactPage();
            
            
            //Step 3 : redirecting to clinical page gallery 
            PageReference pageRef = Page.AGN_AMI_CommunityDetail_page;
            Test.setCurrentPage(pageRef); 
            
            PageReference pr=com.back();
            
            PageReference expectedPage = new PageReference('/AMI/AGN_AMI_Community_Page');
            
            System.assertEquals(expectedPage.getUrl(),pr.getUrl());                        /*Checking Url*/
            
            
        }
        
        
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AGN AMI Clinical Gallery Info Request').getRecordTypeId();
        list <case> cs=[SELECT id FROM Case];
        System.assertEquals(1,cs.size());                            					 /*checking the size of case*/
        test.stopTest();
    }
    
    
    
}