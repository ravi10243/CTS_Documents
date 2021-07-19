public class AGN_GDPR_Case_Redirect_Controller {
    public string selectedLang{get;set;}
    
    public AGN_GDPR_Case_Redirect_Controller(){
        
    }
    
     public List<selectoption> getAvailableLanguages(){
      List<selectOption> options = new List<selectOption>();
       List<AGN_GDPR_Language_Settings__c> languageList = [select name,Language_Code_AGN__c,Language_Order_GDPR_AGN__c from AGN_GDPR_Language_Settings__c ORDER BY Language_Order_GDPR_AGN__c ASC];
      // for (AGN_GDPR_Language_Settings__c iso : AGN_GDPR_Language_Settings__c.getAll().values()){
       for(AGN_GDPR_Language_Settings__c iso :languageList){
        options.add(new SelectOption(iso.Language_Code_AGN__c,iso.Name));
        
        }
       return options;
    }
    
    public PageReference doRedirect() {
       pagereference ref = new pagereference('/apex/Case_GDPR_AGN?Lang='+selectedLang);
       ref.setredirect(true);
       return ref; 
        
    }

}