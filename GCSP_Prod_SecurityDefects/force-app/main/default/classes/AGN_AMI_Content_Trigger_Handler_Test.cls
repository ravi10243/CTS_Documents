@istest public class AGN_AMI_Content_Trigger_Handler_Test {
    
    @testsetup
    public static void testsetup(){
        
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Country_vod__c counVod;
        counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
        insert counVod;
        AMI_Content_AGN__c aca1 = new AMI_Content_AGN__c(Content_Type_AGN__c = 'eLearning', Country_AGN__c = counVod.Id );
        insert aca1;
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        insert module;
        AMI_Sessions_AGN__c asa3 = new AMI_Sessions_AGN__c(Parent_Module_AGN__c = module.Id, Session_Code_AGN__c = 'S92', Country_AGN__c = counVod.Id, Status_AGN__c = 'In Progress', Name_AGN__c = 'Test Session 3',Duration_AGN__c=1,ZINC_number_agn__c='qwerty');
        insert asa3;
    }
    
    @isTest
    public static void testManageSessionUpdate(){
        
        AMI_Content_AGN__c  content = ([select id,Content_URL_AGN__c from AMI_Content_AGN__c limit 1 ]);
        content.Content_URL_AGN__c ='test';
        update content; 
    }
    
}