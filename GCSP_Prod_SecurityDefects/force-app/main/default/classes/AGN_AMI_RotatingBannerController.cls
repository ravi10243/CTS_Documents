/**************************************************************************************************************************
@ Class:          AGN_AMI_RotatingBannerController
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Controller class for AGN_AMI_RotatingBanner vf page.
@ PMO:            CR-3336: Rotating banner in AMI portal home page.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 04.07.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

public without sharing class AGN_AMI_RotatingBannerController {
    static final String METHODNAME1  = 'setBannerPopup';
    static final String CLASSNAME    = 'AGN_AMI_RotatingBannerController';
    public Static String Banner_id = 'bannerId';
    public List<AMI_Banner_AGN__c> banners {get;set;}    
    public AMI_Banner_AGN__c selectedBanner {get; set;}
    public Id bannerId {get; set;}
    public String userCountryCode {get; set;}
    public List<String> whitelistedURLs {get; set;}
    public AGN_AMI_RotatingBannerController() {
        
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();  
        userCountryCode =  userDetails.userCountryName;
        banners = [SELECT Id,BannerImageId_AGN_AMI__c, Behaviour_AGN_AMI__c,Link_AGN_AMI__c,
                   Vault_code_AGN_AMI__c,ButtonLabel_AGN_AMI__c,Sequence_AGN_AMI__c,
                   Button_Color_AGN_AMI__c, Button_Position_AGN_AMI__c, Font_Color_AGN_AMI__c
                   FROM AMI_Banner_AGN__c 
                   WHERE Active_AGN_AMI__c= true  
                   AND (Country_AGN_AMI__c =:userCountryCode or Global_AGN_AMI__c = true)
                   AND (Start_Date_AGN_AMI__c <= today OR Start_Date_AGN_AMI__c = null )
                   AND (End_Date_AGN_AMI__c >= today OR End_Date_AGN_AMI__c = null)
                   ORDER BY Sequence_AGN_AMI__c ASC NULLS LAST];
        whitelistedURLs = new List<String>();
        List<AMI_Whitelisted_URLs_AGN__mdt> whitelistRecords = [Select Domain_AGN_AMI__c from AMI_Whitelisted_URLs_AGN__mdt];
        for(AMI_Whitelisted_URLs_AGN__mdt whitelist : whitelistRecords){
            whitelistedURLs.add(whitelist.Domain_AGN_AMI__c);
        }
    }
    
    public PageReference setBannerPopup() {
        try{
            bannerId = ApexPages.currentPage().getParameters().get(Banner_id);
            selectedBanner = [SELECT Id, BannerImageId_AGN_AMI__c, Name, Behaviour_AGN_AMI__c,Action_Count_AGN_AMI__c, 
                              Link_AGN_AMI__c, Description_AGN_AMI__c,Vault_code_AGN_AMI__c,
                              ButtonLabel_AGN_AMI__c, TagLine_AGN_AMI__c 
                              FROM AMI_Banner_AGN__c 
                              WHERE Id = :bannerId 
                              LIMIT 1];
            
            if (Schema.sObjectType.AMI_Banner_AGN__c.fields.Action_Count_AGN_AMI__c.isUpdateable ()){
                selectedBanner.Action_Count_AGN_AMI__c = (selectedBanner.Action_Count_AGN_AMI__c != null) ? 
                    selectedBanner.Action_Count_AGN_AMI__c + 1 : 1;
            }
            
            if(Schema.sObjectType.AMI_Banner_AGN__c.isUpdateable ()){
                update selectedBanner;
            }
            
        }
        catch(Exception ex){
            AGN_AMI_ErrorLogger.createExceptionsLog(ex, CLASSNAME, METHODNAME1);    
        }
        PageReference pr = null;
        if(selectedBanner.Link_AGN_AMI__c!=null && selectedBanner.Behaviour_AGN_AMI__c == 'Direct Link') {
            pr = new PageReference(selectedBanner.Link_AGN_AMI__c);
            pr.setRedirect(true);
        }
        
        return pr;
    }
    
}