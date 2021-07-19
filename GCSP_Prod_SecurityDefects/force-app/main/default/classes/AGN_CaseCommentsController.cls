/*
Type Name: AGN_CaseCommentsController
Reason: Controller class for Case Comments VF component.
03-08-2016 - SG - Initial Version
*/
public with sharing class AGN_CaseCommentsController {
    
    public list<AGN_CaseCommentWrapper> commentLineItems {get;set;}
    public integer deleteRowNumber {get;set;}
        
    public AGN_CaseCommentsController(){
            
    }
    
    public List<SelectOption> getItems() {
            
            User uInfo = [select Id, Country_Code__c,Position_AGN__c from User where Id =: UserInfo.getUserId()];
            List<SelectOption> options = new List<SelectOption>();
            for(AGN_Case_Comment_Type__c c : AGN_Case_Comment_Type__c.getAll().values()){
             if (uInfo.Country_Code__c == c.Country_Code__c)
             options.add(new SelectOption(c.Name,c.Name)); 

                else if ((c.Country_Code__c == 'All') && (uInfo.Position_AGN__c== c.Position_AGN__c))
                options.add(new SelectOption(c.Name, c.Name));
           
            }
            return options;
        }
    
    public void addComments(){
        commentLineItems.add(new AGN_CaseCommentWrapper());
    }
    
    public void deleteComments(){        
        commentLineItems.remove(deleteRowNumber-1);
    }
}