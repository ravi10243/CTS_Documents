/*
Name            : AGN_GDPR_RejectedCasePdfController
Created Date    : 05-OCT-2019
Developer Name  : CCPA/GDPR Case management project team
Purpose         : This controller is being called Used by VF AGN_GDPR_RejectCasePdfGenerator 
                for pdf generationon rejecting a task. This is populating the case fields in the Vf page which will be 
                stored as pdf after rejection.
*/
public class AGN_GDPR_RejectedCasePdfController {
    public Id  caseId{get;set;}
    public case caseList{get;set;}
    public AGN_GDPR_RejectedCasePdfController(ApexPages.StandardController stdController){
        caseId= Apexpages.currentPage().getParameters().get('caseId');
        this.caselist= [Select Id,Full_Name_GDPR_AGN__c, Street_Address_GDPR_AGN__c,Town_City_GDPR_AGN__c,
                        Zip_AGN_GDPR__c,Country_AGN_GDPR__c,DS_Email_Body_AGN__c from Case where Id= :caseId limit 1];  
    } 
    
}