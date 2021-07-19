/*
Modified by :ICL Project Team
Description: Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
             Added cluster country logic as part of ICL wave 3 development
             Added getCaslConsent method as a part of Casl Consent for Canada
             Added method isTwoLayerLayout as a part of Canada change for Two Column Layout
             Added getMultipicklistBrandCount method  as a part of Duallist Box Logic for Brand 
             Added isCaslConsentEnabled method as a par tof Canada to check if CASL Consent is enabled for the country by ICL Project
			 Added Lines 165-169 and 215 as part of DCR Enablement
			 Updated Line 210 as part of DCR Enablement
			 Commented Lines 200,201,203,204,214 as part of DCR Enablement
Modified Date : 4th March 2021
Release :ICL Wave-3
*/
public without sharing class AGN_ICLRegistrationPageController {
    
    public String SalutaionList { get; set; }
    
    public String name {get;set;}

    public Account Clinic_Admin_details {get;set;}
    public String countrycode { get;set;}
    public Locator_Listing_AGN__c newLocator {get;set;}
    public static final String USERNAME_SUFFIX = 'icl';
    public AGN_ICLRegistrationPageController()
    {
    }
    /*@AuraEnabled
public static List<String> getSalutaionList(){

List<SelectOption> options = new List<SelectOption>();
List<String> salutation = new List<String>();
options.add(new SelectOption( '', '--Select--'));
Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();     
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
for( Schema.PicklistEntry f : ple){
options.add(new SelectOption( f.getValue(), f.getLabel()));
salutation.add(f.getValue());
}   
return salutation;
}*/
    @AuraEnabled
    public static List<String> getCommunityURL()
    {
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        List<String> commURL = new List<String>();
        commURL.add((String)portalSetting.ICL_Community_Portal_Base_URL_AGN__c);
        commURL.add((String)portalSetting.ICL_Community_Portal_Suffix_AGN__c);
        return commURL;
    }
    
    @AuraEnabled
    public static Boolean isGuestUser(){
        Boolean isGuest = False;
        if (UserInfo.getUserType() == 'Guest') {
            isGuest = True;
        } 
        return isGuest;
    }
    
    @AuraEnabled
    public static List<Locator_Listing_AGN__c> getClinicDetails(){   
        User u = [Select id,Name,contactId from User where Id=: UserInfo.getUserId() LIMIT 1];
        
        List<AccountContactRelation > acc_con = [Select id,AccountId,ContactId from AccountContactRelation where ContactId =: u.contactId];
        List<Id> accid = new List<Id>();
        for(AccountContactRelation  ac : acc_con)
        {
            accid.add(ac.AccountId);
        }
        List<Locator_Listing_AGN__c> loclst = [Select id,name,Account_AGN__c,Street_AGN__c,City_AGN__c,State_Providence_Region_AGN__c,Zip_Code_AGN__c,Country_AGN__c,Phone_Number_AGN__c,Email_AGN__c,IsChildClinic_AGN__c from Locator_Listing_AGN__c where Active_AGN__c=true and Account_AGN__c IN: accid]; 
        return loclst;
    }
    
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues()
    {
        // Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        //List<SelectOption> options = new List<SelectOption>();
        List<String> picklistval = new List<String>();
        //options.add(new SelectOption( '', '--Select--'));
        //picklistval.add('');
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            //options.add(new SelectOption( f.getValue(), f.getLabel()));
            picklistval.add(f.getValue());
        }   
        return picklistval;
    }
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues(String countryCode)
    {      
        return AGN_ICL_UtlityClass.getBrandPicklistValues(countryCode);
    }
    
    @AuraEnabled
    public static Boolean getDisclaimerSettings(String countryCode)
    {      
        return AGN_ICL_UtlityClass.getDisclaimerSettings(countryCode);
    } 
    
    @AuraEnabled
    public static Boolean isClinicConsentEnabled(String countryCode)
    {      
        return AGN_ICL_UtlityClass.isClinicConsentEnabled(countryCode);
    } 
    
    //Added CASL Consent Logic for Canada as a part of ICL Project
     @AuraEnabled
    public static Boolean isCaslConsentEnabled(String countryCode)
    {      
        return AGN_ICL_UtlityClass.isCaslConsentEnabled(countryCode);
    } 
    //End
   // Duallist Box Logic added for Brand 
       @AuraEnabled
       public static String getMultipicklistBrandCount(){
       return AGN_ICL_UtlityClass.getMultipicklistBrand();
       }
     // Duallist Box Logic added for Brand  
   
    //Added as a part of Canada change for Two Column Layout
    @AuraEnabled
    public static Boolean isTwoLayerLayout(String countryCode)
    {   
        
        Boolean twolayerlayout = AGN_ICL_UtlityClass.isTwoLayerLayout(countryCode);
        return twolayerlayout;
        
    }
    //END
    
     @AuraEnabled
    public static Boolean isClinicTimingEnabled(String countryCode)
    {      
        return AGN_ICL_UtlityClass.isClinicTimingEnabled(countryCode);
    } 
    
    @AuraEnabled
    public Static Account CreateClinicAccount(Account clinic,Locator_Listing_AGN__c loc)
    {
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:clinic.Country_Code__c limit 1];
        Account acc = AGN_ICL_ClinicRegistrationController.addclinicRecord(clinic,loc,Country_code);
        return acc;
    }
    
    @AuraEnabled
    public static Boolean IsDuplicateEmail(String clinicAdminEmail)
    {
        List<Locator_Listing_AGN__c> loc = [Select id,name,Account_AGN__c,Clinic_Admin_AGN__c,Clinic_Admin_Email_AGN__c from Locator_Listing_AGN__c where Clinic_Admin_Email_AGN__c =:clinicAdminEmail];
        if(loc.size()>0)
        {
            return true;
        }
        return false;
    }
    
    //Create Person Account for clinic admin
    @AuraEnabled
    public Static String createClinicAdminPersonAccount(Account Clinic_Admin_details,Account clinic_detail,Locator_Listing_AGN__c loc,boolean casl_consent)
    {
        //***Line of code has been added as a part of DCR Enablement***
        String FirstName = Clinic_Admin_details.FirstName;
        String LastName = Clinic_Admin_details.LastName;
        String Salutation= Clinic_Admin_details.Salutation;
        //***Line of code has been added as a part of DCR Enablement***
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:Clinic_Admin_details.Country_Code__c limit 1];
        Account clinicAdminAcc = new Account();
        clinicAdminAcc.Salutation = Clinic_Admin_details.Salutation;
        clinicAdminAcc.FirstName = Clinic_Admin_details.FirstName;
        clinicAdminAcc.LastName = Clinic_Admin_details.LastName;
        clinicAdminAcc.PersonEmail = Clinic_Admin_details.PersonEmail;
        clinicAdminAcc.Customer_Managed_AGN__c = True;
        clinicAdminAcc.Registered_For_Clinic_Locator_AGN__c = True;
        // clinicAdminAcc.Primary_Parent_vod__c = clinic_detail.id;
        clinicAdminAcc.Status_AGN__c = 'Pending Validation';
        clinicAdminAcc.Country_vod__c = Country_code.id;//clinic_detail.Country_vod__c;
        
       // Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
        if(Country_code.Cluster_Country_AGN__c==null)
        {
           clinicAdminAcc.Country_Code__c = Country_code.Alpha_2_Code_vod__c; 
        }
        else
        {
          clinicAdminAcc.Country_Code__c = Country_code.Cluster_Country_AGN__c;   
        }
        //End
        
        //clinicAdminAcc.Country_Code__c = Clinic_Admin_details.Country_Code__c;//'GB'; //Country Code to be given dynamically
        clinicAdminAcc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        //------CheckMarx Phase2--Added on 24/09/2020----------
        list<Account> lstacc=new list <Account>();
        lstacc.add(clinicAdminAcc);
        // ***Lines of code have been commented as a part of DCR Enablement*** 
        String objAcc = 'Account';
        //  SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
        //  AGN_FLSCheck.check(lstacc,accObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        //  insert clinicAdminAcc;
        //  String DcrIdAdmin = AGN_ICL_ClinicRegistrationController.createDCR(clinicAdminAcc.id,'Approve');
        //Added below lines to create multichannel consent for CASL Consent(Canada) as apart of ICL Project
        //if(Country_code.Alpha_2_Code_vod__c==Label.AGN_ICL_Country_Code && clinicAdminAcc.id != null){
            //AGN_ICL_UtlityClass.CaslConsent(casl_consent,clinicAdminAcc.id,loc.User_Language_AGN__c,Country_code.Alpha_2_Code_vod__c);
        //}
        //End
        AGN_ICL_ClinicRegistrationController.createLocatorListingData(clinic_detail,clinicAdminAcc,loc,Country_code,FirstName,LastName,Salutation,casl_consent);
        //clinicAdminAcc = [select Id, Name, PersonContactId, FirstName,Country_Code__c, LastName, PersonEmail, Phone,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c from Account where Id =: clinicAdminAcc.Id limit 1];
        //createClinicAdminUser(Json.serialize(clinicAdminAcc));
        
        //  return clinicAdminAcc.id;
        return objAcc;
    }
      // ***Lines of code have been commented as a part of DCR Enablement***
    
    
    
    @AuraEnabled
    public static Map<String,List<AGN_ICL_Layout_Field__mdt>> getCountryWiseFields(String CountryCode)
    {
    //Added below line as part of ICL wave 3 development for cluster country logic
        CountryCode = AGN_ICL_UtlityClass.isCluster(CountryCode); 
        //end
        Map<String,List<AGN_ICL_Layout_Field__mdt>> section_field_map = new Map<String,List<AGN_ICL_Layout_Field__mdt>>();
        List<AGN_ICL_Layout_Field__mdt> fields = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_Of_HCP_or_HCA_AGN__c = 'SignUp' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
        for(AGN_ICL_Layout_Field__mdt iclmdt : fields)
        {
            if(section_field_map.containsKey(iclmdt.Section_Header__c))
            {
                List<AGN_ICL_Layout_Field__mdt> temp = section_field_map.get(iclmdt.Section_Header__c);
                temp.add(iclmdt);
                section_field_map.put(iclmdt.Section_Header__c,temp);
            }
            else
            {
                List<AGN_ICL_Layout_Field__mdt> temp = new List<AGN_ICL_Layout_Field__mdt>();
                temp.add(iclmdt);
                section_field_map.put(iclmdt.Section_Header__c,temp);
            }
        }
        //return fields;
        return section_field_map;
    }
    
    //Added as a part of new terms and condition
    @AuraEnabled
    public static list<Allergan_Consent_Footer_Info__c> gettermsandcondition(String country,String language)
    {
        //Added below line as part of ICL wave 3 development for cluster country logic
        String CountryCode = String.escapeSingleQuotes(AGN_ICL_UtlityClass.isCluster(country));
        
        Country_vod__c cv=[select Id from Country_vod__c where Name=:CountryCode];
        //end
        List<Allergan_Consent_Footer_Info__c> acf=[select Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where country_code_AGN__c=:cv.Id and Language__c=: language and Application_Flag_AGN__c='ICL' and name='ICL Terms & Condition'];
        return acf;
    }
    
    //Added as a part of Casl Consent for Canada
        @AuraEnabled
    
    public static list<Consent_Type_vod__c> getCaslConsent(String country,String language)
    {
        
        Country_vod__c cv=[select Id from Country_vod__c where Name=:country];
        List<Consent_Type_vod__c> acf=[SELECT Id,zvod_Consent_Default_Consent_Text_vod__c,Disclaimer_Text_vod__c from Consent_Type_vod__c where Consent_Header_vod__r.Country_vod__r.Alpha_2_Code_vod__c=:country and Consent_Header_vod__r.Language_vod__c =:language and RecordType.name='CASL Consent'];
        return acf;
    }
    //End
    @InvocableMethod(label='SendWelcomeMailToClinicAdmin')
    public static void sendWelcomeMail(List<Locator_Listing_AGN__c>  locList){        
        AGN_ICL_SendEmailNotification.sendMailLocatorListing(locList,'ICL_Admin_Welcome_Mail_Template__c');       
    }
    @AuraEnabled
    public static String getcountry(String country)
    {               
        return AGN_ICL_UtlityClass.getCountry(country);
        
    }
}