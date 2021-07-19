/*******************************************************************************
* @author         :    Pankaj Sontakke
* @date           :    March 2019 
* @description    :    Act as a property wrapper for MDForm Properties
* @Revisions      :    
*******************************************************************************/
public class MDFormPropertyWrapper 
{
	@AuraEnabled
    public String PropertyKey
    {get;set;}
    
    @AuraEnabled
    public String PropertyLabel
    {get;set;}
    
    @AuraEnabled
    public Boolean PropertyValue
    {get;set;}
}