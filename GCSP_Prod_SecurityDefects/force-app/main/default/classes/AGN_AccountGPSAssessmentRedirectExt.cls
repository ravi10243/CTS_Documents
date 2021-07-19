public class AGN_AccountGPSAssessmentRedirectExt {

    public final Account acct;
    public List<GPS_Assessment__c> accountGPSAssessment = new List<GPS_Assessment__c>();
    List<User> user = new List<User>();
    Set<ID> UserIDs = new Set<ID>();
   
 
    
    
    public AGN_AccountGPSAssessmentRedirectExt(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();

    }
    

             
    public List<GPS_Assessment__c> getAssessments()
    {
        user= [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId() OR ManagerId = :UserInfo.getUserId()];
        
        for(User userId : user)
        {
            UserIDs.add(userId.id);
        }
        
        System.debug('User Ids:' + UserIDs);

        accountGPSAssessment = [Select Id, Name, Owner.name, Status_AGN__c from GPS_Assessment__c WHERE Id IN (SELECT GPS_Assessment_AGN__c FROM Account_GPS_Assessment__c WHERE Account_AGN__c = :acct.id AND (OwnerId = :UserIDs OR GPS_Assessment_AGN__r.owner.id =:UserIDs))];
        System.debug('accountGPSAssessment object: '+accountGPSAssessment);
        return accountGPSAssessment;
    }
    
    
}