/**************************************************************************************************************************
@ Class:          AGN_AMI_EventLiveStreamBanner_Cont_Test
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Test class for AGN_AMI_EventLiveStreamBanner_Controller.
@ PMO:            CR-3141: Banner to communicate live stream events issues
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.04.2020 / JOYDEV MONDOL / Created the test class.
***************************************************************************************************************************/

@isTest(seeAllData = false)
private class AGN_AMI_EventLiveStreamBanner_Cont_Test {
    
    
    /**********************************************************************************************************************
    @ Method:         testPollEventMessageSystemAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE     Constructor and action poller should be able to initialize and fresh based on custom 
                                    settings and event field values.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testPollEventMessageSystemAdmin() {
                
        /** TEST DATA **/
        
        User sysAdminUser = AGN_AMI_TestData_Factory.createUser('System Administrator', 'U1');
        Medical_Event_vod__c evnt = AGN_AMI_TestData_Factory.createMeeting('AMI Portal Event');
        AMIPortalPushNotification__c pshSet = AGN_AMI_TestData_Factory.createPushNotCustomSetting('Live Streaming');
        
        /** PROFILE TESTING **/
        
        //Profile: Sytem Administrtor
        System.runAs(sysAdminUser) {
            Test.startTest();
                
                //STEP 1: Launch portal event detail page
                ApexPages.currentPage().getParameters().put('eventId', String.valueOf(evnt.Id));
                AGN_AMI_EventLiveStreamBanner_Controller con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, false);                    /*push notification disabled by default*/
                System.assertEquals(con.Language, sysAdminUser.LocaleSidKey);   /*fetched correct current user language*/
                System.assertEquals(con.Meeting.ShowMessage__c, false);         /*Message disabled by default*/
                
                //STEP 2: Push notification switched 
                pshSet.Enabled__c = true;
                update pshSet;
                
                //STEP 3: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, true);    /*push notification enabled*/
                
                //STEP 4: Event updated
                String errMsg = 'Test message1';
                Boolean showErr = true;
                
                evnt.ShowMessage__c = showErr;
                evnt.EventMessageR__c = errMsg;
                update evnt;
                
                //STEP 5: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.ShowMessage__c, showErr);     /*Message enabled*/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsg);    /*Message available*/
                
                //STEP 6: Event Updated
                String errMsgx = 'Test message1x';
                
                evnt.EventMessageR__c = errMsgx;
                update evnt;
                
                //STEP 7: Action poll - no manual refresh
                con.pollEventMessage();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsgx);    /*Message updated*/
                
            Test.stopTest();
        }
    } 
    
    /**********************************************************************************************************************
    @ Method:         testPollEventMessageAMIAdmin
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE     Constructor and action poller should be able to initialize and fresh based on custom 
                                    settings and event field values.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testPollEventMessageAMIAdmin() {
                
        /** TEST DATA **/
        
        User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U2');
        AMIPortalPushNotification__c pshSet = AGN_AMI_TestData_Factory.createPushNotCustomSetting('Live Streaming');
        
        /** PROFILE TESTING **/
        
        //Profile: AMI Admin Profile
        System.runAs(adminUser) {
            Test.startTest();
                
                //STEP 1: Create event (sharing model) & Launch portal event detail page
                Medical_Event_vod__c evnt = AGN_AMI_TestData_Factory.createMeeting('AMI Portal Event');
        
                ApexPages.currentPage().getParameters().put('eventId', String.valueOf(evnt.Id));
                AGN_AMI_EventLiveStreamBanner_Controller con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, false);                  /*push notification disabled by default*/
                System.assertEquals(con.Language, adminUser.LocaleSidKey);    /*fetched correct current user language*/
                System.assertEquals(con.Meeting.ShowMessage__c, false);       /*Message disabled by default*/
                
                //STEP 2: Push notification switched 
                pshSet.Enabled__c = true;
                update pshSet;
                
                //STEP 3: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, true);    /*push notification enabled*/
                
                //STEP 4: Event updated
                String errMsg = 'Test message1';
                Boolean showErr = true;
                
                evnt.ShowMessage__c = showErr;
                evnt.EventMessageR__c = errMsg;
                update evnt;
                
                //STEP 5: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.ShowMessage__c, showErr);     /*Message enabled*/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsg);    /*Message available*/
                
                //STEP 6: Event Updated
                String errMsgx = 'Test message1x';
                
                evnt.EventMessageR__c = errMsgx;
                update evnt;
                
                //STEP 7: Action poll - no manual refresh
                con.pollEventMessage();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsgx);    /*Message updated*/
                
            Test.stopTest();
        }
    }
    
    /**********************************************************************************************************************
    @ Method:         testPollEventMessageHCP
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        TEST CASE     Constructor and action poller should be able to initialize and fresh based on custom 
                                    settings and event field values.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 25.04.2020 / JOYDEV MONDOL / Created the test method.
    ***********************************************************************************************************************/
    static testMethod void testPollEventMessageHCP() {
                
        /** TEST DATA **/
        
        User hcp = AGN_AMI_TestData_Factory.createCommunityUser('U3');
        AMIPortalPushNotification__c pshSet = AGN_AMI_TestData_Factory.createPushNotCustomSetting('Live Streaming');
        
        /** PROFILE TESTING **/
        
        //Profile: AMI Customer Community
        System.runAs(hcp) {
            Test.startTest();
            
                //Dummy step to create event otherwise HCP can have access to event records directly
                Medical_Event_vod__c evnt = AGN_AMI_TestData_Factory.createMeeting('AMI Portal Event');
                        
                //STEP 1: Launch portal event detail page
                ApexPages.currentPage().getParameters().put('eventId', String.valueOf(evnt.Id));
                AGN_AMI_EventLiveStreamBanner_Controller con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, false);               /*push notification disabled by default*/
                System.assertEquals(con.Language, hcp.LocaleSidKey);       /*fetched correct current user language*/
                System.assertEquals(con.Meeting.ShowMessage__c, false);    /*Message disabled by default*/
                
                //STEP 2: Push notification switched 
                pshSet.Enabled__c = true;
                update pshSet;
                
                //STEP 3: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/                
                System.assertEquals(con.PushMessage, true);    /*push notification enabled*/
                
                //STEP 4: Event updated
                String errMsg = 'Test message1';
                Boolean showErr = true;
                
                evnt.ShowMessage__c = showErr;
                evnt.EventMessageR__c = errMsg;
                update evnt;
                
                //STEP 5: Refresh page manually
                con = new AGN_AMI_EventLiveStreamBanner_Controller();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.ShowMessage__c, showErr);     /*Message enabled*/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsg);    /*Message available*/
                
                //STEP 6: Event Updated
                String errMsgx = 'Test message1x';
                
                evnt.EventMessageR__c = errMsgx;
                update evnt;
                
                //STEP 7: Action poll - no manual refresh
                con.pollEventMessage();
                
                /** POSITIVE TESTINGS **/
                System.assertEquals(con.Meeting.EventMessageR__c, errMsgx);    /*Message updated*/
                
            Test.stopTest();
        }
    }  
}