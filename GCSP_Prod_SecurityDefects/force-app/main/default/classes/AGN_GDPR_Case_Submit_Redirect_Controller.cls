public class AGN_GDPR_Case_Submit_Redirect_Controller {
    public string selectedLang{get;set;}
    public String caseObjectID { get; set; }
    public AGN_GDPR_Case_Submit_Redirect_Controller(){
        selectedLang = apexpages.currentpage().getparameters().get('Lang');
        caseObjectID = apexpages.currentpage().getparameters().get('CaseID');
        System.debug('Value of caseObjectID'+caseObjectID);
    }
    /*
       public PageReference doRedirect() {
       pagereference ref = new pagereference('/apex/AGN_GDPR_Email_Verification?Lang='+selectedLang +'&CaseID=' + caseObjectID);
       ref.setredirect(true);
       return ref; 
        
    }
    */
}