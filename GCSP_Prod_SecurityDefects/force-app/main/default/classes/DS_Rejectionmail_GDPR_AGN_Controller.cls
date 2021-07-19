public class DS_Rejectionmail_GDPR_AGN_Controller {
        @AuraEnabled
    public static String checkCase(Id caseId)
    {
        system.debug('Case id for Update:  ' +caseId);
        List<Case> cs = new List<Case>();
        cs=[SELECT Id,Status,DPO_Verified_the_Mail_Content_AGN__c,Mail_Sent_AGN__c,RejectCase_AGN__c from Case where Id= :caseId];
        System.debug('Case '+cs[0].Status);
        
        if(cs[0].RejectCase_AGN__c==true && cs[0].DPO_Verified_the_Mail_Content_AGN__c==True && cs[0].Mail_Sent_AGN__c==false)
        {
            
                Case c = new Case();
                c.Id = caseId;
                c.Mail_Sent_AGN__c=true;
               // c.Status='Closed';
                update c;
                System.debug('Good to go!!!');
                return 'Email Send';
           
        }
        
       else if(cs[0].Status=='Task Completed' && cs[0].DPO_Verified_the_Mail_Content_AGN__c==True && cs[0].Mail_Sent_AGN__c==false)
        {
           
                Case c = new Case();
                c.Id = caseId;
                c.Mail_Sent_AGN__c=true;
               // c.Status='Closed';
                update c;
                System.debug('Good to go!!!');
                return 'Email Send';
           
        }
        else
        {
            if(cs[0].Mail_Sent_AGN__c==true)
            {
                return 'Alraeady Sent';
            }
            else if(cs[0].DPO_Verified_the_Mail_Content_AGN__c==false)
            {
                 return 'NotVerifiedByDPO';
            }
            else
            {
                return 'Invalid Status';
                
            }
           
        }
        
    }

}