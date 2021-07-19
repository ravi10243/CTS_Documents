/**************************************************************************************************************************
@ Class:  AGN_AMI_Community_page_Controller_Test
@ Version: 1.0
@ Author:  Sujan Guha (sujan.guha@cognizant.com)
@ Purpose: Test Class for AGN_AMI_Community_page_Controller
***************************************************************************************************************************/
@isTest
public class AGN_AMI_Community_page_Controller_Test {
	
    @isTest
    public static void testCommunityPageController(){
        
        //Test Data
        
        User comUser =AGN_AMI_TestData_Factory.createCommunityUser('u1');
        Account acc =AGN_AMI_TestData_Factory.createAccountNew();
       	Country_vod__c contr=[SELECT Id FROM Country_vod__c WHERE Name = 'GB']; 
        Account accRecord;
        Contact conRecord;
        String userLanguage;
        String userCountryName;
        String projectId;
        String PROJECTSTATUS;
        Boolean isFilterEmpty;
        
        List<AMI_Project_AGN__c> project = new List<AMI_Project_AGN__c>();
        
        AMI_Project_AGN__c projects= AGN_AMI_TestData_Factory.createAMIProjectAGN();
        List<AMI_Project_AGN__c> projectList;
        projects.Account_AGN_AMI__c=acc.Id;
        projects.Country_AGN__c=contr.Id;  
        
        projectId=projects.Id;
        project.add(projects);
        
       
		Account acc2 =AGN_AMI_TestData_Factory.createAccountNew();
		AMI_Project_AGN__c projects2= AGN_AMI_TestData_Factory.createAMIProjectAGN();
        
        projects2.Account_AGN_AMI__c=acc2.Id;
        projects2.Country_AGN__c=contr.Id; 
		
		Account acc3 =AGN_AMI_TestData_Factory.createAccountNew();
		AMI_Project_AGN__c projects3= AGN_AMI_TestData_Factory.createAMIProjectAGN();
        
        projects3.Account_AGN_AMI__c=acc3.Id;
        projects3.Country_AGN__c=contr.Id;
		
		project.add(projects2);
        project.add(projects3);
		    

        
        //Profile: AMI Community User
        System.runAs(comUser){
            Test.startTest();
            
            //STEP 1: Launch console page
            PageReference pageRef=page.AGN_AMI_Community_Page;
            Test.setCurrentPage(pageRef);
            
            AGN_AMI_Community_page_Controller communityPageController = new AGN_AMI_Community_page_Controller();
            
            
           
           System.assertEquals(communityPageController.project.size(), 0);
            
            //getProjectExists is a Boolean method communityPageController in  returns true by querying AMI_Project_AGN__c
            System.assertEquals(communityPageController.getProjectExists(),true);
            
            

            /**Selecting the Checkbox Response and Refreshing**/
            communityPageController.categoryFilterList[0].checked=true;
            communityPageController.refreshProjects();   
            /*ApexPages.currentPage().getParameters().get('projectId');
            pageRef.getParameters().put('projectId',projectId);
            System.currentPageReference().getParameters().put('projectId',projectId);
			*/
            ApexPages.currentPage().getParameters().put('projectId',projectId);
           
            communityPageController.redirect();
            
           
            
            /** POSITIVE TESTINGS **/
           //System.assert(communityPageController.project.size());
			
            String pageRefRet ='/AMI/AGN_AMI_CommunityDetail_page';
            System.currentPageReference().getParameters().get('projectId');

            //System.assertEquals(communityPageController.redirect(), pageRefRet);
            System.assertNotEquals(communityPageController.redirect(), null);
            //System.assertEquals(expected, actual, msg);
            /** NEGETIVE TESTINGS **/
            //System.assertEquals(communityPageController.project.size(), 0);

            //System.assertEquals(communityPageController.redirect(),null);
            
            Test.stopTest();   
}
        
    	
        
    }
}