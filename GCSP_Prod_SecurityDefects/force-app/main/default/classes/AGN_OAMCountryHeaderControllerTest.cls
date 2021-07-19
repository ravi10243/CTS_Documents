@isTest
public class AGN_OAMCountryHeaderControllerTest {
    
    public static testmethod void headerMethodTest(){ 
        
        User u = new User();		
        Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Profile' LIMIT 1];
        UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
        u = new User(Alias = 'agn', Email='pk@vp.kp', 
                     EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                     LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                     TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
        
        insert u; 
        
        system.runAs(u){
            
            
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser(); 
            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
            list<Object> obj = new list<Object>();          
            
            Customer_Type_Configuration_AGN__c cTypeConfig  = new Customer_Type_Configuration_AGN__c(Category_AGN__c = 'Clinic', 
                                                                                                     Category_Label_AGN__c ='Klinik' , 
                                                                                                     Country_Code_AGN__c = 'DE', 
                                                                                                     Customer_Group_AGN__c ='Cl' ,
                                                                                                     Sub_Category__c = 'Public or Private Clinic',                                                                                                
                                                                                                     Customer_Group_Display_Text_AGN__c='display text',
                                                                                                     Documents_Required_AGN__c='AAF Form (Required);',
                                                                                                     Official_website_AGN__c='http://www.tierarzt-onlinesuche.de;',
                                                                                                     Sub_Category_Label_AGN__c='Klinik ohne eigene Apotheke',
                                                                                                     Applicable_For_Online_Registration_AGN__c= true);
            
            insert cTypeConfig;
              list<Customer_Type_Configuration_AGN__c> configList = [SELECT ID,Country_Code_AGN__c FROM Customer_Type_Configuration_AGN__c];
            //configList.add(cTypeConfig);            
            Country_vod__c con = new Country_vod__c(Alpha_2_Code_vod__c='DE',AGN_Country_Name__c='Germany');            
            insert con;
            list<Country_vod__c> cList = [SELECT Id,
                                                       Alpha_2_Code_vod__c,
                                                       AGN_Country_Name__c
                                                       FROM Country_vod__c
                                                       WHERE Alpha_2_Code_vod__c =: cTypeConfig.Country_Code_AGN__c];
                                           
            obj.add(cList);
            obj.add(configList);
            
            //AGN_OAMCountryHeaderController.customerTypeConfig();
            system.assertNotEquals(obj, AGN_OAMCountryHeaderController.fetchCountryList());
            
            
        }
        
        
        
    } 
    
}