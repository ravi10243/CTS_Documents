/*
Modified by :ICL Project Team
Description: Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
Release :ICL Wave-3
*/
 
global class AGN_ICL_Practitioner_Listing_Batch implements Database.Batchable<sObject>,Database.Stateful {
    
    // Get the details of Practioner Listing where Account is NULL
    // Database.executeBatch(new RunThisBatch(), 200);
    global Integer recordsProcessed = 0;
    public List<Id> accId = new List<Id>();
    
    
    
    public Map<Id,Practitioner_Listing_AGN__c> Practitioner_Map = new Map<Id,Practitioner_Listing_AGN__c>();
    //public List<Practitioner_Listing_AGN__c> pl = new List<Practitioner_Listing_AGN__c>();
    
    Id rcId = [SELECT Id from RecordType where SObjectType='Account' AND Name ='Professional_vod'].Id;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Practitioner_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,Clinic_AGN__c,
                                         Locator_Listing_AGN__c,Locator_Listing_AGN__r.Country_Code_AGN__c ,
                                         Locator_Listing_AGN__r.Country_Code_AGN__r.Country_Name_vod__c,
                                         Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c,
                                         Brand_AGN__c,Consent_AGN__c,CurrencyIsoCode,Email_AGN__c,Gender_AGN__c,
                                         Practitioner_Image_Available_AGN__c,Practitioner_Status_AGN__c,Qualification_AGN__c,
                                         Salutation_AGN__c,Status_AGN__c,Type_AGN__c,Type_Of_Physician_AGN__c ,Years_of_Experience_AGN__c,Locator_Listing_AGN__r.Account_AGN__c 
                                         FROM Practitioner_Listing_AGN__c Where Practitioner_AGN__c='']);   
    }
    
    global void execute(Database.BatchableContext bc, List<Practitioner_Listing_AGN__c> scope){
        // Create a new HCP with for those Pratitioner
        List<Practitioner_Listing_AGN__c> pl = new List<Practitioner_Listing_AGN__c>();
        List<Child_Account_vod__c> childAcc = new List<Child_Account_vod__c>();
        List<Account> accounts = new List<Account>();
        for (Practitioner_Listing_AGN__c pc: scope) 
        {      
            Account acc= new Account(); 
            
            acc.RecordTypeId=rcId;
            acc.FirstName= pc.First_Name_AGN__c;
            acc.LastName= pc.Last_Name_AGN__c;
            
            //acc.Primary_Parent_vod__c = pc.Clinic_AGN__c;
            //Added the below defect fix as a part of locator listing account mapping with the practitioner
            acc.Primary_Parent_vod__c=pc.Locator_Listing_AGN__r.Account_AGN__c;
            //End
            
            acc.Practitioner_Listing_Id__c = pc.Id;
            acc.PersonEmail = pc.Email_AGN__c;
            acc.Registered_For_Clinic_Locator_AGN__c = True;
            acc.Status_AGN__c = 'Pending Validation';
            acc.Country_vod__c =pc.Locator_Listing_AGN__r.Country_Code_AGN__c;
            //acc.Country_Code__c=pc.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c;
            
           // Changing the logic for cluster country go live as a part of ICL-Wave3 for Account country code
            
             Country_vod__c Ct = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Id =:pc.Locator_Listing_AGN__r.Country_Code_AGN__c];
             if(Ct.Cluster_Country_AGN__c==null)
        	{
           		acc.Country_Code__c = Ct.Alpha_2_Code_vod__c; 
        	}
        	else
        	{
         		acc.Country_Code__c = Ct.Cluster_Country_AGN__c;   
			}
            
            //End
            
            Practitioner_Map.put(pc.Id,pc);       
            accounts.add(acc);
            //------CheckMarx Phase2--Added on 24/09/2020----------
                     String objAccount = 'Account';
                     SObjectType accountObjType = ((SObject)(Type.forName('Schema.'+objAccount).newInstance())).getSObjectType();
                       AGN_FLSCheck.check(accounts,accountObjType,'INSERT');
              //------CheckMarx Phase2--Ends here----------
            //recordsProcessed = recordsProcessed + 1;
        }       
        List<String> acclist = new List<String>();
        if(accounts.size()>0)
        {
            try {
                //insert accounts;
                Database.SaveResult[] srList = Database.insert(accounts, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        acclist.add(sr.getId());
                        
                    }
                }
               
                for(Account a: [Select id,name,Practitioner_Listing_Id__c,Primary_Parent_vod__c from Account where id IN :acclist])
                {
                    String DCR_note ='Success';
                    //accId.add(a.Id); //Id of newly inserted Accounts
                    Child_Account_vod__c ChAcc = new Child_Account_vod__c();
                    ChAcc.Child_Account_vod__c = a.Id;
                    ChAcc.Parent_Account_vod__c = a.Primary_Parent_vod__c;
                    ChAcc.Copy_Address_vod__c = True;
                    ChAcc.External_ID_vod__c = a.Primary_Parent_vod__c+'__'+a.Id;                    
                    childAcc.add(ChAcc);
                    //------CheckMarx Phase2--Added on 24/09/2020----------
                        String objChildaccount = 'Child_Account_vod__c';
                        SObjectType childaccountObjType = ((SObject)(Type.forName('Schema.'+objChildaccount).newInstance())).getSObjectType();
                        AGN_FLSCheck.check(childAcc,childaccountObjType,'INSERT');
                     //------CheckMarx Phase2--Ends here----------
                    
                    AGN_Account_SendToDP_DCR.createDCR(a.Id, DCR_note);
                   
                    if(Practitioner_Map.containsKey(a.Practitioner_Listing_Id__c))
                    {
                        Practitioner_Listing_AGN__c pcupdate =new Practitioner_Listing_AGN__c();
                        pcupdate = Practitioner_Map.get(a.Practitioner_Listing_Id__c);
                        pcupdate.Practitioner_AGN__c = a.Id;
                        pl.add(pcupdate);
                        
                    }
                    
                    
                }
              
                if(pl.size()>0)
                {
                    
                    Database.update(pl);
                    Database.insert(childAcc);
                    
                    
                } 
               
            }
            catch(DmlException e) {
                
            }
            catch(Exception ex){
               
            }
        }
        
        
    }
    
    
    
    global void finish(Database.BatchableContext bc)
    {
        
    }    
}