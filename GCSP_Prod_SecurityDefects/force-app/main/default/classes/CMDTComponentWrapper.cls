/*******************************************************************************
* @author         :    Wrapper class for 
* @date           :    March 2019 
* @description    :    
* @Revisions      :    
*******************************************************************************/
public class CMDTComponentWrapper 
{
    @AuraEnabled
    public String RecordId {get;set;}
    
    @AuraEnabled
    public String DeveloperName {get;set;}
    
    @AuraEnabled
    public String Label {get;set;}
    
    @AuraEnabled
    public String IconName {get;set;}
    
    //@AuraEnabled
    //public String ComponentType {get;set;}
}