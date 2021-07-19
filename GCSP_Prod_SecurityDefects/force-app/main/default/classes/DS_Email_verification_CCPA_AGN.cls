/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev
* @modifiedBy     Rajeev
* @maintainedBy   
* @version        2.0
* @created        
* @modified      03-Feb-2020
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
* USED BY PROCESS BUILDER DS_Email_verification_CCPA for Email Verification by DS.
*-------------------------------------------------------------------------------------------------------------------------+
*/

public class DS_Email_verification_CCPA_AGN 
{
    @InvocableMethod
    public static void DSEmailVerification(List<ID> caseIdList)
    {
        System.debug('ID   --> '+caseIdList[0]);
        ID caseId = caseIdList[0];
        List<RecordType> recordtype=[SELECT developerName FROM RecordType WHERE Id in(Select RecordTypeId  from Case where id=:caseId)];
        
        system.debug('recordtype : '+recordtype[0]);
        
        External_Email_Communication_GDPR_AGN__c ex = new External_Email_Communication_GDPR_AGN__c();
        ex.Associated_Case_GDPR_AGN__c=caseId;
        ex.Email_From_GDPR_AGN__c='System Owner';
        
        
        List<DS_Email_Verification_GDPR_AGN__c> emailVerificationObj;
        Case caseObj;
        boolean isEmailInsertReq = false;
        Group queueID=[select ID from Group where type='Queue' and Name='CCPA' limit 1];
        List<AGN_GDPR_Language_Settings__c> languageNameFetchList = [select name,Language_Code_AGN__c,Language_Order_GDPR_AGN__c from AGN_GDPR_Language_Settings__c WHERE Language_Code_AGN__c = 'en_US' ];
        List<Case> caseList = [select id,CaseNumber,E_Mail_Address_GDPR_AGN__c,DS_Email_Subject_GDPR_AGN__c,Data_Subject_Email_GDPR_AGN__c,Status,Titile_AGN_GDPR__c,First_Name_GDPR_AGN__c,Last_Name_GDPR_AGN__c,ownerid from Case where Id= :caseId];
        caseObj = caseList[0];
        
        ex.Email_Sent_To__c=caseList[0].Data_Subject_Email_GDPR_AGN__c;
        ex.Email_Subject_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNVSubj_CCPA;
        ex.Email_Body_GDPR_AGN__c=System.Label.AGN_WelcomeEmailNV_CCPA;
        
        try
        {
            //Not creatig External Email Communication record for CCPA Cases, implemented during Experian Integration
            if(recordtype[0].developerName != 'CCPA_Case'){
                Insert ex;
            }
            DS_Email_Verification_GDPR_AGN__c emailVar = new DS_Email_Verification_GDPR_AGN__c();
            emailVar.DS_Email_GDPR_AGN__c =caseObj.Data_Subject_Email_GDPR_AGN__c;
            emailVar.IsVerified_GDPR_AGN__c= false;
            emailVar.Language_GDPR_AGN__c=languageNameFetchList[0].name;
            emailVar.Language_Code_GDPR_AGN__c=languageNameFetchList[0].Language_Code_AGN__c;
            emailVar.Case_ID_GDPR_AGN__c = caseObj.CaseNumber;
            emailVar.Case_AGN__c = caseObj.Id;
            emailVar.Data_Subject_Name_AGN__c = (caseObj.First_Name_GDPR_AGN__c == null ? '' : caseObj.First_Name_GDPR_AGN__c) + ' ' + (caseObj.Last_Name_GDPR_AGN__c == null ? '' : caseObj.Last_Name_GDPR_AGN__c);
            Insert emailVar;
            System.debug('Email Inserted '+emailVar.Id);
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}