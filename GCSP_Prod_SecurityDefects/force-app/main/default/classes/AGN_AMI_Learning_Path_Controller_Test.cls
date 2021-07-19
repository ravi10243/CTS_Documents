@isTest public class AGN_AMI_Learning_Path_Controller_Test {
    
    Static ID alpId;
    Static ID alpId2;
    static AMI_Learning_Path_AGN__c alp=null;
    
    static AMI_Learning_Path_AGN__c alp2=null;
    static AMI_Learning_Path_AGN__c alp3=null;
    
    static AMI_Learning_Path_AGN__c alp_1=null;
    static AMI_Learning_Path_AGN__c alp2_1=null;
    static AMI_Learning_Path_AGN__c alp3_1=null;
    
    public static User dataCreation()
    {
        User u;
        Account acc;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (AdminUser) {
            
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;  
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id, RecordTypeId = recordId);
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
                            timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com',
                            contactId = ConId);
            Insert u;
        }
        //////////////////////////////////////
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId, IsActive_AGN__c = true);
        
        AMI_Learning_AGN__c module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c program2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId, IsActive_AGN__c = true);
        AMI_Learning_AGN__c curriuclum2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId, IsActive_AGN__c = true);
        
        insert module;
        insert program;
        insert curriuclum;
        
        insert module2;
        insert program2;
        insert curriuclum2;
        
        AMI_Lrn_Rel_Dtl_AGN__c alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id);
        
        AMI_Lrn_Rel_Dtl_AGN__c alrd2 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module2.Id, Program_AGN__c = program2.Id, Curriculum_AGN__c = curriuclum2.Id);
        
        insert alrd;
        insert alrd2;
        
        alp = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        alp2 = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        alp3 = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        
        alp_1 = new AMI_Learning_Path_AGN__c(Module__c = alrd2.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        alp2_1 = new AMI_Learning_Path_AGN__c(Module__c = alrd2.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        alp3_1 = new AMI_Learning_Path_AGN__c(Module__c = alrd2.Id, HCP_AGN__c = acc.Id,ownerid=u.id,Country_AGN__c=counVod.Id);
        
        insert alp;
        insert alp2;
        insert alp3;
        
        insert alp_1;
        insert alp2_1;
        insert alp3_1;
        
        alpId  = alp.Id;
        alpId2 = alp2.Id;
        
        AMI_Path_Session_AGN__c alpSess1=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp.id,Total_Value_AGN__c=100,Current_Value_AGN__c=0); 
        AMI_Path_Session_AGN__c alpSess2=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp2.id,Total_Value_AGN__c=100,Current_Value_AGN__c=40);
        AMI_Path_Session_AGN__c alpSess3=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp3.id,Total_Value_AGN__c=100,Current_Value_AGN__c=100);
        
        
        AMI_Path_Session_AGN__c alpSess1_1=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp_1.id,Total_Value_AGN__c=100,Current_Value_AGN__c=0);
        AMI_Path_Session_AGN__c alpSess2_1=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp2_1.id,Total_Value_AGN__c=100,Current_Value_AGN__c=60);
        AMI_Path_Session_AGN__c alpSess3_1=new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c=alp3_1.id,Total_Value_AGN__c=100,Current_Value_AGN__c=100);
        
        insert alpSess1; 
        insert alpSess2; 
        insert alpSess3;
        
        insert alpSess1_1;
        insert alpSess2_1;
        insert alpSess3_1; 
        
        return u;
    }
    @isTest
    public static void testLearningPathController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            ApexPages.currentPage().getParameters().put('removeId',alpId2);
			ApexPages.currentPage().getParameters().put('removeIdNotStarted',alpId);
            AGN_AMI_Learning_Path_Controller learningPathPage = new AGN_AMI_Learning_Path_Controller();
            
            PageReference pr1 = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
            pr1.setRedirect(true);
            pr1.getParameters().put('lRDId',null);
            PageReference testpr1 = learningPathPage.redirectToModulePage();
            
            Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Learning_Path_Link)); 
            
            learningPathPage.removeId=alp2.id; 
            learningPathPage.remove();
            
          	learningPathPage.removeIdNotStarted=alp.id;           
            learningPathPage.removeNotStarted();
            
            /*Test.setCurrentPageReference(new PageReference('https://amidighub-allergancommunityeu.cs84.force.com/AMI/apex/AGN_AMI_Learning_Path_Page')); 
			//System.currentPageReference().getParameters().put('sessionName', 'Test Session 1');
			//PageReference testpr2 = learningPathPage.redirectToSession();
			PageReference pr2 = new PageReference(System.Label.Module_Page_Link);
			pr2.redirectToModulePage();            
			pr2.getParameters().put('lRDId',null);
			pr2.getParameters().put('blVideo','true');
			pr2.getParameters().put('sessionId',null);*/
        }
        Test.stopTest();
    }
    
   
}