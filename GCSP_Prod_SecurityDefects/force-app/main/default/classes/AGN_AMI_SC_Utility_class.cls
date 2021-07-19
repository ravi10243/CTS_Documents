global without sharing class AGN_AMI_SC_Utility_class{
/* Updated with Cluster Country Logic 7/7/2020 - Start */
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c,Cluster_User_AGN__c,MA_User_Country_Code_AGN__c from User where Id =: UserInfo.getUserId() limit 1];}} 
    public static final String USERNAME_SUFFIX =  (String)AMI_User_Settings_AGN__c.getValues((uInfo.Cluster_User_AGN__c)?uInfo.MA_User_Country_Code_AGN__c:uInfo.Country_code__c).get('Username_Suffix__c');
    public static final String RECORD_OWNER = (String)AMI_User_Settings_AGN__c.getValues((uInfo.Cluster_User_AGN__c)?uInfo.MA_User_Country_Code_AGN__c:uInfo.Country_code__c).get('CR_Record_Owner__c');
    /* Updated with Cluster Country Logic 7/7/2020 - End */
    public static final String OWNER_ID = [SELECT ID FROM User where Username =: RECORD_OWNER LIMIT 1].Id;
    //public static List<Account> accountList;
    //public static string noAddressLabel = System.Label.AGN_AMI_NoRelated_Address;
    public class  AGN_AMI_SC_UserDetails {
        public String userLanguage;
        public String userCountryName;
        public user user;
        public User userRecord;
        public Account accountRecord;
        public Contact contactRecord;
        public String maskedUserCountryName;
        public AGN_AMI_SC_UserDetails() 
        {
            this.user = [Select  
                         //Fields from Account record
                         contact.Account.isPersonAccount, contact.Account.Id, 
                         contact.Account.AMI_Specialty_AGN__c, contact.Account.Type_AGN__c, 
                         contact.Account.Country_vod__c,
                         //Fields from Contact record
                         Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email, 
                         Contact.Salutation, contact.AccountId,
                         //Fields from User record
                         contactId, Cluster_User_AGN__c, MA_User_Country_Code_AGN__c, FirstName, LastName, 
                         Country_code__c, LanguageLocaleKey, Email, Profile.Id, UserType, Is_AMI_Demo_User_AGN__c
                         from user 
                         where id =: Userinfo.getUserid() 
                         limit 1];     
            // DQ - HCP Harmonization changes start
            system.debug('this.user.ContactId-->'+this.user.ContactId);
            //system.debug('IsDirect-->'+IsDirect);
            system.debug('Account.AGN_AMI_Enabled__c-->'+Account.AGN_AMI_Enabled__c);
            /* Added logic to check Account.AGN_AMI_SC_Enabled__c and Contact.Is_AMI_SC_Contact_AGN__c is true  for Specialty Care -START*/
            if(! user.contact.Account.isPersonAccount && user.UserType == 'CspLitePortal')
            {
                // Use this query to fetch all account and contact related information. 
                // Query on contact and account should not be made in any other pages.
                AccountContactRelation acr = [Select AccountId, ContactId,
                                              //Fields from Account record
                                              Account.Id, Account.AMI_Specialty_AGN__c, 
                                              Account.Type_AGN__c, Account.Country_vod__c,
                                              //Fields from Contact record
                                              Contact.Id, Contact.FirstName, Contact.LastName, Contact.Salutation, Contact.Email
                                              from AccountContactRelation 
                                              where ContactId =: this.user.ContactId 
                                              and IsDirect = false
                                              and (Account.AGN_AMI_Enabled__c = true 
                                                   or   Account.AGN_AMI_SC_Enabled__c = true)
                                              and (Contact.Is_AMI_Contact_AGN__c = true
                                                   or Contact.Is_AMI_SC_Contact_AGN__c = true)     
                                              Limit 1];
                this.userRecord = user;
                this.accountRecord = acr.Account;
                this.contactRecord = acr.Contact;
            }
            
            // PMO#2733 - Sales Rep Login Start
            /* Added logic to check Account.AGN_AMI_SC_Enabled__c and Contact.Is_AMI_SC_Contact_AGN__c is true  for Specialty Care - END */
            else if(user.UserType != 'CspLitePortal' && user.UserType != 'Guest')
            {
                String countryCode = (user.Cluster_User_AGN__c)?user.MA_User_Country_Code_AGN__c:user.Country_Code__c;
                String accountId = [Select Demo_Account_AGN__c from 
                  			AGN_AMI_SC_User_Setting__mdt where Label=:countryCode].Demo_Account_AGN__c;
                AccountContactRelation acr = [Select AccountId, ContactId,
                                              //Fields from Account record
                                              Account.Id, Account.AMI_Specialty_AGN__c, 
                                              Account.Type_AGN__c, Account.Country_vod__c,
                                              //Fields from Contact record
                                              Contact.Id, Contact.FirstName, Contact.LastName, Contact.Salutation, Contact.Email
                                              from AccountContactRelation 
                                              where AccountId =: accountId 
                                              and IsDirect = false
                                              and (Account.AGN_AMI_Enabled__c = true 
                                                   or   Account.AGN_AMI_SC_Enabled__c = true)
                                              Limit 1];
                this.userRecord = user;
                this.accountRecord = acr.Account;
                this.contactRecord = acr.Contact;
            }
            // Sales Rep Login End
            // DQ - HCP Harmonization backward compatibility start
            else
            {
                this.accountRecord = user.Contact.Account;
                this.contactRecord = user.Contact;
            }
            // DQ - HCP Harmonization backward compatibility start
            // DQ - HCP Harmonization changes end
            
            this.userLanguage = this.user.LanguageLocaleKey;
            if(! this.user.Cluster_User_AGN__c)
            {
                this.userCountryName = this.user.Country_code__c;
            }
            else
            {
                this.userCountryName = this.user.MA_User_Country_Code_AGN__c;
            }
            /*AMI MENA changes- Start*/ 
            if(user.UserType == 'Guest'){
                String externalCountry = ApexPages.currentPage().getParameters().get('country');
                List<AGN_AMI_MENA_Mapping__mdt> menaSettings1 = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from 
                                                                                                     AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:externalCountry ]) ;
                if(menaSettings1.size() > 0){
                    userCountryName=menaSettings1[0].AGN_AMI_Parent_Country_Code__c;
                }else{
                    userCountryName=externalCountry;
                }
            }
            List<AGN_AMI_MENA_Mapping__mdt> menaSettings2 = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from 
                                                                                                 AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:userCountryName ]) ;
            
            if(menaSettings2.size() > 0){
                for(AGN_AMI_MENA_Mapping__mdt m:menaSettings2){
                    maskedUserCountryName=userCountryName;
                    userCountryName=m.AGN_AMI_Parent_Country_Code__c;
                    
                }
            }else{
                maskedUserCountryName=userCountryName;
            }
            /*AMI MENA changes- End */
        } 
    }
}