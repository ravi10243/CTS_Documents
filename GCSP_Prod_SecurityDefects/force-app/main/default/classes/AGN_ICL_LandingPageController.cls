public class AGN_ICL_LandingPageController {

    public PageReference forwardToCommunityPage(){
        
         //String lang = ApexPages.currentPage().getParameters().get('lang');
         User currentUser = [Select id,name,Country_Code__c,contactId from User where Id =: UserInfo.getUserId() limit 1];
        String communitybaseurl = (String)AGN_ICL_Settings__c.getValues(currentUser.Country_Code__c).get('Community_Base_URL_AGN__c');
        String communitysuffix = (String)AGN_ICL_Settings__c.getValues(currentUser.Country_Code__c).get('ICL_Community_Portal_Suffix_AGN__c');
        //String communitybaseurl = (String)AGN_ICL_Portal_Settings__c.getInstance().ICL_Community_Portal_Base_URL_AGN__c;
        //String communitysuffix = (String)AGN_ICL_Portal_Settings__c.getInstance().ICL_Community_Portal_Suffix_AGN__c;
        List<AccountContactRelation > acc_con = [Select id,AccountId,ContactId from AccountContactRelation where ContactId =: currentUser.contactId];
        List<Id> accid = new List<Id>();
        for(AccountContactRelation  ac : acc_con)
        {
            accid.add(ac.AccountId);
        }
        List<Locator_Listing_AGN__c> loclst = [Select id,name,Account_AGN__c,Street_AGN__c,City_AGN__c,State_Providence_Region_AGN__c,Zip_Code_AGN__c,Country_AGN__c,Phone_Number_AGN__c,Email_AGN__c from Locator_Listing_AGN__c where Active_AGN__c=true and Account_AGN__c IN: accid]; 
        if(loclst.size()>1)
        {
            return new PageReference(communitybaseurl+ communitysuffix+'/s/agn-icl-cliniclistviewpage');
        }
   
        String lcid = loclst[0].Id;
        return new PageReference(communitybaseurl+ communitysuffix+'/s/agn-icl-detailpage?lcid='+lcid);
        //return null;
    }
}