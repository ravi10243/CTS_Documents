public class AGN_AMI_EJ_Update_Helper 
{
	@InvocableMethod
    //To updated or create AMI_HCP_Profile if the account is enabled in AMI Portal and its related Product Metrics is updated
    public static void updateHCPProfile(List<Id> idList)
    {
        List<Product_Metrics_vod__c> metrics = [SELECT Id,AMI_Education_Journey_AGN__c, Account_vod__c 
                                                FROM Product_Metrics_vod__c 
                                                WHERE Id in :idList];
        Map<String,String> eduJourneyMap = new Map<String,String>();
        for(Product_Metrics_vod__c metric : metrics)
        {
            eduJourneyMap.put(metric.Account_vod__c, metric.AMI_Education_Journey_AGN__c);
        }
        List<String> accIds = new List<String>(eduJourneyMap.keySet());
        List<AMI_HCP_Profile_AGN__c> oldProfiles = [Select Id, Account_AGN__c,AMI_Education_AGN__c 
                                                    from AMI_HCP_Profile_AGN__c 
                                                    where Account_AGN__c in :accIds];
        List<Account> accList = [Select id from Account where id in :accIds and AGN_AMI_Enabled__c = true];
        List<Id> accEnabledList = new List<Id>();
        for(Account acc : accList)
        {
            accEnabledList.add(acc.Id);
        }
        
        List<AMI_HCP_Profile_AGN__c> newProfiles = new List<AMI_HCP_Profile_AGN__c>();
        
        for(String accId : accIds)
        {
            if(! accEnabledList.contains(accId))
                continue;
            
            boolean flag = false;
            for(AMI_HCP_Profile_AGN__c ahp : oldProfiles)
            {
                if(ahp.Account_AGN__c == accId)
                {
                    flag = true;
                    ahp.AMI_Education_AGN__c = eduJourneyMap.get(accId);
                    newProfiles.add(ahp);
                }
            }
            if(! flag)
            {
                AMI_HCP_Profile_AGN__c ahp = new AMI_HCP_Profile_AGN__c(Account_AGN__c = accId, 
                                                                        AMI_Education_AGN__c = eduJourneyMap.get(accId), 
                                                                        HCP_Category_AGN__c = 'Knowledge seeker');
                newProfiles.add(ahp);
            }
            
            if(! newProfiles.isEmpty())
            {
                try
                {
                    upsert newProfiles;
                }
                catch(Exception e)
                {
                    System.debug(e.getMessage());
                    //AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Utility_class','updateHCPProfile');
                }
            }
        }
    }
}