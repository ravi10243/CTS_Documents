/*******************************************************************************
* @author         :    Wrapper class for 
* @date           :    March 2019 
* @description    :    Controller class for ComponetsInDesigner Lightning Component
* @Revisions      :    
*******************************************************************************/
public class MDComponentInDesignerWrapper 
{
    @AuraEnabled
    public List<CMDTComponentWrapper> ListComponentType {get;set;}
    
    @AuraEnabled
    public List<MDFormStepWrapper> ListFormSteps {get;set;}
    
    @AuraEnabled
    public List<MDObjectFieldInfoWrapper> ListObjectField {get;set;}
}