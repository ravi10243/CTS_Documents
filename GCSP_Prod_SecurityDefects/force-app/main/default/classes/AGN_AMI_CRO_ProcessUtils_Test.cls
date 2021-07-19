@isTest
public class AGN_AMI_CRO_ProcessUtils_Test {
    
    static Allergan_Customer_Registration_AGN__c aaCRAC;
    static Allergan_Customer_Registration_AGN__c aaCRAC1;
     static Allergan_Customer_Registration_AGN__c aaCRAC2;
    static Allergan_Customer_Address_AGN__c acaac;
    static Allergan_Customer_Address_AGN__c acaac1;
    static Country_vod__c counVod;
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];}} 
    public static final String RECORD_OWNER = (String)AMI_User_Settings_AGN__c.getValues(uInfo.Country_Code__c).get('CR_Record_Owner__c');
    static AGN_CR_CountryRegionMapping__mdt regionValue = [SELECT RegionName__c, Country_Code__c FROM AGN_CR_CountryRegionMapping__mdt LIMIT 1];
    static String OWNER_ID = [SELECT ID FROM User where Username =: RECORD_OWNER LIMIT 1].Id;
    public static void dataCreation()
    {
        
        Country_vod__c counVod = [SELECT Id FROM Country_vod__c Where Name = 'GB'];
       Id caseRecordTypId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_AMI_Customer_Registration_AGN' LIMIT 1][0].Id;
       Id regRecordTypId =[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New_AMI_AGN'][0].Id; 
        Id addRecordTypId =[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New_AMI_AGN'][0].Id;
      	Id specialityId = [SELECT Id from Specialty_AGN__c where Country_code_AGN__c='GB' and name='Aesthetic Medicine'][0].Id;
        
        Case caseObj = new Case(Status = 'New', Origin = 'Web', RecordTypeId =caseRecordTypId,Country_Code_AGN__c='GB');
        insert caseObj;
      
        aaCRAC = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseObj.Id, First_Name_AGN__c = 'Tarasankar', Last_Name_AGN__c = 'Panda',
                                                           Email_AGN__c = 'tarasankar.panda@cognizant.com',
                                                           Phone_AGN__c='9073926242', Country_Code_AGN__c='GB', AMI_Registration_AGN__c = True, OwnerId = OWNER_ID);
        insert aaCRAC;
        
        acaac = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id, Parent_AGN__c = aaCRAC.Id);
        insert acaac;
        
        aaCRAC1 = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseObj.Id, First_Name_AGN__c = 'Tarasankar', Last_Name_AGN__c = 'Panda',
                                                            Email_AGN__c = 'tarasankar.panda@cognizant.com',
                                                            Phone_AGN__c='9073926242', Country_Code_AGN__c='GB', AMI_Registration_AGN__c = True, OwnerId = OWNER_ID);
        
        acaac1 = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id);
              
        aaCRAC2 = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseObj.Id, Online_Registration_AGN__c=true,Country_Code_AGN__c='GB',AMI_Registration_AGN__c=true,Use_Existing_Account_AGN__c= True, Account_AGN__c=null, OwnerId = OWNER_ID, RecordTypeId=regRecordTypId,Specialty_1_AGN__c=specialityId,Last_Name_AGN__c='test');
        insert aaCRAC2;    
         acaac1 = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id ,Sold_To_AGN__c = true, Country_AGN__c=counVod.Id,Company_Name_AGN__c='world',Parent_AGN__c=aaCRAC2.id,RecordTypeId=addRecordTypId);
    	insert acaac1;	
    }
    @isTest(SeeAllData=true)
    public static void testCustomerRegisPageController()
    {
        Test.startTest();
        dataCreation();
        AGN_AMI_CRO_ProcessUtils aacProcessUtils = new AGN_AMI_CRO_ProcessUtils(); 
        AGN_AMI_CRO_ProcessUtils.fetchFieldMappings();
        //AGN_AMI_CRO_ProcessUtils.Process(aaCRAC);          
        //AGN_AMI_CRO_ProcessUtils.Process(aaCRAC1);          
        AGN_AMI_CRO_ProcessUtils.Process(aaCRAC2); 
                 
        Test.stopTest();
    }
}