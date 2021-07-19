public class BusinessTaskAccept_GDPR_AGN_Controller {
        @AuraEnabled
    public static String acceptCase(Id caseId)
    {
        System.debug('Case ID+'+caseId);
       List<Case> caseObj = [select id, Status from Case where id =: caseId limit 1];
        if(caseObj[0].Status=='Under Review'){
            return 'underReview';
        }else if(caseObj[0].Status=='New'){
            Case c = new Case();
            c.Id = caseId;
            c.Status='Under Review';
            update c;
            return 'New';
        } else if(caseObj[0].Status=='Email Not Verified'){
            return 'notVerified';
            
        }else{
            return 'other';
        } 

    }

}