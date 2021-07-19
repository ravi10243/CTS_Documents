/**************************************************************************************************************************
@ Class:          AGN_AMI_Community_Form_ControllerTest 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This is a test class for AGN_AMI_Community_Form_Controller
@ PMO:            CR-3257: Clinical Gallery Tab
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.06.2020 / Ayush Basak / Created the class.
***************************************************************************************************************************/
@isTest
public class AGN_AMI_Community_Form_ControllerTest 
{
    @isTest
    public static void AGN_AMI_Community_Form_ControllerTest(){
        Test.startTest();
        
        // Creating HCP user
        User hcpUser = AGN_AMI_TestData_Factory.createCommunityUser('U1');        
        
        // Creating Admin User
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile','U2');
        
        // Adding Admin user to country group
        Group g=[ SELECT id,DeveloperName 
                  FROM group 
                  WHERE DeveloperName ='AGN_AMI_Admin_GB'];
        
        GroupMember grpMem = new GroupMember();
        grpMem.UserOrGroupId =adminUser.id;
        grpMem.GroupId = g.Id;
        insert grpMem;
        
        String title = 'Test Submission Title';
        String description = 'Test Submission Description';
        String contactMode = 'Email';
        
        // Running the class as HCP user
        System.runAs(hcpUser){
            AGN_AMI_Community_page_Controller pageCon = new AGN_AMI_Community_page_Controller(); 
            AGN_AMI_Community_Form_Controller formCon = new AGN_AMI_Community_Form_Controller();
            
            // Passing Attributes from Page controller to Component Controller
            formCon.accountDetail = pageCon.accRecord;
            formCon.contactDetail = pageCon.conRecord;
            formCon.userCountryCode = pageCon.userCountryName;
            
            // Setting variables/fields captured on VF Page
            formCon.newCase.Title_Submitted_AGN_AMI__c  = title;
            formCon.newCase.Description = description;
            formCon.contactMode = contactMode;
            formCon.categoryList[0].checked = true;
            
            // Calling Submit methods, which is called when Submit button is clicked on form component
            formCon.submitRequest();            
        } 
        
        // Checking A case of proper recordtype and proper data has been inserted
        // This has been executed outside HCP Instance as owner of the records are changed to Admin user
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AGN AMI Clinical Gallery Request').getRecordTypeId();
        List<Case> testCases = [SELECT id, OwnerId 
                                 FROM Case 
                                 WHERE RecordTypeId = :caseRecordType 
                                 AND Title_Submitted_AGN_AMI__c = :title
                                 AND Mode_of_Contact_AGN_AMI__c = :contactMode];
        System.assertEquals(1, testCases.size());
        System.assertNotEquals(hcpUser.Id, testCases[0].OwnerId);
        
        // Checking Task has been created for Admin users in the group
        List<Task> testTasks = [SELECT Id 
                                FROM Task 
                                WHERE WhatId = :testCases[0].Id 
                                AND Owner.Id = :adminUser.Id];
        //System.assertEquals(1, testTasks.size());
        
        Test.stopTest();      
        
    }
    
}