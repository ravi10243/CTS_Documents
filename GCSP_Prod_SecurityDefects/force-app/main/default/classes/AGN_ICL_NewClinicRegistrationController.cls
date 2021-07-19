/*
Modified by :ICL Project Team
Description: Added new method getclinicadminname to show the Clinic admin details in detail page and clinic page same in ICL portal.
             Added line 82 as a  part of ICL wave 3 development for cluster country logic.
             Added line 153 to 161 for cluster country logic as a part of ICL-Wave 3 for locator listing object
             Added isTwoLayerLayout method as a part of Canada change for Two Column Layout
             Added getMultipicklistBrandCount method for Brand Duallist Box Logic  
             Added Lines 142-176,188-191 and 211-217 as part of DCR Enablement
Modified Date - 3rd March 2021
Release :ICL Wave-3
*/
public without sharing class AGN_ICL_NewClinicRegistrationController {
    
    
    public AGN_ICL_NewClinicRegistrationController(){
        
    }
    
    @AuraEnabled
    public static String fetchUserDetails()
    {
        User u = [Select id,Name,contactId,FirstName from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.FirstName;
    } 
    
    @AuraEnabled
    public static String fetchfullName()
    {
        User u = [Select id,Name,contactId,FirstName,LastName from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.FirstName+' '+u.LastName;
    }  
    
    @AuraEnabled
    public static List<String> getBrandPicklistValues1()
    {
        
        List<String> picklistval = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Locator_Listing_AGN__c').getDescribe().fields.getMap().get('Brand_AGN__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            picklistval.add(f.getValue());
        }   
        return picklistval;
    }
    @AuraEnabled
    public static List<String> getBrandPicklistValues(){
        User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
        return AGN_ICL_UtlityClass.getBrandPicklistValues(u.Country_Code__c);
    }
    
    @AuraEnabled    
    public static Boolean getDisclaimerSettings(String countryCode)         
    {  User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c     
                 FROM User  
                 WHERE id =:UserInfo.getUserId()    
                 LIMIT 1];      
     return AGN_ICL_UtlityClass.getDisclaimerSettings(u.Country_Code__c);   
    } 
    
    @AuraEnabled    
    public static Boolean isClinicConsentEnabled()          
    {  User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c     
                 FROM User  
                 WHERE id =:UserInfo.getUserId()    
                 LIMIT 1]; 
      return AGN_ICL_UtlityClass.isClinicConsentEnabled(u.Country_Code__c);
    } 
    
    @AuraEnabled    
    public static String getUserCountryCode()           
    {  User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c     
                 FROM User  
                 WHERE id =:UserInfo.getUserId()    
                 LIMIT 1]; 
      return u.Country_Code__c;
    }
    
    @AuraEnabled
    public static Map<String,List<AGN_ICL_Layout_Field__mdt>> getCountryWiseFields()
    {
        User u = [Select id,name,Country_Code__c from User where Id=:UserInfo.getUserId() limit 1];
         // Added as part of ICL wave 3 development for cluster country logic.
        String CountryCode = AGN_ICL_UtlityClass.isCluster(u.Country_Code__c);
        Map<String,List<AGN_ICL_Layout_Field__mdt>> section_field_map = new Map<String,List<AGN_ICL_Layout_Field__mdt>>();
        List<AGN_ICL_Layout_Field__mdt> fields = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_for_AGN__c != 'Clinic Admin' and Field_Of_HCP_or_HCA_AGN__c = 'SignUp' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
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
    
    @AuraEnabled
    public static Locator_Listing_AGN__c CreateNewClinic(Locator_Listing_AGN__c loc){
        AccountContactRelation ac = new AccountContactRelation();
        User u = [Select id,name,Country_code__c,LanguageLocaleKey,contactId,Email from User where ID=:UserInfo.getUserId() limit 1];
        String conid = u.ContactId;
        List<AccountContactRelation> acc_con = [SELECT AccountId,Account.name,Account.Recordtype.name,Account.IsPersonAccount,ContactId,EndDate,Id,IsActive FROM AccountContactRelation WHERE ContactId =:conid and Account.IsPersonAccount = true];
        if(acc_con.size()==1)
        {
            ac = acc_con.get(0);
        }
        /*List<Id> accid = new List<Id>();
for(AccountContactRelation acc : acc_con)
{
accid.add(acc.AccountId);
}
lIST<Account> acclst = [Select id,name from Account where Id IN: accid];
if(acclst.size()>0)
{

}
List<Locator_Listing_AGN__c> loclst = [Select id,name,Clinic_Admin_AGN__c from Locator_Listing_AGN__c where Account_AGN__c IN:accid];

if(acc_con.size()>0)
{
for(AccountContactRelation acc : acc_con)
{

if(acc.Account.IsPersonAccount == true)
{

ac = acc;
break;
}
}
}*/
        // ***Line of code has been added as a part of DCR Enablement***
        AssignmentRule AR = new AssignmentRule(); 
        AR = [select id,Name from AssignmentRule where SobjectType = 'Case' and Active = true and Name=: System.label.AGN_ICL_Case_Assignment_Rule limit 1];
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
        //cs.Country_AGN_GDPR__c = loc.Country_AGN__c;
        //cs.Country_Code_AGN__c = loc.Country_Code_AGN__r.Name;
        cs.Country_Code_AGN__c = [Select Country_Code__c from User where id = :UserInfo.getUserId()].Country_Code__c;
        cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_ICL_Clinic_Registration_AGN' LIMIT 1][0].Id;
        cs.setOptions(dmlOpts);
       // insert cs;
       //Adding checkmarx comment
             try{
                	List<Case> Caseinsert = new List<Case>();
           			Caseinsert.add(cs); 
                    String objAcc = 'Case';
                    SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(Caseinsert,accObjType,'INSERT');
                    insert Caseinsert;
            }
            catch(Exception ex)
            {
                System.debug('There is an exception for the Case insert:'+ex);
			}
        //End
        System.debug('cs::'+cs.id); 
// ***Line of code has been added as a part of DCR Enablement***
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:u.Country_Code__c limit 1];
       loc.Country_Code_AGN__c = Country_code.Id;
        //loc.Country_Code_AGN__c = AGN_ICL_UtlityClass.getsitecorecountry(Country_code.Alpha_2_Code_vod__c);
        loc.First_Level_Clinic_Approver_AGN__c = Country_code.First_Level_Clinic_Approver_AGN__c;
        //loc.Second_Level_Clinic_Approver_AGN__c =Country_code.Second_Level_Clinic_Approver_AGN__c;
        loc.User_Language_AGN__c = u.LanguageLocaleKey;
        loc.Active_AGN__c = False;
        loc.Registered_For_Clinic_Locator_AGN__c = TRUE;
        loc.Clinic_Admin_AGN__c = ac.AccountId;//loclst[0].Clinic_Admin_AGN__c;
        loc.Clinic_Admin_Email_AGN__c = u.Email;
        loc.IsChildClinic_AGN__c = TRUE;
        //***Line of code has been added as a part of DCR Enablement***
        loc.ICL_Registration_Case__c = cs.Id;
        loc.AGN_Person_Account__c =ac.AccountId;
        //***Line of code has been added as a part of DCR Enablement***
        //Updated code for cluster country logic as a part of ICL-Wave 3.
         List<AGN_ICL_Country_Settings__c> cus = AGN_ICL_Country_Settings__c.getall().values();
                  for(AGN_ICL_Country_Settings__c aic:cus)
                    {
                         if(Country_code.Alpha_2_Code_vod__c==aic.Country_AGN__c)
                             {
                                loc.Cluster_Country_AGN__c=aic.Site_core_country_AGN__c;
                             }
                        
                    }
        //End
        
        //------CheckMarx Phase2--Added on 24/09/2020----------
        list<Locator_Listing_AGN__c> loctinsert= new list<Locator_Listing_AGN__c>();
        loctinsert.add(loc);
        String objLoc = 'Locator_Listing_AGN__c';
        SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objLoc).newInstance())).getSObjectType();
        AGN_FLSCheck.check(loctinsert,locObjType,'INSERT');
        //------CheckMarx Phase2--Ends here----------
        try{
        insert loc;
        }
        catch(Exception ex)
        {
            System.debug('There is an exception for the Locator listing creation:'+ex);
        }
        return loc;
    }
    @AuraEnabled
    public static List<Locator_Listing_AGN__c> getNoOfLocatorListing(){
        User u = [Select id,Name,contactId from User where Id=: UserInfo.getUserId() LIMIT 1];
        
        List<AccountContactRelation > acc_con = [Select id,AccountId,ContactId from AccountContactRelation where ContactId =: u.contactId];
        List<Id> accid = new List<Id>();
        for(AccountContactRelation  ac : acc_con)
        {
            accid.add(ac.AccountId);
        }
        List<Locator_Listing_AGN__c> loclst = [Select id,name,Account_AGN__c,Street_AGN__c,City_AGN__c,State_Providence_Region_AGN__c,Zip_Code_AGN__c,Country_AGN__c,Phone_Number_AGN__c,Email_AGN__c from Locator_Listing_AGN__c where Active_AGN__c=true and Account_AGN__c IN: accid]; 
        return loclst;
    }
    
    @AuraEnabled
    public static String fetchUsercountry()
    {
        User u = [Select Country_Code__c from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.Country_Code__c;
    } 
    
    //TH CR Clinic Timing Disable 
    @AuraEnabled
    public static Boolean isClinicTimingEnabled(String countryCode)
    {      
        return AGN_ICL_UtlityClass.isClinicTimingEnabled(countryCode);
    } 
    //TH CR Clinic Timing Disable 
    // Duallist Box Logic added for Brand 
       @AuraEnabled
       public static String getMultipicklistBrandCount(){
       return AGN_ICL_UtlityClass.getMultipicklistBrand();
       }
     // Duallist Box Logic added for Brand
    
    @InvocableMethod(label='NotifyChildClinics')
    public static void SendNotificationToClinics(List<Locator_Listing_AGN__c>  locList) {
        
        String LocCountryCode = ''; 
        String LocLangCode = '';
        Boolean hasRecord = false;        
        List<EmailTemplate> eTList = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        
        Map<String, EmailTemplate> eTMap = new Map<String, EmailTemplate>(); 
        
        Integer  counter =0;        
        try{
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress LIMIT 1];           
            EmailTemplate objCS =[SELECT Id, Body, Description, 
                                  Name, Subject, Markup, 
                                  HtmlValue, DeveloperName  
                                  FROM EmailTemplate 
                                  WHERE DeveloperName ='AGN_ICL_Child_Clinic_Registration' LIMIT 1];
            
            
            for(Locator_Listing_AGN__c LocObj:locList){                   
                
                counter++;
                Messaging.SingleEmailMessage mailToClinic = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(LocObj.Clinic_Admin_Email_AGN__c);
                sendTo.add(LocObj.Email_AGN__c);
                mailToClinic.setOrgWideEmailAddressId(owea.Id);
                mailToClinic.setToAddresses(sendTo);
                mailToClinic.setTargetObjectId(UserInfo.getUserId());
                mailToClinic.setWhatId(LocObj.Id);        
                mailToClinic.setTreatTargetObjectAsRecipient(false);        
                mailToClinic.setSaveAsActivity(false);  
                mailToClinic.setCharset('UTF-8');
                mailToClinic.setTemplateId(objCS.id);          
                mails.add(mailToClinic);  
                ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(objCS.id, null, LocObj.id);
                emailLog.Subject_AGN__c =email.Subject;
                emailLog.From_AGN__c = fromEmailAddress;          
                emailLog.Body_AGN__c = email.getHtmlBody();
                emailLog.Sent_On_AGN__c = datetime.now();
                emailLog.To_AGN__c = AGN_ICL_SendEmailNotification.getStringValue(sendTo);
                logList.add(emailLog);
            }
            
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if(results.size() > 0){    
                integer i=0;
                for(Messaging.SendEmailResult result : results){          
                    logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                    i++;
                }   
                if(logList.size()>0){
                    //------CheckMarx Phase2--Added on 18/11/2020----------                        
                    String objlog = 'ICL_Email_Status_Log_AGN__c';
                    SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(logList,objlogType,'INSERT');
                    //------CheckMarx Phase2--Ends here----------
                    insert logList;  
                }                    
            }
        }
        catch(exception ex){
  
        }
        
    }
    
    // Updated as a part of production defect fix for Clinic admin details in detail page and clinic page not same.

    
     @Auraenabled
    public static String getclinicadminname()
    {
        User usr = [Select id,name,contactId,Country_Code__c from User where Id=: UserInfo.getUserId()];
        AccountContactRelation acr=[Select id,Account.name,ContactId,Account.recordtype.developername from AccountContactRelation where ContactId =: usr.contactId and Account.recordtype.developername in('Professional_vod','PersonAccount')];
        return acr.Account.name;
    }
    
    //Added as a part of Canada change for Two Column Layout
    @AuraEnabled
    public static Boolean isTwoLayerLayout(String countryCode)
    {   
        
        Boolean twolayerlayout = AGN_ICL_UtlityClass.isTwoLayerLayout(countryCode);
        return twolayerlayout;
        
    }
    //END
    
}