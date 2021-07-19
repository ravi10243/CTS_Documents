public without sharing class AGN_ICL_ClinicRegistrationForOAM {
    public Account Clinic_details {get;set;}
    public Account Clinic_Admin_details {get;set;}
    public Locator_Listing_AGN__c Locator_Listing {get;set;}
    public Address_vod__c Address_details {get;set;}
    //    Public Country_vod__c Country_code = [select id,name,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c ='GB' limit 1];
    public AGN_ICL_ClinicRegistrationForOAM()
    {
    }
    @AuraEnabled
    public static List<String> getBrandPicklistValues()
    {
        
        List<String> picklistval = new List<String>();
        //picklistval.add('');
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            picklistval.add(f.getValue());
        }   
        return picklistval;
    }
    @AuraEnabled
    public static Account getClinicAdminDetails() {
        User uInfo = [SELECT Id,FirstName,LastName,Email,Country_Code__c,ContactId from User where Id =: UserInfo.getUserId() limit 1];
       
        Account acc = [SELECT Id,                       
                       Salutation,
                       FirstName,
                       LastName,Primary_Parent_vod__c,
                       PersonEmail,Phone
                       FROM Account WHERE PersonContactId  =: uInfo.ContactId limit 1];
        return acc;
    } 
    
    
    @AuraEnabled
    public static Account fetchClinicDetails(Id clinicID)
    {
        Account clinicAcc = [Select Id,Name from Account where Id=:clinicID]; 
        return clinicAcc;  
    }  
     @AuraEnabled
    public static Boolean IsLocatorListingCreated(Id clinicID)
    {
        Boolean present = false;
        List<Locator_Listing_AGN__c> loclst = [Select id,name,Account_AGN__c from Locator_Listing_AGN__c where Account_AGN__c =:clinicID];
        if(loclst.size()>0)
        {
            present = true;
        }
        return present;
    }
    
    @AuraEnabled
    public static list<Allergan_Consent_Footer_Info__c> gettermsandcondition()
    {
        User u = [Select id,name,Country_code__c,LanguageLocaleKey from User where Id=:UserInfo.getUserId() limit 1];
        String countrycode = u.Country_Code__c;
        if(countrycode == 'AU')
        {
            countrycode = 'AN';
        }
        Country_vod__c cv=[select Id from Country_vod__c where Name=:countrycode];
        List<Allergan_Consent_Footer_Info__c> acf=[select Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where country_code_AGN__c=:cv.Id and Language__c=:u.LanguageLocaleKey and Application_Flag_AGN__c='ICL' and name='ICL Terms & Condition'];
        return acf;
    }
    
    @AuraEnabled
    public static Address_vod__c getAddressDetails(String clinicID){
       
        Address_vod__c clinicAdd = [SELECT Id, Account_vod__c, Account_vod__r.External_ID2_AGN__c,Account_vod__r.Name,Account_vod__r.Calling_Name_AGN__c,Name,Address_line_2_vod__c,State_vod__c,City_vod__c,Country_vod__c,Province_AGN__c,Phone_vod__c,Email_AGN__c,Zip_vod__c FROM Address_vod__c WHERE 
                                    Account_vod__c =:clinicID  AND Inactive_vod__c= False ];           
        
        return clinicAdd;
        
    }
    @AuraEnabled
    public static Locator_Listing_AGN__c createLocatorListingData(Account clinicAcc,Account acc,Locator_Listing_AGN__c loc)
    {
        //Account acc = getClinicAdminDetails();
         AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String countrylst = portalSetting.OAM_Country_Code_using_contact_AGN__c;
        List<String> countrycodelst = countrylst.split(';');
        User uInfo = [SELECT Id,Country_Code__c,ContactId,LanguageLocaleKey,Email from User where Id =: UserInfo.getUserId() limit 1];
        String countrycode = uInfo.Country_Code__c;
        if(countrycode == 'AU')
        {
            countrycode = 'AN';
        }
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:countrycode limit 1];
        Locator_Listing_AGN__c newLOC = new Locator_Listing_AGN__c();
        newLOC.Name = clinicAcc.Name;
        newLOC.Email_AGN__c = loc.Email_AGN__c;
        newLOC.Monday_Open_Hours_AGN__c = loc.Monday_Open_Hours_AGN__c;
        newLOC.Monday_Close_Hours_AGN__c = loc.Monday_Close_Hours_AGN__c;
        newLOC.Tuesday_Open_Hours_AGN__c = loc.Tuesday_Open_Hours_AGN__c;
        newLOC.Tuesday_Close_Hours_AGN__c = loc.Tuesday_Close_Hours_AGN__c;
        newLOC.Wednesday_Open_Hours_AGN__c = loc.Wednesday_Open_Hours_AGN__c;
        newLOC.Wednesday_Close_Hours_AGN__c = loc.Wednesday_Close_Hours_AGN__c;
        newLOC.Thursday_Open_Hours_AGN__c = loc.Thursday_Open_Hours_AGN__c;
        newLOC.Thursday_Close_Hours_AGN__c = loc.Thursday_Close_Hours_AGN__c;
        newLOC.Friday_Open_Hours_AGN__c = loc.Friday_Open_Hours_AGN__c;
        newLOC.Friday_Close_Hours_AGN__c = loc.Friday_Close_Hours_AGN__c;
        newLOC.Saturday_Open_Hours_AGN__c = loc.Saturday_Open_Hours_AGN__c;
        newLOC.Saturday_Close_Hours_AGN__c = loc.Saturday_Close_Hours_AGN__c;
        newLOC.Sunday_Open_Hours_AGN__c = loc.Sunday_Open_Hours_AGN__c;
        newLOC.Sunday_Close_Hours_AGN__c = loc.Sunday_Close_Hours_AGN__c;
        //newLOC.First_Level_Clinic_Approver_AGN__c = Country_code.First_Level_Clinic_Approver_AGN__c;
        //newLOC.Second_Level_Clinic_Approver_AGN__c = Country_code.Second_Level_Clinic_Approver_AGN__c;
        newLOC.Account_AGN__c = clinicAcc.Id;
        if(!countrycodelst.contains(countrycode))
        {
            Contact con = [Select id,name,AccountId from Contact where id =:uInfo.ContactId limit 1];
            newLOC.Clinic_Admin_AGN__c = con.AccountId;
        }
        newLOC.Clinic_Admin_Email_AGN__c = uInfo.Email;
        newLOC.Street_AGN__c = loc.Street_AGN__c;
        newLOC.Phone_Number_AGN__c = loc.Phone_Number_AGN__c;
        newLOC.City_AGN__c = loc.City_AGN__c;
        newLOC.Country_AGN__c = loc.Country_AGN__c;
        newLOC.Country_Code_AGN__c = Country_code.Id;
        newLOC.Zip_Code_AGN__c = loc.Zip_Code_AGN__c;
        newLOC.Website_AGN__c = loc.Website_AGN__c;
        newLOC.State_Providence_Region_AGN__c = loc.State_Providence_Region_AGN__c;   
        newLOC.Active_AGN__c = False;
        newLOC.Clinic_Experience_AGN__c = loc.Clinic_Experience_AGN__c;
        newLOC.Clinic_Experience_Site_AGN__c = loc.Clinic_Experience_Site_AGN__c;
        newLOC.Enquiriy_Email_AGN__c = loc.Enquiriy_Email_AGN__c;
        newLOC.Ask_Question_Email_AGN__c = loc.Ask_Question_Email_AGN__c;
        newLOC.Request_Call_Email_AGN__c = loc.Request_Call_Email_AGN__c;
        newLOC.Open_Evenings_Email_AGN__c = loc.Open_Evenings_Email_AGN__c;
        newLOC.Brand_AGN__c = loc.Brand_AGN__c;
        newLOC.Consent_AGN__c = loc.Consent_AGN__c;
        newLOC.Google_Url_AGN__c = loc.Google_Url_AGN__c;
        newLOC.Testimonial_Available_AGN__c = loc.Testimonial_Available_AGN__c;
        newLOC.Offer_Evenings_AGN__c = loc.Offer_Evenings_AGN__c;
        newLOC.Registered_For_Clinic_Locator_AGN__c = TRUE;
        newLOC.Registered_from_OAM_AGN__c = TRUE;
        newLOC.User_Language_AGN__c = uInfo.LanguageLocaleKey;
        // newLOC.Account_AGN__c = '0015E00000jh2ql';
        //  newLOC.Email_AGN__c = clinic.Email_AGN__c;
        insert newLOC;
        //uInfo.Locator_Listing_Id_AGN__c = newLOC.Id;
        //update uInfo;
        return null;
    }
    
    
    @AuraEnabled
    public Static boolean updateClinic(Account clinicAcc , Id clinicId)
    {
        Account clAcc = new Account();
        clAcc.Id = clinicId;
        clAcc.Registered_For_Clinic_Locator_AGN__c = True;
        update clAcc;
        return true;
    }
    
    @AuraEnabled
    public Static Boolean IscheckLocatorListing()
    {
        User u = [Select id,name,Locator_Listing_Id_AGN__c from User where id =: UserInfo.getUserId()];
        if(u.Locator_Listing_Id_AGN__c !=null)
        {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static Map<String,List<AGN_ICL_Layout_Field__mdt>> getCountryWiseFields()
    {
        User uInfo = [SELECT Id,Country_Code__c,ContactId from User where Id =: UserInfo.getUserId() limit 1];
        String countrycode = uInfo.Country_Code__c;
        if(countrycode == 'AU')
        {
            countrycode = 'AN';
        }
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:countrycode limit 1];
        Map<String,List<AGN_ICL_Layout_Field__mdt>> section_field_map = new Map<String,List<AGN_ICL_Layout_Field__mdt>>();
        List<AGN_ICL_Layout_Field__mdt> fields = [Select id,Section_Header__c,Field_for_AGN__c,Field_Regex_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_for_AGN__c != 'Clinic Admin' and Field_Of_HCP_or_HCA_AGN__c = 'SignUp' and Country_Code_AGN__c =:Country_code.Alpha_2_Code_vod__c order by Field_Sort_Order_AGN__c];
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
}