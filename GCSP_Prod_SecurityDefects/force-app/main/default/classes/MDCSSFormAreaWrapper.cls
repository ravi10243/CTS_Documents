/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Represents a form area which contains elements
* @Revisions      :    
*******************************************************************************/
public class MDCSSFormAreaWrapper 
{
	@AuraEnabled
    public String AreaKey
    {get;set;}
    
    @AuraEnabled
    public String ScreenLabel
    {get;set;}
    
    @AuraEnabled
    public List<MDCSSElementPropertyWrapper> ListElement
    {get;set;}
}