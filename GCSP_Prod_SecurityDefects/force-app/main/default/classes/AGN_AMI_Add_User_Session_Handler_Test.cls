@istest
public class AGN_AMI_Add_User_Session_Handler_Test {
   
        
    @testsetup
    public static void testsetup(){
        
         
        Country_vod__c counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Name = 'GB');
        insert counVod; 
        Id moduleRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Module' LIMIT 1].Id;
       
        AMI_Learning_AGN__c module = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Module', RecordTypeId = moduleRecordTypeId, Country_AGN__c = counVod.Id, Language_AGN__c = 'en_US', IsActive_AGN__c = true);
        insert module;
        
        AMI_Lrn_Rel_Dtl_AGN__c alrd = new AMI_Lrn_Rel_Dtl_AGN__c(Module_AGN__c = module.Id, Language_AGN__c = 'en_US', Country_AGN__c = counVod.Id);
        insert alrd;
        
        AMI_Learning_Path_AGN__c alp = new AMI_Learning_Path_AGN__c(Module__c = alrd.Id, Country_AGN__c = counVod.Id);
         insert alp;
         
        AMI_Sessions_AGN__c asa3 = new AMI_Sessions_AGN__c(Parent_Module_AGN__c = module.Id, Session_Code_AGN__c = 'S92', Country_AGN__c = counVod.Id, Status_AGN__c = 'In Progress', Name_AGN__c = 'Test Session 3',Duration_AGN__c=1,ZINC_number_agn__c='qwerty');
        insert asa3;
        
        AMI_Path_Session_AGN__c aps1 = new AMI_Path_Session_AGN__c(AMI_Learning_Path_AGN__c = alp.Id, Total_Value_AGN__c = 1,Name_AGN__c = 'Test Session 3',Session_Code_AGN__c = 'S92',Duration_AGN__c=1,ZINC_number_agn__c='qwerty');
       insert aps1;
      
        
        
    }
    @isTest
    public static void testManageSessionUpdate(){
        //testsetup();
        
       AMI_Sessions_AGN__c  session1 = ([select Name_AGN__c,Session_Code_AGN__c,Parent_Module_AGN__c,Country_AGN__c,Duration_AGN__c,ZINC_number_agn__c,id from AMI_Sessions_AGN__c limit 1]);
        session1.Name_AGN__c= 'test';
        session1.Session_Code_AGN__c= 'S12';
        session1.Duration_AGN__c= 1;
        session1.ZINC_number_agn__c= 'test';
        update session1;

    }
    @isTest
    public static void testManageSessiondelete(){
       AMI_Sessions_AGN__c  session2 =([select Name_AGN__c,Session_Code_AGN__c,Parent_Module_AGN__c,Country_AGN__c,Duration_AGN__c,ZINC_number_agn__c,id from AMI_Sessions_AGN__c limit 1]);
        delete session2;
    }
}