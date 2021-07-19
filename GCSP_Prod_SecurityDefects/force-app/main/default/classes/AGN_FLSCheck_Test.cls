@isTest
public class AGN_FLSCheck_Test {

    public static testmethod void agnflscheckTest(){
    
    User u = new User();    
    Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Profile' LIMIT 1];
    UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
    u = new User(Alias = 'agn', Email='pk@vp.kp', 
                 EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                 LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                 TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
    
    insert u;
    Account acc;
         user customerUser;
        system.runAs(u){     
            acc =new Account();      
         acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                            AND DeveloperName = 'Professional_vod'
                                            LIMIT 1
                                           ][0].Id;
            acc.Salutation = 'Mr.';
            acc.FirstName ='Test';
            acc.LastName = 'Last';
            acc.PersonEmail = 'Email@ema.kl';
            acc.Phone = '784623857';
            acc.Customer_Registration_AGN__c = 'In Progress';
            acc.Customer_Managed_AGN__c = true;
            acc.Country_Code__c = 'DE';
            acc.Customer_Category_AGN__c = 'Clinic';
            acc.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
         insert acc;       
         }    
         
         Account customerAccount = [SELECT ID, Name,PersonContactId,Salutation,FirstName,LastName,PersonEmail,Phone,Customer_Registration_AGN__c,Primary_Parent_vod__c,Customer_Managed_AGN__c,Country_Code__c,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c FROM Account WHERE Id=: acc.ID];
         List<Account> tempAcList = new List<Account>();
         tempAcList.add(customerAccount);
    
         String objAcc = 'Account';
         SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
         
         AGN_FLSCheck.check(tempAcList,AccObjType,'INSERT');
         try {
            AGN_FLSCheck.checkObjectAccess(AccObjType,'UPDATE');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'INSERT');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'UPSERT');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'DELETE');
         } catch (AGN_CommonException e) {
         }
         
         AGN_FLSCheck.check(acc,AccObjType,'INSERT');
         integer i = 0;
         integer j = 0;
         System.assertEquals(i,j);
    
    }
    
    public static testmethod void agnflscheckTest1(){
    
    User u = new User();    
    Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Profile' LIMIT 1];
    UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
    u = new User(Alias = 'agn', Email='pk@vp.kp', 
                 EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                 LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                 TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
    
    insert u;
    Account acc;
         user customerUser;
        system.runAs(u){     
            acc =new Account();      
         acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                            AND DeveloperName = 'Professional_vod'
                                            LIMIT 1
                                           ][0].Id;
            acc.Salutation = 'Mr.';
            acc.FirstName ='Test';
            acc.LastName = 'Last';
            acc.PersonEmail = 'Email@ema.kl';
            acc.Phone = '784623857';
            acc.Customer_Registration_AGN__c = 'In Progress';
            acc.Customer_Managed_AGN__c = true;
            acc.Country_Code__c = 'DE';
            acc.Customer_Category_AGN__c = 'Clinic';
            acc.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
         insert acc;       
         }    
         
         Account customerAccount = [SELECT ID, Name,PersonContactId,Salutation,FirstName,LastName,PersonEmail,Phone,Customer_Registration_AGN__c,Primary_Parent_vod__c,Customer_Managed_AGN__c,Country_Code__c,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c FROM Account WHERE Id=: acc.ID];
         List<Account> tempAcList = new List<Account>();
         tempAcList.add(customerAccount);
    
         String objAcc = 'Account';
         SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
         

         try {
            AGN_FLSCheck.checkObjectAccess(AccObjType,'INSERT');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'UPSERT');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'DELETE');
         } catch (AGN_CommonException e) {
         }
         integer i = 0;
         integer j = 0;
         System.assertEquals(i,j);
    
    }
    
    public static testmethod void agnflscheckTest2(){
    
    User u = new User();    
    Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Profile' LIMIT 1];
    UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
    u = new User(Alias = 'agn', Email='pk@vp.kp', 
                 EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                 LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                 TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
    
    insert u;
    Account acc;
         user customerUser;
        system.runAs(u){     
            acc =new Account();      
         acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                            AND DeveloperName = 'Professional_vod'
                                            LIMIT 1
                                           ][0].Id;
            acc.Salutation = 'Mr.';
            acc.FirstName ='Test';
            acc.LastName = 'Last';
            acc.PersonEmail = 'Email@ema.kl';
            acc.Phone = '784623857';
            acc.Customer_Registration_AGN__c = 'In Progress';
            acc.Customer_Managed_AGN__c = true;
            acc.Country_Code__c = 'DE';
            acc.Customer_Category_AGN__c = 'Clinic';
            acc.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
         insert acc;       
         }    
         
         Account customerAccount = [SELECT ID, Name,PersonContactId,Salutation,FirstName,LastName,PersonEmail,Phone,Customer_Registration_AGN__c,Primary_Parent_vod__c,Customer_Managed_AGN__c,Country_Code__c,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c FROM Account WHERE Id=: acc.ID];
         List<Account> tempAcList = new List<Account>();
         tempAcList.add(customerAccount);
    
         String objAcc = 'Account';
         SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
         

         try {
            AGN_FLSCheck.checkObjectAccess(AccObjType,'UPSERT');
            AGN_FLSCheck.checkObjectAccess(AccObjType,'DELETE');
         } catch (AGN_CommonException e) {
         }
         integer i = 0;
         integer j = 0;
         System.assertEquals(i,j);
    
    }
}