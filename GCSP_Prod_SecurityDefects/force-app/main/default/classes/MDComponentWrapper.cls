/*******************************************************************************
* @author         :    Wrapper class for MD Component
* @date           :    March 2019 
* @description    :    
* @Revisions      :    
*******************************************************************************/
public class MDComponentWrapper 
{
	@AuraEnabled
    public String ComponentId {get;set;}
    
    @AuraEnabled
    public String DeveloperName {get;set;}
     
    @AuraEnabled
    public String ComponentType {get;set;}
    
    @AuraEnabled
    public String ComponentTypeIcon {get;set;}
    
    @AuraEnabled
    public String ComponentTypeLabel {get;set;}
    
    @AuraEnabled
    public Decimal SortOrder {get;set;}
    
    @AuraEnabled
    public Boolean IsActive {get;set;}
}