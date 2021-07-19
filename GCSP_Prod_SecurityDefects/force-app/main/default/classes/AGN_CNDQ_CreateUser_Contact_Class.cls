public without sharing class AGN_CNDQ_CreateUser_Contact_Class {
    
    //Public Contact cont {get;set;}
    Public User portalUser {get;set;}
    public ID accountID = ApexPages.currentPage().getParameters().get('personAccId');
    public Account aID {get;set;}
    public Contact cID {get;set;}
    public Boolean isSuccess {get;set;}
    public String userLang {get;set;}
    
    Public AGN_CNDQ_CreateUser_Contact_Class(){
        isSuccess = false;
        userLang = Userinfo.getLanguage();
        portalUser = new user();
    }
    
    public PageReference cancel()
    {
        PageReference reRend = null;
        if(!String.isEmpty(accountID)){
            reRend = new PageReference('/'+accountID);
            reRend.setRedirect(true);
        }
        return reRend;
    }
    public PageReference save()
    {
        Boolean canManageExternalUsers = AGN_CNDQ_FindUserProfile.hasManageExternalUserPermission();
        if(!canManageExternalUsers)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_CNDQ_No_Permission)); //Custom label
            return null ;
        }
        
        if(String.isEmpty(accountID)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AGN_CNDQ_HCP_Not_Found); //Custom label
            ApexPages.addMessage(myMsg);
            return null;
        }
        try
        {
            integer existingUser=[select count() from user where Username=:portalUser.Username and isActive = True];
            
            if(existingUser>0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AGN_CNDQ_Dup_User); //Custom label
                ApexPages.addMessage(myMsg);
            }
            else
            { 
                //CC AG
                aId=[Select Id,FirstName,LastName,Primary_Parent_vod__c from Account where ID=:ApexPages.currentPage().getParameters().get('personAccId')];
                
                if(aId.Primary_Parent_vod__c != null)
                {
                    Contact newContact = new Contact();
                    //CC AG
                    if (Schema.sObjectType.Contact.fields.FirstName.isCreateable())
                    {
                        newContact.FirstName = portalUser.FirstName;
                    }
                    newContact.LastName = portalUser.LastName;
                    newContact.AccountId = aId.Primary_Parent_vod__c;
                    newContact.Email = portalUser.Email;
                    newContact.Phone = portalUser.Phone;
                    insert newContact; //Contact creation
                    
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = aId.Id;
                    acr.ContactId = newContact.Id;
                    acr.IsActive = true;
                    insert acr; //Account releationshipt creation
                    //CC AG
                    
                    if (Schema.sObjectType.AccountContactRelation.fields.ContactId.isAccessible())
                    {  
                      portalUser.ContactId = newContact.id;
                    }
                    String userString = JSON.serialize(portalUser);
                    createCommunityUser(userString);
                    isSuccess = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.AGN_CNDQ_UserCreated); //Custom label
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AGN_CNDQ_HCANotPresent_WithHCP); //Custom label
                    ApexPages.addMessage(myMsg);
                }
            }
        }
        Catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
            System.debug('Exception***' +ex.getMessage());
            return null;
        }
        return null;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    @future
    Public Static void createCommunityUser(String userString)
    {
        User newPortalUser = (User)JSON.deserialize(userString, User.class);
        
        string alias = generateRandomString(8);
        String getCoolnetPorfileId = (String)AGN_CNDQ_User_profile__c.getValues('Id').get('CoolNet_Profile_id_AGN__c');
        newPortalUser.Alias = alias;
        newPortalUser.CoolNet_International_User_AGN__c = true;
        newPortalUser.IsActive = true;
        newPortalUser.ProfileId = getCoolnetPorfileId; //custom settings
        insert newPortalUser;
        System.Debug('User Created ****' +newPortalUser);
    }
    
    public PageReference Redirect()
    {
        
        PageReference reRend = new PageReference('/'+portalUser.ContactId);
        reRend.setRedirect(true);
        return reRend;
    }
}