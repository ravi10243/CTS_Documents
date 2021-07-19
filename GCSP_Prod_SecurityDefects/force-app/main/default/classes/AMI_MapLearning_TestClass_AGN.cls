@isTest
public class AMI_MapLearning_TestClass_AGN 
{
    static AMI_Lrn_Rel_Dtl_AGN__c alrd;
    public static void dataCreation()
    {
        AMI_SPecality_AGN__c spcl;
        
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
        insert counVod;
        
        spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
        insert spcl;
        
        
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
        Id programRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Program' LIMIT 1].Id;
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        Id currProgRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_Relationship_AGN__c' and DeveloperName ='Curriculum_Program' LIMIT 1].Id;
        Id progModRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_Relationship_AGN__c' and DeveloperName ='Program_Module' LIMIT 1].Id;
        
        List<AMI_Learning_AGN__c> learnings = new List<AMI_Learning_AGN__c>();
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c module1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c module2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c module3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', Restricted_AGN__c = true, RecordTypeId = moduleRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c program = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program', RecordTypeId = programRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c program1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Program1', RecordTypeId = programRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', RecordTypeId = currRecordTypeId,IsActive_AGN__c=true, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        learnings.add(module);
        learnings.add(module1);
        learnings.add(module2);
        learnings.add(module3);
        learnings.add(program);
        learnings.add(program1);
        learnings.add(curriuclum);
        
        insert learnings;
        
        List<AMI_Learning_Relationship_AGN__c> alpList = new List<AMI_Learning_Relationship_AGN__c>();
        AMI_Learning_Relationship_AGN__c ALP1 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = curriuclum.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Program_AGN__c = program.Id, 
                                                                                     Sequence_AGN__c = 1, RecordtypeID = currProgRecordTypeId);
        AMI_Learning_Relationship_AGN__c ALP2 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = curriuclum.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Program_AGN__c = program1.Id,
                                                                                     Sequence_AGN__c = 2, RecordtypeID = currProgRecordTypeId);
        AMI_Learning_Relationship_AGN__c ALP3 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = program.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Module_AGN__c = module.Id, 
                                                                                     Sequence_AGN__c = 1, RecordtypeID = progModRecordTypeId);
        AMI_Learning_Relationship_AGN__c ALP4 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = program.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Module_AGN__c = module1.Id, 
                                                                                     Sequence_AGN__c = 2, RecordtypeID = progModRecordTypeId);
        AMI_Learning_Relationship_AGN__c ALP5 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = program1.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Module_AGN__c = module2.Id,
                                                                                     Sequence_AGN__c = 1, RecordtypeID = progModRecordTypeId);
        AMI_Learning_Relationship_AGN__c ALP6 = new AMI_Learning_Relationship_AGN__c(AMI_Parent_Learning_AGN__c = program1.Id, Country_AGN__c = counVod.Id, 
                                                                                     Child_Module_AGN__c = module3.Id, 
                                                                                     Sequence_AGN__c = 2, RecordtypeID = progModRecordTypeId);
        alpList.add(ALP1);
        alpList.add(ALP2);
        alpList.add(ALP3);
        alpList.add(ALP4);
        alpList.add(ALP5);
        alpList.add(ALP6);
        
        insert alpList;
        
        alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Program_AGN__c = program.Id, Curriculum_AGN__c = curriuclum.Id,Language_AGN__c = 'en_US');
        insert alrd;
        
        AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                    CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                    Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                    User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
        insert AUS;
    }
    @isTest
    public static void testHomeController()
    {
        Test.startTest();
        dataCreation();
        
        AMI_MapLearning_AGN.Learning(alrd.Id);
        
        Test.stopTest();
    }
}