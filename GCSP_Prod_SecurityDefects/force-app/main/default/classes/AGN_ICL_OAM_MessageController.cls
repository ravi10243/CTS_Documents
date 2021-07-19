//public class AGN_ICL_OAM_MessageController {
public without sharing class AGN_ICL_OAM_MessageController {  /* added without sharing for Spring'21 Release Updates */

    @AuraEnabled
    public static Boolean isLocatorListingActive()
    {
        User u = [Select id,name,Locator_Listing_Id_AGN__c from User where id=:UserInfo.getUserId() limit 1];
        String loc_id = u.Locator_Listing_Id_AGN__c;
        Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c from Locator_Listing_AGN__c where id=:loc_id limit 1];
        //Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c from Locator_Listing_AGN__c where id='a7q5E0000008qF7' limit 1];
        return loc.Active_AGN__c;
    }
    
    @AuraEnabled
    public static Boolean isPendingforApprovalOrRejected()
    {
        User u = [Select id,name,Locator_Listing_Id_AGN__c from User where id=:UserInfo.getUserId() limit 1];
        String loc_id = u.Locator_Listing_Id_AGN__c;
        Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c,Second_Level_Clinic_Approver_AGN__c,Approval_Status__c from Locator_Listing_AGN__c where id=:loc_id limit 1];
        //Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c from Locator_Listing_AGN__c where id='a7q5E0000008qF7' limit 1];
        if(loc.Approval_Status__c == 'Rejected' && loc.Second_Level_Clinic_Approver_AGN__c != null)
        {
            return true;
        }
        else if(loc.Approval_Status__c == 'Finally Rejected')
        {
            return false;
        }
        else if(loc.Approval_Status__c == 'Rejected' && loc.Second_Level_Clinic_Approver_AGN__c == null)
        {
            return false;
        }
        return true;
    }
    
    
}