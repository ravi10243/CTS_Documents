public class F3_LEXCaseFormAndStepContext 
{	
    @AuraEnabled
    public String LEXFormId {get;set;}
    
    @AuraEnabled
    public String LEXFormStepId {get;set;}
    
    @AuraEnabled 
    public boolean IsFirstStep {get;set;}
    
    @AuraEnabled
    public boolean IsLastStep {get;set;}
}