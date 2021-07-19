@isTest
public class AGN_AMI_Wrapper_Misc_Test 
{
	@isTest
    public static void testMeetingWrapper()
    {
        Medical_event_vod__c event = new Medical_event_vod__c(Name='Test',Start_Time_vod__c=DateTime.now(),End_Time_vod__c=DateTime.now().addDays(1));
        AGN_AMI_Meeting_Details_Wrapper MDW = new AGN_AMI_Meeting_Details_Wrapper(event,true,'Faculty Name');
        System.assertEquals(MDW.facultyName, 'Faculty Name');
    }
    @isTest
    public static void testStaticClass()
    {
        System.assertEquals(AGN_AMI_Static_Labels.attendeeStatusCancelled, 'Cancelled');
    }
    @isTest
    public static void testLRDSort()
    {
        Country_vod__c counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
        insert counVod;
        
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        
        AMI_Learning_AGN__c module1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module1', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', isActive_AGN__c = true);
        AMI_Learning_AGN__c module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module2', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', isActive_AGN__c = true);
        
        insert module1;
        insert module2;
        
        AMI_Lrn_Rel_Dtl_AGN__c alrd1 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module1.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Lrn_Rel_Dtl_AGN__c alrd2 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module2.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        
        insert alrd1;
        insert alrd2;
        
        List<AGN_AMI_LRD_Sort> ALS1 = new List<AGN_AMI_LRD_Sort>();
        ALS1.add(new AGN_AMI_LRD_Sort(alrd1,'Recommended'));
        ALS1.add(new AGN_AMI_LRD_Sort(alrd2,'Recommended'));
        ALS1.sort();
        
        List<AGN_AMI_LRD_Sort> ALS2 = new List<AGN_AMI_LRD_Sort>();
        ALS2.add(new AGN_AMI_LRD_Sort(alrd1,'Recently Added'));
        ALS2.add(new AGN_AMI_LRD_Sort(alrd2,'Recently Added'));
        ALS2.sort();
    }
    @isTest
    public static void testErrorPage()
    {
        AGN_AMI_Custom_Error_Controller CEC = new AGN_AMI_Custom_Error_Controller();
        CEC.yourPageLevelAction();
    }
}