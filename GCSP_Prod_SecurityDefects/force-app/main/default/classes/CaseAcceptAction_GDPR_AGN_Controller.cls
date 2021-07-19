public class CaseAcceptAction_GDPR_AGN_Controller {
    
    @AuraEnabled
    public static String acceptCase(Id caseId)
    {
        System.debug('Case ID+'+caseId);
        List<Case> caseObj = [select id,RejectCase_AGN__c,Status,RecordType.DeveloperName,Deletion_Status_AGN__c,Request_Type_GDPR_AGN_new__c from Case where id =: caseId limit 1];
        
        if(caseObj[0].Status=='Under Review')
        {
            return 'underReview';
        }
        else if(caseObj[0].Status=='New'  && caseObj[0].RejectCase_AGN__c==false)
        {
            if((caseObj[0].RecordType.DeveloperName == 'CCPA_Case' || caseObj[0].RecordType.DeveloperName == 'Contact_Center_AGN' ) && caseObj[0].Deletion_Status_AGN__c =='DS Approved' && caseObj[0].Request_Type_GDPR_AGN_new__c =='Deletion')
            {
               Case c = new Case();
                c.Id = caseId;
                c.Status='Under Review';
                update c;
                return 'New';
            }
            else
            {
                return 'deletionInvalid';   
            }
        }
        else if(caseObj[0].Status=='Email Not Verified')
        {
            return 'notVerified';
            
        }
        else if(caseObj[0].RejectCase_AGN__c==true)
        {
            return 'CaseRejected';
            
        }
        else
        {
            return 'other';
        } 
        
    }
}