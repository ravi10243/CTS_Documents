/**************************************************************************************************************************
@ Class:          AGN_AMI_BannerCommConsole_Cont_Test
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Test class for AGN_AMI_Banner_Comm_Console_Controller.
@ PMO:            CR-3141: Banner to communicate live stream events issues
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test class.
***************************************************************************************************************************/

@isTest(seeAllData = false)
private class AGN_AMI_BannerCommConsole_Cont_Test {    
    
    /*== PROFILE: System Administrator ===================================================================================*/
    
    /**********************************************************************************************************************
    @ Method:         testConstructorSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Query all ami portal events in live status excluding past and future events 
                                 more than 2 days sorted by latest start date/time
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testConstructorSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(String.isBlank(con.RecordTypeId), false);       /*rec type id fetched*/
                System.assertEquals(con.CurrentFilter, 'Both');                     /*current filter - both*/
                System.assertEquals(con.Meetings.size(), 4);                        /*fetched 4/10 events only*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.containsKey(
                                               evnts.get('completed').Id), false);  /*past events excluded*/                
                System.assertEquals(con.Meetings.containsKey(
                                               evnts.get('planned1').Id), false);   /*planned events excluded*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testSaveMessagesSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Save adhoc changes on the events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testSaveMessagesSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: Save adhoc event message - message preps
                Id mId = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                con.Meetings.get(mId).Meeting.EventMessageR__c = 't1';
                con.saveMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId).Meeting.EventMessageR__c, 't1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId).Meeting.ShowMessage__c, false);  /*display status - as is*/
                
                /** NEGETIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, null); /*rec - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testDisplayMessagesSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Set ShowMessage__c = true for all selected events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testDisplayMessagesSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select and display messages
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                Id mId3 = evnts.get('live4').Id;
                con.Meetings.get(mId1).Meeting.EventMessageR__c = 'er1';
                con.Meetings.get(mId1).Selected = true;  
                con.Meetings.get(mId2).Meeting.EventMessageR__c = 'er2';
                con.Meetings.get(mId2).Selected = true;  
                con.displayMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'er1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.ShowMessage__c, true);    /*flag checked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, 'er2'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);    /*flag checked*/
                
                /** NEGETIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, false);   /*flag - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testWithdrawMessagesSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Set ShowMessage__c = false for all selected events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testWithdrawMessagesSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select and display messages
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                Id mId3 = evnts.get('live4').Id;
                con.Meetings.get(mId1).Meeting.EventMessageR__c = 'er1';
                con.Meetings.get(mId1).Selected = true;  
                con.Meetings.get(mId2).Meeting.EventMessageR__c = 'er2';
                con.Meetings.get(mId2).Selected = true;  
                con.Meetings.get(mId3).Meeting.EventMessageR__c = 'er3';
                con.Meetings.get(mId3).Selected = true;  
                con.displayMessages();
                
                //STEP 3: select and withdraw messages
                con.Meetings.get(mId1).Selected = true;                
                con.Meetings.get(mId2).Selected = true;                
                con.Meetings.get(mId3).Selected = false;                
                con.withdrawMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'er1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.ShowMessage__c, false);   /*flag unchecked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, 'er2'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, false);   /*flag unchecked*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, true);   /*flag - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testDisplayBulkMessagesSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: sets common message and show message in bulk
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testDisplayBulkMessagesSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select multiple events and batch update
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;                
                Id mId3 = evnts.get('live4').Id;                
                con.Meetings.get(mId1).Selected = true;
                con.Meetings.get(mId2).Selected = true; 
                
                //STEP 3: click batch update button and set common message and save
                con.showBulkAction();
                con.BlankMeeting.EventMessageR__c = 'com1';
                con.displayBulkMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'com1'); /*msg updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'com1'); /*msg updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);     /*flag checked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);     /*flag checked*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, false);    /*flag - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testAllUtilMethodsSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Covers all the utility methods
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testAllUtilMethodsSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: cover rest of the minor codes
                Id mId1 = evnts.get('live2').Id;
                
                con.SelectedId = mId1;
                con.checkMeeting();
                
                con.SelectAll = false;
                con.checkAll();
                con.SelectAll = true;
                con.checkAll();
                
                con.cancelBulkChanges(); 
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testBulkSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Bulk testing
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testBulkSystemAdmin() {
                
         /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');        
        
        /** TEMPORARY SKIP - for veeva trigger issues
        List<Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createBulkMeetings('AMI Portal Event', 200);
        */
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: update all
                for(AGN_AMI_Banner_Comm_Console_Controller.Meeting m : con.Meetings.values()) {
                    m.Meeting.EventMessageR__c = 'com 1';
                    m.Meeting.ShowMessage__c = true;
                }
                
                /** TEMPORARY SKIP - for veeva trigger issues
                con.saveMessages();
                */
                
                //NO ERROR = SUCCESS
                                
            Test.stopTest();
        }
    }
    
    /*== PROFILE: AMI Admin Profile ======================================================================================*/
    
    /**********************************************************************************************************************
    @ Method:         testConstructorAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Query all ami portal events in live status excluding past and future events 
                                 more than 2 days sorted by latest start date/time
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testConstructorAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(String.isBlank(con.RecordTypeId), false);       /*rec type id fetched*/
                System.assertEquals(con.CurrentFilter, 'Both');                     /*current filter - both*/
                System.assertEquals(con.Meetings.size(), 4);                        /*fetched 4/10 events only*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.containsKey(
                                               evnts.get('completed').Id), false);  /*past events excluded*/                
                System.assertEquals(con.Meetings.containsKey(
                                               evnts.get('planned1').Id), false);   /*planned events excluded*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testSaveMessagesAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Save adhoc changes on the events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testSaveMessagesAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: Save adhoc event message - message preps
                Id mId = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                con.Meetings.get(mId).Meeting.EventMessageR__c = 't1';
                con.saveMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId).Meeting.EventMessageR__c, 't1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId).Meeting.ShowMessage__c, false);  /*display status - as is*/
                
                /** NEGETIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, null); /*rec - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testDisplayMessagesAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Set ShowMessage__c = true for all selected events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testDisplayMessagesAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select and display messages
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                Id mId3 = evnts.get('live4').Id;
                con.Meetings.get(mId1).Meeting.EventMessageR__c = 'er1';
                con.Meetings.get(mId1).Selected = true;  
                con.Meetings.get(mId2).Meeting.EventMessageR__c = 'er2';
                con.Meetings.get(mId2).Selected = true;  
                con.displayMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'er1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.ShowMessage__c, true);    /*flag checked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, 'er2'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);    /*flag checked*/
                
                /** NEGETIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, false);   /*flag - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testWithdrawMessagesAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: Set ShowMessage__c = false for all selected events
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testWithdrawMessagesAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select and display messages
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;
                Id mId3 = evnts.get('live4').Id;
                con.Meetings.get(mId1).Meeting.EventMessageR__c = 'er1';
                con.Meetings.get(mId1).Selected = true;  
                con.Meetings.get(mId2).Meeting.EventMessageR__c = 'er2';
                con.Meetings.get(mId2).Selected = true;  
                con.Meetings.get(mId3).Meeting.EventMessageR__c = 'er3';
                con.Meetings.get(mId3).Selected = true;  
                con.displayMessages();
                
                //STEP 3: select and withdraw messages
                con.Meetings.get(mId1).Selected = true;                
                con.Meetings.get(mId2).Selected = true;                
                con.Meetings.get(mId3).Selected = false;                
                con.withdrawMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'er1'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.ShowMessage__c, false);   /*flag unchecked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.EventMessageR__c, 'er2'); /*rec updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, false);   /*flag unchecked*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, true);   /*flag - as is*/
                                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testDisplayBulkMessagesAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE: sets common message and show message in bulk
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 30.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testDisplayBulkMessagesAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        Map<String, Medical_Event_vod__c> evnts = AGN_AMI_TestData_Factory.createMeetings('AMI Portal Event');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Launch console page
                PageReference pageRef = Page.AGN_AMI_Banner_Communication_Console;
                Test.setCurrentPage(pageRef);                
                AGN_AMI_Banner_Comm_Console_Controller con = new AGN_AMI_Banner_Comm_Console_Controller();
                
                //STEP 2: select multiple events and batch update
                Id mId1 = evnts.get('live2').Id;
                Id mId2 = evnts.get('live3').Id;                
                Id mId3 = evnts.get('live4').Id;                
                con.Meetings.get(mId1).Selected = true;
                con.Meetings.get(mId2).Selected = true; 
                
                //STEP 3: click batch update button and set common message and save
                con.showBulkAction();
                con.BlankMeeting.EventMessageR__c = 'com1';
                con.displayBulkMessages();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'com1'); /*msg updated*/
                System.assertEquals(con.Meetings.get(mId1).Meeting.EventMessageR__c, 'com1'); /*msg updated*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);     /*flag checked*/
                System.assertEquals(con.Meetings.get(mId2).Meeting.ShowMessage__c, true);     /*flag checked*/
                
                /** NEGETIVE TESTINGS **/
                System.assertEquals(con.Meetings.get(mId3).Meeting.ShowMessage__c, false);    /*flag - as is*/
                                
            Test.stopTest();
        }
    }
}