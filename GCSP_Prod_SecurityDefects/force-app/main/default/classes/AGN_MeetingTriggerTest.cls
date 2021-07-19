/*********************************************************************** 
   
    * Created Date: 24 August 2016
    * Purpose: Created as a part of LATAM Phase 2
    * Test Class for Meeting object Trigger
    
************************************************************************/



@isTest(SeeAllData=false)
public with sharing class AGN_MeetingTriggerTest {
static Medical_Event_vod__c  obj2; 

static Account objAccount; 

   static testMethod void testMeetingTrigger() {
            
            createData();
            test.StartTest();          
            
            System.assertnotEquals(obj2, null);
        }



      static void createData() {
            
            List<User> lstUsr= [SELECT Country_Code__c FROM User WHERE Id = : UserInfo.getUserId()];
            
            objAccount=new Account();
            objAccount.Name='Test';
            
            insert objAccount ;
            
            RecordType rtCase=[SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Case' and name='PMO Case Record Type'];
        
            AGN_Meeting_Setting__c setting=new AGN_Meeting_Setting__c();
            setting.Case_Creation_CountryCode_AGN__c=lstUsr[0].Country_Code__c ;
            setting.Case_Creation_Recordtype__c='PMO Case Record Type';
            setting.Case_Creation_CaseType_AGN__c='Test' ;
            insert setting;
            
            
            RecordType rtMeetingEvent=[SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Medical_Event_vod__c' and name='Meeting Event'];
            RecordType rtScholarship=[SELECT id,DeveloperName FROM RecordType WHERE SobjectType='Medical_Event_vod__c' and name='Scholarship'];
            
            
             Meeting_Type_AGN__c obj1=new Meeting_Type_AGN__c();
            obj1.Name='Test';
            obj1.Active_AGN__c=true;
            obj1.Approval_Needed_AGN__c=true;
            obj1.Compliance_Approver_AGN__c=lstUsr[0].id;
            obj1.SPC_Approver_AGN__c=lstUsr[0].id;
            obj1.Level_3_Approver_AGN__c=lstUsr[0].id;
            obj1.Country_Code_AGN__c=lstUsr[0].Country_Code__c ;
            insert obj1;
            
            obj2=new Medical_Event_vod__c ();
            obj2.Name='DG';
            obj2.Status_AGN__c='In progress';
            obj2.Account_AGN__c=objAccount.ID;
            obj2.Account_vod__c=objAccount.ID;
            obj2.Meeting_Type_AGN__c=obj1.id;
            obj2.Country_Code__c=lstUsr[0].Country_Code__c ;
            obj2.recordtypeid=rtMeetingEvent.id;
            insert obj2;
            
            
            Medical_Event_vod__c  obj3=new Medical_Event_vod__c ();
            obj3.Name='DG';
            obj3.Account_AGN__c=objAccount.ID;
            obj3.Status_AGN__c='In progress';
            obj3.Meeting_Type_AGN__c=obj1.id;
            obj3.Country_Code__c=lstUsr[0].Country_Code__c ;
            obj3.recordtypeid=rtScholarship.id;
            insert obj3;
            /*
            Meeting_Cost_AGN__C obj4=new Meeting_Cost_AGN__C ();
            obj4.Medical_Event_AGN__c=obj2.id;
            insert obj4;
                        
            Training_Program_AGN__c obj8=new Training_Program_AGN__c();
            obj8.Name='Test';
            insert obj8;
            
            Medical_Event_vod__c  obj6=new Medical_Event_vod__c ();
            obj6.Name='DG';
            obj6.Status_AGN__c='Attended';
            obj6.Account_AGN__c=objAccount.ID;
            obj6.Account_vod__c=objAccount.ID;
            obj6.Meeting_Type_AGN__c=obj1.id;
            obj6.Country_Code__c=lstUsr[0].Country_Code__c ;
            obj6.recordtypeid=rtMeetingEvent.id;
            obj6.Unlock_AGN__c=true;
            obj6.Program_Target_Calculated_AGN__c=true;
            obj6.Training_Program_AGN__c=obj8.id;
            insert obj6;
            */
            
           

                        
            obj2.Status_AGN__c='Approved';
            update obj2;
            
            obj3.Status_AGN__c='Approved';
            update obj3;

       }
}