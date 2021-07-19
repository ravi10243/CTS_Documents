public class AGN_AMI_Speciality_Update_Helper 
{
    @InvocableMethod
    public static void updateAccounts(List<Id> idList)
    {
        Map<String, AMI_User_Settings_AGN__c> userSettings = AMI_User_Settings_AGN__c.getAll();
        List<Account> accList = [Select id, Specialty_1_AGN__r.Name, Specialty_Allergan_1_AGN__r.Name, AMI_Specialty_AGN__c, Country_vod__r.Name 
                                 from Account 
                                 where Id in :idList];
        system.debug(accList);
        List<String> specList = new List<String>();
        for(Account acc : accList)
        {
            specList.add(acc.Specialty_Allergan_1_AGN__r.Name);
            specList.add(acc.Specialty_1_AGN__r.Name);
        }
        system.debug(specList);
        List<AMI_SPecality_AGN__c> amiSpecList = [Select id, Country_Code_AGN__c, Allergan_Speciality_Name_AGN__c 
                                                  from AMI_SPecality_AGN__c 
                                                  where Allergan_Speciality_Name_AGN__c in :specList];
        system.debug(amiSpecList);
        Map<String,String> specMap = new Map<String,String>();
        for(AMI_SPecality_AGN__c spec : amiSpecList)
        {
            specMap.put(spec.Allergan_Speciality_Name_AGN__c + '__' + spec.Country_Code_AGN__c, spec.Id);
        }
        system.debug(specMap);
        List<Account> accUpdateList = new List<Account>();
        for(Account acc : accList)
        {
            Account tempAcc = new Account(Id = acc.Id);
            if(userSettings.keySet().contains(acc.Country_vod__r.Name))
            {
                if(userSettings.get(acc.Country_vod__r.Name).Country_Managed_Specialty_AGN__c)
                {
                    tempAcc.AMI_Specialty_AGN__c = specMap.get(acc.Specialty_Allergan_1_AGN__r.Name + '__' + acc.Country_vod__r.Name);
                }
                else
                {
                    tempAcc.AMI_Specialty_AGN__c = specMap.get(acc.Specialty_1_AGN__r.Name + '__' + acc.Country_vod__r.Name);
                }
            }
            accUpdateList.add(tempAcc);
        }
        
        system.debug(accUpdateList);
        update accUpdateList;
    }
}