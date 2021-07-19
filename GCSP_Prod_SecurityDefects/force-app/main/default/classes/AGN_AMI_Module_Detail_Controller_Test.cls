@isTest
public class AGN_AMI_Module_Detail_Controller_Test {
    
   /* public void AGN_AMI_Module_Detail_Controller_Test(){
        
    }*/
    static Id currId;
    static AMI_Learning_AGN__c module;
    static AMI_Learning_AGN__c module1;
    static AMI_Learning_AGN__c module2;
    static AMI_Lrn_Rel_Dtl_AGN__c alrd;
    static AMI_Lrn_Rel_Dtl_AGN__c alrd3;
    static AMI_Lrn_Rel_Dtl_AGN__c alrd2;
    static AMI_Sessions_AGN__c asa1;
    static AMI_Sessions_AGN__c asa2;
    static AMI_Learning_Faculty_AGN__c alfag;
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
            //counVod = [SELECT Id FROM Country_vod__c Where Name = 'GB'];
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', firstname='Demo', lastname='Testing', languagelocalekey='en_US', 
                         localesidkey='en_GB', profileid = profileId, Country_code__c = 'GB',
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        
        module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        module1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module1', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module2', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        AMI_Learning_AGN__c module3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module3', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        AMI_Learning_AGN__c program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        AMI_Learning_AGN__c program1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program1', RecordTypeId = programRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
       
        insert module;
        insert module1;
        insert module2;
        insert module3;
        insert program;
        insert program1;
        insert curriuclum;
        
        currId = curriuclum.Id;
        alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Lrn_Rel_Dtl_AGN__c alrd1 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module1.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        alrd2 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module2.Id, Program_AGN__c = program1.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        alrd3 = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module3.Id, Program_AGN__c = program1.Id, Curriculum_AGN__c = curriuclum.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        insert alrd;
        insert alrd1;
        insert alrd2;
        insert alrd3;
        
        AMI_Learning_Path_AGN__c alp = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        AMI_Learning_Path_AGN__c alp1 = new AMI_Learning_Path_AGN__c(Module__c = alrd1.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        AMI_Learning_Path_AGN__c alp2 = new AMI_Learning_Path_AGN__c(Module__c = alrd2.Id, HCP_AGN__c = acc.Id, Country_AGN__c = counVod.Id);
        
        insert alp;
        insert alp1;
        //insert alp2;       
       
        AMI_Path_Session_AGN__c aps1 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp.Id, Total_Value_AGN__c = 1,Name_AGN__c = 'Test Session Path 1');
        AMI_Path_Session_AGN__c aps2 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp1.Id,Name_AGN__c = 'Test Session path 2');
        AMI_Path_Session_AGN__c aps3 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp2.Id, Total_Value_AGN__c = 1,Name_AGN__c = 'Test Session path 3');
        AMI_Path_Session_AGN__c aps4 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp2.Id,Name_AGN__c = 'Test Session Path 4');
        AMI_Path_Session_AGN__c aps5 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp2.Id, Total_Value_AGN__c = 1,Name_AGN__c = 'Test Session Path 5');
        insert aps1;
        insert aps2;
        //insert aps3;
        //insert aps4;
        //insert aps5;
        
        AMI_Content_AGN__c aca1 = new AMI_Content_AGN__c(Content_Type_AGN__c = 'eLearning', Country_AGN__c = counVod.Id);
        AMI_Content_AGN__c aca2 = new AMI_Content_AGN__c(Content_Type_AGN__c = 'Video', Country_AGN__c = counVod.Id);
        AMI_Content_AGN__c aca3 = new AMI_Content_AGN__c(Content_Type_AGN__c = 'Live Webinar', Country_AGN__c = counVod.Id);
        insert aca1;
        insert aca2;
        insert aca3;
        
        asa1 = new AMI_Sessions_AGN__c(Parent_Module_AGN__c = module.Id, Session_Code_AGN__c = 'S90', Country_AGN__c = counVod.Id, AMI_Content_AGN__c = aca1.Id, Status_AGN__c = 'Complete', Name_AGN__c = 'Test Session 1');
        asa2 = new AMI_Sessions_AGN__c(Parent_Module_AGN__c = module1.Id, Session_Code_AGN__c = 'S91', Country_AGN__c = counVod.Id, AMI_Content_AGN__c = aca2.Id, Status_AGN__c = 'Not started', Name_AGN__c = 'Test Session 2');
        AMI_Sessions_AGN__c asa3 = new AMI_Sessions_AGN__c(Parent_Module_AGN__c = module2.Id, Session_Code_AGN__c = 'S92', Country_AGN__c = counVod.Id, AMI_Content_AGN__c = aca3.Id, Status_AGN__c = 'In Progress', Name_AGN__c = 'Test Session 3');
        insert asa1;
        insert asa2;
        insert asa3;
        
        AMI_Faculty_AGN__c alfa= new AMI_Faculty_AGN__c(AMI_Specialty_AGN__c = spcl.Id, Country_LKP_AGN__c = counVod.Id, Name_AGN__c= 'Test Faculty', Active_AGN__c=true);
        AMI_Faculty_AGN__c alfa1= new AMI_Faculty_AGN__c(AMI_Specialty_AGN__c = spcl.Id, Country_LKP_AGN__c = counVod.Id, Name_AGN__c= 'Test Faculty 1');
        insert alfa;       
        insert alfa1;
        
        alfag = new AMI_Learning_Faculty_AGN__c(AMI_Faculty_AGN__c = alfa.id, AMI_Faculty_Role_AGN__c = 'Aesthetic Doctor', AMI_Learning_AGN__c=module.Id);
        AMI_Learning_Faculty_AGN__c alfag1 = new AMI_Learning_Faculty_AGN__c(AMI_Faculty_AGN__c = alfa1.id, AMI_Faculty_Role_AGN__c = 'Aesthetic Doctor', AMI_Learning_AGN__c=module1.Id);
        insert alfag;
        insert alfag1;
        
        AMI_HCP_modules_AGN__c hcpMod = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd.Id, AMI_Account_AGN__c = acc.Id);        
        AMI_HCP_modules_AGN__c hcpMod1 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd1.Id, AMI_Account_AGN__c = acc.Id);
        AMI_HCP_modules_AGN__c hcpMod3 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd2.Id, AMI_Account_AGN__c = acc.Id);
        AMI_HCP_modules_AGN__c hcpMod4 = new AMI_HCP_modules_AGN__c(AMI_Module_AGN__c = alrd3.Id, AMI_Account_AGN__c = acc.Id);
        insert hcpMod;   
        insert hcpMod1; 
        insert hcpMod3;   
        insert hcpMod4; 
        
        AMI_Module_Restriction_AGN__c modRes = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module.Id);
        AMI_Module_Restriction_AGN__c modRes1 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module1.Id);
        AMI_Module_Restriction_AGN__c modRes2 = new AMI_Module_Restriction_AGN__c(AMI_Specialty_AGN__c = spcl.Id, AMI_Learning_agn__c = module2.Id);
        
        insert modRes;
        insert modRes1;
        insert modRes2;
        
        AMI_HCP_Profile_AGN__c ahpa = new AMI_HCP_Profile_AGN__c(Account_AGN__c = acc.Id, Injector_Status_AGN__c = 'True');
        insert ahpa;
        
        return u;
    }
    
    @isTest
    public static void testModuleDetailsController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            System.currentPageReference().getParameters().put('country', 'GB');  
            System.currentPageReference().getParameters().put('lRDId', alrd.Id);
            System.currentPageReference().getParameters().put('sessionStatus','0%');
            
            System.currentPageReference().getParameters().put('sessionId', asa1.Id);
            
            PageReference pr1 = new PageReference(System.Label.AGN_AMI_Module_Details_Page);              
            AGN_AMI_Module_Detail_Controller modDetailController = new AGN_AMI_Module_Detail_Controller(); 
            modDetailController.duration = '45';
            modDetailController.description = 'description';
            modDetailController.currName = 'currName';
            modDetailController.priorId ='priorId';
            modDetailController.currdesc = module;
            modDetailController.counter = 2;
            modDetailController.facultyDetailsID = alfag.Id;
            modDetailController.sessionStatus = 'ContentType=HTML;TotalPages=11;CurrentPage=9;Status=Pending;CustomValue=null@@@@objective_local@@@@facial_dynamics@@@@aging_expression@@@@treatment_plan@@@@gender_specific;Feedback=null';
            System.currentPageReference().getParameters().put('confirmation', 'true');
            System.assertNotEquals(null, modDetailController);
            System.assertEquals(1, modDetailController.lstLFA.size());
            System.assertEquals(1, modDetailController.lstSession.size());
            System.assertEquals(asa1.Id, modDetailController.sessionId);
            //System.assertEquals(4, Integer.valueOf(modDetailController.moduleCount));
          
            modDetailController.facultyDetails();
            System.assertEquals(alfag.AMI_Faculty_AGN__c, modDetailController.lstFaculty.AMI_Faculty_AGN__c);
            
           	System.currentPageReference().getParameters().put('lRDId', alrd2.Id); 
            AGN_AMI_Module_Detail_Controller modDetailController2 = new AGN_AMI_Module_Detail_Controller();
            System.assertNotEquals(null, modDetailController2);
            
            PageReference testpr1 = modDetailController2.AddCurrToLearningPath();         
     		System.assertEquals(null, testpr1);
            PageReference testpr2 = modDetailController.sessionInfoUpdate();
            System.assertEquals(null, testpr2);   
            PageReference testpr4 = modDetailController.moveModDet();  
            System.assertEquals('/apex/AGN_AMI_Module_Details_Page?lRDId='+alrd.Id , testpr4.getUrl());
            
        }
        Test.stopTest();
    }
}