public class F3_MDComponentWrapper {
	@AuraEnabled 
    public ID PageElementId {get;set;}
    
    @AuraEnabled 
    public String CurrentLanguageCode {get;set;}
    
    @AuraEnabled 
    public String DeveloperName {get;set;} 
    
    @AuraEnabled 
    public String PortalLabel {get;set;}
    
    @AuraEnabled 
    public String QuickHelpText {get;set;}
    
    @AuraEnabled 
    public String ContainerHtmlText {get;set;}
    
    @AuraEnabled 
    public String ContainerRichText {get;set;}
    
    @AuraEnabled
    public MDComponent__c PageElement {get;set;}
    
    @AuraEnabled
    public String DefaultValue {get;set;}
    
    @AuraEnabled
    public String OnChangeViewState {get;set;}
    
    @AuraEnabled
    public Boolean IsHidden {get;set;}
    
    @AuraEnabled
    public Boolean ReadOnly {get;set;}
    
    @AuraEnabled
    public String ElementType 
    {
    	get
        {
            if(this.PageElement != null)
                return this.PageElement.ComponentType__c;
            
            return '';
        }
    }
    
    public F3_MDComponentWrapper()
    {
        
    }
    
    public F3_MDComponentWrapper(MDComponent__c pgElement)
    {
        this.PageElement = pgElement;
    }
    /*****************
     * Page Form Branding JSON
     *****************/
    @AuraEnabled
    public MDCSSFormAreaWrapper PageFormComponentBrandingJSON {get;set;}
}