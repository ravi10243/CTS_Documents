/*****************************************************************************************************************************************************************
Apex  Class- AGN_findAccountEmailSet
Description- This is a helper class for AGN_ContractExhibitUniqueEmailFinder.This class prepares the list of all the accounts and is used 
             to identify, if the email address present in contract exhibit(independent of contract language) is already present in Account. If yes, then no email notification is to be triggred
             for email address in contract exhibit. 
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/

public with sharing class AGN_findAccountEmailSet {
    public static Set<String> accEmailSet; 
    
    public static Set<String> findEmailSet(){
    String emailAddrs;accEmailSet=new Set<String>();
       for(Account accEmail: 
                [Select Email_Internal_AGN__c,PersonEmail from Account where RecordType.Name = 'Professional_vod' 
                  and GDPR_Notification_Received_AGN__c=True and (Email_Internal_AGN__c != null OR PersonEmail != null)
                    and Account.country_code__c in ('AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IS','IE','IT','LV','LI','LT','LU','MT','NL','NO','PL','PT','RO','SK','SI','ES','SE','CH','GB') ]){ 
                    if(accEmail.Email_Internal_AGN__c!=null){
                        emailAddrs=accEmail.Email_Internal_AGN__c;
                    }
                    addEmailInSet(emailAddrs);
                    
                    if(accEmail.PersonEmail!=null){
                       emailAddrs=accEmail.PersonEmail; 
                    }
                    addEmailInSet(emailAddrs); 
                    
            }
        return accEmailSet;
    }
    
    public static void addEmailInSet(String emailAddrs){
       if(!accEmailSet.contains(emailAddrs)){
           accEmailSet.add(emailAddrs);
         } 
    }
    
    public static boolean ifEmailExists(String email, Set<String> emailSet){
        if(emailSet.contains(email)){
            return True;
        }
        return false;
    }

}