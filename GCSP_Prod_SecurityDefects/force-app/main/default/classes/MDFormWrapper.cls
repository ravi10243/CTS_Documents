/*******************************************************************************
* @author         :    Wrapper class for MD Form
* @date           :    March 2019 
* @description    :    
* @Revisions      :    
*******************************************************************************/
public class MDFormWrapper 
{
	@AuraEnabled
    public String FormId {get;set;}
    
    @AuraEnabled
    public String DeveloperName {get;set;}
    
    @AuraEnabled
    public String URLKey {get;set;}
    
    @AuraEnabled
    public List<MDFormStepWrapper> ListSteps {get;set;}
}