/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Represents a form element to which CSS properties will be applied
* @Revisions      :    
*******************************************************************************/
public class MDCSSElementPropertyWrapper 
{
	@AuraEnabled
    public String ElementKey
    {get;set;}
    
    @AuraEnabled
    public String ScreenLabel
    {get;set;}
    
    @AuraEnabled
    public List<MDCSSPropertyWrapper> ListProperty
    {get;set;}
}