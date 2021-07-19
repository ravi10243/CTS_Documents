public class AGN_AMI_User_Deactivation_Helper 
{
    @InvocableMethod
    //To deactivate user if associated Account has been deactivated 
    public static void deactivateUser(List<Id> idList)
    {
        List<Id> contactIdList = new List<Id>();
        String updateUserJSON = '';
        List<User> updateUserList = new List<User>();
            
        List<AccountContactRelation> acrList = [Select contactId from AccountContactRelation 
                                                where AccountId in :idList and isDirect = false and Contact.is_AMI_Contact_AGN__c = true];
        for(AccountContactRelation acr : acrList)
        {
            contactIdList.add(acr.ContactId);
        }
        List<User> listUsers = [Select id, isActive, Country_code__c 
                                from User 
                                where (AccountId in :idList 
                                       or ContactId in :contactIdList)
                               ];
        Map<String, AMI_User_Settings_AGN__c> settings = AMI_User_Settings_AGN__c.getAll();
        for(User u : listUsers)
        {
            if(settings.containsKey(u.Country_code__c) && settings.get(u.Country_code__c).Allow_User_Deactivation_AGN__c)
            {
                u.isActive = false;
                updateUserList.add(u); 
            }
        }
        if(! updateUserList.isEmpty())
        {
            updateUserJSON = JSON.serialize(updateUserList);
            AGN_AMI_User_Deactivation_Helper.deactivateUserDML(updateUserJSON);
        }
            
    }
    
    @future
    public static void deactivateUserDML(String updateUserJSON)
    {
        List<User> updateUserList = new List<User>();   
        updateUserList = (List<User>)System.JSON.deserialize(updateUserJSON, List<User>.class);
        update updateUserList;
    }
}