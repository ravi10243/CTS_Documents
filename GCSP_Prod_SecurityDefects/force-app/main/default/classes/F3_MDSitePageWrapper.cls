public class F3_MDSitePageWrapper
{
    /******************
     * PageForm
    *******************/
    @AuraEnabled
    public MDForm__c DefaultPageForm {get;set;}
    
    //Localised Header Image
    /*@AuraEnabled 
    public String FormHeaderImage{get;set;}
    //Localised JSON CSS
    @AuraEnabled 
    public String FormJsonCss{get;set;}
    //Localised Portal Label*/
    @AuraEnabled
    public String recordTypeName{get;set;}
    @AuraEnabled
    public String FormPortalLabel{get;set;}
    
    //Localised Portal Description
    @AuraEnabled
    public String FormPortalDescription{get;set;}
    
    @AuraEnabled
    public String SaveButtonLabel{get;set;}
    
    @AuraEnabled
    public String SaveNextButtonLabel{get;set;}
    
    @AuraEnabled
    public String SavePreviousButtonLabel{get;set;}
   
    @AuraEnabled
    public String HelpText{get;set;}

    @AuraEnabled
    public String languageCode{get; set;}
    
    @AuraEnabled
    public String urlKey{get; set;}
    
    /******************
     * PageFormSteps
    *******************/
    @AuraEnabled
    public List<F3_MDFormStepWrapper> ListPageFormSteps {get;set;}
    
    @AuraEnabled
    public Id CurrentStepId{get;set;}
    
    /******************
     * PageFormStep
    *******************/
    @AuraEnabled
    public F3_MDFormStepWrapper PageFormStepWrapper {get;set;}
    
    /*****************
     * Page Form Branding JSON
     *****************/
    @AuraEnabled
    public List<MDCSSFormAreaWrapper> PageFormBrandingJSON {get;set;}
    
    /*****************
     * Page Form Property JSON
     *****************/
    @AuraEnabled
    public List<MDFormPropertyWrapper> PageFormPropertiesJSON {get;set;}
    
    @AuraEnabled
    public list<F3_PageLanguageSelectorController.languageTypes> languagesList {get;set;}
    
}