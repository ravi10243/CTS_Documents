/*
Type Name: AGN_CustomerDeleteRecords
Reason: Schedulable class for deleting incomplete customer registrations and deactivating user logins.
02-05-2017 - SG - Initial Version
30-06-2019 - AG - implemented unassign Okta groups
*/
global class AGN_CustomerDeleteRecords implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        Integer numberOfDays = Integer.ValueOf(System.Label.AGN_Customer_Portal_NumberOfDaysforUserDeactivation);
        Date thresoldDate = Date.Today().addDays(-numberOfDays);
        
        //Date.valueOf(System.Label.AGN_Customer_Portal_Number_of_Days_for_User_Deactivation);
        List<Case> cases = new List<Case>();
        //List<Account> accounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>(); //Added by AG
        List<User> users = new List<User>();
        List<Allergan_Customer_Registration_AGN__c> customers = new List<Allergan_Customer_Registration_AGN__c>();
        
        for(Allergan_Customer_Registration_AGN__c cr : [SELECT Id, 
                                                        Account_AGN__c, 
                                                        Case_AGN__c,
                                                        Case_AGN__r.ContactId 
                                                        FROM Allergan_Customer_Registration_AGN__c 
                                                        WHERE RecordType.DeveloperName = 'New'
                                                        AND createddate < :thresoldDate 
                                                        AND Online_Registration_Step_AGN__c <> null 
                                                        AND Online_Registration_Step_AGN__c = '2' 
                                                        AND Case_AGN__r.Origin = 'Web'])
        {
            cases.add(new Case(Id = cr.Case_AGN__c));
            //accounts.add(new Account(Id = cr.Account_AGN__c));
            
            //accountIds.add(cr.Account_AGN__c); //Commented by AG
            
            //For single contact approach 
            //Account_AGN__c will not be null 
            //but Case_AGN__r.ContactId will be null
            if(cr.Account_AGN__c !=null){
                accountIds.add(cr.Account_AGN__c);
            }
            //For multiple contact approach 
            //Account_AGN__c will be null 
            //but Case_AGN__r.ContactId will not be null
            if(cr.Case_AGN__r.ContactId !=null){
                contactIds.add(cr.Case_AGN__r.ContactId);
            }
            customers.add(cr);
        }
        
        for(User u : [SELECT Id, IsActive,
                      IsPortalEnabled, 
                      AccountId, 
                      FederationIdentifier,
                      Country_Code__c,
                      Account.Okta_Id_AGN__c,
                      Contact.Okta_Id_AGN__c 
                      FROM User WHERE AccountId IN : accountIds OR ContactId IN : contactIds])
        {
            u.IsActive = false;
            u.IsPortalEnabled = false;
            u.FederationIdentifier = null; //Added by AG
            users.add(u);
        }
        
        deactivateUsers(JSON.serialize(users));
        DataBase.delete(customers);
        DataBase.delete(cases);
        //DataBase.delete(accounts);
        
        //AG - unassign Okta groups
        AGN_CustomerUnAssignOktaGroupsBatch oktaGrpUnassignBatch = new AGN_CustomerUnAssignOktaGroupsBatch(users);
        //Callout limit per transaction is 100
        //In general if executed method has N callouts then batch size will be 100/N
        //our executed method has 2 callouts (currently we have max 2 groups), so ideal batch size will be 50
        
        Database.executeBatch(oktaGrpUnassignBatch, 30);
    }
    
    @future
    global static void deactivateUsers(String userList){
        List<User> users = (List<User>)JSON.deserialize(userList, List<User>.class);
        DataBase.update(users);
    }
}