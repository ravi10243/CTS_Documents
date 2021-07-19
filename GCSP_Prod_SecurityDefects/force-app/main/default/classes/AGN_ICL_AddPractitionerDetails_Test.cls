@isTest
 public class AGN_ICL_AddPractitionerDetails_Test{
 
  @isTest static void getBrandPicklistValuesTest() {
      List<String> brandValues = new List<String>();
      brandValues = AGN_ICL_AddPractitionerDetailsController.getBrandPicklistValues();
      System.assertNotEquals(null,brandValues);
      System.assertEquals(2, brandValues.size());
      System.assertEquals('CoolSculpting', brandValues[0]);
      System.assertEquals('Juvederm', brandValues[1]);
  }

  @isTest static void fetchAllPractionersTest() {
 
    // User usr = [Select Id,Name from User WHERE Id = '0055E000004C8NdQAK'];
     User usr = [Select Id,Name,Locator_Listing_Id_AGN__c,FirstName,LastName from User WHERE Id =:Userinfo.getUserId() limit 1];
     String locListId =usr.Locator_Listing_Id_AGN__c;
     System.runAs(usr){
     List<Practitioner_Listing_AGN__c> practitionerList  = new List<Practitioner_Listing_AGN__c>();
     practitionerList = AGN_ICL_AddPractitionerDetailsController.fetchAllPractioners();
     System.assertNotEquals(null,practitionerList );
       for(Practitioner_Listing_AGN__c practitioner:practitionerList){
          System.assertNotEquals(null,practitioner.Locator_Listing_AGN__c);
          System.assertEquals('Active',practitioner.Status_AGN__c);
        }
      }
       
    }
    
    @isTest
    static void addPractitionerRecordTest(){
  
     Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
     User usr = new User(Alias = 'ICLUsr',Email='testuser@allergan.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testICLuser@allergan.com.icl');
       
     System.runAs(usr){
      System.Test.startTest();   
     
      Account hco = new Account();
      hco.Name= 'Allergan Hospital';
      hco.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      hco.Country_Code__c = 'GB';
      hco.Country_vod__c ='a3L5E000000VqGJUA0';
      insert hco;
      
       Account acc = new Account();
       acc.Salutation = 'Mr.';
       acc.FirstName = 'Test';
       acc.Country_Code__c = 'GB';
       acc.LastName = 'User';
       acc.PersonEmail = 'testuser@allergan.com';
       acc.Primary_Parent_vod__c = hco.Id;
       acc.Country_vod__c ='a3L5E000000VqGJUA0';
       acc.Registered_For_Clinic_Locator_AGN__c = True;
       acc.Email_Internal_AGN__c = 'test@gmail.com';
       acc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        insert acc;
     
      AGN_Settings__c settings = new AGN_Settings__c();
      settings.GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=';
      settings.GoogleClientID_AGN__c='gme-allerganinc';   
      insert settings;   
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'hco.Name';
      locList.Account_AGN__c = hco.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=hco.Id;
      locList.Street_AGN__c='Saltlake';
      locList.City_AGN__c = 'Kolkata';
      locList.Country_AGN__c = 'IN';
      locList.Zip_Code_AGN__c = '755023';
      locList.GeoLocation_AGN__Latitude__s =51.5764305;
      locList.GeoLocation_AGN__Longitude__s =88.2704815;
      insert locList;
      
      usr.Locator_Listing_Id_AGN__c =locList.Id;
      update usr;
     
      AGN_ICL_Portal_Settings__c portal_setting = AGN_ICL_Portal_Settings__c.getInstance();
     
      AGN_ICL_Language_Settings__c langSettings_enUS = new AGN_ICL_Language_Settings__c();
      List<AGN_ICL_Language_Settings__c> langSettingsList=new  List<AGN_ICL_Language_Settings__c>();
      langSettings_enUS.Name ='English' ;
      langSettings_enUS.Language_Code_AGN__c ='en_US';
      langSettingsList.add(langSettings_enUS);
      AGN_ICL_Language_Settings__c langSettings_fr = new AGN_ICL_Language_Settings__c(); 
      langSettings_fr.Name ='French' ;
      langSettings_fr.Language_Code_AGN__c ='fr';
      langSettingsList.add(langSettings_fr); 
      AGN_ICL_Language_Settings__c langSettings_IT = new AGN_ICL_Language_Settings__c();  
      langSettings_IT.Name ='Italian' ;
      langSettings_IT.Language_Code_AGN__c ='IT';
      langSettingsList.add(langSettings_IT); 
      insert langSettingsList;
      Practitioner_Listing_AGN__c practitioner = new Practitioner_Listing_AGN__c();
      practitioner.Name= 'Test XYZ';
      practitioner.Salutation_AGN__c='Prof.';
      practitioner.First_Name_AGN__c='Test';
      practitioner.Last_Name_AGN__c='XYZ';
      practitioner.Type_AGN__c='Doctor';                       
      practitioner.Gender_AGN__c= 'Male';
      practitioner.Brand_AGN__c = 'CoolSculpting';
      practitioner.Qualification_AGN__c='MBBS';
      practitioner.Email_AGN__c= 'TestXYZ@gmail.com';                        
      practitioner.Years_of_Experience_AGN__c= 7;                       
      practitioner.Type_Of_Physician_AGN__c= 'Hospital Doctor';
      practitioner.Clinic_AGN__c=hco.Id;
      practitioner.Locator_Listing_AGN__c=locList.Id;
      practitioner.Language_AGN__c = langSettingsList.get(0).Name;
      //practitioner.Status_AGN__c = 'Active';
      //insert practitioner;
      
   
     Practitioner_Listing_AGN__c practitionerRec = AGN_ICL_AddPractitionerDetailsController.addPractitionerRecord(practitioner);
      //System.assertNotEquals(null,practitionerRec); 
      //System.assertEquals('Active',practitionerRec.Status_AGN__c);
     // System.assertNotEquals(null,practitionerRec.Locator_Listing_AGN__c);
      //System.assertNotEquals(null,practitionerRec.Clinic_AGN__c);
      //System.assertEquals('Active',practitionerRec.Status_AGN__c);
     // practitionerRec.Email_AGN__c='TestXYZ@allergan.com';
       Practitioner_Listing_AGN__c practitionerRecUpdated = AGN_ICL_AddPractitionerDetailsController.updatePractitionerRecord(practitioner);
      //System.assertEquals('TestXYZ@allergan.com',practitionerRecUpdated.Email_AGN__c);
      }
    System.Test.stopTest();
   } 
   
    @isTest(SeeAllData=true)
    static void getCountryWiseFieldListTest(){
    System.Test.startTest();
    
        List<AGN_ICL_Layout_Field__mdt> fieldList = new List<AGN_ICL_Layout_Field__mdt>();
        String CountryCode = [Select id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  from User where id =:UserInfo.getUserId()][0].Country_Code__c;
        System.debug('Country code'+CountryCode);
        fieldList = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_Of_HCP_or_HCA_AGN__c = 'Practitioner' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
        AGN_ICL_AddPractitionerDetailsController.getCountryWiseFieldList();
        System.assertNotEquals(null,fieldList );
         
    System.Test.stopTest();
}
 @isTest static void getPractitionerTypeTest(){
  System.Test.startTest();
   String type ='Beautician;Business/Administrative;Consultant;Dentist;Director;Doctor;General Practitioner;Hospital Doctor;Hospital Nurse;Hospital Pharmacist;Midwife;Nurse;Optician;Optometrist;Other;Pharmacist;Physician;Practice Manager;Professor;Retail Pharmacist';
   List<String> typeList = new List<String>(); 
  /** String[] typeArr = type.split(';');
        for(String str : typeArr)
        {
            typeList.add(str);
        }**/
       typeList = AGN_ICL_AddPractitionerDetailsController.getPractitionerType();
        System.assertNotEquals(null,typeList);
  System.Test.stopTest();
 }
 @isTest static void imageTest(){
  System.Test.startTest();
  //public static String image(Id parentId,String fileName1,String contentType,String base64Data)
 Account hco = new Account();
      hco.Name= 'Allergan Hospital';
      hco.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      hco.Country_Code__c = 'GB';
      hco.Country_vod__c ='a3L5E000000VqGJUA0';
      insert hco;
      
      Practitioner_Listing_AGN__c practitioner = new Practitioner_Listing_AGN__c();
      practitioner.Name= 'Test XYZ';
      practitioner.Salutation_AGN__c='Prof.';
      practitioner.First_Name_AGN__c='Test';
      practitioner.Last_Name_AGN__c='XYZ';
      practitioner.Type_AGN__c='Doctor';                       
      practitioner.Gender_AGN__c= 'Male';
      practitioner.Brand_AGN__c = 'CoolSculpting';
      practitioner.Qualification_AGN__c='MBBS';
      practitioner.Email_AGN__c= 'TestXYZ@gmail.com';                        
      practitioner.Years_of_Experience_AGN__c= 7;                       
      practitioner.Type_Of_Physician_AGN__c= 'Hospital Doctor';
      practitioner.Clinic_AGN__c=hco.Id;
      practitioner.Language_AGN__c ='en_US';
      practitioner.Status_AGN__c = 'Active';
      practitioner.Practitioner_Image_AGN__c  = 'Test Image';
      insert practitioner;
  Id parentId = practitioner.Id;
  String fileName = practitioner.Practitioner_Image_AGN__c ;
  String contentType = 'Allergan';
  String base64Data ='base64';
  //String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
   List<AWS_Login_AGN__c> awsList= new List<AWS_Login_AGN__c>();
   AWS_Login_AGN__c aws = new AWS_Login_AGN__c();
   aws.Name = 'AWS';
   aws.key_AGN__c = 'AKIAWKAT5I2UWBVTQ5OM';
   aws.secret_AGN__c='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';
   aws.bucket_AGN__c ='allergan-icl';
   aws.host_AGN__c='s3.eu-west-1.amazonaws.com';
   awsList.add(aws);
   insert awsList;
    String imgName = AGN_ICL_AddPractitionerDetailsController.image(parentId,fileName,contentType,base64Data);
    System.assertNotEquals(null,imgName);
  System.Test.stopTest();
 }
 
 @isTest static void getPicklistValuesTest(){
  System.Test.startTest();
  String SObjectAPIName = 'Practitioner_Listing_AGN__c';
  String FieldAPIName = 'Brand_AGN__c';
  List<String> picklistval = new List<String>();
  
      picklistval = AGN_ICL_AddPractitionerDetailsController.getPicklistValues(SObjectAPIName,FieldAPIName); 
       System.assertNotEquals(null,picklistval);
    }
    
    @isTest
    static void getMetaDataFieldsTest(){
     System.Test.startTest();
      String CountryCode ='GB' ;
        List<AGN_ICL_Layout_Field__mdt> fields = AGN_ICL_AddPractitionerDetailsController.getMetaDataFields(CountryCode);
        System.assertNotEquals(null,fields);
     System.Test.stopTest();
     }
     
     @isTest
    static void fetchPicklistValuesTest(){
     System.Test.startTest();
     String objectName = 'Practitioner_Listing_AGN__c';
     String field_apiName = 'Brand_AGN__c';
     Boolean nullRequired = true;
     //PicklistWrapper wrapper= AGN_ICL_AddPractitionerDetailsController.PicklistWrapper; 
     //List<PicklistWrapper> piclistval = new List<PicklistWrapper>();
     //List<AGN_ICL_AddPractitionerDetailsController.PicklistWrapper> piclistval = new List<AGN_ICL_AddPractitionerDetailsController.PicklistWrapper>();
     //piclistval = AGN_ICL_AddPractitionerDetailsController.fetchPicklistValues(objectName,field_apiName,nullRequired);
     AGN_ICL_AddPractitionerDetailsController.fetchPicklistValues(objectName,field_apiName,nullRequired);
        //System.assertNotEquals(null,piclistval);
     System.Test.stopTest();
     }
      @isTest
    static void deltePractitionerByIdTest(){
     System.Test.startTest();
   Practitioner_Listing_AGN__c Practitioner = New Practitioner_Listing_AGN__c();
    practitioner.Name= 'Test XYZ';
      practitioner.Salutation_AGN__c='Prof.';
      practitioner.First_Name_AGN__c='Test';
      practitioner.Last_Name_AGN__c='XYZ';
      practitioner.Type_AGN__c='Doctor';                       
      practitioner.Gender_AGN__c= 'Male';
      practitioner.Brand_AGN__c = 'CoolSculpting';
      practitioner.Qualification_AGN__c='MBBS';
      practitioner.Email_AGN__c= 'TestXYZ@gmail.com';                        
      practitioner.Years_of_Experience_AGN__c= 7;                       
      practitioner.Type_Of_Physician_AGN__c= 'Hospital Doctor';
      Practitioner.Status_AGN__c = 'Active';
      insert Practitioner;
     AGN_ICL_AddPractitionerDetailsController.deltePractitionerById(Practitioner);
     System.assertEquals('Inactive',Practitioner.Status_AGN__c);
     Practitioner.Status_AGN__c = 'Active';
     practitioner.Email_AGN__c= 'TestXYZ@allergan.com';   
     AGN_ICL_AddPractitionerDetailsController.updatePractitionerRecord(practitioner);
     System.assertEquals('Active',Practitioner.Status_AGN__c);
     System.assertEquals('TestXYZ@allergan.com',Practitioner.Email_AGN__c);
    System.Test.stopTest();
     }
}