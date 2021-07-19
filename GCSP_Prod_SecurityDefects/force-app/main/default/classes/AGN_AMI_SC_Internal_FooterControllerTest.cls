@isTest
public without sharing class AGN_AMI_SC_Internal_FooterControllerTest {
    static Id currId;
    static Id lrdId;
    public static User dataCreation()
    {
        User u;
        Account acc; 
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, Country_code__c = 'GB', 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId);
        AMI_Learning_AGN__c program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId);
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId);
        insert module;
        insert program;
        insert curriuclum;
        currId = curriuclum.Id;
        AMI_Lrn_Rel_Dtl_AGN__c alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id);
        insert alrd;
        lrdId = alrd.Id;
        return u;
    }
    
    @isTest
    public static void testFooterController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            PageReference pageRef = Page.AGN_AMI_Home_Page;
        	Test.setCurrentPage(pageRef);
            AGN_AMI_SC_Internal_FooterController interFooterController = new AGN_AMI_SC_Internal_FooterController(); 
            
            PageReference pageRef2 = Page.AGN_AMI_Curriculam_Page;
        	Test.setCurrentPage(pageRef2);
            ApexPages.currentPage().getParameters().put('currId', currId);
            AGN_AMI_SC_Internal_FooterController interFooterController2 = new AGN_AMI_SC_Internal_FooterController();
            
            PageReference pageRef3 = Page.AGN_AMI_Module_Details_Page;
        	Test.setCurrentPage(pageRef3);
            ApexPages.currentPage().getParameters().put('lRDId', lRDId);
           AGN_AMI_SC_Internal_FooterController interFooterController3 = new AGN_AMI_SC_Internal_FooterController(); 
            
            System.assertNotEquals(null, interFooterController);
        }
        Test.stopTest();
    }
}