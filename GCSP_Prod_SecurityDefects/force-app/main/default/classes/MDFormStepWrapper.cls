/*******************************************************************************
* @author         :    Wrapper class for MD FormStep
* @date           :    March 2019 
* @description    :    
* @Revisions      :    
*******************************************************************************/
public class MDFormStepWrapper 
{
	@AuraEnabled
    public String StepId {get;set;}
    
    @AuraEnabled
    public String DeveloperName {get;set;}
    
    @AuraEnabled
    public Decimal SortOrder {get;set;}
    
    @AuraEnabled
    public Boolean IsActive {get;set;}
    
    @AuraEnabled
    public List<MDComponentWrapper> ListComponent {get;set;}
}