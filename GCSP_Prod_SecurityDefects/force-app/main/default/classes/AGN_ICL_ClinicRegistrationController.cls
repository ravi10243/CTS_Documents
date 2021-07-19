//public  class  AGN_ICL_ClinicRegistrationController { 
//public Locator_Listing_AGN__c clinic{get;set;}

/*
Modified by :ICL Project Team
Description: Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
             Added CASL Consent Logic for Canada 
Release :ICL Wave-3
*/
/*
Modified by :ICL Project Team
Description: Line 22 to 75, 141, 174 to 175, 201 to 202 has been commented as a part of DCR Enablement 
             Line 81 is Updated and Line 84 to 113 ,167 to 170 has been added as a part of DCR Enablement 
Modified Date :4 mar 2021
*/
//public class AGN_ICL_ClinicRegistrationController {
public without sharing class AGN_ICL_ClinicRegistrationController {  /* added without sharing for Spring'21 Release Updates */ 
    
    public static Account addclinicRecord (Account acc,Locator_Listing_AGN__c loc,Country_vod__c Country_code) {
    // Line of code has been commented as a part of DCR Enablement    
     /*   
        Account a = new Account();
        a.Name = loc.Name;
        a.Status_AGN__c = 'Pending Validation';
        a.Customer_Managed_AGN__c = True;
        a.Country_vod__c = Country_code.id;
        a.Registered_For_Clinic_Locator_AGN__c = True;
        a.Email_Internal_AGN__c = loc.Email_AGN__c;
       // Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
        if(Country_code.Cluster_Country_AGN__c==null)
        {
           a.Country_Code__c = Country_code.Alpha_2_Code_vod__c; 
        }
        else
        {
         a.Country_Code__c = Country_code.Cluster_Country_AGN__c;   
        }
        //End
        
        //a.Sub_Type_AGN__c = 'Dayclinic';
        a.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
        system.debug('Account>>>'+a);
        //------CheckMarx Phase2--Added on 25/09/2020----------
        list<Account> lstacc=new list <Account>();
        lstacc.add(a);
        String objAcc = 'Account';
        SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
        AGN_FLSCheck.check(lstacc,accObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        insert a;
        String accId = a.Id;
        System.debug('Clinic Id'+accId);
        String DCR_note = 'Approve';
        String DcrId = createDCR(accId,DCR_note);
        System.debug('DCR Id'+DcrId);
        
        Address_vod__c ad = new Address_vod__c();
        ad.Account_vod__c = a.Id;
        ad.Name = loc.Street_AGN__c;
        ad.City_vod__c = loc.City_AGN__c;
        ad.Country_vod__c = loc.Country_AGN__c;
        ad.Country_Code__c = Country_code.Alpha_2_Code_vod__c;
        ad.Zip_vod__c = loc.Zip_Code_AGN__c;
        ad.Primary_vod__c = True;
        //------CheckMarx Phase2--Added on 25/09/2020----------
        list<Address_vod__c> lstadd=new list <Address_vod__c>();
        lstadd.add(ad);
        String objAdd = 'Address_vod__c';
        SObjectType addObjType = ((SObject)(Type.forName('Schema.'+objAdd).newInstance())).getSObjectType();
        AGN_FLSCheck.check(lstadd,addObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        insert ad;
        
        
        return a;
       */ 
    //Line of code has been commented as a part of DCR Enablement 
    return acc;
    }
    // FirstName ,LastName has been added as a part of DCR Enablement
    public static Locator_Listing_AGN__c createLocatorListingData(Account clinic_details,Account clinic_Admin,Locator_Listing_AGN__c loc,Country_vod__c Country_code,String FirstName, String LastName, String Salutation,Boolean casl_consent)
    {
        //Line of code has been added as a part of DCR Enablement
        AssignmentRule AR = new AssignmentRule(); 
        AR = [select id,Name from AssignmentRule where SobjectType = 'Case' and Active = true and Name =: System.label.AGN_ICL_Case_Assignment_Rule limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        
        Case cs = new Case();
        cs.Service_AGN__c = 'ICL Clinic Registration';
        cs.Type = 'New';
        cs.Priority = 'Medium';
        cs.Origin = 'Web';
        cs.Status = 'New';
       // cs.Country_AGN_GDPR__c = loc.Country_AGN__c;
        cs.Country_Code_AGN__c = Country_code.Name;
        cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_ICL_Clinic_Registration_AGN' LIMIT 1][0].Id;
        cs.setOptions(dmlOpts);
         //Adding checkmarx comment
        try{
        	List<Case> Casecreation = new List<Case>();
           			Casecreation.add(cs); 
                    String objCase = 'Case';
                    SObjectType caseObjType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Casecreation,caseObjType,'INSERT');
            		System.debug('dmlOpts '+dmlOpts);
                    insert Casecreation; 
                 }
        catch(Exception ex)
            {
                System.debug('There is an exception for the Case Creation:'+ex);
			}
        //Checkmarx End
        //insert cs;
        //System.debug('cs::'+cs.id); 
        //End
        
        Locator_Listing_AGN__c newLOC = new Locator_Listing_AGN__c();
        newLOC.Name = loc.Name;
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
        newLOC.Country_Code_AGN__c = Country_code.Id;
        //newLOC.Country_Code_AGN__c = AGN_ICL_UtlityClass.getsitecorecountry(Country_code.Alpha_2_Code_vod__c);
        newLOC.First_Level_Clinic_Approver_AGN__c = Country_code.First_Level_Clinic_Approver_AGN__c;
        //newLOC.Second_Level_Clinic_Approver_AGN__c =Country_code.Second_Level_Clinic_Approver_AGN__c; Line of code has been commented as a part of DCR Enablement
        newLOC.Account_AGN__c = clinic_details.Id;
        //newLOC.Clinic_Admin_AGN__c = clinic_Admin.Id; //Line of code has been commented as a part of DCR Enablement  
        newLOC.Clinic_Experience_Site_AGN__c = loc.Clinic_Experience_Site_AGN__c;
        newLOC.Clinic_Admin_Email_AGN__c = clinic_Admin.PersonEmail;
        newLOC.User_Language_AGN__c = loc.User_Language_AGN__c;
        newLOC.Phone_Number_AGN__c = loc.Phone_Number_AGN__c;
        newLOC.Street_AGN__c = loc.Street_AGN__c;
        newLOC.City_AGN__c = loc.City_AGN__c;
        newLOC.Country_AGN__c = loc.Country_AGN__c;
        newLOC.Zip_Code_AGN__c = loc.Zip_Code_AGN__c;
        newLOC.Website_AGN__c = loc.Website_AGN__c;
        newLOC.State_Providence_Region_AGN__c = loc.State_Providence_Region_AGN__c;
        newLOC.Active_AGN__c = False;
        newLOC.Book_Consultation_AGN__c = loc.Book_Consultation_AGN__c;
        newLOC.Consent_AGN__c = loc.Consent_AGN__c;
        newLOC.Clinic_Consent_AGN__c = loc.Clinic_Consent_AGN__c;
        newLOC.Clinic_Experience_AGN__c = loc.Clinic_Experience_AGN__c;
        newLOC.Enquiriy_Email_AGN__c = loc.Enquiriy_Email_AGN__c;
        newLOC.Ask_Question_Email_AGN__c = loc.Ask_Question_Email_AGN__c;
        newLOC.Request_Call_Email_AGN__c = loc.Request_Call_Email_AGN__c;
        newLOC.Open_Evenings_Email_AGN__c = loc.Open_Evenings_Email_AGN__c;
        newLOC.Brand_AGN__c = loc.Brand_AGN__c;
        newLOC.Google_Url_AGN__c = loc.Google_Url_AGN__c;
        newLOC.Testimonial_Available_AGN__c = loc.Testimonial_Available_AGN__c;
        newLOC.Offer_Evenings_AGN__c = loc.Offer_Evenings_AGN__c;
        newLOC.Registered_For_Clinic_Locator_AGN__c = TRUE;
       //Line of code has been added as a part of DCR Enablement
        newLOC.AGN_First_Name__c = FirstName;
        newLOC.AGN_Last_Name__c = LastName;
        newLOC.Clinic_Admin_Salutation_AGN__c=Salutation;
        newLOC.ICL_Registration_Case__c = cs.Id;
        if(Country_code.Name != Label.AGN_ICL_Casl_Country){
            newLOC.CASL_Consent_AGN__c= FALSE;
        }
        else{
        newLOC.CASL_Consent_AGN__c = casl_consent;
        }
        system.debug('casl_consent value' +casl_consent);
        //END
     
      //Line of code has been commented as a part of DCR Enablement
       // string DCR = [SELECT name FROM Data_Change_Request_vod__c WHERE Account_vod__c=: clinic_details.Id LIMIT 1].name;
       // newLOC.DCR_Reference_Number_AGN__c=DCR;
      //END
      //Updated code as part of Cluster country go live as a part of ICL-Wave3
         
        List<AGN_ICL_Country_Settings__c> cus = AGN_ICL_Country_Settings__c.getall().values();
                  for(AGN_ICL_Country_Settings__c aic:cus)
                    {
                         if(Country_code.Alpha_2_Code_vod__c==aic.Country_AGN__c)
                             {
                                newLOC.Cluster_Country_AGN__c=aic.Site_core_country_AGN__c;
                             }
                        
                    }
        //End
        
        // newLOC.Account_AGN__c = '0015E00000jh2ql';
        //  newLOC.Email_AGN__c = clinic.Email_AGN__c;
        //  //------CheckMarx Phase2--Added on 25/09/2020----------
        list<Locator_Listing_AGN__c> lstloc=new list <Locator_Listing_AGN__c>();
        lstloc.add(newLOC);
        String objloc = 'Locator_Listing_AGN__c';
        SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
        AGN_FLSCheck.check(lstloc,locObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        insert newLOC;
       //Line of code has been commented as a part of DCR Enablement 
       // AGN_ICL_ClinicRegistrationController.CreateChildAccount(clinic_Admin,clinic_details);
       // AGN_ICL_ClinicRegistrationController.OwnerUpdateofRecords(newLOC,clinic_Admin,clinic_details);
       // End
        System.debug('Locator Listing Id'+newLOC.Id);
       
        return null;
    }
    
    public static void CreateChildAccount(Account clinicAdminAcc,Account clinic_detail){
        Child_Account_vod__c ChAcc = new Child_Account_vod__c();
        ChAcc.Child_Account_vod__c = clinicAdminAcc.Id;
        ChAcc.Parent_Account_vod__c = clinic_detail.Id;
        ChAcc.Copy_Address_vod__c = True;
        ChAcc.External_ID_vod__c = clinic_detail.Id+'__'+clinicAdminAcc.Id;
        //------CheckMarx Phase2--Added on 25/09/2020----------
        list<Child_Account_vod__c> lstchildacc=new list <Child_Account_vod__c>();
        lstchildacc.add(ChAcc);
        String objchildacc = 'Child_Account_vod__c';
        SObjectType childaccObjType = ((SObject)(Type.forName('Schema.'+objchildacc).newInstance())).getSObjectType();
        AGN_FLSCheck.check(lstchildacc,childaccObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        insert ChAcc;
    }
    public static void OwnerUpdateofRecords(Locator_Listing_AGN__c loc,Account Clinic_admin,Account Clinic){
        try{
            AGN_ICL_Portal_Settings__c portal_setting = AGN_ICL_Portal_Settings__c.getInstance();
            //loc.Registered_For_Clinic_Locator_AGN__c = TRUE;
            //loc.OwnerId = (String)portal_setting.ICL_Record_Owner_Id_AGN__c;//'0055E000004KAUm';
            //update loc;
            Clinic.OwnerId = (String)portal_setting.ICL_Record_Owner_Id_AGN__c;//'0055E000004KAUm';
            //------CheckMarx Phase2--Added on 25/09/2020----------
            list<Account> lstacc=new list <Account>();
            lstacc.add(Clinic);
            String objAcc = 'Account';
            SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
            AGN_FLSCheck.check(lstacc,accObjType,'UPDATE');
            //------CheckMarx Phase2--Ends here----------
            update Clinic;
            Clinic_admin.OwnerId = (String)portal_setting.ICL_Record_Owner_Id_AGN__c;//'0055E000004KAUm';
            //------CheckMarx Phase2--Added on 25/09/2020----------
            list<Account> lstaccadm=new list <Account>();
            lstaccadm.add(Clinic_admin);
            String objAccadm = 'Account';
            SObjectType accadmObjType = ((SObject)(Type.forName('Schema.'+objAccadm).newInstance())).getSObjectType();
            AGN_FLSCheck.check(lstaccadm,accadmObjType,'UPDATE');
            //------CheckMarx Phase2--Ends here----------
            update Clinic_admin;
        }catch(Exception e)
        {
            System.debug('Update exception');
        }
    }
    public static void SendWelcomeEmailtoClinicAdmin(Account clinicAdmin){
        try{
            
        }catch(Exception e){
            
        }
    }
    // AGN_Account_SendToDP_DCR.createDCR(accId, DCR_note)  
    public static String createDCR(String accId, String DCR_note){
        try{
            return AGN_Account_SendToDP_DCR.createDCR(accId, DCR_note);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static List<String> fetchPicklistValues(String objectName, String field_apiName,Boolean nullRequired){
        List<String> optionlist = new List<String>();        
        Map<String,Schema.SObjectType> t = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = t.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            optionlist.add('--Select Option--');
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }     
}