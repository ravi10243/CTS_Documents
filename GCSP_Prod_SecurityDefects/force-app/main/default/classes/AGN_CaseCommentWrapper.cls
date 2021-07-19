/*
Type Name: AGN_CaseCommentWrapper
Reason: Wrapper class for CaseComment object.
03-08-2016 - SG - Initial Version
*/
public with sharing class AGN_CaseCommentWrapper {
    public CaseComment comment {get;set;}
    public string type {get;set;}
    
    public AGN_CaseCommentWrapper(){
    	comment = new CaseComment();
    }
    
}