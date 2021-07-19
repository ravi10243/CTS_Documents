/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      10-Feb-2020
* @testClass     
* @Class Name    AGNCCPAEmailLinkExpiration
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
*  Apex Controller to check if an email link is expired after 24hours in CCPA/Contact Center and then updates the case and closes the associated case. 
*-------------------------------------------------------------------------------------------------------------------------------+
*/
public class AGNCCPAEmailLinkExpiration {
    @InvocableMethod
    //Method to update the Case on the basis of link expiration.
    public static void LinkExpireUpdate(List<ID> DSEmailId)
    {
        ID DSEmlId = DSEmailId[0]; // Will recieve a single record always.
        DS_Email_Verification_GDPR_AGN__c dsemlVerif = [Select Id,Case_AGN__c,
                                                        Case_ID_GDPR_AGN__c,
                                                        IsExpired_AGN__c,
                                                        IsVerified_GDPR_AGN__c,
                                                        Case_AGN__r.Status from 
                                                DS_Email_Verification_GDPR_AGN__c where Id = :DSEmlId];   
        
        //Checks if Email Verification is still pending after 24 hours.
        //Excluding closed Cases from link expiration logic, implemented during Experian Integration
        
        if(dsemlVerif.Case_AGN__r.Status != 'Closed' && dsemlVerif.IsVerified_GDPR_AGN__c == false)
        {
            DS_Email_Verification_GDPR_AGN__c dseml = new DS_Email_Verification_GDPR_AGN__c();
            dseml.Id = DSEmlId;
            dseml.IsExpired_AGN__c= true;
            
            Case caseObj = New Case();
            caseObj.Id = dsemlVerif.Case_AGN__c;
            caseObj.OwnerId = [SELECT DeveloperName,Email,Id,Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CCPA_Queue_AGN'].Id;
     
            try
            {
                update dseml;
                update caseObj;
                System.debug('Case and DS Updated once');
            }
            catch(DmlException e)
            {
                System.debug('DML Error Occured!! '+e);
            }
            catch(Exception e)
            {
                System.debug('Error Occured!! '+e);
            }
            
            Case caseObjStatusUpdate = New Case();
            caseObjStatusUpdate.Id = dsemlVerif.Case_AGN__c; 
            caseObjStatusUpdate.Status='Closed';
            
            try
            {
                Update caseObjStatusUpdate;   
                System.debug('Case Updated Status Closed');
            }
            catch(DmlException e)
            {
                System.debug('DML Error Occured!! '+e);
            }
            catch(Exception e)
            {
                System.debug('Error Occured!! '+e);
            }    
        }
        
    }
    
}