/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           GPSDataImport
* @version        1.0
* @created        03/12/2017
* @modified       27/11/2020 (RM, AB)   
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes   
   PMO 3408: Create Account Customer GPS Assessment records
   27 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/

global without sharing class GPSDataImport implements Database.Batchable<sObject>,Database.AllowsCallouts{
    private static Integer numberOfAssessmentsCreated = 0;
    global List<Account_GPS_Assessment__c> MainAccounts = new List<Account_GPS_Assessment__c>();
    global List<Id> lstProdUserMismatch = new List<Id>();
    global GPSDataImport(List<Account_GPS_Assessment__c> lstAcctGPSAssess,Id assessmentId)
    {
        System.debug('lstAcctGPSAssess');
        System.debug(lstAcctGPSAssess);
        System.debug('assessmentId');
        System.debug(assessmentId);
        //Id strAssessmentId=lstAcctGPSAssess.get(0).GPS_Assessment_AGN__c;
        List<My_Setup_Products_vod__c> lstUser=new List<My_Setup_Products_vod__c>();
        Set<Id> stUser=new Set<Id>();
        lstUser=[select OwnerId from My_Setup_Products_vod__c where Product_vod__c in (select Product_AGN__c from GPS_Assessment_Product_AGN__c where GPS_Assessment_AGN__c=:assessmentId)];
        
        for (My_Setup_Products_vod__c objMSPV : lstUser) {
            stUser.add(objMSPV.OwnerId);
        }
        //  strMismatchUser='<table>';
        for (Account_GPS_Assessment__c objAGA : lstAcctGPSAssess)
        {
            if(!stUser.Contains(objAGA.OwnerId))
            {
                lstProdUserMismatch.add(objAGA.OwnerId);
                //  strMismatchUser+='<tr><td>' + objAGA.OwnerId + '</td></tr>';
                // system.debug('mismatch:' + strMismatchUser);
            }
            else
            {
                GPSAssessmentUtils.setAccountAssessmentUniqueId(objAGA);
                MainAccounts.add(objAGA);
            }
        }
        //  strMismatchUser+='</table>';
        system.debug('MainAccounts:' + MainAccounts);
        system.debug('lstProdUserMismatch:' + lstProdUserMismatch);
        
    }
    global List<Account_GPS_Assessment__c> start(Database.BatchableContext BC)
    {
        return MainAccounts;
    }
    
    global void execute(Database.BatchableContext BC,List<Account_GPS_Assessment__c> scopeAcc)
        
    {
        // Deduplicate the list
        scopeAcc = new List<Account_GPS_Assessment__c>(new Set<Account_GPS_Assessment__c>(scopeAcc));
        Database.upsert(scopeAcc, Account_GPS_Assessment__c.Unique_ID_AGN__c, true);
        
        
        //PMO 3408: GPS Assessment: Start: By: RM, AB: Create Account Customer GPS Assessment records
        if(scopeAcc.size() > 0){
            
            //Get the parent GPS Assessment. Since it will be same for all the Account_GPS_Assessment__c records, we will take the first record
            Id parentGPSAssessmentId = scopeAcc[0].GPS_Assessment_AGN__c;
            
            //Get accountAssessmentId : Set<CustomerId> for all customers already added to this GPS assessment
            Map<Id, Set<Id>> accountAssessmentToAddedCustomersMap = new Map<Id, Set<Id>>();
            for(Account_Customer_GPS_Assessment_AGN__c accCust : [SELECT Customer_AGN__c, Account_GPS_Assessment_AGN__c FROM Account_Customer_GPS_Assessment_AGN__c
                                                                  WHERE Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__c = :parentGPSAssessmentId]
               ){
                   Set<Id> addedCustomers = accountAssessmentToAddedCustomersMap.get(accCust.Account_GPS_Assessment_AGN__c);
                   if(addedCustomers == null) addedCustomers = new Set<Id>();
                   addedCustomers.add(accCust.Customer_AGN__c);
                   accountAssessmentToAddedCustomersMap.put(accCust.Account_GPS_Assessment_AGN__c, addedCustomers);
               }
            
            //Get all accounts added to this GPS assessment
            Set<Id> accountsAddedInGPSAssessment = new Set<Id>();
            for(Account_GPS_Assessment__c accAssessment : scopeAcc){
                accountsAddedInGPSAssessment.add(accAssessment.Account_AGN__c);
            }
            
            //Get all the customers available to be added for all the accounts  
            List<Account> customersAvailableToAddForAllAccounts = [SELECT Id, Primary_Parent_vod__c
                                                                   FROM Account
                                                                   WHERE IsPersonAccount = true
                                                                   AND Primary_Parent_vod__c IN :accountsAddedInGPSAssessment
                                                                   ORDER BY Name];
            
            //Create GroupId : Set<CustomerId> maps for available customers
            Map<Id, Set<Id>> groupIdTocustomerIdsMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> territoryIdToCustomerIdsMap = new Map<Id, Set<Id>>();
            // Updated from AccountShare to ObjectTerritory2Association - TM2.0 Implementation
            for(ObjectTerritory2Association accShare : [SELECT ObjectId,Id,Territory2Id FROM ObjectTerritory2Association WHERE AssociationCause = 'Territory2Manual' AND ObjectId IN :customersAvailableToAddForAllAccounts]){
                Set<Id> customerIds = groupIdTocustomerIdsMap.get(accShare.Territory2Id);
                if(customerIds == null) customerIds = new Set<Id>();
                customerIds.add(accShare.ObjectId);
                territoryIdToCustomerIdsMap.put(accShare.Territory2Id, customerIds);
            }
            //System.debug('groupIdTocustomerIdsMap' + groupIdTocustomerIdsMap);
            
            //Create TerritoryId : Set<CustomerId> map for available customers
           	/* Removed as part of TM2.0 Implementation
            Map<Id, Set<Id>> territoryIdToCustomerIdsMap = new Map<Id, Set<Id>>();
            for(Group grp : [SELECT Id, RelatedId from Group where Type = 'Territory' AND Id IN :groupIdTocustomerIdsMap.keySet()]){
                territoryIdToCustomerIdsMap.put(grp.RelatedId, groupIdTocustomerIdsMap.get(grp.Id));
            }
            //System.debug('territoryIdToCustomerIdsMap'+territoryIdToCustomerIdsMap);
            */
            
            //Get all the owners for the Account_GPS_Assessment__c records
            Set<Id> allAvailableUserIds = new Set<Id>();
            for(Account_GPS_Assessment__c accAssessment : scopeAcc){
                allAvailableUserIds.add(accAssessment.OwnerId);
            }
            //System.debug('allAvailableUserIds'+allAvailableUserIds);
            
            //Create UserId : Set<TerritoryId> map for available users
            Map<Id, Set<Id>> userIdtoTerritoryIdMap = new Map<Id, Set<Id>>();
            for(UserTerritory2Association ut : [SELECT Id, UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN :allAvailableUserIds]){
                Set<Id> territories = userIdtoTerritoryIdMap.get(ut.UserId);
                if(territories == null) territories = new Set<Id>();
                territories.add(ut.Territory2Id);
                userIdtoTerritoryIdMap.put(ut.UserId, territories);
            }
            //System.debug('userIdtoTerritoryIdMap'+userIdtoTerritoryIdMap);
            
            //Create UserId : Set<CustomerId> map for available customers and users
            Map<Id, Set<Id>> userIdtoCustomerIdsMap = new Map<Id, Set<Id>>();
            for(Id userId : userIdtoTerritoryIdMap.keySet()){
                Set<Id> customerIds = userIdtoCustomerIdsMap.get(userId);
                if(customerIds == null) customerIds = new Set<Id>();
                for(Id territoryId : userIdtoTerritoryIdMap.get(userId)){
                    if(territoryIdToCustomerIdsMap.containsKey(territoryId)){
                        for(Id customerId : territoryIdToCustomerIdsMap.get(territoryId)){
                            customerIds.add(customerId);
                        }
                    }
                }
                userIdtoCustomerIdsMap.put(userId, customerIds);
            }
            //System.debug('userIdtoCustomerIdsMap'+userIdtoCustomerIdsMap);
            
            //List to store all the newly created Account_Customer_GPS_Assessment_AGN__c records
            List<Account_Customer_GPS_Assessment_AGN__c> accCustAssessmentList = new List<Account_Customer_GPS_Assessment_AGN__c >();  
            
            //For every newly created Account_GPS_Assessment__c
            for(Account_GPS_Assessment__c accAssessment : scopeAcc){
                
                Set<Id> addedCustomers = accountAssessmentToAddedCustomersMap.get(accAssessment.Id);
                if(addedCustomers == null) addedCustomers = new Set<Id>();
                
                //Find the customers to be associated with this account
                if(customersAvailableToAddForAllAccounts.size() > 0){
                    for(Account customer : customersAvailableToAddForAllAccounts){
                        if(customer.Primary_Parent_vod__c == accAssessment.Account_AGN__c && 
                           !addedCustomers.contains(customer.Id) &&
                           userIdtoCustomerIdsMap.get(accAssessment.OwnerId).contains(customer.Id)){		
                               
                               //Create Account_Customer_GPS_Assessment_AGN__c record for the customer
                               Id customerId = customer.Id;
                               
                               Account_Customer_GPS_Assessment_AGN__c  accCustAssessment = new Account_Customer_GPS_Assessment_AGN__c();
                               
                               if(Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.Account_GPS_Assessment_AGN__c.isCreateable()){	//Checkmarks
                                   accCustAssessment.Account_GPS_Assessment_AGN__c = accAssessment.Id;
                               } 
                               if(Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.Customer_AGN__c.isCreateable()){	//Checkmarks
                                   accCustAssessment.Customer_AGN__c = customerId;
                               }
                               if(Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.OwnerId.isCreateable()){	//Checkmarks
                                   accCustAssessment.OwnerId = accAssessment.OwnerId;
                               }
                               
                               accCustAssessmentList.add(accCustAssessment);
                               
                               //To ensure we don't create multiple AccountCustomerAssessment records for same Customer under same AccountAssessment
                               addedCustomers.add(customerId);
                               accountAssessmentToAddedCustomersMap.put(accAssessment.Id, addedCustomers);
                           }
                    }
                }
            }
            
            //Insert the newly created Account_Customer_GPS_Assessment_AGN__c records
            if(Schema.SObjectType.Account_Customer_GPS_Assessment_AGN__c.isCreateable()){	//Checkmarks
                insert accCustAssessmentList;
            }
        }        
        //PMO 3408: GPS Assessment: End: Create Account Customer GPS Assessment records
    }
    
    global void finish(Database.BatchableContext BC)
    {
        String strMailBody='';
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        
        String strMismatchUser='<html><head><style>table {border-collapse: collapse;}table, td, th {border: 1px solid black;}th {background-color: #e5e8e5;}</style></head><body><table><tr><th>User Id</th><th>User Name</th></tr>';
        
        List<user> lstUser=new List<user>();
        
        lstUser=[select Id,name from user where id in:lstProdUserMismatch];
        
        for(user objId:lstUser)
            strMismatchUser+='<tr><td>' + objId.Id + '</td><td>' + objId.Name + '</td></tr>';
        
        strMismatchUser=strMismatchUser+ '</table></body></html>';
        
        if(a.NumberOfErrors!=0)
            strMailBody+= ' Failure reason: ' + a.ExtendedStatus + '.';
        if(lstProdUserMismatch.size()>0)
            strMailBody+=' Following user do not have access to the product on which Assessment is created:</br></br> ' + strMismatchUser;
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Data Import Job in Account Segmentation Assessment is ' + a.Status);
        mail.setHtmlBody('The batch Apex job processed ' + a.TotalJobItems +
                         ' batches with '+ a.NumberOfErrors + ' failures.' + strMailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}