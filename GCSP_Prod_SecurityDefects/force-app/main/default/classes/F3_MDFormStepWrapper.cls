public class F3_MDFormStepWrapper {

    @AuraEnabled 
    public String PageFormStepId {get;set;}
    
    @AuraEnabled 
    public String ShortName {get;set;} 
    
    @AuraEnabled 
    public String PortalLabel {get;set;} 
    
    @AuraEnabled 
    public String StepType {get;set;} 
    
    @AuraEnabled 
    public String Description {get;set;}
	
    @AuraEnabled 
    public MDFormStep__c PageFormStep {get;set;}
    
    @AuraEnabled
    public String SaveButtonLabel{get;set;}
    
    @AuraEnabled
    public String SaveNextButtonLabel{get;set;}
    
    @AuraEnabled
    public String SavePreviousButtonLabel{get;set;}
    
    @AuraEnabled
    public List<F3_MDComponentWrapper> ListElements {get;set;}
    
    @AuraEnabled
    public String CurrentViewState {get;set;}
    ////////////////////////
    // Constructor
    ////////////////////////
    public F3_MDFormStepWrapper()
    {
        
    }
    
    public F3_MDFormStepWrapper(MDFormStep__c formStep)
    {
        //MDLocalisedFormStep__c localisedFormStep = formStep.MD_Localised_FormSteps__r[0];
        this.PageFormStepId = formStep.Id;
        this.PageFormStep = formStep;
        this.ShortName = formStep.LocalisedShortName__c;
        this.StepType = formStep.Type__c;
        this.CurrentViewState = formStep.OnLoadViewState__c;
        if(formStep.MD_Localised_FormSteps__r != NULL && !formStep.MD_Localised_FormSteps__r.isEmpty())
        	this.ShortName = formStep.MD_Localised_FormSteps__r[0].LocalisedShortName__c;
    }
    
    public F3_MDFormStepWrapper(MDFormStep__c formStep, List<F3_MDComponentWrapper> elements)
    {
        //MDLocalisedFormStep__c localisedFormStep = formStep.MD_Localised_FormSteps__r[0];
        this.PageFormStepId = formStep.Id;
        this.PageFormStep = formStep;
        this.ShortName = formStep.LocalisedShortName__c;
        this.StepType = formStep.Type__c;
        this.ListElements = elements;
        if(formStep.MD_Localised_FormSteps__r != NULL && !formStep.MD_Localised_FormSteps__r.isEmpty())
        this.ShortName = formStep.MD_Localised_FormSteps__r[0].LocalisedShortName__c;
    }
}