@isTest public class AGN_AMI_Training_Modules_Controller_Test {

static AMI_Learning_Path_AGN__c alp=null;
static AMI_Learning_Path_AGN__c alp2=null;
static AMI_Learning_Path_AGN__c alp3=null;
    
static AMI_Learning_Path_AGN__c alp_1=null;
static AMI_Learning_Path_AGN__c alp2_1=null;
static AMI_Learning_Path_AGN__c alp3_1=null;
static Id currId;
    
public void AGN_AMI_Training_Modules_Controller_Test()
    {
       //AGN_AMI_Training_Modules_Page_Controller
     }
    
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
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id, AMI_Specialty_AGN__c = spcl.id, RecordTypeId = recordId);
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
        
        ///////Start Code block for adding AMI_Learning_AGN__c
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c module1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c module3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c program1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program1', RecordTypeId = programRecordTypeId, IsActive_AGN__c=true);
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId,curriculum_agn__c='Midface', IsActive_AGN__c=true);
        AMI_Learning_AGN__c curriuclum2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId,curriculum_agn__c='Midface', IsActive_AGN__c=true);
        AMI_Learning_AGN__c curriuclum3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId,curriculum_agn__c='Midface', IsActive_AGN__c=true);
        
       
        insert module;
        insert module1;
        insert module2;
        insert module3;
        insert program;
        insert program1;
        insert curriuclum;
        insert curriuclum2;
        insert curriuclum3;  
        
        ///////======================End Code block for adding AMI_Learning_AGN__c=======================///////////////////
        
        
        currId = curriuclum.Id;
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
        AMI_Module_Restriction_AGN__c modRes1 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module1.Id);
        AMI_Module_Restriction_AGN__c modRes2 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module2.Id);
        AMI_Module_Restriction_AGN__c modRes3 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module3.Id);
        insert modRes;
        insert modRes1;
        insert modRes2;
        insert modRes3;
        
        return u;
    }
    
    
    
     @isTest
     public static void testSearchModulesController()
     {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            
            AGN_AMI_Training_Modules_Page_Controller trainingModulePage = new AGN_AMI_Training_Modules_Page_Controller();
            System.assertNotEquals(null, trainingModulePage);
            
            PageReference pr1 = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
            pr1.setRedirect(true);
            pr1.getParameters().put('lRDId',null);
            PageReference testpr1 = trainingModulePage.redirectToModulePage();
         
            PageReference testpr2 = trainingModulePage.GoToModuleDetails();
           
         
            Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Training_Modules_Page)); 
            
            trainingModulePage.sortType='Recommended';
            trainingModulePage.sort();
            
            trainingModulePage.sortType='Recently Added';
            trainingModulePage.sort();
            
            
            string cur='Mid face';
    		string ana='Mid face';
    		string format='eLearning';
            
            trainingModulePage.cur=cur;
            trainingModulePage.ana=ana;
            trainingModulePage.format=format;

			trainingModulePage.strCurricula=cur;
    		trainingModulePage.strAnatomy=ana;
    		trainingModulePage.strFormat=format;
            
            Set<String> lstCurrName ;
    		List<String> lstAnatomy;
    		List<string> lstFormat;
            
            //lstCurrName
            
            
            
            lstAnatomy=trainingModulePage.GetPickListValues('AMI_Learning_AGN__c','Anatomy_Area_AGN__c');
        	lstFormat=trainingModulePage.GetPickListValues('AMI_Learning_AGN__c','Module_Content_Type_AGN__c');
            
            trainingModulePage.searchModuleDetails();
           // System.assertNotEquals(null, trainingModulePage);
        }

        Test.stopTest();
     }

}