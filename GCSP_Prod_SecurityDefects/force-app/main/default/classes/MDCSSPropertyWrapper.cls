/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Represents a CSS Property
* @Revisions      :    
*******************************************************************************/
public class MDCSSPropertyWrapper 
{
	@AuraEnabled
    public String PropertyKey
    {get;set;}
    
    @AuraEnabled
    public String PropertyValue
    {get;set;}
    
    @AuraEnabled
    public String PropertyType
    {get;set;}
    
    @AuraEnabled
    public String ScreenLabel
    {get;set;}
 	
    // Constructors
    public MDCSSPropertyWrapper()
    {
        
    }
    
    // Constructors
    public MDCSSPropertyWrapper(string propertyKey, string propertyValue)
    {
        this.PropertyKey = propertyKey;
        this.PropertyValue = propertyValue;
    }
}