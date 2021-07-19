/**
 * Description: test class for AGN_AMI_AnatomyAppDiscLoginHandler 
 * @Author: Gaetan Barbeu
 * 
 * Modification Log
 * ==================================================
 * Version  Date            Author          Modification
 * -------  ----            ------          -------------
 * CR#      04.08.2020      Gaetan Barbeu
 * ==================================================
 */

@isTest
public class AGN_AMI_AnatomyAppDiscLoginHandlerTest {
    static User setupTestData(){
        
        User adminUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (adminUser) {
            Country_vod__c counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
                
            AMI_SPecality_AGN__c spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
                
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            Account acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Profile pf= [Select Id from profile where Name='AMI Customer Community']; 
            
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            User anatomyComUser = new User(firstname = 'AnaCommunity', 
                                            lastName = 'User', 
                                            email = 'anacommnunity.user@allergan.com', 
                                            Username = 'anacommnunity.user@allergan.com', 
                                            EmailEncodingKey = 'ISO-8859-1', 
                                            Alias = uniqueName.substring(18, 23), 
                                            TimeZoneSidKey = 'Europe/London', 
                                            LocaleSidKey = 'en_GB',
                                            ContactId = ConId,
                                            MA_User_Country_Code_AGN__c = 'GB',
                                            LanguageLocaleKey = 'en_GB', 
                                            ProfileId = pf.Id
                                            ); 
            
            
            insert anatomyComUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Anatomy_App_Permission_Set_Name];
            if(ps!= null)
                insert new PermissionSetAssignment(AssigneeId = anatomyComUser.id, PermissionSetId = ps.Id); 
            
            System.setpassword(anatomyComUser.Id, 'pwd12345');
            return  anatomyComUser;
        }
        return adminUser;
    }

    @isTest
    public static void testlogin(){
        Test.startTest();
        User anatomyComUser = setupTestData();
        try{
            AGN_AMI_AnatomyAppDiscLoginHandler amiAnaDiscLoginHandler = new AGN_AMI_AnatomyAppDiscLoginHandler();
            amiAnaDiscLoginHandler.login(anatomyComUser.Email, 'https://AMIAnatomyApp.com', null);
        }catch (Exception e){
            system.debug(e.getMessage());
        }
        Test.stopTest();
    }
}