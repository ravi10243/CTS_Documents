/*
Modified by :ICL Project Team
Description: Added new method getclinicadminname to show the Clinic admin details in detail page and clinic page same in ICL portal.
Release :ICL Wave-3
*/
public without sharing class AGN_ICL_ClinicDetailListCntrl {
    @AuraEnabled
    public static List<Locator_Listing_AGN__c> fetchClinicDetails()
    {
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
    public static String fetchUserDetails()
    {
        User u = [Select id,Name,contactId from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.Name;
    } 
    
    //TM2.0 Portal banner related change//
    @AuraEnabled
    public static boolean isSiteUnderMaintenance(){
        User u = [Select id,Country_Code__c  from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        String countryCode = u.Country_Code__c;
        if(countryCode != null){
            return AGN_ICL_Settings__c.getValues(countryCode).AGN_ICL_Maintenance_Alert__c;
            //return false;
        }
        return false;
    }
     //TM2.0 Portal banner related change//
    
     @AuraEnabled
    public static String fetchUsercountry()
    {
        User u = [Select Country_Code__c from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        return u.Country_Code__c;
    }
    @Auraenabled
    public static Boolean delClinicById(Locator_Listing_AGN__c loc)
    {
        Boolean success = false;
        loc.Active_AGN__c  = false;
        try{
        //------CheckMarx Phase2--Added on 24/09/2020----------
            list<Locator_Listing_AGN__c> loctoupdate= new list<Locator_Listing_AGN__c>();
            loctoupdate.add(loc);
            String objLoc = 'Locator_Listing_AGN__c';
                                SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objLoc).newInstance())).getSObjectType();
                                AGN_FLSCheck.check(loctoupdate,locObjType,'UPDATE');
            //------CheckMarx Phase2--Ends here----------
            update loc;
            success = true;
        }catch(Exception ex)
        {
            success = false;
        }
        return success;
    }
    
    
     @Auraenabled
    public static List<AccountNameHasLL> getAllAccounts()
    {
        User u = [Select id,name,contactId,Country_Code__c from User where Id=: UserInfo.getUserId() LIMIT 1];
        String countrycode = u.Country_Code__c;
        if(countrycode == 'AU')
        {
            countrycode = 'AN';
        }
        List<Child_Account_vod__c> childlst = new List<Child_Account_vod__c>();
        Map<String,AccountNameHasLL> accid_llmap = new Map<String,AccountNameHasLL>();
        String accid = '';
        String accname = '';
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String countrylst = portalSetting.OAM_Country_Code_using_contact_AGN__c;
        List<String> countrycodelst = countrylst.split(';');
        if(countrycodelst.contains(countrycode))
        {
            Contact con = [Select id,name,AccountId,Account.name from Contact where id =:u.ContactId limit 1];
            //Account acc = [Select id,name from Account where Id=:con.AccountId LIMIT 1];
            accid = con.AccountId;
            accname = con.Account.Name;
            
            childlst = [Select id,Child_Name_vod__c,name,Bill_To_AGN__c,Child_Account_Type_AGN__c,Child_Account_vod__r.isPersonAccount,Child_Account_vod__c,Country_Code__c,Parent_Account_vod__c,Ship_To_AGN__c,Sold_To_AGN__c from Child_Account_vod__c  where Parent_Account_vod__c =:con.AccountId AND Child_Account_vod__r.isPersonAccount = FALSE AND Ship_To_AGN__c = TRUE];
        }
        else
        {
            Contact con = [Select id,name,AccountId from Contact where id =:u.ContactId limit 1];
            Account acc = [Select id,name,Primary_Parent_vod__c,Primary_Parent_vod__r.name from Account where Id=:con.AccountId LIMIT 1];
            accid = acc.Primary_Parent_vod__c;
            accname = acc.Primary_Parent_vod__r.name;
            
            childlst = [Select id,Child_Name_vod__c,name,Bill_To_AGN__c,Child_Account_Type_AGN__c,Child_Account_vod__c,Child_Account_vod__r.isPersonAccount,Country_Code__c,Parent_Account_vod__c,Ship_To_AGN__c,Sold_To_AGN__c from Child_Account_vod__c  where Parent_Account_vod__c =:acc.Primary_Parent_vod__c AND Child_Account_vod__r.isPersonAccount = FALSE AND Ship_To_AGN__c = TRUE ];

        }
        
        AccountNameHasLL accl = new AccountNameHasLL();
        accl.AccId = accid;
        accl.Accname = accname;
        accl.HasLocatorListing = false;
        accl.IsLocatorListingActive = false;
        accl.LocatorListingId = null;
        accl.IsLLRejected = false;
        accl.IsSoldTo = true;
        accid_llmap.put(accid,accl);
        
        for(Child_Account_vod__c ch : childlst)
        {
            AccountNameHasLL al = new AccountNameHasLL();
            al.AccId = ch.Child_Account_vod__c;
            al.Accname = ch.Child_Name_vod__c;
            al.HasLocatorListing = false;
            al.IsLocatorListingActive = false;
            al.LocatorListingId = null;
            al.IsLLRejected = false;
            al.IsSoldTo = false;
            accid_llmap.put(ch.Child_Account_vod__c,al);
            
        }
        
        
        for(Locator_Listing_AGN__c loc : [Select id,Active_AGN__c,Account_AGN__c,Approval_Status__c,Second_Level_Clinic_Approver_AGN__c from Locator_Listing_AGN__c where Account_AGN__c IN:accid_llmap.keySet()])
        {
            
            if(accid_llmap.containsKey(loc.Account_AGN__c))
            {
                if(loc.Approval_Status__c == 'Approved' && loc.Active_AGN__c == false)
                {
                    accid_llmap.remove(loc.Account_AGN__c);
                }
                else
                {
                    AccountNameHasLL al = accid_llmap.get(loc.Account_AGN__c);
                    al.HasLocatorListing = true;
                    al.LocatorListingId = loc.Id;
                    if(loc.Active_AGN__c == true)
                    {
                        al.IsLocatorListingActive = true;
                    }
                    else if((loc.Approval_Status__c == 'Rejected'  && loc.Second_Level_Clinic_Approver_AGN__c == null) || loc.Approval_Status__c == 'Finally Rejected')
                    {
                        al.IsLLRejected = true;
                    }
                    accid_llmap.put(loc.Account_AGN__c,al);
                }
               
            }
        }
        
        return accid_llmap.values();
    }
    
    
    public class AccountNameHasLL
    {
        @Auraenabled public String AccId;
        @Auraenabled public String Accname;
        @Auraenabled public Boolean HasLocatorListing;
        @Auraenabled public String LocatorListingId;
        @Auraenabled public Boolean IsLocatorListingActive;
        @Auraenabled public Boolean IsLLRejected;
        @Auraenabled public Boolean IsSoldTo;
    }
    
     @Auraenabled
    public static void InactivateLocatorListing(String loclstId)
    {
        try{
            Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c from Locator_Listing_AGN__c where id=:loclstId];
            loc.Active_AGN__c = false;
            //------CheckMarx Phase2--Added on 24/09/2020----------
            list<Locator_Listing_AGN__c> loctoupdate= new list<Locator_Listing_AGN__c>();
            loctoupdate.add(loc);
            String objLoc = 'Locator_Listing_AGN__c';
                                SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objLoc).newInstance())).getSObjectType();
                                AGN_FLSCheck.check(loctoupdate,locObjType,'UPDATE');
            //------CheckMarx Phase2--Ends here----------
                update loc;

        }catch(Exception ex)
        {
            
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
    
}