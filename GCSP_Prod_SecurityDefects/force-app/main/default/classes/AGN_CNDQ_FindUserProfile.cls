public without sharing class AGN_CNDQ_FindUserProfile {
    
    private final Account acct;
    
    public AGN_CNDQ_FindUserProfile(ApexPages.StandardController stdController) 
    {
        this.acct = [select Id from Account where Id =: stdController.getId()][0];
    }
    

    public static Boolean hasManageExternalUserPermission(){
        //Boolean validTargetedProfile = false;
        Boolean canManageExternalUsers = [
            SELECT COUNT()
            FROM PermissionSetAssignment
            WHERE AssigneeId =: UserInfo.getUserId()
            AND PermissionSet.PermissionsManagePartners = true
        ] > 0;
        
        /*if(canManageExternalUsers){
            if(AGN_CNDQ_Profile_Ids__c.getValues('Ids').get('Allowed_Profile_IDs_AGN__c') != null 
               && !String.isEmpty((String)AGN_CNDQ_Profile_Ids__c.getValues('Ids').get('Allowed_Profile_IDs_AGN__c'))){
                   
                   Id currentUserProfileId = Userinfo.getProfileId();
                   String getAdminProfileId = (String)AGN_CNDQ_Profile_Ids__c.getValues('Ids').get('Allowed_Profile_IDs_AGN__c');
                   
                   //get allowed profile ids from custom setting
                   //split using comma (;) and put in a list of string
                   //loop the list and compare with currentUserProfileId
                   //if matches return true else return false
                   
                   List<String> getAdminProfileIdList = getAdminProfileId.split(',');
                   for(String profileId : getAdminProfileIdList)
                   {
                       if(profileId == currentUserProfileId)
                       {
                           validTargetedProfile = true;
                           break;
                       }
                   }
               }
            else{
                validTargetedProfile = true;
            }
        }
        */
        return canManageExternalUsers;
    }
    
    //If already CoolNet Portal User exist then redirect to Contact record
    //else check for logged in user has permission to create CoolNet Portal User
    //if yes then redirect to User creation page
    //else display error message
    public PageReference findUserProfile() {
        
        List<Id> contIdList = new List<Id>();
        List<User> userExist = new List<User>();
        String coolnetPorfileId = (String)AGN_CNDQ_User_profile__c.getValues('Id').get('CoolNet_Profile_id_AGN__c');
        
        for(AccountContactRelation acr : [select Id, ContactId from AccountContactRelation where AccountId =:acct.id])
        {
            contIdList.add(acr.ContactId);
        }
        if(contIdList.size() > 0)
        {
            //userExist = [select Id, ContactId from User where ContactId =:contIdList and CoolNet_International_User_AGN__c = true];
            userExist = [select Id, ContactId from User where ContactId =:contIdList and ProfileId =: coolnetPorfileId];
        }
        if(userExist.size() > 0)
        {
            PageReference reRend = new PageReference('/' + userExist[0].ContactId);
            reRend.setRedirect(true);
            return reRend;
        }
        else if(hasManageExternalUserPermission())
        {
            PageReference reRend = new PageReference('/apex/AGN_CNDQ_CreateUser_Contact?personAccId=' + acct.id);
            reRend.setRedirect(true);
            return reRend;
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_CNDQ_No_Permission)); //ToDo - Custom label implement
            return null;
        }
    }
}