public without sharing class AGN_AMI_Maintenance_controller {
 	public string lang_code;
    public AMI_Language_AGN__c defLang {get; set;}
    
    public AGN_AMI_Maintenance_controller(){
        if(ApexPages.currentPage().getParameters().get('lang') != null)
            lang_code = ApexPages.currentPage().getParameters().get('lang');
        else
            lang_code = 'en_GB';
        
        defLang=AMI_Language_AGN__c.getvalues(lang_code)!=null?AMI_Language_AGN__c.getvalues(lang_code):AMI_Language_AGN__c.getvalues('en_GB');
    }    
}