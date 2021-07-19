public class F3_LEXCaseFormStepWrapper 
{
	@AuraEnabled
    public String LEXStepId {get;set;}
    
    @AuraEnabled
    public String CaseFormObjectAPIName {get;set;}
    
    @AuraEnabled
    public String CaseRelationshipFieldAPIName {get;set;}
    
    @AuraEnabled
    public String CaseFormObjectRecordId {get;set;}
    
    @AuraEnabled
    public List<F3_MDComponentWrapper> ListComponent {get;set;}
    
    @AuraEnabled
    public String CurrentViewState {get;set;}
}