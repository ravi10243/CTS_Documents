@isTest
public class AGN_OAMAccountDetailControllerTest {
    public static testmethod void AcoountDetailTest(){ 
        user u = AGN_CustReg_TestUtilityClass.createUser();
        System.runAs(u){  
            
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();    
            
            System.assert(oamUser != Null, 'Create AGN_CustReg_TestUtilityClass.createOAMUser  Fail :  OAM User Setting was not inserted properly');
            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();      
            
            System.assert(gcspSettings != Null, 'Create AGN_CustReg_TestUtilityClass.createGCSPSettings  Fail :  GCSP Settings was not inserted properly');
            
            Specialty_Allergan_AGN__c spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
            
            System.assert(spe != Null, 'Create AGN_CustReg_TestUtilityClass.createSpecialty_Allergan  Fail : Specialty_Allergan was not inserted properly');
            
            Country_vod__c country = AGN_CustReg_TestUtilityClass.createCountry();
            
            System.assert(country != Null, 'Create AGN_CustReg_TestUtilityClass.createCountry  Fail :  Country was not inserted properly');
            
            list<Customer_Type_Configuration_AGN__c> configList = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
            
            Account BussinessAcc =  AGN_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
            
            System.assert(BussinessAcc != Null, 'Create AGN_CustReg_TestUtilityClass.createBussinessAccount  Fail :  Bussiness Account was not inserted properly');
            
            Account bussinessAccount = new Account( RecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Pharmacy_vod' LIMIT 1][0].Id,Country_vod__c  = country.Id, External_ID2_AGN__c = '213145',Customer_Category_AGN__c = 'Clinic', 
                                                   Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Calling_Name_AGN__c = 'call name', Country_Code__c = 'DE',SAP_Customer_Group_AGN__c = 'CL',SAP_Search_Term_1_AGN__c = 'Enrku',SAP_Country_Code_AGN__c = 'DE',SAP_Tax_Classification_AGN__c = '9',
                                                   SAP_Sold_To_AGN__c=true,Phone = '4565576',Specialty_Allergan_1_AGN__c = spe.Id,name='testAcc');
            
            insert bussinessAccount; 
            
            system.assertEquals('testAcc', bussinessAccount.Name);
            
            Account PersonAcc =  AGN_CustReg_TestUtilityClass.createPersonAccount(BussinessAcc);
            
            list<Child_Account_vod__c> childAccList = new list<Child_Account_vod__c>();
            
           
            Child_Account_vod__c child1 = new Child_Account_vod__c(Parent_Account_vod__c = bussinessAccount.Id, Child_Account_vod__c = BussinessAcc.ID, 
                                                                   Sold_To_AGN__c= false, Ship_To_AGN__c=false, 
                                                                   Bill_To_AGN__c=true,Customer_Managed_AGN__c =true);
             Child_Account_vod__c child2 = new Child_Account_vod__c(Parent_Account_vod__c = BussinessAcc.Id, Child_Account_vod__c = PersonAcc.ID, 
                                                                   Sold_To_AGN__c= true, Ship_To_AGN__c=false, 
                                                                   Bill_To_AGN__c=false,Customer_Managed_AGN__c =true);
            
            
             
             childAccList.add(child1);
             childAccList.add(child2); 
            
             Database.upsert(childAccList,false); 
            
            list<Address_vod__c> addList = new list<Address_vod__c>();
            
            Address_vod__c add = AGN_CustReg_TestUtilityClass.createAddress(BussinessAcc);
            
            System.assert(add != Null, 'Create AGN_CustReg_TestUtilityClass.createAddress  Fail :  Address was not inserted properly');
            
            Address_vod__c addNew = new Address_vod__c(Account_vod__c =bussinessAccount.Id, Name = 'Add Name1', Address_line_2_vod__c ='Test Address1',State_vod__c= 'Ontario', City_vod__c= 'cityw', Country_vod__c='Germany', 
                                                       Phone_vod__c= '5456457668', Email_AGN__c = 'crr@email.com', Zip_vod__c = '34975', Customer_Managed_AGN__c =true);
            
            system.assert(addNew.Name == 'Add Name1');
            
            addList.add(add);
            addList.add(addNew);
            
            upsert addList;
            
            test.startTest();
            AGN_OAMAccountDetailController.getGCSPSettingsDetails();
            AGN_OAMAccountDetailController.getUserDetail();
            AGN_OAMAccountDetailController.getCustomertypeConfigDetails();
            AGN_OAMAccountDetailController.getCummunityURL();
            AGN_OAMAccountDetailController.getAccountDetails();      
            system.assert(AGN_OAMAccountDetailController.getAccountDetails() !=PersonAcc );
            AGN_OAMAccountDetailController.AddressWrapper addwrap = new AGN_OAMAccountDetailController.AddressWrapper(PersonAcc.Name, add);
            AGN_OAMAccountDetailController.AddressWrapper addwrap2= new AGN_OAMAccountDetailController.AddressWrapper(PersonAcc.Name, add, PersonAcc.Type_AGN__c);            
            AGN_OAMAccountDetailController.getAddressDetails();
            AGN_OAMAccountDetailController.getAD_OktaSSOUrl();
            
            test.stopTest();
        }            
    }
}