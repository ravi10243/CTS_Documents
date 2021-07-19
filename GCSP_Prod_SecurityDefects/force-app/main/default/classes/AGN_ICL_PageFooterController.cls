/* Modified by :ICL Project Team
   Decription :Added line 40 to line 71 for displaying Vault Code at the footer section of the page for Latam Countries
   Release :ICL Wave-3
*/
//public class AGN_ICL_PageFooterController {
public without sharing class AGN_ICL_PageFooterController {  /* added without sharing for Spring'21 Release Updates */ 
    
    @AuraEnabled
    public static String getPrivacyLinkURL(String countryCode)
    {   
        String privacyLink = Label.AGN_ICL_Defualt_Privacy_Link;
        AGN_ICL_Country_Settings__c countrySetting = new AGN_ICL_Country_Settings__c();
        try{
            countrySetting = [SELECT Country_AGN__c,PrivacyLink_AGN__c 
                              FROM AGN_ICL_Country_Settings__c 
                              WHERE Country_AGN__c =:countryCode Limit 1];           
            if(String.isNotBlank(countrySetting.PrivacyLink_AGN__c)){
                privacyLink = countrySetting.PrivacyLink_AGN__c;
                return privacyLink;
            }
        }
        catch(exception ex){
            
        }        
        return privacyLink;
    }
    @AuraEnabled
    public static String getPrivacyLinkLoggedUser(){
        
         return AGN_ICL_UtlityClass.getPrivacyLinkLoggedUser();
        
    }
    
    @AuraEnabled
    public static String getPrivacyLinkURLFromLoc(string LocId){        
        return AGN_ICL_UtlityClass.getPrivacyLinkURLFromLoc(LocId);
    }
    
    //Added below code for Vault Code at the footer section of the page for Latam Countries
   
     @AuraEnabled
    public static String getVaultFromLoc(string LocId){        
        return AGN_ICL_UtlityClass.getVaultFromLoc(LocId);
    }
    @AuraEnabled
    public static String getFooter(String countryCode)
    {   
        String VaultCode;
        AGN_ICL_VaultCode__mdt countrySetting = new AGN_ICL_VaultCode__mdt();
        try{
            countrySetting = [SELECT Country_Code__c,Vault_value__c 
                              FROM AGN_ICL_VaultCode__mdt 
                              WHERE Country_Code__c =:countryCode Limit 1];           
            if(String.isNotBlank(countrySetting.Vault_value__c)){
                VaultCode = countrySetting.Vault_value__c;
                return VaultCode;
            }
        }
        catch(exception ex){
        
        system.debug('Exception for the method getfooter is:'+ex);
            
        }
        System.debug('VaultCode '+VaultCode);        
        return VaultCode;
    }
      @AuraEnabled
    public static String getVaultLoggedUser(){
        
         return AGN_ICL_UtlityClass.getVaultLoggedUser();
        
    }
      //End
}