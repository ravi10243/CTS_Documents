@isTest
public class AGN_AMI_Search_Controller_Test {
    
    static AMI_Learning_AGN__c module;
    static AMI_Learning_AGN__c program;
    static AMI_Learning_AGN__c curriuclum;
    
    public static User dataCreation()
    {
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id,  AMI_Specialty_AGN__c = spcl.id, RecordTypeId = recordId);
            insert acc;
            
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        
        module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId);
        AMI_Learning_AGN__c module1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c module3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, IsActive_AGN__c = true);
        program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c program1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program1', RecordTypeId = programRecordTypeId, IsActive_AGN__c = true);
        curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId, IsActive_AGN__c = true);
       
        insert module;
        insert module1;
        insert module2;
        insert module3;
        insert program;
        insert program1;
        insert curriuclum;
       
        AMI_Lrn_Rel_Dtl_AGN__c alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US');
        AMI_Lrn_Rel_Dtl_AGN__c alrd1 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module1.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US');
        AMI_Lrn_Rel_Dtl_AGN__c alrd2 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module2.Id, Program_AGN__c = program1.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US');
        AMI_Lrn_Rel_Dtl_AGN__c alrd3 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module3.Id, Program_AGN__c = program1.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US');
        insert alrd;
        insert alrd1;
        insert alrd2;
        insert alrd3;
        
        AMI_Learning_Path_AGN__c alp = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        AMI_Learning_Path_AGN__c alp1 = new AMI_Learning_Path_AGN__c(Module__c = alrd1.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        AMI_Learning_Path_AGN__c alp2 = new AMI_Learning_Path_AGN__c(Module__c = alrd2.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        
        insert alp;
        insert alp1;
        insert alp2;
  
        AMI_HCP_modules_AGN__c hcpMod = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd.Id, AMI_Account_AGN__c = acc.Id);        
        AMI_HCP_modules_AGN__c hcpMod1 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd1.Id, AMI_Account_AGN__c = acc.Id);
        AMI_HCP_modules_AGN__c hcpMod2 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd2.Id, AMI_Account_AGN__c = acc.Id);        
        AMI_HCP_modules_AGN__c hcpMod3 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd3.Id, AMI_Account_AGN__c = acc.Id);
        insert hcpMod;   
        insert hcpMod1; 
        insert hcpMod2;   
        insert hcpMod3; 
        
        AMI_Module_Restriction_AGN__c modRes = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module.Id);
        AMI_Module_Restriction_AGN__c modRes1 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = program.Id);
        AMI_Module_Restriction_AGN__c modRes2 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module2.Id);
       
        insert modRes;
        insert modRes1;
        insert modRes2;
        
        return u;
    }
    
    @isTest
    public static void testSearchController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = module.Id;
            fixedSearchResults[1] = program.Id;
            fixedSearchResults[2] = curriuclum.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Search_Link)); 
            System.currentPageReference().getParameters().put('Search', 'Test');
            AGN_AMI_Search_Controller searchController = new AGN_AMI_Search_Controller(); 
                
            
            System.assertNotEquals(null, searchController);
            
            PageReference testpr1 = searchController.GoToModuleDetails();
            testpr1.setRedirect(true);
            testpr1.getParameters().put('moduleId', module.Id);
            searchController.lRDId = module.Id;
            searchController.sort();
        }
        Test.stopTest();
    }
}